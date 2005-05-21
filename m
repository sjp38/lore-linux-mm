From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 14:04:00 +1000 (EST)
Subject: [PATCH 8/15] PTI: Keep calling interface
In-Reply-To: <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 8 of 15.

This patch continues to call the new interface.  It moves through
memory.c and continues to call the page table interface

 	*follow_page now looks up a page table via the page table
 	 interface.  This breaks the hugeTLBfs which will be fixed
 	 in a later patch series.
 	*untouched_anonymous_page looks up the page table via
 	 the page table interface.
 	*get_user_pages calls lookup_page_table_gate from the
 	 new interface
 	*vmalloc_to_page does a lookup of the kernel page table
 	 via lookup_page_table.

  mm/memory.c |   94 
+++++++++++-------------------------------------------------
  1 files changed, 18 insertions(+), 76 deletions(-)

Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-18 13:05:49.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-18 13:48:29.000000000 
+1000
@@ -528,33 +528,12 @@
  static struct page *
  __follow_page(struct mm_struct *mm, unsigned long address, int read, int 
write)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *ptep, pte;
  	unsigned long pfn;
  	struct page *page;
-
-	page = follow_huge_addr(mm, address, write);
-	if (! IS_ERR(page))
-		return page;
-
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto out;

-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		goto out;
-	if (pmd_huge(*pmd))
-		return follow_huge_pmd(mm, address, pmd, write);
-
-	ptep = pte_offset_map(pmd, address);
-	if (!ptep)
+	ptep = lookup_page_table(mm, address);
+	if(!ptep)
  		goto out;

  	pte = *ptep;
@@ -605,37 +584,20 @@
  	return page;
  }

-
  static inline int
  untouched_anonymous_page(struct mm_struct* mm, struct vm_area_struct 
*vma,
  			 unsigned long address)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
  	/* Check if the vma is for an anonymous mapping. */
  	if (vma->vm_ops && vma->vm_ops->nopage)
  		return 0;
-
-	/* Check if page directory entry exists. */
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		return 1;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		return 1;
-
-	/* Check if page middle directory entry exists. */
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		return 1;
-
+
  	/* There is a pte slot for 'address' in 'mm'. */
-	return 0;
-}
+	if(lookup_page_table(mm, address))
+		return 0;

+	return 1;
+}

  int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
  		unsigned long start, int len, int write, int force,
@@ -657,24 +619,11 @@

  		vma = find_extend_vma(mm, start);
  		if (!vma && in_gate_area(tsk, start)) {
-			unsigned long pg = start & PAGE_MASK;
  			struct vm_area_struct *gate_vma = 
get_gate_vma(tsk);
-			pgd_t *pgd;
-			pud_t *pud;
-			pmd_t *pmd;
  			pte_t *pte;
  			if (write) /* user gate pages are read-only */
  				return i ? : -EFAULT;
-			if (pg > TASK_SIZE)
-				pgd = pgd_offset_k(pg);
-			else
-				pgd = pgd_offset_gate(mm, pg);
-			BUG_ON(pgd_none(*pgd));
-			pud = pud_offset(pgd, pg);
-			BUG_ON(pud_none(*pud));
-			pmd = pmd_offset(pud, pg);
-			BUG_ON(pmd_none(*pmd));
-			pte = pte_offset_map(pmd, pg);
+			pte = lookup_page_table_gate(mm, start);
  			BUG_ON(pte_none(*pte));
  			if (pages) {
  				pages[i] = pte_page(*pte);
@@ -1831,24 +1780,17 @@
  {
  	unsigned long addr = (unsigned long) vmalloc_addr;
  	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *ptep, pte;
-
-	if (!pgd_none(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (!pud_none(*pud)) {
-			pmd = pmd_offset(pud, addr);
-			if (!pmd_none(*pmd)) {
-				ptep = pte_offset_map(pmd, addr);
-				pte = *ptep;
-				if (pte_present(pte))
-					page = pte_page(pte);
-				pte_unmap(ptep);
-			}
-		}
-	}
+
+	ptep = lookup_page_table(NULL, addr);
+	if(!ptep)
+		return page;
+
+	pte = *ptep;
+	if (pte_present(pte))
+		page = pte_page(pte);
+	pte_unmap(ptep);
+
  	return page;
  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
