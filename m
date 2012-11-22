Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C25038D0008
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:26:42 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 28/40] mm: numa: Add pte updates, hinting and migration stats
Date: Thu, 22 Nov 2012 19:25:41 +0000
Message-Id: <1353612353-1576-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1353612353-1576-1-git-send-email-mgorman@suse.de>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/vm_event_item.h |    6 ++++++
 include/linux/vmstat.h        |    8 ++++++++
 mm/huge_memory.c              |    1 +
 mm/memory.c                   |   12 ++++++++++++
 mm/mempolicy.c                |    2 ++
 mm/migrate.c                  |    3 ++-
 mm/vmstat.c                   |    6 ++++++
 7 files changed, 37 insertions(+), 1 deletion(-)

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
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 92a86b2..dffccfa 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -80,6 +80,14 @@ static inline void vm_events_fold_cpu(int cpu)
 
 #endif /* CONFIG_VM_EVENT_COUNTERS */
 
+#ifdef CONFIG_BALANCE_NUMA
+#define count_vm_numa_event(x)     count_vm_event(x)
+#define count_vm_numa_events(x, y) count_vm_events(x, y)
+#else
+#define count_vm_numa_event(x) do {} while (0)
+#define count_vm_numa_events(x, y) do {} while (0)
+#endif /* CONFIG_BALANCE_NUMA */
+
 #define __count_zone_vm_events(item, zone, delta) \
 		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
 		zone_idx(zone), delta)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b3d4c4b..8f89a98 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1033,6 +1033,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = pmd_page(pmd);
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
+	count_vm_numa_event(NUMA_HINT_FAULTS);
 
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1)
diff --git a/mm/memory.c b/mm/memory.c
index b23b081..8367142 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3477,6 +3477,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
+	count_vm_numa_event(NUMA_HINT_FAULTS);
 	page = vm_normal_page(vma, addr, pte);
 	if (!page) {
 		pte_unmap_unlock(ptep, ptl);
@@ -3485,6 +3486,8 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	get_page(page);
 	current_nid = page_to_nid(page);
+	if (current_nid == numa_node_id())
+		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 	target_nid = mpol_misplaced(page, vma, addr);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
@@ -3516,6 +3519,9 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
+	int local_nid = numa_node_id();
+	unsigned long nr_faults = 0;
+	unsigned long nr_faults_local = 0;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3564,10 +3570,16 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		curr_nid = page_to_nid(page);
 		task_numa_fault(curr_nid, 1);
 
+		nr_faults++;
+		if (curr_nid == local_nid)
+			nr_faults_local++;
+
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
 	pte_unmap_unlock(orig_pte, ptl);
 
+	count_vm_numa_events(NUMA_HINT_FAULTS, nr_faults);
+	count_vm_numa_events(NUMA_HINT_FAULTS_LOCAL, nr_faults_local);
 	return 0;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a7a62fe..516491f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -583,6 +583,8 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 	BUILD_BUG_ON(_PAGE_NUMA != _PAGE_PROTNONE);
 
 	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
+	if (nr_updated)
+		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
 
 	return nr_updated;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index a2c4567..4b876d2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1511,7 +1511,8 @@ int migrate_misplaced_page(struct page *page, int node)
 		if (nr_remaining) {
 			putback_lru_pages(&migratepages);
 			isolated = 0;
-		}
+		} else
+			count_vm_numa_event(NUMA_PAGE_MIGRATE);
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
