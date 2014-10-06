Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B58056B0071
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 12:01:18 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so5406830pad.8
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 09:01:18 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id gz10si13564438pbd.135.2014.10.06.09.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 06 Oct 2014 09:01:16 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ND100FOA5YQYT80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Oct 2014 17:04:02 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 01/13] Add kernel address sanitizer infrastructure.
Date: Mon, 06 Oct 2014 19:53:55 +0400
Message-id: <1412610847-27671-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1412610847-27671-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1412610847-27671-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, Jiri Kosina <jkosina@suse.cz>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.

KASAN uses compile-time instrumentation for checking every memory access,
therefore fresh GCC >= v5.0.0 required.

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

[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel

Based on work by Andrey Konovalov <adech.fo@gmail.com>

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Documentation/kasan.txt | 174 +++++++++++++++++++++++++
 Makefile                |  11 +-
 include/linux/kasan.h   |  42 ++++++
 include/linux/sched.h   |   3 +
 lib/Kconfig.debug       |   2 +
 lib/Kconfig.kasan       |  15 +++
 mm/Makefile             |   1 +
 mm/kasan/Makefile       |   3 +
 mm/kasan/kasan.c        | 336 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h        |  27 ++++
 mm/kasan/report.c       | 169 ++++++++++++++++++++++++
 scripts/Makefile.lib    |  10 ++
 12 files changed, 791 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/kasan.txt
 create mode 100644 include/linux/kasan.h
 create mode 100644 lib/Kconfig.kasan
 create mode 100644 mm/kasan/Makefile
 create mode 100644 mm/kasan/kasan.c
 create mode 100644 mm/kasan/kasan.h
 create mode 100644 mm/kasan/report.c

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
new file mode 100644
index 0000000..577de3a
--- /dev/null
+++ b/Documentation/kasan.txt
@@ -0,0 +1,174 @@
+Kernel address sanitizer
+================
+
+0. Overview
+===========
+
+Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
+a fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
+
+KASAN uses compile-time instrumentation for checking every memory access, therefore you
+will need a special compiler: GCC >= 5.0.0.
+
+Currently KASAN is supported only for x86_64 architecture and requires kernel
+to be built with SLUB allocator.
+
+1. Usage
+=========
+
+KASAN requires the kernel to be built with a special compiler (GCC >= 5.0.0).
+
+To enable KASAN configure kernel with:
+
+	  CONFIG_KASAN = y
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
+Only files which are linked to the main kernel image or are compiled as
+kernel modules are supported by this mechanism.
+
+
+1.1 Error reports
+==========
+
+A typical out of bounds access report looks like this:
+
+==================================================================
+BUG: AddressSanitizer: buffer overflow in kasan_kmalloc_oob_right+0x6a/0x7a at addr c6006f1b
+=============================================================================
+BUG kmalloc-128 (Not tainted): kasan error
+-----------------------------------------------------------------------------
+
+Disabling lock debugging due to kernel taint
+INFO: Allocated in kasan_kmalloc_oob_right+0x2c/0x7a age=5 cpu=0 pid=1
+	__slab_alloc.constprop.72+0x64f/0x680
+	kmem_cache_alloc+0xa8/0xe0
+	kasan_kmalloc_oob_rigth+0x2c/0x7a
+	kasan_tests_init+0x8/0xc
+	do_one_initcall+0x85/0x1a0
+	kernel_init_freeable+0x1f1/0x279
+	kernel_init+0x8/0xd0
+	ret_from_kernel_thread+0x21/0x30
+INFO: Slab 0xc7f3d0c0 objects=14 used=2 fp=0xc6006120 flags=0x5000080
+INFO: Object 0xc6006ea0 @offset=3744 fp=0xc6006d80
+
+Bytes b4 c6006e90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006ea0: 80 6d 00 c6 00 00 00 00 00 00 00 00 00 00 00 00  .m..............
+Object c6006eb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+Object c6006f10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
+CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B          3.16.0-rc3-next-20140704+ #216
+Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
+ 00000000 00000000 c6006ea0 c6889e30 c1c4446f c6801b40 c6889e48 c11c3f32
+ c6006000 c6801b40 c7f3d0c0 c6006ea0 c6889e68 c11c4ff5 c6801b40 c1e44906
+ c1e11352 c7f3d0c0 c6889efc c6801b40 c6889ef4 c11ccb78 c1e11352 00000286
+Call Trace:
+ [<c1c4446f>] dump_stack+0x4b/0x75
+ [<c11c3f32>] print_trailer+0xf2/0x180
+ [<c11c4ff5>] object_err+0x25/0x30
+ [<c11ccb78>] kasan_report_error+0xf8/0x380
+ [<c1c57940>] ? need_resched+0x21/0x25
+ [<c11cb92b>] ? poison_shadow+0x2b/0x30
+ [<c11cb92b>] ? poison_shadow+0x2b/0x30
+ [<c11cb92b>] ? poison_shadow+0x2b/0x30
+ [<c1f82763>] ? kasan_kmalloc_oob_right+0x7a/0x7a
+ [<c11cbacc>] __asan_store1+0x9c/0xa0
+ [<c1f82753>] ? kasan_kmalloc_oob_rigth+0x6a/0x7a
+ [<c1f82753>] kasan_kmalloc_oob_rigth+0x6a/0x7a
+ [<c1f8276b>] kasan_tests_init+0x8/0xc
+ [<c1000435>] do_one_initcall+0x85/0x1a0
+ [<c1f6f508>] ? repair_env_string+0x23/0x66
+ [<c1f6f4e5>] ? initcall_blacklist+0x85/0x85
+ [<c10c9883>] ? parse_args+0x33/0x450
+ [<c1f6fdb7>] kernel_init_freeable+0x1f1/0x279
+ [<c1000558>] kernel_init+0x8/0xd0
+ [<c1c578c1>] ret_from_kernel_thread+0x21/0x30
+ [<c1000550>] ? do_one_initcall+0x1a0/0x1a0
+Write of size 1 by thread T1:
+Memory state around the buggy address:
+ c6006c80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
+ c6006d00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
+ c6006d80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
+ c6006e00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
+ c6006e80: fd fd fd fd 00 00 00 00 00 00 00 00 00 00 00 00
+>c6006f00: 00 00 00 03 fc fc fc fc fc fc fc fc fc fc fc fc
+                    ^
+ c6006f80: fc fc fc fc fc fc fc fc fd fd fd fd fd fd fd fd
+ c6007000: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
+ c6007080: fc fc fc fc fc fc fc fc fc fc fc fc fc 00 00 00
+ c6007100: 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc
+ c6007180: fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00 00
+==================================================================
+
+In the last section the report shows memory state around the accessed address.
+Reading this part requires some more undestanding of how KASAN works.
+
+Each KASAN_SHADOW_SCALE_SIZE bytes of memory can be marked as addressable,
+partially addressable, freed or they can be part of a redzone.
+If bytes are marked as addressable that means that they belong to some
+allocated memory block and it is possible to read or modify any of these
+bytes. Addressable KASAN_SHADOW_SCALE_SIZE bytes are marked by 0 in the report.
+When only the first N bytes of KASAN_SHADOW_SCALE_SIZE belong to an allocated
+memory block, this bytes are partially addressable and marked by 'N'.
+
+Markers of inaccessible bytes could be found in mm/kasan/kasan.h header:
+
+#define KASAN_FREE_PAGE         0xFF  /* page was freed */
+#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
+#define KASAN_SLAB_PADDING      0xFD  /* Slab page redzone, does not belong to any slub object */
+#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
+#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
+#define KASAN_SLAB_FREE         0xFA  /* free slab page */
+#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
+
+In the report above the arrows point to the shadow byte 03, which means that the
+accessed address is partially addressable.
+
+
+2. Implementation details
+========================
+
+From a high level, our approach to memory error detection is similar to that
+of kmemcheck: use shadow memory to record whether each byte of memory is safe
+to access, and use compile-time instrumentation to check shadow on each memory
+access.
+
+AddressSanitizer dedicates 1/8 of kernel memory to its shadow
+memory (e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a
+scale and offset to translate a memory address to its corresponding shadow address.
+
+Here is the function witch translate an address to its corresponding shadow address:
+
+unsigned long kasan_mem_to_shadow(unsigned long addr)
+{
+	return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
+}
+
+where KASAN_SHADOW_SCALE_SHIFT = 3.
+
+Each shadow byte corresponds to 8 bytes of the main memory. We use the
+following encoding for each shadow byte: 0 means that all 8 bytes of the
+corresponding memory region are addressable; k (1 <= k <= 7) means that
+the first k bytes are addressable, and other (8 - k) bytes are not;
+any negative value indicates that the entire 8-byte word is unaddressable.
+We use different negative values to distinguish between different kinds of
+unaddressable memory (redzones, freed memory) (see mm/kasan/kasan.h).
+
+Poisoning or unpoisoning a byte in the main memory means writing some special
+value into the corresponding shadow memory. This value indicates whether the
+byte is addressable or not.
diff --git a/Makefile b/Makefile
index e90dce2..6f8be78 100644
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
@@ -426,7 +426,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
-export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV
+export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KASAN
 export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
 export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
 export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
@@ -757,6 +757,13 @@ ifdef CONFIG_DEBUG_SECTION_MISMATCH
 KBUILD_CFLAGS += $(call cc-option, -fno-inline-functions-called-once)
 endif
 
+ifdef CONFIG_KASAN
+  ifeq ($(CFLAGS_KASAN),)
+    $(warning Cannot use CONFIG_KASAN: \
+	      -fsanitize=kernel-address not supported by compiler)
+  endif
+endif
+
 # arch Makefile may override CC so keep this after arch Makefile is included
 NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
 CHECKFLAGS     += $(NOSTDINC_FLAGS)
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
index 706a9f7..3c3ef5d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1661,6 +1661,9 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+#ifdef CONFIG_KASAN
+	unsigned int kasan_depth;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ddd070a..bb26ec3 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -666,6 +666,8 @@ config DEBUG_STACKOVERFLOW
 
 source "lib/Kconfig.kmemcheck"
 
+source "lib/Kconfig.kasan"
+
 endmenu # "Memory Debugging"
 
 config DEBUG_SHIRQ
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
new file mode 100644
index 0000000..54cf44f
--- /dev/null
+++ b/lib/Kconfig.kasan
@@ -0,0 +1,15 @@
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
+endif
diff --git a/mm/Makefile b/mm/Makefile
index ba3ec4e..40d58a8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
+obj-$(CONFIG_KASAN)	+= kasan/
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
new file mode 100644
index 0000000..46d44bb
--- /dev/null
+++ b/mm/kasan/Makefile
@@ -0,0 +1,3 @@
+KASAN_SANITIZE := n
+
+obj-y := kasan.o report.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
new file mode 100644
index 0000000..8ce738e
--- /dev/null
+++ b/mm/kasan/kasan.c
@@ -0,0 +1,336 @@
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
+static inline bool kasan_enabled(void)
+{
+	return !current->kasan_depth;
+}
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
+	if (likely(!kasan_enabled()))
+		return;
+
+	info.access_addr = addr;
+	info.access_size = size;
+	info.is_write = write;
+	info.ip = _RET_IP_;
+	kasan_report_error(&info);
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
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
new file mode 100644
index 0000000..9a9fe9f
--- /dev/null
+++ b/mm/kasan/kasan.h
@@ -0,0 +1,27 @@
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
+#endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
new file mode 100644
index 0000000..89a9aa1
--- /dev/null
+++ b/mm/kasan/report.c
@@ -0,0 +1,169 @@
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
+
+	pr_err("%s of size %zu by task %s:\n",
+		info->is_write ? "Write" : "Read",
+		info->access_size, current->comm);
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
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 54be19a..c1517e2 100644
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
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
