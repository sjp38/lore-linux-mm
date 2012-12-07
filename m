Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 11AF16B00C7
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:07 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 40/49] mm: sched: Adapt the scanning rate if a NUMA hinting fault does not migrate
Date: Fri,  7 Dec 2012 10:23:43 +0000
Message-Id: <1354875832-9700-41-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The PTE scanning rate and fault rates are two of the biggest sources of
system CPU overhead with automatic NUMA placement.  Ideally a proper policy
would detect if a workload was properly placed, schedule and adjust the
PTE scanning rate accordingly. We do not track the necessary information
to do that but we at least know if we migrated or not.

This patch scans slower if a page was not migrated as the result of a
NUMA hinting fault up to sysctl_balance_numa_scan_period_max which is
now higher than the previous default. Once every minute it will reset
the scanner in case of phase changes.

This is hilariously crude and the numbers are arbitrary. Workloads will
converge quite slowly in comparison to what a proper policy should be able
to do. On the plus side, we will chew up less CPU for workloads that have
no need for automatic balancing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |    3 +++
 include/linux/sched.h    |    5 +++--
 kernel/sched/core.c      |    1 +
 kernel/sched/fair.c      |   29 +++++++++++++++++++++--------
 kernel/sysctl.c          |    7 +++++++
 mm/huge_memory.c         |    2 +-
 mm/memory.c              |   12 ++++++++----
 7 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6b478ff..62d18a9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -410,6 +410,9 @@ struct mm_struct {
 	 */
 	unsigned long numa_next_scan;
 
+	/* numa_next_reset is when the PTE scanner period will be reset */
+	unsigned long numa_next_reset;
+
 	/* Restart point for scanning and setting pte_numa */
 	unsigned long numa_scan_offset;
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a2b06ea..1068afd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1562,9 +1562,9 @@ struct task_struct {
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
 #ifdef CONFIG_BALANCE_NUMA
-extern void task_numa_fault(int node, int pages);
+extern void task_numa_fault(int node, int pages, bool migrated);
 #else
-static inline void task_numa_fault(int node, int pages)
+static inline void task_numa_fault(int node, int pages, bool migrated)
 {
 }
 #endif
@@ -2009,6 +2009,7 @@ extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 extern unsigned int sysctl_balance_numa_scan_delay;
 extern unsigned int sysctl_balance_numa_scan_period_min;
 extern unsigned int sysctl_balance_numa_scan_period_max;
+extern unsigned int sysctl_balance_numa_scan_period_reset;
 extern unsigned int sysctl_balance_numa_scan_size;
 extern unsigned int sysctl_balance_numa_settle_count;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 047e3c7..a59d869 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1537,6 +1537,7 @@ static void __sched_fork(struct task_struct *p)
 #ifdef CONFIG_BALANCE_NUMA
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
 		p->mm->numa_next_scan = jiffies;
+		p->mm->numa_next_reset = jiffies;
 		p->mm->numa_scan_seq = 0;
 	}
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3c632448..c1be907 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -784,7 +784,8 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * numa task sample period in ms
  */
 unsigned int sysctl_balance_numa_scan_period_min = 100;
-unsigned int sysctl_balance_numa_scan_period_max = 100*16;
+unsigned int sysctl_balance_numa_scan_period_max = 100*50;
+unsigned int sysctl_balance_numa_scan_period_reset = 100*600;
 
 /* Portion of address space to scan in MB */
 unsigned int sysctl_balance_numa_scan_size = 256;
@@ -806,20 +807,19 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int pages)
+void task_numa_fault(int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
 
 	/* FIXME: Allocate task-specific structure for placement policy here */
 
 	/*
-	 * Assume that as faults occur that pages are getting properly placed
-	 * and fewer NUMA hints are required. Note that this is a big
-	 * assumption, it assumes processes reach a steady steady with no
-	 * further phase changes.
+	 * If pages are properly placed (did not migrate) then scan slower.
+	 * This is reset periodically in case of phase changes
 	 */
-	p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
-				p->numa_scan_period + jiffies_to_msecs(2));
+        if (!migrated)
+		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
+			p->numa_scan_period + jiffies_to_msecs(10));
 
 	task_numa_placement(p);
 }
@@ -858,6 +858,19 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 	/*
+	 * Reset the scan period if enough time has gone by. Objective is that
+	 * scanning will be reduced if pages are properly placed. As tasks
+	 * can enter different phases this needs to be re-examined. Lacking
+	 * proper tracking of reference behaviour, this blunt hammer is used.
+	 */
+	migrate = mm->numa_next_reset;
+	if (time_after(now, migrate)) {
+		p->numa_scan_period = sysctl_balance_numa_scan_period_min;
+		next_scan = now + msecs_to_jiffies(sysctl_balance_numa_scan_period_reset);
+		xchg(&mm->numa_next_reset, next_scan);
+	}
+
+	/*
 	 * Enforce maximal scan/migration frequency..
 	 */
 	migrate = mm->numa_next_scan;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5ee587d..c335f426 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -367,6 +367,13 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "balance_numa_scan_period_reset",
+		.data		= &sysctl_balance_numa_scan_period_reset,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "balance_numa_scan_period_max_ms",
 		.data		= &sysctl_balance_numa_scan_period_max,
 		.maxlen		= sizeof(unsigned int),
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4c6efa8..1327a03 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1067,7 +1067,7 @@ out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	if (page) {
 		put_page(page);
-		task_numa_fault(numa_node_id(), HPAGE_PMD_NR);
+		task_numa_fault(numa_node_id(), HPAGE_PMD_NR, false);
 	}
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 6a1e534..30e1335 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3468,6 +3468,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int current_nid = -1;
 	int target_nid;
+	bool migrated = false;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3509,12 +3510,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* Migrate to the requested node */
-	if (migrate_misplaced_page(page, target_nid))
+	migrated = migrate_misplaced_page(page, target_nid);
+	if (migrated)
 		current_nid = target_nid;
 
 out:
 	if (current_nid != -1)
-		task_numa_fault(current_nid, 1);
+		task_numa_fault(current_nid, 1, migrated);
 	return 0;
 }
 
@@ -3554,6 +3556,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct page *page;
 		int curr_nid = local_nid;
 		int target_nid;
+		bool migrated;
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3590,9 +3593,10 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		/* Migrate to the requested node */
 		pte_unmap_unlock(pte, ptl);
-		if (migrate_misplaced_page(page, target_nid))
+		migrated = migrate_misplaced_page(page, target_nid);
+		if (migrated)
 			curr_nid = target_nid;
-		task_numa_fault(curr_nid, 1);
+		task_numa_fault(curr_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
