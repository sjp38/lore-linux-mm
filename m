Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 845C66B0070
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:50 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277745eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:50 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 7/9] numa, sched: Improve staggered convergence
Date: Fri,  7 Dec 2012 01:19:24 +0100
Message-Id: <1354839566-15697-8-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Add/tune two convergence mechanisms:

 - add a sysctl for the fault moving average weight factor
   and change it to 3

 - add an initial settlement delay of 2 periods

 - add back parts of the throttling that triggers after a
   task migrates, to let it settle - with a sysctl that is
   set to 0 for now.

This tunes the code to be in harmony with our changed and
more precise 'cpupid' fault statistics, which allows us to
converge more aggressively without introducing destabilizing
turbulences into the convergence flow.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h   |  2 ++
 kernel/sched/core.c     |  1 +
 kernel/sched/fair.c     | 78 ++++++++++++++++++++++++++++++++++++-------------
 kernel/sched/features.h |  2 ++
 kernel/sysctl.c         |  8 +++++
 5 files changed, 71 insertions(+), 20 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1041c0d..6e63022 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1509,6 +1509,7 @@ struct task_struct {
 	int numa_max_node;
 	int numa_scan_seq;
 	unsigned long numa_scan_ts_secs;
+	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
 	unsigned long convergence_strength;
@@ -2064,6 +2065,7 @@ extern unsigned int sysctl_sched_numa_scan_size_min;
 extern unsigned int sysctl_sched_numa_scan_size_max;
 extern unsigned int sysctl_sched_numa_rss_threshold;
 extern unsigned int sysctl_sched_numa_settle_count;
+extern unsigned int sysctl_sched_numa_fault_weight;
 
 #ifdef CONFIG_SCHED_DEBUG
 extern unsigned int sysctl_sched_migration_cost;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index cfa8426..3c74af7 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1562,6 +1562,7 @@ static void __sched_fork(struct task_struct *p)
 	p->convergence_strength		= 0;
 	p->convergence_node		= -1;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
+	p->numa_migrate_seq = 2;
 	p->numa_faults = NULL;
 	p->numa_scan_period = sysctl_sched_numa_scan_delay;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1547d66..fd49920 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -854,9 +854,20 @@ unsigned int sysctl_sched_numa_scan_size_max	__read_mostly = 512;	/* MB */
 unsigned int sysctl_sched_numa_rss_threshold	__read_mostly = 128;	/* MB */
 
 /*
- * Wait for the 2-sample stuff to settle before migrating again
+ * Wait for the 3-sample stuff to settle before migrating again
  */
-unsigned int sysctl_sched_numa_settle_count	__read_mostly = 2;
+unsigned int sysctl_sched_numa_settle_count	__read_mostly = 0;
+
+/*
+ * Weight of decay of the fault stats:
+ */
+unsigned int sysctl_sched_numa_fault_weight	__read_mostly = 3;
+
+static void task_numa_migrate(struct task_struct *p, int next_cpu)
+{
+	if (cpu_to_node(next_cpu) != cpu_to_node(task_cpu(p)))
+		p->numa_migrate_seq = 0;
+}
 
 static int task_ideal_cpu(struct task_struct *p)
 {
@@ -2051,7 +2062,9 @@ static void task_numa_placement_tick(struct task_struct *p)
 {
 	unsigned long total[2] = { 0, 0 };
 	unsigned long faults, max_faults = 0;
-	int node, priv, shared, ideal_node = -1;
+	unsigned long total_priv, total_shared;
+	int node, priv, new_shared, prev_shared, ideal_node = -1;
+	int settle_limit;
 	int flip_tasks;
 	int this_node;
 	int this_cpu;
@@ -2065,14 +2078,17 @@ static void task_numa_placement_tick(struct task_struct *p)
 		for (priv = 0; priv < 2; priv++) {
 			unsigned int new_faults;
 			unsigned int idx;
+			unsigned int weight;
 
 			idx = 2*node + priv;
 			new_faults = p->numa_faults_curr[idx];
 			p->numa_faults_curr[idx] = 0;
 
-			/* Keep a simple running average: */
-			p->numa_faults[idx] = p->numa_faults[idx]*15 + new_faults;
-			p->numa_faults[idx] /= 16;
+			/* Keep a simple exponential moving average: */
+			weight = sysctl_sched_numa_fault_weight;
+
+			p->numa_faults[idx] = p->numa_faults[idx]*(weight-1) + new_faults;
+			p->numa_faults[idx] /= weight;
 
 			faults += p->numa_faults[idx];
 			total[priv] += p->numa_faults[idx];
@@ -2092,23 +2108,38 @@ static void task_numa_placement_tick(struct task_struct *p)
 	 * we might want to consider a different equation below to reduce
 	 * the impact of a little private memory accesses.
 	 */
-	shared = p->numa_shared;
-
-	if (shared < 0) {
-		shared = (total[0] >= total[1]);
-	} else if (shared == 0) {
-		/* If it was private before, make it harder to become shared: */
-		if (total[0] >= total[1]*2)
-			shared = 1;
-	} else if (shared == 1 ) {
+	prev_shared = p->numa_shared;
+	new_shared = prev_shared;
+
+	settle_limit = sysctl_sched_numa_settle_count;
+
+	/*
+	 * Note: shared is spread across multiple tasks and in the future
+	 * we might want to consider a different equation below to reduce
+	 * the impact of a little private memory accesses.
+	 */
+	total_priv = total[1] / 2;
+	total_shared = total[0];
+
+	if (prev_shared < 0) {
+		/* Start out as private: */
+		new_shared = 0;
+	} else if (prev_shared == 0 && p->numa_migrate_seq >= settle_limit) {
+		/*
+		 * Hysteresis: if it was private before, make it harder to
+		 * become shared:
+		 */
+		if (total_shared*2 >= total_priv*3)
+			new_shared = 1;
+	} else if (prev_shared == 1 && p->numa_migrate_seq >= settle_limit) {
 		 /* If it was shared before, make it harder to become private: */
-		if (total[0]*2 <= total[1])
-			shared = 0;
+		if (total_shared*3 <= total_priv*2)
+			new_shared = 0;
 	}
 
 	flip_tasks = 0;
 
-	if (shared)
+	if (new_shared)
 		p->ideal_cpu = sched_update_ideal_cpu_shared(p, &flip_tasks);
 	else
 		p->ideal_cpu = sched_update_ideal_cpu_private(p);
@@ -2126,7 +2157,9 @@ static void task_numa_placement_tick(struct task_struct *p)
 			ideal_node = p->numa_max_node;
 	}
 
-	if (shared != task_numa_shared(p) || (ideal_node != -1 && ideal_node != p->numa_max_node)) {
+	if (new_shared != prev_shared || (ideal_node != -1 && ideal_node != p->numa_max_node)) {
+
+		p->numa_migrate_seq = 0;
 		/*
 		 * Fix up node migration fault statistics artifact, as we
 		 * migrate to another node we'll soon bring over our private
@@ -2141,7 +2174,7 @@ static void task_numa_placement_tick(struct task_struct *p)
 			p->numa_faults[idx_newnode] += p->numa_faults[idx_oldnode];
 			p->numa_faults[idx_oldnode] = 0;
 		}
-		sched_setnuma(p, ideal_node, shared);
+		sched_setnuma(p, ideal_node, new_shared);
 
 		/* Allocate only the maximum node: */
 		if (sched_feat(NUMA_POLICY_MAXNODE)) {
@@ -2323,6 +2356,10 @@ void task_numa_placement_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
+	p->numa_migrate_seq++;
+	if (sched_feat(NUMA_SETTLE) && p->numa_migrate_seq < sysctl_sched_numa_settle_count)
+		return;
+
 	task_numa_placement_tick(p);
 }
 
@@ -5116,6 +5153,7 @@ static void
 migrate_task_rq_fair(struct task_struct *p, int next_cpu)
 {
 	migrate_task_rq_entity(p, next_cpu);
+	task_numa_migrate(p, next_cpu);
 }
 #endif /* CONFIG_SMP */
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 5598f63..c2f137f 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -63,6 +63,8 @@ SCHED_FEAT(NONTASK_POWER, true)
  */
 SCHED_FEAT(TTWU_QUEUE, true)
 
+SCHED_FEAT(NUMA_SETTLE,			true)
+
 SCHED_FEAT(FORCE_SD_OVERLAP,		false)
 SCHED_FEAT(RT_RUNTIME_SHARE,		true)
 SCHED_FEAT(LB_MIN,			false)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 75ab895..254a2b4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -401,6 +401,14 @@ static struct ctl_table kern_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "sched_numa_fault_weight",
+		.data		= &sysctl_sched_numa_fault_weight,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &two,	/* a weight minimum of 2 */
+	},
 #endif /* CONFIG_NUMA_BALANCING */
 #endif /* CONFIG_SCHED_DEBUG */
 	{
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
