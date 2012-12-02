Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A5DA36B00CB
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:31 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082454eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:31 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 44/52] sched: Remove statistical NUMA scheduling
Date: Sun,  2 Dec 2012 19:43:36 +0100
Message-Id: <1354473824-19229-45-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Remove leftovers of the (now inactive) statistical NUMA scheduling code.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h   |   2 -
 kernel/sched/core.c     |   1 -
 kernel/sched/fair.c     | 436 +-----------------------------------------------
 kernel/sched/features.h |   3 -
 kernel/sched/sched.h    |   3 -
 5 files changed, 6 insertions(+), 439 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3bc69b7..8eeb866 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1507,10 +1507,8 @@ struct task_struct {
 	int numa_max_node;
 	int numa_scan_seq;
 	unsigned long numa_scan_ts_secs;
-	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
-	unsigned long numa_weight;
 	unsigned long *numa_faults;
 	unsigned long *numa_faults_curr;
 	struct callback_head numa_scan_work;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 80bdc9b..0fac735 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1556,7 +1556,6 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_shared = -1;
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
-	p->numa_migrate_seq = 2;
 	p->numa_faults = NULL;
 	p->numa_scan_period = sysctl_sched_numa_scan_delay;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 417c7bb..7af89b7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -801,26 +801,6 @@ static unsigned long task_h_load(struct task_struct *p);
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
-{
-	if (task_numa_shared(p) != -1) {
-		p->numa_weight = task_h_load(p);
-		rq->nr_numa_running++;
-		rq->nr_shared_running += task_numa_shared(p);
-		rq->nr_ideal_running += (cpu_to_node(task_cpu(p)) == p->numa_max_node);
-		rq->numa_weight += p->numa_weight;
-	}
-}
-
-static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
-{
-	if (task_numa_shared(p) != -1) {
-		rq->nr_numa_running--;
-		rq->nr_shared_running -= task_numa_shared(p);
-		rq->nr_ideal_running -= (cpu_to_node(task_cpu(p)) == p->numa_max_node);
-		rq->numa_weight -= p->numa_weight;
-	}
-}
 
 /*
  * Scan @scan_size MB every @scan_period after an initial @scan_delay.
@@ -835,11 +815,6 @@ unsigned int sysctl_sched_numa_scan_size = 256;		/* MB */
  */
 unsigned int sysctl_sched_numa_settle_count = 2;
 
-static void task_numa_migrate(struct task_struct *p, int next_cpu)
-{
-	p->numa_migrate_seq = 0;
-}
-
 static int task_ideal_cpu(struct task_struct *p)
 {
 	if (!sched_feat(IDEAL_CPU))
@@ -2041,8 +2016,6 @@ static void task_numa_placement_tick(struct task_struct *p)
 	}
 
 	if (shared != task_numa_shared(p) || (ideal_node != -1 && ideal_node != p->numa_max_node)) {
-
-		p->numa_migrate_seq = 0;
 		/*
 		 * Fix up node migration fault statistics artifact, as we
 		 * migrate to another node we'll soon bring over our private
@@ -2227,13 +2200,6 @@ void task_numa_scan_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
-	p->numa_migrate_seq++;
-	if (sched_feat(NUMA_SETTLE) &&
-	    p->numa_migrate_seq < sysctl_sched_numa_settle_count) {
-		trace_printk("NUMA TICK: placement, return to let it settle, task %s:%d\n", p->comm, p->pid);
-		return;
-	}
-
 	/*
 	 * Enforce maximal scan/migration frequency..
 	 */
@@ -2420,11 +2386,8 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 #else /* !CONFIG_NUMA_BALANCING: */
 #ifdef CONFIG_SMP
 static inline int task_ideal_cpu(struct task_struct *p)				{ return -1; }
-static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)	{ }
 #endif
-static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)	{ }
 static inline void task_tick_numa(struct rq *rq, struct task_struct *curr)	{ }
-static inline void task_numa_migrate(struct task_struct *p, int next_cpu)	{ }
 #endif /* CONFIG_NUMA_BALANCING */
 
 /**************************************************
@@ -2441,7 +2404,6 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (entity_is_task(se)) {
 		struct rq *rq = rq_of(cfs_rq);
 
-		account_numa_enqueue(rq, task_of(se));
 		list_add(&se->group_node, &rq->cfs_tasks);
 	}
 #endif /* CONFIG_SMP */
@@ -2454,10 +2416,9 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se)) {
+	if (entity_is_task(se))
 		list_del_init(&se->group_node);
-		account_numa_dequeue(rq_of(cfs_rq), task_of(se));
-	}
+
 	cfs_rq->nr_running--;
 }
 
@@ -4892,7 +4853,6 @@ static void
 migrate_task_rq_fair(struct task_struct *p, int next_cpu)
 {
 	migrate_task_rq_entity(p, next_cpu);
-	task_numa_migrate(p, next_cpu);
 }
 #endif /* CONFIG_SMP */
 
@@ -5268,9 +5228,6 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
 #define LBF_SOME_PINNED	0x04
-#define LBF_NUMA_RUN	0x08
-#define LBF_NUMA_SHARED	0x10
-#define LBF_KEEP_SHARED	0x20
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -5313,82 +5270,6 @@ static void move_task(struct task_struct *p, struct lb_env *env)
 	check_preempt_curr(env->dst_rq, p, 0);
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-
-static inline unsigned long task_node_faults(struct task_struct *p, int node)
-{
-	return p->numa_faults[2*node] + p->numa_faults[2*node + 1];
-}
-
-static int task_faults_down(struct task_struct *p, struct lb_env *env)
-{
-	int src_node, dst_node, node, down_node = -1;
-	unsigned long faults, src_faults, max_faults = 0;
-
-	if (!sched_feat_numa(NUMA_FAULTS_DOWN) || !p->numa_faults)
-		return 1;
-
-	src_node = cpu_to_node(env->src_cpu);
-	dst_node = cpu_to_node(env->dst_cpu);
-
-	if (src_node == dst_node)
-		return 1;
-
-	src_faults = task_node_faults(p, src_node);
-
-	for (node = 0; node < nr_node_ids; node++) {
-		if (node == src_node)
-			continue;
-
-		faults = task_node_faults(p, node);
-
-		if (faults > max_faults && faults <= src_faults) {
-			max_faults = faults;
-			down_node = node;
-		}
-	}
-
-	if (down_node == dst_node)
-		return 1; /* move towards the next node down */
-
-	return 0; /* stay here */
-}
-
-static int task_faults_up(struct task_struct *p, struct lb_env *env)
-{
-	unsigned long src_faults, dst_faults;
-	int src_node, dst_node;
-
-	if (!sched_feat_numa(NUMA_FAULTS_UP) || !p->numa_faults)
-		return 0; /* can't say it improved */
-
-	src_node = cpu_to_node(env->src_cpu);
-	dst_node = cpu_to_node(env->dst_cpu);
-
-	if (src_node == dst_node)
-		return 0; /* pointless, don't do that */
-
-	src_faults = task_node_faults(p, src_node);
-	dst_faults = task_node_faults(p, dst_node);
-
-	if (dst_faults > src_faults)
-		return 1; /* move to dst */
-
-	return 0; /* stay where we are */
-}
-
-#else /* !CONFIG_NUMA_BALANCING: */
-static inline int task_faults_up(struct task_struct *p, struct lb_env *env)
-{
-	return 0;
-}
-
-static inline int task_faults_down(struct task_struct *p, struct lb_env *env)
-{
-	return 0;
-}
-#endif
-
 /*
  * Is this task likely cache-hot:
  */
@@ -5469,77 +5350,6 @@ static bool can_migrate_running_task(struct task_struct *p, struct lb_env *env)
 }
 
 /*
- * Can we migrate a NUMA task? The rules are rather involved:
- */
-static bool can_migrate_numa_task(struct task_struct *p, struct lb_env *env)
-{
-	/*
-	 * iteration:
-	 *   0		   -- only allow improvement, or !numa
-	 *   1		   -- + worsen !ideal
-	 *   2                         priv
-	 *   3                         shared (everything)
-	 *
-	 * NUMA_HOT_DOWN:
-	 *   1 .. nodes    -- allow getting worse by step
-	 *   nodes+1	   -- punt, everything goes!
-	 *
-	 * LBF_NUMA_RUN    -- numa only, only allow improvement
-	 * LBF_NUMA_SHARED -- shared only
-	 * LBF_NUMA_IDEAL  -- ideal only
-	 *
-	 * LBF_KEEP_SHARED -- do not touch shared tasks
-	 */
-
-	/* a numa run can only move numa tasks about to improve things */
-	if (env->flags & LBF_NUMA_RUN) {
-		if (task_numa_shared(p) < 0 && task_ideal_cpu(p) < 0)
-			return false;
-
-		/* If we are only allowed to pull shared tasks: */
-		if ((env->flags & LBF_NUMA_SHARED) && !task_numa_shared(p))
-			return false;
-	} else {
-		if (task_numa_shared(p) < 0)
-			goto try_migrate;
-	}
-
-	/* can not move shared tasks */
-	if ((env->flags & LBF_KEEP_SHARED) && task_numa_shared(p) == 1)
-		return false;
-
-	if (task_faults_up(p, env))
-		return true; /* memory locality beats cache hotness */
-
-	if (env->iteration < 1)
-		return false;
-
-#ifdef CONFIG_NUMA_BALANCING
-	if (p->numa_max_node != cpu_to_node(task_cpu(p))) /* !ideal */
-		goto demote;
-#endif
-
-	if (env->iteration < 2)
-		return false;
-
-	if (task_numa_shared(p) == 0) /* private */
-		goto demote;
-
-	if (env->iteration < 3)
-		return false;
-
-demote:
-	if (env->iteration < 5)
-		return task_faults_down(p, env);
-
-try_migrate:
-	if (env->failed > env->sd->cache_nice_tries)
-		return true;
-
-	return !task_hot(p, env);
-}
-
-/*
  * can_migrate_task() - may task p from runqueue rq be migrated to this_cpu?
  */
 static int can_migrate_task(struct task_struct *p, struct lb_env *env)
@@ -5559,7 +5369,7 @@ static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 
 #ifdef CONFIG_NUMA_BALANCING
 	/* If we are only allowed to pull ideal tasks: */
-	if ((task_ideal_cpu(p) >= 0) && (p->shared_buddy_faults > 1000)) {
+	if (0 && (task_ideal_cpu(p) >= 0) && (p->shared_buddy_faults > 1000)) {
 		int ideal_node;
 		int dst_node;
 
@@ -5575,9 +5385,6 @@ static int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	}
 #endif
 
-	if (env->sd->flags & SD_NUMA)
-		return can_migrate_numa_task(p, env);
-
 	if (env->failed > env->sd->cache_nice_tries)
 		return true;
 
@@ -5867,24 +5674,6 @@ struct sd_lb_stats {
 	unsigned int  busiest_group_weight;
 
 	int group_imb; /* Is there imbalance in this sd */
-
-#ifdef CONFIG_NUMA_BALANCING
-	unsigned long this_numa_running;
-	unsigned long this_numa_weight;
-	unsigned long this_shared_running;
-	unsigned long this_ideal_running;
-	unsigned long this_group_capacity;
-
-	struct sched_group *numa;
-	unsigned long numa_load;
-	unsigned long numa_nr_running;
-	unsigned long numa_numa_running;
-	unsigned long numa_shared_running;
-	unsigned long numa_ideal_running;
-	unsigned long numa_numa_weight;
-	unsigned long numa_group_capacity;
-	unsigned int  numa_has_capacity;
-#endif
 };
 
 /*
@@ -5900,13 +5689,6 @@ struct sg_lb_stats {
 	unsigned long group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
-
-#ifdef CONFIG_NUMA_BALANCING
-	unsigned long sum_ideal_running;
-	unsigned long sum_numa_running;
-	unsigned long sum_numa_weight;
-#endif
-	unsigned long sum_shared_running;	/* 0 on non-NUMA */
 };
 
 /**
@@ -5935,158 +5717,6 @@ static inline int get_sd_load_idx(struct sched_domain *sd,
 	return load_idx;
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-
-static inline bool pick_numa_rand(int n)
-{
-	return !(get_random_int() % n);
-}
-
-static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
-{
-	sgs->sum_ideal_running += rq->nr_ideal_running;
-	sgs->sum_shared_running += rq->nr_shared_running;
-	sgs->sum_numa_running += rq->nr_numa_running;
-	sgs->sum_numa_weight += rq->numa_weight;
-}
-
-static inline
-void update_sd_numa_stats(struct sched_domain *sd, struct sched_group *sg,
-			  struct sd_lb_stats *sds, struct sg_lb_stats *sgs,
-			  int local_group)
-{
-	if (!(sd->flags & SD_NUMA))
-		return;
-
-	if (local_group) {
-		sds->this_numa_running   = sgs->sum_numa_running;
-		sds->this_numa_weight    = sgs->sum_numa_weight;
-		sds->this_shared_running = sgs->sum_shared_running;
-		sds->this_ideal_running  = sgs->sum_ideal_running;
-		sds->this_group_capacity = sgs->group_capacity;
-
-	} else if (sgs->sum_numa_running - sgs->sum_ideal_running) {
-		if (!sds->numa || pick_numa_rand(sd->span_weight / sg->group_weight)) {
-			sds->numa = sg;
-			sds->numa_load		 = sgs->avg_load;
-			sds->numa_nr_running     = sgs->sum_nr_running;
-			sds->numa_numa_running   = sgs->sum_numa_running;
-			sds->numa_shared_running = sgs->sum_shared_running;
-			sds->numa_ideal_running  = sgs->sum_ideal_running;
-			sds->numa_numa_weight    = sgs->sum_numa_weight;
-			sds->numa_has_capacity	 = sgs->group_has_capacity;
-			sds->numa_group_capacity = sgs->group_capacity;
-		}
-	}
-}
-
-static struct rq *
-find_busiest_numa_queue(struct lb_env *env, struct sched_group *sg)
-{
-	struct rq *rq, *busiest = NULL;
-	int cpu;
-
-	for_each_cpu_and(cpu, sched_group_cpus(sg), env->cpus) {
-		rq = cpu_rq(cpu);
-
-		if (!rq->nr_numa_running)
-			continue;
-
-		if (!(rq->nr_numa_running - rq->nr_ideal_running))
-			continue;
-
-		if ((env->flags & LBF_KEEP_SHARED) && !(rq->nr_running - rq->nr_shared_running))
-			continue;
-
-		if (!busiest || pick_numa_rand(sg->group_weight))
-			busiest = rq;
-	}
-
-	return busiest;
-}
-
-static bool can_do_numa_run(struct lb_env *env, struct sd_lb_stats *sds)
-{
-	/*
-	 * if we're overloaded; don't pull when:
-	 *   - the other guy isn't
-	 *   - imbalance would become too great
-	 */
-	if (!sds->this_has_capacity) {
-		if (sds->numa_has_capacity)
-			return false;
-	}
-
-	/*
-	 * pull if we got easy trade
-	 */
-	if (sds->this_nr_running - sds->this_numa_running)
-		return true;
-
-	/*
-	 * If we got capacity allow stacking up on shared tasks.
-	 */
-	if ((sds->this_shared_running < sds->this_group_capacity) && sds->numa_shared_running) {
-		/* There's no point in trying to move if all are here already: */
-		if (sds->numa_shared_running == sds->this_shared_running)
-			return false;
-
-		env->flags |= LBF_NUMA_SHARED;
-		return true;
-	}
-
-	/*
-	 * pull if we could possibly trade
-	 */
-	if (sds->this_numa_running - sds->this_ideal_running)
-		return true;
-
-	return false;
-}
-
-/*
- * introduce some controlled imbalance to perturb the state so we allow the
- * state to improve should be tightly controlled/co-ordinated with
- * can_migrate_task()
- */
-static int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
-{
-	if (!sched_feat(NUMA_LB))
-		return 0;
-
-	if (!sds->numa || !sds->numa_numa_running)
-		return 0;
-
-	if (!can_do_numa_run(env, sds))
-		return 0;
-
-	env->flags |= LBF_NUMA_RUN;
-	env->flags &= ~LBF_KEEP_SHARED;
-	env->imbalance = sds->numa_numa_weight / sds->numa_numa_running;
-	sds->busiest = sds->numa;
-	env->find_busiest_queue = find_busiest_numa_queue;
-
-	return 1;
-}
-
-#else /* !CONFIG_NUMA_BALANCING: */
-static inline
-void update_sd_numa_stats(struct sched_domain *sd, struct sched_group *sg,
-			  struct sd_lb_stats *sds, struct sg_lb_stats *sgs,
-			  int local_group)
-{
-}
-
-static inline void update_sg_numa_stats(struct sg_lb_stats *sgs, struct rq *rq)
-{
-}
-
-static inline int check_numa_busiest_group(struct lb_env *env, struct sd_lb_stats *sds)
-{
-	return 0;
-}
-#endif
-
 unsigned long default_scale_freq_power(struct sched_domain *sd, int cpu)
 {
 	return SCHED_POWER_SCALE;
@@ -6301,8 +5931,6 @@ static inline void update_sg_lb_stats(struct lb_env *env,
 		sgs->sum_nr_running += nr_running;
 		sgs->sum_weighted_load += weighted_cpuload(i);
 
-		update_sg_numa_stats(sgs, rq);
-
 		if (idle_cpu(i))
 			sgs->idle_cpus++;
 	}
@@ -6394,13 +6022,6 @@ static bool update_sd_pick_busiest(struct lb_env *env,
 	return false;
 }
 
-static void update_src_keep_shared(struct lb_env *env, bool keep_shared)
-{
-	env->flags &= ~LBF_KEEP_SHARED;
-	if (keep_shared)
-		env->flags |= LBF_KEEP_SHARED;
-}
-
 /**
  * update_sd_lb_stats - Update sched_domain's statistics for load balancing.
  * @env: The load balancing environment.
@@ -6433,23 +6054,6 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 		sds->total_load += sgs.group_load;
 		sds->total_pwr += sg->sgp->power;
 
-#ifdef CONFIG_NUMA_BALANCING
-		/*
-		 * In case the child domain prefers tasks go to siblings
-		 * first, lower the sg capacity to one so that we'll try
-		 * and move all the excess tasks away. We lower the capacity
-		 * of a group only if the local group has the capacity to fit
-		 * these excess tasks, i.e. nr_running < group_capacity. The
-		 * extra check prevents the case where you always pull from the
-		 * heaviest group when it is already under-utilized (possible
-		 * with a large weight task outweighs the tasks on the system).
-		 */
-		if (0 && prefer_sibling && !local_group && sds->this_has_capacity) {
-			sgs.group_capacity = clamp_val(sgs.sum_shared_running,
-					1UL, sgs.group_capacity);
-		}
-#endif
-
 		if (local_group) {
 			sds->this_load = sgs.avg_load;
 			sds->this = sg;
@@ -6467,13 +6071,8 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 			sds->busiest_has_capacity = sgs.group_has_capacity;
 			sds->busiest_group_weight = sgs.group_weight;
 			sds->group_imb = sgs.group_imb;
-
-			update_src_keep_shared(env,
-				sgs.sum_shared_running <= sgs.group_capacity);
 		}
 
-		update_sd_numa_stats(env->sd, sg, sds, &sgs, local_group);
-
 		sg = sg->next;
 	} while (sg != env->sd->groups);
 }
@@ -6765,9 +6364,6 @@ out_imbalanced:
 		goto ret;
 
 out_balanced:
-	if (check_numa_busiest_group(env, &sds))
-		return sds.busiest;
-
 ret:
 	env->imbalance = 0;
 
@@ -6806,9 +6402,6 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 		if (capacity && rq->nr_running == 1 && wl > env->imbalance)
 			continue;
 
-		if ((env->flags & LBF_KEEP_SHARED) && !(rq->nr_running - rq->nr_shared_running))
-			continue;
-
 		/*
 		 * For the load comparisons with the other cpu's, consider
 		 * the weighted_cpuload() scaled with the cpu power, so that
@@ -6847,30 +6440,13 @@ static void update_sd_failed(struct lb_env *env, int ld_moved)
 		 * frequent, pollute the failure counter causing
 		 * excessive cache_hot migrations and active balances.
 		 */
-		if (env->idle != CPU_NEWLY_IDLE && !(env->flags & LBF_NUMA_RUN))
+		if (env->idle != CPU_NEWLY_IDLE)
 			env->sd->nr_balance_failed++;
 	} else
 		env->sd->nr_balance_failed = 0;
 }
 
 /*
- * See can_migrate_numa_task()
- */
-static int lb_max_iteration(struct lb_env *env)
-{
-	if (!(env->sd->flags & SD_NUMA))
-		return 0;
-
-	if (env->flags & LBF_NUMA_RUN)
-		return 0; /* NUMA_RUN may only improve */
-
-	if (sched_feat_numa(NUMA_FAULTS_DOWN))
-		return 5; /* nodes^2 would suck */
-
-	return 3;
-}
-
-/*
  * Check this_cpu to ensure it is balanced within domain. Attempt to move
  * tasks if there is an imbalance.
  */
@@ -7006,7 +6582,7 @@ more_balance:
 		if (unlikely(env.flags & LBF_ALL_PINNED))
 			goto out_pinned;
 
-		if (!ld_moved && env.iteration < lb_max_iteration(&env)) {
+		if (!ld_moved && env.iteration < 3) {
 			env.iteration++;
 			env.loop = 0;
 			goto more_balance;
@@ -7192,7 +6768,7 @@ static int active_load_balance_cpu_stop(void *data)
 			.failed		= busiest_rq->ab_failed,
 			.idle		= busiest_rq->ab_idle,
 		};
-		env.iteration = lb_max_iteration(&env);
+		env.iteration = 3;
 
 		schedstat_inc(sd, alb_count);
 
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 2529f05..fd9db0b 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -75,9 +75,6 @@ SCHED_FEAT(WAKE_ON_IDEAL_CPU,		false)
 #ifdef CONFIG_NUMA_BALANCING
 /* Do the working set probing faults: */
 SCHED_FEAT(NUMA,			true)
-SCHED_FEAT(NUMA_FAULTS_UP,		false)
-SCHED_FEAT(NUMA_FAULTS_DOWN,		false)
-SCHED_FEAT(NUMA_SETTLE,			false)
 SCHED_FEAT(NUMA_BALANCE_ALL,		false)
 SCHED_FEAT(NUMA_BALANCE_INTERNODE,		false)
 SCHED_FEAT(NUMA_LB,			false)
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index f46405e..733f646 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -438,9 +438,6 @@ struct rq {
 	struct list_head cfs_tasks;
 
 #ifdef CONFIG_NUMA_BALANCING
-	unsigned long numa_weight;
-	unsigned long nr_numa_running;
-	unsigned long nr_ideal_running;
 	struct task_struct *curr_buddy;
 #endif
 	unsigned long nr_shared_running;	/* 0 on non-NUMA */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
