PRGNAME     = sms.elf

# define regarding OS, which compiler to use
EXESUFFIX = 
TOOLCHAIN = 
CC          = gcc
CXX         = g++
LD          = gcc

# Possible choices : rs97, k3s (PAP K3S), sdl, bittboy, amini
PORT = rs97
# Possible choices : alsa, pulse (pulseaudio), oss, sdl12 (SDL 1.2 sound output), portaudio, libao
SOUND_OUTPUT = alsa
# Possible choices : crabemu_sn76489 (less accurate, GPLv2), maxim_sn76489 (somewhat problematic license but good accuracy)
SOUND_ENGINE = maxim_sn76489
# Possible choices : z80 (accurate but proprietary), eighty (EightyZ80's core, GPLv2)
Z80_CORE = z80
PROFILE = 0

# add SDL dependencies

CFLAGS		= -O0 -g -std=gnu99 -DINLINE=inline -DLSB_FIRST
CFLAGS 		+= -I/usr/include/SDL
CFLAGS		+= -Isource -Isource/cpu_cores/$(Z80_CORE) -Isource/generic -Isource/ports/$(PORT) -I./source/sound -Isource/unzip -Isource/sdl -Isource/sound/$(SOUND_ENGINE) -Isource/sound_output

ifeq ($(SOUND_ENGINE), maxim_sn76489)
CFLAGS 		+= -DMAXIM_PSG
endif

CXXFLAGS	= $(CFLAGS) 
LDFLAGS     = -lSDL -lm -flto -lz
ifeq ($(SOUND_OUTPUT), portaudio)
LDFLAGS		+= -lportaudio
endif
ifeq ($(SOUND_OUTPUT), libao)
LDFLAGS		+= -lao
endif
ifeq ($(SOUND_OUTPUT), alsa)
LDFLAGS		+= -lasound
endif
ifeq ($(SOUND_OUTPUT), pulse)
LDFLAGS		+= -lpulse -lpulse-simple
endif

# Files to be r
SRCDIR		= ./source ./source/unzip ./source/cpu_cores/$(Z80_CORE) ./source/sound
SRCDIR		+= ./source/generic ./source/ports/$(PORT) ./source/sound/$(SOUND_ENGINE) ./source/sound_output/$(SOUND_OUTPUT)
VPATH		= $(SRCDIR)
SRC_C		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.c))
SRC_CP		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.cpp))
OBJ_C		= $(notdir $(patsubst %.c, %.o, $(SRC_C)))
OBJ_CP		= $(notdir $(patsubst %.cpp, %.o, $(SRC_CP)))
OBJS		= $(OBJ_C) $(OBJ_CP)

# Rules to make executable
$(PRGNAME): $(OBJS)  
	$(LD) $(CFLAGS) -o $(PRGNAME) $^ $(LDFLAGS)

$(OBJ_C) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_CP) : %.o : %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(PRGNAME) *.o