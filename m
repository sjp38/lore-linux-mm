Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 14AFF6B0036
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:27:59 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2581232pbb.27
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:27:58 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/63] sched: monolithic code dump of what is being pushed upstream
Date: Fri, 27 Sep 2013 14:26:46 +0100
Message-Id: <1380288468-5551-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

So I have the below patch in front of all your patches. It contains the
10 or so sched,fair patches I posted to lkml the other day.

I used these to poke at the group_imb crud, am now digging through
traces of perf bench numa to see if there's anything else I need.

like said on IRC: I boot with ftrace=nop to ensure we allocate properly
sized trace buffers. This can also be done at runtime by switching
active tracer -- this allocates the default buffer size, or by
explicitly setting a per-cpu buffer size in
/debug/tracing/buffer_size_kb. By default the thing allocates a single
page per cpu or something uselessly small like that.

I then run a benchmark and at an appropriate time (eg. when I see
something 'weird' happen) I do something like:

  echo 0 > /debug/tracing/tracing_on  # disable writing into the buffers
  cat /debug/tracing/trace > ~/trace  # dump to file
  echo 0 > /debug/tracing/trace       # reset buffers
  echo 1 > /debug/tracing/tracing_on  # enable writing to the buffers

[ Note I mount debugfs at /debug, this is not the default location but I
  think the rest of the world is wrong ;-) ]

Also, the brain seems to adapt once you're staring at them for longer
than a day -- yay for human pattern recognition skillz.

Ingo tends to favour more verbose dumps, I tend to favour minimal
dumps.. whatever works for you is something you'll learn with
experience.
---
 arch/x86/mm/numa.c   |   6 +-
 kernel/sched/core.c  |  18 +-
 kernel/sched/fair.c  | 498 ++++++++++++++++++++++++++++-----------------------
 kernel/sched/sched.h |   1 +
 lib/vsprintf.c       |   5 +
 5 files changed, 288 insertions(+), 240 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 8bf93ba..4ed4612 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -737,7 +737,6 @@ int early_cpu_to_node(int cpu)
 void debug_cpumask_set_cpu(int cpu, int node, bool enable)
 {
 	struct cpumask *mask;
-	char buf[64];
 
 	if (node == NUMA_NO_NODE) {
 		/* early_cpu_to_node() already emits a warning and trace */
@@ -755,10 +754,9 @@ void debug_cpumask_set_cpu(int cpu, int node, bool enable)
 	else
 		cpumask_clear_cpu(cpu, mask);
 
-	cpulist_scnprintf(buf, sizeof(buf), mask);
-	printk(KERN_DEBUG "%s cpu %d node %d: mask now %s\n",
+	printk(KERN_DEBUG "%s cpu %d node %d: mask now %pc\n",
 		enable ? "numa_add_cpu" : "numa_remove_cpu",
-		cpu, node, buf);
+		cpu, node, mask);
 	return;
 }
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 05c39f0..f307c2c 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4809,9 +4809,7 @@ static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level,
 				  struct cpumask *groupmask)
 {
 	struct sched_group *group = sd->groups;
-	char str[256];
 
-	cpulist_scnprintf(str, sizeof(str), sched_domain_span(sd));
 	cpumask_clear(groupmask);
 
 	printk(KERN_DEBUG "%*s domain %d: ", level, "", level);
@@ -4824,7 +4822,7 @@ static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level,
 		return -1;
 	}
 
-	printk(KERN_CONT "span %s level %s\n", str, sd->name);
+	printk(KERN_CONT "span %pc level %s\n", sched_domain_span(sd), sd->name);
 
 	if (!cpumask_test_cpu(cpu, sched_domain_span(sd))) {
 		printk(KERN_ERR "ERROR: domain->span does not contain "
@@ -4870,9 +4868,7 @@ static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level,
 
 		cpumask_or(groupmask, groupmask, sched_group_cpus(group));
 
-		cpulist_scnprintf(str, sizeof(str), sched_group_cpus(group));
-
-		printk(KERN_CONT " %s", str);
+		printk(KERN_CONT " %pc", sched_group_cpus(group));
 		if (group->sgp->power != SCHED_POWER_SCALE) {
 			printk(KERN_CONT " (cpu_power = %d)",
 				group->sgp->power);
@@ -4964,7 +4960,8 @@ sd_parent_degenerate(struct sched_domain *sd, struct sched_domain *parent)
 				SD_BALANCE_FORK |
 				SD_BALANCE_EXEC |
 				SD_SHARE_CPUPOWER |
-				SD_SHARE_PKG_RESOURCES);
+				SD_SHARE_PKG_RESOURCES |
+				SD_PREFER_SIBLING);
 		if (nr_node_ids == 1)
 			pflags &= ~SD_SERIALIZE;
 	}
@@ -5168,6 +5165,13 @@ cpu_attach_domain(struct sched_domain *sd, struct root_domain *rd, int cpu)
 			tmp->parent = parent->parent;
 			if (parent->parent)
 				parent->parent->child = tmp;
+			/*
+			 * Transfer SD_PREFER_SIBLING down in case of a
+			 * degenerate parent; the spans match for this
+			 * so the property transfers.
+			 */
+			if (parent->flags & SD_PREFER_SIBLING)
+				tmp->flags |= SD_PREFER_SIBLING;
 			destroy_sched_domain(parent, cpu);
 		} else
 			tmp = tmp->parent;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 68f1609..f238d49 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3859,7 +3859,8 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
-#define LBF_SOME_PINNED 0x04
+#define LBF_DST_PINNED  0x04
+#define LBF_SOME_PINNED	0x08
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3950,6 +3951,8 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 
 		schedstat_inc(p, se.statistics.nr_failed_migrations_affine);
 
+		env->flags |= LBF_SOME_PINNED;
+
 		/*
 		 * Remember if this task can be migrated to any other cpu in
 		 * our sched_group. We may want to revisit it if we couldn't
@@ -3958,13 +3961,13 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		 * Also avoid computing new_dst_cpu if we have already computed
 		 * one in current iteration.
 		 */
-		if (!env->dst_grpmask || (env->flags & LBF_SOME_PINNED))
+		if (!env->dst_grpmask || (env->flags & LBF_DST_PINNED))
 			return 0;
 
 		/* Prevent to re-select dst_cpu via env's cpus */
 		for_each_cpu_and(cpu, env->dst_grpmask, env->cpus) {
 			if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p))) {
-				env->flags |= LBF_SOME_PINNED;
+				env->flags |= LBF_DST_PINNED;
 				env->new_dst_cpu = cpu;
 				break;
 			}
@@ -4019,6 +4022,7 @@ static int move_one_task(struct lb_env *env)
 			continue;
 
 		move_task(p, env);
+
 		/*
 		 * Right now, this is only the second place move_task()
 		 * is called, so we can safely collect move_task()
@@ -4233,50 +4237,65 @@ static unsigned long task_h_load(struct task_struct *p)
 
 /********** Helpers for find_busiest_group ************************/
 /*
- * sd_lb_stats - Structure to store the statistics of a sched_domain
- * 		during load balancing.
- */
-struct sd_lb_stats {
-	struct sched_group *busiest; /* Busiest group in this sd */
-	struct sched_group *this;  /* Local group in this sd */
-	unsigned long total_load;  /* Total load of all groups in sd */
-	unsigned long total_pwr;   /*	Total power of all groups in sd */
-	unsigned long avg_load;	   /* Average load across all groups in sd */
-
-	/** Statistics of this group */
-	unsigned long this_load;
-	unsigned long this_load_per_task;
-	unsigned long this_nr_running;
-	unsigned long this_has_capacity;
-	unsigned int  this_idle_cpus;
-
-	/* Statistics of the busiest group */
-	unsigned int  busiest_idle_cpus;
-	unsigned long max_load;
-	unsigned long busiest_load_per_task;
-	unsigned long busiest_nr_running;
-	unsigned long busiest_group_capacity;
-	unsigned long busiest_has_capacity;
-	unsigned int  busiest_group_weight;
-
-	int group_imb; /* Is there imbalance in this sd */
-};
-
-/*
  * sg_lb_stats - stats of a sched_group required for load_balancing
  */
 struct sg_lb_stats {
 	unsigned long avg_load; /*Avg load across the CPUs of the group */
 	unsigned long group_load; /* Total load over the CPUs of the group */
-	unsigned long sum_nr_running; /* Nr tasks running in the group */
 	unsigned long sum_weighted_load; /* Weighted load of group's tasks */
-	unsigned long group_capacity;
-	unsigned long idle_cpus;
-	unsigned long group_weight;
+	unsigned long load_per_task;
+	unsigned long group_power;
+	unsigned int sum_nr_running; /* Nr tasks running in the group */
+	unsigned int group_capacity;
+	unsigned int idle_cpus;
+	unsigned int group_weight;
 	int group_imb; /* Is there an imbalance in the group ? */
 	int group_has_capacity; /* Is there extra capacity in the group? */
 };
 
+/*
+ * sd_lb_stats - Structure to store the statistics of a sched_domain
+ *		 during load balancing.
+ */
+struct sd_lb_stats {
+	struct sched_group *busiest;	/* Busiest group in this sd */
+	struct sched_group *this;	/* Local group in this sd */
+	unsigned long total_load;	/* Total load of all groups in sd */
+	unsigned long total_pwr;	/* Total power of all groups in sd */
+	unsigned long avg_load;	/* Average load across all groups in sd */
+
+	struct sg_lb_stats busiest_stat;/* Statistics of the busiest group */
+	struct sg_lb_stats this_stat;	/* Statistics of this group */
+};
+
+static inline void init_sd_lb_stats(struct sd_lb_stats *sds)
+{
+	/*
+	 * struct sd_lb_stats {
+	 *	   struct sched_group *       busiest;             //     0  8
+	 *	   struct sched_group *       this;                //     8  8
+	 *	   long unsigned int          total_load;          //    16  8
+	 *	   long unsigned int          total_pwr;           //    24  8
+	 *	   long unsigned int          avg_load;            //    32  8
+	 *	   struct sg_lb_stats {
+	 *		   long unsigned int  avg_load;            //    40  8
+	 *		   long unsigned int  group_load;          //    48  8
+	 *	           ...
+	 *	   } busiest_stat;                                 //    40 64
+	 *	   struct sg_lb_stats	      this_stat;	   //   104 64
+	 *
+	 *	   // size: 168, cachelines: 3, members: 7
+	 *	   // last cacheline: 40 bytes
+	 * };
+	 *
+	 * Skimp on the clearing to avoid duplicate work. We can avoid clearing
+	 * this_stat because update_sg_lb_stats() does a full clear/assignment.
+	 * We must however clear busiest_stat::avg_load because
+	 * update_sd_pick_busiest() reads this before assignment.
+	 */
+	memset(sds, 0, offsetof(struct sd_lb_stats, busiest_stat.group_load));
+}
+
 /**
  * get_sd_load_idx - Obtain the load index for a given sched domain.
  * @sd: The sched_domain whose load_idx is to be obtained.
@@ -4460,60 +4479,66 @@ fix_small_capacity(struct sched_domain *sd, struct sched_group *group)
 	return 0;
 }
 
+/*
+ * Group imbalance indicates (and tries to solve) the problem where balancing
+ * groups is inadequate due to tsk_cpus_allowed() constraints.
+ *
+ * Imagine a situation of two groups of 4 cpus each and 4 tasks each with a
+ * cpumask covering 1 cpu of the first group and 3 cpus of the second group.
+ * Something like:
+ *
+ * 	{ 0 1 2 3 } { 4 5 6 7 }
+ * 	        *     * * *
+ *
+ * If we were to balance group-wise we'd place two tasks in the first group and
+ * two tasks in the second group. Clearly this is undesired as it will overload
+ * cpu 3 and leave one of the cpus in the second group unused.
+ *
+ * The current solution to this issue is detecting the skew in the first group
+ * by noticing the lower domain failed to reach balance and had difficulty
+ * moving tasks due to affinity constraints.
+ *
+ * When this is so detected; this group becomes a candidate for busiest; see
+ * update_sd_pick_busiest(). And calculcate_imbalance() and
+ * find_busiest_group() avoid some of the usual balance conditions to allow it
+ * to create an effective group imbalance.
+ *
+ * This is a somewhat tricky proposition since the next run might not find the
+ * group imbalance and decide the groups need to be balanced again. A most
+ * subtle and fragile situation.
+ */
+
+static inline int sg_imbalanced(struct sched_group *group)
+{
+	return group->sgp->imbalance;
+}
+
 /**
  * update_sg_lb_stats - Update sched_group's statistics for load balancing.
  * @env: The load balancing environment.
  * @group: sched_group whose statistics are to be updated.
  * @load_idx: Load index of sched_domain of this_cpu for load calc.
  * @local_group: Does group contain this_cpu.
- * @balance: Should we balance.
  * @sgs: variable to hold the statistics for this group.
  */
 static inline void update_sg_lb_stats(struct lb_env *env,
 			struct sched_group *group, int load_idx,
-			int local_group, int *balance, struct sg_lb_stats *sgs)
+			int local_group, struct sg_lb_stats *sgs)
 {
-	unsigned long nr_running, max_nr_running, min_nr_running;
-	unsigned long load, max_cpu_load, min_cpu_load;
-	unsigned int balance_cpu = -1, first_idle_cpu = 0;
-	unsigned long avg_load_per_task = 0;
+	unsigned long nr_running;
+	unsigned long load;
 	int i;
 
-	if (local_group)
-		balance_cpu = group_balance_cpu(group);
-
-	/* Tally up the load of all CPUs in the group */
-	max_cpu_load = 0;
-	min_cpu_load = ~0UL;
-	max_nr_running = 0;
-	min_nr_running = ~0UL;
-
 	for_each_cpu_and(i, sched_group_cpus(group), env->cpus) {
 		struct rq *rq = cpu_rq(i);
 
 		nr_running = rq->nr_running;
 
 		/* Bias balancing toward cpus of our domain */
-		if (local_group) {
-			if (idle_cpu(i) && !first_idle_cpu &&
-					cpumask_test_cpu(i, sched_group_mask(group))) {
-				first_idle_cpu = 1;
-				balance_cpu = i;
-			}
-
+		if (local_group)
 			load = target_load(i, load_idx);
-		} else {
+		else
 			load = source_load(i, load_idx);
-			if (load > max_cpu_load)
-				max_cpu_load = load;
-			if (min_cpu_load > load)
-				min_cpu_load = load;
-
-			if (nr_running > max_nr_running)
-				max_nr_running = nr_running;
-			if (min_nr_running > nr_running)
-				min_nr_running = nr_running;
-		}
 
 		sgs->group_load += load;
 		sgs->sum_nr_running += nr_running;
@@ -4522,46 +4547,25 @@ static inline void update_sg_lb_stats(struct lb_env *env,
 			sgs->idle_cpus++;
 	}
 
-	/*
-	 * First idle cpu or the first cpu(busiest) in this sched group
-	 * is eligible for doing load balancing at this and above
-	 * domains. In the newly idle case, we will allow all the cpu's
-	 * to do the newly idle load balance.
-	 */
-	if (local_group) {
-		if (env->idle != CPU_NEWLY_IDLE) {
-			if (balance_cpu != env->dst_cpu) {
-				*balance = 0;
-				return;
-			}
-			update_group_power(env->sd, env->dst_cpu);
-		} else if (time_after_eq(jiffies, group->sgp->next_update))
-			update_group_power(env->sd, env->dst_cpu);
-	}
+	if (local_group && (env->idle != CPU_NEWLY_IDLE ||
+			time_after_eq(jiffies, group->sgp->next_update)))
+		update_group_power(env->sd, env->dst_cpu);
 
 	/* Adjust by relative CPU power of the group */
-	sgs->avg_load = (sgs->group_load*SCHED_POWER_SCALE) / group->sgp->power;
+	sgs->group_power = group->sgp->power;
+	sgs->avg_load = (sgs->group_load*SCHED_POWER_SCALE) / sgs->group_power;
 
-	/*
-	 * Consider the group unbalanced when the imbalance is larger
-	 * than the average weight of a task.
-	 *
-	 * APZ: with cgroup the avg task weight can vary wildly and
-	 *      might not be a suitable number - should we keep a
-	 *      normalized nr_running number somewhere that negates
-	 *      the hierarchy?
-	 */
 	if (sgs->sum_nr_running)
-		avg_load_per_task = sgs->sum_weighted_load / sgs->sum_nr_running;
+		sgs->load_per_task = sgs->sum_weighted_load / sgs->sum_nr_running;
 
-	if ((max_cpu_load - min_cpu_load) >= avg_load_per_task &&
-	    (max_nr_running - min_nr_running) > 1)
-		sgs->group_imb = 1;
+	sgs->group_imb = sg_imbalanced(group);
+
+	sgs->group_capacity =
+		DIV_ROUND_CLOSEST(sgs->group_power, SCHED_POWER_SCALE);
 
-	sgs->group_capacity = DIV_ROUND_CLOSEST(group->sgp->power,
-						SCHED_POWER_SCALE);
 	if (!sgs->group_capacity)
 		sgs->group_capacity = fix_small_capacity(env->sd, group);
+
 	sgs->group_weight = group->group_weight;
 
 	if (sgs->group_capacity > sgs->sum_nr_running)
@@ -4586,7 +4590,7 @@ static bool update_sd_pick_busiest(struct lb_env *env,
 				   struct sched_group *sg,
 				   struct sg_lb_stats *sgs)
 {
-	if (sgs->avg_load <= sds->max_load)
+	if (sgs->avg_load <= sds->busiest_stat.avg_load)
 		return false;
 
 	if (sgs->sum_nr_running > sgs->group_capacity)
@@ -4619,11 +4623,11 @@ static bool update_sd_pick_busiest(struct lb_env *env,
  * @sds: variable to hold the statistics for this sched_domain.
  */
 static inline void update_sd_lb_stats(struct lb_env *env,
-					int *balance, struct sd_lb_stats *sds)
+					struct sd_lb_stats *sds)
 {
 	struct sched_domain *child = env->sd->child;
 	struct sched_group *sg = env->sd->groups;
-	struct sg_lb_stats sgs;
+	struct sg_lb_stats tmp_sgs;
 	int load_idx, prefer_sibling = 0;
 
 	if (child && child->flags & SD_PREFER_SIBLING)
@@ -4632,17 +4636,17 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 	load_idx = get_sd_load_idx(env->sd, env->idle);
 
 	do {
+		struct sg_lb_stats *sgs = &tmp_sgs;
 		int local_group;
 
 		local_group = cpumask_test_cpu(env->dst_cpu, sched_group_cpus(sg));
-		memset(&sgs, 0, sizeof(sgs));
-		update_sg_lb_stats(env, sg, load_idx, local_group, balance, &sgs);
-
-		if (local_group && !(*balance))
-			return;
+		if (local_group) {
+			sds->this = sg;
+			sgs = &sds->this_stat;
+		}
 
-		sds->total_load += sgs.group_load;
-		sds->total_pwr += sg->sgp->power;
+		memset(sgs, 0, sizeof(*sgs));
+		update_sg_lb_stats(env, sg, load_idx, local_group, sgs);
 
 		/*
 		 * In case the child domain prefers tasks go to siblings
@@ -4654,26 +4658,17 @@ static inline void update_sd_lb_stats(struct lb_env *env,
 		 * heaviest group when it is already under-utilized (possible
 		 * with a large weight task outweighs the tasks on the system).
 		 */
-		if (prefer_sibling && !local_group && sds->this_has_capacity)
-			sgs.group_capacity = min(sgs.group_capacity, 1UL);
+		if (prefer_sibling && !local_group &&
+				sds->this && sds->this_stat.group_has_capacity)
+			sgs->group_capacity = min(sgs->group_capacity, 1U);
 
-		if (local_group) {
-			sds->this_load = sgs.avg_load;
-			sds->this = sg;
-			sds->this_nr_running = sgs.sum_nr_running;
-			sds->this_load_per_task = sgs.sum_weighted_load;
-			sds->this_has_capacity = sgs.group_has_capacity;
-			sds->this_idle_cpus = sgs.idle_cpus;
-		} else if (update_sd_pick_busiest(env, sds, sg, &sgs)) {
-			sds->max_load = sgs.avg_load;
+		/* Now, start updating sd_lb_stats */
+		sds->total_load += sgs->group_load;
+		sds->total_pwr += sgs->group_power;
+
+		if (!local_group && update_sd_pick_busiest(env, sds, sg, sgs)) {
 			sds->busiest = sg;
-			sds->busiest_nr_running = sgs.sum_nr_running;
-			sds->busiest_idle_cpus = sgs.idle_cpus;
-			sds->busiest_group_capacity = sgs.group_capacity;
-			sds->busiest_load_per_task = sgs.sum_weighted_load;
-			sds->busiest_has_capacity = sgs.group_has_capacity;
-			sds->busiest_group_weight = sgs.group_weight;
-			sds->group_imb = sgs.group_imb;
+			sds->busiest_stat = *sgs;
 		}
 
 		sg = sg->next;
@@ -4718,7 +4713,8 @@ static int check_asym_packing(struct lb_env *env, struct sd_lb_stats *sds)
 		return 0;
 
 	env->imbalance = DIV_ROUND_CLOSEST(
-		sds->max_load * sds->busiest->sgp->power, SCHED_POWER_SCALE);
+		sds->busiest_stat.avg_load * sds->busiest_stat.group_power,
+		SCHED_POWER_SCALE);
 
 	return 1;
 }
@@ -4736,24 +4732,23 @@ void fix_small_imbalance(struct lb_env *env, struct sd_lb_stats *sds)
 	unsigned long tmp, pwr_now = 0, pwr_move = 0;
 	unsigned int imbn = 2;
 	unsigned long scaled_busy_load_per_task;
+	struct sg_lb_stats *this, *busiest;
 
-	if (sds->this_nr_running) {
-		sds->this_load_per_task /= sds->this_nr_running;
-		if (sds->busiest_load_per_task >
-				sds->this_load_per_task)
-			imbn = 1;
-	} else {
-		sds->this_load_per_task =
-			cpu_avg_load_per_task(env->dst_cpu);
-	}
+	this = &sds->this_stat;
+	busiest = &sds->busiest_stat;
 
-	scaled_busy_load_per_task = sds->busiest_load_per_task
-					 * SCHED_POWER_SCALE;
-	scaled_busy_load_per_task /= sds->busiest->sgp->power;
+	if (!this->sum_nr_running)
+		this->load_per_task = cpu_avg_load_per_task(env->dst_cpu);
+	else if (busiest->load_per_task > this->load_per_task)
+		imbn = 1;
 
-	if (sds->max_load - sds->this_load + scaled_busy_load_per_task >=
-			(scaled_busy_load_per_task * imbn)) {
-		env->imbalance = sds->busiest_load_per_task;
+	scaled_busy_load_per_task =
+		(busiest->load_per_task * SCHED_POWER_SCALE) /
+		busiest->group_power;
+
+	if (busiest->avg_load - this->avg_load + scaled_busy_load_per_task >=
+	    (scaled_busy_load_per_task * imbn)) {
+		env->imbalance = busiest->load_per_task;
 		return;
 	}
 
@@ -4763,34 +4758,37 @@ void fix_small_imbalance(struct lb_env *env, struct sd_lb_stats *sds)
 	 * moving them.
 	 */
 
-	pwr_now += sds->busiest->sgp->power *
-			min(sds->busiest_load_per_task, sds->max_load);
-	pwr_now += sds->this->sgp->power *
-			min(sds->this_load_per_task, sds->this_load);
+	pwr_now += busiest->group_power *
+			min(busiest->load_per_task, busiest->avg_load);
+	pwr_now += this->group_power *
+			min(this->load_per_task, this->avg_load);
 	pwr_now /= SCHED_POWER_SCALE;
 
 	/* Amount of load we'd subtract */
-	tmp = (sds->busiest_load_per_task * SCHED_POWER_SCALE) /
-		sds->busiest->sgp->power;
-	if (sds->max_load > tmp)
-		pwr_move += sds->busiest->sgp->power *
-			min(sds->busiest_load_per_task, sds->max_load - tmp);
+	tmp = (busiest->load_per_task * SCHED_POWER_SCALE) /
+		busiest->group_power;
+	if (busiest->avg_load > tmp) {
+		pwr_move += busiest->group_power *
+			    min(busiest->load_per_task,
+				busiest->avg_load - tmp);
+	}
 
 	/* Amount of load we'd add */
-	if (sds->max_load * sds->busiest->sgp->power <
-		sds->busiest_load_per_task * SCHED_POWER_SCALE)
-		tmp = (sds->max_load * sds->busiest->sgp->power) /
-			sds->this->sgp->power;
-	else
-		tmp = (sds->busiest_load_per_task * SCHED_POWER_SCALE) /
-			sds->this->sgp->power;
-	pwr_move += sds->this->sgp->power *
-			min(sds->this_load_per_task, sds->this_load + tmp);
+	if (busiest->avg_load * busiest->group_power <
+	    busiest->load_per_task * SCHED_POWER_SCALE) {
+		tmp = (busiest->avg_load * busiest->group_power) /
+		      this->group_power;
+	} else {
+		tmp = (busiest->load_per_task * SCHED_POWER_SCALE) /
+		      this->group_power;
+	}
+	pwr_move += this->group_power *
+		    min(this->load_per_task, this->avg_load + tmp);
 	pwr_move /= SCHED_POWER_SCALE;
 
 	/* Move if we gain throughput */
 	if (pwr_move > pwr_now)
-		env->imbalance = sds->busiest_load_per_task;
+		env->imbalance = busiest->load_per_task;
 }
 
 /**
@@ -4802,11 +4800,18 @@ void fix_small_imbalance(struct lb_env *env, struct sd_lb_stats *sds)
 static inline void calculate_imbalance(struct lb_env *env, struct sd_lb_stats *sds)
 {
 	unsigned long max_pull, load_above_capacity = ~0UL;
+	struct sg_lb_stats *this, *busiest;
 
-	sds->busiest_load_per_task /= sds->busiest_nr_running;
-	if (sds->group_imb) {
-		sds->busiest_load_per_task =
-			min(sds->busiest_load_per_task, sds->avg_load);
+	this = &sds->this_stat;
+	busiest = &sds->busiest_stat;
+
+	if (busiest->group_imb) {
+		/*
+		 * In the group_imb case we cannot rely on group-wide averages
+		 * to ensure cpu-load equilibrium, look at wider averages. XXX
+		 */
+		busiest->load_per_task =
+			min(busiest->load_per_task, sds->avg_load);
 	}
 
 	/*
@@ -4814,21 +4819,22 @@ static inline void calculate_imbalance(struct lb_env *env, struct sd_lb_stats *s
 	 * max load less than avg load(as we skip the groups at or below
 	 * its cpu_power, while calculating max_load..)
 	 */
-	if (sds->max_load < sds->avg_load) {
+	if (busiest->avg_load < sds->avg_load) {
 		env->imbalance = 0;
 		return fix_small_imbalance(env, sds);
 	}
 
-	if (!sds->group_imb) {
+	if (!busiest->group_imb) {
 		/*
 		 * Don't want to pull so many tasks that a group would go idle.
+		 * Except of course for the group_imb case, since then we might
+		 * have to drop below capacity to reach cpu-load equilibrium.
 		 */
-		load_above_capacity = (sds->busiest_nr_running -
-						sds->busiest_group_capacity);
+		load_above_capacity =
+			(busiest->sum_nr_running - busiest->group_capacity);
 
 		load_above_capacity *= (SCHED_LOAD_SCALE * SCHED_POWER_SCALE);
-
-		load_above_capacity /= sds->busiest->sgp->power;
+		load_above_capacity /= busiest->group_power;
 	}
 
 	/*
@@ -4838,15 +4844,14 @@ static inline void calculate_imbalance(struct lb_env *env, struct sd_lb_stats *s
 	 * we also don't want to reduce the group load below the group capacity
 	 * (so that we can implement power-savings policies etc). Thus we look
 	 * for the minimum possible imbalance.
-	 * Be careful of negative numbers as they'll appear as very large values
-	 * with unsigned longs.
 	 */
-	max_pull = min(sds->max_load - sds->avg_load, load_above_capacity);
+	max_pull = min(busiest->avg_load - sds->avg_load, load_above_capacity);
 
 	/* How much load to actually move to equalise the imbalance */
-	env->imbalance = min(max_pull * sds->busiest->sgp->power,
-		(sds->avg_load - sds->this_load) * sds->this->sgp->power)
-			/ SCHED_POWER_SCALE;
+	env->imbalance = min(
+		max_pull * busiest->group_power,
+		(sds->avg_load - this->avg_load) * this->group_power
+	) / SCHED_POWER_SCALE;
 
 	/*
 	 * if *imbalance is less than the average load per runnable task
@@ -4854,9 +4859,8 @@ static inline void calculate_imbalance(struct lb_env *env, struct sd_lb_stats *s
 	 * a think about bumping its value to force at least one task to be
 	 * moved
 	 */
-	if (env->imbalance < sds->busiest_load_per_task)
+	if (env->imbalance < busiest->load_per_task)
 		return fix_small_imbalance(env, sds);
-
 }
 
 /******* find_busiest_group() helpers end here *********************/
@@ -4872,69 +4876,62 @@ static inline void calculate_imbalance(struct lb_env *env, struct sd_lb_stats *s
  * to restore balance.
  *
  * @env: The load balancing environment.
- * @balance: Pointer to a variable indicating if this_cpu
- *	is the appropriate cpu to perform load balancing at this_level.
  *
  * Return:	- The busiest group if imbalance exists.
  *		- If no imbalance and user has opted for power-savings balance,
  *		   return the least loaded group whose CPUs can be
  *		   put to idle by rebalancing its tasks onto our group.
  */
-static struct sched_group *
-find_busiest_group(struct lb_env *env, int *balance)
+static struct sched_group *find_busiest_group(struct lb_env *env)
 {
+	struct sg_lb_stats *this, *busiest;
 	struct sd_lb_stats sds;
 
-	memset(&sds, 0, sizeof(sds));
+	init_sd_lb_stats(&sds);
 
 	/*
 	 * Compute the various statistics relavent for load balancing at
 	 * this level.
 	 */
-	update_sd_lb_stats(env, balance, &sds);
-
-	/*
-	 * this_cpu is not the appropriate cpu to perform load balancing at
-	 * this level.
-	 */
-	if (!(*balance))
-		goto ret;
+	update_sd_lb_stats(env, &sds);
+	this = &sds.this_stat;
+	busiest = &sds.busiest_stat;
 
 	if ((env->idle == CPU_IDLE || env->idle == CPU_NEWLY_IDLE) &&
 	    check_asym_packing(env, &sds))
 		return sds.busiest;
 
 	/* There is no busy sibling group to pull tasks from */
-	if (!sds.busiest || sds.busiest_nr_running == 0)
+	if (!sds.busiest || busiest->sum_nr_running == 0)
 		goto out_balanced;
 
 	sds.avg_load = (SCHED_POWER_SCALE * sds.total_load) / sds.total_pwr;
 
 	/*
 	 * If the busiest group is imbalanced the below checks don't
-	 * work because they assumes all things are equal, which typically
+	 * work because they assume all things are equal, which typically
 	 * isn't true due to cpus_allowed constraints and the like.
 	 */
-	if (sds.group_imb)
+	if (busiest->group_imb)
 		goto force_balance;
 
 	/* SD_BALANCE_NEWIDLE trumps SMP nice when underutilized */
-	if (env->idle == CPU_NEWLY_IDLE && sds.this_has_capacity &&
-			!sds.busiest_has_capacity)
+	if (env->idle == CPU_NEWLY_IDLE && this->group_has_capacity &&
+			!busiest->group_has_capacity)
 		goto force_balance;
 
 	/*
 	 * If the local group is more busy than the selected busiest group
 	 * don't try and pull any tasks.
 	 */
-	if (sds.this_load >= sds.max_load)
+	if (this->avg_load >= busiest->avg_load)
 		goto out_balanced;
 
 	/*
 	 * Don't pull any tasks if this group is already above the domain
 	 * average load.
 	 */
-	if (sds.this_load >= sds.avg_load)
+	if (this->avg_load >= sds.avg_load)
 		goto out_balanced;
 
 	if (env->idle == CPU_IDLE) {
@@ -4944,15 +4941,16 @@ find_busiest_group(struct lb_env *env, int *balance)
 		 * there is no imbalance between this and busiest group
 		 * wrt to idle cpu's, it is balanced.
 		 */
-		if ((sds.this_idle_cpus <= sds.busiest_idle_cpus + 1) &&
-		    sds.busiest_nr_running <= sds.busiest_group_weight)
+		if ((this->idle_cpus <= busiest->idle_cpus + 1) &&
+		    busiest->sum_nr_running <= busiest->group_weight)
 			goto out_balanced;
 	} else {
 		/*
 		 * In the CPU_NEWLY_IDLE, CPU_NOT_IDLE cases, use
 		 * imbalance_pct to be conservative.
 		 */
-		if (100 * sds.max_load <= env->sd->imbalance_pct * sds.this_load)
+		if (100 * busiest->avg_load <=
+				env->sd->imbalance_pct * this->avg_load)
 			goto out_balanced;
 	}
 
@@ -4962,7 +4960,6 @@ force_balance:
 	return sds.busiest;
 
 out_balanced:
-ret:
 	env->imbalance = 0;
 	return NULL;
 }
@@ -4974,10 +4971,10 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 				     struct sched_group *group)
 {
 	struct rq *busiest = NULL, *rq;
-	unsigned long max_load = 0;
+	unsigned long busiest_load = 0, busiest_power = SCHED_POWER_SCALE;
 	int i;
 
-	for_each_cpu(i, sched_group_cpus(group)) {
+	for_each_cpu_and(i, sched_group_cpus(group), env->cpus) {
 		unsigned long power = power_of(i);
 		unsigned long capacity = DIV_ROUND_CLOSEST(power,
 							   SCHED_POWER_SCALE);
@@ -4986,9 +4983,6 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 		if (!capacity)
 			capacity = fix_small_capacity(env->sd, group);
 
-		if (!cpumask_test_cpu(i, env->cpus))
-			continue;
-
 		rq = cpu_rq(i);
 		wl = weighted_cpuload(i);
 
@@ -5005,10 +4999,9 @@ static struct rq *find_busiest_queue(struct lb_env *env,
 		 * the load can be moved away from the cpu that is potentially
 		 * running at a lower capacity.
 		 */
-		wl = (wl * SCHED_POWER_SCALE) / power;
-
-		if (wl > max_load) {
-			max_load = wl;
+		if (wl * busiest_power > busiest_load * power) {
+			busiest_load = wl;
+			busiest_power = power;
 			busiest = rq;
 		}
 	}
@@ -5045,15 +5038,50 @@ static int need_active_balance(struct lb_env *env)
 
 static int active_load_balance_cpu_stop(void *data);
 
+static int should_we_balance(struct lb_env *env)
+{
+	struct sched_group *sg = env->sd->groups;
+	struct cpumask *sg_cpus, *sg_mask;
+	int cpu, balance_cpu = -1;
+
+	/*
+	 * In the newly idle case, we will allow all the cpu's
+	 * to do the newly idle load balance.
+	 */
+	if (env->idle == CPU_NEWLY_IDLE)
+		return 1;
+
+	sg_cpus = sched_group_cpus(sg);
+	sg_mask = sched_group_mask(sg);
+	/* Try to find first idle cpu */
+	for_each_cpu_and(cpu, sg_cpus, env->cpus) {
+		if (!cpumask_test_cpu(cpu, sg_mask) || !idle_cpu(cpu))
+			continue;
+
+		balance_cpu = cpu;
+		break;
+	}
+
+	if (balance_cpu == -1)
+		balance_cpu = group_balance_cpu(sg);
+
+	/*
+	 * First idle cpu or the first cpu(busiest) in this sched group
+	 * is eligible for doing load balancing at this and above domains.
+	 */
+	return balance_cpu == env->dst_cpu;
+}
+
 /*
  * Check this_cpu to ensure it is balanced within domain. Attempt to move
  * tasks if there is an imbalance.
  */
 static int load_balance(int this_cpu, struct rq *this_rq,
 			struct sched_domain *sd, enum cpu_idle_type idle,
-			int *balance)
+			int *should_balance)
 {
 	int ld_moved, cur_ld_moved, active_balance = 0;
+	struct sched_domain *sd_parent = sd->parent;
 	struct sched_group *group;
 	struct rq *busiest;
 	unsigned long flags;
@@ -5080,12 +5108,11 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 
 	schedstat_inc(sd, lb_count[idle]);
 
-redo:
-	group = find_busiest_group(&env, balance);
-
-	if (*balance == 0)
+	if (!(*should_balance = should_we_balance(&env)))
 		goto out_balanced;
 
+redo:
+	group = find_busiest_group(&env);
 	if (!group) {
 		schedstat_inc(sd, lb_nobusyg[idle]);
 		goto out_balanced;
@@ -5158,11 +5185,11 @@ more_balance:
 		 * moreover subsequent load balance cycles should correct the
 		 * excess load moved.
 		 */
-		if ((env.flags & LBF_SOME_PINNED) && env.imbalance > 0) {
+		if ((env.flags & LBF_DST_PINNED) && env.imbalance > 0) {
 
 			env.dst_rq	 = cpu_rq(env.new_dst_cpu);
 			env.dst_cpu	 = env.new_dst_cpu;
-			env.flags	&= ~LBF_SOME_PINNED;
+			env.flags	&= ~LBF_DST_PINNED;
 			env.loop	 = 0;
 			env.loop_break	 = sched_nr_migrate_break;
 
@@ -5176,6 +5203,18 @@ more_balance:
 			goto more_balance;
 		}
 
+		/*
+		 * We failed to reach balance because of affinity.
+		 */
+		if (sd_parent) {
+			int *group_imbalance = &sd_parent->groups->sgp->imbalance;
+
+			if ((env.flags & LBF_SOME_PINNED) && env.imbalance > 0) {
+				*group_imbalance = 1;
+			} else if (*group_imbalance)
+				*group_imbalance = 0;
+		}
+
 		/* All tasks on this runqueue were pinned by CPU affinity */
 		if (unlikely(env.flags & LBF_ALL_PINNED)) {
 			cpumask_clear_cpu(cpu_of(busiest), cpus);
@@ -5298,7 +5337,7 @@ void idle_balance(int this_cpu, struct rq *this_rq)
 	rcu_read_lock();
 	for_each_domain(this_cpu, sd) {
 		unsigned long interval;
-		int balance = 1;
+		int should_balance;
 
 		if (!(sd->flags & SD_LOAD_BALANCE))
 			continue;
@@ -5306,7 +5345,8 @@ void idle_balance(int this_cpu, struct rq *this_rq)
 		if (sd->flags & SD_BALANCE_NEWIDLE) {
 			/* If we've pulled tasks over stop searching: */
 			pulled_task = load_balance(this_cpu, this_rq,
-						   sd, CPU_NEWLY_IDLE, &balance);
+						   sd, CPU_NEWLY_IDLE,
+						   &should_balance);
 		}
 
 		interval = msecs_to_jiffies(sd->balance_interval);
@@ -5544,7 +5584,7 @@ void update_max_interval(void)
  */
 static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 {
-	int balance = 1;
+	int should_balance = 1;
 	struct rq *rq = cpu_rq(cpu);
 	unsigned long interval;
 	struct sched_domain *sd;
@@ -5576,9 +5616,9 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 		}
 
 		if (time_after_eq(jiffies, sd->last_balance + interval)) {
-			if (load_balance(cpu, rq, sd, idle, &balance)) {
+			if (load_balance(cpu, rq, sd, idle, &should_balance)) {
 				/*
-				 * The LBF_SOME_PINNED logic could have changed
+				 * The LBF_DST_PINNED logic could have changed
 				 * env->dst_cpu, so we can't know our idle
 				 * state even if we migrated tasks. Update it.
 				 */
@@ -5599,7 +5639,7 @@ out:
 		 * CPU in our sched group which is doing load balancing more
 		 * actively.
 		 */
-		if (!balance)
+		if (!should_balance)
 			break;
 	}
 	rcu_read_unlock();
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index ef0a7b2..7c17661 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -605,6 +605,7 @@ struct sched_group_power {
 	 */
 	unsigned int power, power_orig;
 	unsigned long next_update;
+	int imbalance; /* XXX unrelated to power but shared group state */
 	/*
 	 * Number of busy cpus in this group.
 	 */
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 739a363..5521015 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -26,6 +26,7 @@
 #include <linux/math64.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/cpumask.h>
 #include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -1142,6 +1143,7 @@ int kptr_restrict __read_mostly;
  *            The maximum supported length is 64 bytes of the input. Consider
  *            to use print_hex_dump() for the larger input.
  * - 'a' For a phys_addr_t type and its derivative types (passed by reference)
+ * - 'c' For a cpumask list
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -1253,6 +1255,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		spec.base = 16;
 		return number(buf, end,
 			      (unsigned long long) *((phys_addr_t *)ptr), spec);
+	case 'c':
+		return buf + cpulist_scnprintf(buf, end - buf, ptr);
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
@@ -1494,6 +1498,7 @@ qualifier:
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
  *           bytes of the input)
+ * %pc print a cpumask as comma-separated list
  * %n is ignored
  *
  * ** Please update Documentation/printk-formats.txt when making changes **
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
