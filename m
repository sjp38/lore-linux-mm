Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DD9E76B00F0
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:05 -0400 (EDT)
Message-Id: <20120316144240.952119284@chello.nl>
Date: Fri, 16 Mar 2012 15:40:41 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 13/26] sched: Implement home-node awareness
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-foo-5.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Implement home node preference in the load-balancer.

This is done in four pieces:

 - task_numa_hot(); make it harder to migrate tasks away from their
   home-node, controlled using the NUMA_HOT feature flag.

 - select_task_rq_fair(); prefer placing the task in their home-node,
   controlled using the NUMA_BIAS feature flag.

 - load_balance(); during the regular pull load-balance pass, try
   pulling tasks that are on the wrong node first with a preference
   of moving them nearer to their home-node through task_numa_hot(),
   controlled through the NUMA_PULL feature flag.

 - load_balance(); when the balancer finds no imbalance, introduce
   some such that it still prefers to move tasks towards their
   home-node, using active load-balance if needed, controlled through
   the NUMA_PULL_BIAS feature flag.

In order to easily find off-node tasks, split the per-cpu task list
into two parts.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/sched.h   |    1 
 kernel/sched/core.c     |   22 +++
 kernel/sched/debug.c    |    3 
 kernel/sched/fair.c     |  299 +++++++++++++++++++++++++++++++++++++++++-------
 kernel/sched/features.h |    7 +
 kernel/sched/sched.h    |    9 +
 6 files changed, 299 insertions(+), 42 deletions(-)
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -850,6 +850,7 @@ enum cpu_idle_type {
 #define SD_ASYM_PACKING		0x0800  /* Place busy groups earlier in the domain */
 #define SD_PREFER_SIBLING	0x1000	/* Prefer to place tasks in a sibling domain */
 #define SD_OVERLAP		0x2000	/* sched_domains of this level overlap */
+#define SD_NUMA			0x4000	/* cross-node balancing */
 
 enum powersavings_balance_level {
 	POWERSAVINGS_BALANCE_NONE = 0,  /* No power saving load balance */
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5806,7 +5806,9 @@ static void destroy_sched_domains(struct
 DEFINE_PER_CPU(struct sched_domain *, sd_llc);
 DEFINE_PER_CPU(int, sd_llc_id);
 
-static void update_top_cache_domain(int cpu)
+DEFINE_PER_CPU(struct sched_domain *, sd_node);
+
+static void update_domain_cache(int cpu)
 {
 	struct sched_domain *sd;
 	int id = cpu;
@@ -5817,6 +5819,17 @@ static void update_top_cache_domain(int
 
 	rcu_assign_pointer(per_cpu(sd_llc, cpu), sd);
 	per_cpu(sd_llc_id, cpu) = id;
+
+	for_each_domain(cpu, sd) {
+		if (cpumask_equal(sched_domain_span(sd),
+				  cpumask_of_node(cpu_to_node(cpu))))
+			goto got_node;
+	}
+	sd = NULL;
+got_node:
+	rcu_assign_pointer(per_cpu(sd_node, cpu), sd);
+	if (sd) for (sd = sd->parent; sd; sd = sd->parent)
+		sd->flags |= SD_NUMA;
 }
 
 /*
@@ -5859,7 +5872,7 @@ cpu_attach_domain(struct sched_domain *s
 	rcu_assign_pointer(rq->sd, sd);
 	destroy_sched_domains(tmp, cpu);
 
-	update_top_cache_domain(cpu);
+	update_domain_cache(cpu);
 }
 
 /* cpus with isolated domains */
@@ -7012,6 +7025,11 @@ void __init sched_init(void)
 		rq->avg_idle = 2*sysctl_sched_migration_cost;
 
 		INIT_LIST_HEAD(&rq->cfs_tasks);
+#ifdef CONFIG_NUMA
+		INIT_LIST_HEAD(&rq->offnode_tasks);
+		rq->offnode_running = 0;
+		rq->offnode_weight = 0;
+#endif
 
 		rq_attach_root(rq, &def_root_domain);
 #ifdef CONFIG_NO_HZ
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -132,6 +132,9 @@ print_task(struct seq_file *m, struct rq
 	SEQ_printf(m, "%15Ld %15Ld %15Ld.%06ld %15Ld.%06ld %15Ld.%06ld",
 		0LL, 0LL, 0LL, 0L, 0LL, 0L, 0LL, 0L);
 #endif
+#ifdef CONFIG_NUMA
+	SEQ_printf(m, " %d/%d", p->node, cpu_to_node(task_cpu(p)));
+#endif
 #ifdef CONFIG_CGROUP_SCHED
 	SEQ_printf(m, " %s", task_group_path(task_group(p)));
 #endif
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/random.h>
 
 #include <trace/events/sched.h>
 
@@ -783,8 +784,10 @@ account_entity_enqueue(struct cfs_rq *cf
 	if (!parent_entity(se))
 		update_load_add(&rq_of(cfs_rq)->load, se->load.weight);
 #ifdef CONFIG_SMP
-	if (entity_is_task(se))
-		list_add_tail(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
+	if (entity_is_task(se)) {
+		if (!account_numa_enqueue(task_of(se)))
+			list_add_tail(&se->group_node, &rq_of(cfs_rq)->cfs_tasks);
+	}
 #endif
 	cfs_rq->nr_running++;
 }
@@ -795,8 +798,10 @@ account_entity_dequeue(struct cfs_rq *cf
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
 		list_del_init(&se->group_node);
+		account_numa_dequeue(task_of(se));
+	}
 	cfs_rq->nr_running--;
 }
 
@@ -2702,6 +2707,7 @@ select_task_rq_fair(struct task_struct *
 	int want_affine = 0;
 	int want_sd = 1;
 	int sync = wake_flags & WF_SYNC;
+	int node = tsk_home_node(p);
 
 	if (p->rt.nr_cpus_allowed == 1)
 		return prev_cpu;
@@ -2713,6 +2719,29 @@ select_task_rq_fair(struct task_struct *
 	}
 
 	rcu_read_lock();
+	if (sched_feat(NUMA_BIAS) && node != -1) {
+		int node_cpu;
+
+		node_cpu = cpumask_any_and(tsk_cpus_allowed(p), cpumask_of_node(node));
+		if (node_cpu >= nr_cpu_ids)
+			goto find_sd;
+
+		/*
+		 * For fork,exec find the idlest cpu in the home-node.
+		 */
+		if (sd_flag & (SD_BALANCE_FORK|SD_BALANCE_EXEC)) {
+			new_cpu = cpu = node_cpu;
+			sd = per_cpu(sd_node, cpu);
+			goto pick_idlest;
+		}
+
+		/*
+		 * For wake, pretend we were running in the home-node.
+		 */
+		prev_cpu = node_cpu;
+	}
+
+find_sd:
 	for_each_domain(cpu, tmp) {
 		if (!(tmp->flags & SD_LOAD_BALANCE))
 			continue;
@@ -2769,6 +2798,7 @@ select_task_rq_fair(struct task_struct *
 		goto unlock;
 	}
 
+pick_idlest:
 	while (sd) {
 		int load_idx = sd->forkexec_idx;
 		struct sched_group *group;
@@ -3085,6 +3115,8 @@ struct lb_env {
 	long			load_move;
 	unsigned int		flags;
 
+	struct list_head	*tasks;
+
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
@@ -3102,6 +3134,30 @@ static void move_task(struct task_struct
 	check_preempt_curr(env->dst_rq, p, 0);
 }
 
+#ifdef CONFIG_NUMA
+static int task_numa_hot(struct task_struct *p, int from_cpu, int to_cpu)
+{
+	int from_dist, to_dist;
+	int node = tsk_home_node(p);
+
+	if (!sched_feat(NUMA_HOT) || node == -1)
+		return 0; /* no node preference */
+
+	from_dist = node_distance(cpu_to_node(from_cpu), node);
+	to_dist = node_distance(cpu_to_node(to_cpu), node);
+
+	if (to_dist < from_dist)
+		return 0; /* getting closer is ok */
+
+	return 1; /* stick to where we are */
+}
+#else
+static inline int task_numa_hot(struct task_struct *p, int from_cpu, int to_cpu)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA */
+
 /*
  * Is this task likely cache-hot:
  */
@@ -3165,6 +3221,7 @@ int can_migrate_task(struct task_struct
 	 */
 
 	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
+	tsk_cache_hot |= task_numa_hot(p, env->src_cpu, env->dst_cpu);
 	if (!tsk_cache_hot ||
 		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
 #ifdef CONFIG_SCHEDSTATS
@@ -3190,11 +3247,11 @@ int can_migrate_task(struct task_struct
  *
  * Called with both runqueues locked.
  */
-static int move_one_task(struct lb_env *env)
+static int __move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
-	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
+	list_for_each_entry_safe(p, n, env->tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
 
@@ -3213,6 +3270,21 @@ static int move_one_task(struct lb_env *
 	return 0;
 }
 
+static int move_one_task(struct lb_env *env)
+{
+	if (sched_feat(NUMA_PULL)) {
+		env->tasks = &env->src_rq->offnode_tasks;
+		if (__move_one_task(env))
+			return 1;
+	}
+
+	env->tasks = &env->src_rq->cfs_tasks;
+	if (__move_one_task(env))
+		return 1;
+
+	return 0;
+}
+
 static unsigned long task_h_load(struct task_struct *p);
 
 /*
@@ -3224,7 +3296,6 @@ static unsigned long task_h_load(struct
  */
 static int move_tasks(struct lb_env *env)
 {
-	struct list_head *tasks = &env->src_rq->cfs_tasks;
 	struct task_struct *p;
 	unsigned long load;
 	int pulled = 0;
@@ -3232,8 +3303,9 @@ static int move_tasks(struct lb_env *env
 	if (env->load_move <= 0)
 		return 0;
 
-	while (!list_empty(tasks)) {
-		p = list_first_entry(tasks, struct task_struct, se.group_node);
+again:
+	while (!list_empty(env->tasks)) {
+		p = list_first_entry(env->tasks, struct task_struct, se.group_node);
 
 		env->loop++;
 		/* We've more or less seen every task there is, call it quits */
@@ -3244,7 +3316,7 @@ static int move_tasks(struct lb_env *env
 		if (env->loop > env->loop_break) {
 			env->loop_break += sysctl_sched_nr_migrate;
 			env->flags |= LBF_NEED_BREAK;
-			break;
+			goto out;
 		}
 
 		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
@@ -3272,7 +3344,7 @@ static int move_tasks(struct lb_env *env
 		 * the critical section.
 		 */
 		if (env->idle == CPU_NEWLY_IDLE)
-			break;
+			goto out;
 #endif
 
 		/*
@@ -3280,13 +3352,20 @@ static int move_tasks(struct lb_env *env
 		 * weighted load.
 		 */
 		if (env->load_move <= 0)
-			break;
+			goto out;
 
 		continue;
 next:
-		list_move_tail(&p->se.group_node, tasks);
+		list_move_tail(&p->se.group_node, env->tasks);
 	}
 
+	if (env->tasks == &env->src_rq->offnode_tasks) {
+		env->tasks = &env->src_rq->cfs_tasks;
+		env->loop = 0;
+		goto again;
+	}
+
+out:
 	/*
 	 * Right now, this is one of only two places move_task() is called,
 	 * so we can safely collect move_task() stats here rather than
@@ -3441,6 +3520,15 @@ struct sd_lb_stats {
 	unsigned long leader_nr_running; /* Nr running of group_leader */
 	unsigned long min_nr_running; /* Nr running of group_min */
 #endif
+#ifdef CONFIG_NUMA
+	struct sched_group *numa_group; /* group which has offnode_tasks */
+	unsigned long numa_group_weight;
+	unsigned long numa_group_running;
+#endif
+
+	struct rq *(*find_busiest_queue)(struct sched_domain *sd,
+			struct sched_group *group, enum cpu_idle_type idle,
+			unsigned long imbalance, const struct cpumask *cpus);
 };
 
 /*
@@ -3456,6 +3544,10 @@ struct sg_lb_stats {
 	unsigned long group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
+#ifdef CONFIG_NUMA
+	unsigned long numa_weight;
+	unsigned long numa_running;
+#endif
 };
 
 /**
@@ -3625,6 +3717,117 @@ static inline int check_power_save_busie
 }
 #endif /* CONFIG_SCHED_MC || CONFIG_SCHED_SMT */
 
+#ifdef CONFIG_NUMA
+static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
+{
+	sgs->numa_weight += rq->offnode_weight;
+	sgs->numa_running += rq->offnode_running;
+}
+
+/*
+ * Since the offnode lists are indiscriminate (they contain tasks for all other
+ * nodes) it is impossible to say if there's any task on there that wants to
+ * move towards the pulling cpu. Therefore select a random offnode list to pull
+ * from such that eventually we'll try them all.
+ */
+static inline bool pick_numa_rand(void)
+{
+	return get_random_int() & 1;
+}
+
+static inline void update_sd_numa_stats(struct sched_domain *sd,
+		struct sched_group *group, struct sd_lb_stats *sds,
+		int local_group, struct sg_lb_stats *sgs)
+{
+	if (!(sd->flags & SD_NUMA))
+		return;
+
+	if (local_group)
+		return;
+
+	if (!sgs->numa_running)
+		return;
+
+	if (!sds->numa_group_running || pick_numa_rand()) {
+		sds->numa_group = group;
+		sds->numa_group_weight = sgs->numa_weight;
+		sds->numa_group_running = sgs->numa_running;
+	}
+}
+
+static struct rq *
+find_busiest_numa_queue(struct sched_domain *sd, struct sched_group *group,
+		   enum cpu_idle_type idle, unsigned long imbalance,
+		   const struct cpumask *cpus)
+{
+	struct rq *busiest = NULL, *rq;
+	int cpu;
+
+	for_each_cpu_and(cpu, sched_group_cpus(group), cpus) {
+		rq = cpu_rq(cpu);
+		if (!rq->offnode_running)
+			continue;
+		if (!busiest || pick_numa_rand())
+			busiest = rq;
+	}
+
+	return busiest;
+}
+
+static inline int check_numa_busiest_group(struct sd_lb_stats *sds,
+		int this_cpu, unsigned long *imbalance)
+{
+	if (!sched_feat(NUMA_PULL_BIAS))
+		return 0;
+
+	if (!sds->numa_group)
+		return 0;
+
+	*imbalance = sds->numa_group_weight / sds->numa_group_running;
+	sds->busiest = sds->numa_group;
+	sds->find_busiest_queue = find_busiest_numa_queue;
+	return 1;
+}
+
+static inline
+bool need_active_numa_balance(struct sched_domain *sd, struct rq *busiest)
+{
+	/*
+	 * Not completely fail-safe, but its a fair bet that if we're at a
+	 * rq that only has one task, and its offnode, we're here through
+	 * find_busiest_numa_queue(). In any case, we want to kick such tasks.
+	 */
+	if ((sd->flags & SD_NUMA) && busiest->offnode_running == 1 &&
+			busiest->nr_running == 1)
+		return true;
+
+	return false;
+}
+
+#else /* CONFIG_NUMA */
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
+static inline int check_numa_busiest_group(struct sd_lb_stats *sds,
+		int this_cpu, unsigned long *imbalance)
+{
+	return 0;
+}
+
+static inline
+bool need_active_numa_balance(struct sched_domain *sd, struct rq *busiest)
+{
+	return false;
+}
+#endif /* CONFIG_NUMA */
 
 unsigned long default_scale_freq_power(struct sched_domain *sd, int cpu)
 {
@@ -3816,6 +4019,8 @@ static inline void update_sg_lb_stats(st
 		sgs->sum_weighted_load += weighted_cpuload(i);
 		if (idle_cpu(i))
 			sgs->idle_cpus++;
+
+		update_sg_numa_stats(sgs, rq);
 	}
 
 	/*
@@ -3977,6 +4182,8 @@ static inline void update_sd_lb_stats(st
 		}
 
 		update_sd_power_savings_stats(sg, sds, local_group, &sgs);
+		update_sd_numa_stats(sd, sg, sds, local_group, &sgs);
+
 		sg = sg->next;
 	} while (sg != sd->groups);
 }
@@ -4192,19 +4399,16 @@ static inline void calculate_imbalance(s
  *		   put to idle by rebalancing its tasks onto our group.
  */
 static struct sched_group *
-find_busiest_group(struct sched_domain *sd, int this_cpu,
-		   unsigned long *imbalance, enum cpu_idle_type idle,
-		   const struct cpumask *cpus, int *balance)
+find_busiest_group(struct sched_domain *sd, struct sd_lb_stats *sds,
+		   int this_cpu, unsigned long *imbalance,
+		   enum cpu_idle_type idle, const struct cpumask *cpus,
+		   int *balance)
 {
-	struct sd_lb_stats sds;
-
-	memset(&sds, 0, sizeof(sds));
-
 	/*
 	 * Compute the various statistics relavent for load balancing at
 	 * this level.
 	 */
-	update_sd_lb_stats(sd, this_cpu, idle, cpus, balance, &sds);
+	update_sd_lb_stats(sd, this_cpu, idle, cpus, balance, sds);
 
 	/*
 	 * this_cpu is not the appropriate cpu to perform load balancing at
@@ -4214,40 +4418,40 @@ find_busiest_group(struct sched_domain *
 		goto ret;
 
 	if ((idle == CPU_IDLE || idle == CPU_NEWLY_IDLE) &&
-	    check_asym_packing(sd, &sds, this_cpu, imbalance))
-		return sds.busiest;
+	    check_asym_packing(sd, sds, this_cpu, imbalance))
+		return sds->busiest;
 
 	/* There is no busy sibling group to pull tasks from */
-	if (!sds.busiest || sds.busiest_nr_running == 0)
+	if (!sds->busiest || sds->busiest_nr_running == 0)
 		goto out_balanced;
 
-	sds.avg_load = (SCHED_POWER_SCALE * sds.total_load) / sds.total_pwr;
+	sds->avg_load = (SCHED_POWER_SCALE * sds->total_load) / sds->total_pwr;
 
 	/*
 	 * If the busiest group is imbalanced the below checks don't
 	 * work because they assumes all things are equal, which typically
 	 * isn't true due to cpus_allowed constraints and the like.
 	 */
-	if (sds.group_imb)
+	if (sds->group_imb)
 		goto force_balance;
 
 	/* SD_BALANCE_NEWIDLE trumps SMP nice when underutilized */
-	if (idle == CPU_NEWLY_IDLE && sds.this_has_capacity &&
-			!sds.busiest_has_capacity)
+	if (idle == CPU_NEWLY_IDLE && sds->this_has_capacity &&
+			!sds->busiest_has_capacity)
 		goto force_balance;
 
 	/*
 	 * If the local group is more busy than the selected busiest group
 	 * don't try and pull any tasks.
 	 */
-	if (sds.this_load >= sds.max_load)
+	if (sds->this_load >= sds->max_load)
 		goto out_balanced;
 
 	/*
 	 * Don't pull any tasks if this group is already above the domain
 	 * average load.
 	 */
-	if (sds.this_load >= sds.avg_load)
+	if (sds->this_load >= sds->avg_load)
 		goto out_balanced;
 
 	if (idle == CPU_IDLE) {
@@ -4257,30 +4461,33 @@ find_busiest_group(struct sched_domain *
 		 * there is no imbalance between this and busiest group
 		 * wrt to idle cpu's, it is balanced.
 		 */
-		if ((sds.this_idle_cpus <= sds.busiest_idle_cpus + 1) &&
-		    sds.busiest_nr_running <= sds.busiest_group_weight)
+		if ((sds->this_idle_cpus <= sds->busiest_idle_cpus + 1) &&
+		    sds->busiest_nr_running <= sds->busiest_group_weight)
 			goto out_balanced;
 	} else {
 		/*
 		 * In the CPU_NEWLY_IDLE, CPU_NOT_IDLE cases, use
 		 * imbalance_pct to be conservative.
 		 */
-		if (100 * sds.max_load <= sd->imbalance_pct * sds.this_load)
+		if (100 * sds->max_load <= sd->imbalance_pct * sds->this_load)
 			goto out_balanced;
 	}
 
 force_balance:
 	/* Looks like there is an imbalance. Compute it */
-	calculate_imbalance(&sds, this_cpu, imbalance);
-	return sds.busiest;
+	calculate_imbalance(sds, this_cpu, imbalance);
+	return sds->busiest;
 
 out_balanced:
+	if (check_numa_busiest_group(sds, this_cpu, imbalance))
+		return sds->busiest;
+
 	/*
 	 * There is no obvious imbalance. But check if we can do some balancing
 	 * to save power.
 	 */
-	if (check_power_save_busiest_group(&sds, this_cpu, imbalance))
-		return sds.busiest;
+	if (check_power_save_busiest_group(sds, this_cpu, imbalance))
+		return sds->busiest;
 ret:
 	*imbalance = 0;
 	return NULL;
@@ -4347,9 +4554,11 @@ find_busiest_queue(struct sched_domain *
 DEFINE_PER_CPU(cpumask_var_t, load_balance_tmpmask);
 
 static int need_active_balance(struct sched_domain *sd, int idle,
-			       int busiest_cpu, int this_cpu)
+			       struct rq *busiest, struct rq *this)
 {
 	if (idle == CPU_NEWLY_IDLE) {
+		int busiest_cpu = cpu_of(busiest);
+		int this_cpu = cpu_of(this);
 
 		/*
 		 * ASYM_PACKING needs to force migrate tasks from busy but
@@ -4382,6 +4591,9 @@ static int need_active_balance(struct sc
 			return 0;
 	}
 
+	if (need_active_numa_balance(sd, busiest))
+		return 1;
+
 	return unlikely(sd->nr_balance_failed > sd->cache_nice_tries+2);
 }
 
@@ -4401,6 +4613,7 @@ static int load_balance(int this_cpu, st
 	struct rq *busiest;
 	unsigned long flags;
 	struct cpumask *cpus = __get_cpu_var(load_balance_tmpmask);
+	struct sd_lb_stats sds;
 
 	struct lb_env env = {
 		.sd		= sd,
@@ -4412,10 +4625,12 @@ static int load_balance(int this_cpu, st
 
 	cpumask_copy(cpus, cpu_active_mask);
 
+	memset(&sds, 0, sizeof(sds));
+	sds.find_busiest_queue = find_busiest_queue;
 	schedstat_inc(sd, lb_count[idle]);
 
 redo:
-	group = find_busiest_group(sd, this_cpu, &imbalance, idle,
+	group = find_busiest_group(sd, &sds, this_cpu, &imbalance, idle,
 				   cpus, balance);
 
 	if (*balance == 0)
@@ -4426,7 +4641,7 @@ static int load_balance(int this_cpu, st
 		goto out_balanced;
 	}
 
-	busiest = find_busiest_queue(sd, group, idle, imbalance, cpus);
+	busiest = sds.find_busiest_queue(sd, group, idle, imbalance, cpus);
 	if (!busiest) {
 		schedstat_inc(sd, lb_nobusyq[idle]);
 		goto out_balanced;
@@ -4449,6 +4664,10 @@ static int load_balance(int this_cpu, st
 		env.src_cpu = busiest->cpu;
 		env.src_rq = busiest;
 		env.loop_max = busiest->nr_running;
+		if (sched_feat(NUMA_PULL))
+			env.tasks = &busiest->offnode_tasks;
+		else
+			env.tasks = &busiest->cfs_tasks;
 
 more_balance:
 		local_irq_save(flags);
@@ -4490,7 +4709,7 @@ static int load_balance(int this_cpu, st
 		if (idle != CPU_NEWLY_IDLE)
 			sd->nr_balance_failed++;
 
-		if (need_active_balance(sd, idle, cpu_of(busiest), this_cpu)) {
+		if (need_active_balance(sd, idle, busiest, this_rq)) {
 			raw_spin_lock_irqsave(&busiest->lock, flags);
 
 			/* don't kick the active_load_balance_cpu_stop,
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -68,3 +68,10 @@ SCHED_FEAT(TTWU_QUEUE, true)
 
 SCHED_FEAT(FORCE_SD_OVERLAP, false)
 SCHED_FEAT(RT_RUNTIME_SHARE, true)
+
+#ifdef CONFIG_NUMA
+SCHED_FEAT(NUMA_HOT,       true)
+SCHED_FEAT(NUMA_BIAS,      true)
+SCHED_FEAT(NUMA_PULL,      true)
+SCHED_FEAT(NUMA_PULL_BIAS, true)
+#endif
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -414,6 +414,12 @@ struct rq {
 
 	struct list_head cfs_tasks;
 
+#ifdef CONFIG_NUMA
+	unsigned long    offnode_running;
+	unsigned long	 offnode_weight;
+	struct list_head offnode_tasks;
+#endif
+
 	u64 rt_avg;
 	u64 age_stamp;
 	u64 idle_stamp;
@@ -525,6 +531,7 @@ static inline struct sched_domain *highe
 
 DECLARE_PER_CPU(struct sched_domain *, sd_llc);
 DECLARE_PER_CPU(int, sd_llc_id);
+DECLARE_PER_CPU(struct sched_domain *, sd_node);
 
 #endif /* CONFIG_SMP */
 
@@ -1158,3 +1165,5 @@ enum rq_nohz_flag_bits {
 #endif
 
 static inline void select_task_node(struct task_struct *p, struct mm_struct *mm, int sd_flags) { }
+static inline bool account_numa_enqueue(struct task_struct *p) { return false; }
+static inline void account_numa_dequeue(struct task_struct *p) { }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
