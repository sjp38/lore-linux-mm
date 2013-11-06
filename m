Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3246B00EE
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 11:36:25 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10921043pab.0
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 08:36:25 -0800 (PST)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id yh6si17837919pab.208.2013.11.06.08.36.22
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 08:36:23 -0800 (PST)
Date: Wed, 6 Nov 2013 13:10:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131106131048.GC4877@suse.de>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131104200346.GA3066@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 04, 2013 at 02:03:46PM -0600, Alex Thorlton wrote:
> On Mon, Nov 04, 2013 at 02:58:28PM +0000, Mel Gorman wrote:
> > On Wed, Oct 16, 2013 at 10:54:29AM -0500, Alex Thorlton wrote:
> > > Hi guys,
> > > 
> > > I ran into a bug a week or so ago, that I believe has something to do
> > > with NUMA balancing, but I'm having a tough time tracking down exactly
> > > what is causing it.  When running with the following configuration
> > > options set:
> > > 
> > 
> > Can you test with patches
> > cd65718712469ad844467250e8fad20a5838baae..0255d491848032f6c601b6410c3b8ebded3a37b1
> > applied? They fix some known memory corruption problems, were merged for
> > 3.12 (so alternatively just test 3.12) and have been tagged for -stable.
> 
> I just finished testing with 3.12, and I'm still seeing the same issue.

Ok, I plugged your test into mmtests and ran it a few times but was not
able to reproduce the same issue. It's a much smaller machine which
might be a factor.

> I'll poke around a bit more on this in the next few days and see if I
> can come up with any more information.  In the meantime, let me know if
> you have any other suggestions.
> 

Try the following patch on top of 3.12. It's a patch that is expected to
be merged for 3.13. On its own it'll hurt automatic NUMA balancing in
-stable but corruption trumps performance and the full series is not
going to be considered acceptable for -stable

---8<---
mm: numa: Do not batch handle PMD pages

With the THP migration races closed it is still possible to occasionally
see corruption. The problem is related to handling PMD pages in batch.
When a page fault is handled it can be assumed that the page being
faulted will also be flushed from the TLB. The same flushing does not
happen when handling PMD pages in batch. Fixing is straight forward but
there are a number of reasons not to

1. Multiple TLB flushes may have to be sent depending on what pages get
   migrated
2. The handling of PMDs in batch means that faults get accounted to
   the task that is handling the fault. While care is taken to only
   mark PMDs where the last CPU and PID match it can still have problems
   due to PID truncation when matching PIDs.
3. Batching on the PMD level may reduce faults but setting pmd_numa
   requires taking a heavy lock that can contend with THP migration
   and handling the fault requires the release/acquisition of the PTL
   for every page migrated. It's still pretty heavy.

PMD batch handling is not something that people ever have been happy
with. This patch removes it and later patches will deal with the
additional fault overhead using more installigent migrate rate adaption.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c   | 91 ++---------------------------------------------------------
 mm/mprotect.c | 39 ++-----------------------
 2 files changed, 4 insertions(+), 126 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d176154..f453384 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3586,93 +3586,6 @@ out:
 	return 0;
 }
 
-/* NUMA hinting page fault entry point for regular pmds */
-#ifdef CONFIG_NUMA_BALANCING
-static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		     unsigned long addr, pmd_t *pmdp)
-{
-	pmd_t pmd;
-	pte_t *pte, *orig_pte;
-	unsigned long _addr = addr & PMD_MASK;
-	unsigned long offset;
-	spinlock_t *ptl;
-	bool numa = false;
-
-	spin_lock(&mm->page_table_lock);
-	pmd = *pmdp;
-	if (pmd_numa(pmd)) {
-		set_pmd_at(mm, _addr, pmdp, pmd_mknonnuma(pmd));
-		numa = true;
-	}
-	spin_unlock(&mm->page_table_lock);
-
-	if (!numa)
-		return 0;
-
-	/* we're in a page fault so some vma must be in the range */
-	BUG_ON(!vma);
-	BUG_ON(vma->vm_start >= _addr + PMD_SIZE);
-	offset = max(_addr, vma->vm_start) & ~PMD_MASK;
-	VM_BUG_ON(offset >= PMD_SIZE);
-	orig_pte = pte = pte_offset_map_lock(mm, pmdp, _addr, &ptl);
-	pte += offset >> PAGE_SHIFT;
-	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
-		pte_t pteval = *pte;
-		struct page *page;
-		int page_nid = -1;
-		int target_nid;
-		bool migrated = false;
-
-		if (!pte_present(pteval))
-			continue;
-		if (!pte_numa(pteval))
-			continue;
-		if (addr >= vma->vm_end) {
-			vma = find_vma(mm, addr);
-			/* there's a pte present so there must be a vma */
-			BUG_ON(!vma);
-			BUG_ON(addr < vma->vm_start);
-		}
-		if (pte_numa(pteval)) {
-			pteval = pte_mknonnuma(pteval);
-			set_pte_at(mm, addr, pte, pteval);
-		}
-		page = vm_normal_page(vma, addr, pteval);
-		if (unlikely(!page))
-			continue;
-		/* only check non-shared pages */
-		if (unlikely(page_mapcount(page) != 1))
-			continue;
-
-		page_nid = page_to_nid(page);
-		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
-		pte_unmap_unlock(pte, ptl);
-		if (target_nid != -1) {
-			migrated = migrate_misplaced_page(page, target_nid);
-			if (migrated)
-				page_nid = target_nid;
-		} else {
-			put_page(page);
-		}
-
-		if (page_nid != -1)
-			task_numa_fault(page_nid, 1, migrated);
-
-		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
-	}
-	pte_unmap_unlock(orig_pte, ptl);
-
-	return 0;
-}
-#else
-static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		     unsigned long addr, pmd_t *pmdp)
-{
-	BUG();
-	return 0;
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3811,8 +3724,8 @@ retry:
 		}
 	}
 
-	if (pmd_numa(*pmd))
-		return do_pmd_numa_page(mm, vma, address, pmd);
+	/* THP should already have been handled */
+	BUG_ON(pmd_numa(*pmd));
 
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 412ba2b..4c9d733 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,14 +37,12 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa, bool *ret_all_same_node)
+		int dirty_accountable, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
-	bool all_same_node = true;
-	int last_nid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -63,12 +61,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
-					int this_nid = page_to_nid(page);
-					if (last_nid == -1)
-						last_nid = this_nid;
-					if (last_nid != this_nid)
-						all_same_node = false;
-
 					/* only check non-shared pages */
 					if (!pte_numa(oldpte) &&
 					    page_mapcount(page) == 1) {
@@ -111,26 +103,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
-	*ret_all_same_node = all_same_node;
 	return pages;
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmd)
-{
-	spin_lock(&mm->page_table_lock);
-	set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
-	spin_unlock(&mm->page_table_lock);
-}
-#else
-static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmd)
-{
-	BUG();
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pud_t *pud, unsigned long addr, unsigned long end,
 		pgprot_t newprot, int dirty_accountable, int prot_numa)
@@ -138,7 +113,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
-	bool all_same_node;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -156,16 +130,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		pages += change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa, &all_same_node);
-
-		/*
-		 * If we are changing protections for NUMA hinting faults then
-		 * set pmd_numa if the examined pages were all on the same
-		 * node. This allows a regular PMD to be handled as one fault
-		 * and effectively batches the taking of the PTL
-		 */
-		if (prot_numa && all_same_node)
-			change_pmd_protnuma(vma->vm_mm, addr, pmd);
+				 dirty_accountable, prot_numa);
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
