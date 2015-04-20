Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id F316E6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 16:43:14 -0400 (EDT)
Received: by widdi4 with SMTP id di4so106232395wid.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 13:43:14 -0700 (PDT)
Received: from lb1-smtp-cloud6.xs4all.net (lb1-smtp-cloud6.xs4all.net. [194.109.24.24])
        by mx.google.com with ESMTPS id t18si33857473wjq.133.2015.04.20.13.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 13:43:13 -0700 (PDT)
Message-ID: <1429562587.14597.80.camel@x220>
Subject: Re: [RFC PATCH v3 09/10] lib: libos build scripts and documentation
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 20 Apr 2015 22:43:07 +0200
In-Reply-To: <1429450104-47619-10-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
	 <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
	 <1429450104-47619-10-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

Some random observations while I'm still trying to wrap my head around
all this (which might take quite some time).

On Sun, 2015-04-19 at 22:28 +0900, Hajime Tazaki wrote:
> --- /dev/null
> +++ b/arch/lib/Kconfig
> @@ -0,0 +1,124 @@
> +menuconfig LIB
> +       bool "LibOS-specific options"
> +       def_bool n

This is the start of the Kconfig parse for lib. (That would basically
still be true even if you didn't set KBUILD_KCONFIG, see below.) So why
not do something like all arches do:

config LIB
	def_bool y
	select [...]

Ie, why would someone want to build for ARCH=lib and still not set LIB?

> +       select PROC_FS
> +       select PROC_SYSCTL
> +       select SYSCTL
> +       select SYSFS
> +       help
> +          The 'lib' architecture is a library (user-mode) version of
> +          the linux kernel that includes only its network stack and is
> +	  used within the userspace application, and ns-3 simulator.
> +	  For more information, about ns-3, see http://www.nsnam.org.
> +
> +config EXPERIMENTAL
> +	def_bool y

Unneeded: removed treewide in, I think, 2014.

> +config MMU
> +        def_bool n

Add empty line.

> +config FPU
> +        def_bool n

Ditto.

> +config SMP
> +        def_bool n
> +
> +config ARCH
> +	string
> +	option env="ARCH"
> +
> +config KTIME_SCALAR
> +       def_bool y

This one is unused.

> +config MODULES
> +       def_bool y
> +       option modules
> +
> +config GENERIC_CSUM
> +	def_bool y
> +
> +config GENERIC_BUG
> +	def_bool y
> +	depends on BUG

Add empty line here.

> +config PRINTK
> +       def_bool y
> +
> +config RWSEM_GENERIC_SPINLOCK
> +	def_bool y
> +
> +config GENERIC_FIND_NEXT_BIT
> +	def_bool y

This one is unused too.

> +config GENERIC_HWEIGHT
> +       def_bool y
> +
> +config TRACE_IRQFLAGS_SUPPORT
> +	def_bool y
> +
> +config NO_HZ
> +	def_bool y
> +
> +config BASE_FULL
> +       def_bool n
> +
> +config SELECT_MEMORY_MODEL
> +       def_bool n
> +
> +config FLAT_NODE_MEM_MAP
> +       def_bool n
> +
> +config PAGEFLAGS_EXTENDED
> +       def_bool n
> +
> +config VIRT_TO_BUS
> +       def_bool n
> +
> +config HAS_DMA
> +       def_bool n
> +
> +config HZ
> +        int
> +        default 250
> +
> +config TINY_RCU
> +       def_bool y
> +
> +config HZ_250
> +       def_bool y
> +
> +config BASE_SMALL
> +       int
> +       default 1
> +
> +config SPLIT_PTLOCK_CPUS
> +       int
> +       default 1
> +
> +config FLATMEM
> +       def_bool y
> +
> +config SYSCTL
> +       def_bool y
> +
> +config PROC_FS
> +       def_bool y
> +
> +config SYSFS
> +       def_bool y
> +
> +config PROC_SYSCTL
> +       def_bool y
> +
> +config NETDEVICES
> +       def_bool y
> +
> +config SLIB
> +       def_bool y

You've also added SLIB to init/Kconfig in 02/10. But "make ARCH=lib
*config" will never visit init/Kconfig, will it? And, apparently, none
of SL[AOU]B are wanted for lib. So I think the entry for config SLIB in
that file can be dropped (as other arches will never see it because it
depends on LIB).

(Note that I haven't actually looked into all the Kconfig entries added
above. Perhaps I might do that. But I'm pretty sure most of the time all
I can say is: "I have no idea why this entry defaults to $VALUE".)

> +source "net/Kconfig"
> +
> +source "drivers/base/Kconfig"
> +
> +source "crypto/Kconfig"
> +
> +source "lib/Kconfig"
> +
> +

Trailing empty lines.

> diff --git a/arch/lib/Makefile b/arch/lib/Makefile
> new file mode 100644
> index 0000000..d8a0bf9
> --- /dev/null
> +++ b/arch/lib/Makefile
> @@ -0,0 +1,251 @@
> +ARCH_DIR := arch/lib
> +SRCDIR=$(dir $(firstword $(MAKEFILE_LIST)))

Do you use SRCDIR?

> +DCE_TESTDIR=$(srctree)/tools/testing/libos/
> +KBUILD_KCONFIG := arch/$(ARCH)/Kconfig

I think you copied this from arch/um/Makefile. But arch/um/ is, well,
special. Why should lib not start the kconfig parse in the file named
Kconfig? And if you want to start in arch/lib/Kconfig, it would be nice
to add a mainmenu (just like arch/x86/um/Kconfig does).

(I don't read Makefilese well enough to understand the rest of this
file. I think it's scary.)

> +
> +CC = gcc
> +GCCVERSIONGTEQ48 := $(shell expr `gcc -dumpversion` \>= 4.8)
> +ifeq "$(GCCVERSIONGTEQ48)" "1"
> +   NO_TREE_LOOP_OPT += -fno-tree-loop-distribute-patterns
> +endif
> +
> +
> +-include $(ARCH_DIR)/objs.mk
> +-include $(srctree)/.config
> +include $(srctree)/scripts/Kbuild.include
> +include $(ARCH_DIR)/processor.mk
> +
> +# targets
> +LIBOS_TOOLS=$(ARCH_DIR)/tools
> +LIBOS_GIT_REPO=git://github.com/libos-nuse/linux-libos-tools
> +KERNEL_LIB=liblinux-$(KERNELVERSION).so
> +
> +ALL_OBJS=$(OBJS) $(KERNEL_LIB) $(modules) $(all-obj-for-clean)
> +
> +# auto generated files
> +AUTOGENS=$(CRC32TABLE) $(COMPILE_H) $(BOUNDS_H) $(ARCH_DIR)/timeconst.h $(ARCH_DIR)/linker.lds
> +COMPILE_H=$(srctree)/include/generated/compile.h
> +BOUNDS_H=$(srctree)/include/generated/bounds.h
> +
> +# from lib/Makefile
> +CRC32TABLE = $(ARCH_DIR)/crc32table.h
> +hostprogs-y	:= $(srctree)/lib/gen_crc32table
> +clean-files	:= crc32table.h
> +
> +# sources and objects
> +LIB_SRC=\
> +lib.c lib-device.c lib-socket.c random.c softirq.c time.c \
> +timer.c hrtimer.c sched.c workqueue.c \
> +print.c tasklet.c tasklet-hrtimer.c \
> +glue.c fs.c sysctl.c proc.c sysfs.c \
> +capability.c pid.c modules.c filemap.c vmscan.c
> +
> +LIB_OBJ=$(addprefix $(ARCH_DIR)/,$(addsuffix .o,$(basename $(LIB_SRC))))
> +LIB_DEPS=$(addprefix $(ARCH_DIR)/.,$(addsuffix .o.cmd,$(basename $(LIB_SRC))))
> +-include $(LIB_DEPS)
> +
> +DEPENDS=$(addprefix $(ARCH_DIR)/.,\
> +	$(addsuffix .d,$(basename $(LIB_SRC)))\
> +	)
> +
> +# options
> +COV?=no
> +cov_yes=-fprofile-arcs -ftest-coverage
> +cov_no=
> +covl_yes=-fprofile-arcs
> +covl_no=
> +OPT?=yes
> +opt_yes=-O3 -fomit-frame-pointer $(NO_TREE_LOOP_OPT)
> +opt_no=-O0
> +PIC?=yes
> +pic_yes=-fpic -DPIC
> +pic_no=-mcmodel=large
> +PIC_CFLAGS=$(pic_$(PIC))
> +
> +# flags
> +CFLAGS_USPACE= \
> + -Wp,-MD,$(depfile) $(opt_$(OPT)) -g3 -Wall -Wstrict-prototypes -Wno-trigraphs \
> + -fno-inline -fno-strict-aliasing -fno-common \
> + -fno-delete-null-pointer-checks -fno-builtin \
> + -fno-stack-protector -Wno-unused -Wno-pointer-sign \
> + $(PIC_CFLAGS) -D_DEBUG $(cov_$(COV)) -I$(ARCH_DIR)/include
> +
> +CFLAGS+= \
> + $(CFLAGS_USPACE) -nostdinc -D__KERNEL__ -iwithprefix $(srctree)/include \
> + -DKBUILD_BASENAME=\"clnt\" -DKBUILD_MODNAME=\"nsc\" -DMODVERSIONS \
> + -DEXPORT_SYMTAB \
> + -U__FreeBSD__ -D__linux__=1 -Dlinux=1 -D__linux=1 \
> + -DCONFIG_DEFAULT_HOSTNAME=\"lib\" \
> + -I$(ARCH_DIR)/include/generated/uapi \
> + -I$(ARCH_DIR)/include/generated \
> + -I$(srctree)/include -I$(ARCH_DIR)/include/uapi \
> + -I$(srctree)/include/uapi -I$(srctree)/include/generated/uapi \
> + -include $(srctree)/include/linux/kconfig.h \
> + -I$(ARCH_DIR) -I.
> +
> +ifeq ($(PROCESSOR_SIZE),64)
> +CFLAGS+= -DCONFIG_64BIT
> +endif
> +
> +LDFLAGS += -shared -nodefaultlibs -g3 -Wl,-O1 -Wl,-T$(ARCH_DIR)/linker.lds $(covl_$(COV))
> +
> +# targets
> +
> +modules:=
> +all-obj-for-clean:=
> +
> +all: library modules
> +
> +# note: the directory order below matters to ensure that we match the kernel order
> +dirs=kernel/ kernel/time/ kernel/rcu/ kernel/locking/ kernel/bpf/ mm/ fs/ fs/proc/ crypto/ lib/ drivers/base/ drivers/net/ net/ init/
> +empty:=
> +space:= $(empty) $(empty)
> +colon:= :
> +comma= ,
> +kernel/_to_keep=notifier.o params.o sysctl.o \
> +rwsem.o semaphore.o kfifo.o cred.o user.o groups.o ksysfs.o
> +kernel/time/_to_keep=time.o
> +kernel/rcu_to_keep=rcu/srcu.o rcu/pdate.o rcu/tiny.o
> +kernel/locking_to_keep=locking/mutex.o
> +kernel/bpf_to_keep=bpf/core.o
> +mm/_to_keep=util.o list_lru.o slib.o
> +crypto/_to_keep=aead.o ahash.o shash.o api.o algapi.o cipher.o compress.o proc.o \
> +crc32c_generic.o
> +drivers/base/_to_keep=class.o core.o bus.o dd.o driver.o devres.o module.o map.o
> +drivers/net/_to_keep=loopback.o
> +lib/_to_keep=klist.o kobject.o kref.o hweight.o int_sqrt.o checksum.o \
> +find_last_bit.o find_next_bit.o bitmap.o nlattr.o idr.o libcrc32c.o \
> +ctype.o string.o kasprintf.o rbtree.o sha1.o textsearch.o vsprintf.o \
> +rwsem-spinlock.o scatterlist.o ratelimit.o hexdump.o dec_and_lock.o \
> +div64.o dynamic_queue_limits.o md5.o kstrtox.o iovec.o lockref.o crc32.o \
> +rhashtable.o iov_iter.o cmdline.o kobject_uevent.o
> +fs/_to_keep=read_write.o libfs.o namei.o filesystems.o file.o file_table.o \
> +dcache.o inode.o pipe.o char_dev.o splice.o no-block.o seq_file.o super.o \
> +fcntl.o coredump.o
> +fs/proc/_to_keep=proc_sysctl.o proc_net.o root.o generic.o inode.o
> +init/_to_keep=version.o
> +
> +quiet_cmd_objsmk = OBJS-MK   $@
> +      cmd_objsmk = \
> +	for i in 1; do \
> +	$(foreach d,$(dirs), \
> +           $(MAKE) -i -s -f $< srcdir=$(srctree)/$(d) \
> +	    objdir=$(srctree)/$(d) \
> +            config=$(srctree)/.config \
> +	    to_keep=$(subst $(space),$(colon),$($(d)_to_keep)) print;) \
> +	done > $@
> +
> +$(ARCH_DIR)/objs.mk: $(ARCH_DIR)/Makefile.print $(srctree)/.config $(ARCH_DIR)/Makefile
> +	+$(call if_changed,objsmk)
> +
> +quiet_cmd_timeconst = GEN     $@
> +      cmd_timeconst = echo "hz=$(CONFIG_HZ)" > $(ARCH_DIR)/hz.bc ; \
> +                      bc $(ARCH_DIR)/hz.bc kernel/time/timeconst.bc > $@
> +$(ARCH_DIR)/timeconst.h: $(srctree)/.config
> +	$(call if_changed,timeconst)
> +
> +quiet_cmd_linker = GEN     $@
> +      cmd_linker = ld -shared --verbose | ./$^ > $@
> +$(ARCH_DIR)/linker.lds: $(ARCH_DIR)/generate-linker-script.py
> +	$(call if_changed,linker)
> +
> +quiet_cmd_crc32src = GEN     $@
> +      cmd_crc32src = $(MAKE) -f $(srctree)/Makefile silentoldconfig ; \
> +                     cc $^ -o $@
> +$(srctree)/lib/gen_crc32table: $(srctree)/lib/gen_crc32table.c
> +	$(call if_changed,crc32src)
> +
> +quiet_cmd_crc32 = GEN     $@
> +      cmd_crc32 = $< > $@
> +
> +$(CRC32TABLE): $(srctree)/lib/gen_crc32table
> +	$(call if_changed,crc32)
> +
> +# copied from init/Makefile
> +       chk_compile.h = :
> + quiet_chk_compile.h = echo '  CHK     $@'
> +silent_chk_compile.h = :
> +$(COMPILE_H): include/generated/utsrelease.h asm-generic $(version_h)
> +	@$($(quiet)chk_compile.h)
> +	+$(Q)$(CONFIG_SHELL) $(srctree)/scripts/mkcompile_h $@ \
> +	"$(UTS_MACHINE)" "$(CONFIG_SMP)" "$(CONFIG_PREEMPT)" "$(CC) $(KBUILD_CFLAGS)"
> +
> +# crafted from $(srctree)/Kbuild
> +quiet_cmd_lib_bounds = GEN     $@
> +define cmd_lib_bounds
> +	(set -e; \
> +	 echo "#ifndef GENERATED_BOUNDS_H"; \
> +	 echo "#define GENERATED_BOUNDS_H"; \
> +	 echo ""; \
> +	 echo "#define NR_PAGEFLAGS (__NR_PAGEFLAGS)"; \
> +	 echo "#define MAX_NR_ZONES (__MAX_NR_ZONES)"; \
> +	 echo ""; \
> +	 echo "#endif /* GENERATED_BOUNDS_H */") > $@
> +endef
> +
> +$(BOUNDS_H):
> +	$(Q)mkdir -p $(dir $@)
> +	$(call cmd,lib_bounds)
> +
> +
> +KERNEL_BUILTIN=$(addprefix $(srctree)/,$(addsuffix builtin.o,$(dirs)))
> +OBJS=$(LIB_OBJ) $(foreach builtin,$(KERNEL_BUILTIN),$(if $($(builtin)),$($(builtin))))
> +export OBJS KERNEL_LIB COV covl_yes covl_no
> +
> +quiet_cmd_cc = CC      $@
> +      cmd_cc = 	mkdir -p $(dir $@);	\
> +		$(CC) $(CFLAGS) -c $< -o $@
> +quiet_cmd_linkko = KO   $@
> +      cmd_linkko = $(CC) -shared -o $@ -nostdlib $^
> +quiet_cmd_builtin = BUILTIN   $@
> +      cmd_builtin = mkdir -p $(dir $(srctree)/$@); rm -f $(srctree)/$@; \
> +		    if test -n "$($(srctree)/$@)"; then for f in $($(srctree)/$@); \
> +		    do $(AR) Tcru $@ $$f; done; else $(AR) Tcru $@; fi
> +
> +%/builtin.o:
> +	$(call if_changed,builtin)
> +%.ko:%.o
> +	$(call if_changed,linkko)
> +%.o:%.c
> +	$(call if_changed_dep,cc)
> +
> +library: $(KERNEL_LIB) $(LIBOS_TOOLS)
> +modules: $(modules)
> +
> +$(LIBOS_TOOLS): $(KERNEL_LIB) Makefile FORCE
> +	$(Q) if [ ! -d "$@" ]; then \
> +		git clone $(LIBOS_GIT_REPO) $@ ;\
> +	fi
> +	$(Q) $(MAKE) -C $(LIBOS_TOOLS)
> +
> +install: modules library
> +
> +install-dir:
> +
> +$(KERNEL_LIB): $(ARCH_DIR)/objs.mk $(AUTOGENS) $(OBJS)
> +	$(call if_changed,linklib)
> +
> +quiet_cmd_linklib = LIB     $@
> +      cmd_linklib = $(CC) -Wl,--whole-archive $(OBJS) $(LDFLAGS) -o $@; \
> +		    ln -s -f $(KERNEL_LIB) liblinux.so
> +
> +quiet_cmd_clean = CLEAN   $@
> +      cmd_clean = for f in $(foreach m,$(modules),$($(m))) ; do rm -f $$f 2>/dev/null; done ; \
> +		  for f in $(ALL_OBJS); do rm -f $$f; done 2>/dev/null ;\
> +		  rm -rf $(AUTOGENS) $(ARCH_DIR)/objs.mk 2>/dev/null ;\
> +		  if [ -d $(LIBOS_TOOLS) ]; then $(MAKE) -C $(LIBOS_TOOLS) clean ; fi
> +
> +archclean:
> +	$(call if_changed,clean)
> +
> +.%.d:%.c $(srctree)/.config
> +	$(Q) set -e; $(CC) -MM -MT $(<:.c=.o) $(CFLAGS) $< > $@
> +
> +deplib: $(DEPENDS)
> +	-include $(DEPENDS)
> +
> +test:
> +	$(Q) $(MAKE) -C $(DCE_TESTDIR)/
> +
> +.PHONY : clean deplib
> +
> diff --git a/arch/lib/Makefile.print b/arch/lib/Makefile.print
> new file mode 100644
> index 0000000..40e6db0
> --- /dev/null
> +++ b/arch/lib/Makefile.print
> @@ -0,0 +1,45 @@
> +# inherit $(objdir) $(config) $(srcdir) $(to_keep) from command-line
> +
> +include $(config)
> +include $(srcdir)Makefile
> +
> +# fix minor nits for make version dependencies
> +ifeq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
> +  SEPARATOR=
> +else
> +  SEPARATOR=/
> +endif
> +
> +to_keep_list=$(subst :, ,$(to_keep))
> +obj-y += $(lib-y)
> +obj-m += $(lib-m)
> +subdirs := $(filter %/, $(obj-y) $(obj-m))
> +subdirs-y := $(filter %/, $(obj-y))
> +subdirs-m := $(filter %/, $(obj-m))
> +tmp1-obj-y=$(patsubst %/,%/builtin.o,$(obj-y))
> +tmp1-obj-m=$(filter-out $(subdirs-m),$(obj-m))
> +tmp2-obj-y=$(foreach m,$(tmp1-obj-y), $(if $($(m:.o=-objs)),$($(m:.o=-objs)),$(if $($(m:.o=-y)),$($(m:.o=-y)),$(m))))
> +tmp2-obj-m=$(foreach m,$(tmp1-obj-m), $(if $($(m:.o=-objs)),$($(m:.o=-objs)),$(if $($(m:.o=-y)),$($(m:.o=-y)),$(m))))
> +tmp3-obj-y=$(if $(to_keep_list),$(filter $(to_keep_list),$(tmp2-obj-y)),$(tmp2-obj-y))
> +tmp3-obj-m=$(if $(to_keep_list),$(filter $(to_keep_list),$(tmp2-obj-m)),$(tmp2-obj-m))
> +final-obj-y=$(tmp3-obj-y)
> +final-obj-m=$(tmp3-obj-m)
> +
> +print: $(final-obj-m) $(subdirs)
> +	@if test $(if $(final-obj-y),1); then \
> +	  echo -n $(objdir)builtin.o; echo -n "="; echo $(addprefix $(objdir),$(final-obj-y)); \
> +	  echo -n $(objdir)builtin.o; echo -n ": "; echo $(addprefix $(objdir),$(final-obj-y)); \
> +          echo -n "-include "; echo $(addprefix $(objdir).,$(addsuffix ".cmd", $(final-obj-y))); \
> +	  echo -n "all-obj-for-clean+="; echo $(addprefix $(objdir),$(final-obj-y)) $(objdir)builtin.o; \
> +	fi
> +$(final-obj-m):
> +	@echo -n "modules+="; echo $(addprefix $(objdir),$(@:.o=.ko))
> +	@echo -n $(addprefix $(objdir),$(@:.o=.ko)); echo -n ": "
> +	@echo $(addprefix $(objdir),$(if $($(@:.o=-objs)),$($(@:.o=-objs)),$@))
> +	@echo -n $(addprefix $(objdir),$(@:.o=.ko)); echo -n "="
> +	@echo $(addprefix $(objdir),$(if $($(@:.o=-objs)),$($(@:.o=-objs)),$@))
> +$(subdirs):
> +	@$(MAKE) -s -f $(firstword $(MAKEFILE_LIST)) objdir=$(objdir)$@$(SEPARATOR) config=$(config) srcdir=$(srcdir)$@$(SEPARATOR) to_keep=$(to_keep) print 2>/dev/null

When I did
    make ARCH=lib menuconfig

I saw (among other things):
    arch/lib/Makefile.print:41: target `trace/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `trace/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `trace/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `trace/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `lzo/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `lz4/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `lz4/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `ppp/' given more than once in the same rule.
    arch/lib/Makefile.print:41: target `slip/' given more than once in the same rule.

I have no idea why. Unclean tree?

> +.PHONY : core
> +.NOTPARALLEL : print $(subdirs) $(final-obj-m)

> --- /dev/null
> +++ b/arch/lib/processor.mk
> @@ -0,0 +1,7 @@
> +PROCESSOR=$(shell uname -m)
> +PROCESSOR_x86_64=64
> +PROCESSOR_i686=32
> +PROCESSOR_i586=32
> +PROCESSOR_i386=32
> +PROCESSOR_i486=32
> +PROCESSOR_SIZE=$(PROCESSOR_$(PROCESSOR))

The rest of the tree appears to use BITS instead of PROCESSOR_SIZE. And
I do hope there's a cleaner way for lib to set PROCESSOR_SIZE than this.

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
