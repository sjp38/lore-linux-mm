Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 847546B0083
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:15:18 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/19] mm: numa: Add pte updates, hinting and migration stats
Date: Tue,  6 Nov 2012 09:14:52 +0000
Message-Id: <1352193295-26815-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It is tricky to quantify the basic cost of automatic NUMA placement in a
meaningful manner. This patch adds some vmstats that can be used as part
of a basic costing model.

u    = basic unit = sizeof(void *)
Ca   = cost of struct page access = sizeof(struct page) / u
Cpte = Cost PTE access = Ca
Cupdate = Cost PTE update = (2 * Cpte) + (2 * Wlock)
	where Cpte is incurred twice for a read and a write and Wlock
	is a constant representing the cost of taking or releasing a
	lock
Cnumahint = Cost of a minor page fault = some high constant e.g. 1000
Cpagerw = Cost to read or write a full page = Ca + PAGE_SIZE/u
Ci = Cost of page isolation = Ca + Wi
	where Wi is a constant that should reflect the approximate cost
	of the locking operation
Cpagecopy = Cpagerw + (Cpagerw * Wnuma) + Ci + (Ci * Wnuma)
	where Wnuma is the approximate NUMA factor. 1 is local. 1.2
	would imply that remote accesses are 20% more expensive

Balancing cost = Cpte * numa_pte_updates +
		Cnumahint * numa_hint_faults +
		Ci * numa_pages_migrated +
		Cpagecopy * numa_pages_migrated

Note that numa_pages_migrated is used as a measure of how many pages
were isolated even though it would miss pages that failed to migrate. A
vmstat counter could have been added for it but the isolation cost is
pretty marginal in comparison to the overall cost so it seemed overkill.

The ideal way to measure automatic placement benefit would be to count
the number of remote accesses versus local accesses and do something like

	benefit = (remote_accesses_before - remove_access_after) * Wnuma

but the information is not readily available. As a workload converges, the
expection would be that the number of remote numa hints would reduce to 0.

	convergence = numa_hint_faults_local / numa_hint_faults
		where this is measured for the last N number of
		numa hints recorded. When the workload is fully
		converged the value is 1.

This can measure if the placement policy is converging and how fast it is
doing it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    6 ++++++
 mm/huge_memory.c              |    1 +
 mm/memory.c                   |    3 +++
 mm/mempolicy.c                |    6 ++++++
 mm/migrate.c                  |    3 ++-
 mm/vmstat.c                   |    6 ++++++
 6 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index a1f750b..dded0af 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -38,6 +38,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_BALANCE_NUMA
+		NUMA_PTE_UPDATES,
+		NUMA_HINT_FAULTS,
+		NUMA_HINT_FAULTS_LOCAL,
+		NUMA_PAGE_MIGRATE,
+#endif
 #ifdef CONFIG_MIGRATION
 		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 91f9b06..a82a313 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1033,6 +1033,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = pmd_page(pmd);
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
+	count_vm_event(NUMA_HINT_FAULTS);
 
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1)
diff --git a/mm/memory.c b/mm/memory.c
index a63daf9..2780948 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3456,11 +3456,14 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*ptep, pte)))
 		goto out_unlock;
 
+	count_vm_event(NUMA_HINT_FAULTS);
 	page = vm_normal_page(vma, addr, pte);
 	BUG_ON(!page);
 
 	get_page(page);
 	current_nid = page_to_nid(page);
+	if (current_nid == numa_node_id())
+		count_vm_event(NUMA_HINT_FAULTS_LOCAL);
 	target_nid = mpol_misplaced(page, vma, addr);
 	if (target_nid == -1)
 		goto clear_pmdnuma;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index abe2e45..e25da64 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -583,6 +583,7 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long _address, end;
 	spinlock_t *ptl;
 	int ret = 0;
+	int nr_pte_updates = 0;
 
 	VM_BUG_ON(address & ~PAGE_MASK);
 
@@ -625,6 +626,7 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
+		nr_pte_updates++;
 		/* defer TLB flush to lower the overhead */
 		spin_unlock(&mm->page_table_lock);
 		goto out;
@@ -654,6 +656,7 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 			continue;
 
 		set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
+		nr_pte_updates++;
 
 		/* defer TLB flush to lower the overhead */
 		ret++;
@@ -668,6 +671,8 @@ change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 out:
+	if (nr_pte_updates)
+		count_vm_events(NUMA_PTE_UPDATES, nr_pte_updates);
 	return ret;
 }
 
@@ -694,6 +699,7 @@ change_prot_numa(struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(vma->vm_mm, address, end);
 	flush_tlb_range(vma, address, end);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, address, end);
+
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index 4a92808..14e2a31 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1508,7 +1508,8 @@ int migrate_misplaced_page(struct page *page, int node)
 		if (nr_remaining) {
 			putback_lru_pages(&migratepages);
 			isolated = 0;
-		}
+		} else
+			count_vm_event(NUMA_PAGE_MIGRATE);
 	}
 	BUG_ON(!list_empty(&migratepages));
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3a067fa..cfa386da 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -774,6 +774,12 @@ const char * const vmstat_text[] = {
 
 	"pgrotated",
 
+#ifdef CONFIG_BALANCE_NUMA
+	"numa_pte_updates",
+	"numa_hint_faults",
+	"numa_hint_faults_local",
+	"numa_pages_migrated",
+#endif
 #ifdef CONFIG_MIGRATION
 	"pgmigrate_success",
 	"pgmigrate_fail",
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
