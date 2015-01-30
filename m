Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 916F982925
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:44:07 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so53154471pad.8
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:44:07 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ub10si13831752pbc.203.2015.01.30.06.43.54
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/19] parisc: expose number of page table levels on Kconfig level
Date: Fri, 30 Jan 2015 16:43:19 +0200
Message-Id: <1422629008-13689-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
---
 arch/parisc/Kconfig               |  5 +++++
 arch/parisc/include/asm/pgalloc.h |  2 +-
 arch/parisc/include/asm/pgtable.h | 17 ++++++++---------
 arch/parisc/kernel/entry.S        |  4 ++--
 arch/parisc/kernel/head.S         |  4 ++--
 arch/parisc/mm/init.c             |  2 +-
 6 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 1554a6f2a5bb..1899d65b283c 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -103,6 +103,11 @@ config ARCH_MAY_HAVE_PC_FDC
 	depends on BROKEN
 	default y
 
+config PGTABLE_LEVELS
+	int
+	default 3 if 64BIT && PARISC_PAGE_SIZE_4KB
+	default 2
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index f213f5b4c423..55ad8be9b7f3 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -51,7 +51,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ALLOC_ORDER);
 }
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 
 /* Three Level Page Table Support for pmd's */
 
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index 8c966b2270aa..0a183756d6ec 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -68,13 +68,11 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 #define KERNEL_INITIAL_ORDER	24	/* 0 to 1<<24 = 16MB */
 #define KERNEL_INITIAL_SIZE	(1 << KERNEL_INITIAL_ORDER)
 
-#if defined(CONFIG_64BIT) && defined(CONFIG_PARISC_PAGE_SIZE_4KB)
-#define PT_NLEVELS	3
+#if CONFIG_PGTABLE_LEVELS == 3
 #define PGD_ORDER	1 /* Number of pages per pgd */
 #define PMD_ORDER	1 /* Number of pages per pmd */
 #define PGD_ALLOC_ORDER	2 /* first pgd contains pmd */
 #else
-#define PT_NLEVELS	2
 #define PGD_ORDER	1 /* Number of pages per pgd */
 #define PGD_ALLOC_ORDER	PGD_ORDER
 #endif
@@ -93,9 +91,10 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 #define PMD_SHIFT       (PLD_SHIFT + BITS_PER_PTE)
 #define PMD_SIZE	(1UL << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 #define BITS_PER_PMD	(PAGE_SHIFT + PMD_ORDER - BITS_PER_PMD_ENTRY)
 #else
+#define __PAGETABLE_PMD_FOLDED
 #define BITS_PER_PMD	0
 #endif
 #define PTRS_PER_PMD    (1UL << BITS_PER_PMD)
@@ -276,7 +275,7 @@ extern unsigned long *empty_zero_page;
 #define pgd_flag(x)	(pgd_val(x) & PxD_FLAG_MASK)
 #define pgd_address(x)	((unsigned long)(pgd_val(x) &~ PxD_FLAG_MASK) << PxD_VALUE_SHIFT)
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 /* The first entry of the permanent pmd is not there if it contains
  * the gateway marker */
 #define pmd_none(x)	(!pmd_val(x) || pmd_flag(x) == PxD_FLAG_ATTACHED)
@@ -286,7 +285,7 @@ extern unsigned long *empty_zero_page;
 #define pmd_bad(x)	(!(pmd_flag(x) & PxD_FLAG_VALID))
 #define pmd_present(x)	(pmd_flag(x) & PxD_FLAG_PRESENT)
 static inline void pmd_clear(pmd_t *pmd) {
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 	if (pmd_flag(*pmd) & PxD_FLAG_ATTACHED)
 		/* This is the entry pointing to the permanent pmd
 		 * attached to the pgd; cannot clear it */
@@ -298,7 +297,7 @@ static inline void pmd_clear(pmd_t *pmd) {
 
 
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 #define pgd_page_vaddr(pgd) ((unsigned long) __va(pgd_address(pgd)))
 #define pgd_page(pgd)	virt_to_page((void *)pgd_page_vaddr(pgd))
 
@@ -308,7 +307,7 @@ static inline void pmd_clear(pmd_t *pmd) {
 #define pgd_bad(x)      (!(pgd_flag(x) & PxD_FLAG_VALID))
 #define pgd_present(x)  (pgd_flag(x) & PxD_FLAG_PRESENT)
 static inline void pgd_clear(pgd_t *pgd) {
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 	if(pgd_flag(*pgd) & PxD_FLAG_ATTACHED)
 		/* This is the permanent pmd attached to the pgd; cannot
 		 * free it */
@@ -392,7 +391,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 
 /* Find an entry in the second-level page table.. */
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 #define pmd_offset(dir,address) \
 ((pmd_t *) pgd_page_vaddr(*(dir)) + (((address)>>PMD_SHIFT) & (PTRS_PER_PMD-1)))
 #else
diff --git a/arch/parisc/kernel/entry.S b/arch/parisc/kernel/entry.S
index e8f07dd28401..2cd5fb8798a8 100644
--- a/arch/parisc/kernel/entry.S
+++ b/arch/parisc/kernel/entry.S
@@ -398,7 +398,7 @@
 	 * can address up to 1TB
 	 */
 	.macro		L2_ptep	pmd,pte,index,va,fault
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 	extru		\va,31-ASM_PMD_SHIFT,ASM_BITS_PER_PMD,\index
 #else
 # if defined(CONFIG_64BIT)
@@ -436,7 +436,7 @@
 	 * all ILP32 processes and all the kernel for machines with
 	 * under 4GB of memory) */
 	.macro		L3_ptep pgd,pte,index,va,fault
-#if PT_NLEVELS == 3 /* we might have a 2-Level scheme, e.g. with 16kb page size */
+#if CONFIG_PGTABLE_LEVELS == 3 /* we might have a 2-Level scheme, e.g. with 16kb page size */
 	extrd,u		\va,63-ASM_PGDIR_SHIFT,ASM_BITS_PER_PGD,\index
 	copy		%r0,\pte
 	extrd,u,*=	\va,63-ASM_PGDIR_SHIFT,64-ASM_PGDIR_SHIFT,%r0
diff --git a/arch/parisc/kernel/head.S b/arch/parisc/kernel/head.S
index d4dc588c0dc1..e7d64527aff9 100644
--- a/arch/parisc/kernel/head.S
+++ b/arch/parisc/kernel/head.S
@@ -74,7 +74,7 @@ $bss_loop:
 	mtctl		%r4,%cr24	/* Initialize kernel root pointer */
 	mtctl		%r4,%cr25	/* Initialize user root pointer */
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 	/* Set pmd in pgd */
 	load32		PA(pmd0),%r5
 	shrd            %r5,PxD_VALUE_SHIFT,%r3	
@@ -97,7 +97,7 @@ $bss_loop:
 	stw		%r3,0(%r4)
 	ldo		(PAGE_SIZE >> PxD_VALUE_SHIFT)(%r3),%r3
 	addib,>		-1,%r1,1b
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 	ldo             ASM_PMD_ENTRY_SIZE(%r4),%r4
 #else
 	ldo             ASM_PGD_ENTRY_SIZE(%r4),%r4
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 0bef864264c0..849226b0f21e 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -34,7 +34,7 @@
 extern int  data_start;
 extern void parisc_kernel_start(void);	/* Kernel entry point in head.S */
 
-#if PT_NLEVELS == 3
+#if CONFIG_PGTABLE_LEVELS == 3
 /* NOTE: This layout exactly conforms to the hybrid L2/L3 page table layout
  * with the first pmd adjacent to the pgd and below it. gcc doesn't actually
  * guarantee that global objects will be laid out in memory in the same order
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
