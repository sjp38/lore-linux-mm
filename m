Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A5A906B004D
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 19:09:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/15] sched: Set the scan rate proportional to the size of the task being scanned
Date: Sat,  6 Jul 2013 00:08:57 +0100
Message-Id: <1373065742-9753-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1373065742-9753-1-git-send-email-mgorman@suse.de>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The NUMA PTE scan rate is controlled with a combination of the
numa_balancing_scan_period_min, numa_balancing_scan_period_max and
numa_balancing_scan_size. This scan rate is independent of the size
of the task and as an aside it is further complicated by the fact that
numa_balancing_scan_size controls how many pages are marked pte_numa and
not how much virtual memory is scanned.

In combination, it is almost impossible to meaningfully tune the min and
max scan periods and reasoning about performance is complex when the time
to complete a full scan is is partially a function of the tasks memory
size. This patch alters the semantic of the min and max tunables to be
about tuning the length time it takes to complete a scan of a tasks virtual
address space. Conceptually this is a lot easier to understand. There is a
"sanity" check to ensure the scan rate is never extremely fast based on the
amount of virtual memory that should be scanned in a second. The default
of 2.5G seems arbitrary but it is to have the maximum scan rate after the
patch roughly match the maximum scan rate before the patch was applied.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 11 ++++---
 include/linux/sched.h           |  1 +
 kernel/sched/fair.c             | 72 +++++++++++++++++++++++++++++++++++------
 3 files changed, 70 insertions(+), 14 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index a275042..f38d4f4 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -401,15 +401,16 @@ workload pattern changes and minimises performance impact due to remote
 memory accesses. These sysctls control the thresholds for scan delays and
 the number of pages scanned.
 
-numa_balancing_scan_period_min_ms is the minimum delay in milliseconds
-between scans. It effectively controls the maximum scanning rate for
-each task.
+numa_balancing_scan_period_min_ms is the minimum time in milliseconds to
+scan a tasks virtual memory. It effectively controls the maximum scanning
+rate for each task.
 
 numa_balancing_scan_delay_ms is the starting "scan delay" used for a task
 when it initially forks.
 
-numa_balancing_scan_period_max_ms is the maximum delay between scans. It
-effectively controls the minimum scanning rate for each task.
+numa_balancing_scan_period_max_ms is the maximum time in milliseconds to
+scan a tasks virtual memory. It effectively controls the minimum scanning
+rate for each task.
 
 numa_balancing_scan_size_mb is how many megabytes worth of pages are
 scanned for a given scan.
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b81195e..d44fbc6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1504,6 +1504,7 @@ struct task_struct {
 	int numa_scan_seq;
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
+	unsigned int numa_scan_period_max;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index aee3e0b..66306c7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -779,10 +779,12 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
 
 #ifdef CONFIG_NUMA_BALANCING
 /*
- * numa task sample period in ms
+ * Approximate time to scan a full NUMA task in ms. The task scan period is
+ * calculated based on the tasks virtual memory size and
+ * numa_balancing_scan_size.
  */
-unsigned int sysctl_numa_balancing_scan_period_min = 100;
-unsigned int sysctl_numa_balancing_scan_period_max = 100*600;
+unsigned int sysctl_numa_balancing_scan_period_min = 1000;
+unsigned int sysctl_numa_balancing_scan_period_max = 600000;
 
 /* Portion of address space to scan in MB */
 unsigned int sysctl_numa_balancing_scan_size = 256;
@@ -790,6 +792,46 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
+static unsigned int task_nr_scan_windows(struct task_struct *p)
+{
+	unsigned long nr_vm_pages = 0;
+	unsigned long nr_scan_pages;
+
+	nr_scan_pages = sysctl_numa_balancing_scan_size << (20 - PAGE_SHIFT);
+	nr_vm_pages = p->mm->total_vm;
+	if (!nr_vm_pages)
+		nr_vm_pages = nr_scan_pages;
+
+	nr_vm_pages = round_up(nr_vm_pages, nr_scan_pages);
+	return nr_vm_pages / nr_scan_pages;
+}
+
+/* For sanitys sake, never scan more PTEs than MAX_SCAN_WINDOW MB/sec. */
+#define MAX_SCAN_WINDOW 2560
+
+static unsigned int task_scan_min(struct task_struct *p)
+{
+	unsigned int scan, floor;
+	unsigned int windows = 1;
+
+	if (sysctl_numa_balancing_scan_size < MAX_SCAN_WINDOW)
+		windows = MAX_SCAN_WINDOW / sysctl_numa_balancing_scan_size;
+	floor = 1000 / windows;
+
+	scan = sysctl_numa_balancing_scan_period_min / task_nr_scan_windows(p);
+	return max_t(unsigned int, floor, scan);
+}
+
+static unsigned int task_scan_max(struct task_struct *p)
+{
+	unsigned int smin = task_scan_min(p);
+	unsigned int smax;
+
+	/* Watch for min being lower than max due to floor calculations */
+	smax = sysctl_numa_balancing_scan_period_max / task_nr_scan_windows(p);
+	return max(smin, smax);
+}
+
 /*
  * Once a preferred node is selected the scheduler balancer will prefer moving
  * a task to that node for sysctl_numa_balancing_settle_count number of PTE
@@ -848,6 +890,7 @@ static void task_numa_placement(struct task_struct *p)
 		return;
 	p->numa_scan_seq = seq;
 	p->numa_migrate_seq++;
+	p->numa_scan_period_max = task_scan_max(p);
 
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
@@ -903,7 +946,7 @@ static void task_numa_placement(struct task_struct *p)
 		 */
 		if (old_migrate_seq >= sysctl_numa_balancing_settle_count) {
 			p->numa_scan_period = max(p->numa_scan_period >> 1,
-					sysctl_numa_balancing_scan_period_min);
+					task_scan_min(p));
 		}
 	}
 }
@@ -944,7 +987,7 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 	 * This is reset periodically in case of phase changes
 	 */
         if (!migrated)
-		p->numa_scan_period = min(sysctl_numa_balancing_scan_period_max,
+		p->numa_scan_period = min(p->numa_scan_period_max,
 			p->numa_scan_period + jiffies_to_msecs(10));
 
 	task_numa_placement(p);
@@ -970,6 +1013,7 @@ void task_numa_work(struct callback_head *work)
 	struct mm_struct *mm = p->mm;
 	struct vm_area_struct *vma;
 	unsigned long start, end;
+	unsigned long nr_pte_updates = 0;
 	long pages;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
@@ -1011,8 +1055,10 @@ void task_numa_work(struct callback_head *work)
 	if (time_before(now, migrate))
 		return;
 
-	if (p->numa_scan_period == 0)
-		p->numa_scan_period = sysctl_numa_balancing_scan_period_min;
+	if (p->numa_scan_period == 0) {
+		p->numa_scan_period_max = task_scan_max(p);
+		p->numa_scan_period = task_scan_min(p);
+	}
 
 	next_scan = now + msecs_to_jiffies(p->numa_scan_period);
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
@@ -1051,7 +1097,15 @@ void task_numa_work(struct callback_head *work)
 			start = max(start, vma->vm_start);
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
 			end = min(end, vma->vm_end);
-			pages -= change_prot_numa(vma, start, end);
+			nr_pte_updates += change_prot_numa(vma, start, end);
+
+			/*
+			 * Scan sysctl_numa_balancing_scan_size but ensure that
+			 * at least one PTE is updated so that unused virtual
+			 * address space is quickly skipped.
+			 */
+			if (nr_pte_updates)
+				pages -= (end - start) >> PAGE_SHIFT;
 
 			start = end;
 			if (pages <= 0)
@@ -1098,7 +1152,7 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 
 	if (now - curr->node_stamp > period) {
 		if (!curr->node_stamp)
-			curr->numa_scan_period = sysctl_numa_balancing_scan_period_min;
+			curr->numa_scan_period = task_scan_min(curr);
 		curr->node_stamp = now;
 
 		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
