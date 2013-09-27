Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9E957900035
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:49 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2625133pde.10
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:49 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 58/63] sched: numa: adjust scan rate in task_numa_placement
Date: Fri, 27 Sep 2013 14:27:43 +0100
Message-Id: <1380288468-5551-59-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

Adjust numa_scan_period in task_numa_placement, depending on how much
useful work the numa code can do. The more local faults there are in a
given scan window the longer the period (and hence the slower the scan rate)
during the next window. If there are excessive shared faults then the scan
period will decrease with the amount of scaling depending on whether the
ratio of shared/private faults. If the preferred node changes then the
scan rate is reset to recheck if the task is properly placed.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |   9 ++++
 kernel/sched/fair.c   | 112 +++++++++++++++++++++++++++++++++++++++-----------
 mm/huge_memory.c      |   4 +-
 mm/memory.c           |   9 ++--
 4 files changed, 105 insertions(+), 29 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 718bb60..918baf3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1356,6 +1356,14 @@ struct task_struct {
 	 */
 	unsigned long *numa_faults_buffer;
 
+	/*
+	 * numa_faults_locality tracks if faults recorded during the last
+	 * scan window were remote/local. The task scan period is adapted
+	 * based on the locality of the faults with different weights
+	 * depending on whether they were shared or private faults
+	 */
+	unsigned long numa_faults_locality[2];
+
 	int numa_preferred_nid;
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
@@ -1439,6 +1447,7 @@ struct task_struct {
 #define TNF_MIGRATED	0x01
 #define TNF_NO_GROUP	0x02
 #define TNF_SHARED	0x04
+#define TNF_FAULT_LOCAL	0x08
 
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3486042..4f99c09 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1241,6 +1241,12 @@ static int task_numa_migrate(struct task_struct *p)
 
 	sched_setnuma(p, env.dst_nid);
 
+	/*
+	 * Reset the scan period if the task is being rescheduled on an
+	 * alternative node to recheck if the tasks is now properly placed.
+	 */
+	p->numa_scan_period = task_scan_min(p);
+
 	if (env.best_task == NULL) {
 		int ret = migrate_task_to(p, env.best_cpu);
 		return ret;
@@ -1276,10 +1282,86 @@ static void numa_migrate_preferred(struct task_struct *p)
 		p->numa_migrate_retry = jiffies + HZ*5;
 }
 
+/*
+ * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
+ * increments. The more local the fault statistics are, the higher the scan
+ * period will be for the next scan window. If local/remote ratio is below
+ * NUMA_PERIOD_THRESHOLD (where range of ratio is 1..NUMA_PERIOD_SLOTS) the
+ * scan period will decrease
+ */
+#define NUMA_PERIOD_SLOTS 10
+#define NUMA_PERIOD_THRESHOLD 3
+
+/*
+ * Increase the scan period (slow down scanning) if the majority of
+ * our memory is already on our local node, or if the majority of
+ * the page accesses are shared with other processes.
+ * Otherwise, decrease the scan period.
+ */
+static void update_task_scan_period(struct task_struct *p,
+			unsigned long shared, unsigned long private)
+{
+	unsigned int period_slot;
+	int ratio;
+	int diff;
+
+	unsigned long remote = p->numa_faults_locality[0];
+	unsigned long local = p->numa_faults_locality[1];
+
+	/*
+	 * If there were no record hinting faults then either the task is
+	 * completely idle or all activity is areas that are not of interest
+	 * to automatic numa balancing. Scan slower
+	 */
+	if (local + shared == 0) {
+		p->numa_scan_period = min(p->numa_scan_period_max,
+			p->numa_scan_period << 1);
+
+		p->mm->numa_next_scan = jiffies +
+			msecs_to_jiffies(p->numa_scan_period);
+
+		return;
+	}
+
+	/*
+	 * Prepare to scale scan period relative to the current period.
+	 *	 == NUMA_PERIOD_THRESHOLD scan period stays the same
+	 *       <  NUMA_PERIOD_THRESHOLD scan period decreases (scan faster)
+	 *	 >= NUMA_PERIOD_THRESHOLD scan period increases (scan slower)
+	 */
+	period_slot = DIV_ROUND_UP(p->numa_scan_period, NUMA_PERIOD_SLOTS);
+	ratio = (local * NUMA_PERIOD_SLOTS) / (local + remote);
+	if (ratio >= NUMA_PERIOD_THRESHOLD) {
+		int slot = ratio - NUMA_PERIOD_THRESHOLD;
+		if (!slot)
+			slot = 1;
+		diff = slot * period_slot;
+	} else {
+		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
+
+		/*
+		 * Scale scan rate increases based on sharing. There is an
+		 * inverse relationship between the degree of sharing and
+		 * the adjustment made to the scanning period. Broadly
+		 * speaking the intent is that there is little point
+		 * scanning faster if shared accesses dominate as it may
+		 * simply bounce migrations uselessly
+		 */
+		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
+		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
+		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
+	}
+
+	p->numa_scan_period = clamp(p->numa_scan_period + diff,
+			task_scan_min(p), task_scan_max(p));
+	memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1, max_group_nid = -1;
 	unsigned long max_faults = 0, max_group_faults = 0;
+	unsigned long fault_types[2] = { 0, 0 };
 	spinlock_t *group_lock = NULL;
 
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
@@ -1309,6 +1391,7 @@ static void task_numa_placement(struct task_struct *p)
 			/* Decay existing window, copy faults since last scan */
 			p->numa_faults[i] >>= 1;
 			p->numa_faults[i] += p->numa_faults_buffer[i];
+			fault_types[priv] += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
 
 			faults += p->numa_faults[i];
@@ -1333,6 +1416,8 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
+	update_task_scan_period(p, fault_types[0], fault_types[1]);
+
 	if (p->numa_group) {
 		/*
 		 * If the preferred task and group nids are different,
@@ -1538,6 +1623,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		BUG_ON(p->numa_faults_buffer);
 		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
 		p->total_numa_faults = 0;
+		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}
 
 	/*
@@ -1552,19 +1638,6 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 			task_numa_group(p, last_cpupid, flags, &priv);
 	}
 
-	/*
-	 * If pages are properly placed (did not migrate) then scan slower.
-	 * This is reset periodically in case of phase changes
-	 */
-	if (!migrated) {
-		/* Initialise if necessary */
-		if (!p->numa_scan_period_max)
-			p->numa_scan_period_max = task_scan_max(p);
-
-		p->numa_scan_period = min(p->numa_scan_period_max,
-			p->numa_scan_period + 10);
-	}
-
 	task_numa_placement(p);
 
 	/* Retry task to preferred node migration if it previously failed */
@@ -1575,6 +1648,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 		p->numa_pages_migrated += pages;
 
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
+	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
@@ -1702,18 +1776,6 @@ void task_numa_work(struct callback_head *work)
 
 out:
 	/*
-	 * If the whole process was scanned without updates then no NUMA
-	 * hinting faults are being recorded and scan rate should be lower.
-	 */
-	if (mm->numa_scan_offset == 0 && !nr_pte_updates) {
-		p->numa_scan_period = min(p->numa_scan_period_max,
-			p->numa_scan_period << 1);
-
-		next_scan = now + msecs_to_jiffies(p->numa_scan_period);
-		mm->numa_next_scan = next_scan;
-	}
-
-	/*
 	 * It is possible to reach the end of the VMA list but the last few
 	 * VMAs are not guaranteed to the vma_migratable. If they are not, we
 	 * would find the !migratable VMA on the next scan but not reset the
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index aaf46dc..22096da 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1308,8 +1308,10 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page_nid = page_to_nid(page);
 	last_cpupid = page_cpupid_last(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (page_nid == this_nid)
+	if (page_nid == this_nid) {
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
+		flags |= TNF_FAULT_LOCAL;
+	}
 
 	/*
 	 * Avoid grouping on DSO/COW pages in specific and RO pages
diff --git a/mm/memory.c b/mm/memory.c
index 7bef788..1865e4c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3538,13 +3538,16 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-				unsigned long addr, int page_nid)
+				unsigned long addr, int page_nid,
+				int *flags)
 {
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (page_nid == numa_node_id())
+	if (page_nid == numa_node_id()) {
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
+		*flags |= TNF_FAULT_LOCAL;
+	}
 
 	return mpol_misplaced(page, vma, addr);
 }
@@ -3604,7 +3607,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
+	target_nid = numa_migrate_prep(page, vma, addr, page_nid, &flags);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
 		put_page(page);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
