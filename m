Received: from northrelay03.pok.ibm.com (northrelay03.pok.ibm.com [9.56.224.151])
	by e4.ny.us.ibm.com (8.12.7/8.12.2) with ESMTP id h1Q1n53r074502
	for <linux-mm@kvack.org>; Tue, 25 Feb 2003 20:49:05 -0500
Received: from nighthawk.sr71.net (dyn9-47-17-248.beaverton.ibm.com [9.47.17.248])
	by northrelay03.pok.ibm.com (8.12.3/NCO/VER6.5) with ESMTP id h1Q1n20r070100
	for <linux-mm@kvack.org>; Tue, 25 Feb 2003 20:49:02 -0500
Received: from us.ibm.com (dave@nighthawk [127.0.0.1])
	by nighthawk.sr71.net (8.12.3/8.12.3/Debian -4) with ESMTP id h1Q1lsiV003780
	for <linux-mm@kvack.org>; Tue, 25 Feb 2003 17:47:58 -0800
Message-ID: <3E5C1CC9.1010403@us.ibm.com>
Date: Tue, 25 Feb 2003 17:47:53 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC] move around pgtable headers
Content-Type: multipart/mixed;
 boundary="------------090309090605020406030809"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090309090605020406030809
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I was screwing around with changing some macros in pgtable-3level.h into
static inlines and I quickly ran into some dependency problems.  Mainly,
pgtable-3level.h was included from pgtable.h before __pmd_offset() was
defined, and I wanted to use __pmd_offset() in a function instead of a
macro.

Anyway I have some _really_ rough demonstration of what I would like to
do in the attached patch.  What I want to see is some more explicit
definitions of what the dependencies are in the various header files.
Is this anything that people would like to see expanded?

I haven't even gotten close to moving all of the macros into the ops.h
file, but you can probably get the idea.

 page.h                 |   26 ------------------------
 pgtable-2level.h       |   19 +++--------------
 pgtable-3level.h       |   53 +++++++++++++++++++----------------------
 pgtable.h              |    3 --
 pgtable/const-2level.h |   17 +++++++++++++++
 pgtable/const-3level.h |   25 +++++++++++++++++++++++
 pgtable/const.h        |   12 +++++++++++
 pgtable/ops.h          |   17 +++++++++++++++
 pgtable/types-2level.h |   10 +++++++++
 pgtable/types-3level.h |   10 +++++++++
 pgtable/types.h        |   12 +++++++++++
 13 files changed, 132 insertions(+), 72 deletions(-)

-- 
Dave Hansen
haveblue@us.ibm.com

--------------090309090605020406030809
Content-Type: text/plain;
 name="pgtable-moves.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pgtable-moves.patch"

Binary files linux-2.5.62-clean/include/asm-i386/.page.h.swp and linux-2.5.62-vm_names/include/asm-i386/.page.h.swp differ
Binary files linux-2.5.62-clean/include/asm-i386/.pgtable-3level.h.swp and linux-2.5.62-vm_names/include/asm-i386/.pgtable-3level.h.swp differ
diff -urN linux-2.5.62-clean/include/asm-i386/page.h linux-2.5.62-vm_names/include/asm-i386/page.h
--- linux-2.5.62-clean/include/asm-i386/page.h	Mon Feb 17 14:55:57 2003
+++ linux-2.5.62-vm_names/include/asm-i386/page.h	Tue Feb 25 17:18:40 2003
@@ -13,6 +13,7 @@
 #ifndef __ASSEMBLY__
 
 #include <linux/config.h>
+#include <asm/pgtable/types.h>
 
 #ifdef CONFIG_X86_USE_3DNOW
 
@@ -36,22 +37,6 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-/*
- * These are used to make use of C type-checking..
- */
-#ifdef CONFIG_X86_PAE
-typedef struct { unsigned long pte_low, pte_high; } pte_t;
-typedef struct { unsigned long long pmd; } pmd_t;
-typedef struct { unsigned long long pgd; } pgd_t;
-#define pte_val(x)	((x).pte_low | ((unsigned long long)(x).pte_high << 32))
-#define HPAGE_SHIFT	21
-#else
-typedef struct { unsigned long pte_low; } pte_t;
-typedef struct { unsigned long pmd; } pmd_t;
-typedef struct { unsigned long pgd; } pgd_t;
-#define pte_val(x)	((x).pte_low)
-#define HPAGE_SHIFT	22
-#endif
 #define PTE_MASK	PAGE_MASK
 
 #ifdef CONFIG_HUGETLB_PAGE
@@ -61,15 +46,6 @@
 #endif
 
 typedef struct { unsigned long pgprot; } pgprot_t;
-
-#define pmd_val(x)	((x).pmd)
-#define pgd_val(x)	((x).pgd)
-#define pgprot_val(x)	((x).pgprot)
-
-#define __pte(x) ((pte_t) { (x) } )
-#define __pmd(x) ((pmd_t) { (x) } )
-#define __pgd(x) ((pgd_t) { (x) } )
-#define __pgprot(x)	((pgprot_t) { (x) } )
 
 #endif /* !__ASSEMBLY__ */
 
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/const-2level.h linux-2.5.62-vm_names/include/asm-i386/pgtable/const-2level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/const-2level.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/const-2level.h	Tue Feb 25 15:16:16 2003
@@ -0,0 +1,17 @@
+
+/*
+ * traditional i386 two-level paging structure:
+ */
+
+#define PGDIR_SHIFT	22
+#define PTRS_PER_PGD	1024
+
+/*
+ * the i386 is two-level, so we don't really have any
+ * PMD directory physically.
+ */
+#define PMD_SHIFT	22
+#define PTRS_PER_PMD	1
+
+#define PTRS_PER_PTE	1024
+
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/const-3level.h linux-2.5.62-vm_names/include/asm-i386/pgtable/const-3level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/const-3level.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/const-3level.h	Tue Feb 25 15:14:02 2003
@@ -0,0 +1,25 @@
+/*
+ * Intel Physical Address Extension (PAE) Mode - three-level page
+ * tables on PPro+ CPUs.
+ *
+ * Copyright (C) 1999 Ingo Molnar <mingo@redhat.com> 
+ */
+ 
+/*
+ * PGDIR_SHIFT determines what a top-level page table entry can map
+ */
+#define PGDIR_SHIFT     30 
+#define PTRS_PER_PGD    4
+
+/*
+ * PMD_SHIFT determines the size of the area a middle-level
+ * page table can map
+ */
+#define PMD_SHIFT       21
+#define PTRS_PER_PMD    512
+
+/*
+ * entries per page directory level
+ */
+#define PTRS_PER_PTE    512
+
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/const.h linux-2.5.62-vm_names/include/asm-i386/pgtable/const.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/const.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/const.h	Tue Feb 25 17:24:29 2003
@@ -0,0 +1,12 @@
+#ifndef _I386_PGTABLE_CONST_H_
+#define _I386_PGTABLE_CONST_H_
+
+#include <linux/config.h>
+
+#ifdef CONFIG_X86_PAE
+ #include <asm/pgtable/const-3level.h>
+#else
+ #include <asm/pgtable/const-2level.h>
+#endif
+
+#endif
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/ops.h linux-2.5.62-vm_names/include/asm-i386/pgtable/ops.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/ops.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/ops.h	Tue Feb 25 17:28:40 2003
@@ -0,0 +1,17 @@
+#ifndef __I386_PGTABLE_OPS_H_
+#define __I386_PGTABLE_OPS_H_
+
+#define pmd_val(x)      ((x).pmd)
+#define pgd_val(x)      ((x).pgd)
+#define pgprot_val(x)   ((x).pgprot)
+
+#define __pte(x) ((pte_t) { (x) } )
+#define __pmd(x) ((pmd_t) { (x) } )
+#define __pgd(x) ((pgd_t) { (x) } )
+#define __pgprot(x)     ((pgprot_t) { (x) } )
+
+
+#define __pmd_offset(address) \
+		(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
+
+#endif
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/types-2level.h linux-2.5.62-vm_names/include/asm-i386/pgtable/types-2level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/types-2level.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/types-2level.h	Tue Feb 25 15:23:03 2003
@@ -0,0 +1,10 @@
+#ifndef _I386_PGTABLE_TYPES_2LEVEL_H_
+#define _I386_PGTABLE_TYPES_2LEVEL_H_
+
+typedef struct { unsigned long pte_low; } pte_t;
+typedef struct { unsigned long pmd; } pmd_t;
+typedef struct { unsigned long pgd; } pgd_t;
+#define pte_val(x)	((x).pte_low)
+#define HPAGE_SHIFT	22
+
+#endif
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/types-3level.h linux-2.5.62-vm_names/include/asm-i386/pgtable/types-3level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/types-3level.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/types-3level.h	Tue Feb 25 15:23:21 2003
@@ -0,0 +1,10 @@
+#ifndef _I386_PGTABLE_TYPES_3LEVEL_H_
+#define _I386_PGTABLE_TYPES_3LEVEL_H_
+
+typedef struct { unsigned long pte_low, pte_high; } pte_t;
+typedef struct { unsigned long long pmd; } pmd_t;
+typedef struct { unsigned long long pgd; } pgd_t;
+#define pte_val(x)	((x).pte_low | ((unsigned long long)(x).pte_high << 32))
+#define HPAGE_SHIFT	21
+
+#endif
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable/types.h linux-2.5.62-vm_names/include/asm-i386/pgtable/types.h
--- linux-2.5.62-clean/include/asm-i386/pgtable/types.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable/types.h	Tue Feb 25 17:20:19 2003
@@ -0,0 +1,12 @@
+#ifndef _I386_PGTABLE_TYPES_H_
+#define _I386_PGTABLE_TYPES_H_
+
+#include <linux/config.h>
+
+#ifdef CONFIG_X86_PAE
+ #include <asm/pgtable/types-3level.h>
+#else
+ #include <asm/pgtable/types-2level.h>
+#endif
+
+#endif
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable-2level.h linux-2.5.62-vm_names/include/asm-i386/pgtable-2level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable-2level.h	Mon Feb 17 14:56:16 2003
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable-2level.h	Tue Feb 25 17:27:42 2003
@@ -1,21 +1,10 @@
 #ifndef _I386_PGTABLE_2LEVEL_H
 #define _I386_PGTABLE_2LEVEL_H
 
-/*
- * traditional i386 two-level paging structure:
- */
-
-#define PGDIR_SHIFT	22
-#define PTRS_PER_PGD	1024
-
-/*
- * the i386 is two-level, so we don't really have any
- * PMD directory physically.
- */
-#define PMD_SHIFT	22
-#define PTRS_PER_PMD	1
-
-#define PTRS_PER_PTE	1024
+/* these are order-dependent right now */
+#include <asm/pgtable/types.h>
+#include <asm/pgtable/const.h>
+#include <asm/pgtable/ops.h>
 
 #define pte_ERROR(e) \
 	printk("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, (e).pte_low)
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable-3level.h linux-2.5.62-vm_names/include/asm-i386/pgtable-3level.h
--- linux-2.5.62-clean/include/asm-i386/pgtable-3level.h	Mon Feb 17 14:56:48 2003
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable-3level.h	Tue Feb 25 17:29:33 2003
@@ -1,30 +1,10 @@
 #ifndef _I386_PGTABLE_3LEVEL_H
 #define _I386_PGTABLE_3LEVEL_H
 
-/*
- * Intel Physical Address Extension (PAE) Mode - three-level page
- * tables on PPro+ CPUs.
- *
- * Copyright (C) 1999 Ingo Molnar <mingo@redhat.com>
- */
-
-/*
- * PGDIR_SHIFT determines what a top-level page table entry can map
- */
-#define PGDIR_SHIFT	30
-#define PTRS_PER_PGD	4
-
-/*
- * PMD_SHIFT determines the size of the area a middle-level
- * page table can map
- */
-#define PMD_SHIFT	21
-#define PTRS_PER_PMD	512
-
-/*
- * entries per page directory level
- */
-#define PTRS_PER_PTE	512
+/* these are order-dependent right now, careful */ 
+#include <asm/pgtable/types-3level.h>
+#include <asm/pgtable/const-3level.h>
+#include <asm/pgtable/ops.h> /* for __pmd_offset */
 
 #define pte_ERROR(e) \
 	printk("%s:%d: bad pte %p(%08lx%08lx).\n", __FILE__, __LINE__, &(e), (e).pte_high, (e).pte_low)
@@ -64,12 +44,27 @@
  */
 static inline void pgd_clear (pgd_t * pgd) { }
 
-#define pgd_page(pgd) \
-((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
+/* 
+ * the __va() will only work on lowmem addresses, so this 
+ * assumes that the PMD pages (the things pointed to by PGD
+ * entries) are in lowmem.
+ */
+static inline pmd_t *pgd_entry_to_pmd_page(pgd_t *pgd)
+{
+	/* the '&' strips out the flags from the PGD entry */
+	void * pmd_vaddr = __va(pgd_val(*pgd) & PAGE_MASK);
+	return (pmd_t *)pmd_vaddr;
+}
+
+#define pmd_offset(dir,address) pgd_entry_to_pmd_entry(dir,address)
 
-/* Find an entry in the second-level page table.. */
-#define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
-			__pmd_offset(address))
+/* Find a single entry in the second-level page table.. */
+static inline pmd_t *pgd_entry_to_pmd_entry(pgd_t *pgd_entry, 
+					    unsigned long address) 
+{
+	pmd_t *pmd_page = pgd_entry_to_pmd_page(pgd_entry);
+	return &pmd_page[__pmd_offset(address)];
+}
 
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
diff -urN linux-2.5.62-clean/include/asm-i386/pgtable.h linux-2.5.62-vm_names/include/asm-i386/pgtable.h
--- linux-2.5.62-clean/include/asm-i386/pgtable.h	Mon Feb 17 14:56:43 2003
+++ linux-2.5.62-vm_names/include/asm-i386/pgtable.h	Tue Feb 25 15:17:52 2003
@@ -242,9 +242,6 @@
 /* to find an entry in a kernel page-table-directory */
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
-#define __pmd_offset(address) \
-		(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
-
 /* Find an entry in the third-level page table.. */
 #define __pte_offset(address) \
 		(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))

--------------090309090605020406030809--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
