Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SFiFdq011695
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:44:15 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SFiEQB271788
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 09:44:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SFiEhA015569
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 09:44:14 -0600
Subject: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 28 Aug 2006 08:44:13 -0700
Message-Id: <20060828154413.E05721BD@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter suggested that I break this up into a few more
patches.  This one should at least break out the architectures where
some real thinking is involved from the trivial ones that have a
simple definition of PAGE_SIZE/SHIFT.

----
 
All architectures currently explicitly define their page size.  In some
cases (ppc, parisc, ia64, sparc64, mips) this size is somewhat
configurable.

There several reimplementations of ways to make sure that PAGE_SIZE
is usable in assembly code, yet still somewhat type safe for use in
C code (as a UL type).  These are all very similar.  There are also a
number of macros based off of PAGE_SIZE/SHIFT which are duplicated
across architectures.

This patch unifies all of those definitions.  It defines PAGE_SIZE in
a single header which gets its definitions from Kconfig.  The new
Kconfig options mirror what used to be done with #ifdefs and
arch-specific Kconfig options.  The new Kconfig menu eliminates
the need for parisc, ia64, and sparc64 to have their own "choice"
menus for selecting page size.  The help text has been adapted from
these three architectures, but is now more generic.

For now, architectures must enable GENERIC_PAGE_SIZE in order to get
this new code.  This option will be removed by the last patch in the
series.

Why am I doing this?  The OpenVZ beancounter patch hooks into the
alloc_thread_info() path, but only in two architectures.  It is silly
to patch each and every architecture when they all just do the same
thing.  This is the first step to have a single place in which to
do alloc_thread_info().  Oh, and this series removes about 300 lines
of code.

 46 files changed, 178 insertions(+), 514 deletions(-)

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-generic/page.h |   33 ++++++++++++++++++--
 threadalloc-dave/mm/Kconfig                 |   45 ++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 3 deletions(-)

diff -puN include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure include/asm-generic/page.h
--- threadalloc/include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure	2006-08-25 11:34:22.000000000 -0700
+++ threadalloc-dave/include/asm-generic/page.h	2006-08-25 11:34:22.000000000 -0700
@@ -1,10 +1,38 @@
 #ifndef _ASM_GENERIC_PAGE_H
 #define _ASM_GENERIC_PAGE_H
 
+#include <linux/compiler.h>
+
 #ifdef __KERNEL__
-#ifndef __ASSEMBLY__
 
-#include <linux/compiler.h>
+#ifdef CONFIG_ARCH_GENERIC_PAGE_SIZE
+#ifdef __ASSEMBLY__
+#define ASM_CONST(x) x
+#else
+#define __ASM_CONST(x) x##UL
+#define ASM_CONST(x) __ASM_CONST(x)
+#endif
+
+#define PAGE_SHIFT      CONFIG_PAGE_SHIFT
+#define PAGE_SIZE       (ASM_CONST(1) << PAGE_SHIFT)
+
+/* align addr on a size boundary - adjust address up/down if needed */
+#define _ALIGN_UP(addr,size)    (((addr)+((size)-1))&(~((size)-1)))
+#define _ALIGN_DOWN(addr,size)  ((addr)&(~((size)-1)))
+
+/* align addr on a size boundary - adjust address up if needed */
+#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
+
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr)        _ALIGN(addr, PAGE_SIZE)
+
+/*
+ * Subtle: (1 << PAGE_SHIFT) is an int, not an unsigned long. So if we
+ * assign PAGE_MASK to a larger type it gets extended the way we want
+ * (i.e. with 1s in the high bits)
+ */
+#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
+#endif /* CONFIG_ARCH_GENERIC_PAGE_SIZE */
 
 /* Pure 2^n version of get_order */
 static __inline__ __attribute_const__ int get_order(unsigned long size)
@@ -20,7 +48,6 @@ static __inline__ __attribute_const__ in
 	return order;
 }
 
-#endif	/* __ASSEMBLY__ */
 #endif	/* __KERNEL__ */
 
 #endif	/* _ASM_GENERIC_PAGE_H */
diff -puN mm/Kconfig~generic-PAGE_SIZE-infrastructure mm/Kconfig
--- threadalloc/mm/Kconfig~generic-PAGE_SIZE-infrastructure	2006-08-25 11:34:22.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-25 11:34:22.000000000 -0700
@@ -1,3 +1,48 @@
+#
+# On PPC32 page size is 4K. For PPC64 we support either 4K or 64K software
+# page size. When using 64K pages however, whether we are really supporting
+# 64K pages in HW or not is irrelevant to those definitions.
+#
+choice
+	prompt "Kernel Page Size"
+	depends on ARCH_GENERIC_PAGE_SIZE
+config PAGE_SIZE_4KB
+	bool "4KB"
+	help
+	  This lets you select the page size of the kernel.  For best 64-bit
+	  performance, a page size of larger than 4k is recommended.  For best
+	  32-bit compatibility on 64-bit architectures, a page size of 4KB
+	  should be selected (although most binaries work perfectly fine with
+	  a larger page size).
+
+	  4KB                For best 32-bit compatibility
+	  8KB and up         For best performance
+	  above 64k	     For kernel hackers only
+
+	  If you don't know what to do, choose 8KB (if available).
+	  Otherwise, choose 4KB.
+config PAGE_SIZE_8KB
+	bool "8KB"
+config PAGE_SIZE_16KB
+	bool "16KB"
+config PAGE_SIZE_64KB
+	bool "64KB"
+config PAGE_SIZE_512KB
+	bool "512KB"
+config PAGE_SIZE_4MB
+	bool "4MB"
+endchoice
+
+config PAGE_SHIFT
+	int
+	depends on ARCH_GENERIC_PAGE_SIZE
+	default "13" if PAGE_SIZE_8KB
+	default "14" if PAGE_SIZE_16KB
+	default "16" if PAGE_SIZE_64KB
+	default "19" if PAGE_SIZE_512KB
+	default "22" if PAGE_SIZE_4MB
+	default "12"
+
 config SELECT_MEMORY_MODEL
 	def_bool y
 	depends on EXPERIMENTAL || ARCH_SELECT_MEMORY_MODEL
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
