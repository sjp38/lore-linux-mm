Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7HJ93N2028656
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJ93Fv186476
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJ927O030488
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:03 -0400
Subject: [PATCH 2/4] x86-move-stale-pgtable
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1124304966.3139.37.camel@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 14:03:47 -0500
Message-Id: <1124305427.3139.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

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

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 arch/i386/mm/hugetlbpage.c |   13 +++++++++++--
 mm/hugetlb.c               |    2 --
 2 files changed, 11 insertions(+), 4 deletions(-)
diff -upN reference/arch/i386/mm/hugetlbpage.c current/arch/i386/mm/hugetlbpage.c
--- reference/arch/i386/mm/hugetlbpage.c
+++ current/arch/i386/mm/hugetlbpage.c
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
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -360,8 +360,6 @@ int hugetlb_prefault(struct address_spac
 			ret = -ENOMEM;
 			goto out;
 		}
-		if (! pte_none(*pte))
-			hugetlb_clean_stale_pgtable(pte);
 
 		idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
 			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
