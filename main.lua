mapsizey = 500 -- change this to change the size of the y axis, 5*input
mapsizex = 500 -- change this to change the size of the x axis, 5*input

function clearscreen(dist) -- clear the screen
	for i = 1, dist do
		print()
	end
end
function round(number) -- round numbers
	return tonumber(string.format("%." .. 0 .. "f", number))
end
function dump(o) -- dump a table to string
	if type(o) == 'table' then
		local s = '{ '
			for kkk,v in pairs(o) do
			if type(kkk) ~= 'number' then kkk = '"'..kkk..'"' end
			s = s .. '['..kkk..'] = ' .. dump(v) .. ','
		end
	return s .. '} '
	else
	return tostring(o)
	end
end
function savefile() -- save the table a text file
	file = io.open("save.tbl", "w")
	file:write(dump(savedata))
	file:close()
end

mapsizey = mapsizey * 5 -- multiply input values by 5 to prevent it from breaking
mapsizex = mapsizex * 5
file = io.open("save.tbl", "r") -- load a existing save if it exists
ostime = os.date("%H%M%S")
ostime = tonumber(ostime)
math.randomseed(ostime)
first = math.random(9) -- set a starting value
if not (file) then -- create save data if it doesnt exist
    savedata = {
        cord = {
            x = 3,
            y = 3,
        },
        map = {
        },
    }
    temp1 = 1
	for i = 1, mapsizey do -- y axis
        temp2 = 1
	    savedata.map[temp1] = {}
        for h = 1, mapsizex do -- x axis
            savedata.map[temp1][temp2] = 0
            temp2 = temp2 + 1
        end
        temp1 = temp1 + 1
	end
    savedata.cord.y = math.floor(#savedata.map / 2) -- put in centre of the map
    savedata.cord.x = math.floor(#savedata.map[1] / 2)
    goto loop
end
savestring = file:read("*l")
file:close()
savedata = load("return "..savestring)() -- convert string to a table

::loop::
if (response == "n") then -- commands
	savedata.cord.y = savedata.cord.y - 1
end
if (response == "s") then
	savedata.cord.y = savedata.cord.y + 1
end
if (response == "w") then
	savedata.cord.x = savedata.cord.x - 1
end
if (response == "e") then
	savedata.cord.x = savedata.cord.x + 1
end
if (response == "save") then
	savefile()
end
if (savedata.cord.y >= #savedata.map - 2) then
	savedata.cord.y = #savedata.map - 3
	far = 1
end
if (savedata.cord.y <= (#savedata.map - (#savedata.map - 2))) then
	savedata.cord.y = (#savedata.map - (#savedata.map - 3))
	far = 1
end
if (savedata.cord.x >= #savedata.map[1] - 2) then
	savedata.cord.x = #savedata.map[1] - 3
	far = 1
end
if (savedata.cord.x <= (#savedata.map[1] - (#savedata.map[1] - 2))) then
	savedata.cord.x = (#savedata.map[1] - (#savedata.map[1] - 3))
	far = 1
end
sx = -2 -- set start positions for scanning
sy = -2
map = "(" .. savedata.cord.x .. ":" .. savedata.cord.y * -1 .. ")\n\n"
::loop1:: -- loop1 generates the world
tile = savedata.map[savedata.cord.y + sy][savedata.cord.x + sx]
if (tile == 0) then
    tilelist = {} -- create a blank 5x5 chunk
    tilelist[1] = { 0, 0, 0, 0, 0, }
    tilelist[2] = { 0, 0, 0, 0, 0, }
    tilelist[3] = { 0, 0, 0, 0, 0, }
    tilelist[4] = { 0, 0, 0, 0, 0, }
    tilelist[5] = { 0, 0, 0, 0, 0, }
    tx = 1 -- start positions
    ty = 1
    ::loop6:: -- loop6 sloppily smooths the world
    tv = math.random(9)
    tilelist[ty][tx] = tv
    if (first >= tv + 3) or (first <= tv -3) then
        goto loop6
    end
    first = tv 
    tx = tx + 1 -- scan through the blank chunk and generate it
    if (tx == 6) then
        tx = 1
        ty = ty + 1
    end
    if (ty == 6) then
        goto loop7
    end
    goto loop6
    ::loop7:: -- loop7 checks if a new chunk is needed
    tiley = (savedata.cord.y + sy) / 5 -- find offset for the 0 tile
    tilex = (savedata.cord.x + sx) / 5
    tilew = math.floor(tiley) + 0.0
    tilez = math.floor(tilex) + 0.0
    tiley = round((savedata.cord.y + sy) - (((tiley - tilew) * 10) / 2)) -- compare numbers to find the real distance
    tilex = round((savedata.cord.x + sx) - (((tilex - tilez) * 10) / 2))
    nx = 1 -- start positions
    ny = 1
    ::loop4:: -- loop4 scans through a 5x5 chunk to write generated values
    savedata.map[tiley + ny][tilex + nx] = tilelist[ny][nx]
    nx = nx + 1 -- scan through save file
    if (nx == 6) then
        nx = 1
        ny = ny + 1
    end
    if (ny == 6) then
        goto loop5
    end
    goto loop4
end
::loop5:: -- loop5 scans through the world to display a nonlocked 5x5 chunk
tile = savedata.map[savedata.cord.y + sy][savedata.cord.x + sx] -- get a value
map = map .. tile .. " " -- add the value to the list
sx = sx + 1 -- scan
if (sx == 3) then
    sx = -2
    sy = sy + 1
    map = map .. "\n"
end
if (sy == 3) then
    goto loop2
end
goto loop1
::loop2:: -- loop2 displays the values for you
clearscreen(100) -- get rid of old data from visible area
if (far == 1) then
	map = map .. "\nYou cannot go any further\n" -- add this message to display data if needed
    far = 0
end
print(map .. "\nn = up\ns = down\nw = left\ne = right\nsave = save") -- add commands to display data
::loop3:: -- loop3 lazily handles user input
response = io.read()
if (response == "n") or (response == "s") or (response == "w") or (response == "e") or (response == "save") then 
    goto loop
end
if (response == "q") then
    goto eof
end
goto loop3
::eof::