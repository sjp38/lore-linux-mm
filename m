Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 486DD900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:39 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so2800854pad.14
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:38 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 47/63] mm: numa: Do not batch handle PMD pages
Date: Fri, 27 Sep 2013 14:27:32 +0100
Message-Id: <1380288468-5551-48-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
 mm/memory.c   | 101 ++--------------------------------------------------------
 mm/mprotect.c |  47 ++-------------------------
 2 files changed, 4 insertions(+), 144 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 1aa4187..da65ad4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3617,103 +3617,6 @@ out:
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
-	int last_cpupid;
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
-		int flags = 0;
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
-
-		/*
-		 * Avoid grouping on DSO/COW pages in specific and RO pages
-		 * in general, RO pages shouldn't hurt as much anyway since
-		 * they can be in shared cache state.
-		 */
-		if (!pte_write(pteval))
-			flags |= TNF_NO_GROUP;
-
-		last_cpupid = page_cpupid_last(page);
-		page_nid = page_to_nid(page);
-		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
-		pte_unmap_unlock(pte, ptl);
-		if (target_nid != -1) {
-			migrated = migrate_misplaced_page(page, vma, target_nid);
-			if (migrated) {
-				page_nid = target_nid;
-				flags |= TNF_MIGRATED;
-			}
-		} else {
-			put_page(page);
-		}
-
-		if (page_nid != -1)
-			task_numa_fault(last_cpupid, page_nid, 1, flags);
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
@@ -3857,8 +3760,8 @@ retry:
 		}
 	}
 
-	if (pmd_numa(*pmd))
-		return do_pmd_numa_page(mm, vma, address, pmd);
+	/* THP should already have been handled */
+	BUG_ON(pmd_numa(*pmd));
 
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 9a74855..a0302ac 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,15 +37,12 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa, bool *ret_all_same_cpupid)
+		int dirty_accountable, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
-	bool all_same_cpupid = true;
-	int last_cpu = -1;
-	int last_pid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -64,19 +61,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
-					int cpupid = page_cpupid_last(page);
-					int this_cpu = cpupid_to_cpu(cpupid);
-					int this_pid = cpupid_to_pid(cpupid);
-
-					if (last_cpu == -1)
-						last_cpu = this_cpu;
-					if (last_pid == -1)
-						last_pid = this_pid;
-					if (last_cpu != this_cpu ||
-					    last_pid != this_pid) {
-						all_same_cpupid = false;
-					}
-
 					if (!pte_numa(oldpte)) {
 						ptent = pte_mknuma(ptent);
 						updated = true;
@@ -115,26 +99,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
-	*ret_all_same_cpupid = all_same_cpupid;
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
@@ -142,7 +109,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
-	bool all_same_cpupid;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -168,17 +134,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa, &all_same_cpupid);
+				 dirty_accountable, prot_numa);
 		pages += this_pages;
-
-		/*
-		 * If we are changing protections for NUMA hinting faults then
-		 * set pmd_numa if the examined pages were all on the same
-		 * node. This allows a regular PMD to be handled as one fault
-		 * and effectively batches the taking of the PTL
-		 */
-		if (prot_numa && this_pages && all_same_cpupid)
-			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
