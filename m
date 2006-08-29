Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJecj020566
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJe5Q290034
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJeke020924
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:40 -0400
Subject: [RFC][PATCH 06/10] sparc64 generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:38 -0700
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
Message-Id: <20060829201938.8E1B700A@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is the sparc64 portion to convert it over to the generic PAGE_SIZE
framework.

* Change all references to CONFIG_SPARC64_PAGE_SIZE_*KB to
  CONFIG_PAGE_SIZE_* and update the defconfig.
* remove sparc64-specific Kconfig menu
* add sparc64 default of 8k pages to mm/Kconfig
* remove generic support for 4k pages
* add support for 8k, 64k, 512k, and 4MB pages

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-sparc64/page.h |   19 ----------------
 threadalloc-dave/include/asm-sparc64/mmu.h  |    8 +++----
 threadalloc-dave/arch/sparc64/Kconfig       |   32 +++-------------------------
 threadalloc-dave/arch/sparc64/defconfig     |    8 +++----
 threadalloc-dave/arch/sparc64/mm/tsb.c      |    8 +++----
 threadalloc-dave/mm/Kconfig                 |    8 +++++--
 6 files changed, 23 insertions(+), 60 deletions(-)

diff -puN include/asm-sparc64/page.h~sparc64 include/asm-sparc64/page.h
--- threadalloc/include/asm-sparc64/page.h~sparc64	2006-08-29 13:14:48.000000000 -0700
+++ threadalloc-dave/include/asm-sparc64/page.h	2006-08-29 13:14:54.000000000 -0700
@@ -4,21 +4,7 @@
 #define _SPARC64_PAGE_H
 
 #include <asm/const.h>
-
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
-#define PAGE_SHIFT   13
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
-#define PAGE_SHIFT   16
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_512KB)
-#define PAGE_SHIFT   19
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_4MB)
-#define PAGE_SHIFT   22
-#else
-#error No page size specified in kernel configuration
-#endif
-
-#define PAGE_SIZE    (_AC(1,UL) << PAGE_SHIFT)
-#define PAGE_MASK    (~(PAGE_SIZE-1))
+#include <asm-generic/page.h>
 
 /* Flushing for D-cache alias handling is only needed if
  * the page size is smaller than 16K.
@@ -114,9 +100,6 @@ typedef unsigned long pgprot_t;
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 /* We used to stick this into a hard-coded global register (%g4)
  * but that does not make sense anymore.
  */
diff -puN include/asm-sparc64/mmu.h~sparc64 include/asm-sparc64/mmu.h
--- threadalloc/include/asm-sparc64/mmu.h~sparc64	2006-08-29 13:14:48.000000000 -0700
+++ threadalloc-dave/include/asm-sparc64/mmu.h	2006-08-29 13:14:54.000000000 -0700
@@ -30,13 +30,13 @@
 #define CTX_PGSZ_MASK		((CTX_PGSZ_BITS << CTX_PGSZ0_SHIFT) | \
 				 (CTX_PGSZ_BITS << CTX_PGSZ1_SHIFT))
 
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
+#if defined(CONFIG_PAGE_SIZE_8KB)
 #define CTX_PGSZ_BASE	CTX_PGSZ_8KB
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
+#elif defined(CONFIG_PAGE_SIZE_64KB)
 #define CTX_PGSZ_BASE	CTX_PGSZ_64KB
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_512KB)
+#elif defined(CONFIG_PAGE_SIZE_512KB)
 #define CTX_PGSZ_BASE	CTX_PGSZ_512KB
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_4MB)
+#elif defined(CONFIG_PAGE_SIZE_4MB)
 #define CTX_PGSZ_BASE	CTX_PGSZ_4MB
 #else
 #error No page size specified in kernel configuration
diff -puN arch/sparc64/Kconfig~sparc64 arch/sparc64/Kconfig
--- threadalloc/arch/sparc64/Kconfig~sparc64	2006-08-29 13:14:48.000000000 -0700
+++ threadalloc-dave/arch/sparc64/Kconfig	2006-08-29 13:14:54.000000000 -0700
@@ -34,32 +34,8 @@ config ARCH_MAY_HAVE_PC_FDC
 	bool
 	default y
 
-choice
-	prompt "Kernel page size"
-	default SPARC64_PAGE_SIZE_8KB
-
-config SPARC64_PAGE_SIZE_8KB
-	bool "8KB"
-	help
-	  This lets you select the page size of the kernel.
-
-	  8KB and 64KB work quite well, since Sparc ELF sections
-	  provide for up to 64KB alignment.
-
-	  Therefore, 512KB and 4MB are for expert hackers only.
-
-	  If you don't know what to do, choose 8KB.
-
-config SPARC64_PAGE_SIZE_64KB
-	bool "64KB"
-
-config SPARC64_PAGE_SIZE_512KB
-	bool "512KB"
-
-config SPARC64_PAGE_SIZE_4MB
-	bool "4MB"
-
-endchoice
+config ARCH_GENERIC_PAGE_SIZE
+	def_bool y
 
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
@@ -187,11 +163,11 @@ config HUGETLB_PAGE_SIZE_4MB
 	bool "4MB"
 
 config HUGETLB_PAGE_SIZE_512K
-	depends on !SPARC64_PAGE_SIZE_4MB && !SPARC64_PAGE_SIZE_512KB
+	depends on !PAGE_SIZE_4MB && !PAGE_SIZE_512KB
 	bool "512K"
 
 config HUGETLB_PAGE_SIZE_64K
-	depends on !SPARC64_PAGE_SIZE_4MB && !SPARC64_PAGE_SIZE_512KB && !SPARC64_PAGE_SIZE_64KB
+	depends on !PAGE_SIZE_4MB && !PAGE_SIZE_512KB && !PAGE_SIZE_64KB
 	bool "64K"
 
 endchoice
diff -puN arch/sparc64/defconfig~sparc64 arch/sparc64/defconfig
--- threadalloc/arch/sparc64/defconfig~sparc64	2006-08-29 13:14:48.000000000 -0700
+++ threadalloc-dave/arch/sparc64/defconfig	2006-08-29 13:14:54.000000000 -0700
@@ -9,10 +9,10 @@ CONFIG_64BIT=y
 CONFIG_MMU=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_ARCH_MAY_HAVE_PC_FDC=y
-CONFIG_SPARC64_PAGE_SIZE_8KB=y
-# CONFIG_SPARC64_PAGE_SIZE_64KB is not set
-# CONFIG_SPARC64_PAGE_SIZE_512KB is not set
-# CONFIG_SPARC64_PAGE_SIZE_4MB is not set
+CONFIG_PAGE_SIZE_8KB=y
+# CONFIG_PAGE_SIZE_64KB is not set
+# CONFIG_PAGE_SIZE_512KB is not set
+# CONFIG_PAGE_SIZE_4MB is not set
 CONFIG_SECCOMP=y
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
diff -puN arch/sparc64/mm/tsb.c~sparc64 arch/sparc64/mm/tsb.c
--- threadalloc/arch/sparc64/mm/tsb.c~sparc64	2006-08-29 13:14:48.000000000 -0700
+++ threadalloc-dave/arch/sparc64/mm/tsb.c	2006-08-29 13:14:54.000000000 -0700
@@ -90,16 +90,16 @@ void flush_tsb_user(struct mmu_gather *m
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
 
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
+#if defined(CONFIG_PAGE_SIZE_8KB)
 #define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_8K
 #define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_8K
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
+#elif defined(CONFIG_PAGE_SIZE_64KB)
 #define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_64K
 #define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_64K
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_512KB)
+#elif defined(CONFIG_PAGE_SIZE_512KB)
 #define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_512K
 #define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_512K
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_4MB)
+#elif defined(CONFIG_PAGE_SIZE_4MB)
 #define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_4MB
 #define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_4MB
 #else
diff -puN mm/Kconfig~sparc64 mm/Kconfig
--- threadalloc/mm/Kconfig~sparc64	2006-08-29 13:14:53.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-29 13:14:54.000000000 -0700
@@ -5,9 +5,11 @@ config ARCH_HAVE_GET_ORDER
 choice
 	prompt "Kernel Page Size"
 	depends on ARCH_GENERIC_PAGE_SIZE
+	default PAGE_SIZE_8KB if SPARC64
 	default PAGE_SIZE_16KB if IA64
 config PAGE_SIZE_4KB
 	bool "4KB"
+	depends on !SPARC64
 	help
 	  This lets you select the page size of the kernel.  For best
 	  performance, a page size of larger than 4k is recommended.  For best
@@ -24,17 +26,19 @@ config PAGE_SIZE_4KB
 	  architecture.
 config PAGE_SIZE_8KB
 	bool "8KB"
-	depends on IA64
+	depends on IA64 || SPARC64
 config PAGE_SIZE_16KB
 	bool "16KB"
 	depends on IA64
 config PAGE_SIZE_64KB
 	bool "64KB"
-	depends on (IA64 && !ITANIUM)
+	depends on (IA64 && !ITANIUM) || SPARC64
 config PAGE_SIZE_512KB
 	bool "512KB"
+	depends on SPARC64
 config PAGE_SIZE_4MB
 	bool "4MB"
+	depends on SPARC64
 endchoice
 
 config PAGE_SHIFT
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
