Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 47C246B007B
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:54 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4763716eek.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:53 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 9/9] numa, sched: Streamline and fix numa_allow_migration() use
Date: Fri,  7 Dec 2012 01:19:26 +0100
Message-Id: <1354839566-15697-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

There were a few inconsistencies in how numa_allow_migration() was
used, in particular it did no always take into account
high-imbalance scenarios, where affinity preferences are generally
overriden.

To fix this make use of numa_allow_migration() more consistent and
also pass in the load-balancing environment to the function, where
it can look at env->failed and env->sd->cache_nice_tries.

Also add a NUMA check to ALB.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 103 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 57 insertions(+), 46 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c393fba..503ec29 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4792,6 +4792,39 @@ static inline unsigned long effective_load(struct task_group *tg, int cpu,
 
 #endif
 
+#define LBF_ALL_PINNED	0x01
+#define LBF_NEED_BREAK	0x02
+#define LBF_SOME_PINNED	0x04
+
+struct lb_env {
+	struct sched_domain	*sd;
+
+	struct rq		*src_rq;
+	int			src_cpu;
+
+	int			dst_cpu;
+	struct rq		*dst_rq;
+
+	struct cpumask		*dst_grpmask;
+	int			new_dst_cpu;
+	enum cpu_idle_type	idle;
+	long			imbalance;
+	/* The set of CPUs under consideration for load-balancing */
+	struct cpumask		*cpus;
+
+	unsigned int		flags;
+	unsigned int		failed;
+	unsigned int		iteration;
+
+	unsigned int		loop;
+	unsigned int		loop_break;
+	unsigned int		loop_max;
+
+	struct rq *		(*find_busiest_queue)(struct lb_env *,
+						      struct sched_group *);
+};
+
+
 static int wake_affine(struct sched_domain *sd, struct task_struct *p, int sync)
 {
 	s64 this_load, load;
@@ -5011,30 +5044,35 @@ done:
 	return target;
 }
 
-static bool numa_allow_migration(struct task_struct *p, int prev_cpu, int new_cpu)
+static bool numa_allow_migration(struct task_struct *p, int prev_cpu, int new_cpu,
+				 struct lb_env *env)
 {
 #ifdef CONFIG_NUMA_BALANCING
+
 	if (sched_feat(NUMA_CONVERGE_MIGRATIONS)) {
 		/* Help in the direction of expected convergence: */
 		if (p->convergence_node >= 0 && (cpu_to_node(new_cpu) != p->convergence_node))
 			return false;
 
-		return true;
-	}
-
-	if (sched_feat(NUMA_BALANCE_ALL)) {
- 		if (task_numa_shared(p) >= 0)
-			return false;
-
-		return true;
+		if (!env || env->failed <= env->sd->cache_nice_tries) {
+			if (task_numa_shared(p) >= 0 &&
+					cpu_to_node(prev_cpu) != cpu_to_node(new_cpu))
+				return false;
+		}
 	}
 
 	if (sched_feat(NUMA_BALANCE_INTERNODE)) {
 		if (task_numa_shared(p) >= 0) {
- 			if (cpu_to_node(prev_cpu) != cpu_to_node(new_cpu))
+			if (cpu_to_node(prev_cpu) != cpu_to_node(new_cpu))
 				return false;
 		}
 	}
+
+	if (sched_feat(NUMA_BALANCE_ALL)) {
+		if (task_numa_shared(p) >= 0)
+			return false;
+	}
+
 #endif
 	return true;
 }
@@ -5148,7 +5186,7 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		/* while loop will break here if sd == NULL */
 	}
 unlock:
-	if (!numa_allow_migration(p, prev0_cpu, new_cpu)) {
+	if (!numa_allow_migration(p, prev0_cpu, new_cpu, NULL)) {
 		if (cpumask_test_cpu(prev0_cpu, tsk_cpus_allowed(p)))
 			new_cpu = prev0_cpu;
 	}
@@ -5567,38 +5605,6 @@ static bool yield_to_task_fair(struct rq *rq, struct task_struct *p, bool preemp
 
 static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
-#define LBF_ALL_PINNED	0x01
-#define LBF_NEED_BREAK	0x02
-#define LBF_SOME_PINNED	0x04
-
-struct lb_env {
-	struct sched_domain	*sd;
-
-	struct rq		*src_rq;
-	int			src_cpu;
-
-	int			dst_cpu;
-	struct rq		*dst_rq;
-
-	struct cpumask		*dst_grpmask;
-	int			new_dst_cpu;
-	enum cpu_idle_type	idle;
-	long			imbalance;
-	/* The set of CPUs under consideration for load-balancing */
-	struct cpumask		*cpus;
-
-	unsigned int		flags;
-	unsigned int		failed;
-	unsigned int		iteration;
-
-	unsigned int		loop;
-	unsigned int		loop_break;
-	unsigned int		loop_max;
-
-	struct rq *		(*find_busiest_queue)(struct lb_env *,
-						      struct sched_group *);
-};
-
 /*
  * move_task - move a task from one runqueue to another runqueue.
  * Both runqueues must be locked.
@@ -5699,7 +5705,7 @@ static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	/* We do NUMA balancing elsewhere: */
 
 	if (env->failed <= env->sd->cache_nice_tries) {
-		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu))
+		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu, env))
 			return false;
 	}
 
@@ -5760,7 +5766,7 @@ static int move_one_task(struct lb_env *env)
 		if (!can_migrate_task(p, env))
 			continue;
 
-		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu))
+		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu, env))
 			continue;
 
 		move_task(p, env);
@@ -5823,7 +5829,7 @@ static int move_tasks(struct lb_env *env)
 		if (!can_migrate_task(p, env))
 			goto next;
 
-		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu))
+		if (!numa_allow_migration(p, env->src_rq->cpu, env->dst_cpu, env))
 			goto next;
 
 		move_task(p, env);
@@ -6944,6 +6950,11 @@ more_balance:
 			goto out_pinned;
 		}
 
+		/* Is this active load-balancing NUMA-beneficial? */
+		if (!numa_allow_migration(busiest->curr, env.src_rq->cpu, env.dst_cpu, &env)) {
+			raw_spin_unlock_irqrestore(&busiest->lock, flags);
+			goto out;
+		}
 		/*
 		 * ->active_balance synchronizes accesses to
 		 * ->active_balance_work.  Once set, it's cleared
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
