Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4DCD08D0007
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:59:00 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so657977eek.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:58:59 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 04/10] mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
Date: Fri, 30 Nov 2012 20:58:35 +0100
Message-Id: <1354305521-11583-5-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Reduce the 4K page fault count by looking around and processing
nearby pages if possible.

To keep the logic and cache overhead simple and straightforward
we do a couple of simplifications:

 - we only scan in the HPAGE_SIZE range of the faulting address
 - we only go as far as the vma allows us

Also simplify the do_numa_page() flow while at it and fix the
previous double faulting we incurred due to not properly fixing
up freshly migrated ptes.

While at it also simplify the THP fault processing code and make
the change_protection() code more robust.

Suggested-by: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c |  51 ++++++++++++-------
 mm/memory.c      | 151 ++++++++++++++++++++++++++++++++++++++++++-------------
 mm/mprotect.c    |  24 +++++++--
 3 files changed, 167 insertions(+), 59 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 977834c..5c8de10 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -739,6 +739,7 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct mem_cgroup *memcg = NULL;
 	struct page *new_page;
 	struct page *page = NULL;
+	int page_nid = -1;
 	int last_cpu;
 	int node = -1;
 
@@ -754,12 +755,11 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(entry);
 	if (page) {
-		int page_nid = page_to_nid(page);
+		page_nid = page_to_nid(page);
 
 		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
 		last_cpu = page_last_cpu(page);
 
-		get_page(page);
 		/*
 		 * Note that migrating pages shared by others is safe, since
 		 * get_user_pages() or GUP fast would have to fault this page
@@ -769,6 +769,8 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		node = mpol_misplaced(page, vma, haddr);
 		if (node != -1 && node != page_nid)
 			goto migrate;
+
+		task_numa_fault(page_nid, last_cpu, HPAGE_PMD_NR);
 	}
 
 fixup:
@@ -779,32 +781,33 @@ fixup:
 
 unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (page) {
-		task_numa_fault(page_to_nid(page), last_cpu, HPAGE_PMD_NR);
-		put_page(page);
-	}
 	return;
 
 migrate:
-	spin_unlock(&mm->page_table_lock);
-
 	/*
 	 * If this node is getting full then don't migrate even
  	 * more pages here:
  	 */
-	if (!migrate_balanced_pgdat(NODE_DATA(node), HPAGE_PMD_NR)) {
-		put_page(page);
-		return;
-	}
+	if (!migrate_balanced_pgdat(NODE_DATA(node), HPAGE_PMD_NR))
+		goto fixup;
 
-	lock_page(page);
-	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry))) {
+	get_page(page);
+
+	/*
+	 * If we cannot lock the page immediately then wait for it
+	 * to migrate and re-take the fault (which might not be
+	 * necessary if the migrating task fixed up the pmd):
+	 */
+	if (!trylock_page(page)) {
 		spin_unlock(&mm->page_table_lock);
+
+		lock_page(page);
 		unlock_page(page);
 		put_page(page);
+
 		return;
 	}
+
 	spin_unlock(&mm->page_table_lock);
 
 	new_page = alloc_pages_node(node,
@@ -884,12 +887,13 @@ migrate:
 
 alloc_fail:
 	unlock_page(page);
+
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry))) {
-		put_page(page);
-		page = NULL;
+	put_page(page);
+
+	if (unlikely(!pmd_same(*pmd, entry)))
 		goto unlock;
-	}
+
 	goto fixup;
 }
 #endif
@@ -1275,9 +1279,18 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
 		pmd_t entry;
+
 		entry = pmdp_get_and_clear(mm, addr, pmd);
 		entry = pmd_modify(entry, newprot);
+
+		if (pmd_numa(vma, entry)) {
+			struct page *page = pmd_page(*pmd);
+
+ 			if (page_mapcount(page) != 1)
+				goto skip;
+		}
 		set_pmd_at(mm, addr, pmd, entry);
+skip:
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		ret = 1;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 1f733dc..c6884e8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3457,64 +3457,143 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int __do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pmd_t *pmd,
-			unsigned int flags, pte_t entry)
+			unsigned int flags, pte_t entry, spinlock_t *ptl)
 {
-	struct page *page = NULL;
-	int node, page_nid = -1;
-	int last_cpu = -1;
-	spinlock_t *ptl;
+	struct page *page;
+	int best_node;
+	int last_cpu;
+	int page_nid;
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, entry)))
-		goto out_unlock;
+	WARN_ON_ONCE(pmd_trans_splitting(*pmd));
 
 	page = vm_normal_page(vma, address, entry);
-	if (page) {
-		get_page(page);
-		page_nid = page_to_nid(page);
-		last_cpu = page_last_cpu(page);
-		node = mpol_misplaced(page, vma, address);
-		if (node != -1 && node != page_nid)
-			goto migrate;
-	}
 
-out_pte_upgrade_unlock:
 	flush_cache_page(vma, address, pte_pfn(entry));
-
 	ptep_modify_prot_start(mm, address, ptep);
 	entry = pte_modify(entry, vma->vm_page_prot);
-	ptep_modify_prot_commit(mm, address, ptep, entry);
 
-	/* No TLB flush needed because we upgraded the PTE */
+	/* Be careful: */
+	if (pte_dirty(entry) && page && PageAnon(page) && (page_mapcount(page) == 1))
+		entry = pte_mkwrite(entry);
 
+	ptep_modify_prot_commit(mm, address, ptep, entry);
+	/* No TLB flush needed because we upgraded the PTE */
 	update_mmu_cache(vma, address, ptep);
 
-out_unlock:
-	pte_unmap_unlock(ptep, ptl);
+	if (!page)
+		return 0;
 
-	if (page) {
+	page_nid = page_to_nid(page);
+	last_cpu = page_last_cpu(page);
+	best_node = mpol_misplaced(page, vma, address);
+
+	if (best_node == -1 || best_node == page_nid || page_mapcount(page) != 1) {
 		task_numa_fault(page_nid, last_cpu, 1);
-		put_page(page);
+		return 0;
 	}
-out:
-	return 0;
 
-migrate:
+	/* Start the migration: */
+
+	get_page(page);
 	pte_unmap_unlock(ptep, ptl);
 
-	if (migrate_misplaced_page(page, node)) {
-		goto out;
+	/* Drops the page reference */
+	if (migrate_misplaced_page(page, best_node))
+		task_numa_fault(best_node, last_cpu, 1);
+
+	spin_lock(ptl);
+	return 0;
+}
+
+/*
+ * Also fault over nearby ptes from within the same pmd and vma,
+ * in order to minimize the overhead from page fault exceptions:
+ */
+static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr0, pte_t *ptep0, pmd_t *pmd,
+			unsigned int flags, pte_t entry0)
+{
+	unsigned long addr0_pmd;
+	unsigned long addr_start;
+	unsigned long addr;
+	struct page *page;
+	spinlock_t *ptl;
+	pte_t *ptep_start;
+	pte_t *ptep;
+	pte_t entry;
+
+	WARN_ON_ONCE(addr0 < vma->vm_start || addr0 >= vma->vm_end);
+
+	addr0_pmd = addr0 & PMD_MASK;
+	addr_start = max(addr0_pmd, vma->vm_start);
+
+	/*
+	 * Serialize the 2MB clustering of this NUMA probing
+	 * pte by taking the lock of the pmd level page.
+	 *
+	 * This allows the whole HPAGE_SIZE-sized NUMA operation
+	 * that was already started by another thread to be
+	 * finished, without us interfering.
+	 *
+	 * It's not like that we are likely to make any meaningful
+	 * progress while the NUMA pte handling logic is running
+	 * in another thread, so we (and other threads) don't
+	 * waste CPU time taking the ptl lock and excessive page
+	 * faults and scheduling.
+	 *
+	 * ( This is also roughly analogous to the serialization of
+	 *   a real 2MB huge page fault. )
+	 */
+	spin_lock(&mm->page_table_lock);
+	page = pmd_page(*pmd);
+	WARN_ON_ONCE(!page);
+	get_page(page);
+	spin_unlock(&mm->page_table_lock);
+
+	if (!trylock_page(page)) {
+
+		lock_page(page);
+		unlock_page(page);
+		put_page(page);
+
+		/* The pte has most likely been resolved by another thread meanwhile */
+
+		return 0;
 	}
-	page = NULL;
 
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_same(*ptep, entry))
-		goto out_unlock;
+	ptep_start = pte_offset_map(pmd, addr_start);
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	ptep = ptep_start+1;
 
-	goto out_pte_upgrade_unlock;
+	for (addr = addr_start+PAGE_SIZE; addr < vma->vm_end; addr += PAGE_SIZE, ptep++) {
+
+		if ((addr & PMD_MASK) != addr0_pmd)
+			break;
+
+		entry = ACCESS_ONCE(*ptep);
+
+		if (!pte_present(entry))
+			continue;
+		if (!pte_numa(vma, entry))
+			continue;
+
+		__do_numa_page(mm, vma, addr, ptep, pmd, flags, entry, ptl);
+	}
+
+	entry = ACCESS_ONCE(*ptep_start);
+	if (pte_present(entry) && pte_numa(vma, entry))
+		__do_numa_page(mm, vma, addr_start, ptep_start, pmd, flags, entry, ptl);
+
+	pte_unmap_unlock(ptep_start, ptl);
+
+	unlock_page(page);
+	put_page(page);
+
+	return 0;
 }
 
 /*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6ff2d5e..7bb3536 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,16 +28,19 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
+	struct page *page;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
+
 	do {
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
@@ -46,6 +49,18 @@ static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
 
+			/* Are we turning it into a NUMA entry? */
+			if (pte_numa(vma, ptent)) {
+				page = vm_normal_page(vma, addr, oldpte);
+
+				/* Skip all but private pages: */
+				if (!page || !PageAnon(page) || page_mapcount(page) != 1)
+					ptent = oldpte;
+				else
+					pages++;
+			} else {
+				pages++;
+			}
 			/*
 			 * Avoid taking write faults for pages we know to be
 			 * dirty.
@@ -54,7 +69,6 @@ static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 				ptent = pte_mkwrite(ptent);
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
-			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
@@ -98,7 +112,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		}
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		pages += change_pte_range(vma->vm_mm, pmd, addr, next, newprot,
+		pages += change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable);
 	} while (pmd++, addr = next, addr != end);
 
@@ -135,7 +149,9 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 	unsigned long start = addr;
 	unsigned long pages = 0;
 
-	BUG_ON(addr >= end);
+	if (WARN_ON_ONCE(addr >= end))
+		return 0;
+
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
 	do {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
