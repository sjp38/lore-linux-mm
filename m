Message-Id: <200508310039.j7V0dIg00416@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch added to -mm tree
Date: Tue, 30 Aug 2005 17:38:37 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <200508292245.j7TMjcwk029212@shell0.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

akpm@osdl.org wrote on Monday, August 29, 2005 3:48 PM
> The patch titled
> 
>      hugetlb: move stale pte check into huge_pte_alloc()
> 
> has been added to the -mm tree.  Its filename is
> 
>      hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch
> 
> Patches currently in -mm which might be from agl@us.ibm.com are
> 
> hugetlb-add-pte_huge-macro.patch
> hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch
> hugetlb-check-pd_present-in-huge_pte_offset.patch

I don't think we need to call hugetlb_clean_stale_pgtable() anymore
in 2.6.13 because of the rework with free_pgtables().  It now collect
all the pte page at the time of munmap.  It used to only collect page
table pages when entire one pgd can be freed and left with staled pte
pages.  Not anymore with 2.6.13.  This function will never be called
and We should turn it into a BUG_ON.

I also spotted two problems here, not Adam's fault :-)
(1) in huge_pte_alloc(), it looks like a bug to me that pud is not
    checked before calling pmd_alloc()
(2) in hugetlb_clean_stale_pgtable(), it also missed a call to
    pmd_free_tlb.  I think a tlb flush is required to flush the mapping
    for the page table itself when we clear out the pmd pointing to a
    pte page.  However, since hugetlb_clean_stale_pgtable() is never
    called, so it won't trigger the bug.

Patch to remove hugetlb_clean_stale_pgtable() and fix huge_pte_alloc().
Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/i386/mm/hugetlbpage.c.orig	2005-08-30 17:24:09.691156277 -0700
+++ ./arch/i386/mm/hugetlbpage.c	2005-08-30 17:24:33.016351304 -0700
@@ -22,20 +22,14 @@ pte_t *huge_pte_alloc(struct mm_struct *
 {
 	pgd_t *pgd;
 	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
-	pmd = pmd_alloc(mm, pud, addr);
+	if (pud)
+		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
-	if (!pmd)
-		goto out;
-
-	pte = (pte_t *) pmd;
-	if (!pte_none(*pte) && !pte_huge(*pte))
-		hugetlb_clean_stale_pgtable(pte);
-out:
 	return pte;
 }
 
@@ -130,17 +124,6 @@ follow_huge_pmd(struct mm_struct *mm, un
 }
 #endif
 
-void hugetlb_clean_stale_pgtable(pte_t *pte)
-{
-	pmd_t *pmd = (pmd_t *) pte;
-	struct page *page;
-
-	page = pmd_page(*pmd);
-	pmd_clear(pmd);
-	dec_page_state(nr_page_table_pages);
-	page_cache_release(page);
-}
-
 /* x86_64 also uses this file */
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
--- ./include/asm-i386/page.h.orig	2005-08-30 17:24:43.008538682 -0700
+++ ./include/asm-i386/page.h	2005-08-30 17:24:48.427483928 -0700
@@ -68,7 +68,6 @@ typedef struct { unsigned long pgprot; }
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-#define ARCH_HAS_HUGETLB_CLEAN_STALE_PGTABLE
 #endif
 
 #define pgd_val(x)	((x).pgd)
--- ./include/asm-x86_64/page.h.orig	2005-08-30 17:24:57.657952565 -0700
+++ ./include/asm-x86_64/page.h	2005-08-30 17:25:03.637444679 -0700
@@ -28,7 +28,6 @@
 #define HPAGE_SIZE	((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
-#define ARCH_HAS_HUGETLB_CLEAN_STALE_PGTABLE
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
--- ./include/linux/hugetlb.h.orig	2005-08-28 16:41:01.000000000 -0700
+++ ./include/linux/hugetlb.h	2005-08-30 17:24:33.017327867 -0700
@@ -70,12 +70,6 @@ pte_t huge_ptep_get_and_clear(struct mm_
 void hugetlb_prefault_arch_hook(struct mm_struct *mm);
 #endif
 
-#ifndef ARCH_HAS_HUGETLB_CLEAN_STALE_PGTABLE
-#define hugetlb_clean_stale_pgtable(pte)	BUG()
-#else
-void hugetlb_clean_stale_pgtable(pte_t *pte);
-#endif
-
 #else /* !CONFIG_HUGETLB_PAGE */
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
