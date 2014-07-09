Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EC8836B0036
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:25 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so8793081pdj.22
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:25 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id au10si45876068pbd.14.2014.07.09.04.36.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:24 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G00BUB08L2650@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:21 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer
 infrastructure.
Date: Wed, 09 Jul 2014 15:29:55 +0400
Message-id: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Address sanitizer for kernel (kasan) is a dynamic memory error detector.

The main features of kasan is:
 - is based on compiler instrumentation (fast),
 - detects out of bounds for both writes and reads,
 - provides use after free detection,

This patch only adds infrastructure for kernel address sanitizer. It's not
available for use yet. The idea and some code was borrowed from [1].

This feature requires pretty fresh GCC (revision r211699 from 2014-06-16 or
latter).

Implementation details:
The main idea of KASAN is to use shadow memory to record whether each byte of memory
is safe to access or not, and use compiler's instrumentation to check the shadow memory
on each memory access.

Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
mapping with a scale and offset to translate a memory address to its corresponding
shadow address.

Here is function to translate address to corresponding shadow address:

     unsigned long kasan_mem_to_shadow(unsigned long addr)
     {
                return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
                             + kasan_shadow_start;
     }

where KASAN_SHADOW_SCALE_SHIFT = 3.

So for every 8 bytes of lowmemory there is one corresponding byte of shadow memory.
The following encoding used for each shadow byte: 0 means that all 8 bytes of the
corresponding memory region are valid for access; k (1 <= k <= 7) means that
the first k bytes are valid for access, and other (8 - k) bytes are not;
Any negative value indicates that the entire 8-bytes are unaccessible.
Different negative values used to distinguish between different kinds of
unaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

To be able to detect accesses to bad memory we need a special compiler.
Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
before each memory access of size 1, 2, 4, 8 or 16.

These functions check whether memory region is valid to access or not by checking
corresponding shadow memory. If access is not valid an error printed.

[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Documentation/kasan.txt | 224 +++++++++++++++++++++++++++++++++++++
 Makefile                |   8 +-
 commit                  |   3 +
 include/linux/kasan.h   |  33 ++++++
 include/linux/sched.h   |   4 +
 lib/Kconfig.debug       |   2 +
 lib/Kconfig.kasan       |  20 ++++
 mm/Makefile             |   1 +
 mm/kasan/Makefile       |   3 +
 mm/kasan/kasan.c        | 292 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h        |  36 ++++++
 mm/kasan/report.c       | 157 ++++++++++++++++++++++++++
 scripts/Makefile.lib    |  10 ++
 13 files changed, 792 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/kasan.txt
 create mode 100644 commit
 create mode 100644 include/linux/kasan.h
 create mode 100644 lib/Kconfig.kasan
 create mode 100644 mm/kasan/Makefile
 create mode 100644 mm/kasan/kasan.c
 create mode 100644 mm/kasan/kasan.h
 create mode 100644 mm/kasan/report.c

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
new file mode 100644
index 0000000..141391ba
--- /dev/null
+++ b/Documentation/kasan.txt
@@ -0,0 +1,224 @@
+Kernel address sanitizer
+================
+
+0. Overview
+===========
+
+Address sanitizer for kernel (KASAN) is a dynamic memory error detector. It provides
+fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
+
+KASAN is better than all of CONFIG_DEBUG_PAGEALLOC, because it:
+ - is based on compiler instrumentation (fast),
+ - detects OOB for both writes and reads,
+ - provides UAF detection,
+ - prints informative reports.
+
+KASAN uses compiler instrumentation for checking every memory access, therefore you
+will need a special compiler: GCC >= 4.10.0.
+
+Currently KASAN supported on x86/x86_64/arm architectures and requires kernel
+to be build with SLUB allocator.
+
+1. Usage
+=========
+
+KASAN requires the kernel to be built with a special compiler (GCC >= 4.10.0).
+
+To enable KASAN configure kernel with:
+
+	  CONFIG_KASAN = y
+
+to instrument entire kernel:
+
+	  CONFIG_KASAN_SANTIZE_ALL = y
+
+Currently KASAN works only with SLUB. It is highly recommended to run KASAN with
+CONFIG_SLUB_DEBUG=y and 'slub_debug=U'. This enables user tracking (free and alloc traces).
+There is no need to enable redzoning since KASAN detects access to user tracking structs
+so they actually act like redzones.
+
+To enable instrumentation for only specific files or directories, add a line
+similar to the following to the respective kernel Makefile:
+
+        For a single file (e.g. main.o):
+                KASAN_SANITIZE_main.o := y
+
+        For all files in one directory:
+                KASAN_SANITIZE := y
+
+To exclude files from being profiled even when CONFIG_GCOV_PROFILE_ALL
+is specified, use:
+
+                KASAN_SANITIZE_main.o := n
+        and:
+                KASAN_SANITIZE := n
+
+Only files which are linked to the main kernel image or are compiled as
+kernel modules are supported by this mechanism.
+
+
+1.1 Error reports
+==========
+
+A typical buffer overflow report looks like this:
+
+==================================================================
+AddressSanitizer: buffer overflow in kasan_kmalloc_oob_rigth+0x6a/0x7a at addr c6006f1b
+=============================================================================
+BUG kmalloc-128 (Not tainted): kasan error
+-----------------------------------------------------------------------------
+
+Disabling lock debugging due to kernel taint
+INFO: Allocated in kasan_kmalloc_oob_rigth+0x2c/0x7a age=5 cpu=0 pid=1
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
+ [<c1f82763>] ? kasan_kmalloc_oob_rigth+0x7a/0x7a
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
+Markers of unaccessible bytes could be found in mm/kasan/kasan.h header:
+
+#define KASAN_FREE_PAGE         0xFF  /* page was freed */
+#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
+#define KASAN_SLAB_REDZONE      0xFD  /* Slab page redzone, does not belong to any slub object */
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
+2.1. Shadow memory
+==================
+
+From a high level, our approach to memory error detection is similar to that
+of kmemcheck: use shadow memory to record whether each byte of memory is safe
+to access, and use instrumentation to check the shadow memory on each memory
+access.
+
+AddressSanitizer dedicates one-eighth of the low memory to its shadow
+memory and uses direct mapping with a scale and offset to translate a memory
+address to its corresponding shadow address.
+
+Here is function witch translate address to corresponding shadow address:
+
+unsigned long kasan_mem_to_shadow(unsigned long addr)
+{
+	return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_START;
+}
+
+where KASAN_SHADOW_SCALE_SHIFT = 3.
+
+The figure below shows the address space layout. The memory is split
+into two parts (low and high) which map to the corresponding shadow regions.
+Applying the shadow mapping to addresses in the shadow region gives us
+addresses in the Bad region.
+
+|--------|        |--------|
+| Memory |----    | Memory |
+|--------|    \   |--------|
+| Shadow |--   -->| Shadow |
+|--------|  \     |--------|
+|   Bad  |   ---->|  Bad   |
+|--------|  /     |--------|
+| Shadow |--   -->| Shadow |
+|--------|    /   |--------|
+| Memory |----    | Memory |
+|--------|        |--------|
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
+
+
+2.2. Instrumentation
+====================
+
+Since some functions (such as memset, memmove, memcpy) wich do memory accesses
+are written in assembly, compiler can't instrument them.
+Therefore we replace these functions with our own instrumented functions
+(kasan_memset, kasan_memcpy, kasan_memove).
+In some circumstances you may need to use the original functions,
+in such case insert #undef KASAN_HOOKS before includes.
+
diff --git a/Makefile b/Makefile
index 64ab7b3..08a07f2 100644
--- a/Makefile
+++ b/Makefile
@@ -384,6 +384,12 @@ LDFLAGS_MODULE  =
 CFLAGS_KERNEL	=
 AFLAGS_KERNEL	=
 CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage
+CFLAGS_KASAN	= -fsanitize=address --param asan-stack=0 \
+			--param asan-use-after-return=0 \
+			--param asan-globals=0 \
+			--param asan-memintrin=0 \
+			--param asan-instrumentation-with-call-threshold=0 \
+			-DKASAN_HOOKS
 
 
 # Use USERINCLUDE when you must reference the UAPI directories only.
@@ -428,7 +434,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
 
 export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
-export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV
+export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KASAN
 export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
 export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
 export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
diff --git a/commit b/commit
new file mode 100644
index 0000000..134f4dd
--- /dev/null
+++ b/commit
@@ -0,0 +1,3 @@
+
+I'm working on address sanitizer for kernel.
+fuck this bloody.
\ No newline at end of file
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
new file mode 100644
index 0000000..7efc3eb
--- /dev/null
+++ b/include/linux/kasan.h
@@ -0,0 +1,33 @@
+#ifndef _LINUX_KASAN_H
+#define _LINUX_KASAN_H
+
+#include <linux/types.h>
+
+struct kmem_cache;
+struct page;
+
+#ifdef CONFIG_KASAN
+
+void unpoison_shadow(const void *address, size_t size);
+
+void kasan_enable_local(void);
+void kasan_disable_local(void);
+
+/* Reserves shadow memory. */
+void kasan_alloc_shadow(void);
+void kasan_init_shadow(void);
+
+#else /* CONFIG_KASAN */
+
+static inline void unpoison_shadow(const void *address, size_t size) {}
+
+static inline void kasan_enable_local(void) {}
+static inline void kasan_disable_local(void) {}
+
+/* Reserves shadow memory. */
+static inline void kasan_init_shadow(void) {}
+static inline void kasan_alloc_shadow(void) {}
+
+#endif /* CONFIG_KASAN */
+
+#endif /* LINUX_KASAN_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 322d4fc..286650a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1471,6 +1471,10 @@ struct task_struct {
 	gfp_t lockdep_reclaim_gfp;
 #endif
 
+#ifdef CONFIG_KASAN
+	int kasan_depth;
+#endif
+
 /* journalling filesystem info */
 	void *journal_info;
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index cf9cf82..67a4dfc 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -611,6 +611,8 @@ config DEBUG_STACKOVERFLOW
 
 source "lib/Kconfig.kmemcheck"
 
+source "lib/Kconfig.kasan"
+
 endmenu # "Memory Debugging"
 
 config DEBUG_SHIRQ
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
new file mode 100644
index 0000000..2bfff78
--- /dev/null
+++ b/lib/Kconfig.kasan
@@ -0,0 +1,20 @@
+config HAVE_ARCH_KASAN
+	bool
+
+if HAVE_ARCH_KASAN
+
+config KASAN
+	bool "AddressSanitizer: dynamic memory error detector"
+	default n
+	help
+	  Enables AddressSanitizer - dynamic memory error detector,
+	  that finds out-of-bounds and use-after-free bugs.
+
+config KASAN_SANITIZE_ALL
+	bool "Instrument entire kernel"
+	depends on KASAN
+	default y
+	help
+	  This enables compiler intrumentation for entire kernel
+
+endif
diff --git a/mm/Makefile b/mm/Makefile
index e4a97bd..dbe9a22 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -64,3 +64,4 @@ obj-$(CONFIG_ZPOOL)	+= zpool.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
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
index 0000000..e2cd345
--- /dev/null
+++ b/mm/kasan/kasan.c
@@ -0,0 +1,292 @@
+/*
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
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
+#include <linux/memcontrol.h>
+
+#include "kasan.h"
+#include "../slab.h"
+
+static bool __read_mostly kasan_initialized;
+
+unsigned long kasan_shadow_start;
+unsigned long kasan_shadow_end;
+
+/* equals to (kasan_shadow_start - PAGE_OFFSET/KASAN_SHADOW_SCALE_SIZE) */
+unsigned long __read_mostly kasan_shadow_offset; /* it's not a very good name for this variable */
+
+
+static inline bool addr_is_in_mem(unsigned long addr)
+{
+	return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
+}
+
+void kasan_enable_local(void)
+{
+	if (likely(kasan_initialized))
+		current->kasan_depth--;
+}
+
+void kasan_disable_local(void)
+{
+	if (likely(kasan_initialized))
+		current->kasan_depth++;
+}
+
+static inline bool kasan_enabled(void)
+{
+	return likely(kasan_initialized
+		&& !current->kasan_depth);
+}
+
+/*
+ * Poisons the shadow memory for 'size' bytes starting from 'addr'.
+ * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
+ */
+static void poison_shadow(const void *address, size_t size, u8 value)
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
+void unpoison_shadow(const void *address, size_t size)
+{
+	poison_shadow(address, size, 0);
+
+	if (size & KASAN_SHADOW_MASK) {
+		u8 *shadow = (u8 *)kasan_mem_to_shadow((unsigned long)address
+						+ size);
+		*shadow = size & KASAN_SHADOW_MASK;
+	}
+}
+
+static __always_inline bool address_is_poisoned(unsigned long addr)
+{
+	s8 shadow_value = *(s8 *)kasan_mem_to_shadow(addr);
+
+	if (shadow_value != 0) {
+		s8 last_byte = addr & KASAN_SHADOW_MASK;
+		return last_byte >= shadow_value;
+	}
+	return false;
+}
+
+static __always_inline unsigned long memory_is_poisoned(unsigned long addr,
+							size_t size)
+{
+	unsigned long end = addr + size;
+	for (; addr < end; addr++)
+		if (unlikely(address_is_poisoned(addr)))
+			return addr;
+	return 0;
+}
+
+static __always_inline void check_memory_region(unsigned long addr,
+						size_t size, bool write)
+{
+	unsigned long access_addr;
+	struct access_info info;
+
+	if (!kasan_enabled())
+		return;
+
+	if (unlikely(addr < TASK_SIZE)) {
+		info.access_addr = addr;
+		info.access_size = size;
+		info.is_write = write;
+		info.ip = _RET_IP_;
+		kasan_report_user_access(&info);
+		return;
+	}
+
+	if (!addr_is_in_mem(addr))
+		return;
+
+	access_addr = memory_is_poisoned(addr, size);
+	if (likely(access_addr == 0))
+		return;
+
+	info.access_addr = access_addr;
+	info.access_size = size;
+	info.is_write = write;
+	info.ip = _RET_IP_;
+	kasan_report_error(&info);
+}
+
+void __init kasan_alloc_shadow(void)
+{
+	unsigned long lowmem_size = (unsigned long)high_memory - PAGE_OFFSET;
+	unsigned long shadow_size;
+	phys_addr_t shadow_phys_start;
+
+	shadow_size = lowmem_size >> KASAN_SHADOW_SCALE_SHIFT;
+
+	shadow_phys_start = memblock_alloc(shadow_size, PAGE_SIZE);
+	if (!shadow_phys_start) {
+		pr_err("Unable to reserve shadow memory\n");
+		return;
+	}
+
+	kasan_shadow_start = (unsigned long)phys_to_virt(shadow_phys_start);
+	kasan_shadow_end = kasan_shadow_start + shadow_size;
+
+	pr_info("reserved shadow memory: [0x%lx - 0x%lx]\n",
+		kasan_shadow_start, kasan_shadow_end);
+	kasan_shadow_offset = kasan_shadow_start -
+		(PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT);
+}
+
+void __init kasan_init_shadow(void)
+{
+	if (kasan_shadow_start) {
+		unpoison_shadow((void *)PAGE_OFFSET,
+				(size_t)(kasan_shadow_start - PAGE_OFFSET));
+		poison_shadow((void *)kasan_shadow_start,
+			kasan_shadow_end - kasan_shadow_start,
+			KASAN_SHADOW_GAP);
+		unpoison_shadow((void *)kasan_shadow_end,
+				(size_t)(high_memory - kasan_shadow_end));
+		kasan_initialized = true;
+		pr_info("shadow memory initialized\n");
+	}
+}
+
+void *kasan_memcpy(void *dst, const void *src, size_t len)
+{
+	if (unlikely(len == 0))
+		return dst;
+
+	check_memory_region((unsigned long)src, len, false);
+	check_memory_region((unsigned long)dst, len, true);
+
+	return memcpy(dst, src, len);
+}
+EXPORT_SYMBOL(kasan_memcpy);
+
+void *kasan_memset(void *ptr, int val, size_t len)
+{
+	if (unlikely(len == 0))
+		return ptr;
+
+	check_memory_region((unsigned long)ptr, len, true);
+
+	return memset(ptr, val, len);
+}
+EXPORT_SYMBOL(kasan_memset);
+
+void *kasan_memmove(void *dst, const void *src, size_t len)
+{
+	if (unlikely(len == 0))
+		return dst;
+
+	check_memory_region((unsigned long)src, len, false);
+	check_memory_region((unsigned long)dst, len, true);
+
+	return memmove(dst, src, len);
+}
+EXPORT_SYMBOL(kasan_memmove);
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
+/* to shut up compiler complains */
+void __asan_init_v3(void) {}
+EXPORT_SYMBOL(__asan_init_v3);
+
+void __asan_handle_no_return(void) {}
+EXPORT_SYMBOL(__asan_handle_no_return);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
new file mode 100644
index 0000000..711ae4f
--- /dev/null
+++ b/mm/kasan/kasan.h
@@ -0,0 +1,36 @@
+#ifndef __MM_KASAN_KASAN_H
+#define __MM_KASAN_KASAN_H
+
+#define KASAN_SHADOW_SCALE_SHIFT 3
+#define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
+#define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
+
+#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
+
+struct access_info {
+	unsigned long access_addr;
+	size_t access_size;
+	bool is_write;
+	unsigned long ip;
+};
+
+extern unsigned long kasan_shadow_start;
+extern unsigned long kasan_shadow_end;
+extern unsigned long kasan_shadow_offset;
+
+void kasan_report_error(struct access_info *info);
+void kasan_report_user_access(struct access_info *info);
+
+static inline unsigned long kasan_mem_to_shadow(unsigned long addr)
+{
+	return (addr >> KASAN_SHADOW_SCALE_SHIFT)
+		+ kasan_shadow_offset;
+}
+
+static inline unsigned long kasan_shadow_to_mem(unsigned long shadow_addr)
+{
+	return ((shadow_addr - kasan_shadow_start)
+		<< KASAN_SHADOW_SCALE_SHIFT) + PAGE_OFFSET;
+}
+
+#endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
new file mode 100644
index 0000000..2430e05
--- /dev/null
+++ b/mm/kasan/report.c
@@ -0,0 +1,157 @@
+/*
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
+ *
+ * Some of code borrowed from https://github.com/xairy/linux by
+ *        Andrey Konovalov <andreyknvl@google.com>
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
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/kasan.h>
+#include <linux/memcontrol.h> /* for ../slab.h */
+
+#include "kasan.h"
+#include "../slab.h"
+
+/* Shadow layout customization. */
+#define SHADOW_BYTES_PER_BLOCK 1
+#define SHADOW_BLOCKS_PER_ROW 16
+#define SHADOW_BYTES_PER_ROW (SHADOW_BLOCKS_PER_ROW * SHADOW_BYTES_PER_BLOCK)
+#define SHADOW_ROWS_AROUND_ADDR 5
+
+static inline void *virt_to_obj(struct kmem_cache *s, void *slab_start, void *x)
+{
+	return x - ((x - slab_start) % s->size);
+}
+
+static void print_error_description(struct access_info *info)
+{
+	const char *bug_type = "unknown crash";
+	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->access_addr);
+
+	switch (shadow_val) {
+	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		bug_type = "buffer overflow";
+		break;
+	case KASAN_SHADOW_GAP:
+		bug_type = "wild memory access";
+		break;
+	}
+
+	pr_err("AddressSanitizer: %s in %pS at addr %p\n",
+		bug_type, (void *)info->ip,
+		(void *)info->access_addr);
+}
+
+static void print_address_description(struct access_info *info)
+{
+	void *object;
+	struct kmem_cache *cache;
+	void *slab_start;
+	struct page *page;
+	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->access_addr);
+
+	page = virt_to_page(info->access_addr);
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
+	pr_err("%s of size %zu by thread T%d:\n",
+		info->is_write ? "Write" : "Read",
+		info->access_size, current->pid);
+}
+
+static bool row_is_guilty(unsigned long row, unsigned long guilty)
+{
+	return (row <= guilty) && (guilty < row + SHADOW_BYTES_PER_ROW);
+}
+
+static void print_shadow_pointer(unsigned long row, unsigned long shadow,
+				 char *output)
+{
+	/* The length of ">ff00ff00ff00ff00: " is 3 + (BITS_PER_LONG/8)*2 chars. */
+	unsigned long space_count = 3 + (BITS_PER_LONG >> 2) + (shadow - row)*2 +
+		(shadow - row) / SHADOW_BYTES_PER_BLOCK;
+	unsigned long i;
+
+	for (i = 0; i < space_count; i++)
+		output[i] = ' ';
+	output[space_count] = '^';
+	output[space_count + 1] = '\0';
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
+		char buffer[100];
+
+		snprintf(buffer, sizeof(buffer),
+			(i == 0) ? ">%lx: " : " %lx: ", kaddr);
+
+		print_hex_dump(KERN_ERR, buffer,
+			DUMP_PREFIX_NONE, SHADOW_BYTES_PER_ROW, 1,
+			(void *)aligned_shadow, SHADOW_BYTES_PER_ROW, 0);
+
+		if (row_is_guilty(aligned_shadow, shadow)) {
+			print_shadow_pointer(aligned_shadow, shadow, buffer);
+			pr_err("%s\n", buffer);
+		}
+		aligned_shadow += SHADOW_BYTES_PER_ROW;
+	}
+}
+
+void kasan_report_error(struct access_info *info)
+{
+	kasan_disable_local();
+	pr_err("================================="
+		"=================================\n");
+	print_error_description(info);
+	print_address_description(info);
+	print_shadow_for_address(info->access_addr);
+	pr_err("================================="
+		"=================================\n");
+	kasan_enable_local();
+}
+
+void kasan_report_user_access(struct access_info *info)
+{
+	kasan_disable_local();
+	pr_err("================================="
+		"=================================\n");
+        pr_err("AddressSanitizer: user-memory-access on address %lx\n",
+		info->access_addr);
+        pr_err("%s of size %zu by thread T%d:\n",
+		info->is_write ? "Write" : "Read",
+               info->access_size, current->pid);
+	dump_stack();
+	pr_err("================================="
+		"=================================\n");
+	kasan_enable_local();
+}
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 260bf8a..2bec69e 100644
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
+		$(KASAN_SANITIZE_$(basetarget).o)$(KASAN_SANITIZE)$(CONFIG_KASAN_SANITIZE_ALL)), \
+		$(CFLAGS_KASAN))
+endif
+
 # If building the kernel in a separate objtree expand all occurrences
 # of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').
 
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
