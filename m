Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A0BF59C0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:39 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so7176858pab.27
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:39 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 59/63] sched: numa: Remove the numa_balancing_scan_period_reset sysctl
Date: Mon,  7 Oct 2013 11:29:37 +0100
Message-Id: <1381141781-10992-60-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

With scan rate adaptions based on whether the workload has properly
converged or not there should be no need for the scan period reset
hammer. Get rid of it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 11 +++--------
 include/linux/mm_types.h        |  3 ---
 include/linux/sched/sysctl.h    |  1 -
 kernel/sched/core.c             |  1 -
 kernel/sched/fair.c             | 18 +-----------------
 kernel/sysctl.c                 |  7 -------
 6 files changed, 4 insertions(+), 37 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index d48bca4..84f1780 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -374,15 +374,13 @@ guarantee. If the target workload is already bound to NUMA nodes then this
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
@@ -418,9 +416,6 @@ rate for each task.
 numa_balancing_scan_size_mb is how many megabytes worth of pages are
 scanned for a given scan.
 
-numa_balancing_scan_period_reset is a blunt instrument that controls how
-often a tasks scan delay is reset to detect sudden changes in task behaviour.
-
 numa_balancing_settle_count is how many scan periods must complete before
 the schedule balancer stops pushing the task towards a preferred node. This
 gives the scheduler a chance to place the task on an alternative node if the
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a30f9ca..a3198e5 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -420,9 +420,6 @@ struct mm_struct {
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
index 86497b8..07d7c11 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1716,7 +1716,6 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 #ifdef CONFIG_NUMA_BALANCING
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
 		p->mm->numa_next_scan = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
-		p->mm->numa_next_reset = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
 		p->mm->numa_scan_seq = 0;
 	}
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d8514c8..38ec714 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -826,7 +826,6 @@ static unsigned long task_h_load(struct task_struct *p);
  */
 unsigned int sysctl_numa_balancing_scan_period_min = 1000;
 unsigned int sysctl_numa_balancing_scan_period_max = 60000;
-unsigned int sysctl_numa_balancing_scan_period_reset = 60000;
 
 /* Portion of address space to scan in MB */
 unsigned int sysctl_numa_balancing_scan_size = 256;
@@ -1685,24 +1684,9 @@ void task_numa_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
-	if (!mm->numa_next_reset || !mm->numa_next_scan) {
+	if (!mm->numa_next_scan) {
 		mm->numa_next_scan = now +
 			msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
-		mm->numa_next_reset = now +
-			msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
-	}
-
-	/*
-	 * Reset the scan period if enough time has gone by. Objective is that
-	 * scanning will be reduced if pages are properly placed. As tasks
-	 * can enter different phases this needs to be re-examined. Lacking
-	 * proper tracking of reference behaviour, this blunt hammer is used.
-	 */
-	migrate = mm->numa_next_reset;
-	if (time_after(now, migrate)) {
-		p->numa_scan_period = task_scan_min(p);
-		next_scan = now + msecs_to_jiffies(sysctl_numa_balancing_scan_period_reset);
-		xchg(&mm->numa_next_reset, next_scan);
 	}
 
 	/*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 42f616a..e509b90 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -371,13 +371,6 @@ static struct ctl_table kern_table[] = {
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
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
