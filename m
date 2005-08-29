Message-Id: <200508292245.j7TMjcwk029212@shell0.pdx.osdl.net>
Subject: hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch added to -mm tree
From: akpm@osdl.org
Date: Mon, 29 Aug 2005 15:48:05 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com, linux-mm@kvack.org, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     hugetlb: move stale pte check into huge_pte_alloc()

has been added to the -mm tree.  Its filename is

     hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch

Patches currently in -mm which might be from agl@us.ibm.com are

hugetlb-add-pte_huge-macro.patch
hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch
hugetlb-check-pd_present-in-huge_pte_offset.patch



From: Adam Litke <agl@us.ibm.com>

Initial Post (Wed, 17 Aug 2005)

This patch moves the
	if (! pte_none(*pte))
		hugetlb_clean_stale_pgtable(pte);
logic into huge_pte_alloc() so all of its callers can be immune to the bug
described by Kenneth Chen at http://lkml.org/lkml/2004/6/16/246

> It turns out there is a bug in hugetlb_prefault(): with 3 level page table,
> huge_pte_alloc() might return a pmd that points to a PTE page. It happens
> if the virtual address for hugetlb mmap is recycled from previously used
> normal page mmap. free_pgtables() might not scrub the pmd entry on
> munmap and hugetlb_prefault skips on any pmd presence regardless what type 
> it is.

Unless I am missing something, it seems more correct to place the check inside
huge_pte_alloc() to prevent a the same bug wherever a huge pte is allocated.
It also allows checking for this condition when lazily faulting huge pages
later in the series.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/i386/mm/hugetlbpage.c |   13 +++++++++++--
 mm/hugetlb.c               |    2 --
 2 files changed, 11 insertions(+), 4 deletions(-)

diff -puN arch/i386/mm/hugetlbpage.c~hugetlb-move-stale-pte-check-into-huge_pte_alloc arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~hugetlb-move-stale-pte-check-into-huge_pte_alloc	Mon Aug 29 15:48:03 2005
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	Mon Aug 29 15:48:03 2005
@@ -22,12 +22,21 @@ pte_t *huge_pte_alloc(struct mm_struct *
 {
 	pgd_t *pgd;
 	pud_t *pud;
-	pmd_t *pmd = NULL;
+	pmd_t *pmd;
+	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
 	pmd = pmd_alloc(mm, pud, addr);
-	return (pte_t *) pmd;
+
+	if (!pmd)
+		goto out;
+
+	pte = (pte_t *) pmd;
+	if (!pte_none(*pte) && !pte_huge(*pte))
+		hugetlb_clean_stale_pgtable(pte);
+out:
+	return pte;
 }
 
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
diff -puN mm/hugetlb.c~hugetlb-move-stale-pte-check-into-huge_pte_alloc mm/hugetlb.c
--- 25/mm/hugetlb.c~hugetlb-move-stale-pte-check-into-huge_pte_alloc	Mon Aug 29 15:48:03 2005
+++ 25-akpm/mm/hugetlb.c	Mon Aug 29 15:48:03 2005
@@ -360,8 +360,6 @@ int hugetlb_prefault(struct address_spac
 			ret = -ENOMEM;
 			goto out;
 		}
-		if (! pte_none(*pte))
-			hugetlb_clean_stale_pgtable(pte);
 
 		idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
 			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
