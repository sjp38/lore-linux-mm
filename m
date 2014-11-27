Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7E63E6B006C
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:29 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id w10so5146432pde.10
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:29 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rr2si12030953pbc.207.2014.11.27.08.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:26 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP004YMGMVPJ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:08 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 01/12] Add kernel address sanitizer infrastructure.
Date: Thu, 27 Nov 2014 19:00:45 +0300
Message-id: <1417104057-20335-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.

KASAN uses compile-time instrumentation for checking every memory access,
therefore GCC >= v4.9.2 required.

This patch only adds infrastructure for kernel address sanitizer. It's not
available for use yet. The idea and some code was borrowed from [1].

Basic idea:
The main idea of KASAN is to use shadow memory to record whether each byte of memory
is safe to access or not, and use compiler's instrumentation to check the shadow memory
on each memory access.

Address sanitizer uses 1/8 of the memory addressable in kernel for shadow memory
and uses direct mapping with a scale and offset to translate a memory
address to its corresponding shadow address.

Here is function to translate address to corresponding shadow address:

     unsigned long kasan_mem_to_shadow(unsigned long addr)
     {
                return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
     }
where KASAN_SHADOW_SCALE_SHIFT = 3.

So for every 8 bytes there is one corresponding byte of shadow memory.
The following encoding used for each shadow byte: 0 means that all 8 bytes of the
corresponding memory region are valid for access; k (1 <= k <= 7) means that
the first k bytes are valid for access, and other (8 - k) bytes are not;
Any negative value indicates that the entire 8-bytes are inaccessible.
Different negative values used to distinguish between different kinds of
inaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

To be able to detect accesses to bad memory we need a special compiler.
Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
before each memory access of size 1, 2, 4, 8 or 16.

These functions check whether memory region is valid to access or not by checking
corresponding shadow memory. If access is not valid an error printed.

Historical background of the address sanitizer from Dmitry Vyukov <dvyukov@google.com>:
	"We've developed the set of tools, AddressSanitizer (Asan),
	ThreadSanitizer and MemorySanitizer, for user space. We actively use
	them for testing inside of Google (continuous testing, fuzzing,
	running prod services). To date the tools have found more than 10'000
	scary bugs in Chromium, Google internal codebase and various
	open-source projects (Firefox, OpenSSL, gcc, clang, ffmpeg, MySQL and
	lots of others): [2] [3] [4].
	The tools are part of both gcc and clang compilers.

	We have not yet done massive testing under the Kernel AddressSanitizer
	(it's kind of chicken and egg problem, you need it to be upstream to
	start applying it extensively). To date it has found about 50 bugs.
	Bugs that we've found in upstream kernel are listed in [5].
	We've also found ~20 bugs in out internal version of the kernel. Also
	people from Samsung and Oracle have found some.

	[...]

	As others noted, the main feature of AddressSanitizer is its
	performance due to inline compiler instrumentation and simple linear
	shadow memory. User-space Asan has ~2x slowdown on computational
	programs and ~2x memory consumption increase. Taking into account that
	kernel usually consumes only small fraction of CPU and memory when
	running real user-space programs, I would expect that kernel Asan will
	have ~10-30% slowdown and similar memory consumption increase (when we
	finish all tuning).

	I agree that Asan can well replace kmemcheck. We have plans to start
	working on Kernel MemorySanitizer that finds uses of unitialized
	memory. Asan+Msan will provide feature-parity with kmemcheck. As
	others noted, Asan will unlikely replace debug slab and pagealloc that
	can be enabled at runtime. Asan uses compiler instrumentation, so even
	if it is disabled, it still incurs visible overheads.

	Asan technology is easily portable to other architectures. Compiler
	instrumentation is fully portable. Runtime has some arch-dependent
	parts like shadow mapping and atomic operation interception. They are
	relatively easy to port."

Comparison with other debugging features:
========================================

KMEMCHECK:
	- KASan can do almost everything that kmemcheck can. KASan uses compile-time
	  instrumentation, which makes it significantly faster than kmemcheck.
	  The only advantage of kmemcheck over KASan is detection of uninitialized
	  memory reads.

	  Some brief performance testing showed that kasan could be x500-x600 times
	  faster than kmemcheck:

$ netperf -l 30
		MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
		Recv   Send    Send
		Socket Socket  Message  Elapsed
		Size   Size    Size     Time     Throughput
		bytes  bytes   bytes    secs.    10^6bits/sec

no debug:	87380  16384  16384    30.00    41624.72

kasan inline:	87380  16384  16384    30.00    12870.54

kasan outline:	87380  16384  16384    30.00    10586.39

kmemcheck: 	87380  16384  16384    30.03      20.23

	- Also kmemcheck couldn't work on several CPUs. It always sets number of CPUs to 1.
	  KASan doesn't have such limitation.

DEBUG_PAGEALLOC:
	- KASan is slower than DEBUG_PAGEALLOC, but KASan works on sub-page
	  granularity level, so it able to find more bugs.

SLUB_DEBUG (poisoning, redzones):
	- SLUB_DEBUG has lower overhead than KASan.

	- SLUB_DEBUG in most cases are not able to detect bad reads,
	  KASan able to detect both reads and writes.

	- In some cases (e.g. redzone overwritten) SLUB_DEBUG detect
	  bugs only on allocation/freeing of object. KASan catch
	  bugs right before it will happen, so we always know exact
	  place of first bad read/write.

[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
[2] https://code.google.com/p/address-sanitizer/wiki/FoundBugs
[3] https://code.google.com/p/thread-sanitizer/wiki/FoundBugs
[4] https://code.google.com/p/memory-sanitizer/wiki/FoundBugs
[5] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel#Trophies

Based on work by Andrey Konovalov <adech.fo@gmail.com>

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Documentation/kasan.txt               | 169 +++++++++++++++
 Makefile                              |  23 ++-
 drivers/firmware/efi/libstub/Makefile |   1 +
 include/linux/kasan.h                 |  42 ++++
 include/linux/sched.h                 |   3 +
 lib/Kconfig.debug                     |   2 +
 lib/Kconfig.kasan                     |  43 ++++
 mm/Makefile                           |   1 +
 mm/kasan/Makefile                     |   8 +
 mm/kasan/kasan.c                      | 374 ++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h                      |  49 +++++
 mm/kasan/report.c                     | 205 +++++++++++++++++++
 scripts/Makefile.lib                  |  10 +
 13 files changed, 928 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/kasan.txt
 create mode 100644 include/linux/kasan.h
 create mode 100644 lib/Kconfig.kasan
 create mode 100644 mm/kasan/Makefile
 create mode 100644 mm/kasan/kasan.c
 create mode 100644 mm/kasan/kasan.h
 create mode 100644 mm/kasan/report.c

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
new file mode 100644
index 0000000..a3a9009
--- /dev/null
+++ b/Documentation/kasan.txt
@@ -0,0 +1,169 @@
+Kernel address sanitizer
+================
+
+0. Overview
+===========
+
+Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
+a fast and comprehensive solution for finding use-after-free and out-of-bounds
+bugs.
+
+KASan uses compile-time instrumentation for checking every memory access,
+therefore you will need a certain version of GCC >= 4.9.2
+
+Currently KASan is supported only for x86_64 architecture and requires that the
+kernel be built with the SLUB allocator.
+
+1. Usage
+=========
+
+To enable KASAN configure kernel with:
+
+	  CONFIG_KASAN = y
+
+and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline/inline
+is compiler instrumentation types. The former produces smaller binary the
+latter is 1.1 - 2 times faster. Inline instrumentation requires GCC 5.0 or
+latter.
+
+Currently KASAN works only with the SLUB memory allocator.
+For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
+at least 'slub_debug=U' in the boot cmdline.
+
+To disable instrumentation for specific files or directories, add a line
+similar to the following to the respective kernel Makefile:
+
+        For a single file (e.g. main.o):
+                KASAN_SANITIZE_main.o := n
+
+        For all files in one directory:
+                KASAN_SANITIZE := n
+
+1.1 Error reports
+==========
+
+A typical out of bounds access report looks like this:
+
+==================================================================
+BUG: AddressSanitizer: out of bounds access in kmalloc_oob_right+0x65/0x75 [test_kasan] at addr ffff8800693bc5d3
+Write of size 1 by task modprobe/1689
+=============================================================================
+BUG kmalloc-128 (Not tainted): kasan error
+-----------------------------------------------------------------------------
+
+Disabling lock debugging due to kernel taint
+INFO: Allocated in kmalloc_oob_right+0x3d/0x75 [test_kasan] age=0 cpu=0 pid=1689
+ __slab_alloc+0x4b4/0x4f0
+ kmem_cache_alloc_trace+0x10b/0x190
+ kmalloc_oob_right+0x3d/0x75 [test_kasan]
+ init_module+0x9/0x47 [test_kasan]
+ do_one_initcall+0x99/0x200
+ load_module+0x2cb3/0x3b20
+ SyS_finit_module+0x76/0x80
+ system_call_fastpath+0x12/0x17
+INFO: Slab 0xffffea0001a4ef00 objects=17 used=7 fp=0xffff8800693bd728 flags=0x100000000004080
+INFO: Object 0xffff8800693bc558 @offset=1368 fp=0xffff8800693bc720
+
+Bytes b4 ffff8800693bc548: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
+Object ffff8800693bc558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc5a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc5b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
+Object ffff8800693bc5c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
+Redzone ffff8800693bc5d8: cc cc cc cc cc cc cc cc                          ........
+Padding ffff8800693bc718: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
+CPU: 0 PID: 1689 Comm: modprobe Tainted: G    B          3.18.0-rc1-mm1+ #98
+Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
+ ffff8800693bc000 0000000000000000 ffff8800693bc558 ffff88006923bb78
+ ffffffff81cc68ae 00000000000000f3 ffff88006d407600 ffff88006923bba8
+ ffffffff811fd848 ffff88006d407600 ffffea0001a4ef00 ffff8800693bc558
+Call Trace:
+ [<ffffffff81cc68ae>] dump_stack+0x46/0x58
+ [<ffffffff811fd848>] print_trailer+0xf8/0x160
+ [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
+ [<ffffffff811ff0f5>] object_err+0x35/0x40
+ [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
+ [<ffffffff8120b9fa>] kasan_report_error+0x38a/0x3f0
+ [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
+ [<ffffffff8120b344>] ? kasan_unpoison_shadow+0x14/0x40
+ [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
+ [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
+ [<ffffffff8120a995>] __asan_store1+0x75/0xb0
+ [<ffffffffa0002601>] ? kmem_cache_oob+0x1d/0xc3 [test_kasan]
+ [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
+ [<ffffffffa0002065>] kmalloc_oob_right+0x65/0x75 [test_kasan]
+ [<ffffffffa00026b0>] init_module+0x9/0x47 [test_kasan]
+ [<ffffffff810002d9>] do_one_initcall+0x99/0x200
+ [<ffffffff811e4e5c>] ? __vunmap+0xec/0x160
+ [<ffffffff81114f63>] load_module+0x2cb3/0x3b20
+ [<ffffffff8110fd70>] ? m_show+0x240/0x240
+ [<ffffffff81115f06>] SyS_finit_module+0x76/0x80
+ [<ffffffff81cd3129>] system_call_fastpath+0x12/0x17
+Memory state around the buggy address:
+ ffff8800693bc300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ffff8800693bc380: fc fc 00 00 00 00 00 00 00 00 00 00 00 00 00 fc
+ ffff8800693bc400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ffff8800693bc480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ffff8800693bc500: fc fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00
+>ffff8800693bc580: 00 00 00 00 00 00 00 00 00 00 03 fc fc fc fc fc
+                                                 ^
+ ffff8800693bc600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ffff8800693bc680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
+ ffff8800693bc700: fc fc fc fc fb fb fb fb fb fb fb fb fb fb fb fb
+ ffff8800693bc780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
+ ffff8800693bc800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
+==================================================================
+
+First sections describe slub object where bad access happened.
+See 'SLUB Debug output' section in Documentation/vm/slub.txt for details.
+
+In the last section the report shows memory state around the accessed address.
+Reading this part requires some more understanding of how KASAN works.
+
+Each 8 bytes of memory are encoded in one shadow byte as accessible,
+partially accessible, freed or they can be part of a redzone.
+We use the following encoding for each shadow byte: 0 means that all 8 bytes
+of the corresponding memory region are accessible; number N (1 <= N <= 7) means
+that the first N bytes are accessible, and other (8 - N) bytes are not;
+any negative value indicates that the entire 8-byte word is inaccessible.
+We use different negative values to distinguish between different kinds of
+inaccessible memory like redzones or freed memory (see mm/kasan/kasan.h).
+
+In the report above the arrows point to the shadow byte 03, which means that
+the accessed address is partially accessible.
+
+
+2. Implementation details
+========================
+
+From a high level, our approach to memory error detection is similar to that
+of kmemcheck: use shadow memory to record whether each byte of memory is safe
+to access, and use compile-time instrumentation to check shadow memory on each
+memory access.
+
+AddressSanitizer dedicates 1/8 of kernel memory to its shadow memory
+(e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a scale and
+offset to translate a memory address to its corresponding shadow address.
+
+Here is the function witch translate an address to its corresponding shadow
+address:
+
+unsigned long kasan_mem_to_shadow(unsigned long addr)
+{
+	return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
+}
+
+where KASAN_SHADOW_SCALE_SHIFT = 3.
+
+Compile-time instrumentation used for checking memory accesses. Compiler inserts
+function calls (__asan_load*(addr), __asan_store*(addr)) before each memory
+access of size 1, 2, 4, 8 or 16. These functions check whether memory access is
+valid or not by checking corresponding shadow memory.
+
+GCC 5.0 has possibility to perform inline instrumentation. Instead of making
+function calls GCC directly inserts the code to check the shadow memory.
+This option significantly enlarges kernel but it gives x1.1-x2 performance
+boost over outline instrumented kernel.
diff --git a/Makefile b/Makefile
index 8869dc8..b382b62 100644
--- a/Makefile
+++ b/Makefile
@@ -382,7 +382,7 @@ LDFLAGS_MODULE  =
 CFLAGS_KERNEL	=
 AFLAGS_KERNEL	=
 CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage
-
+CFLAGS_KASAN	= $(call cc-option, -fsanitize=kernel-address)
 
 # Use USERINCLUDE when you must reference the UAPI directories only.
 USERINCLUDE    := \
@@ -427,7 +427,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
-export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV
+export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KASAN
 export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
 export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
 export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
@@ -758,6 +758,25 @@ ifdef CONFIG_DEBUG_SECTION_MISMATCH
 KBUILD_CFLAGS += $(call cc-option, -fno-inline-functions-called-once)
 endif
 
+ifdef CONFIG_KASAN
+ifdef CONFIG_KASAN_INLINE
+  kasan_inline := $(call cc-option, $(CFLAGS_KASAN) \
+			-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
+			--param asan-instrumentation-with-call-threshold=10000)
+  ifeq ($(kasan_inline),)
+    $(warning Cannot use CONFIG_KASAN_INLINE: \
+	      inline instrumentation is not supported by compiler. Trying CONFIG_KASAN_OUTLINE.)
+  else
+    CFLAGS_KASAN := $(kasan_inline)
+  endif
+
+endif
+  ifeq ($(CFLAGS_KASAN),)
+    $(warning Cannot use CONFIG_KASAN: \
+	      -fsanitize=kernel-address is not supported by compiler)
+  endif
+endif
+
 # arch Makefile may override CC so keep this after arch Makefile is included
 NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
 CHECKFLAGS     += $(NOSTDINC_FLAGS)
diff --git a/drivers/firmware/efi/libstub/Makefile b/drivers/firmware/efi/libstub/Makefile
index b14bc2b..c5533c7 100644
--- a/drivers/firmware/efi/libstub/Makefile
+++ b/drivers/firmware/efi/libstub/Makefile
@@ -19,6 +19,7 @@ KBUILD_CFLAGS			:= $(cflags-y) \
 				   $(call cc-option,-fno-stack-protector)
 
 GCOV_PROFILE			:= n
+KASAN_SANITIZE			:= n
 
 lib-y				:= efi-stub-helper.o
 lib-$(CONFIG_EFI_ARMSTUB)	+= arm-stub.o fdt.o
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
new file mode 100644
index 0000000..01c99fe
--- /dev/null
+++ b/include/linux/kasan.h
@@ -0,0 +1,42 @@
+#ifndef _LINUX_KASAN_H
+#define _LINUX_KASAN_H
+
+#include <linux/types.h>
+
+struct kmem_cache;
+struct page;
+
+#ifdef CONFIG_KASAN
+#include <asm/kasan.h>
+#include <linux/sched.h>
+
+#define KASAN_SHADOW_SCALE_SHIFT 3
+#define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
+
+static inline unsigned long kasan_mem_to_shadow(unsigned long addr)
+{
+	return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
+}
+
+static inline void kasan_enable_local(void)
+{
+	current->kasan_depth++;
+}
+
+static inline void kasan_disable_local(void)
+{
+	current->kasan_depth--;
+}
+
+void kasan_unpoison_shadow(const void *address, size_t size);
+
+#else /* CONFIG_KASAN */
+
+static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
+
+static inline void kasan_enable_local(void) {}
+static inline void kasan_disable_local(void) {}
+
+#endif /* CONFIG_KASAN */
+
+#endif /* LINUX_KASAN_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef..26e1b47 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1662,6 +1662,9 @@ struct task_struct {
 	unsigned long timer_slack_ns;
 	unsigned long default_timer_slack_ns;
 
+#ifdef CONFIG_KASAN
+	unsigned int kasan_depth;
+#endif
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 	/* Index of current stored address in ret_stack */
 	int curr_ret_stack;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 1c23b54..9843de2 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -670,6 +670,8 @@ config DEBUG_STACKOVERFLOW
 
 source "lib/Kconfig.kmemcheck"
 
+source "lib/Kconfig.kasan"
+
 endmenu # "Memory Debugging"
 
 config DEBUG_SHIRQ
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
new file mode 100644
index 0000000..10341df
--- /dev/null
+++ b/lib/Kconfig.kasan
@@ -0,0 +1,43 @@
+config HAVE_ARCH_KASAN
+	bool
+
+if HAVE_ARCH_KASAN
+
+config KASAN
+	bool "AddressSanitizer: runtime memory debugger"
+	help
+	  Enables address sanitizer - runtime memory debugger,
+	  designed to find out-of-bounds accesses and use-after-free bugs.
+	  This is strictly debugging feature. It consumes about 1/8
+	  of available memory and brings about ~x3 performance slowdown.
+	  For better error detection enable CONFIG_STACKTRACE,
+	  and add slub_debug=U to boot cmdline.
+
+config KASAN_SHADOW_OFFSET
+	hex
+
+choice
+	prompt "Instrumentation type"
+	depends on KASAN
+	default KASAN_OUTLINE
+
+config KASAN_OUTLINE
+	bool "Outline instrumentation"
+	help
+	  Before every memory access compiler insert function call
+	  __asan_load*/__asan_store*. These functions performs check
+	  of shadow memory. This is slower than inline instrumentation,
+	  however it doesn't bloat size of kernel's .text section so
+	  much as inline does.
+
+config KASAN_INLINE
+	bool "Inline instrumentation"
+	help
+	  Compiler directly inserts code checking shadow memory before
+	  memory accesses. This is faster than outline (in some workloads
+	  it gives about x2 boost over outline instrumentation), but
+	  make kernel's .text size much bigger.
+
+endchoice
+
+endif
diff --git a/mm/Makefile b/mm/Makefile
index 3548460..930b52d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
+obj-$(CONFIG_KASAN)	+= kasan/
 obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
new file mode 100644
index 0000000..28486bb
--- /dev/null
+++ b/mm/kasan/Makefile
@@ -0,0 +1,8 @@
+KASAN_SANITIZE := n
+
+CFLAGS_REMOVE_kasan.o = -pg
+# Function splitter causes unnecessary splits in __asan_load1/__asan_store1
+# see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
+CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack)
+
+obj-y := kasan.o report.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
new file mode 100644
index 0000000..f77be01
--- /dev/null
+++ b/mm/kasan/kasan.c
@@ -0,0 +1,374 @@
+/*
+ * This file contains shadow memory manipulation code.
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
+ *
+ * Some of code borrowed from https://github.com/xairy/linux by
+ *        Andrey Konovalov <adech.fo@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/export.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/memblock.h>
+#include <linux/mm.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kasan.h>
+
+#include "kasan.h"
+
+/*
+ * Poisons the shadow memory for 'size' bytes starting from 'addr'.
+ * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
+ */
+static void kasan_poison_shadow(const void *address, size_t size, u8 value)
+{
+	unsigned long shadow_start, shadow_end;
+	unsigned long addr = (unsigned long)address;
+
+	shadow_start = kasan_mem_to_shadow(addr);
+	shadow_end = kasan_mem_to_shadow(addr + size);
+
+	memset((void *)shadow_start, value, shadow_end - shadow_start);
+}
+
+void kasan_unpoison_shadow(const void *address, size_t size)
+{
+	kasan_poison_shadow(address, size, 0);
+
+	if (size & KASAN_SHADOW_MASK) {
+		u8 *shadow = (u8 *)kasan_mem_to_shadow((unsigned long)address
+						+ size);
+		*shadow = size & KASAN_SHADOW_MASK;
+	}
+}
+
+static __always_inline bool memory_is_poisoned_1(unsigned long addr)
+{
+	s8 shadow_value = *(s8 *)kasan_mem_to_shadow(addr);
+
+	if (unlikely(shadow_value)) {
+		s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
+		return unlikely(last_accessible_byte >= shadow_value);
+	}
+
+	return false;
+}
+
+static __always_inline bool memory_is_poisoned_2(unsigned long addr)
+{
+	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow(addr);
+
+	if (unlikely(*shadow_addr)) {
+		if (memory_is_poisoned_1(addr + 1))
+			return true;
+
+		if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
+			return false;
+
+		return unlikely(*(u8 *)shadow_addr);
+	}
+
+	return false;
+}
+
+static __always_inline bool memory_is_poisoned_4(unsigned long addr)
+{
+	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow(addr);
+
+	if (unlikely(*shadow_addr)) {
+		if (memory_is_poisoned_1(addr + 3))
+			return true;
+
+		if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
+			return false;
+
+		return unlikely(*(u8 *)shadow_addr);
+	}
+
+	return false;
+}
+
+static __always_inline bool memory_is_poisoned_8(unsigned long addr)
+{
+	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow(addr);
+
+	if (unlikely(*shadow_addr)) {
+		if (memory_is_poisoned_1(addr + 7))
+			return true;
+
+		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
+			return false;
+
+		return unlikely(*(u8 *)shadow_addr);
+	}
+
+	return false;
+}
+
+static __always_inline bool memory_is_poisoned_16(unsigned long addr)
+{
+	u32 *shadow_addr = (u32 *)kasan_mem_to_shadow(addr);
+
+	if (unlikely(*shadow_addr)) {
+		u16 shadow_first_bytes = *(u16 *)shadow_addr;
+		s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
+
+		if (unlikely(shadow_first_bytes))
+			return true;
+
+		if (likely(!last_byte))
+			return false;
+
+		return memory_is_poisoned_1(addr + 15);
+	}
+
+	return false;
+}
+
+static __always_inline unsigned long bytes_is_zero(unsigned long start,
+					size_t size)
+{
+	while (size) {
+		if (unlikely(*(u8 *)start))
+			return start;
+		start++;
+		size--;
+	}
+
+	return 0;
+}
+
+static __always_inline unsigned long memory_is_zero(unsigned long start,
+						unsigned long end)
+{
+	unsigned int prefix = start % 8;
+	unsigned int words;
+	unsigned long ret;
+
+	if (end - start <= 16)
+		return bytes_is_zero(start, end - start);
+
+	if (prefix) {
+		prefix = 8 - prefix;
+		ret = bytes_is_zero(start, prefix);
+		if (unlikely(ret))
+			return ret;
+		start += prefix;
+	}
+
+	words = (end - start) / 8;
+	while (words) {
+		if (unlikely(*(u64 *)start))
+			return bytes_is_zero(start, 8);
+		start += 8;
+		words--;
+	}
+
+	return bytes_is_zero(start, (end - start) % 8);
+}
+
+static __always_inline bool memory_is_poisoned_n(unsigned long addr,
+						size_t size)
+{
+	unsigned long ret;
+
+	ret = memory_is_zero(kasan_mem_to_shadow(addr),
+			kasan_mem_to_shadow(addr + size - 1) + 1);
+
+	if (unlikely(ret)) {
+		unsigned long last_byte = addr + size - 1;
+		s8 *last_shadow = (s8 *)kasan_mem_to_shadow(last_byte);
+
+		if (unlikely(ret != (unsigned long)last_shadow ||
+			((last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
+			return true;
+	}
+	return false;
+}
+
+static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
+{
+	if (__builtin_constant_p(size)) {
+		switch (size) {
+		case 1:
+			return memory_is_poisoned_1(addr);
+		case 2:
+			return memory_is_poisoned_2(addr);
+		case 4:
+			return memory_is_poisoned_4(addr);
+		case 8:
+			return memory_is_poisoned_8(addr);
+		case 16:
+			return memory_is_poisoned_16(addr);
+		default:
+			BUILD_BUG();
+		}
+	}
+
+	return memory_is_poisoned_n(addr, size);
+}
+
+
+static __always_inline void check_memory_region(unsigned long addr,
+						size_t size, bool write)
+{
+	struct access_info info;
+
+	if (unlikely(size == 0))
+		return;
+
+	if (unlikely(addr < kasan_shadow_to_mem(KASAN_SHADOW_START))) {
+		info.access_addr = addr;
+		info.access_size = size;
+		info.is_write = write;
+		info.ip = _RET_IP_;
+		kasan_report_user_access(&info);
+		return;
+	}
+
+	if (likely(!memory_is_poisoned(addr, size)))
+		return;
+
+	kasan_report(addr, size, write);
+}
+
+void __asan_load1(unsigned long addr)
+{
+	check_memory_region(addr, 1, false);
+}
+EXPORT_SYMBOL(__asan_load1);
+
+void __asan_load2(unsigned long addr)
+{
+	check_memory_region(addr, 2, false);
+}
+EXPORT_SYMBOL(__asan_load2);
+
+void __asan_load4(unsigned long addr)
+{
+	check_memory_region(addr, 4, false);
+}
+EXPORT_SYMBOL(__asan_load4);
+
+void __asan_load8(unsigned long addr)
+{
+	check_memory_region(addr, 8, false);
+}
+EXPORT_SYMBOL(__asan_load8);
+
+void __asan_load16(unsigned long addr)
+{
+	check_memory_region(addr, 16, false);
+}
+EXPORT_SYMBOL(__asan_load16);
+
+void __asan_loadN(unsigned long addr, size_t size)
+{
+	check_memory_region(addr, size, false);
+}
+EXPORT_SYMBOL(__asan_loadN);
+
+void __asan_store1(unsigned long addr)
+{
+	check_memory_region(addr, 1, true);
+}
+EXPORT_SYMBOL(__asan_store1);
+
+void __asan_store2(unsigned long addr)
+{
+	check_memory_region(addr, 2, true);
+}
+EXPORT_SYMBOL(__asan_store2);
+
+void __asan_store4(unsigned long addr)
+{
+	check_memory_region(addr, 4, true);
+}
+EXPORT_SYMBOL(__asan_store4);
+
+void __asan_store8(unsigned long addr)
+{
+	check_memory_region(addr, 8, true);
+}
+EXPORT_SYMBOL(__asan_store8);
+
+void __asan_store16(unsigned long addr)
+{
+	check_memory_region(addr, 16, true);
+}
+EXPORT_SYMBOL(__asan_store16);
+
+void __asan_storeN(unsigned long addr, size_t size)
+{
+	check_memory_region(addr, size, true);
+}
+EXPORT_SYMBOL(__asan_storeN);
+
+/* to shut up compiler complaints */
+void __asan_handle_no_return(void) {}
+EXPORT_SYMBOL(__asan_handle_no_return);
+
+
+/* GCC 5.0 has different function names by default */
+__attribute__((alias("__asan_load1")))
+void __asan_load1_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_load1_noabort);
+
+__attribute__((alias("__asan_load2")))
+void __asan_load2_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_load2_noabort);
+
+__attribute__((alias("__asan_load4")))
+void __asan_load4_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_load4_noabort);
+
+__attribute__((alias("__asan_load8")))
+void __asan_load8_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_load8_noabort);
+
+__attribute__((alias("__asan_load16")))
+void __asan_load16_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_load16_noabort);
+
+__attribute__((alias("__asan_loadN")))
+void __asan_loadN_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_loadN_noabort);
+
+__attribute__((alias("__asan_store1")))
+void __asan_store1_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_store1_noabort);
+
+__attribute__((alias("__asan_store2")))
+void __asan_store2_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_store2_noabort);
+
+__attribute__((alias("__asan_store4")))
+void __asan_store4_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_store4_noabort);
+
+__attribute__((alias("__asan_store8")))
+void __asan_store8_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_store8_noabort);
+
+__attribute__((alias("__asan_store16")))
+void __asan_store16_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_store16_noabort);
+
+__attribute__((alias("__asan_storeN")))
+void __asan_storeN_noabort(unsigned long);
+EXPORT_SYMBOL(__asan_storeN_noabort);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
new file mode 100644
index 0000000..6da1d78
--- /dev/null
+++ b/mm/kasan/kasan.h
@@ -0,0 +1,49 @@
+#ifndef __MM_KASAN_KASAN_H
+#define __MM_KASAN_KASAN_H
+
+#include <linux/kasan.h>
+
+#define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
+#define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
+
+#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
+
+struct access_info {
+	unsigned long access_addr;
+	unsigned long first_bad_addr;
+	size_t access_size;
+	bool is_write;
+	unsigned long ip;
+};
+
+void kasan_report_error(struct access_info *info);
+void kasan_report_user_access(struct access_info *info);
+
+static inline unsigned long kasan_shadow_to_mem(unsigned long shadow_addr)
+{
+	return (shadow_addr - KASAN_SHADOW_OFFSET) << KASAN_SHADOW_SCALE_SHIFT;
+}
+
+static inline bool kasan_enabled(void)
+{
+	return !current->kasan_depth;
+}
+
+static __always_inline void kasan_report(unsigned long addr,
+					size_t size,
+					bool is_write)
+{
+	struct access_info info;
+
+	if (likely(!kasan_enabled()))
+		return;
+
+	info.access_addr = addr;
+	info.access_size = size;
+	info.is_write = is_write;
+	info.ip = _RET_IP_;
+	kasan_report_error(&info);
+}
+
+
+#endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
new file mode 100644
index 0000000..56a2089
--- /dev/null
+++ b/mm/kasan/report.c
@@ -0,0 +1,205 @@
+/*
+ * This file contains error reporting code.
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
+ *
+ * Some of code borrowed from https://github.com/xairy/linux by
+ *        Andrey Konovalov <adech.fo@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kasan.h>
+
+#include "kasan.h"
+
+/* Shadow layout customization. */
+#define SHADOW_BYTES_PER_BLOCK 1
+#define SHADOW_BLOCKS_PER_ROW 16
+#define SHADOW_BYTES_PER_ROW (SHADOW_BLOCKS_PER_ROW * SHADOW_BYTES_PER_BLOCK)
+#define SHADOW_ROWS_AROUND_ADDR 5
+
+static unsigned long find_first_bad_addr(unsigned long addr, size_t size)
+{
+	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
+	unsigned long first_bad_addr = addr;
+
+	while (!shadow_val && first_bad_addr < addr + size) {
+		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
+		shadow_val = *(u8 *)kasan_mem_to_shadow(first_bad_addr);
+	}
+	return first_bad_addr;
+}
+
+static void print_error_description(struct access_info *info)
+{
+	const char *bug_type = "unknown crash";
+	u8 shadow_val;
+
+	info->first_bad_addr = find_first_bad_addr(info->access_addr,
+						info->access_size);
+
+	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
+
+	switch (shadow_val) {
+	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		bug_type = "out of bounds access";
+		break;
+	case KASAN_SHADOW_GAP:
+		bug_type = "wild memory access";
+		break;
+	}
+
+	pr_err("BUG: AddressSanitizer: %s in %pS at addr %p\n",
+		bug_type, (void *)info->ip,
+		(void *)info->access_addr);
+	pr_err("%s of size %zu by task %s/%d\n",
+		info->is_write ? "Write" : "Read",
+		info->access_size, current->comm, task_pid_nr(current));
+}
+
+static void print_address_description(struct access_info *info)
+{
+	struct page *page;
+	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
+
+	page = virt_to_head_page((void *)info->access_addr);
+
+	switch (shadow_val) {
+	case KASAN_SHADOW_GAP:
+		pr_err("No metainfo is available for this access.\n");
+		dump_stack();
+		break;
+	default:
+		WARN_ON(1);
+	}
+}
+
+static bool row_is_guilty(unsigned long row, unsigned long guilty)
+{
+	return (row <= guilty) && (guilty < row + SHADOW_BYTES_PER_ROW);
+}
+
+static int shadow_pointer_offset(unsigned long row, unsigned long shadow)
+{
+	/* The length of ">ff00ff00ff00ff00: " is
+	 *    3 + (BITS_PER_LONG/8)*2 chars.
+	 */
+	return 3 + (BITS_PER_LONG/8)*2 + (shadow - row)*2 +
+		(shadow - row) / SHADOW_BYTES_PER_BLOCK + 1;
+}
+
+static void print_shadow_for_address(unsigned long addr)
+{
+	int i;
+	unsigned long shadow = kasan_mem_to_shadow(addr);
+	unsigned long aligned_shadow = round_down(shadow, SHADOW_BYTES_PER_ROW)
+		- SHADOW_ROWS_AROUND_ADDR * SHADOW_BYTES_PER_ROW;
+
+	pr_err("Memory state around the buggy address:\n");
+
+	for (i = -SHADOW_ROWS_AROUND_ADDR; i <= SHADOW_ROWS_AROUND_ADDR; i++) {
+		unsigned long kaddr = kasan_shadow_to_mem(aligned_shadow);
+		char buffer[4 + (BITS_PER_LONG/8)*2];
+
+		snprintf(buffer, sizeof(buffer),
+			(i == 0) ? ">%lx: " : " %lx: ", kaddr);
+
+		kasan_disable_local();
+		print_hex_dump(KERN_ERR, buffer,
+			DUMP_PREFIX_NONE, SHADOW_BYTES_PER_ROW, 1,
+			(void *)aligned_shadow, SHADOW_BYTES_PER_ROW, 0);
+		kasan_enable_local();
+
+		if (row_is_guilty(aligned_shadow, shadow))
+			pr_err("%*c\n",
+				shadow_pointer_offset(aligned_shadow, shadow),
+				'^');
+
+		aligned_shadow += SHADOW_BYTES_PER_ROW;
+	}
+}
+
+static DEFINE_SPINLOCK(report_lock);
+
+void kasan_report_error(struct access_info *info)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&report_lock, flags);
+	pr_err("================================="
+		"=================================\n");
+	print_error_description(info);
+	print_address_description(info);
+	print_shadow_for_address(info->first_bad_addr);
+	pr_err("================================="
+		"=================================\n");
+	spin_unlock_irqrestore(&report_lock, flags);
+}
+
+void kasan_report_user_access(struct access_info *info)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&report_lock, flags);
+	pr_err("================================="
+		"=================================\n");
+	pr_err("BUG: AddressSanitizer: user-memory-access on address %lx\n",
+		info->access_addr);
+	pr_err("%s of size %zu by thread T%d:\n",
+		info->is_write ? "Write" : "Read",
+		info->access_size, current->pid);
+	dump_stack();
+	pr_err("================================="
+		"=================================\n");
+	spin_unlock_irqrestore(&report_lock, flags);
+}
+
+#define DEFINE_ASAN_REPORT_LOAD(size)                     \
+void __asan_report_load##size##_noabort(unsigned long addr) \
+{                                                         \
+	kasan_report(addr, size, false);                  \
+}                                                         \
+EXPORT_SYMBOL(__asan_report_load##size##_noabort)
+
+#define DEFINE_ASAN_REPORT_STORE(size)                     \
+void __asan_report_store##size##_noabort(unsigned long addr) \
+{                                                          \
+	kasan_report(addr, size, true);                    \
+}                                                          \
+EXPORT_SYMBOL(__asan_report_store##size##_noabort)
+
+DEFINE_ASAN_REPORT_LOAD(1);
+DEFINE_ASAN_REPORT_LOAD(2);
+DEFINE_ASAN_REPORT_LOAD(4);
+DEFINE_ASAN_REPORT_LOAD(8);
+DEFINE_ASAN_REPORT_LOAD(16);
+DEFINE_ASAN_REPORT_STORE(1);
+DEFINE_ASAN_REPORT_STORE(2);
+DEFINE_ASAN_REPORT_STORE(4);
+DEFINE_ASAN_REPORT_STORE(8);
+DEFINE_ASAN_REPORT_STORE(16);
+
+void __asan_report_load_n_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, false);
+}
+EXPORT_SYMBOL(__asan_report_load_n_noabort);
+
+void __asan_report_store_n_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, true);
+}
+EXPORT_SYMBOL(__asan_report_store_n_noabort);
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 5117552..a5845a2 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -119,6 +119,16 @@ _c_flags += $(if $(patsubst n%,, \
 		$(CFLAGS_GCOV))
 endif
 
+#
+# Enable address sanitizer flags for kernel except some files or directories
+# we don't want to check (depends on variables KASAN_SANITIZE_obj.o, KASAN_SANITIZE)
+#
+ifeq ($(CONFIG_KASAN),y)
+_c_flags += $(if $(patsubst n%,, \
+		$(KASAN_SANITIZE_$(basetarget).o)$(KASAN_SANITIZE)$(CONFIG_KASAN)), \
+		$(CFLAGS_KASAN))
+endif
+
 # If building the kernel in a separate objtree expand all occurrences
 # of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
