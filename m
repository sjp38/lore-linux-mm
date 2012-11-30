Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 520E16B009D
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:59:14 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so657952eek.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:59:13 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 09/10] sched: Add convergence strength based adaptive NUMA page fault rate
Date: Fri, 30 Nov 2012 20:58:40 +0100
Message-Id: <1354305521-11583-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Mel Gorman reported that the NUMA code is system-time intense even
after a workload has converged.

To remedy this, turn sched_numa_scan_size into a range:

   sched_numa_scan_size_min        [default:  32 MB]
   sched_numa_scan_size_max        [default: 512 MB]

As workloads converge, so does their scanning activity get reduced.
If they unconverge again - for example because system load changes,
then their scanning will pick up again.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  3 ++-
 kernel/sched/fair.c   | 57 +++++++++++++++++++++++++++++++++++++++++++--------
 kernel/sysctl.c       | 11 ++++++++--
 3 files changed, 59 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5b2cf2e..ce834e7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2057,7 +2057,8 @@ extern enum sched_tunable_scaling sysctl_sched_tunable_scaling;
 extern unsigned int sysctl_sched_numa_scan_delay;
 extern unsigned int sysctl_sched_numa_scan_period_min;
 extern unsigned int sysctl_sched_numa_scan_period_max;
-extern unsigned int sysctl_sched_numa_scan_size;
+extern unsigned int sysctl_sched_numa_scan_size_min;
+extern unsigned int sysctl_sched_numa_scan_size_max;
 extern unsigned int sysctl_sched_numa_settle_count;
 
 #ifdef CONFIG_SCHED_DEBUG
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 10cbfa3..9262692 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -805,15 +805,17 @@ static unsigned long task_h_load(struct task_struct *p);
 /*
  * Scan @scan_size MB every @scan_period after an initial @scan_delay.
  */
-unsigned int sysctl_sched_numa_scan_delay = 1000;	/* ms */
-unsigned int sysctl_sched_numa_scan_period_min = 100;	/* ms */
-unsigned int sysctl_sched_numa_scan_period_max = 100*16;/* ms */
-unsigned int sysctl_sched_numa_scan_size = 256;		/* MB */
+unsigned int sysctl_sched_numa_scan_delay	__read_mostly = 1000;	/* ms */
+unsigned int sysctl_sched_numa_scan_period_min	__read_mostly = 100;	/* ms */
+unsigned int sysctl_sched_numa_scan_period_max	__read_mostly = 100*16;	/* ms */
+
+unsigned int sysctl_sched_numa_scan_size_min	__read_mostly =  32;	/* MB */
+unsigned int sysctl_sched_numa_scan_size_max	__read_mostly = 512;	/* MB */
 
 /*
  * Wait for the 2-sample stuff to settle before migrating again
  */
-unsigned int sysctl_sched_numa_settle_count = 2;
+unsigned int sysctl_sched_numa_settle_count	__read_mostly = 2;
 
 static int task_ideal_cpu(struct task_struct *p)
 {
@@ -2077,9 +2079,15 @@ static void task_numa_placement_tick(struct task_struct *p)
 			p->numa_faults[idx_oldnode] = 0;
 		}
 		sched_setnuma(p, ideal_node, shared);
+		/*
+		 * We changed a node, start scanning more frequently again
+		 * to map out the working set:
+		 */
+		p->numa_scan_period = sysctl_sched_numa_scan_period_min;
 	} else {
 		/* node unchanged, back off: */
-		p->numa_scan_period = min(p->numa_scan_period * 2, sysctl_sched_numa_scan_period_max);
+		p->numa_scan_period = min(p->numa_scan_period*2,
+						sysctl_sched_numa_scan_period_max);
 	}
 
 	this_cpu = task_cpu(p);
@@ -2238,6 +2246,7 @@ void task_numa_scan_work(struct callback_head *work)
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
 	struct vm_area_struct *vma;
+	long pages_min, pages_max;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_scan_work));
 
@@ -2260,10 +2269,40 @@ void task_numa_scan_work(struct callback_head *work)
 	current->numa_scan_period += jiffies_to_msecs(2);
 
 	start0 = start = end = mm->numa_scan_offset;
-	pages_total = sysctl_sched_numa_scan_size;
-	pages_total <<= 20 - PAGE_SHIFT; /* MB in pages */
-	if (!pages_total)
+
+	pages_max = sysctl_sched_numa_scan_size_max;
+	pages_max <<= 20 - PAGE_SHIFT; /* MB in pages */
+	if (!pages_max)
+		return;
+
+	pages_min = sysctl_sched_numa_scan_size_min;
+	pages_min <<= 20 - PAGE_SHIFT; /* MB in pages */
+	if (!pages_min)
+		return;
+
+	if (WARN_ON_ONCE(p->convergence_strength < 0 || p->convergence_strength > 1024))
 		return;
+	if (WARN_ON_ONCE(pages_min > pages_max))
+		return;
+
+	/*
+	 * Convergence strength is a number in the range of
+	 * 0 ... 1024.
+	 *
+	 * As tasks converge, scale down our scanning to the minimum
+	 * of the allowed range. Shortly after they get unsettled
+	 * (because the workload changes or the system is loaded
+	 * differently), scanning revs up again.
+	 *
+	 * The important thing is that when the system is in an
+	 * equilibrium, we do the minimum amount of scanning.
+	 */
+
+	pages_total = pages_min;
+	pages_total += (pages_max - pages_min)*(1024-p->convergence_strength)/1024;
+
+	pages_total = max(pages_min, pages_total);
+	pages_total = min(pages_max, pages_total);
 
 	sum_pages_scanned = 0;
 	pages_left = pages_total;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6d2fe5b..b6ddfae 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -374,8 +374,15 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "sched_numa_scan_size_mb",
-		.data		= &sysctl_sched_numa_scan_size,
+		.procname	= "sched_numa_scan_size_min_mb",
+		.data		= &sysctl_sched_numa_scan_size_min,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sched_numa_scan_size_max_mb",
+		.data		= &sysctl_sched_numa_scan_size_max,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
