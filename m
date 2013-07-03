Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3834C6B003A
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/13] sched: Increase NUMA PTE scanning when a new preferred node is selected
Date: Wed,  3 Jul 2013 15:21:35 +0100
Message-Id: <1372861300-9973-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The NUMA PTE scan is reset every sysctl_numa_balancing_scan_period_reset
in case of phase changes. This is crude and it is clearly visible in graphs
when the PTE scanner resets even if the workload is already balanced. This
patch increases the scan rate if the preferred node is updated and the
task is currently running on the node to recheck if the placement
decision is correct. In the optimistic expectation that the placement
decisions will be correct, the maximum period between scans is also
increased to reduce overhead due to automatic NUMA balancing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 11 +++--------
 include/linux/mm_types.h        |  3 ---
 include/linux/sched/sysctl.h    |  1 -
 kernel/sched/core.c             |  1 -
 kernel/sched/fair.c             | 27 ++++++++++++---------------
 kernel/sysctl.c                 |  7 -------
 6 files changed, 15 insertions(+), 35 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 246b128..a275042 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -373,15 +373,13 @@ guarantee. If the target workload is already bound to NUMA nodes then this
 feature should be disabled. Otherwise, if the system overhead from the
 feature is too high then the rate the kernel samples for NUMA hinting
 faults may be controlled by the numa_balancing_scan_period_min_ms,
-numa_balancing_scan_delay_ms, numa_balancing_scan_period_reset,
-numa_balancing_scan_period_max_ms, numa_balancing_scan_size_mb and
-numa_balancing_settle_count sysctls.
+numa_balancing_scan_delay_ms, numa_balancing_scan_period_max_ms,
+numa_balancing_scan_size_mb and numa_balancing_settle_count sysctls.
 
 ==============================================================
 
 numa_balancing_scan_period_min_ms, numa_balancing_scan_delay_ms,
-numa_balancing_scan_period_max_ms, numa_balancing_scan_period_reset,
-numa_balancing_scan_size_mb
+numa_balancing_scan_period_max_ms, numa_balancing_scan_size_mb
 
 Automatic NUMA balancing scans tasks address space and unmaps pages to
 detect if pages are properly placed or if the data should be migrated to a
@@ -416,9 +414,6 @@ effectively controls the minimum scanning rate for each task.
 numa_balancing_scan_size_mb is how many megabytes worth of pages are
 scanned for a given scan.
 
-numa_balancing_scan_period_reset is a blunt instrument that controls how
-often a tasks scan delay is reset to detect sudden changes in task behaviour.
-
 numa_balancing_settle_count is how many scan periods must complete before
 the schedule balancer stops pushing the task towards a preferred node. This
 gives the scheduler a chance to place the task on an alternative node if the
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..de70964 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -421,9 +421,6 @@ struct mm_struct {
 	 */
 	unsigned long numa_next_scan;
 
-	/* numa_next_reset is when the PTE scanner period will be reset */
-	unsigned long numa_next_reset;
-
 	/* Restart point for scanning and setting pte_numa */
 	unsigned long numa_scan_offset;
 
diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index bf8086b..10d16c4f 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -47,7 +47,6 @@ extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 extern unsigned int sysctl_numa_balancing_scan_delay;
 extern unsigned int sysctl_numa_balancing_scan_period_min;
 extern unsigned int sysctl_numa_balancing_scan_period_max;
-extern unsigned int sysctl_numa_balancing_scan_period_reset;
 extern unsigned int sysctl_numa_balancing_scan_size;
 extern unsigned int sysctl_numa_balancing_settle_count;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index b4722d6..2d1fd93 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1585,7 +1585,6 @@ static void __sched_fork(struct task_struct *p)
 #ifdef CONFIG_NUMA_BALANCING
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
 		p->mm->numa_next_scan = jiffies;
-		p->mm->numa_next_reset = jiffies;
 		p->mm->numa_scan_seq = 0;
 	}
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index a66f2bb..e8d9b3e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -782,8 +782,7 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * numa task sample period in ms
  */
 unsigned int sysctl_numa_balancing_scan_period_min = 100;
-unsigned int sysctl_numa_balancing_scan_period_max = 100*50;
-unsigned int sysctl_numa_balancing_scan_period_reset = 100*600;
+unsigned int sysctl_numa_balancing_scan_period_max = 100*600;
 
 /* Portion of address space to scan in MB */
 unsigned int sysctl_numa_balancing_scan_size = 256;
@@ -879,6 +878,7 @@ static void task_numa_placement(struct task_struct *p)
 	 */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 		int preferred_cpu;
+		int old_migrate_seq = p->numa_migrate_seq;
 
 		/*
 		 * If the task is not on the preferred node then find the most
@@ -891,6 +891,16 @@ static void task_numa_placement(struct task_struct *p)
 		}
 
 		sched_setnuma(p, max_nid, preferred_cpu);
+
+		/*
+		 * If preferred nodes changes frequently then the scan rate
+		 * will be continually high. Mitigate this by increaseing the
+		 * scan rate only if the task was settled.
+		 */
+		if (old_migrate_seq >= sysctl_numa_balancing_settle_count) {
+			p->numa_scan_period = max(p->numa_scan_period >> 1,
+					sysctl_numa_balancing_scan_period_min);
+		}
 	}
 }
 
@@ -984,19 +994,6 @@ void task_numa_work(struct callback_head *work)
 	}
 
 	/*
-	 * Reset the scan period if enough time has gone by. Objective is that
-	 * scanning will be reduced if pages are properly placed. As tasks
-	 * can enter different phases this needs to be re-examined. Lacking
-	 * proper tracking of reference behaviour, this blunt hammer is used.
-	 */
-	migrate = mm->numa_next_reset;
-	if (time_after(now, migrate)) {
-		p->numa_scan_period = sysctl_numa_balancing_scan_period_min;
-		next_scan = now + msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
-		xchg(&mm->numa_next_reset, next_scan);
-	}
-
-	/*
 	 * Enforce maximal scan/migration frequency..
 	 */
 	migrate = mm->numa_next_scan;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 263486f..1fcbc68 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -373,13 +373,6 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "numa_balancing_scan_period_reset",
-		.data		= &sysctl_numa_balancing_scan_period_reset,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "numa_balancing_scan_period_max_ms",
 		.data		= &sysctl_numa_balancing_scan_period_max,
 		.maxlen		= sizeof(unsigned int),
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
