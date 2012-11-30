Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 945F46B00EB
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:59:07 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so427555eaa.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:59:07 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 07/10] sched: Track quality and strength of convergence
Date: Fri, 30 Nov 2012 20:58:38 +0100
Message-Id: <1354305521-11583-8-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Track strength of convergence, which is a value between 1 and 1024.
This will be used by the placement logic later on.

A strength value of 1024 means that the workload has fully
converged, all faults after the last scan period came from a
single node.

A value of 1024/nr_nodes means a totally spread out working set.

'max_faults' is the number of faults observed on the highest-faulting node.
'sum_faults' are all faults from the last scan, averaged over ~16 periods.

The goal of the scheduler is to maximize convergence system-wide.
Once a task has converged, it carries with it a non-trivial amount
of working set. If such a task is migrated to another node later
on then its working set will migrate there as well, which is a
non-trivial cost.

So the ultimate goal of NUMA scheduling is to let as many tasks
converge as possible, and to run them as close to their memory
as possible.

( Note: we could also sample migration activities to directly measure
  how much convergence influx there is. )

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |  2 ++
 kernel/sched/core.c   |  2 ++
 kernel/sched/fair.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8eeb866..5b2cf2e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1509,6 +1509,8 @@ struct task_struct {
 	unsigned long numa_scan_ts_secs;
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
+	unsigned long convergence_strength;
+	int convergence_node;
 	unsigned long *numa_faults;
 	unsigned long *numa_faults_curr;
 	struct callback_head numa_scan_work;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index c5a707c..47b14d1 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1555,6 +1555,8 @@ static void __sched_fork(struct task_struct *p)
 
 	p->numa_shared = -1;
 	p->node_stamp = 0ULL;
+	p->convergence_strength		= 0;
+	p->convergence_node		= -1;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_faults = NULL;
 	p->numa_scan_period = sysctl_sched_numa_scan_delay;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7af89b7..1f6104a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1934,6 +1934,50 @@ clear_buddy:
 }
 
 /*
+ * Update the p->convergence_strength info, which is a value between 1 and 1024.
+ *
+ * A strength value of 1024 means that the workload has fully
+ * converged, all faults after the last scan period came from a
+ * single node.
+ *
+ * A value of 1024/nr_nodes means a totally spread out working set.
+ *
+ * 'max_faults' is the number of faults observed on the highest-faulting node.
+ * 'sum_faults' are all faults from the last scan, averaged over ~8 periods.
+ *
+ * The goal of the scheduler is to maximize convergence system-wide.
+ * Once a task has converged, it carries with it a non-trivial amount
+ * of working set. If such a task is migrated to another node later
+ * on then its working set will migrate there as well, which is a
+ * non-trivial cost.
+ *
+ * So the ultimate goal of NUMA scheduling is to let as many tasks
+ * converge as possible, and to run them as close to their memory
+ * as possible.
+ *
+ * ( Note: we could also sample migration activities to directly measure
+ *   how much convergence influx there is. )
+ */
+static void
+shared_fault_calc_convergence(struct task_struct *p, int max_node,
+			      unsigned long max_faults, unsigned long sum_faults)
+{
+	/*
+	 * If sum_faults is 0 then leave the convergence alone:
+	 */
+	if (sum_faults) {
+		p->convergence_strength = 1024L * max_faults / sum_faults;
+
+		if (p->convergence_strength >= 921) {
+			WARN_ON_ONCE(max_node == -1);
+			p->convergence_node = max_node;
+		} else {
+			p->convergence_node = -1;
+		}
+	}
+}
+
+/*
  * Called every couple of hundred milliseconds in the task's
  * execution life-time, this function decides whether to
  * change placement parameters:
@@ -1974,6 +2018,8 @@ static void task_numa_placement_tick(struct task_struct *p)
 		}
 	}
 
+	shared_fault_calc_convergence(p, ideal_node, max_faults, total[0] + total[1]);
+
 	shared_fault_full_scan_done(p);
 
 	/*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
