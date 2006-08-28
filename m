Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SFiHIq031697
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:44:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SFiIWu296220
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:44:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SFiIwD005309
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:44:18 -0400
Subject: [RFC][PATCH 6/7] powerpc generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 28 Aug 2006 08:44:16 -0700
References: <20060828154413.E05721BD@localhost.localdomain>
In-Reply-To: <20060828154413.E05721BD@localhost.localdomain>
Message-Id: <20060828154416.09E64946@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is the powerpc portion to convert it over to the generic PAGE_SIZE
framework.

* add powerpc default of 64k pages to mm/Kconfig, when the 64k
  option is enabled.  Defaults to 4k otherwise.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-powerpc/page.h |   34 ++--------------------------
 threadalloc-dave/include/asm-ppc/page.h     |   22 ------------------
 threadalloc-dave/arch/powerpc/Kconfig       |    5 +++-
 threadalloc-dave/arch/powerpc/boot/page.h   |   22 ------------------
 threadalloc-dave/mm/Kconfig                 |    2 -
 5 files changed, 10 insertions(+), 75 deletions(-)

diff -puN include/asm-powerpc/page.h~powerpc include/asm-powerpc/page.h
--- threadalloc/include/asm-powerpc/page.h~powerpc	2006-08-25 11:34:21.000000000 -0700
+++ threadalloc-dave/include/asm-powerpc/page.h	2006-08-25 11:34:26.000000000 -0700
@@ -10,32 +10,14 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <asm-generic/page.h>
+
 #ifdef __KERNEL__
 #include <asm/asm-compat.h>
 #include <asm/kdump.h>
 
-/*
- * On PPC32 page size is 4K. For PPC64 we support either 4K or 64K software
- * page size. When using 64K pages however, whether we are really supporting
- * 64K pages in HW or not is irrelevant to those definitions.
- */
-#ifdef CONFIG_PPC_64K_PAGES
-#define PAGE_SHIFT		16
-#else
-#define PAGE_SHIFT		12
-#endif
-
-#define PAGE_SIZE		(ASM_CONST(1) << PAGE_SHIFT)
-
 /* We do define AT_SYSINFO_EHDR but don't use the gate mechanism */
-#define __HAVE_ARCH_GATE_AREA		1
-
-/*
- * Subtle: (1 << PAGE_SHIFT) is an int, not an unsigned long. So if we
- * assign PAGE_MASK to a larger type it gets extended the way we want
- * (i.e. with 1s in the high bits)
- */
-#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
+#define __HAVE_ARCH_GATE_AREA          1
 
 /*
  * KERNELBASE is the virtual address of the start of the kernel, it's often
@@ -89,16 +71,6 @@
 #include <asm/page_32.h>
 #endif
 
-/* align addr on a size boundary - adjust address up/down if needed */
-#define _ALIGN_UP(addr,size)	(((addr)+((size)-1))&(~((size)-1)))
-#define _ALIGN_DOWN(addr,size)	((addr)&(~((size)-1)))
-
-/* align addr on a size boundary - adjust address up if needed */
-#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
-
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 /*
  * Don't compare things with KERNELBASE or PAGE_OFFSET to test for
  * "kernelness", use is_kernel_addr() - it should do what you want.
diff -puN include/asm-ppc/page.h~powerpc include/asm-ppc/page.h
--- threadalloc/include/asm-ppc/page.h~powerpc	2006-08-25 11:34:21.000000000 -0700
+++ threadalloc-dave/include/asm-ppc/page.h	2006-08-25 11:34:26.000000000 -0700
@@ -2,16 +2,7 @@
 #define _PPC_PAGE_H
 
 #include <asm/asm-compat.h>
-
-/* PAGE_SHIFT determines the page size */
-#define PAGE_SHIFT	12
-#define PAGE_SIZE	(ASM_CONST(1) << PAGE_SHIFT)
-
-/*
- * Subtle: this is an int (not an unsigned long) and so it
- * gets extended to 64 bits the way want (i.e. with 1s).  -- paulus
- */
-#define PAGE_MASK	(~((1 << PAGE_SHIFT) - 1))
+#include <asm-generic/page.h>
 
 #ifdef __KERNEL__
 
@@ -36,17 +27,6 @@ typedef unsigned long pte_basic_t;
 #define PTE_FMT		"%.8lx"
 #endif
 
-/* align addr on a size boundary - adjust address up/down if needed */
-#define _ALIGN_UP(addr,size)	(((addr)+((size)-1))&(~((size)-1)))
-#define _ALIGN_DOWN(addr,size)	((addr)&(~((size)-1)))
-
-/* align addr on a size boundary - adjust address up if needed */
-#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
-
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
-
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff -puN arch/powerpc/Kconfig~powerpc arch/powerpc/Kconfig
--- threadalloc/arch/powerpc/Kconfig~powerpc	2006-08-25 11:34:21.000000000 -0700
+++ threadalloc-dave/arch/powerpc/Kconfig	2006-08-25 11:34:26.000000000 -0700
@@ -725,8 +725,11 @@ config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
 
+config ARCH_GENERIC_PAGE_SIZE
+	def_bool y
+
 config PPC_64K_PAGES
-	bool "64k page size"
+	bool "enable 64k page size"
 	depends on PPC64
 	help
 	  This option changes the kernel logical page size to 64k. On machines
diff -puN arch/powerpc/boot/page.h~powerpc arch/powerpc/boot/page.h
--- threadalloc/arch/powerpc/boot/page.h~powerpc	2006-08-25 11:34:21.000000000 -0700
+++ threadalloc-dave/arch/powerpc/boot/page.h	2006-08-25 11:34:26.000000000 -0700
@@ -9,26 +9,6 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifdef __ASSEMBLY__
-#define ASM_CONST(x) x
-#else
-#define __ASM_CONST(x) x##UL
-#define ASM_CONST(x) __ASM_CONST(x)
-#endif
-
-/* PAGE_SHIFT determines the page size */
-#define PAGE_SHIFT	12
-#define PAGE_SIZE	(ASM_CONST(1) << PAGE_SHIFT)
-#define PAGE_MASK	(~(PAGE_SIZE-1))
-
-/* align addr on a size boundary - adjust address up/down if needed */
-#define _ALIGN_UP(addr,size)	(((addr)+((size)-1))&(~((size)-1)))
-#define _ALIGN_DOWN(addr,size)	((addr)&(~((size)-1)))
-
-/* align addr on a size boundary - adjust address up if needed */
-#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
-
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
+#include <asm-generic/page.h>
 
 #endif				/* _PPC_BOOT_PAGE_H */
diff -puN mm/Kconfig~powerpc mm/Kconfig
--- threadalloc/mm/Kconfig~powerpc	2006-08-25 11:34:25.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-25 11:34:26.000000000 -0700
@@ -48,7 +48,7 @@ config PAGE_SHIFT
 	depends on ARCH_GENERIC_PAGE_SIZE
 	default "13" if PAGE_SIZE_8KB
 	default "14" if PAGE_SIZE_16KB
-	default "16" if PAGE_SIZE_64KB
+	default "16" if PAGE_SIZE_64KB || PPC_64K_PAGES
 	default "19" if PAGE_SIZE_512KB
 	default "22" if PAGE_SIZE_4MB
 	default "12"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
