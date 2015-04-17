Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B6C57900018
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:42:00 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so123013355pdb.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:42:00 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [2001:200:0:8803::53])
        by mx.google.com with ESMTPS id g12si16011208pat.50.2015.04.17.02.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 02:41:58 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH v2 10/11] lib: libos build scripts and documentation
Date: Fri, 17 Apr 2015 18:36:13 +0900
Message-Id: <1429263374-57517-11-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Signed-off-by: Ryo Nakamura <upa@haeena.net>
---
 Documentation/virtual/libos-howto.txt | 144 ++++++++
 MAINTAINERS                           |   9 +
 arch/lib/.gitignore                   |   8 +
 arch/lib/Kconfig                      | 121 +++++++
 arch/lib/Makefile                     | 251 +++++++++++++
 arch/lib/Makefile.print               |  45 +++
 arch/lib/defconfig                    | 653 ++++++++++++++++++++++++++++++++++
 arch/lib/generate-linker-script.py    |  50 +++
 arch/lib/processor.mk                 |   7 +
 9 files changed, 1288 insertions(+)
 create mode 100644 Documentation/virtual/libos-howto.txt
 create mode 100644 arch/lib/.gitignore
 create mode 100644 arch/lib/Kconfig
 create mode 100644 arch/lib/Makefile
 create mode 100644 arch/lib/Makefile.print
 create mode 100644 arch/lib/defconfig
 create mode 100755 arch/lib/generate-linker-script.py
 create mode 100644 arch/lib/processor.mk

diff --git a/Documentation/virtual/libos-howto.txt b/Documentation/virtual/libos-howto.txt
new file mode 100644
index 0000000..fbf7946
--- /dev/null
+++ b/Documentation/virtual/libos-howto.txt
@@ -0,0 +1,144 @@
+Library operating system (libos) version of Linux
+=================================================
+
+* Overview
+
+New hardware independent architecture 'arch/lib', configured by
+CONFIG_LIB gives you two features.
+
+- network stack in userspace (NUSE)
+  NUSE will give you a personalized network stack for each application
+  without replacing host operating system.
+
+- network simulator integration, which is called Direct Code Execution (DCE)
+  DCE will give us a network simulation environment with Linux network stack
+  to investigate the detail behavior protocol implementation with a flexible
+  network configuration. This is also useful for the testing environment.
+
+(- more abstracted implementation of underlying platform will be a future
+   direction (e.g., rump hypercall))
+
+In both features, Linux kernel network stack is running on top of
+userspace application with a linked or dynamically loaded library.
+
+They have their own, isolated network stack from host operating system
+so they are configured different IP addresses as other virtualization
+methods do.
+
+
+* How different with others ?
+
+- User-mode Linux (UML)
+
+UML is a way to execute Linux kernel code as a userspace
+application. It is completely isolated from host kernel but can host
+arbitrary userspace applications on top of UML.
+
+- namespace / container
+
+Container technologies with namespace brings a process-level isolation
+to host multiple network entities but shares the kernel among
+processes, which prevents to introduce new features implemented in
+kernel space.
+
+
+* How to build it ?
+
+configuration of arch/lib follows a standard configuration of kernel.
+
+ make defconfig ARCH=lib
+
+or
+
+ make menuconfig ARCH=lib
+
+then you can build a set of libraries for libos.
+
+ make library ARCH=lib
+
+This will give you a shared library file liblinux-$(KERNELVERSION).so
+in the top directory.
+
+* Hello world
+
+you may first need to configure a configuration file, named
+'nuse.conf' so that the library version of network stack can know what
+kind of IP configuration should be used. There is an example file
+at arch/lib/nuse.conf.sample: you may copy and modify it for your purpose.
+
+ sudo NUSECONF=nuse.conf ./nuse ping www.google.com
+
+
+
+* Example use cases
+- regression test with Direct Code Execution (DCE)
+
+'make test' by DCE gives a test platform for networking code, with the
+help of network simulator facilities like link delay/bandwidth/drop
+configurations, large network topology with userspace routing protocol
+daemons, etc.
+
+An interesting feature is the determinism of any test executions. A
+test script always gives same results in every execution if there is
+no modification on test target code.
+
+For the first step, you need to obtain network simulator
+environment. 'make testbin' does all the stuff for the preparation.
+
+% make testbin -C tools/testing/libos
+
+Then, you can 'make test' for your code.
+
+% make test ARCH=lib
+
+ PASS: TestSuite netlink-socket
+ PASS: TestSuite process-manager
+ PASS: TestSuite dce-cradle
+ PASS: TestSuite dce-mptcp
+ PASS: TestSuite dce-umip
+ PASS: TestSuite dce-quagga
+ PASS: Example dce-tcp-simple
+ PASS: Example dce-udp-simple
+
+
+- userspace network stack (NUSE)
+
+an application can use its own network stack, distinct from host network stack
+in order to personalize any network feature to the application specific one.
+The 'nuse' wrapper script, based on LD_PRELOAD technique, carefully replaces
+socket API and redirects system calls to the network stack library, provided by
+this framework.
+
+the network stack can be used with any kind of raw-socket like
+technologies such as Intel DPDK, netmap, etc.
+
+
+
+* Files / External Repository
+
+The kernel source tree (i.e., arch/lib) only contains a shared part of
+applications (NUSE/DCE). Pure userspace part is managed at a different
+repository, called Linux-libos-tools: it is automatically downloaded
+during make library.
+
+ https://github.com/libos-nuse/linux-libos-tools
+
+
+* More information
+- libos-nuse@googlegroups.com (LibOS in general and NUSE related questions)
+- ns-3-users@googlegroups.com (ns-3 related questions)
+- articles, slides
+ Experimentation Tools for Networking Research (Lacage, 2010)
+   http://cutebugs.net/files/thesis.pdf
+ Direct code execution: revisiting library OS architecture for reproducible
+  network experiments (Tazaki et al., 2013)
+   http://dx.doi.org/10.1145/2535372.2535374
+ Library Operating System with Mainline Linux Network Stack (Tazaki et al., 2015)
+   https://www.netdev01.org/docs/netdev01-tazaki-libos.pdf (slides)
+
+
+* Authors
+ Mathieu Lacage <mathieu.lacage@gmail.com>
+ Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ Frederic Urbani <frederic.urbani@gmail.com>
+ Ryo Nakamura <upa@haeena.net>
diff --git a/MAINTAINERS b/MAINTAINERS
index 3589d67..ae88290 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5699,6 +5699,15 @@ M:	Sasha Levin <sasha.levin@oracle.com>
 S:	Maintained
 F:	tools/lib/lockdep/
 
+LIBRARY OS (LIBOS)
+M:	Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+L:	libos-nuse@googlegroups.com
+W:	http://libos-nuse.github.io/
+S:	Maintained
+F:	Documentation/virtual/libos-howto.txt
+F:	arch/lib/
+F:	tools/testing/libos/
+
 LINUX FOR IBM pSERIES (RS/6000)
 M:	Paul Mackerras <paulus@au.ibm.com>
 W:	http://www.ibm.com/linux/ltc/projects/ppc
diff --git a/arch/lib/.gitignore b/arch/lib/.gitignore
new file mode 100644
index 0000000..9f48573
--- /dev/null
+++ b/arch/lib/.gitignore
@@ -0,0 +1,8 @@
+linker.lds
+autoconf.h
+objs.mk
+timeconst.h
+hz.bc
+crc32table.h
+*.d
+tools
diff --git a/arch/lib/Kconfig b/arch/lib/Kconfig
new file mode 100644
index 0000000..eb7dede
--- /dev/null
+++ b/arch/lib/Kconfig
@@ -0,0 +1,121 @@
+menuconfig LIB
+       bool "LibOS-specific options"
+       def_bool n
+       select PROC_FS
+       select PROC_SYSCTL
+       select SYSCTL
+       select SYSFS
+       help
+          The 'lib' architecture is a library (user-mode) version of
+          the linux kernel that includes only its network stack and is
+	  used within the userspace application, and ns-3 simulator.
+	  For more information, about ns-3, see http://www.nsnam.org.
+
+config EXPERIMENTAL
+	def_bool y
+
+config MMU
+        def_bool n
+config FPU
+        def_bool n
+config SMP
+        def_bool n
+
+config ARCH
+	string
+	option env="ARCH"
+
+config KTIME_SCALAR
+       def_bool y
+
+config MODULES
+       def_bool y
+       option modules
+
+config GENERIC_CSUM
+	def_bool y
+
+config GENERIC_BUG
+	def_bool y
+	depends on BUG
+config PRINTK
+       def_bool y
+
+config RWSEM_GENERIC_SPINLOCK
+	def_bool y
+
+config GENERIC_FIND_NEXT_BIT
+	def_bool y
+
+config GENERIC_HWEIGHT
+       def_bool y
+
+config TRACE_IRQFLAGS_SUPPORT
+	def_bool y
+
+config NO_HZ
+	def_bool y
+
+config BASE_FULL
+       def_bool n
+
+config SELECT_MEMORY_MODEL
+       def_bool n
+
+config FLAT_NODE_MEM_MAP
+       def_bool n
+
+config PAGEFLAGS_EXTENDED
+       def_bool n
+
+config VIRT_TO_BUS
+       def_bool n
+
+config HAS_DMA
+       def_bool n
+
+config HZ
+        int
+        default 250
+
+config TINY_RCU
+       def_bool y
+
+config HZ_250
+       def_bool y
+
+config BASE_SMALL
+       int
+       default 1
+
+config SPLIT_PTLOCK_CPUS
+       int
+       default 1
+
+config FLATMEM
+       def_bool y
+
+config SYSCTL
+       def_bool y
+
+config PROC_FS
+       def_bool y
+
+config SYSFS
+       def_bool y
+
+config PROC_SYSCTL
+       def_bool y
+
+config NETDEVICES
+       def_bool y
+
+source "net/Kconfig"
+
+source "drivers/base/Kconfig"
+
+source "crypto/Kconfig"
+
+source "lib/Kconfig"
+
+
diff --git a/arch/lib/Makefile b/arch/lib/Makefile
new file mode 100644
index 0000000..624c2ef
--- /dev/null
+++ b/arch/lib/Makefile
@@ -0,0 +1,251 @@
+ARCH_DIR := arch/lib
+SRCDIR=$(dir $(firstword $(MAKEFILE_LIST)))
+DCE_TESTDIR=$(srctree)/tools/testing/libos/
+KBUILD_KCONFIG := arch/$(ARCH)/Kconfig
+
+CC = gcc
+GCCVERSIONGTEQ48 := $(shell expr `gcc -dumpversion` \>= 4.8)
+ifeq "$(GCCVERSIONGTEQ48)" "1"
+   NO_TREE_LOOP_OPT += -fno-tree-loop-distribute-patterns
+endif
+
+
+-include $(ARCH_DIR)/objs.mk
+-include $(srctree)/.config
+include $(srctree)/scripts/Kbuild.include
+include $(ARCH_DIR)/processor.mk
+
+# targets
+LIBOS_TOOLS=$(ARCH_DIR)/tools
+LIBOS_GIT_REPO=git://github.com/libos-nuse/linux-libos-tools
+KERNEL_LIB=liblinux-$(KERNELVERSION).so
+
+ALL_OBJS=$(OBJS) $(KERNEL_LIB) $(modules) $(all-obj-for-clean)
+
+# auto generated files
+AUTOGENS=$(CRC32TABLE) $(COMPILE_H) $(BOUNDS_H) $(ARCH_DIR)/timeconst.h $(ARCH_DIR)/linker.lds
+COMPILE_H=$(srctree)/include/generated/compile.h
+BOUNDS_H=$(srctree)/include/generated/bounds.h
+
+# from lib/Makefile
+CRC32TABLE = $(ARCH_DIR)/crc32table.h
+hostprogs-y	:= $(srctree)/lib/gen_crc32table
+clean-files	:= crc32table.h
+
+# sources and objects
+LIB_SRC=\
+lib.c lib-device.c lib-socket.c random.c softirq.c time.c \
+timer.c hrtimer.c sched.c workqueue.c \
+print.c slab.c tasklet.c tasklet-hrtimer.c \
+glue.c fs.c sysctl.c proc.c sysfs.c \
+capability.c pid.c modules.c filemap.c vmscan.c
+
+LIB_OBJ=$(addprefix $(ARCH_DIR)/,$(addsuffix .o,$(basename $(LIB_SRC))))
+LIB_DEPS=$(addprefix $(ARCH_DIR)/.,$(addsuffix .o.cmd,$(basename $(LIB_SRC))))
+-include $(LIB_DEPS)
+
+DEPENDS=$(addprefix $(ARCH_DIR)/.,\
+	$(addsuffix .d,$(basename $(LIB_SRC)))\
+	)
+
+# options
+COV?=no
+cov_yes=-fprofile-arcs -ftest-coverage
+cov_no=
+covl_yes=-fprofile-arcs
+covl_no=
+OPT?=yes
+opt_yes=-O3 -fomit-frame-pointer $(NO_TREE_LOOP_OPT)
+opt_no=-O0
+PIC?=yes
+pic_yes=-fpic -DPIC
+pic_no=-mcmodel=large
+PIC_CFLAGS=$(pic_$(PIC))
+
+# flags
+CFLAGS_USPACE= \
+ -Wp,-MD,$(depfile) $(opt_$(OPT)) -g3 -Wall -Wstrict-prototypes -Wno-trigraphs \
+ -fno-inline -fno-strict-aliasing -fno-common \
+ -fno-delete-null-pointer-checks -fno-builtin \
+ -fno-stack-protector -Wno-unused -Wno-pointer-sign \
+ $(PIC_CFLAGS) -D_DEBUG $(cov_$(COV)) -I$(ARCH_DIR)/include
+
+CFLAGS+= \
+ $(CFLAGS_USPACE) -nostdinc -D__KERNEL__ -iwithprefix $(srctree)/include \
+ -DKBUILD_BASENAME=\"clnt\" -DKBUILD_MODNAME=\"nsc\" -DMODVERSIONS \
+ -DEXPORT_SYMTAB \
+ -U__FreeBSD__ -D__linux__=1 -Dlinux=1 -D__linux=1 \
+ -DCONFIG_DEFAULT_HOSTNAME=\"lib\" \
+ -I$(ARCH_DIR)/include/generated/uapi \
+ -I$(ARCH_DIR)/include/generated \
+ -I$(srctree)/include -I$(ARCH_DIR)/include/uapi \
+ -I$(srctree)/include/uapi -I$(srctree)/include/generated/uapi \
+ -include $(srctree)/include/linux/kconfig.h \
+ -I$(ARCH_DIR) -I.
+
+ifeq ($(PROCESSOR_SIZE),64)
+CFLAGS+= -DCONFIG_64BIT
+endif
+
+LDFLAGS += -shared -nodefaultlibs -g3 -Wl,-O1 -Wl,-T$(ARCH_DIR)/linker.lds $(covl_$(COV))
+
+# targets
+
+modules:=
+all-obj-for-clean:=
+
+all: library modules
+
+# note: the directory order below matters to ensure that we match the kernel order
+dirs=kernel/ kernel/time/ kernel/rcu/ kernel/locking/ kernel/bpf/ mm/ fs/ fs/proc/ crypto/ lib/ drivers/base/ drivers/net/ net/ init/
+empty:=
+space:= $(empty) $(empty)
+colon:= :
+comma= ,
+kernel/_to_keep=notifier.o params.o sysctl.o \
+rwsem.o semaphore.o kfifo.o cred.o user.o groups.o ksysfs.o
+kernel/time/_to_keep=time.o
+kernel/rcu_to_keep=rcu/srcu.o rcu/pdate.o rcu/tiny.o
+kernel/locking_to_keep=locking/mutex.o
+kernel/bpf_to_keep=bpf/core.o
+mm/_to_keep=util.o list_lru.o
+crypto/_to_keep=aead.o ahash.o shash.o api.o algapi.o cipher.o compress.o proc.o \
+crc32c_generic.o
+drivers/base/_to_keep=class.o core.o bus.o dd.o driver.o devres.o module.o map.o
+drivers/net/_to_keep=loopback.o
+lib/_to_keep=klist.o kobject.o kref.o hweight.o int_sqrt.o checksum.o \
+find_last_bit.o find_next_bit.o bitmap.o nlattr.o idr.o libcrc32c.o \
+ctype.o string.o kasprintf.o rbtree.o sha1.o textsearch.o vsprintf.o \
+rwsem-spinlock.o scatterlist.o ratelimit.o hexdump.o dec_and_lock.o \
+div64.o dynamic_queue_limits.o md5.o kstrtox.o iovec.o lockref.o crc32.o \
+rhashtable.o iov_iter.o cmdline.o kobject_uevent.o
+fs/_to_keep=read_write.o libfs.o namei.o filesystems.o file.o file_table.o \
+dcache.o inode.o pipe.o char_dev.o splice.o no-block.o seq_file.o super.o \
+fcntl.o coredump.o
+fs/proc/_to_keep=proc_sysctl.o proc_net.o root.o generic.o inode.o
+init/_to_keep=version.o
+
+quiet_cmd_objsmk = OBJS-MK   $@
+      cmd_objsmk = \
+	for i in 1; do \
+	$(foreach d,$(dirs), \
+           $(MAKE) -i -s -f $< srcdir=$(srctree)/$(d) \
+	    objdir=$(srctree)/$(d) \
+            config=$(srctree)/.config \
+	    to_keep=$(subst $(space),$(colon),$($(d)_to_keep)) print;) \
+	done > $@
+
+$(ARCH_DIR)/objs.mk: $(ARCH_DIR)/Makefile.print $(srctree)/.config $(ARCH_DIR)/Makefile
+	+$(call if_changed,objsmk)
+
+quiet_cmd_timeconst = GEN     $@
+      cmd_timeconst = echo "hz=$(CONFIG_HZ)" > $(ARCH_DIR)/hz.bc ; \
+                      bc $(ARCH_DIR)/hz.bc kernel/time/timeconst.bc > $@
+$(ARCH_DIR)/timeconst.h: $(srctree)/.config
+	$(call if_changed,timeconst)
+
+quiet_cmd_linker = GEN     $@
+      cmd_linker = ld -shared --verbose | ./$^ > $@
+$(ARCH_DIR)/linker.lds: $(ARCH_DIR)/generate-linker-script.py
+	$(call if_changed,linker)
+
+quiet_cmd_crc32src = GEN     $@
+      cmd_crc32src = $(MAKE) -f $(srctree)/Makefile silentoldconfig ; \
+                     cc $^ -o $@
+$(srctree)/lib/gen_crc32table: $(srctree)/lib/gen_crc32table.c
+	$(call if_changed,crc32src)
+
+quiet_cmd_crc32 = GEN     $@
+      cmd_crc32 = $< > $@
+
+$(CRC32TABLE): $(srctree)/lib/gen_crc32table
+	$(call if_changed,crc32)
+
+# copied from init/Makefile
+       chk_compile.h = :
+ quiet_chk_compile.h = echo '  CHK     $@'
+silent_chk_compile.h = :
+$(COMPILE_H): include/generated/utsrelease.h asm-generic $(version_h)
+	@$($(quiet)chk_compile.h)
+	+$(Q)$(CONFIG_SHELL) $(srctree)/scripts/mkcompile_h $@ \
+	"$(UTS_MACHINE)" "$(CONFIG_SMP)" "$(CONFIG_PREEMPT)" "$(CC) $(KBUILD_CFLAGS)"
+
+# crafted from $(srctree)/Kbuild
+quiet_cmd_lib_bounds = GEN     $@
+define cmd_lib_bounds
+	(set -e; \
+	 echo "#ifndef GENERATED_BOUNDS_H"; \
+	 echo "#define GENERATED_BOUNDS_H"; \
+	 echo ""; \
+	 echo "#define NR_PAGEFLAGS (__NR_PAGEFLAGS)"; \
+	 echo "#define MAX_NR_ZONES (__MAX_NR_ZONES)"; \
+	 echo ""; \
+	 echo "#endif /* GENERATED_BOUNDS_H */") > $@
+endef
+
+$(BOUNDS_H):
+	$(Q)mkdir -p $(dir $@)
+	$(call cmd,lib_bounds)
+
+
+KERNEL_BUILTIN=$(addprefix $(srctree)/,$(addsuffix builtin.o,$(dirs)))
+OBJS=$(LIB_OBJ) $(foreach builtin,$(KERNEL_BUILTIN),$(if $($(builtin)),$($(builtin))))
+export OBJS KERNEL_LIB COV covl_yes covl_no
+
+quiet_cmd_cc = CC      $@
+      cmd_cc = 	mkdir -p $(dir $@);	\
+		$(CC) $(CFLAGS) -c $< -o $@
+quiet_cmd_linkko = KO   $@
+      cmd_linkko = $(CC) -shared -o $@ -nostdlib $^
+quiet_cmd_builtin = BUILTIN   $@
+      cmd_builtin = mkdir -p $(dir $(srctree)/$@); rm -f $(srctree)/$@; \
+		    if test -n "$($(srctree)/$@)"; then for f in $($(srctree)/$@); \
+		    do $(AR) Tcru $@ $$f; done; else $(AR) Tcru $@; fi
+
+%/builtin.o:
+	$(call if_changed,builtin)
+%.ko:%.o
+	$(call if_changed,linkko)
+%.o:%.c
+	$(call if_changed_dep,cc)
+
+library: $(KERNEL_LIB) $(LIBOS_TOOLS)
+modules: $(modules)
+
+$(LIBOS_TOOLS): $(KERNEL_LIB) Makefile FORCE
+	$(Q) if [ ! -d "$@" ]; then \
+		git clone $(LIBOS_GIT_REPO) $@ ;\
+	fi
+	$(Q) $(MAKE) -C $(LIBOS_TOOLS)
+
+install: modules library
+
+install-dir:
+
+$(KERNEL_LIB): $(ARCH_DIR)/objs.mk $(AUTOGENS) $(OBJS)
+	$(call if_changed,linklib)
+
+quiet_cmd_linklib = LIB     $@
+      cmd_linklib = $(CC) -Wl,--whole-archive $(OBJS) $(LDFLAGS) -o $@; \
+		    ln -s -f $(KERNEL_LIB) liblinux.so
+
+quiet_cmd_clean = CLEAN   $@
+      cmd_clean = for f in $(foreach m,$(modules),$($(m))) ; do rm -f $$f 2>/dev/null; done ; \
+		  for f in $(ALL_OBJS); do rm -f $$f; done 2>/dev/null ;\
+		  rm -rf $(AUTOGENS) $(ARCH_DIR)/objs.mk 2>/dev/null ;\
+		  if [ -d $(LIBOS_TOOLS) ]; then $(MAKE) -C $(LIBOS_TOOLS) clean ; fi
+
+archclean:
+	$(call if_changed,clean)
+
+.%.d:%.c $(srctree)/.config
+	$(Q) set -e; $(CC) -MM -MT $(<:.c=.o) $(CFLAGS) $< > $@
+
+deplib: $(DEPENDS)
+	-include $(DEPENDS)
+
+test:
+	$(Q) $(MAKE) -C $(DCE_TESTDIR)/
+
+.PHONY : clean deplib
+
diff --git a/arch/lib/Makefile.print b/arch/lib/Makefile.print
new file mode 100644
index 0000000..40e6db0
--- /dev/null
+++ b/arch/lib/Makefile.print
@@ -0,0 +1,45 @@
+# inherit $(objdir) $(config) $(srcdir) $(to_keep) from command-line
+
+include $(config)
+include $(srcdir)Makefile
+
+# fix minor nits for make version dependencies
+ifeq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
+  SEPARATOR=
+else
+  SEPARATOR=/
+endif
+
+to_keep_list=$(subst :, ,$(to_keep))
+obj-y += $(lib-y)
+obj-m += $(lib-m)
+subdirs := $(filter %/, $(obj-y) $(obj-m))
+subdirs-y := $(filter %/, $(obj-y))
+subdirs-m := $(filter %/, $(obj-m))
+tmp1-obj-y=$(patsubst %/,%/builtin.o,$(obj-y))
+tmp1-obj-m=$(filter-out $(subdirs-m),$(obj-m))
+tmp2-obj-y=$(foreach m,$(tmp1-obj-y), $(if $($(m:.o=-objs)),$($(m:.o=-objs)),$(if $($(m:.o=-y)),$($(m:.o=-y)),$(m))))
+tmp2-obj-m=$(foreach m,$(tmp1-obj-m), $(if $($(m:.o=-objs)),$($(m:.o=-objs)),$(if $($(m:.o=-y)),$($(m:.o=-y)),$(m))))
+tmp3-obj-y=$(if $(to_keep_list),$(filter $(to_keep_list),$(tmp2-obj-y)),$(tmp2-obj-y))
+tmp3-obj-m=$(if $(to_keep_list),$(filter $(to_keep_list),$(tmp2-obj-m)),$(tmp2-obj-m))
+final-obj-y=$(tmp3-obj-y)
+final-obj-m=$(tmp3-obj-m)
+
+print: $(final-obj-m) $(subdirs)
+	@if test $(if $(final-obj-y),1); then \
+	  echo -n $(objdir)builtin.o; echo -n "="; echo $(addprefix $(objdir),$(final-obj-y)); \
+	  echo -n $(objdir)builtin.o; echo -n ": "; echo $(addprefix $(objdir),$(final-obj-y)); \
+          echo -n "-include "; echo $(addprefix $(objdir).,$(addsuffix ".cmd", $(final-obj-y))); \
+	  echo -n "all-obj-for-clean+="; echo $(addprefix $(objdir),$(final-obj-y)) $(objdir)builtin.o; \
+	fi
+$(final-obj-m):
+	@echo -n "modules+="; echo $(addprefix $(objdir),$(@:.o=.ko))
+	@echo -n $(addprefix $(objdir),$(@:.o=.ko)); echo -n ": "
+	@echo $(addprefix $(objdir),$(if $($(@:.o=-objs)),$($(@:.o=-objs)),$@))
+	@echo -n $(addprefix $(objdir),$(@:.o=.ko)); echo -n "="
+	@echo $(addprefix $(objdir),$(if $($(@:.o=-objs)),$($(@:.o=-objs)),$@))
+$(subdirs):
+	@$(MAKE) -s -f $(firstword $(MAKEFILE_LIST)) objdir=$(objdir)$@$(SEPARATOR) config=$(config) srcdir=$(srcdir)$@$(SEPARATOR) to_keep=$(to_keep) print 2>/dev/null
+
+.PHONY : core
+.NOTPARALLEL : print $(subdirs) $(final-obj-m)
diff --git a/arch/lib/defconfig b/arch/lib/defconfig
new file mode 100644
index 0000000..9307e6f
--- /dev/null
+++ b/arch/lib/defconfig
@@ -0,0 +1,653 @@
+#
+# Automatically generated file; DO NOT EDIT.
+# Linux Kernel Configuration
+#
+CONFIG_LIB=y
+CONFIG_EXPERIMENTAL=y
+# CONFIG_MMU is not set
+# CONFIG_FPU is not set
+# CONFIG_SMP is not set
+CONFIG_KTIME_SCALAR=y
+CONFIG_MODULES=y
+CONFIG_GENERIC_CSUM=y
+CONFIG_PRINTK=y
+CONFIG_RWSEM_GENERIC_SPINLOCK=y
+CONFIG_GENERIC_FIND_NEXT_BIT=y
+CONFIG_GENERIC_HWEIGHT=y
+CONFIG_TRACE_IRQFLAGS_SUPPORT=y
+CONFIG_NO_HZ=y
+# CONFIG_BASE_FULL is not set
+# CONFIG_SELECT_MEMORY_MODEL is not set
+# CONFIG_FLAT_NODE_MEM_MAP is not set
+# CONFIG_PAGEFLAGS_EXTENDED is not set
+# CONFIG_VIRT_TO_BUS is not set
+# CONFIG_HAS_DMA is not set
+CONFIG_HZ=250
+CONFIG_TINY_RCU=y
+CONFIG_HZ_250=y
+CONFIG_BASE_SMALL=1
+CONFIG_SPLIT_PTLOCK_CPUS=1
+CONFIG_FLATMEM=y
+CONFIG_SYSCTL=y
+CONFIG_PROC_FS=y
+CONFIG_SYSFS=y
+CONFIG_PROC_SYSCTL=y
+CONFIG_NET=y
+CONFIG_NETDEVICES=y
+
+#
+# Networking options
+#
+CONFIG_PACKET=y
+# CONFIG_PACKET_DIAG is not set
+CONFIG_UNIX=y
+# CONFIG_UNIX_DIAG is not set
+CONFIG_XFRM=y
+CONFIG_XFRM_ALGO=y
+CONFIG_XFRM_USER=y
+CONFIG_XFRM_SUB_POLICY=y
+CONFIG_XFRM_MIGRATE=y
+CONFIG_XFRM_STATISTICS=y
+CONFIG_XFRM_IPCOMP=y
+CONFIG_NET_KEY=y
+CONFIG_NET_KEY_MIGRATE=y
+CONFIG_INET=y
+CONFIG_IP_MULTICAST=y
+CONFIG_IP_ADVANCED_ROUTER=y
+# CONFIG_IP_FIB_TRIE_STATS is not set
+CONFIG_IP_MULTIPLE_TABLES=y
+CONFIG_IP_ROUTE_MULTIPATH=y
+CONFIG_IP_ROUTE_VERBOSE=y
+# CONFIG_IP_PNP is not set
+CONFIG_NET_IPIP=y
+CONFIG_NET_IPGRE_DEMUX=y
+CONFIG_NET_IP_TUNNEL=y
+CONFIG_NET_IPGRE=y
+# CONFIG_NET_IPGRE_BROADCAST is not set
+CONFIG_IP_MROUTE=y
+CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
+CONFIG_IP_PIMSM_V1=y
+CONFIG_IP_PIMSM_V2=y
+CONFIG_SYN_COOKIES=y
+# CONFIG_NET_IPVTI is not set
+CONFIG_NET_UDP_TUNNEL=m
+# CONFIG_NET_FOU is not set
+# CONFIG_NET_FOU_IP_TUNNELS is not set
+# CONFIG_GENEVE is not set
+CONFIG_INET_AH=y
+CONFIG_INET_ESP=y
+CONFIG_INET_IPCOMP=y
+CONFIG_INET_XFRM_TUNNEL=y
+CONFIG_INET_TUNNEL=y
+CONFIG_INET_XFRM_MODE_TRANSPORT=y
+CONFIG_INET_XFRM_MODE_TUNNEL=y
+CONFIG_INET_XFRM_MODE_BEET=y
+# CONFIG_INET_LRO is not set
+CONFIG_INET_DIAG=y
+CONFIG_INET_TCP_DIAG=y
+CONFIG_INET_UDP_DIAG=y
+CONFIG_TCP_CONG_ADVANCED=y
+CONFIG_TCP_CONG_BIC=y
+CONFIG_TCP_CONG_CUBIC=y
+CONFIG_TCP_CONG_WESTWOOD=y
+CONFIG_TCP_CONG_HTCP=y
+CONFIG_TCP_CONG_HSTCP=y
+CONFIG_TCP_CONG_HYBLA=y
+CONFIG_TCP_CONG_VEGAS=y
+CONFIG_TCP_CONG_SCALABLE=y
+CONFIG_TCP_CONG_LP=y
+CONFIG_TCP_CONG_VENO=y
+CONFIG_TCP_CONG_YEAH=y
+CONFIG_TCP_CONG_ILLINOIS=y
+CONFIG_TCP_CONG_DCTCP=y
+# CONFIG_DEFAULT_BIC is not set
+# CONFIG_DEFAULT_CUBIC is not set
+# CONFIG_DEFAULT_HTCP is not set
+# CONFIG_DEFAULT_HYBLA is not set
+# CONFIG_DEFAULT_VEGAS is not set
+# CONFIG_DEFAULT_VENO is not set
+# CONFIG_DEFAULT_WESTWOOD is not set
+# CONFIG_DEFAULT_DCTCP is not set
+CONFIG_DEFAULT_RENO=y
+CONFIG_DEFAULT_TCP_CONG="reno"
+# CONFIG_TCP_MD5SIG is not set
+CONFIG_IPV6=y
+CONFIG_IPV6_ROUTER_PREF=y
+# CONFIG_IPV6_ROUTE_INFO is not set
+# CONFIG_IPV6_OPTIMISTIC_DAD is not set
+CONFIG_INET6_AH=y
+CONFIG_INET6_ESP=y
+CONFIG_INET6_IPCOMP=y
+CONFIG_IPV6_MIP6=y
+CONFIG_INET6_XFRM_TUNNEL=y
+CONFIG_INET6_TUNNEL=y
+CONFIG_INET6_XFRM_MODE_TRANSPORT=y
+CONFIG_INET6_XFRM_MODE_TUNNEL=y
+CONFIG_INET6_XFRM_MODE_BEET=y
+CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
+# CONFIG_IPV6_VTI is not set
+CONFIG_IPV6_SIT=y
+# CONFIG_IPV6_SIT_6RD is not set
+CONFIG_IPV6_NDISC_NODETYPE=y
+CONFIG_IPV6_TUNNEL=y
+# CONFIG_IPV6_GRE is not set
+CONFIG_IPV6_MULTIPLE_TABLES=y
+CONFIG_IPV6_SUBTREES=y
+# CONFIG_IPV6_MROUTE is not set
+# CONFIG_NETWORK_SECMARK is not set
+# CONFIG_NET_PTP_CLASSIFY is not set
+# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
+CONFIG_NETFILTER=y
+CONFIG_NETFILTER_DEBUG=y
+CONFIG_NETFILTER_ADVANCED=y
+CONFIG_BRIDGE_NETFILTER=m
+
+#
+# Core Netfilter Configuration
+#
+CONFIG_NETFILTER_NETLINK=y
+CONFIG_NETFILTER_NETLINK_ACCT=y
+CONFIG_NETFILTER_NETLINK_QUEUE=y
+CONFIG_NETFILTER_NETLINK_LOG=y
+CONFIG_NF_CONNTRACK=y
+CONFIG_NF_LOG_COMMON=y
+CONFIG_NF_CONNTRACK_MARK=y
+CONFIG_NF_CONNTRACK_PROCFS=y
+CONFIG_NF_CONNTRACK_EVENTS=y
+CONFIG_NF_CONNTRACK_TIMEOUT=y
+CONFIG_NF_CONNTRACK_TIMESTAMP=y
+CONFIG_NF_CT_PROTO_DCCP=y
+CONFIG_NF_CT_PROTO_SCTP=y
+CONFIG_NF_CT_PROTO_UDPLITE=y
+CONFIG_NF_CONNTRACK_AMANDA=y
+CONFIG_NF_CONNTRACK_FTP=y
+# CONFIG_NF_CONNTRACK_H323 is not set
+# CONFIG_NF_CONNTRACK_IRC is not set
+# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
+# CONFIG_NF_CONNTRACK_SNMP is not set
+# CONFIG_NF_CONNTRACK_PPTP is not set
+# CONFIG_NF_CONNTRACK_SANE is not set
+# CONFIG_NF_CONNTRACK_SIP is not set
+# CONFIG_NF_CONNTRACK_TFTP is not set
+# CONFIG_NF_CT_NETLINK is not set
+# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
+CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
+CONFIG_NF_NAT=y
+CONFIG_NF_NAT_NEEDED=y
+CONFIG_NF_NAT_PROTO_DCCP=y
+CONFIG_NF_NAT_PROTO_UDPLITE=y
+CONFIG_NF_NAT_PROTO_SCTP=y
+CONFIG_NF_NAT_AMANDA=y
+CONFIG_NF_NAT_FTP=y
+# CONFIG_NF_NAT_IRC is not set
+# CONFIG_NF_NAT_SIP is not set
+# CONFIG_NF_NAT_TFTP is not set
+CONFIG_NF_NAT_REDIRECT=y
+CONFIG_NF_TABLES=y
+CONFIG_NF_TABLES_INET=y
+CONFIG_NFT_EXTHDR=y
+CONFIG_NFT_META=y
+CONFIG_NFT_CT=y
+CONFIG_NFT_RBTREE=y
+CONFIG_NFT_HASH=y
+CONFIG_NFT_COUNTER=y
+CONFIG_NFT_LOG=y
+CONFIG_NFT_LIMIT=y
+CONFIG_NFT_MASQ=y
+# CONFIG_NFT_REDIR is not set
+CONFIG_NFT_NAT=y
+# CONFIG_NFT_QUEUE is not set
+# CONFIG_NFT_REJECT is not set
+# CONFIG_NFT_REJECT_INET is not set
+# CONFIG_NFT_COMPAT is not set
+CONFIG_NETFILTER_XTABLES=y
+
+#
+# Xtables combined modules
+#
+CONFIG_NETFILTER_XT_MARK=y
+CONFIG_NETFILTER_XT_CONNMARK=y
+# CONFIG_NETFILTER_XT_SET is not set
+
+#
+# Xtables targets
+#
+CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
+CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
+# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
+CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
+CONFIG_NETFILTER_XT_TARGET_LOG=y
+CONFIG_NETFILTER_XT_TARGET_MARK=y
+CONFIG_NETFILTER_XT_NAT=y
+CONFIG_NETFILTER_XT_TARGET_NETMAP=y
+CONFIG_NETFILTER_XT_TARGET_NFLOG=y
+CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
+CONFIG_NETFILTER_XT_TARGET_RATEEST=y
+CONFIG_NETFILTER_XT_TARGET_REDIRECT=y
+# CONFIG_NETFILTER_XT_TARGET_TEE is not set
+# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
+
+#
+# Xtables matches
+#
+# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
+# CONFIG_NETFILTER_XT_MATCH_BPF is not set
+# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set
+# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
+# CONFIG_NETFILTER_XT_MATCH_CONNBYTES is not set
+# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
+# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set
+# CONFIG_NETFILTER_XT_MATCH_CONNMARK is not set
+# CONFIG_NETFILTER_XT_MATCH_CONNTRACK is not set
+# CONFIG_NETFILTER_XT_MATCH_CPU is not set
+CONFIG_NETFILTER_XT_MATCH_DCCP=y
+# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
+# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
+# CONFIG_NETFILTER_XT_MATCH_ECN is not set
+# CONFIG_NETFILTER_XT_MATCH_ESP is not set
+# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
+# CONFIG_NETFILTER_XT_MATCH_HELPER is not set
+# CONFIG_NETFILTER_XT_MATCH_HL is not set
+# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
+# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
+CONFIG_NETFILTER_XT_MATCH_L2TP=m
+# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set
+# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set
+# CONFIG_NETFILTER_XT_MATCH_MAC is not set
+# CONFIG_NETFILTER_XT_MATCH_MARK is not set
+# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
+# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
+# CONFIG_NETFILTER_XT_MATCH_OSF is not set
+# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
+# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
+# CONFIG_NETFILTER_XT_MATCH_PHYSDEV is not set
+# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
+# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
+# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
+# CONFIG_NETFILTER_XT_MATCH_REALM is not set
+# CONFIG_NETFILTER_XT_MATCH_RECENT is not set
+CONFIG_NETFILTER_XT_MATCH_SCTP=y
+CONFIG_NETFILTER_XT_MATCH_SOCKET=y
+# CONFIG_NETFILTER_XT_MATCH_STATE is not set
+# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
+# CONFIG_NETFILTER_XT_MATCH_STRING is not set
+# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
+# CONFIG_NETFILTER_XT_MATCH_TIME is not set
+# CONFIG_NETFILTER_XT_MATCH_U32 is not set
+CONFIG_IP_SET=y
+CONFIG_IP_SET_MAX=256
+# CONFIG_IP_SET_BITMAP_IP is not set
+# CONFIG_IP_SET_BITMAP_IPMAC is not set
+# CONFIG_IP_SET_BITMAP_PORT is not set
+# CONFIG_IP_SET_HASH_IP is not set
+# CONFIG_IP_SET_HASH_IPMARK is not set
+# CONFIG_IP_SET_HASH_IPPORT is not set
+# CONFIG_IP_SET_HASH_IPPORTIP is not set
+# CONFIG_IP_SET_HASH_IPPORTNET is not set
+# CONFIG_IP_SET_HASH_MAC is not set
+# CONFIG_IP_SET_HASH_NETPORTNET is not set
+# CONFIG_IP_SET_HASH_NET is not set
+# CONFIG_IP_SET_HASH_NETNET is not set
+# CONFIG_IP_SET_HASH_NETPORT is not set
+# CONFIG_IP_SET_HASH_NETIFACE is not set
+# CONFIG_IP_SET_LIST_SET is not set
+# CONFIG_IP_VS is not set
+
+#
+# IP: Netfilter Configuration
+#
+CONFIG_NF_DEFRAG_IPV4=y
+CONFIG_NF_CONNTRACK_IPV4=y
+CONFIG_NF_CONNTRACK_PROC_COMPAT=y
+# CONFIG_NF_LOG_ARP is not set
+CONFIG_NF_LOG_IPV4=y
+CONFIG_NF_TABLES_IPV4=y
+CONFIG_NFT_CHAIN_ROUTE_IPV4=y
+# CONFIG_NF_REJECT_IPV4 is not set
+# CONFIG_NFT_REJECT_IPV4 is not set
+# CONFIG_NF_TABLES_ARP is not set
+# CONFIG_NF_NAT_IPV4 is not set
+CONFIG_IP_NF_IPTABLES=y
+# CONFIG_IP_NF_MATCH_AH is not set
+# CONFIG_IP_NF_MATCH_ECN is not set
+# CONFIG_IP_NF_MATCH_TTL is not set
+# CONFIG_IP_NF_FILTER is not set
+# CONFIG_IP_NF_TARGET_SYNPROXY is not set
+# CONFIG_IP_NF_NAT is not set
+# CONFIG_IP_NF_MANGLE is not set
+# CONFIG_IP_NF_RAW is not set
+# CONFIG_IP_NF_ARPTABLES is not set
+
+#
+# IPv6: Netfilter Configuration
+#
+CONFIG_NF_DEFRAG_IPV6=y
+CONFIG_NF_CONNTRACK_IPV6=y
+CONFIG_NF_TABLES_IPV6=y
+# CONFIG_NFT_CHAIN_ROUTE_IPV6 is not set
+# CONFIG_NF_REJECT_IPV6 is not set
+# CONFIG_NFT_REJECT_IPV6 is not set
+CONFIG_NF_LOG_IPV6=y
+# CONFIG_NF_NAT_IPV6 is not set
+# CONFIG_IP6_NF_IPTABLES is not set
+
+#
+# DECnet: Netfilter Configuration
+#
+# CONFIG_DECNET_NF_GRABULATOR is not set
+# CONFIG_NF_TABLES_BRIDGE is not set
+# CONFIG_BRIDGE_NF_EBTABLES is not set
+CONFIG_IP_DCCP=y
+CONFIG_INET_DCCP_DIAG=y
+
+#
+# DCCP CCIDs Configuration
+#
+# CONFIG_IP_DCCP_CCID2_DEBUG is not set
+CONFIG_IP_DCCP_CCID3=y
+# CONFIG_IP_DCCP_CCID3_DEBUG is not set
+CONFIG_IP_DCCP_TFRC_LIB=y
+CONFIG_IP_SCTP=y
+# CONFIG_SCTP_DBG_OBJCNT is not set
+# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
+# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
+CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
+# CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
+# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
+# CONFIG_RDS is not set
+# CONFIG_TIPC is not set
+CONFIG_ATM=m
+CONFIG_ATM_CLIP=m
+CONFIG_ATM_CLIP_NO_ICMP=y
+CONFIG_ATM_LANE=m
+CONFIG_ATM_MPOA=m
+CONFIG_ATM_BR2684=m
+CONFIG_ATM_BR2684_IPFILTER=y
+CONFIG_L2TP=m
+# CONFIG_L2TP_V3 is not set
+CONFIG_STP=m
+CONFIG_GARP=m
+CONFIG_BRIDGE=m
+CONFIG_BRIDGE_IGMP_SNOOPING=y
+# CONFIG_BRIDGE_VLAN_FILTERING is not set
+CONFIG_VLAN_8021Q=m
+CONFIG_VLAN_8021Q_GVRP=y
+# CONFIG_VLAN_8021Q_MVRP is not set
+CONFIG_DECNET=m
+# CONFIG_DECNET_ROUTER is not set
+CONFIG_LLC=m
+CONFIG_LLC2=m
+CONFIG_IPX=m
+CONFIG_IPX_INTERN=y
+CONFIG_ATALK=m
+CONFIG_DEV_APPLETALK=m
+CONFIG_IPDDP=m
+CONFIG_IPDDP_ENCAP=y
+# CONFIG_X25 is not set
+# CONFIG_LAPB is not set
+CONFIG_PHONET=m
+# CONFIG_6LOWPAN is not set
+# CONFIG_IEEE802154 is not set
+# CONFIG_NET_SCHED is not set
+# CONFIG_DCB is not set
+# CONFIG_BATMAN_ADV is not set
+# CONFIG_OPENVSWITCH is not set
+# CONFIG_VSOCKETS is not set
+# CONFIG_NETLINK_MMAP is not set
+# CONFIG_NETLINK_DIAG is not set
+# CONFIG_NET_MPLS_GSO is not set
+# CONFIG_HSR is not set
+# CONFIG_NET_SWITCHDEV is not set
+CONFIG_NET_RX_BUSY_POLL=y
+CONFIG_BQL=y
+
+#
+# Network testing
+#
+CONFIG_NET_PKTGEN=m
+# CONFIG_HAMRADIO is not set
+CONFIG_CAN=m
+CONFIG_CAN_RAW=m
+CONFIG_CAN_BCM=m
+CONFIG_CAN_GW=m
+
+#
+# CAN Device Drivers
+#
+CONFIG_CAN_VCAN=m
+CONFIG_CAN_DEV=m
+CONFIG_CAN_CALC_BITTIMING=y
+CONFIG_CAN_SJA1000=m
+# CONFIG_CAN_SJA1000_ISA is not set
+CONFIG_CAN_SJA1000_PLATFORM=m
+# CONFIG_CAN_C_CAN is not set
+# CONFIG_CAN_M_CAN is not set
+# CONFIG_CAN_CC770 is not set
+# CONFIG_CAN_SOFTING is not set
+CONFIG_CAN_DEBUG_DEVICES=y
+CONFIG_IRDA=m
+
+#
+# IrDA protocols
+#
+CONFIG_IRLAN=m
+CONFIG_IRDA_ULTRA=y
+
+#
+# IrDA options
+#
+CONFIG_IRDA_CACHE_LAST_LSAP=y
+CONFIG_IRDA_FAST_RR=y
+CONFIG_IRDA_DEBUG=y
+
+#
+# Infrared-port device drivers
+#
+
+#
+# SIR device drivers
+#
+
+#
+# Dongle support
+#
+
+#
+# FIR device drivers
+#
+CONFIG_BT=m
+CONFIG_BT_BREDR=y
+CONFIG_BT_RFCOMM=m
+CONFIG_BT_BNEP=m
+CONFIG_BT_BNEP_MC_FILTER=y
+CONFIG_BT_BNEP_PROTO_FILTER=y
+CONFIG_BT_LE=y
+
+#
+# Bluetooth device drivers
+#
+CONFIG_BT_HCIVHCI=m
+CONFIG_BT_MRVL=m
+# CONFIG_AF_RXRPC is not set
+CONFIG_FIB_RULES=y
+# CONFIG_WIRELESS is not set
+CONFIG_WIMAX=m
+CONFIG_WIMAX_DEBUG_LEVEL=8
+CONFIG_RFKILL=m
+# CONFIG_NET_9P is not set
+CONFIG_CAIF=m
+CONFIG_CAIF_DEBUG=y
+CONFIG_CAIF_NETDEV=m
+# CONFIG_CAIF_USB is not set
+# CONFIG_CEPH_LIB is not set
+# CONFIG_NFC is not set
+
+#
+# Generic Driver Options
+#
+CONFIG_UEVENT_HELPER=y
+CONFIG_UEVENT_HELPER_PATH=""
+# CONFIG_DEVTMPFS is not set
+CONFIG_STANDALONE=y
+CONFIG_PREVENT_FIRMWARE_BUILD=y
+CONFIG_FW_LOADER=y
+CONFIG_FIRMWARE_IN_KERNEL=y
+CONFIG_EXTRA_FIRMWARE=""
+# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
+CONFIG_ALLOW_DEV_COREDUMP=y
+# CONFIG_SYS_HYPERVISOR is not set
+# CONFIG_GENERIC_CPU_DEVICES is not set
+# CONFIG_DMA_SHARED_BUFFER is not set
+CONFIG_CRYPTO=y
+
+#
+# Crypto core or helper
+#
+CONFIG_CRYPTO_ALGAPI=y
+CONFIG_CRYPTO_ALGAPI2=y
+CONFIG_CRYPTO_AEAD=y
+CONFIG_CRYPTO_AEAD2=y
+CONFIG_CRYPTO_BLKCIPHER=y
+CONFIG_CRYPTO_BLKCIPHER2=y
+CONFIG_CRYPTO_HASH=y
+CONFIG_CRYPTO_HASH2=y
+CONFIG_CRYPTO_RNG=m
+CONFIG_CRYPTO_RNG2=y
+CONFIG_CRYPTO_PCOMP=m
+CONFIG_CRYPTO_PCOMP2=y
+CONFIG_CRYPTO_MANAGER=y
+CONFIG_CRYPTO_MANAGER2=y
+# CONFIG_CRYPTO_USER is not set
+CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
+CONFIG_CRYPTO_GF128MUL=m
+CONFIG_CRYPTO_NULL=m
+CONFIG_CRYPTO_WORKQUEUE=y
+CONFIG_CRYPTO_CRYPTD=m
+# CONFIG_CRYPTO_MCRYPTD is not set
+CONFIG_CRYPTO_AUTHENC=y
+CONFIG_CRYPTO_TEST=m
+
+#
+# Authenticated Encryption with Associated Data
+#
+CONFIG_CRYPTO_CCM=m
+CONFIG_CRYPTO_GCM=m
+CONFIG_CRYPTO_SEQIV=m
+
+#
+# Block modes
+#
+CONFIG_CRYPTO_CBC=y
+CONFIG_CRYPTO_CTR=m
+CONFIG_CRYPTO_CTS=m
+CONFIG_CRYPTO_ECB=m
+# CONFIG_CRYPTO_LRW is not set
+CONFIG_CRYPTO_PCBC=m
+# CONFIG_CRYPTO_XTS is not set
+
+#
+# Hash modes
+#
+CONFIG_CRYPTO_CMAC=m
+CONFIG_CRYPTO_HMAC=y
+# CONFIG_CRYPTO_XCBC is not set
+# CONFIG_CRYPTO_VMAC is not set
+
+#
+# Digest
+#
+CONFIG_CRYPTO_CRC32C=y
+# CONFIG_CRYPTO_CRC32 is not set
+CONFIG_CRYPTO_CRCT10DIF=m
+CONFIG_CRYPTO_GHASH=m
+CONFIG_CRYPTO_MD4=m
+CONFIG_CRYPTO_MD5=y
+CONFIG_CRYPTO_MICHAEL_MIC=m
+CONFIG_CRYPTO_RMD128=m
+CONFIG_CRYPTO_RMD160=m
+CONFIG_CRYPTO_RMD256=m
+CONFIG_CRYPTO_RMD320=m
+CONFIG_CRYPTO_SHA1=y
+CONFIG_CRYPTO_SHA256=m
+CONFIG_CRYPTO_SHA512=m
+CONFIG_CRYPTO_TGR192=m
+CONFIG_CRYPTO_WP512=m
+
+#
+# Ciphers
+#
+CONFIG_CRYPTO_AES=y
+CONFIG_CRYPTO_ANUBIS=m
+CONFIG_CRYPTO_ARC4=m
+CONFIG_CRYPTO_BLOWFISH=m
+CONFIG_CRYPTO_BLOWFISH_COMMON=m
+CONFIG_CRYPTO_CAMELLIA=m
+CONFIG_CRYPTO_CAST_COMMON=m
+CONFIG_CRYPTO_CAST5=m
+CONFIG_CRYPTO_CAST6=m
+CONFIG_CRYPTO_DES=y
+CONFIG_CRYPTO_FCRYPT=m
+CONFIG_CRYPTO_KHAZAD=m
+# CONFIG_CRYPTO_SALSA20 is not set
+CONFIG_CRYPTO_SEED=m
+CONFIG_CRYPTO_SERPENT=m
+CONFIG_CRYPTO_TEA=m
+CONFIG_CRYPTO_TWOFISH=m
+CONFIG_CRYPTO_TWOFISH_COMMON=m
+
+#
+# Compression
+#
+CONFIG_CRYPTO_DEFLATE=y
+CONFIG_CRYPTO_ZLIB=m
+CONFIG_CRYPTO_LZO=m
+# CONFIG_CRYPTO_LZ4 is not set
+# CONFIG_CRYPTO_LZ4HC is not set
+
+#
+# Random Number Generation
+#
+CONFIG_CRYPTO_ANSI_CPRNG=m
+# CONFIG_CRYPTO_DRBG_MENU is not set
+# CONFIG_CRYPTO_USER_API_HASH is not set
+# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
+CONFIG_CRYPTO_HW=y
+# CONFIG_BINARY_PRINTF is not set
+
+#
+# Library routines
+#
+CONFIG_BITREVERSE=y
+CONFIG_GENERIC_NET_UTILS=y
+CONFIG_GENERIC_IO=y
+CONFIG_CRC_CCITT=m
+CONFIG_CRC16=m
+CONFIG_CRC_T10DIF=m
+CONFIG_CRC_ITU_T=m
+CONFIG_CRC32=y
+# CONFIG_CRC32_SELFTEST is not set
+CONFIG_CRC32_SLICEBY8=y
+# CONFIG_CRC32_SLICEBY4 is not set
+# CONFIG_CRC32_SARWATE is not set
+# CONFIG_CRC32_BIT is not set
+CONFIG_CRC7=m
+CONFIG_LIBCRC32C=y
+# CONFIG_CRC8 is not set
+# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
+# CONFIG_RANDOM32_SELFTEST is not set
+CONFIG_ZLIB_INFLATE=y
+CONFIG_ZLIB_DEFLATE=y
+CONFIG_LZO_COMPRESS=m
+CONFIG_LZO_DECOMPRESS=m
+# CONFIG_XZ_DEC is not set
+# CONFIG_XZ_DEC_BCJ is not set
+CONFIG_TEXTSEARCH=y
+CONFIG_TEXTSEARCH_KMP=y
+CONFIG_HAS_IOMEM=y
+CONFIG_HAS_IOPORT_MAP=y
+CONFIG_DQL=y
+CONFIG_NLATTR=y
+# CONFIG_AVERAGE is not set
+# CONFIG_CORDIC is not set
+# CONFIG_DDR is not set
+# CONFIG_ARCH_HAS_SG_CHAIN is not set
diff --git a/arch/lib/generate-linker-script.py b/arch/lib/generate-linker-script.py
new file mode 100755
index 0000000..db3d7f8
--- /dev/null
+++ b/arch/lib/generate-linker-script.py
@@ -0,0 +1,50 @@
+#!/usr/bin/env python
+
+import re
+
+def linker_script(reading, writing):
+    delim = re.compile('^==')
+    end_of_ro = re.compile('^ *.gcc_except_table[^:]*:[ ]*ONLY_IF_RW')
+    skipping = True
+    for line in reading.readlines():
+        if delim.search (line) is not None:
+            if skipping:
+                skipping = False
+                continue
+            else:
+                skipping = True
+        if skipping:
+            continue
+        m = end_of_ro.search(line)
+        if m is not None:
+            skipping = False
+            initcall = """
+  /* taken from kernel script*/
+    . = ALIGN (CONSTANT (MAXPAGESIZE));
+    .initcall.init : AT(ADDR(.initcall.init)) {
+     __initcall_start = .;
+     *(.initcallearly.init)
+     *(.initcall0.init)
+     *(.initcall0s.init)
+     *(.initcall1.init)
+     *(.initcall1s.init)
+     *(.initcall2.init)
+     *(.initcall2s.init)
+     *(.initcall3.init)
+     *(.initcall3s.init)
+     *(.initcall4.init)
+     *(.initcall4s.init)
+     *(.initcall5.init)
+     *(.initcall5s.init)
+     *(.initcall6.init)
+     *(.initcall6s.init)
+     *(.initcall7.init)
+     *(.initcall7s.init)
+     __initcall_end = .;
+    }
+"""
+            writing.write (initcall)
+        writing.write(line)
+
+import sys
+linker_script (sys.stdin, sys.stdout)
diff --git a/arch/lib/processor.mk b/arch/lib/processor.mk
new file mode 100644
index 0000000..7331528
--- /dev/null
+++ b/arch/lib/processor.mk
@@ -0,0 +1,7 @@
+PROCESSOR=$(shell uname -m)
+PROCESSOR_x86_64=64
+PROCESSOR_i686=32
+PROCESSOR_i586=32
+PROCESSOR_i386=32
+PROCESSOR_i486=32
+PROCESSOR_SIZE=$(PROCESSOR_$(PROCESSOR))
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
