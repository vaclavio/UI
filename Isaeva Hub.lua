local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")

local WindowMethods = {}
local TabMethods = {}
local SectionMethods = {}
local GroupMethods = {}

local Library = {}

local fastTween = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local midTween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function create(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    return instance
end

local function connect(window, signal, callback)
    local connection = signal:Connect(callback)
    table.insert(window._connections, connection)
    return connection
end

local function tween(instance, tweenInfo, properties)
    local t = TweenService:Create(instance, tweenInfo, properties)
    t:Play()
    return t
end

local function safeCall(callback, ...)
    if typeof(callback) == "function" then
        task.spawn(callback, ...)
    end
end

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end
    if value > maximum then
        return maximum
    end
    return value
end

local function countDecimals(value)
    value = tonumber(value)
    if not value then
        return 0
    end
    local text = string.format("%.8f", math.abs(value))
    text = text:gsub("0+$", "")
    local dot = text:find("%.")
    if not dot then
        return 0
    end
    return #text - dot
end

local function roundToDecimals(value, decimals)
    decimals = math.max(0, math.floor(tonumber(decimals) or 0))
    local multiplier = 10 ^ decimals
    if value >= 0 then
        return math.floor(value * multiplier + 0.5) / multiplier
    end
    return math.ceil(value * multiplier - 0.5) / multiplier
end

local function roundToStep(value, step, minimum, decimals)
    if step <= 0 then
        if decimals and decimals > 0 then
            return roundToDecimals(value, decimals)
        end
        return value
    end
    local rounded = minimum + math.floor(((value - minimum) / step) + 0.5) * step
    local places = decimals
    if places == nil then
        places = math.max(countDecimals(step), countDecimals(minimum))
    end
    if places > 0 then
        rounded = roundToDecimals(rounded, places)
    end
    return rounded
end

local function lerpUDim2(a, b, alpha)
    return UDim2.new(
        a.X.Scale + (b.X.Scale - a.X.Scale) * alpha,
        a.X.Offset + (b.X.Offset - a.X.Offset) * alpha,
        a.Y.Scale + (b.Y.Scale - a.Y.Scale) * alpha,
        a.Y.Offset + (b.Y.Offset - a.Y.Offset) * alpha
    )
end

local themeColorKeys = {
    "Background",
    "Window",
    "Panel",
    "Card",
    "Control",
    "ControlHover",
    "Stroke",
    "Text",
    "SubText",
    "Accent",
    "AccentDark",
    "Success"
}

local ThemeOrder = {
    "Isaeva",
    "Vaclav",
    "Midnight",
    "Ember",
    "Emerald",
    "Ocean",
    "Sunset",
    "Graphite",
    "Sakura",
    "Frost",
    "Forest"
}

local ThemePresets = {
    Isaeva = {
        Background = Color3.fromRGB(10, 10, 10),
        Window = Color3.fromRGB(26, 26, 26),
        Panel = Color3.fromRGB(22, 22, 22),
        Card = Color3.fromRGB(20, 20, 20),
        Control = Color3.fromRGB(30, 30, 30),
        ControlHover = Color3.fromRGB(39, 39, 39),
        Stroke = Color3.fromRGB(108, 77, 83),
        Text = Color3.fromRGB(240, 236, 238),
        SubText = Color3.fromRGB(178, 168, 171),
        Accent = Color3.fromRGB(184, 106, 115),
        AccentDark = Color3.fromRGB(145, 84, 92),
        Success = Color3.fromRGB(115, 204, 154)
    },
    Vaclav = {
        Background = Color3.fromRGB(10, 10, 10),
        Window = Color3.fromRGB(26, 26, 26),
        Panel = Color3.fromRGB(22, 22, 22),
        Card = Color3.fromRGB(20, 20, 20),
        Control = Color3.fromRGB(30, 30, 30),
        ControlHover = Color3.fromRGB(39, 39, 39),
        Stroke = Color3.fromRGB(108, 77, 83),
        Text = Color3.fromRGB(240, 236, 238),
        SubText = Color3.fromRGB(178, 168, 171),
        Accent = Color3.fromRGB(184, 106, 115),
        AccentDark = Color3.fromRGB(145, 84, 92),
        Success = Color3.fromRGB(115, 204, 154)
    },
    Midnight = {
        Background = Color3.fromRGB(8, 11, 18),
        Window = Color3.fromRGB(14, 19, 29),
        Panel = Color3.fromRGB(18, 24, 36),
        Card = Color3.fromRGB(16, 21, 33),
        Control = Color3.fromRGB(23, 30, 45),
        ControlHover = Color3.fromRGB(31, 39, 58),
        Stroke = Color3.fromRGB(72, 88, 120),
        Text = Color3.fromRGB(232, 238, 248),
        SubText = Color3.fromRGB(153, 169, 196),
        Accent = Color3.fromRGB(97, 149, 255),
        AccentDark = Color3.fromRGB(68, 111, 198),
        Success = Color3.fromRGB(96, 203, 160)
    },
    Ember = {
        Background = Color3.fromRGB(15, 11, 11),
        Window = Color3.fromRGB(24, 17, 17),
        Panel = Color3.fromRGB(31, 22, 22),
        Card = Color3.fromRGB(27, 19, 19),
        Control = Color3.fromRGB(36, 25, 25),
        ControlHover = Color3.fromRGB(47, 32, 32),
        Stroke = Color3.fromRGB(121, 80, 73),
        Text = Color3.fromRGB(244, 236, 232),
        SubText = Color3.fromRGB(193, 162, 156),
        Accent = Color3.fromRGB(219, 114, 90),
        AccentDark = Color3.fromRGB(170, 83, 64),
        Success = Color3.fromRGB(129, 211, 143)
    },
    Emerald = {
        Background = Color3.fromRGB(9, 13, 11),
        Window = Color3.fromRGB(16, 22, 18),
        Panel = Color3.fromRGB(21, 28, 24),
        Card = Color3.fromRGB(19, 25, 21),
        Control = Color3.fromRGB(26, 34, 29),
        ControlHover = Color3.fromRGB(35, 44, 38),
        Stroke = Color3.fromRGB(78, 112, 92),
        Text = Color3.fromRGB(232, 241, 236),
        SubText = Color3.fromRGB(159, 184, 171),
        Accent = Color3.fromRGB(102, 198, 151),
        AccentDark = Color3.fromRGB(73, 150, 113),
        Success = Color3.fromRGB(125, 224, 171)
    },
    Ocean = {
        Background = Color3.fromRGB(7, 12, 15),
        Window = Color3.fromRGB(13, 20, 25),
        Panel = Color3.fromRGB(17, 26, 32),
        Card = Color3.fromRGB(15, 23, 29),
        Control = Color3.fromRGB(22, 31, 38),
        ControlHover = Color3.fromRGB(30, 41, 50),
        Stroke = Color3.fromRGB(76, 106, 126),
        Text = Color3.fromRGB(231, 239, 245),
        SubText = Color3.fromRGB(151, 176, 194),
        Accent = Color3.fromRGB(92, 172, 216),
        AccentDark = Color3.fromRGB(63, 130, 169),
        Success = Color3.fromRGB(102, 204, 182)
    },
    Sunset = {
        Background = Color3.fromRGB(17, 12, 8),
        Window = Color3.fromRGB(27, 20, 14),
        Panel = Color3.fromRGB(35, 26, 18),
        Card = Color3.fromRGB(31, 23, 16),
        Control = Color3.fromRGB(41, 30, 21),
        ControlHover = Color3.fromRGB(53, 39, 28),
        Stroke = Color3.fromRGB(134, 100, 76),
        Text = Color3.fromRGB(246, 238, 227),
        SubText = Color3.fromRGB(204, 176, 153),
        Accent = Color3.fromRGB(224, 157, 92),
        AccentDark = Color3.fromRGB(178, 117, 62),
        Success = Color3.fromRGB(139, 212, 156)
    },
    Graphite = {
        Background = Color3.fromRGB(12, 12, 13),
        Window = Color3.fromRGB(19, 19, 21),
        Panel = Color3.fromRGB(24, 24, 27),
        Card = Color3.fromRGB(22, 22, 25),
        Control = Color3.fromRGB(31, 31, 35),
        ControlHover = Color3.fromRGB(40, 40, 46),
        Stroke = Color3.fromRGB(98, 98, 108),
        Text = Color3.fromRGB(236, 236, 238),
        SubText = Color3.fromRGB(171, 171, 178),
        Accent = Color3.fromRGB(167, 177, 194),
        AccentDark = Color3.fromRGB(123, 132, 149),
        Success = Color3.fromRGB(124, 198, 163)
    },
    Sakura = {
        Background = Color3.fromRGB(13, 10, 12),
        Window = Color3.fromRGB(22, 16, 20),
        Panel = Color3.fromRGB(29, 21, 26),
        Card = Color3.fromRGB(25, 19, 23),
        Control = Color3.fromRGB(34, 25, 30),
        ControlHover = Color3.fromRGB(44, 32, 38),
        Stroke = Color3.fromRGB(116, 80, 98),
        Text = Color3.fromRGB(243, 234, 240),
        SubText = Color3.fromRGB(197, 162, 181),
        Accent = Color3.fromRGB(225, 129, 167),
        AccentDark = Color3.fromRGB(176, 94, 130),
        Success = Color3.fromRGB(129, 212, 165)
    },
    Frost = {
        Background = Color3.fromRGB(9, 12, 14),
        Window = Color3.fromRGB(16, 21, 25),
        Panel = Color3.fromRGB(21, 27, 32),
        Card = Color3.fromRGB(19, 24, 29),
        Control = Color3.fromRGB(27, 34, 40),
        ControlHover = Color3.fromRGB(36, 44, 52),
        Stroke = Color3.fromRGB(90, 116, 132),
        Text = Color3.fromRGB(234, 242, 246),
        SubText = Color3.fromRGB(165, 187, 201),
        Accent = Color3.fromRGB(133, 191, 222),
        AccentDark = Color3.fromRGB(94, 149, 181),
        Success = Color3.fromRGB(120, 211, 188)
    },
    Forest = {
        Background = Color3.fromRGB(8, 12, 9),
        Window = Color3.fromRGB(14, 20, 16),
        Panel = Color3.fromRGB(18, 25, 20),
        Card = Color3.fromRGB(16, 22, 18),
        Control = Color3.fromRGB(23, 30, 25),
        ControlHover = Color3.fromRGB(31, 40, 33),
        Stroke = Color3.fromRGB(75, 105, 82),
        Text = Color3.fromRGB(231, 240, 233),
        SubText = Color3.fromRGB(151, 178, 159),
        Accent = Color3.fromRGB(119, 177, 118),
        AccentDark = Color3.fromRGB(84, 132, 87),
        Success = Color3.fromRGB(135, 215, 145)
    }
}

Library.ThemeOrder = ThemeOrder
Library.ThemePresets = ThemePresets

local function copyTheme(source)
    local target = {}
    for key, value in pairs(source or {}) do
        target[key] = value
    end
    return target
end

local function getThemeStyleNames()
    local names = {}
    local seen = {}
    for _, name in ipairs(ThemeOrder) do
        if ThemePresets[name] then
            table.insert(names, name)
            seen[name] = true
        end
    end
    for name in pairs(ThemePresets) do
        if not seen[name] then
            table.insert(names, name)
        end
    end
    return names
end

local function resolveThemeName(themeInput)
    if themeInput == nil then
        return "Isaeva"
    end
    if type(themeInput) == "string" then
        if ThemePresets[themeInput] then
            return themeInput
        end
        return "Isaeva"
    end
    if type(themeInput) == "table" then
        local presetName = themeInput.Preset or themeInput.Style or themeInput.StyleName
        if type(presetName) == "string" and ThemePresets[presetName] then
            return presetName
        end
    end
    return "Custom"
end

local function mergeTheme(customTheme)
    local theme = copyTheme(ThemePresets.Isaeva)
    local presetName

    if type(customTheme) == "string" then
        presetName = customTheme
    elseif type(customTheme) == "table" then
        presetName = customTheme.Preset or customTheme.Style or customTheme.StyleName
    end

    local preset = type(presetName) == "string" and ThemePresets[presetName] or nil
    if preset then
        for key, value in pairs(preset) do
            theme[key] = value
        end
    end

    if type(customTheme) == "table" then
        for key, value in pairs(customTheme) do
            if key ~= "Preset" and key ~= "Style" and key ~= "StyleName" then
                theme[key] = value
            end
        end
    end

    return theme
end

function Library:GetThemeNames()
    return getThemeStyleNames()
end

function Library:GetTheme(themeInput)
    return mergeTheme(themeInput)
end

local colorProperties = {
    "BackgroundColor3",
    "TextColor3",
    "ImageColor3",
    "PlaceholderColor3",
    "ScrollBarImageColor3",
    "BorderColor3"
}

local function colorsMatch(a, b)
    return typeof(a) == "Color3"
        and typeof(b) == "Color3"
        and math.abs(a.R - b.R) <= 0.0005
        and math.abs(a.G - b.G) <= 0.0005
        and math.abs(a.B - b.B) <= 0.0005
end

local function remapThemeColor(color, colorMap)
    for _, entry in ipairs(colorMap) do
        if colorsMatch(color, entry.From) then
            return entry.To
        end
    end
    return color
end

local function buildThemeColorMap(oldTheme, newTheme)
    local map = {}
    for _, key in ipairs(themeColorKeys) do
        local fromColor = oldTheme and oldTheme[key]
        local toColor = newTheme and newTheme[key]
        if typeof(fromColor) == "Color3" and typeof(toColor) == "Color3" and not colorsMatch(fromColor, toColor) then
            table.insert(map, {
                From = fromColor,
                To = toColor
            })
        end
    end
    return map
end

local function remapInstanceThemeColors(instance, colorMap)
    for _, propertyName in ipairs(colorProperties) do
        local ok, current = pcall(function()
            return instance[propertyName]
        end)
        if ok and typeof(current) == "Color3" then
            local target = remapThemeColor(current, colorMap)
            if not colorsMatch(target, current) then
                pcall(function()
                    instance[propertyName] = target
                end)
            end
        end
    end

    if instance:IsA("UIStroke") then
        local targetColor = remapThemeColor(instance.Color, colorMap)
        if not colorsMatch(targetColor, instance.Color) then
            instance.Color = targetColor
        end
    elseif instance:IsA("UIGradient") then
        local sequence = instance.Color
        local changed = false
        local keypoints = sequence.Keypoints
        local newKeypoints = table.create(#keypoints)
        for index, keypoint in ipairs(keypoints) do
            local mapped = remapThemeColor(keypoint.Value, colorMap)
            if not colorsMatch(mapped, keypoint.Value) then
                changed = true
            end
            newKeypoints[index] = ColorSequenceKeypoint.new(keypoint.Time, mapped)
        end
        if changed then
            instance.Color = ColorSequence.new(newKeypoints)
        end
    end
end

local function applyThemeToHierarchy(root, oldTheme, newTheme)
    if not root then
        return
    end
    local colorMap = buildThemeColorMap(oldTheme, newTheme)
    if #colorMap == 0 then
        return
    end
    remapInstanceThemeColors(root, colorMap)
    for _, instance in ipairs(root:GetDescendants()) do
        remapInstanceThemeColors(instance, colorMap)
    end
end

local function applyCorner(target, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = target
    })
end

local function applyStroke(target, color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = target
    })
end

local function keyCodeToText(keyCode)
    if typeof(keyCode) ~= "EnumItem" then
        return "None"
    end
    if keyCode == Enum.KeyCode.Unknown then
        return "None"
    end
    local name = keyCode.Name
    name = name:gsub("Left", "L")
    name = name:gsub("Right", "R")
    name = name:gsub("Control", "Ctrl")
    return name
end

local function toHex(color)
    local r = math.floor(color.R * 255 + 0.5)
    local g = math.floor(color.G * 255 + 0.5)
    local b = math.floor(color.B * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function isEnumKeyCode(value)
    return typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode
end

local function resolveGuiParent()
    local candidates = {}
    if gethui then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then
            table.insert(candidates, result)
        end
    end
    local okCore, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if okCore and coreGui then
        table.insert(candidates, coreGui)
    end
    local localPlayer = Players.LocalPlayer
    if localPlayer then
        local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 10)
        if playerGui then
            table.insert(candidates, playerGui)
        end
    end
    for _, candidate in ipairs(candidates) do
        local probe = Instance.new("Folder")
        local ok = pcall(function()
            probe.Parent = candidate
        end)
        probe:Destroy()
        if ok then
            return candidate
        end
    end
    return nil
end

local function createCard(parent, theme, height)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = theme.Control,
        BorderSizePixel = 0
    })
    applyCorner(frame, 8)
    applyStroke(frame, theme.Stroke, 0.55, 1)
    return frame
end

local function playLoadAnimation(gui, theme, logoId, titleText, useBlur)
    local loadRoot = create("Frame", {
        Name = "IsaevaLoadRoot",
        Parent = gui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 120
    })

    local introTitle = tostring(titleText or "Isaeva Hub")
    local logoSize = 62
    local titleFont = Enum.Font.GothamBold
    local titleTextSize = 24
    local textBounds = TextService:GetTextSize(introTitle, titleTextSize, titleFont, Vector2.new(360, 40))
    local titleWidth = clamp(textBounds.X + 8, 64, 320)
    local titleHeight = clamp(textBounds.Y + 2, 20, 34)
    local splitTravel = math.max(math.floor((logoSize + titleWidth + 20) * 0.25), 36)
    local intro = create("Frame", {
        Parent = loadRoot,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, logoSize + 10 + titleWidth, 0, math.max(logoSize, titleHeight) + 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 122
    })
    local introScale = create("UIScale", {
        Parent = intro,
        Scale = 0.84
    })

    local logo = create("ImageLabel", {
        Parent = intro,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, logoSize, 0, logoSize),
        BackgroundTransparency = 1,
        Image = logoId,
        ImageTransparency = 1,
        ZIndex = 124
    })
    local logoScale = create("UIScale", {
        Parent = logo,
        Scale = 0.9
    })

    local titleLabel = create("TextLabel", {
        Parent = intro,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, titleWidth, 0, titleHeight),
        Font = titleFont,
        Text = introTitle,
        TextColor3 = theme.Text,
        TextSize = titleTextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTransparency = 1,
        ZIndex = 124
    })

    local function ease(duration)
        return TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
    local function easeOut(duration)
        return TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end
    local function hold(duration)
        task.wait(math.max(duration * 0.96, 0.01))
    end

    local blurEffect
    if useBlur then
        local existingBlur = Lighting:FindFirstChild("VaclavLoadBlur")
        if existingBlur and existingBlur:IsA("BlurEffect") then
            pcall(function()
                existingBlur:Destroy()
            end)
        end
        blurEffect = Instance.new("BlurEffect")
        blurEffect.Size = 0
        blurEffect.Enabled = true
        blurEffect.Name = "VaclavLoadBlur"
        local ok = pcall(function()
            blurEffect.Parent = Lighting
        end)
        if not ok then
            blurEffect = nil
        end
    end

    tween(loadRoot, ease(0.22), {BackgroundTransparency = 0.12})
    tween(introScale, ease(0.32), {Scale = 1})
    tween(logoScale, ease(0.34), {Scale = 1})
    tween(logo, ease(0.28), {ImageTransparency = 0})
    if blurEffect then
        tween(blurEffect, ease(0.34), {Size = 14})
    end
    hold(0.36)

    for pulseIndex = 1, 3 do
        local targetScale = pulseIndex % 2 == 1 and 1.012 or 0.998
        tween(introScale, ease(0.24), {Scale = targetScale})
        hold(0.22)
    end
    tween(introScale, ease(0.18), {Scale = 1})
    hold(0.15)

    tween(logo, easeOut(0.38), {
        Position = UDim2.new(0.5, -splitTravel, 0.5, 0)
    })
    tween(titleLabel, easeOut(0.38), {
        Position = UDim2.new(0.5, splitTravel, 0.5, 0),
        TextTransparency = 0
    })
    hold(0.34)

    for swayIndex = 1, 2 do
        local yOffset = swayIndex % 2 == 1 and -1 or 1
        tween(logo, ease(0.2), {
            Position = UDim2.new(0.5, -splitTravel, 0.5, yOffset)
        })
        tween(titleLabel, ease(0.2), {
            Position = UDim2.new(0.5, splitTravel, 0.5, -yOffset),
            TextTransparency = 0
        })
        hold(0.18)
    end

    if blurEffect then
        tween(blurEffect, ease(0.24), {Size = 0})
    end
    tween(loadRoot, ease(0.24), {BackgroundTransparency = 1})
    tween(introScale, ease(0.24), {Scale = 1.04})
    tween(logo, ease(0.24), {
        ImageTransparency = 1,
        Position = UDim2.new(0.5, -splitTravel - 8, 0.5, 0)
    })
    tween(titleLabel, ease(0.22), {
        TextTransparency = 1,
        Position = UDim2.new(0.5, splitTravel + 10, 0.5, 0)
    })
    hold(0.26)

    if blurEffect then
        pcall(function()
            blurEffect:Destroy()
        end)
    end
    if loadRoot and loadRoot.Parent then
        loadRoot:Destroy()
    end
end

local function normalizeOptionList(values)
    local optionList = {}
    local seen = {}
    if type(values) == "table" then
        for _, value in ipairs(values) do
            local text = tostring(value)
            if not seen[text] then
                seen[text] = true
                table.insert(optionList, text)
            end
        end
    end
    return optionList
end

local function resolveSliderPrecision(explicitDecimals, minimum, maximum, increment, value)
    local decimals = tonumber(explicitDecimals)
    if decimals ~= nil then
        decimals = math.floor(decimals + 0.5)
    else
        decimals = math.max(
            countDecimals(minimum),
            countDecimals(maximum),
            countDecimals(increment),
            countDecimals(value)
        )
    end
    return clamp(decimals, 0, 6)
end

local function createValueText(value, suffix, decimals)
    if decimals and decimals > 0 then
        return string.format("%." .. tostring(decimals) .. "f%s", value, suffix or "")
    end
    return string.format("%d%s", roundToDecimals(value, 0), suffix or "")
end

function WindowMethods:GetThemeNames()
    return Library:GetThemeNames()
end

function WindowMethods:GetTheme()
    return copyTheme(self.Theme)
end

function WindowMethods:GetThemeName()
    return self.ThemeName or "Custom"
end

function WindowMethods:SetTheme(themeInput, silent, syncControl)
    local oldTheme = self.Theme
    local nextTheme = mergeTheme(themeInput)
    self.Theme = nextTheme
    self.ThemeName = resolveThemeName(themeInput)
    applyThemeToHierarchy(self.Gui, oldTheme, nextTheme)

    if syncControl ~= false and self._themeDropdownControl and self._themeDropdownControl.Get then
        local themeName = self.ThemeName
        local controlValue = self._themeDropdownControl.Get()
        if themeName and themeName ~= "Custom" and controlValue ~= themeName then
            self._themeDropdownControl.Set(themeName, true)
        end
    end

    if not silent then
        safeCall(self._themeChangedCallback, self.ThemeName, copyTheme(nextTheme))
    end

    return nextTheme
end

function WindowMethods:ApplyTheme(themeInput, silent, syncControl)
    return self:SetTheme(themeInput, silent, syncControl)
end

function WindowMethods:SetToggleKey(keyCode, syncControl)
    if not isEnumKeyCode(keyCode) then
        return
    end
    self.ToggleKey = keyCode
    if self.KeyHint then
        self.KeyHint.Text = "Toggle Key: " .. keyCodeToText(keyCode)
    end
    if syncControl ~= false and self._toggleBindControl and self._toggleBindControl.Get and self._toggleBindControl.Get() ~= keyCode then
        self._toggleBindControl.Set(keyCode, true, true)
    end
end

function WindowMethods:SetVisible(state)
    state = not not state
    if self.Visible == state then
        return
    end
    self.Visible = state
    if state then
        self.Main.Visible = true
        self.MainScale.Scale = 0.965
        tween(self.MainScale, midTween, {Scale = 1})
        tween(self.Overlay, midTween, {BackgroundTransparency = 0.65})
    else
        tween(self.MainScale, fastTween, {Scale = 0.965})
        tween(self.Overlay, fastTween, {BackgroundTransparency = 1})
        task.delay(0.14, function()
            if not self.Visible and self.Main then
                self.Main.Visible = false
            end
        end)
    end
end

function WindowMethods:Toggle()
    self:SetVisible(not self.Visible)
end

function WindowMethods:Destroy()
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
    self._connections = {}
    if self.Gui then
        self.Gui:Destroy()
    end
end

function WindowMethods:Notify(options)
    options = options or {}
    local title = tostring(options.Title or "Notification")
    local duration = tonumber(options.Duration) or 2.5
    local item = create("Frame", {
        Parent = self.NotificationHolder,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.Theme.Control,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    applyCorner(item, 8)
    applyStroke(item, self.Theme.Stroke, 0.55, 1)
    create("UIPadding", {
        Parent = item,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    create("TextLabel", {
        Parent = item,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    item.BackgroundTransparency = 1
    tween(item, fastTween, {BackgroundTransparency = 0})
    task.delay(duration, function()
        if item.Parent then
            local shrink = tween(item, fastTween, {BackgroundTransparency = 1})
            shrink.Completed:Connect(function()
                if item then
                    item:Destroy()
                end
            end)
        end
    end)
end

function WindowMethods:SelectTab(tab)
    if self.SelectedTab == tab then
        return
    end
    for _, listed in ipairs(self.Tabs) do
        local active = listed == tab
        listed.Active = active
        listed.Page.Visible = active
        tween(listed.ButtonFrame, fastTween, {
            BackgroundColor3 = active and self.Theme.ControlHover or self.Theme.Control
        })
        tween(listed.Indicator, fastTween, {
            Size = active and UDim2.new(0, 3, 0, 20) or UDim2.new(0, 3, 0, 0),
            BackgroundColor3 = active and self.Theme.Accent or self.Theme.AccentDark
        })
        tween(listed.ButtonLabel, fastTween, {
            TextColor3 = active and self.Theme.Text or self.Theme.SubText
        })
        if listed.IconLabel then
            tween(listed.IconLabel, fastTween, {
                TextColor3 = active and self.Theme.Accent or self.Theme.SubText
            })
        end
        if active then
            listed.Page.Position = UDim2.new(0, 12, 0, 0)
            listed.PageScale.Scale = 0.986
            tween(listed.Page, midTween, {Position = UDim2.new(0, 0, 0, 0)})
            tween(listed.PageScale, midTween, {Scale = 1})
        end
    end
    self.SelectedTab = tab
end

function WindowMethods:AddTab(options)
    options = options or {}
    local tab = setmetatable({
        Window = self,
        Name = tostring(options.Name or ("Tab " .. tostring(#self.Tabs + 1))),
        Sections = {}
    }, {__index = TabMethods})

    local button = create("TextButton", {
        Parent = self.TabList,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Theme.Control,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    applyCorner(button, 8)
    applyStroke(button, self.Theme.Stroke, 0.58, 1)

    local indicator = create("Frame", {
        Parent = button,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 0),
        BackgroundColor3 = self.Theme.AccentDark,
        BorderSizePixel = 0
    })
    applyCorner(indicator, 6)

    local iconLabel
    local iconValue = options.Icon
    if type(iconValue) == "string" and iconValue ~= "" then
        iconLabel = create("TextLabel", {
            Parent = button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0, 18, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = iconValue,
            TextColor3 = self.Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center
        })
    end

    local nameOffset = iconLabel and 28 or 10
    local label = create("TextLabel", {
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, nameOffset, 0, 0),
        Size = UDim2.new(1, -nameOffset - 6, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tab.Name,
        TextColor3 = self.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local page = create("Frame", {
        Parent = self.Pages,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    local pageScale = create("UIScale", {
        Parent = page,
        Scale = 1
    })

    local leftColumn = create("ScrollingFrame", {
        Parent = page,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, -6, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent
    })
    create("UIPadding", {
        Parent = leftColumn,
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 1),
        PaddingRight = UDim.new(0, 4)
    })
    create("UIListLayout", {
        Parent = leftColumn,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    local rightColumn = create("ScrollingFrame", {
        Parent = page,
        Position = UDim2.new(0.5, 6, 0, 0),
        Size = UDim2.new(0.5, -6, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent
    })
    create("UIPadding", {
        Parent = rightColumn,
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 1)
    })
    create("UIListLayout", {
        Parent = rightColumn,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    tab.ButtonFrame = button
    tab.ButtonLabel = label
    tab.IconLabel = iconLabel
    tab.Indicator = indicator
    tab.Page = page
    tab.PageScale = pageScale
    tab.LeftColumn = leftColumn
    tab.RightColumn = rightColumn
    tab.Active = false

    connect(self, button.MouseEnter, function()
        if not tab.Active then
            tween(button, fastTween, {BackgroundColor3 = self.Theme.ControlHover})
        end
    end)
    connect(self, button.MouseLeave, function()
        if not tab.Active then
            tween(button, fastTween, {BackgroundColor3 = self.Theme.Control})
        end
    end)
    connect(self, button.MouseButton1Click, function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    local autoSelect = options.AutoSelect
    if autoSelect == nil then
        autoSelect = true
    end
    if autoSelect and not self.SelectedTab then
        self:SelectTab(tab)
    end

    return tab
end

function TabMethods:AddSection(options)
    options = options or {}
    local side = tostring(options.Side or "Left"):lower()
    local section = setmetatable({
        Tab = self,
        Window = self.Window,
        Name = tostring(options.Name or ("Section " .. tostring(#self.Sections + 1)))
    }, {__index = SectionMethods})

    local parentColumn = side == "right" and self.RightColumn or self.LeftColumn
    local frame = create("Frame", {
        Parent = parentColumn,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Window.Theme.Card,
        BorderSizePixel = 0
    })
    applyCorner(frame, 10)
    applyStroke(frame, self.Window.Theme.Stroke, 0.5, 1)

    create("UIPadding", {
        Parent = frame,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    create("UIListLayout", {
        Parent = frame,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local title = create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = section.Name,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local holder = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = holder,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    section.Frame = frame
    section.TitleLabel = title
    section.GroupsHolder = holder
    section.ElementsHolder = holder
    section.Groups = {}

    table.insert(self.Sections, section)
    return section
end

function TabMethods:ThemeCreate(options)
    options = options or {}
    local window = self.Window
    local styles = window:GetThemeNames()
    if options.AllowCustom ~= false and not table.find(styles, "Custom") then
        table.insert(styles, "Custom")
    end
    local selectedStyle = tostring(options.Default or window:GetThemeName())
    if not table.find(styles, selectedStyle) then
        selectedStyle = styles[1]
    end

    local section = self:AddSection({
        Name = tostring(options.SectionName or "Themes"),
        Side = tostring(options.Side or "Right")
    })
    local container = section

    local function resolveCustomTheme()
        local custom = options.CustomTheme
        if typeof(custom) == "function" then
            local ok, result = pcall(custom, window:GetTheme(), window:GetThemeName())
            if ok and type(result) == "table" then
                return result
            end
        elseif type(custom) == "table" then
            return custom
        end
        return window:GetTheme()
    end

    local function applySelection(silent)
        if selectedStyle == "Custom" then
            local customTheme = resolveCustomTheme()
            window:SetTheme(customTheme, silent == true)
            safeCall(options.Callback, "Custom", window:GetTheme())
            return
        end
        if selectedStyle then
            window:SetTheme(selectedStyle, silent == true)
            safeCall(options.Callback, selectedStyle, window:GetTheme())
        end
    end

    local instantApply = options.InstantApply == true
    local dropdown = container:AddDropdown({
        Name = tostring(options.DropdownName or "Style"),
        Options = styles,
        Default = selectedStyle,
        Callback = function(styleName)
            selectedStyle = styleName
            if instantApply then
                applySelection(false)
            end
        end
    })
    window._themeDropdownControl = dropdown

    local applyButton = container:AddButton({
        Name = tostring(options.ButtonName or "Apply Theme"),
        Callback = function()
            applySelection(false)
        end
    })

    local object = {
        Section = section,
        Group = nil,
        Dropdown = dropdown,
        Button = applyButton
    }

    function object:Set(styleName, shouldApply)
        if styleName == nil then
            return
        end
        dropdown:Set(styleName, true)
        selectedStyle = dropdown:Get()
        if shouldApply then
            object:Apply(nil, false)
        end
    end

    function object:Get()
        return selectedStyle
    end

    function object:Apply(styleName, silent)
        if styleName ~= nil then
            dropdown:Set(styleName, true)
            selectedStyle = dropdown:Get()
        end
        applySelection(silent == true)
    end

    return object
end

function SectionMethods:AddGroup(options)
    return self
end

function GroupMethods:AddButton(options)
    options = options or {}
    local buttonCard = createCard(self.ElementsHolder, self.Window.Theme, 34)
    local button = create("TextButton", {
        Parent = buttonCard,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(options.Name or "Button"),
        Font = Enum.Font.GothamSemibold,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        AutoButtonColor = false
    })

    connect(self.Window, button.MouseEnter, function()
        tween(buttonCard, fastTween, {BackgroundColor3 = self.Window.Theme.ControlHover})
    end)
    connect(self.Window, button.MouseLeave, function()
        tween(buttonCard, fastTween, {BackgroundColor3 = self.Window.Theme.Control})
    end)
    connect(self.Window, button.MouseButton1Down, function()
        tween(buttonCard, fastTween, {BackgroundColor3 = self.Window.Theme.AccentDark})
    end)
    connect(self.Window, button.MouseButton1Up, function()
        tween(buttonCard, fastTween, {BackgroundColor3 = self.Window.Theme.ControlHover})
    end)
    connect(self.Window, button.MouseButton1Click, function()
        safeCall(options.Callback)
    end)

    local object = {}
    function object:SetText(text)
        button.Text = tostring(text)
    end
    return object
end

function GroupMethods:AddLabel(options)
    options = options or {}
    local window = self.Window
    local text = tostring(options.Text or options.Name or "Label")
    local updateCallback = options.Update
    local autoUpdate = options.AutoUpdate
    local autoInterval
    if autoUpdate == true then
        autoInterval = tonumber(options.UpdateInterval) or 0.5
    elseif type(autoUpdate) == "number" then
        autoInterval = autoUpdate
    elseif options.UpdateInterval ~= nil then
        autoInterval = tonumber(options.UpdateInterval)
    end
    if autoInterval and autoInterval <= 0 then
        autoInterval = 0.1
    end
    local autoSilent = options.AutoUpdateSilent
    if autoSilent == nil then
        autoSilent = true
    end
    local autoToken = 0

    local card = createCard(self.ElementsHolder, window.Theme, 30)
    local label = create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = window.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local object = {}

    local function setText(nextText, silent)
        nextText = tostring(nextText or "")
        if text == nextText then
            return
        end
        text = nextText
        label.Text = text
        if not silent then
            safeCall(options.Callback, text)
        end
    end

    function object:Set(nextText, silent)
        setText(nextText, silent)
    end

    function object:Get()
        return text
    end

    function object:Refresh(silent)
        if typeof(updateCallback) ~= "function" then
            return false
        end
        local ok, nextText = pcall(updateCallback, text)
        if not ok then
            return false
        end
        setText(nextText, silent)
        return true
    end

    function object:StopAutoUpdate()
        autoToken = autoToken + 1
    end

    function object:StartAutoUpdate(interval, silent)
        if typeof(updateCallback) ~= "function" then
            return
        end
        interval = tonumber(interval) or autoInterval or 0.5
        if interval <= 0 then
            interval = 0.1
        end
        autoToken = autoToken + 1
        local token = autoToken
        task.spawn(function()
            while token == autoToken and not window._destroyed and card.Parent do
                task.wait(interval)
                if token ~= autoToken or window._destroyed or not card.Parent then
                    break
                end
                object:Refresh(silent)
            end
        end)
    end

    if typeof(updateCallback) == "function" then
        object:Refresh(true)
        if autoInterval then
            object:StartAutoUpdate(autoInterval, autoSilent)
        end
    end
    safeCall(options.Callback, text)
    return object
end

function GroupMethods:AddToggle(options)
    options = options or {}
    local state = options.Default == true
    local card = createCard(self.ElementsHolder, self.Window.Theme, 34)

    create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -64, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Toggle"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local track = create("Frame", {
        Parent = card,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0
    })
    applyCorner(track, 10)
    applyStroke(track, self.Window.Theme.Stroke, 0.5, 1)

    local knob = create("Frame", {
        Parent = track,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = self.Window.Theme.SubText,
        BorderSizePixel = 0
    })
    applyCorner(knob, 100)

    local toggleButton = create("TextButton", {
        Parent = card,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })

    local function render(immediate)
        local targetTrack = state and self.Window.Theme.AccentDark or self.Window.Theme.Panel
        local targetKnob = state and self.Window.Theme.Accent or self.Window.Theme.SubText
        local targetPos = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        if immediate then
            track.BackgroundColor3 = targetTrack
            knob.BackgroundColor3 = targetKnob
            knob.Position = targetPos
        else
            tween(track, fastTween, {BackgroundColor3 = targetTrack})
            tween(knob, fastTween, {BackgroundColor3 = targetKnob, Position = targetPos})
        end
    end

    local object = {}
    function object:Set(value, silent)
        local nextValue = not not value
        if state == nextValue then
            return
        end
        state = nextValue
        render(false)
        if not silent then
            safeCall(options.Callback, state)
        end
    end
    function object:Get()
        return state
    end

    connect(self.Window, toggleButton.MouseButton1Click, function()
        object:Set(not state, false)
    end)

    render(true)
    safeCall(options.Callback, state)
    return object
end

function GroupMethods:AddSlider(options)
    options = options or {}
    local minimum = tonumber(options.Min) or 0
    local maximum = tonumber(options.Max) or 100
    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end
    local increment = tonumber(options.Increment) or 1
    if increment <= 0 then
        increment = 1
    end
    local suffix = tostring(options.Suffix or "")
    local explicitDecimals = options.Decimals
    if explicitDecimals == nil then
        explicitDecimals = options.Precision
    end
    local value = tonumber(options.Default)
    if value == nil then
        value = minimum
    end
    local decimals = resolveSliderPrecision(explicitDecimals, minimum, maximum, increment, value)
    value = clamp(roundToStep(value, increment, minimum, decimals), minimum, maximum)

    local card = createCard(self.ElementsHolder, self.Window.Theme, 52)
    create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -70, 0, 16),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Slider"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local valueLabel = create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -66, 0, 5),
        Size = UDim2.new(0, 56, 0, 16),
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = self.Window.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local bar = create("Frame", {
        Parent = card,
        Position = UDim2.new(0, 10, 0, 31),
        Size = UDim2.new(1, -20, 0, 10),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0
    })
    applyCorner(bar, 6)
    applyStroke(bar, self.Window.Theme.Stroke, 0.6, 1)

    local fill = create("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Window.Theme.AccentDark,
        BorderSizePixel = 0
    })
    applyCorner(fill, 6)
    create("UIGradient", {
        Parent = fill,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Window.Theme.AccentDark),
            ColorSequenceKeypoint.new(1, self.Window.Theme.Accent)
        })
    })

    local knob = create("Frame", {
        Parent = bar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0
    })
    applyCorner(knob, 99)
    applyStroke(knob, self.Window.Theme.Stroke, 0.4, 1)

    local dragging = false

    local function updateVisual(animated)
        local alpha = 0
        if maximum ~= minimum then
            alpha = (value - minimum) / (maximum - minimum)
        end
        alpha = clamp(alpha, 0, 1)
        valueLabel.Text = createValueText(value, suffix, decimals)
        local targetFill = UDim2.new(alpha, 0, 1, 0)
        local targetKnob = UDim2.new(alpha, 0, 0.5, 0)
        if animated then
            tween(fill, fastTween, {Size = targetFill})
            tween(knob, fastTween, {Position = targetKnob})
        else
            fill.Size = targetFill
            knob.Position = targetKnob
        end
    end

    local object = {}
    function object:Set(nextValue, silent)
        nextValue = tonumber(nextValue)
        if not nextValue then
            return
        end
        nextValue = clamp(roundToStep(nextValue, increment, minimum, decimals), minimum, maximum)
        if nextValue == value then
            return
        end
        value = nextValue
        updateVisual(true)
        if not silent then
            safeCall(options.Callback, value)
        end
    end
    function object:Get()
        return value
    end

    local function setFromInputX(x)
        local barX = bar.AbsolutePosition.X
        local barW = bar.AbsoluteSize.X
        if barW <= 0 then
            return
        end
        local alpha = clamp((x - barX) / barW, 0, 1)
        local raw = minimum + (maximum - minimum) * alpha
        object:Set(raw, false)
    end

    connect(self.Window, bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromInputX(input.Position.X)
        end
    end)
    connect(self.Window, UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    connect(self.Window, UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromInputX(input.Position.X)
        end
    end)

    updateVisual(false)
    safeCall(options.Callback, value)
    return object
end

function GroupMethods:AddDropdown(options)
    options = options or {}
    local window = self.Window
    local optionList = normalizeOptionList(type(options.Options) == "table" and options.Options or nil)
    local updateProvider = options.Update
    if typeof(updateProvider) ~= "function" and type(options.Options) == "function" then
        updateProvider = options.Options
    end
    local selected = options.Default and tostring(options.Default) or optionList[1]
    local open = false
    local autoToken = 0
    local autoUpdate = options.AutoUpdate
    local autoInterval
    if autoUpdate == true then
        autoInterval = tonumber(options.UpdateInterval) or 1
    elseif type(autoUpdate) == "number" then
        autoInterval = autoUpdate
    elseif options.UpdateInterval ~= nil and autoUpdate ~= false then
        autoInterval = tonumber(options.UpdateInterval)
    end
    if autoInterval and autoInterval <= 0 then
        autoInterval = 0.2
    end
    local autoSilent = options.AutoUpdateSilent
    if autoSilent == nil then
        autoSilent = true
    end
    local keepCurrentOnUpdate = options.KeepCurrentOnUpdate
    if keepCurrentOnUpdate == nil then
        keepCurrentOnUpdate = true
    end
    local hasRefreshButton = typeof(updateProvider) == "function" and options.UpdateButton ~= false
    local valueOffset = hasRefreshButton and -136 or -122

    local wrapper = create("Frame", {
        Parent = self.ElementsHolder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = wrapper,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local row = createCard(wrapper, window.Theme, 34)
    create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -130, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Dropdown"),
        TextColor3 = window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local valueLabel = create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, valueOffset, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = window.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    local arrow = create("TextLabel", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = ">",
        TextColor3 = window.Theme.SubText,
        TextSize = 12
    })
    local refreshButton
    if hasRefreshButton then
        refreshButton = create("TextButton", {
            Parent = row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -22, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = tostring(options.UpdateButtonText or "R"),
            TextColor3 = window.Theme.SubText,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 5
        })
    end

    local panel = create("Frame", {
        Parent = wrapper,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = window.Theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    applyCorner(panel, 8)
    applyStroke(panel, window.Theme.Stroke, 0.58, 1)

    local scroll = create("ScrollingFrame", {
        Parent = panel,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = window.Theme.AccentDark
    })
    create("UIListLayout", {
        Parent = scroll,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local optionButtons = {}

    local function refreshDisplay()
        valueLabel.Text = selected or "None"
        for optionValue, button in pairs(optionButtons) do
            local isSelected = optionValue == selected
            tween(button, fastTween, {
                BackgroundColor3 = isSelected and window.Theme.AccentDark or window.Theme.Control
            })
            local textLabel = button:FindFirstChild("Label")
            if textLabel then
                tween(textLabel, fastTween, {
                    TextColor3 = isSelected and window.Theme.Text or window.Theme.SubText
                })
            end
        end
    end

    local function setOpen(state)
        open = state
        tween(arrow, fastTween, {Rotation = state and 90 or 0})
        local targetHeight = 0
        if state then
            targetHeight = math.min(#optionList * 30 + 12, 146)
        end
        tween(panel, midTween, {Size = UDim2.new(1, 0, 0, targetHeight)})
    end

    local function setSelected(value, silent)
        if value ~= nil then
            value = tostring(value)
        end
        if selected == value then
            return
        end
        selected = value
        refreshDisplay()
        if not silent then
            safeCall(options.Callback, selected)
        end
    end

    local rebuildOptions

    local function applyOptionList(values, keepCurrent, silent)
        local previous = selected
        optionList = normalizeOptionList(values)
        if keepCurrent then
            if selected and not table.find(optionList, selected) then
                selected = optionList[1]
            end
            if not selected then
                selected = optionList[1]
            end
        else
            selected = optionList[1]
        end
        rebuildOptions()
        if selected ~= previous and not silent then
            safeCall(options.Callback, selected)
        end
    end

    local object = {}

    rebuildOptions = function()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        optionButtons = {}
        for _, optionValue in ipairs(optionList) do
            local optionButton = create("TextButton", {
                Parent = scroll,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = window.Theme.Control,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false
            })
            applyCorner(optionButton, 7)
            create("TextLabel", {
                Name = "Label",
                Parent = optionButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -8, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = optionValue,
                TextColor3 = window.Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            optionButtons[optionValue] = optionButton
            connect(window, optionButton.MouseEnter, function()
                if selected ~= optionValue then
                    tween(optionButton, fastTween, {BackgroundColor3 = window.Theme.ControlHover})
                end
            end)
            connect(window, optionButton.MouseLeave, function()
                if selected ~= optionValue then
                    tween(optionButton, fastTween, {BackgroundColor3 = window.Theme.Control})
                end
            end)
            connect(window, optionButton.MouseButton1Click, function()
                setSelected(optionValue, false)
                setOpen(false)
            end)
        end
        if selected and not optionButtons[selected] then
            selected = optionList[1]
        end
        refreshDisplay()
    end

    local rowButton = create("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    connect(window, rowButton.MouseButton1Click, function()
        setOpen(not open)
    end)
    if refreshButton then
        connect(window, refreshButton.MouseEnter, function()
            tween(refreshButton, fastTween, {TextColor3 = window.Theme.Text})
        end)
        connect(window, refreshButton.MouseLeave, function()
            tween(refreshButton, fastTween, {TextColor3 = window.Theme.SubText})
        end)
        connect(window, refreshButton.MouseButton1Click, function()
            object:Refresh(keepCurrentOnUpdate, false)
        end)
    end
    function object:Set(value, silent)
        if value ~= nil and not optionButtons[tostring(value)] then
            return
        end
        setSelected(value, silent)
    end
    function object:Get()
        return selected
    end
    function object:SetOptions(values, keepCurrent, silent)
        if silent == nil then
            silent = true
        end
        applyOptionList(values, keepCurrent == true, silent)
    end
    function object:Refresh(keepCurrent, silent)
        if typeof(updateProvider) ~= "function" then
            return false
        end
        if keepCurrent == nil then
            keepCurrent = true
        end
        if silent == nil then
            silent = false
        end
        local ok, values = pcall(updateProvider, selected, optionList)
        if not ok or type(values) ~= "table" then
            return false
        end
        applyOptionList(values, keepCurrent, silent)
        return true
    end
    function object:StopAutoUpdate()
        autoToken = autoToken + 1
    end
    function object:StartAutoUpdate(interval, keepCurrent, silent)
        if typeof(updateProvider) ~= "function" then
            return
        end
        interval = tonumber(interval) or autoInterval or 1
        if interval <= 0 then
            interval = 0.2
        end
        if keepCurrent == nil then
            keepCurrent = true
        end
        if silent == nil then
            silent = true
        end
        autoToken = autoToken + 1
        local token = autoToken
        task.spawn(function()
            while token == autoToken and not window._destroyed and wrapper.Parent do
                task.wait(interval)
                if token ~= autoToken or window._destroyed or not wrapper.Parent then
                    break
                end
                object:Refresh(keepCurrent, silent)
            end
        end)
    end

    rebuildOptions()
    setOpen(false)
    if typeof(updateProvider) == "function" then
        object:Refresh(keepCurrentOnUpdate, true)
        if autoInterval then
            object:StartAutoUpdate(autoInterval, keepCurrentOnUpdate, autoSilent)
        end
    end
    safeCall(options.Callback, selected)
    return object
end

function GroupMethods:AddMultiDropdown(options)
    options = options or {}
    local optionList = {}
    if type(options.Options) == "table" then
        for _, value in ipairs(options.Options) do
            table.insert(optionList, tostring(value))
        end
    end
    local selectedMap = {}
    if type(options.Default) == "table" then
        for _, value in ipairs(options.Default) do
            selectedMap[tostring(value)] = true
        end
    end
    local open = false

    local wrapper = create("Frame", {
        Parent = self.ElementsHolder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = wrapper,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local row = createCard(wrapper, self.Window.Theme, 34)
    create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -130, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Multi Dropdown"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local valueLabel = create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -122, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = self.Window.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    local arrow = create("TextLabel", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = ">",
        TextColor3 = self.Window.Theme.SubText,
        TextSize = 12
    })

    local panel = create("Frame", {
        Parent = wrapper,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    applyCorner(panel, 8)
    applyStroke(panel, self.Window.Theme.Stroke, 0.58, 1)

    local scroll = create("ScrollingFrame", {
        Parent = panel,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Window.Theme.AccentDark
    })
    create("UIListLayout", {
        Parent = scroll,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local optionButtons = {}

    local function selectedList()
        local result = {}
        for _, value in ipairs(optionList) do
            if selectedMap[value] then
                table.insert(result, value)
            end
        end
        return result
    end

    local function updateValueText()
        local list = selectedList()
        if #list == 0 then
            valueLabel.Text = "None"
        elseif #list == 1 then
            valueLabel.Text = list[1]
        elseif #list == 2 then
            valueLabel.Text = list[1] .. ", " .. list[2]
        else
            valueLabel.Text = tostring(#list) .. " selected"
        end
    end

    local function refreshButtons()
        for optionValue, button in pairs(optionButtons) do
            local active = selectedMap[optionValue] == true
            local mark = button:FindFirstChild("Mark")
            tween(button, fastTween, {
                BackgroundColor3 = active and self.Window.Theme.AccentDark or self.Window.Theme.Control
            })
            if mark then
                tween(mark, fastTween, {
                    BackgroundColor3 = active and self.Window.Theme.Success or self.Window.Theme.Panel
                })
            end
            local label = button:FindFirstChild("Label")
            if label then
                tween(label, fastTween, {
                    TextColor3 = active and self.Window.Theme.Text or self.Window.Theme.SubText
                })
            end
        end
        updateValueText()
    end

    local function setOpen(state)
        open = state
        tween(arrow, fastTween, {Rotation = state and 90 or 0})
        local targetHeight = 0
        if state then
            targetHeight = math.min(#optionList * 30 + 12, 150)
        end
        tween(panel, midTween, {Size = UDim2.new(1, 0, 0, targetHeight)})
    end

    local function toggleOption(optionValue, silent)
        selectedMap[optionValue] = not selectedMap[optionValue]
        refreshButtons()
        if not silent then
            safeCall(options.Callback, selectedList())
        end
    end

    local function rebuildOptions()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        optionButtons = {}
        for _, optionValue in ipairs(optionList) do
            local optionButton = create("TextButton", {
                Parent = scroll,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = self.Window.Theme.Control,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false
            })
            applyCorner(optionButton, 7)

            local mark = create("Frame", {
                Name = "Mark",
                Parent = optionButton,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 6, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0
            })
            applyCorner(mark, 4)
            applyStroke(mark, self.Window.Theme.Stroke, 0.55, 1)

            create("TextLabel", {
                Name = "Label",
                Parent = optionButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 24, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = optionValue,
                TextColor3 = self.Window.Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            optionButtons[optionValue] = optionButton

            connect(self.Window, optionButton.MouseEnter, function()
                if not selectedMap[optionValue] then
                    tween(optionButton, fastTween, {BackgroundColor3 = self.Window.Theme.ControlHover})
                end
            end)
            connect(self.Window, optionButton.MouseLeave, function()
                if not selectedMap[optionValue] then
                    tween(optionButton, fastTween, {BackgroundColor3 = self.Window.Theme.Control})
                end
            end)
            connect(self.Window, optionButton.MouseButton1Click, function()
                toggleOption(optionValue, false)
            end)
        end
        local valid = {}
        for _, optionValue in ipairs(optionList) do
            if selectedMap[optionValue] then
                valid[optionValue] = true
            end
        end
        selectedMap = valid
        refreshButtons()
    end

    local rowButton = create("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    connect(self.Window, rowButton.MouseButton1Click, function()
        setOpen(not open)
    end)

    local object = {}
    function object:Set(values, silent)
        selectedMap = {}
        if type(values) == "table" then
            for _, value in ipairs(values) do
                value = tostring(value)
                if table.find(optionList, value) then
                    selectedMap[value] = true
                end
            end
        end
        refreshButtons()
        if not silent then
            safeCall(options.Callback, selectedList())
        end
    end
    function object:Get()
        return selectedList()
    end
    function object:SetOptions(values, keepSelected)
        optionList = {}
        if type(values) == "table" then
            for _, value in ipairs(values) do
                table.insert(optionList, tostring(value))
            end
        end
        if not keepSelected then
            selectedMap = {}
        end
        rebuildOptions()
    end

    rebuildOptions()
    setOpen(false)
    safeCall(options.Callback, selectedList())
    return object
end

function GroupMethods:AddTextbox(options)
    options = options or {}
    local value = tostring(options.Default or "")
    local card = createCard(self.ElementsHolder, self.Window.Theme, 36)
    create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.4, -8, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Textbox"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local inputBox = create("TextBox", {
        Parent = card,
        Position = UDim2.new(0.4, 0, 0.5, -11),
        Size = UDim2.new(0.6, -10, 0, 22),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamSemibold,
        PlaceholderText = tostring(options.Placeholder or ""),
        PlaceholderColor3 = self.Window.Theme.SubText,
        Text = value,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    applyCorner(inputBox, 6)
    applyStroke(inputBox, self.Window.Theme.Stroke, 0.55, 1)
    create("UIPadding", {
        Parent = inputBox,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })

    connect(self.Window, inputBox.FocusLost, function(enterPressed)
        value = inputBox.Text
        safeCall(options.Callback, value, enterPressed)
    end)

    local object = {}
    function object:Set(text, silent)
        value = tostring(text or "")
        inputBox.Text = value
        if not silent then
            safeCall(options.Callback, value, false)
        end
    end
    function object:Get()
        return value
    end
    return object
end

function GroupMethods:AddKeybind(options)
    options = options or {}
    local key = options.Default
    if not isEnumKeyCode(key) then
        key = Enum.KeyCode.Unknown
    end
    local card = createCard(self.ElementsHolder, self.Window.Theme, 34)
    create("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -102, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Keybind"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local keyButton = create("TextButton", {
        Parent = card,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 86, 0, 22),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = self.Window.Theme.SubText,
        TextSize = 12,
        AutoButtonColor = false
    })
    applyCorner(keyButton, 6)
    applyStroke(keyButton, self.Window.Theme.Stroke, 0.56, 1)

    local bindEntry = {
        Key = key,
        Callback = options.Callback
    }
    table.insert(self.Window._keybindEntries, bindEntry)

    local listening = false

    local function render()
        keyButton.Text = listening and "..." or keyCodeToText(key)
        tween(keyButton, fastTween, {
            BackgroundColor3 = listening and self.Window.Theme.AccentDark or self.Window.Theme.Panel,
            TextColor3 = listening and self.Window.Theme.Text or self.Window.Theme.SubText
        })
    end

    local object = {}
    function object:Set(newKey, silentChanged, suppressSync)
        if not isEnumKeyCode(newKey) then
            return
        end
        key = newKey
        bindEntry.Key = newKey
        render()
        if not silentChanged then
            safeCall(options.ChangedCallback, newKey)
        end
        if not suppressSync and self.Window._toggleBindControl == object then
            self.Window:SetToggleKey(newKey, false)
        end
    end
    function object:Get()
        return key
    end

    connect(self.Window, keyButton.MouseButton1Click, function()
        listening = true
        render()
        self.Window._awaitingKeybind = function(inputKey)
            listening = false
            if inputKey == Enum.KeyCode.Escape then
                object:Set(Enum.KeyCode.Unknown, false, false)
            else
                object:Set(inputKey, false, false)
            end
        end
    end)

    render()
    return object
end

function GroupMethods:AddColorPicker(options)
    options = options or {}
    local current = options.Default
    if typeof(current) ~= "Color3" then
        current = Color3.fromRGB(255, 255, 255)
    end
    local hue, saturation, value = Color3.toHSV(current)
    local open = false

    local wrapper = create("Frame", {
        Parent = self.ElementsHolder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = wrapper,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local row = createCard(wrapper, self.Window.Theme, 34)
    create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -88, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(options.Name or "Color Picker"),
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local hexLabel = create("TextLabel", {
        Parent = row,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 0),
        Size = UDim2.new(0, 56, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = self.Window.Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    local preview = create("Frame", {
        Parent = row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = current,
        BorderSizePixel = 0
    })
    applyCorner(preview, 4)
    applyStroke(preview, self.Window.Theme.Stroke, 0.45, 1)

    local panel = create("Frame", {
        Parent = wrapper,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.Window.Theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    applyCorner(panel, 8)
    applyStroke(panel, self.Window.Theme.Stroke, 0.58, 1)

    local satVal = create("Frame", {
        Parent = panel,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -32, 0, 120),
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        BorderSizePixel = 0
    })
    applyCorner(satVal, 6)

    create("UIGradient", {
        Parent = satVal,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })

    local valOverlay = create("Frame", {
        Parent = satVal,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0
    })
    applyCorner(valOverlay, 6)
    create("UIGradient", {
        Parent = valOverlay,
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
    })

    local satValCursor = create("Frame", {
        Parent = satVal,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    applyCorner(satValCursor, 99)
    applyStroke(satValCursor, Color3.fromRGB(18, 18, 18), 0.2, 1)

    local hueBar = create("Frame", {
        Parent = panel,
        Position = UDim2.new(1, -20, 0, 8),
        Size = UDim2.new(0, 12, 0, 120),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0
    })
    applyCorner(hueBar, 6)
    create("UIGradient", {
        Parent = hueBar,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    })
    local hueCursor = create("Frame", {
        Parent = hueBar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, 2, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    applyCorner(hueCursor, 6)

    local rowButton = create("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })

    local satDragging = false
    local hueDragging = false

    local function emit()
        current = Color3.fromHSV(hue, saturation, value)
        preview.BackgroundColor3 = current
        hexLabel.Text = toHex(current)
        safeCall(options.Callback, current)
    end

    local function refreshVisual()
        satVal.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        satValCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
        hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
        preview.BackgroundColor3 = Color3.fromHSV(hue, saturation, value)
        hexLabel.Text = toHex(Color3.fromHSV(hue, saturation, value))
    end

    local function setOpen(state)
        open = state
        local target = state and 136 or 0
        tween(panel, midTween, {Size = UDim2.new(1, 0, 0, target)})
    end

    local function setFromSatVal(mousePosition)
        local relativeX = clamp((mousePosition.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
        local relativeY = clamp((mousePosition.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
        saturation = relativeX
        value = 1 - relativeY
        refreshVisual()
        emit()
    end

    local function setFromHue(mousePosition)
        local relative = clamp((mousePosition.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
        hue = relative
        refreshVisual()
        emit()
    end

    connect(self.Window, rowButton.MouseButton1Click, function()
        setOpen(not open)
    end)

    connect(self.Window, satVal.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = true
            setFromSatVal(input.Position)
        end
    end)
    connect(self.Window, hueBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            setFromHue(input.Position)
        end
    end)
    connect(self.Window, UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = false
            hueDragging = false
        end
    end)
    connect(self.Window, UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if satDragging then
                setFromSatVal(input.Position)
            elseif hueDragging then
                setFromHue(input.Position)
            end
        end
    end)

    local object = {}
    function object:Set(color, silent)
        if typeof(color) ~= "Color3" then
            return
        end
        hue, saturation, value = Color3.toHSV(color)
        refreshVisual()
        current = color
        if not silent then
            safeCall(options.Callback, current)
        end
    end
    function object:Get()
        return current
    end

    refreshVisual()
    setOpen(false)
    safeCall(options.Callback, current)
    return object
end

SectionMethods.AddButton = GroupMethods.AddButton
SectionMethods.AddLabel = GroupMethods.AddLabel
SectionMethods.AddToggle = GroupMethods.AddToggle
SectionMethods.AddSlider = GroupMethods.AddSlider
SectionMethods.AddDropdown = GroupMethods.AddDropdown
SectionMethods.AddMultiDropdown = GroupMethods.AddMultiDropdown
SectionMethods.AddTextbox = GroupMethods.AddTextbox
SectionMethods.AddKeybind = GroupMethods.AddKeybind
SectionMethods.AddColorPicker = GroupMethods.AddColorPicker

function Library:CreateWindow(options)
    options = options or {}
    local initialThemeName = resolveThemeName(options.Theme)
    local theme = mergeTheme(options.Theme)
    local parent = resolveGuiParent()
    if not parent then
        error("Unable to resolve a GUI parent")
    end

    local gui = create("ScreenGui", {
        Name = tostring(options.Name or "GalaxyUI"),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent
    })

    local overlay = create("Frame", {
        Parent = gui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0
    })

    local main = create("Frame", {
        Parent = gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = options.Size or UDim2.new(0, 760, 0, 470),
        BackgroundColor3 = theme.Window,
        BorderSizePixel = 0
    })
    applyCorner(main, 11)
    applyStroke(main, theme.Stroke, 0.35, 1)
    local mainScale = create("UIScale", {
        Parent = main,
        Scale = 1
    })

    local accentBar = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0
    })
    applyCorner(accentBar, 4)
    create("UIGradient", {
        Parent = accentBar,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.AccentDark),
            ColorSequenceKeypoint.new(1, theme.Accent)
        })
    })

    local topBar = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0
    })
    applyCorner(topBar, 11)
    create("Frame", {
        Parent = topBar,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0
    })

    local logoId = tostring(options.Logo or options.HeaderLogo or options.BrandLogo or "108702816998934")
    if not string.find(logoId, "rbxassetid://", 1, true) then
        logoId = "rbxassetid://" .. logoId
    end

    local logoCrop = clamp(math.floor(tonumber(options.LogoCrop) or 3), 0, 8)

    local topLogoClip = create("Frame", {
        Parent = topBar,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    local topLogo = create("ImageLabel", {
        Parent = topLogoClip,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, logoCrop * 2, 1, logoCrop * 2),
        ScaleType = Enum.ScaleType.Fit,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = logoId
    })

    local topTitle = tostring(options.HeaderTitle or options.BrandName or "Isaeva Hub")
    create("TextLabel", {
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 42, 0, 0),
        Size = UDim2.new(1, -230, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = topTitle,
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local keyHint = create("TextLabel", {
        Parent = topBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 190, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local side = create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 172, 1, -42),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0
    })
    create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 172, 0, 42),
        Size = UDim2.new(0, 1, 1, -42),
        BackgroundColor3 = theme.Stroke,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0
    })

    local tabList = create("Frame", {
        Parent = side,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = tabList,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local content = create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 183, 0, 50),
        Size = UDim2.new(1, -194, 1, -60),
        BackgroundTransparency = 1
    })
    local pages = create("Frame", {
        Parent = content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })

    local notifHolder = create("Frame", {
        Parent = gui,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.new(0, 250, 0, 300),
        BackgroundTransparency = 1
    })
    create("UIListLayout", {
        Parent = notifHolder,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    local window = setmetatable({
        Gui = gui,
        Theme = theme,
        ThemeName = initialThemeName,
        Overlay = overlay,
        Main = main,
        MainScale = mainScale,
        TopBar = topBar,
        TabList = tabList,
        Pages = pages,
        NotificationHolder = notifHolder,
        KeyHint = keyHint,
        Tabs = {},
        SelectedTab = nil,
        Visible = true,
        ToggleKey = isEnumKeyCode(options.ToggleKey) and options.ToggleKey or Enum.KeyCode.RightControl,
        _connections = {},
        _keybindEntries = {},
        _awaitingKeybind = nil,
        _toggleBindControl = nil,
        _themeDropdownControl = nil,
        _themeChangedCallback = options.ThemeChangedCallback,
        _destroyed = false
    }, {__index = WindowMethods})

    keyHint.Text = "Toggle Key: " .. keyCodeToText(window.ToggleKey)

    local shouldPlayLoadAnimation = options.LoadAnimation
    if shouldPlayLoadAnimation == nil then
        shouldPlayLoadAnimation = true
    end
    local shouldUseLoadBlur = options.LoadBlur
    if shouldUseLoadBlur == nil then
        shouldUseLoadBlur = true
    end
    if shouldPlayLoadAnimation then
        main.Visible = false
        overlay.Visible = false
        overlay.BackgroundTransparency = 1
        mainScale.Scale = 0.95
    end

    local dragging = false
    local dragStart
    local startPos
    local dragTarget = main.Position

    connect(window, topBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            dragTarget = main.Position
        end
    end)
    connect(window, UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    connect(window, UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            dragTarget = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    connect(window, RunService.RenderStepped, function(deltaTime)
        if dragging then
            local alpha = clamp(deltaTime * 20, 0, 1)
            main.Position = lerpUDim2(main.Position, dragTarget, alpha)
        end
    end)

    connect(window, UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if window._awaitingKeybind then
            local resolver = window._awaitingKeybind
            window._awaitingKeybind = nil
            resolver(input.KeyCode)
            return
        end
        if input.KeyCode == window.ToggleKey then
            window:Toggle()
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        for _, bind in ipairs(window._keybindEntries) do
            if bind.Key == input.KeyCode and bind.Key ~= Enum.KeyCode.Unknown then
                safeCall(bind.Callback, input.KeyCode)
            end
        end
    end)

    local settingsTab = window:AddTab({
        Name = tostring(options.SettingsTabName or "Settings"),
        Icon = tostring(options.SettingsIcon or "S"),
        AutoSelect = false
    })
    local settingsSection = settingsTab:AddSection({
        Name = tostring(options.SettingsSectionName or "Window"),
        Side = "Left"
    })
    local toggleBind = settingsSection:AddKeybind({
        Name = tostring(options.ToggleBindName or "Toggle UI"),
        Default = window.ToggleKey,
        ChangedCallback = function(newKey)
            window:SetToggleKey(newKey, false)
            keyHint.Text = "Toggle Key: " .. keyCodeToText(window.ToggleKey)
        end
    })
    window._toggleBindControl = toggleBind
    settingsSection:AddButton({
        Name = tostring(options.HideNowButtonName or "Hide Interface"),
        Callback = function()
            window:SetVisible(false)
        end
    })
    settingsSection:AddButton({
        Name = tostring(options.DestroyButtonName or "Destroy Interface"),
        Callback = function()
            window:Destroy()
        end
    })

    local showThemeChooser = options.ShowThemeChooser
    if showThemeChooser == nil then
        showThemeChooser = true
    end
    if showThemeChooser then
        window._settingsThemeControl = settingsTab:ThemeCreate({
            SectionName = tostring(options.ThemeSectionName or "Themes"),
            Side = tostring(options.ThemeSide or "Right"),
            GroupName = tostring(options.ThemeGroupName or "Styles"),
            DropdownName = tostring(options.ThemeDropdownName or "Style"),
            ButtonName = tostring(options.ThemeButtonName or "Apply Style"),
            Default = window.ThemeName,
            InstantApply = options.InstantThemeApply == true,
            Callback = options.ThemeCallback
        })
    end

    if not window.SelectedTab then
        window:SelectTab(settingsTab)
    end

    if shouldPlayLoadAnimation then
        local ok, loadErr = pcall(playLoadAnimation, gui, theme, logoId, topTitle, shouldUseLoadBlur)
        if not ok then
            warn("[Isaeva Hub] Load animation failed:", loadErr)
            local staleBlur = Lighting:FindFirstChild("VaclavLoadBlur")
            if staleBlur and staleBlur:IsA("BlurEffect") then
                pcall(function()
                    staleBlur:Destroy()
                end)
            end
            local staleLoadRoot = gui:FindFirstChild("IsaevaLoadRoot")
            if staleLoadRoot then
                staleLoadRoot:Destroy()
            end
        end
        overlay.Visible = true
        main.Visible = true
        tween(mainScale, midTween, {Scale = 1})
        tween(overlay, midTween, {BackgroundTransparency = 0.65})
    end

    if options.ShowLoadNotification ~= false then
        window:Notify({
            Title = "UI Loaded",
            Duration = 2
        })
    end

    return window
end

return Library
