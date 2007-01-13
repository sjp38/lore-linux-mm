From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:25 +1100
Message-Id: <20070113024825.29682.27750.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 2/5] Abstract pgtable
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH IA64 02
 * Create file page-default.h and move implementation dependent code from
 page.h into it.
 * Create pgtable-default.h and put implementation dependent code from
 pgtable.h into it.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 page-default.h    |   38 +++++++++++++++++++++++++++++++++++++
 page.h            |   20 ++++---------------
 pgtable-default.h |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 pgtable.h         |   55 +++++-------------------------------------------------
 4 files changed, 103 insertions(+), 64 deletions(-)
Index: linux-2.6.20-rc1/include/asm-ia64/page-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/page-default.h	2006-12-23 20:24:57.787909000 +1100
@@ -0,0 +1,38 @@
+#ifndef _ASM_IA64_PAGE_DEFAULT_H
+#define _ASM_IA64_PAGE_DEFAULT_H
+
+#ifdef __KERNEL__
+
+#ifdef STRICT_MM_TYPECHECKS
+  /*
+   * These are used to make use of C type-checking..
+   */
+  typedef struct { unsigned long pmd; } pmd_t;
+#ifdef CONFIG_PGTABLE_4
+  typedef struct { unsigned long pud; } pud_t;
+#endif
+  typedef struct { unsigned long pgd; } pgd_t;
+
+# define pmd_val(x)	((x).pmd)
+#ifdef CONFIG_PGTABLE_4
+# define pud_val(x)	((x).pud)
+#endif
+# define pgd_val(x)	((x).pgd)
+
+#else /* !STRICT_MM_TYPECHECKS */
+  /*
+   * .. while these make it easier on the compiler
+   */
+# ifndef __ASSEMBLY__
+    typedef unsigned long pmd_t;
+    typedef unsigned long pgd_t;
+# endif
+
+# define pmd_val(x)	(x)
+# define pgd_val(x)	(x)
+
+# define __pgd(x)	(x)
+#endif /* !STRICT_MM_TYPECHECKS */
+
+#endif /* __KERNEL__ */
+#endif /* _ASM_IA64_PAGE_DEFAULT_H */
Index: linux-2.6.20-rc1/include/asm-ia64/page.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/page.h	2006-12-23 20:24:51.003909000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/page.h	2006-12-23 20:25:39.879909000 +1100
@@ -180,19 +180,9 @@
    * These are used to make use of C type-checking..
    */
   typedef struct { unsigned long pte; } pte_t;
-  typedef struct { unsigned long pmd; } pmd_t;
-#ifdef CONFIG_PGTABLE_4
-  typedef struct { unsigned long pud; } pud_t;
-#endif
-  typedef struct { unsigned long pgd; } pgd_t;
   typedef struct { unsigned long pgprot; } pgprot_t;
 
 # define pte_val(x)	((x).pte)
-# define pmd_val(x)	((x).pmd)
-#ifdef CONFIG_PGTABLE_4
-# define pud_val(x)	((x).pud)
-#endif
-# define pgd_val(x)	((x).pgd)
 # define pgprot_val(x)	((x).pgprot)
 
 # define __pte(x)	((pte_t) { (x) } )
@@ -204,18 +194,13 @@
    */
 # ifndef __ASSEMBLY__
     typedef unsigned long pte_t;
-    typedef unsigned long pmd_t;
-    typedef unsigned long pgd_t;
     typedef unsigned long pgprot_t;
 # endif
 
 # define pte_val(x)	(x)
-# define pmd_val(x)	(x)
-# define pgd_val(x)	(x)
 # define pgprot_val(x)	(x)
 
 # define __pte(x)	(x)
-# define __pgd(x)	(x)
 # define __pgprot(x)	(x)
 #endif /* !STRICT_MM_TYPECHECKS */
 
@@ -227,4 +212,9 @@
 					  ? VM_EXEC : 0))
 
 # endif /* __KERNEL__ */
+
+#ifdef CONFIG_PT_DEFAULT
+#include <asm/page-default.h>
+#endif
+
 #endif /* _ASM_IA64_PAGE_H */
Index: linux-2.6.20-rc1/include/asm-ia64/pgtable-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pgtable-default.h	2006-12-23 20:24:57.791909000 +1100
@@ -0,0 +1,54 @@
+#ifndef _ASM_IA64_PGTABLE_DEFAULT_H
+#define _ASM_IA64_PGTABLE_DEFAULT_H
+
+/*
+ * How many pointers will a page table level hold expressed in shift
+ */
+#define PTRS_PER_PTD_SHIFT	(PAGE_SHIFT-3)
+
+/*
+ * Definitions for fourth level:
+ */
+#define PTRS_PER_PTE	(__IA64_UL(1) << (PTRS_PER_PTD_SHIFT))
+
+/*
+ * Definitions for third level:
+ *
+ * PMD_SHIFT determines the size of the area a third-level page table
+ * can map.
+ */
+#define PMD_SHIFT	(PAGE_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PMD_SIZE	(1UL << PMD_SHIFT)
+#define PMD_MASK	(~(PMD_SIZE-1))
+#define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
+
+#ifdef CONFIG_PGTABLE_4
+/*
+ * Definitions for second level:
+ *
+ * PUD_SHIFT determines the size of the area a second-level page table
+ * can map.
+ */
+#define PUD_SHIFT	(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+#define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
+
+#endif
+/*
+ * Definitions for first level:
+ *
+ * PGDIR_SHIFT determines what a first-level page table entry can map.
+ */
+#ifdef CONFIG_PGTABLE_4
+#define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#else
+#define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
+#endif
+#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
+#define PGDIR_MASK		(~(PGDIR_SIZE-1))
+#define PTRS_PER_PGD_SHIFT	PTRS_PER_PTD_SHIFT
+#define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
+#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
+
+#endif
Index: linux-2.6.20-rc1/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pgtable.h	2006-12-23 20:24:51.003909000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pgtable.h	2006-12-23 20:26:16.243909000 +1100
@@ -19,6 +19,10 @@
 #include <asm/system.h>
 #include <asm/types.h>
 
+#ifdef CONFIG_PT_DEFAULT
+#include <asm/pgtable-default.h>
+#endif
+
 #define IA64_MAX_PHYS_BITS	50	/* max. number of physical address bits (architected) */
 
 /*
@@ -82,55 +86,6 @@
 #define __DIRTY_BITS_NO_ED	_PAGE_A | _PAGE_P | _PAGE_D | _PAGE_MA_WB
 #define __DIRTY_BITS		_PAGE_ED | __DIRTY_BITS_NO_ED
 
-/*
- * How many pointers will a page table level hold expressed in shift
- */
-#define PTRS_PER_PTD_SHIFT	(PAGE_SHIFT-3)
-
-/*
- * Definitions for fourth level:
- */
-#define PTRS_PER_PTE	(__IA64_UL(1) << (PTRS_PER_PTD_SHIFT))
-
-/*
- * Definitions for third level:
- *
- * PMD_SHIFT determines the size of the area a third-level page table
- * can map.
- */
-#define PMD_SHIFT	(PAGE_SHIFT + (PTRS_PER_PTD_SHIFT))
-#define PMD_SIZE	(1UL << PMD_SHIFT)
-#define PMD_MASK	(~(PMD_SIZE-1))
-#define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
-
-#ifdef CONFIG_PGTABLE_4
-/*
- * Definitions for second level:
- *
- * PUD_SHIFT determines the size of the area a second-level page table
- * can map.
- */
-#define PUD_SHIFT	(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
-#define PUD_SIZE	(1UL << PUD_SHIFT)
-#define PUD_MASK	(~(PUD_SIZE-1))
-#define PTRS_PER_PUD	(1UL << (PTRS_PER_PTD_SHIFT))
-#endif
-
-/*
- * Definitions for first level:
- *
- * PGDIR_SHIFT determines what a first-level page table entry can map.
- */
-#ifdef CONFIG_PGTABLE_4
-#define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
-#else
-#define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
-#endif
-#define PGDIR_SIZE		(__IA64_UL(1) << PGDIR_SHIFT)
-#define PGDIR_MASK		(~(PGDIR_SIZE-1))
-#define PTRS_PER_PGD_SHIFT	PTRS_PER_PTD_SHIFT
-#define PTRS_PER_PGD		(1UL << PTRS_PER_PGD_SHIFT)
-#define USER_PTRS_PER_PGD	(5*PTRS_PER_PGD/8)	/* regions 0-4 are user regions */
 #define FIRST_USER_ADDRESS	0
 
 /*
@@ -595,9 +550,11 @@
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
+#ifdef CONFIG_PT_DEFAULT
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
 #endif
 #include <asm-generic/pgtable.h>
+#endif
 
 #endif /* _ASM_IA64_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
