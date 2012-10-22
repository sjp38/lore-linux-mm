Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 05D276B0072
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:13:46 -0400 (EDT)
Date: Mon, 22 Oct 2012 09:06:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/5] mm: autonuma: Add pte updates, hinting and migration
 stats for AutoNUMA
Message-ID: <20121022080616.GC2198@suse.de>
References: <1350892791-2682-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1350892791-2682-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

The system CPU cost of AutoNUMA is known to be high but it is tricky to
quantify the cost in a meaningful manner. This patch adds some vmstats
that can be used as part of a basic costing model.

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

AutoNUMA cost = Cpte * numa_pte_updates +
		Cnumahint * numa_hint_faults +
		Ci * numa_pages_migrated +
		Cpagecopy * numa_pages_migrated

Note that numa_pages_migrated is used as a measure of how many pages
were isolated even though it would miss pages that failed to migrate. A
vmstat counter could have been added for it but the isolation cost is
pretty marginal in comparison to the overall cost so it seemed overkill.

The ideal way to measure AutoNUMA benefit would be to count the number
of remote accesses versus local accesses and do something like

	benefit = (remote_accesses_before - remove_access_after) * Wnuma

but the information is not readily available. However, for two given
versions of AutoNUMA we can at least estimate if one is better than the
other in terms of convergence.  As a workload converges, the expection
would be that the number of remote numa hints would reduce to 0.

	convergence = numa_hint_faults_local / numa_hint_faults
		where this is measured for the last N number of
		numa hints recorded. When the workload is fully
		converged the value is 1.

This can measure if AutoNUMA is converging and how fast it is doing it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    6 ++++++
 mm/autonuma.c                 |   19 +++++++++++++++----
 mm/vmstat.c                   |    6 ++++++
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 83ea0b6..53eb132 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -38,6 +38,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_AUTONUMA
+		NUMA_PTE_UPDATES,
+		NUMA_HINT_FAULTS,
+		NUMA_HINT_FAULTS_LOCAL,
+		NUMA_PAGE_MIGRATE,
+#endif
 #ifdef CONFIG_MIGRATION
 		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
 #endif
diff --git a/mm/autonuma.c b/mm/autonuma.c
index f1e699f..4db53a1 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -245,11 +245,13 @@ static bool autonuma_migrate_page(struct page *page, int dst_nid,
 						     migrated);
 
 	if (isolated) {
-		int err;
+		int nr_remaining;
 		pages_migrated += isolated; /* FIXME: per node */
-		err = migrate_pages(&migratepages, alloc_migrate_dst_page,
+		nr_remaining = migrate_pages(&migratepages,
+				    alloc_migrate_dst_page,
 				    pgdat->node_id, false, MIGRATE_ASYNC);
-		if (err)
+		count_vm_events(NUMA_PAGE_MIGRATE, isolated - nr_remaining);
+		if (nr_remaining)
 			putback_lru_pages(&migratepages);
 	}
 	BUG_ON(!list_empty(&migratepages));
@@ -364,6 +366,8 @@ bool numa_hinting_fault(struct page *page, int numpages)
 			p->mm->mm_autonuma->mm_numa_fault_pass;
 		page_nid = page_to_nid(page);
 		this_nid = numa_node_id();
+		if (page_nid == this_nid)
+			count_vm_event(NUMA_HINT_FAULTS_LOCAL);
 		VM_BUG_ON(this_nid < 0);
 		VM_BUG_ON(this_nid >= MAX_NUMNODES);
 		access_nid = numa_hinting_fault_memory_follow_cpu(page,
@@ -423,6 +427,7 @@ out:
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
+	count_vm_event(NUMA_HINT_FAULTS);
 	goto out;
 }
 
@@ -571,6 +576,7 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 	unsigned long _address, end;
 	spinlock_t *ptl;
 	int ret = 0;
+	int nr_pte_updates = 0;
 
 	VM_BUG_ON(address & ~PAGE_MASK);
 
@@ -616,6 +622,7 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		}
 
 		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
+		nr_pte_updates++;
 		/* defer TLB flush to lower the overhead */
 		spin_unlock(&mm->page_table_lock);
 		goto out;
@@ -648,8 +655,10 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		if (pte_numa(pteval))
 			continue;
 
-		if (!autonuma_scan_pmd())
+		if (!autonuma_scan_pmd()) {
 			set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
+			nr_pte_updates++;
+		}
 
 		/* defer TLB flush to lower the overhead */
 		ret++;
@@ -668,6 +677,8 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 	}
 
 out:
+	if (nr_pte_updates)
+		count_vm_events(NUMA_PTE_UPDATES, nr_pte_updates);
 	return ret;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ab0b1b1..58c2757 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -761,6 +761,12 @@ const char * const vmstat_text[] = {
 
 	"pgrotated",
 
+#ifdef CONFIG_AUTONUMA
+	"numa_pte_updates",
+	"numa_hint_faults",
+	"numa_hint_faults_local",
+	"numa_pages_migrated",
+#endif
 #ifdef CONFIG_MIGRATION
 	"pgmigrate_success",
 	"pgmigrate_fail",
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
