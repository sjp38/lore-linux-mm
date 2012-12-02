Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A9C2A6B00B2
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:09 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082454eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:09 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 33/52] sched: Use the best-buddy 'ideal cpu' in balancing decisions
Date: Sun,  2 Dec 2012 19:43:25 +0100
Message-Id: <1354473824-19229-34-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Now that we have a notion of (one of the) best CPUs we interrelate
with in terms of memory usage, use that information to improve
can_migrate_task() balancing decisions: allow the migration to
occur even if we locally cache-hot, if we are on another node
and want to migrate towards our best buddy's node.

( Note that this is not hard affinity - if imbalance persists long
  enough then the scheduler will eventually balance tasks anyway,
  to maximize CPU utilization. )

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c     | 35 ++++++++++++++++++++++++++++++++---
 kernel/sched/features.h |  2 ++
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 67f7fd2..24a5588 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -840,6 +840,14 @@ static void task_numa_migrate(struct task_struct *p, int next_cpu)
 	p->numa_migrate_seq = 0;
 }
 
+static int task_ideal_cpu(struct task_struct *p)
+{
+	if (!sched_feat(IDEAL_CPU))
+		return -1;
+
+	return p->ideal_cpu;
+}
+
 /*
  * Called for every full scan - here we consider switching to a new
  * shared buddy, if the one we found during this scan is good enough:
@@ -1028,7 +1036,7 @@ out_hit:
 	 * but don't stop the discovery of process level sharing
 	 * either:
 	 */
-	if (this_task->mm == last_task->mm)
+	if (sched_feat(IDEAL_CPU_THREAD_BIAS) && this_task->mm == last_task->mm)
 		pages *= 2;
 
 	this_task->shared_buddy_faults_curr += pages;
@@ -1189,6 +1197,7 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 }
 #else /* !CONFIG_NUMA_BALANCING: */
 #ifdef CONFIG_SMP
+static inline int task_ideal_cpu(struct task_struct *p)				{ return -1; }
 static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)	{ }
 #endif
 static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)	{ }
@@ -4064,6 +4073,7 @@ struct lb_env {
 static void move_task(struct task_struct *p, struct lb_env *env)
 {
 	deactivate_task(env->src_rq, p, 0);
+
 	set_task_cpu(p, env->dst_cpu);
 	activate_task(env->dst_rq, p, 0);
 	check_preempt_curr(env->dst_rq, p, 0);
@@ -4242,15 +4252,17 @@ static bool can_migrate_numa_task(struct task_struct *p, struct lb_env *env)
 	 *
 	 * LBF_NUMA_RUN    -- numa only, only allow improvement
 	 * LBF_NUMA_SHARED -- shared only
+	 * LBF_NUMA_IDEAL  -- ideal only
 	 *
 	 * LBF_KEEP_SHARED -- do not touch shared tasks
 	 */
 
 	/* a numa run can only move numa tasks about to improve things */
 	if (env->flags & LBF_NUMA_RUN) {
-		if (task_numa_shared(p) < 0)
+		if (task_numa_shared(p) < 0 && task_ideal_cpu(p) < 0)
 			return false;
-		/* can only pull shared tasks */
+
+		/* If we are only allowed to pull shared tasks: */
 		if ((env->flags & LBF_NUMA_SHARED) && !task_numa_shared(p))
 			return false;
 	} else {
@@ -4307,6 +4319,23 @@ static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	if (!can_migrate_running_task(p, env))
 		return false;
 
+#ifdef CONFIG_NUMA_BALANCING
+	/* If we are only allowed to pull ideal tasks: */
+	if ((task_ideal_cpu(p) >= 0) && (p->shared_buddy_faults > 1000)) {
+		int ideal_node;
+		int dst_node;
+
+		BUG_ON(env->dst_cpu < 0);
+
+		ideal_node = cpu_to_node(p->ideal_cpu);
+		dst_node = cpu_to_node(env->dst_cpu);
+
+		if (ideal_node == dst_node)
+			return true;
+		return false;
+	}
+#endif
+
 	if (env->sd->flags & SD_NUMA)
 		return can_migrate_numa_task(p, env);
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index b75a10d..737d2c8 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -66,6 +66,8 @@ SCHED_FEAT(TTWU_QUEUE, true)
 SCHED_FEAT(FORCE_SD_OVERLAP, false)
 SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
+SCHED_FEAT(IDEAL_CPU,			true)
+SCHED_FEAT(IDEAL_CPU_THREAD_BIAS,	false)
 
 #ifdef CONFIG_NUMA_BALANCING
 /* Do the working set probing faults: */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
