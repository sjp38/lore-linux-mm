Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F273A8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 06:01:33 -0400 (EDT)
Date: Tue, 15 Mar 2011 11:01:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
Message-ID: <20110315100107.GI10696@random.random>
References: <20110311020410.GH5641@random.random>
 <20110315092750.GD2140@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110315092750.GD2140@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Tue, Mar 15, 2011 at 10:27:50AM +0100, Johannes Weiner wrote:
> On Fri, Mar 11, 2011 at 03:04:10AM +0100, Andrea Arcangeli wrote:
> > @@ -42,7 +42,7 @@ static pmd_t *get_old_pmd(struct mm_stru
> >  
> >  	pmd = pmd_offset(pud, addr);
> >  	split_huge_page_pmd(mm, pmd);
> 
> Wasn't getting rid of this line the sole purpose of the patch? :)

Leftover that should have been deleted right...

> > +		if (pmd_trans_huge(*old_pmd)) {
> > +			int err = move_huge_pmd(vma, old_addr, new_addr,
> > +						old_end, old_pmd, new_pmd);
> > +			if (err > 0) {
> > +				old_addr += HPAGE_PMD_SIZE;
> > +				new_addr += HPAGE_PMD_SIZE;
> > +				continue;
> > +			}
> > +		}
> > +		/*
> > +		 * split_huge_page_pmd() must run outside the
> > +		 * pmd_trans_huge() block above because that check
> > +		 * racy. split_huge_page_pmd() will recheck
> > +		 * pmd_trans_huge() but in a not racy way under the
> > +		 * page_table_lock.
> > +		 */
> > +		split_huge_page_pmd(vma->vm_mm, old_pmd);
> 
> I don't understand what we are racing here against.  If we see a huge
> pmd, it may split.  But we hold mmap_sem in write-mode, I don't see
> how a regular pmd could become huge all of a sudden at this point.

Agreed, in fact it runs it without the lock too...

Does this look any better? This also optimizes away the tlb flush for
totally uninitialized areas.

===
Subject: thp: mremap support and TLB optimization

From: Andrea Arcangeli <aarcange@redhat.com>

This adds THP support to mremap (decreases the number of split_huge_page
called).

This also replaces ptep_clear_flush with ptep_get_and_clear and replaces it
with a final flush_tlb_range to send a single tlb flush IPI instead of one IPI
for each page.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |    3 +++
 mm/huge_memory.c        |   38 ++++++++++++++++++++++++++++++++++++++
 mm/mremap.c             |   29 +++++++++++++++++++++--------
 3 files changed, 62 insertions(+), 8 deletions(-)

--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -22,6 +22,9 @@ extern int zap_huge_pmd(struct mmu_gathe
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
+extern int move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
+			 unsigned long new_addr, unsigned long old_end,
+			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot);
 
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -41,8 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
-	split_huge_page_pmd(mm, pmd);
-	if (pmd_none_or_clear_bad(pmd))
+	if (pmd_none(*pmd))
 		return NULL;
 
 	return pmd;
@@ -80,11 +79,7 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
-	unsigned long old_start;
 
-	old_start = old_addr;
-	mmu_notifier_invalidate_range_start(vma->vm_mm,
-					    old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -112,7 +107,7 @@ static void move_ptes(struct vm_area_str
 				   new_pte++, new_addr += PAGE_SIZE) {
 		if (pte_none(*old_pte))
 			continue;
-		pte = ptep_clear_flush(vma, old_addr, old_pte);
+		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
@@ -124,7 +119,6 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
-	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
@@ -135,10 +129,13 @@ unsigned long move_page_tables(struct vm
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
+	bool need_flush = false;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
+	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
+
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
@@ -151,6 +148,18 @@ unsigned long move_page_tables(struct vm
 		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
 		if (!new_pmd)
 			break;
+		need_flush = true;
+		if (pmd_trans_huge(*old_pmd)) {
+			int err = move_huge_pmd(vma, old_addr, new_addr,
+						old_end, old_pmd, new_pmd);
+			if (err > 0) {
+				old_addr += HPAGE_PMD_SIZE;
+				new_addr += HPAGE_PMD_SIZE;
+				continue;
+			} else if (!err)
+				__split_huge_page_pmd(vma->vm_mm, old_pmd);
+			VM_BUG_ON(pmd_trans_huge(*old_pmd));
+		}
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
 		if (extent > next - new_addr)
 			extent = next - new_addr;
@@ -159,6 +168,10 @@ unsigned long move_page_tables(struct vm
 		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
 				new_vma, new_pmd, new_addr);
 	}
+	if (likely(need_flush))
+		flush_tlb_range(vma, old_end-len, old_addr);
+
+	mmu_notifier_invalidate_range_end(vma->vm_mm, old_end-len, old_end);
 
 	return len + old_addr - old_end;	/* how much done */
 }
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1048,6 +1048,44 @@ int mincore_huge_pmd(struct vm_area_stru
 	return ret;
 }
 
+int move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
+		  unsigned long new_addr, unsigned long old_end,
+		  pmd_t *old_pmd, pmd_t *new_pmd)
+{
+	int ret = 0;
+	pmd_t pmd;
+
+	struct mm_struct *mm = vma->vm_mm;
+
+	if ((old_addr & ~HPAGE_PMD_MASK) ||
+	    (new_addr & ~HPAGE_PMD_MASK) ||
+	    (old_addr + HPAGE_PMD_SIZE) > old_end)
+		goto out;
+
+	/* if the new area is all for our destination it must be unmapped */
+	VM_BUG_ON(!pmd_none(*new_pmd));
+	/* mostly to remember this locking isn't enough with filebacked vma */
+	VM_BUG_ON(vma->vm_file);
+
+	spin_lock(&mm->page_table_lock);
+	if (likely(pmd_trans_huge(*old_pmd))) {
+		if (pmd_trans_splitting(*old_pmd)) {
+			spin_unlock(&vma->vm_mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, old_pmd);
+			ret = -1;
+		} else {
+			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
+			set_pmd_at(mm, new_addr, new_pmd, pmd);
+			spin_unlock(&mm->page_table_lock);
+			ret = 1;
+		}
+	} else
+		spin_unlock(&mm->page_table_lock);
+
+out:
+	return ret;
+}
+
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, pgprot_t newprot)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
