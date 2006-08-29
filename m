Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJcrB010905
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:38 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJc92268452
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJcZM010503
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:38 -0400
Subject: [RFC][PATCH 03/10] actual generic PAGE_SIZE infrastructure
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:36 -0700
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
Message-Id: <20060829201936.2C7D5100@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

* Add _ALIGN_UP() which we'll use now and _ALIGN_DOWN(), just for
  parity.
* Define ASM_CONST() macro to help using constants in both assembly
  and C code.  Several architectures have some form of this, and
  they will be consolidated around this one.
* Actually create PAGE_SHIFT and PAGE_SIZE macros
* For now, require that architectures enable GENERIC_PAGE_SIZE in
  order to get this new code.  This option will be removed by the
  last patch in the series, and makes the series bisect-safe.
* Note that this moves the compiler.h define outside of the
  #ifdef __KERNEL__, but that's OK because it has its own.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/linux/align.h      |    7 ++++
 threadalloc-dave/include/asm-generic/page.h |   31 +++++++++++++++++++--
 threadalloc-dave/mm/Kconfig                 |   41 ++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 4 deletions(-)

diff -puN include/linux/align.h~generic-PAGE_SIZE-infrastructure include/linux/align.h
--- threadalloc/include/linux/align.h~generic-PAGE_SIZE-infrastructure	2006-08-29 13:14:50.000000000 -0700
+++ threadalloc-dave/include/linux/align.h	2006-08-29 13:14:51.000000000 -0700
@@ -6,12 +6,17 @@
  * dependencies, and can be used safely from any other header.
  */
 
+/* align addr on a size boundary - adjust address up/down if needed */
+#define _ALIGN_UP(addr,size)    (((addr)+((size)-1))&(~((size)-1)))
+#define _ALIGN_DOWN(addr,size)  ((addr)&(~((size)-1)))
+
 /*
  * ALIGN is special.  There's a linkage.h as well that
  * has a quite different meaning.
  */
 #ifndef __ASSEMBLY__
-#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
+/* align addr on a size boundary - adjust address up if needed */
+#define ALIGN(addr,size)     _ALIGN_UP(addr,size)
 #endif
 
 #endif /* _LINUX_ALIGN_H */
diff -puN include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure include/asm-generic/page.h
--- threadalloc/include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure	2006-08-29 13:14:50.000000000 -0700
+++ threadalloc-dave/include/asm-generic/page.h	2006-08-29 13:14:51.000000000 -0700
@@ -1,11 +1,36 @@
 #ifndef _ASM_GENERIC_PAGE_H
 #define _ASM_GENERIC_PAGE_H
 
+#include <linux/compiler.h>
+#include <linux/align.h>
+
 #ifdef __KERNEL__
-#ifndef __ASSEMBLY__
 
-#include <linux/compiler.h>
+#ifdef __ASSEMBLY__
+#define ASM_CONST(x) x
+#else
+#define __ASM_CONST(x) x##UL
+#define ASM_CONST(x) __ASM_CONST(x)
+#endif
+
+#ifdef CONFIG_ARCH_GENERIC_PAGE_SIZE
+
+#define PAGE_SHIFT      CONFIG_PAGE_SHIFT
+#define PAGE_SIZE       (ASM_CONST(1) << PAGE_SHIFT)
+
+/*
+ * Subtle: (1 << PAGE_SHIFT) is an int, not an unsigned long. So if we
+ * assign PAGE_MASK to a larger type it gets extended the way we want
+ * (i.e. with 1s in the high bits)
+ */
+#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
 
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr)        ALIGN(addr, PAGE_SIZE)
+
+#endif /* CONFIG_ARCH_GENERIC_PAGE_SIZE */
+
+#ifndef __ASSEMBLY__
 #ifndef CONFIG_ARCH_HAVE_GET_ORDER
 /* Pure 2^n version of get_order */
 static __inline__ __attribute_const__ int get_order(unsigned long size)
@@ -22,7 +47,7 @@ static __inline__ __attribute_const__ in
 }
 
 #endif	/* CONFIG_ARCH_HAVE_GET_ORDER */
-#endif /*  __ASSEMBLY__ */
+#endif  /* __ASSEMBLY__ */
 #endif	/* __KERNEL__ */
 
 #endif	/* _ASM_GENERIC_PAGE_H */
diff -puN mm/Kconfig~generic-PAGE_SIZE-infrastructure mm/Kconfig
--- threadalloc/mm/Kconfig~generic-PAGE_SIZE-infrastructure	2006-08-29 13:14:50.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-29 13:14:51.000000000 -0700
@@ -2,6 +2,47 @@ config ARCH_HAVE_GET_ORDER
 	def_bool y
 	depends on IA64 || PPC32 || XTENSA
 
+choice
+	prompt "Kernel Page Size"
+	depends on ARCH_GENERIC_PAGE_SIZE
+config PAGE_SIZE_4KB
+	bool "4KB"
+	help
+	  This lets you select the page size of the kernel.  For best
+	  performance, a page size of larger than 4k is recommended.  For best
+	  32-bit compatibility on 64-bit architectures, a page size of 4KB
+	  should be selected (although most binaries work perfectly fine with
+	  a larger page size).
+
+	  4KB                For best 32-bit compatibility
+	  8KB-64KB           Better performace
+	  above 64KB	     For kernel hackers only
+
+	  If you don't know what to do, choose 4KB, or simply leave this
+	  option alone.  A sane default has already been selected for your
+	  architecture.
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
