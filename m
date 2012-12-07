Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id ACEA96B0071
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:48 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4763716eek.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:48 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 6/9] numa, mm: Fix !THP, 4K-pte "2M-emu" NUMA fault handling
Date: Fri,  7 Dec 2012 01:19:23 +0100
Message-Id: <1354839566-15697-7-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

The !THP pte_numa code from the unified tree is not working very well
for me: I suspect it would work better with migration bandwidth throttling
in place, but without that (and in form of my port to the unified tree)
it performs badly in a number of situations:

 - when for whatever reason the numa_pmd entry is not established
   yet and threads are hitting the 4K ptes then the pte lock can
   kill performance quickly:

    19.29%        process 1  [kernel.kallsyms]          [k] do_raw_spin_lock
                  |
                  --- do_raw_spin_lock
                     |
                     |--99.67%-- _raw_spin_lock
                     |          |
                     |          |--34.47%-- remove_migration_pte
                     |          |          rmap_walk
                     |          |          move_to_new_page
                     |          |          migrate_pages
                     |          |          migrate_misplaced_page_put
                     |          |          __do_numa_page.isra.56
                     |          |          handle_pte_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          __memset_sse2
                     |          |
                     |          |--34.32%-- __page_check_address
                     |          |          try_to_unmap_one
                     |          |          try_to_unmap_anon
                     |          |          try_to_unmap
                     |          |          migrate_pages
                     |          |          migrate_misplaced_page_put
                     |          |          __do_numa_page.isra.56
                     |          |          handle_pte_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          __memset_sse2
                     |          |
    [...]

 - even if the pmd entry is established we'd hit ptes in a loop while
   other CPUs do it too, seeing the migration ptes as they are being
   established and torn down - resulting in up to 1 million page faults
   per second on my test-system. Not a happy sight and you really don't
   want me to cite that profile here.

So import the 2M-EMU handling code from the v17 numa/core tree, which
was working reasonably well, and add a few other goodies as well:

 - let the first page of an emulated large page determine the target
   node - and also pass down the expected interleaving shift to
   mpol_misplaced(), for overload situations where one group of threads
   spans multiple nodes.

 - turn off the pmd clustering in change_protection() - because the
   2M-emu code works better at the moment. We can re-establish it if
   it's enhanced. I kept both variants for the time being, feedback
   is welcome on this issue.

 - instead of calling mpol_misplaced() 512 times per emulated hugepage,
   extract the cpupid operation from it. Results in measurably lower
   CPU overhead for this functionality.

4K-intense workloads are immediately much happier: 3-5K pagefaults/sec
on my 32-way test-box and a lot less migrations all around.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mempolicy.h |   4 +-
 mm/huge_memory.c          |   2 +-
 mm/memory.c               | 153 +++++++++++++++++++++++++++++++++++-----------
 mm/mempolicy.c            |  13 +---
 mm/mprotect.c             |   4 +-
 5 files changed, 127 insertions(+), 49 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index f44b7f3..8bb6ab5 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -161,7 +161,7 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 	return 1;
 }
 
-extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
+extern int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr, int shift);
 
 #else
 
@@ -289,7 +289,7 @@ static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 }
 
 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
-				 unsigned long address)
+				 unsigned long address, int shift)
 {
 	return -1; /* no node preference */
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e6820aa..7c82f28 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1043,7 +1043,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
-	target_nid = mpol_misplaced(page, vma, haddr);
+	target_nid = mpol_misplaced(page, vma, haddr, HPAGE_SHIFT);
 	if (target_nid == -1) {
 		put_page(page);
 		goto clear_pmdnuma;
diff --git a/mm/memory.c b/mm/memory.c
index 6ebfbbe..fc0026e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3455,6 +3455,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
 static int numa_migration_target(struct page *page, struct vm_area_struct *vma,
 			       unsigned long addr, int page_nid)
 {
@@ -3462,57 +3463,50 @@ static int numa_migration_target(struct page *page, struct vm_area_struct *vma,
 	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
-	return mpol_misplaced(page, vma, addr);
+	return mpol_misplaced(page, vma, addr, PAGE_SHIFT);
 }
 
-int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+static int __do_numa_page(int target_nid, struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr, pte_t *ptep, pmd_t *pmd,
+			unsigned int flags, pte_t pte, spinlock_t *ptl)
 {
 	struct page *page = NULL;
 	bool migrated = false;
-	spinlock_t *ptl;
-	int target_nid;
 	int last_cpupid;
 	int page_nid;
 
-	/*
-	* The "pte" at this point cannot be used safely without
-	* validation through pte_unmap_same(). It's of NUMA type but
-	* the pfn may be screwed if the read is non atomic.
-	*
-	* ptep_modify_prot_start is not called as this is clearing
-	* the _PAGE_NUMA bit and it is not really expected that there
-	* would be concurrent hardware modifications to the PTE.
-	*/
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, pte))) {
-		pte_unmap_unlock(ptep, ptl);
-		return 0;
-	}
-
+	/* Mark it non-NUMA first: */
 	pte = pte_mknonnuma(pte);
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
 	page = vm_normal_page(vma, addr, pte);
-	if (!page) {
-		pte_unmap_unlock(ptep, ptl);
+	if (!page)
 		return 0;
-	}
 
 	page_nid = page_to_nid(page);
 	WARN_ON_ONCE(page_nid == -1);
 
-	/* Get it before mpol_misplaced() flips it: */
-	last_cpupid = page_last__cpupid(page);
+	/*
+	 * Propagate the last_cpupid access info, even though
+	 * the target_nid has already been established for
+	 * this NID range:
+	 */
+	{
+		int this_cpupid;
+		int this_cpu;
+		int this_node;
+
+		this_cpu = raw_smp_processor_id();
+		this_node = numa_node_id();
 
-	target_nid = numa_migration_target(page, vma, addr, page_nid);
-	if (target_nid == -1) {
-		pte_unmap_unlock(ptep, ptl);
-		goto out;
+		this_cpupid = cpu_pid_to_cpupid(this_cpu, current->pid);
+
+		last_cpupid = page_xchg_last_cpupid(page, this_cpupid);
 	}
-	WARN_ON_ONCE(target_nid == page_nid);
+
+	if (target_nid == -1 || target_nid == page_nid)
+		goto out;
 
 	/* Get a reference for migration: */
 	get_page(page);
@@ -3522,6 +3516,8 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	migrated = migrate_misplaced_page_put(page, target_nid); /* Drops the reference */
 	if (migrated)
 		page_nid = target_nid;
+
+	spin_lock(ptl);
 out:
 	/* Always account where the page currently is, physically: */
 	task_numa_fault(addr, page_nid, last_cpupid, 1, migrated);
@@ -3529,9 +3525,81 @@ out:
 	return 0;
 }
 
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
+	struct page *page0;
+	spinlock_t *ptl;
+	pte_t *ptep_start;
+	pte_t *ptep;
+	pte_t entry;
+	int target_nid;
+
+	WARN_ON_ONCE(addr0 < vma->vm_start || addr0 >= vma->vm_end);
+
+	addr0_pmd = addr0 & PMD_MASK;
+	addr_start = max(addr0_pmd, vma->vm_start);
+
+	ptep_start = pte_offset_map(pmd, addr_start);
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	ptep = ptep_start+1;
+
+	/*
+	 * The first page of the range represents the NUMA
+	 * placement of the range. This way we get consistent
+	 * placement even if the faults themselves might hit
+	 * this area at different offsets:
+	 */
+	target_nid = -1;
+	entry = ACCESS_ONCE(*ptep_start);
+	if (pte_present(entry)) {
+		page0 = vm_normal_page(vma, addr_start, entry);
+		if (page0) {
+			target_nid = mpol_misplaced(page0, vma, addr_start, PMD_SHIFT);
+			if (target_nid == -1)
+				target_nid = page_to_nid(page0);
+		}
+		if (WARN_ON_ONCE(target_nid == -1))
+			target_nid = numa_node_id();
+	}
+
+	for (addr = addr_start+PAGE_SIZE; addr < vma->vm_end; addr += PAGE_SIZE, ptep++) {
+
+		if ((addr & PMD_MASK) != addr0_pmd)
+			break;
+
+		entry = ACCESS_ONCE(*ptep);
+
+		if (!pte_present(entry))
+			continue;
+		if (!pte_numa(entry))
+			continue;
+
+		__do_numa_page(target_nid, mm, vma, addr, ptep, pmd, flags, entry, ptl);
+	}
+
+	entry = ACCESS_ONCE(*ptep_start);
+	if (pte_present(entry) && pte_numa(entry))
+		__do_numa_page(target_nid, mm, vma, addr_start, ptep_start, pmd, flags, entry, ptl);
+
+	pte_unmap_unlock(ptep_start, ptl);
+
+	return 0;
+}
+
 /* NUMA hinting page fault entry point for regular pmds */
-int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		     unsigned long addr, pmd_t *pmdp)
+static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			    unsigned long addr, pmd_t *pmdp)
 {
 	pmd_t pmd;
 	pte_t *pte, *orig_pte;
@@ -3558,6 +3626,7 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	VM_BUG_ON(offset >= PMD_SIZE);
 	orig_pte = pte = pte_offset_map_lock(mm, pmdp, _addr, &ptl);
 	pte += offset >> PAGE_SHIFT;
+
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		struct page *page;
 		int page_nid;
@@ -3581,6 +3650,9 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (pte_numa(pteval)) {
 			pteval = pte_mknonnuma(pteval);
 			set_pte_at(mm, addr, pte, pteval);
+		} else {
+			/* Should not happen */
+			WARN_ON_ONCE(1);
 		}
 		page = vm_normal_page(vma, addr, pteval);
 		if (unlikely(!page))
@@ -3621,6 +3693,19 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	return 0;
 }
+#else
+static inline int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr0, pte_t *ptep0, pmd_t *pmd,
+			unsigned int flags, pte_t entry0)
+{
+	return 0;
+}
+static inline int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		     unsigned long addr, pmd_t *pmdp)
+{
+	return 0;
+}
+#endif
 
 /*
  * These routines also need to handle stuff like marking pages dirty
@@ -3661,7 +3746,7 @@ int handle_pte_fault(struct mm_struct *mm,
 	}
 
 	if (pte_numa(entry))
-		return do_numa_page(mm, vma, address, entry, pte, pmd);
+		return do_numa_page(mm, vma, address, pte, pmd, flags, entry);
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6bb9fd0..128e2e7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2339,7 +2339,7 @@ static void sp_free(struct sp_node *n)
  * Policy determination "mimics" alloc_page_vma().
  * Called from fault path where we know the vma and faulting address.
  */
-int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
+int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr, int shift)
 {
 	struct mempolicy *pol;
 	struct zone *zone;
@@ -2353,6 +2353,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	BUG_ON(!vma);
 
 	pol = get_vma_policy(current, vma, addr);
+
 	if (!(pol->flags & MPOL_F_MOF))
 		goto out_keep_page;
 	if (task_numa_shared(current) < 0)
@@ -2360,23 +2361,13 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
-	{
-		int shift;
 
 		BUG_ON(addr >= vma->vm_end);
 		BUG_ON(addr < vma->vm_start);
 
-#ifdef CONFIG_HUGETLB_PAGE
-		if (transparent_hugepage_enabled(vma) || vma->vm_flags & VM_HUGETLB)
-			shift = HPAGE_SHIFT;
-		else
-#endif
-			shift = PAGE_SHIFT;
-
 		target_node = interleave_nid(pol, vma, addr, shift);
 
 		goto out_keep_page;
-	}
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 47335a9..b5be3f1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -138,19 +138,21 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		pages += change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable, prot_numa, &all_same_node);
 
+#ifdef CONFIG_NUMA_BALANCING
 		/*
 		 * If we are changing protections for NUMA hinting faults then
 		 * set pmd_numa if the examined pages were all on the same
 		 * node. This allows a regular PMD to be handled as one fault
 		 * and effectively batches the taking of the PTL
 		 */
-		if (prot_numa && all_same_node) {
+		if (prot_numa && all_same_node && 0) {
 			struct mm_struct *mm = vma->vm_mm;
 
 			spin_lock(&mm->page_table_lock);
 			set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
 			spin_unlock(&mm->page_table_lock);
 		}
+#endif
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
