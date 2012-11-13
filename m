Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 818C36B00B4
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:14:11 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 28/31] sched: numa: Implement home-node awareness
Date: Tue, 13 Nov 2012 11:12:57 +0000
Message-Id: <1352805180-1607-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NOTE: Entirely on "sched, numa, mm: Implement home-node awareness" but
	only a subset of it. There was stuff in there that was disabled
	by default and generally did slightly more than what I felt was
	necessary at this stage. In particular the random queue selection
	logic is gone because it looks broken but it does mean that the
	last CPU in a node may see increased scheduling pressure which
	is almost certainly the wrong thing to do. Needs re-examination
	Signed-offs removed as a result but will re-add if authors are ok.

Implement home node preference in the scheduler's load-balancer.

- task_numa_hot(); make it harder to migrate tasks away from their
  home-node, controlled using the NUMA_HOMENODE_PREFERRED feature flag.

- load_balance(); during the regular pull load-balance pass, try
  pulling tasks that are on the wrong node first with a preference of
  moving them nearer to their home-node through task_numa_hot(), controlled
  through the NUMA_PULL feature flag.

- load_balance(); when the balancer finds no imbalance, introduce
  some such that it still prefers to move tasks towards their home-node,
  using active load-balance if needed, controlled through the NUMA_PULL_BIAS
  feature flag.

  In particular, only introduce this BIAS if the system is otherwise properly
  (weight) balanced and we either have an offnode or !numa task to trade
  for it.

In order to easily find off-node tasks, split the per-cpu task list
into two parts.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h   |    3 +
 kernel/sched/core.c     |   14 ++-
 kernel/sched/debug.c    |    3 +
 kernel/sched/fair.c     |  298 +++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/features.h |   18 +++
 kernel/sched/sched.h    |   16 +++
 6 files changed, 324 insertions(+), 28 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2677f22..7ebf32e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -823,6 +823,7 @@ enum cpu_idle_type {
 #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
 #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
 #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
+#define SD_NUMA			0x4000	/* cross-node balancing */
 
 extern int __weak arch_sd_sibiling_asym_packing(void);
 
@@ -1481,6 +1482,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_BALANCE_NUMA
 	int home_node;
+	unsigned long numa_contrib;
 	int numa_scan_seq;
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
@@ -2104,6 +2106,7 @@ extern int sched_setscheduler(struct task_struct *, int,
 			      const struct sched_param *);
 extern int sched_setscheduler_nocheck(struct task_struct *, int,
 				      const struct sched_param *);
+extern void sched_setnode(struct task_struct *p, int node);
 extern struct task_struct *idle_task(int cpu);
 /**
  * is_idle_task - is the specified task an idle task?
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 55dcf53..3d9fc26 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5978,9 +5978,9 @@ static struct sched_domain_topology_level *sched_domain_topology = default_topol
  * Requeues a task ensuring its on the right load-balance list so
  * that it might get migrated to its new home.
  *
- * Note that we cannot actively migrate ourselves since our callers
- * can be from atomic context. We rely on the regular load-balance
- * mechanisms to move us around -- its all preference anyway.
+ * Since home-node is pure preference there's no hard migrate to force
+ * us anywhere, this also allows us to call this from atomic context if
+ * required.
  */
 void sched_setnode(struct task_struct *p, int node)
 {
@@ -6053,6 +6053,7 @@ sd_numa_init(struct sched_domain_topology_level *tl, int cpu)
 					| 0*SD_SHARE_PKG_RESOURCES
 					| 1*SD_SERIALIZE
 					| 0*SD_PREFER_SIBLING
+					| 1*SD_NUMA
 					| sd_local_flags(level)
 					,
 		.last_balance		= jiffies,
@@ -6914,7 +6915,12 @@ void __init sched_init(void)
 		rq->avg_idle = 2*sysctl_sched_migration_cost;
 
 		INIT_LIST_HEAD(&rq->cfs_tasks);
-
+#ifdef CONFIG_BALANCE_NUMA
+		INIT_LIST_HEAD(&rq->offnode_tasks);
+		rq->onnode_running = 0;
+		rq->offnode_running = 0;
+		rq->offnode_weight = 0;
+#endif
 		rq_attach_root(rq, &def_root_domain);
 #ifdef CONFIG_NO_HZ
 		rq->nohz_flags = 0;
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 6f79596..2474a02 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -132,6 +132,9 @@ print_task(struct seq_file *m, struct rq *rq, struct task_struct *p)
 	SEQ_printf(m, "%15Ld %15Ld %15Ld.%06ld %15Ld.%06ld %15Ld.%06ld",
 		0LL, 0LL, 0LL, 0L, 0LL, 0L, 0LL, 0L);
 #endif
+#ifdef CONFIG_BALANCE_NUMA
+	SEQ_printf(m, " %d/%d", p->home_node, cpu_to_node(task_cpu(p)));
+#endif
 #ifdef CONFIG_CGROUP_SCHED
 	SEQ_printf(m, " %s", task_group_path(task_group(p)));
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9c242e8..a816bbe 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -775,6 +775,51 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
 }
 
 /**************************************************
+ * Scheduling class numa methods.
+ */
+
+#ifdef CONFIG_SMP
+static unsigned long task_h_load(struct task_struct *p);
+#endif
+
+#ifdef CONFIG_BALANCE_NUMA
+static struct list_head *account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	struct list_head *tasks = &rq->cfs_tasks;
+
+	if (tsk_home_node(p) != cpu_to_node(task_cpu(p))) {
+		p->numa_contrib = task_h_load(p);
+		rq->offnode_weight += p->numa_contrib;
+		rq->offnode_running++;
+		tasks = &rq->offnode_tasks;
+	} else
+		rq->onnode_running++;
+
+	return tasks;
+}
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+	if (tsk_home_node(p) != cpu_to_node(task_cpu(p))) {
+		rq->offnode_weight -= p->numa_contrib;
+		rq->offnode_running--;
+	} else
+		rq->onnode_running--;
+}
+#else
+#ifdef CONFIG_SMP
+static struct list_head *account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	return NULL;
+}
+#endif
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
+/**************************************************
  * Scheduling class queueing methods:
  */
 
@@ -950,9 +995,17 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
-		list_add(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
-#endif
+	if (entity_is_task(se)) {
+		struct rq *rq = rq_of(cfs_rq);
+		struct task_struct *p = task_of(se);
+		struct list_head *tasks = &rq->cfs_tasks;
+
+		if (tsk_home_node(p) != -1)
+			tasks = account_numa_enqueue(rq, p);
+
+		list_add(&se->group_node, tasks);
+	}
+#endif /* CONFIG_SMP */
 	cfs_rq->nr_running++;
 }
 
@@ -962,8 +1015,14 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
+		struct task_struct *p = task_of(se);
+
 		list_del_init(&se->group_node);
+
+		if (tsk_home_node(p) != -1)
+			account_numa_dequeue(rq_of(cfs_rq), p);
+	}
 	cfs_rq->nr_running--;
 }
 
@@ -3227,6 +3286,8 @@ struct lb_env {
 
 	unsigned int		flags;
 
+	struct list_head	*tasks;
+
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
@@ -3248,10 +3309,32 @@ static void move_task(struct task_struct *p, struct lb_env *env)
 }
 
 /*
+ * Returns true if task should stay on the current node. The intent is that
+ * a task that is running on a node identified as the "home node" should
+ * stay there if possible
+ */
+static bool task_numa_hot(struct task_struct *p, struct lb_env *env)
+{
+	int from_dist, to_dist;
+	int node = tsk_home_node(p);
+
+	if (!sched_feat_numa(NUMA_HOMENODE_PREFERRED) || node == -1)
+		return false; /* no node preference */
+
+	from_dist = node_distance(cpu_to_node(env->src_cpu), node);
+	to_dist = node_distance(cpu_to_node(env->dst_cpu), node);
+
+	if (to_dist < from_dist)
+		return false; /* getting closer is ok */
+
+	return true; /* stick to where we are */
+}
+
+/*
  * Is this task likely cache-hot:
  */
 static int
-task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
+task_hot(struct task_struct *p, struct lb_env *env)
 {
 	s64 delta;
 
@@ -3274,7 +3357,7 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 	if (sysctl_sched_migration_cost == 0)
 		return 0;
 
-	delta = now - p->se.exec_start;
+	delta = env->src_rq->clock_task - p->se.exec_start;
 
 	return delta < (s64)sysctl_sched_migration_cost;
 }
@@ -3331,7 +3414,9 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	 * 2) too many balance attempts have failed.
 	 */
 
-	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
+	tsk_cache_hot = task_hot(p, env);
+	if (env->idle == CPU_NOT_IDLE)
+		tsk_cache_hot |= task_numa_hot(p, env);
 	if (!tsk_cache_hot ||
 		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
 #ifdef CONFIG_SCHEDSTATS
@@ -3353,15 +3438,15 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 /*
  * move_one_task tries to move exactly one task from busiest to this_rq, as
  * part of active balancing operations within "domain".
- * Returns 1 if successful and 0 otherwise.
+ * Returns true if successful and false otherwise.
  *
  * Called with both runqueues locked.
  */
-static int move_one_task(struct lb_env *env)
+static bool __move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
-	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
+	list_for_each_entry_safe(p, n, env->tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
 
@@ -3375,12 +3460,25 @@ static int move_one_task(struct lb_env *env)
 		 * stats here rather than inside move_task().
 		 */
 		schedstat_inc(env->sd, lb_gained[env->idle]);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
-static unsigned long task_h_load(struct task_struct *p);
+static bool move_one_task(struct lb_env *env)
+{
+	if (sched_feat_numa(NUMA_HOMENODE_PULL)) {
+		env->tasks = offnode_tasks(env->src_rq);
+		if (__move_one_task(env))
+			return true;
+	}
+
+	env->tasks = &env->src_rq->cfs_tasks;
+	if (__move_one_task(env))
+		return true;
+
+	return false;
+}
 
 static const unsigned int sched_nr_migrate_break = 32;
 
@@ -3393,7 +3491,6 @@ static const unsigned int sched_nr_migrate_break = 32;
  */
 static int move_tasks(struct lb_env *env)
 {
-	struct list_head *tasks = &env->src_rq->cfs_tasks;
 	struct task_struct *p;
 	unsigned long load;
 	int pulled = 0;
@@ -3401,8 +3498,9 @@ static int move_tasks(struct lb_env *env)
 	if (env->imbalance <= 0)
 		return 0;
 
-	while (!list_empty(tasks)) {
-		p = list_first_entry(tasks, struct task_struct, se.group_node);
+again:
+	while (!list_empty(env->tasks)) {
+		p = list_first_entry(env->tasks, struct task_struct, se.group_node);
 
 		env->loop++;
 		/* We've more or less seen every task there is, call it quits */
@@ -3413,7 +3511,7 @@ static int move_tasks(struct lb_env *env)
 		if (env->loop > env->loop_break) {
 			env->loop_break += sched_nr_migrate_break;
 			env->flags |= LBF_NEED_BREAK;
-			break;
+			goto out;
 		}
 
 		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
@@ -3441,7 +3539,7 @@ static int move_tasks(struct lb_env *env)
 		 * the critical section.
 		 */
 		if (env->idle == CPU_NEWLY_IDLE)
-			break;
+			goto out;
 #endif
 
 		/*
@@ -3449,13 +3547,20 @@ static int move_tasks(struct lb_env *env)
 		 * weighted load.
 		 */
 		if (env->imbalance <= 0)
-			break;
+			goto out;
 
 		continue;
 next:
-		list_move_tail(&p->se.group_node, tasks);
+		list_move_tail(&p->se.group_node, env->tasks);
 	}
 
+	if (env->tasks == offnode_tasks(env->src_rq)) {
+		env->tasks = &env->src_rq->cfs_tasks;
+		env->loop = 0;
+		goto again;
+	}
+
+out:
 	/*
 	 * Right now, this is one of only two places move_task() is called,
 	 * so we can safely collect move_task() stats here rather than
@@ -3574,12 +3679,13 @@ static inline void update_shares(int cpu)
 static inline void update_h_load(long cpu)
 {
 }
-
+#ifdef CONFIG_SMP
 static unsigned long task_h_load(struct task_struct *p)
 {
 	return p->se.load.weight;
 }
 #endif
+#endif
 
 /********** Helpers for find_busiest_group ************************/
 /*
@@ -3610,6 +3716,14 @@ struct sd_lb_stats {
 	unsigned int  busiest_group_weight;
 
 	int group_imb; /* Is there imbalance in this sd */
+#ifdef CONFIG_BALANCE_NUMA
+	struct sched_group *numa_group; /* group which has offnode_tasks */
+	unsigned long numa_group_weight;
+	unsigned long numa_group_running;
+
+	unsigned long this_offnode_running;
+	unsigned long this_onnode_running;
+#endif
 };
 
 /*
@@ -3625,6 +3739,11 @@ struct sg_lb_stats {
 	unsigned long group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
+#ifdef CONFIG_BALANCE_NUMA
+	unsigned long numa_offnode_weight;
+	unsigned long numa_offnode_running;
+	unsigned long numa_onnode_running;
+#endif
 };
 
 /**
@@ -3653,6 +3772,121 @@ static inline int get_sd_load_idx(struct sched_domain *sd,
 	return load_idx;
 }
 
+#ifdef CONFIG_BALANCE_NUMA
+static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
+{
+	sgs->numa_offnode_weight += rq->offnode_weight;
+	sgs->numa_offnode_running += rq->offnode_running;
+	sgs->numa_onnode_running += rq->onnode_running;
+}
+
+/*
+ * Since the offnode lists are indiscriminate (they contain tasks for all other
+ * nodes) it is impossible to say if there's any task on there that wants to
+ * move towards the pulling cpu. Therefore select a random offnode list to pull
+ * from such that eventually we'll try them all.
+ *
+ * Select a random group that has offnode tasks as sds->numa_group
+ */
+static inline void update_sd_numa_stats(struct sched_domain *sd,
+		struct sched_group *group, struct sd_lb_stats *sds,
+		int local_group, struct sg_lb_stats *sgs)
+{
+	if (!(sd->flags & SD_NUMA))
+		return;
+
+	if (local_group) {
+		sds->this_offnode_running = sgs->numa_offnode_running;
+		sds->this_onnode_running  = sgs->numa_onnode_running;
+		return;
+	}
+
+	if (!sgs->numa_offnode_running)
+		return;
+
+	if (!sds->numa_group) {
+		sds->numa_group = group;
+		sds->numa_group_weight = sgs->numa_offnode_weight;
+		sds->numa_group_running = sgs->numa_offnode_running;
+	}
+}
+
+/*
+ * Pick a random queue from the group that has offnode tasks.
+ */
+static struct rq *find_busiest_numa_queue(struct lb_env *env,
+					  struct sched_group *group)
+{
+	struct rq *busiest = NULL, *rq;
+	int cpu;
+
+	for_each_cpu_and(cpu, sched_group_cpus(group), env->cpus) {
+		rq = cpu_rq(cpu);
+		if (!rq->offnode_running)
+			continue;
+		if (!busiest)
+			busiest = rq;
+	}
+
+	return busiest;
+}
+
+/*
+ * Called in case of no other imbalance. Returns true if there is a queue
+ * running offnode tasks which pretends we are imbalanced anyway to nudge these
+ * tasks towards their home node.
+ */
+static inline int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
+{
+	if (!sched_feat(NUMA_HOMENODE_PULL_BIAS))
+		return false;
+
+	if (!sds->numa_group)
+		return false;
+
+	/*
+	 * Only pull an offnode task home if we've got offnode or !numa tasks to trade for it.
+	 */
+	if (!sds->this_offnode_running &&
+	    !(sds->this_nr_running - sds->this_onnode_running - sds->this_offnode_running))
+		return false;
+
+	env->imbalance = sds->numa_group_weight / sds->numa_group_running;
+	sds->busiest = sds->numa_group;
+	env->find_busiest_queue = find_busiest_numa_queue;
+	return true;
+}
+
+static inline bool need_active_numa_balance(struct lb_env *env)
+{
+	return env->find_busiest_queue == find_busiest_numa_queue &&
+			env->src_rq->offnode_running == 1 &&
+			env->src_rq->nr_running == 1;
+}
+
+#else /* CONFIG_BALANCE_NUMA */
+
+static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
+{
+}
+
+static inline void update_sd_numa_stats(struct sched_domain *sd,
+		struct sched_group *group, struct sd_lb_stats *sds,
+		int local_group, struct sg_lb_stats *sgs)
+{
+}
+
+static inline bool check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
+{
+	return false;
+}
+
+static inline bool need_active_numa_balance(struct lb_env *env)
+{
+	return false;
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 unsigned long default_scale_freq_power(struct sched_domain *sd, int cpu)
 {
 	return SCHED_POWER_SCALE;
@@ -3868,6 +4102,8 @@ static inline void update_sg_lb_stats(struct lb_env *env,
 		sgs->sum_weighted_load += weighted_cpuload(i);
 		if (idle_cpu(i))
 			sgs->idle_cpus++;
+
+		update_sg_numa_stats(sgs, rq);
 	}
 
 	/*
@@ -4021,6 +4257,8 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 			sds->group_imb = sgs.group_imb;
 		}
 
+		update_sd_numa_stats(env->sd, sg, sds, local_group, &sgs);
+
 		sg = sg->next;
 	} while (sg != env->sd->groups);
 }
@@ -4251,7 +4489,7 @@ find_busiest_group(struct lb_env *env, int *balance)
 
 	/* There is no busy sibling group to pull tasks from */
 	if (!sds.busiest || sds.busiest_nr_running == 0)
-		goto out_balanced;
+		goto ret;
 
 	sds.avg_load = (SCHED_POWER_SCALE * sds.total_load) / sds.total_pwr;
 
@@ -4273,14 +4511,14 @@ find_busiest_group(struct lb_env *env, int *balance)
 	 * don't try and pull any tasks.
 	 */
 	if (sds.this_load >= sds.max_load)
-		goto out_balanced;
+		goto ret;
 
 	/*
 	 * Don't pull any tasks if this group is already above the domain
 	 * average load.
 	 */
 	if (sds.this_load >= sds.avg_load)
-		goto out_balanced;
+		goto ret;
 
 	if (env->idle == CPU_IDLE) {
 		/*
@@ -4307,6 +4545,9 @@ force_balance:
 	return sds.busiest;
 
 out_balanced:
+	if (check_numa_busiest_group(env, &sds))
+		return sds.busiest;
+
 ret:
 	env->imbalance = 0;
 	return NULL;
@@ -4385,6 +4626,9 @@ static int need_active_balance(struct lb_env *env)
 			return 1;
 	}
 
+	if (need_active_numa_balance(env))
+		return 1;
+
 	return unlikely(sd->nr_balance_failed > sd->cache_nice_tries+2);
 }
 
@@ -4437,6 +4681,8 @@ redo:
 		schedstat_inc(sd, lb_nobusyq[idle]);
 		goto out_balanced;
 	}
+	env.src_rq  = busiest;
+	env.src_cpu = busiest->cpu;
 
 	BUG_ON(busiest == env.dst_rq);
 
@@ -4455,6 +4701,10 @@ redo:
 		env.src_cpu   = busiest->cpu;
 		env.src_rq    = busiest;
 		env.loop_max  = min(sysctl_sched_nr_migrate, busiest->nr_running);
+		if (sched_feat_numa(NUMA_HOMENODE_PULL))
+			env.tasks = offnode_tasks(busiest);
+		else
+			env.tasks = &busiest->cfs_tasks;
 
 		update_h_load(env.src_cpu);
 more_balance:
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 7cfd289..4ae02cb 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -67,4 +67,22 @@ SCHED_FEAT(LB_MIN, false)
  */
 #ifdef CONFIG_BALANCE_NUMA
 SCHED_FEAT(NUMA,	true)
+
+/* Keep tasks running on their home node if possible */
+SCHED_FEAT(NUMA_HOMENODE_PREFERRED, true)
+
+/*
+ * During the regular pull load-balance pass, try pulling tasks that are
+ * running off their home node first with a preference to moving them
+ * nearer their home node through task_numa_hot.
+ */
+SCHED_FEAT(NUMA_HOMENODE_PULL, true)
+
+/*
+ * When the balancer finds no imbalance, introduce some such that it
+ * still prefers to move tasks towards their home node, using active
+ * load-balance if needed.
+ */
+SCHED_FEAT(NUMA_HOMENODE_PULL_BIAS, true)
+
 #endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 9a43241..3f0e5a1 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -418,6 +418,13 @@ struct rq {
 
 	struct list_head cfs_tasks;
 
+#ifdef CONFIG_BALANCE_NUMA
+	unsigned long    onnode_running;
+	unsigned long    offnode_running;
+	unsigned long	 offnode_weight;
+	struct list_head offnode_tasks;
+#endif
+
 	u64 rt_avg;
 	u64 age_stamp;
 	u64 idle_stamp;
@@ -469,6 +476,15 @@ struct rq {
 #endif
 };
 
+static inline struct list_head *offnode_tasks(struct rq *rq)
+{
+#ifdef CONFIG_BALANCE_NUMA
+	return &rq->offnode_tasks;
+#else
+	return NULL;
+#endif
+}
+
 static inline int cpu_of(struct rq *rq)
 {
 #ifdef CONFIG_SMP
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
