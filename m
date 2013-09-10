Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id ADC966B008A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:13 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 38/50] sched: numa: Use a system-wide search to find swap/migration candidates
Date: Tue, 10 Sep 2013 10:32:18 +0100
Message-Id: <1378805550-29949-39-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch implements a system-wide search for swap/migration candidates
based on total NUMA hinting faults. It has a balance limit, however it
doesn't properly consider total node balance.

In the old scheme a task selected a preferred node based on the highest
number of private faults recorded on the node. In this scheme, the preferred
node is based on the total number of faults. If the preferred node for a
task changes then task_numa_migrate will search the whole system looking
for tasks to swap with that would improve both the overall compute
balance and minimise the expected number of remote NUMA hinting faults.

Note from Mel: There appears to be no guarantee that the node the source
	task is placed on by task_numa_migrate() has any relationship
	to the newly selected task->numa_preferred_nid. It is not clear
	if this is deliberate but it looks accidental.

[riel@redhat.com: Do not swap with tasks that cannot run on source cpu]
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 244 ++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 178 insertions(+), 66 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index cf16c1a..12b42a6 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -816,6 +816,8 @@ update_stats_curr_start(struct cfs_rq *cfs_rq, struct sched_entity *se)
  * Scheduling class queueing methods:
  */
 
+static unsigned long task_h_load(struct task_struct *p);
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * Approximate time to scan a full NUMA task in ms. The task scan period is
@@ -906,12 +908,40 @@ static unsigned long target_load(int cpu, int type);
 static unsigned long power_of(int cpu);
 static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
 
+/* Cached statistics for all CPUs within a node */
 struct numa_stats {
+	unsigned long nr_running;
 	unsigned long load;
-	s64 eff_load;
-	unsigned long faults;
+
+	/* Total compute capacity of CPUs on a node */
+	unsigned long power;
+
+	/* Approximate capacity in terms of runnable tasks on a node */
+	unsigned long capacity;
+	int has_capacity;
 };
 
+/*
+ * XXX borrowed from update_sg_lb_stats
+ */
+static void update_numa_stats(struct numa_stats *ns, int nid)
+{
+	int cpu;
+
+	memset(ns, 0, sizeof(*ns));
+	for_each_cpu(cpu, cpumask_of_node(nid)) {
+		struct rq *rq = cpu_rq(cpu);
+
+		ns->nr_running += rq->nr_running;
+		ns->load += weighted_cpuload(cpu);
+		ns->power += power_of(cpu);
+	}
+
+	ns->load = (ns->load * SCHED_POWER_SCALE) / ns->power;
+	ns->capacity = DIV_ROUND_CLOSEST(ns->power, SCHED_POWER_SCALE);
+	ns->has_capacity = (ns->nr_running < ns->capacity);
+}
+
 struct task_numa_env {
 	struct task_struct *p;
 
@@ -920,28 +950,126 @@ struct task_numa_env {
 
 	struct numa_stats src_stats, dst_stats;
 
-	unsigned long best_load;
+	int imbalance_pct, idx;
+
+	struct task_struct *best_task;
+	long best_imp;
 	int best_cpu;
 };
 
+static void task_numa_assign(struct task_numa_env *env,
+			     struct task_struct *p, long imp)
+{
+	if (env->best_task)
+		put_task_struct(env->best_task);
+	if (p)
+		get_task_struct(p);
+
+	env->best_task = p;
+	env->best_imp = imp;
+	env->best_cpu = env->dst_cpu;
+}
+
+/*
+ * This checks if the overall compute and NUMA accesses of the system would
+ * be improved if the source tasks was migrated to the target dst_cpu taking
+ * into account that it might be best if task running on the dst_cpu should
+ * be exchanged with the source task
+ */
+static void task_numa_compare(struct task_numa_env *env, long imp)
+{
+	struct rq *src_rq = cpu_rq(env->src_cpu);
+	struct rq *dst_rq = cpu_rq(env->dst_cpu);
+	struct task_struct *cur;
+	long dst_load, src_load;
+	long load;
+
+	rcu_read_lock();
+	cur = ACCESS_ONCE(dst_rq->curr);
+	if (cur->pid == 0) /* idle */
+		cur = NULL;
+
+	/*
+	 * "imp" is the fault differential for the source task between the
+	 * source and destination node. Calculate the total differential for
+	 * the source task and potential destination task. The more negative
+	 * the value is, the more rmeote accesses that would be expected to
+	 * be incurred if the tasks were swapped.
+	 */
+	if (cur) {
+		/* Skip this swap candidate if cannot move to the source cpu */
+		if (!cpumask_test_cpu(env->src_cpu, tsk_cpus_allowed(cur)))
+			goto unlock;
+
+		imp += task_faults(cur, env->src_nid) -
+		       task_faults(cur, env->dst_nid);
+	}
+
+	if (imp < env->best_imp)
+		goto unlock;
+
+	if (!cur) {
+		/* Is there capacity at our destination? */
+		if (env->src_stats.has_capacity &&
+		    !env->dst_stats.has_capacity)
+			goto unlock;
+
+		goto balance;
+	}
+
+	/* Balance doesn't matter much if we're running a task per cpu */
+	if (src_rq->nr_running == 1 && dst_rq->nr_running == 1)
+		goto assign;
+
+	/*
+	 * In the overloaded case, try and keep the load balanced.
+	 */
+balance:
+	dst_load = env->dst_stats.load;
+	src_load = env->src_stats.load;
+
+	/* XXX missing power terms */
+	load = task_h_load(env->p);
+	dst_load += load;
+	src_load -= load;
+
+	if (cur) {
+		load = task_h_load(cur);
+		dst_load -= load;
+		src_load += load;
+	}
+
+	/* make src_load the smaller */
+	if (dst_load < src_load)
+		swap(dst_load, src_load);
+
+	if (src_load * env->imbalance_pct < dst_load * 100)
+		goto unlock;
+
+assign:
+	task_numa_assign(env, cur, imp);
+unlock:
+	rcu_read_unlock();
+}
+
 static int task_numa_migrate(struct task_struct *p)
 {
-	int node_cpu = cpumask_first(cpumask_of_node(p->numa_preferred_nid));
+	const struct cpumask *cpumask = cpumask_of_node(p->numa_preferred_nid);
 	struct task_numa_env env = {
 		.p = p,
+
 		.src_cpu = task_cpu(p),
 		.src_nid = cpu_to_node(task_cpu(p)),
-		.dst_cpu = node_cpu,
-		.dst_nid = p->numa_preferred_nid,
-		.best_load = ULONG_MAX,
-		.best_cpu = task_cpu(p),
+
+		.imbalance_pct = 112,
+
+		.best_task = NULL,
+		.best_imp = 0,
+		.best_cpu = -1
 	};
-	struct sched_domain *sd;
-	int cpu;
-	struct task_group *tg = task_group(p);
-	unsigned long weight;
-	bool balanced;
-	int imbalance_pct, idx = -1;
+ 	struct sched_domain *sd;
+	unsigned long faults;
+	int nid, cpu, ret;
 
 	/*
 	 * Find the lowest common scheduling domain covering the nodes of both
@@ -949,66 +1077,52 @@ static int task_numa_migrate(struct task_struct *p)
 	 */
 	rcu_read_lock();
 	for_each_domain(env.src_cpu, sd) {
-		if (cpumask_test_cpu(node_cpu, sched_domain_span(sd))) {
-			/*
-			 * busy_idx is used for the load decision as it is the
-			 * same index used by the regular load balancer for an
-			 * active cpu.
-			 */
-			idx = sd->busy_idx;
-			imbalance_pct = sd->imbalance_pct;
+		if (cpumask_intersects(cpumask, sched_domain_span(sd))) {
+			env.imbalance_pct = 100 + (sd->imbalance_pct - 100) / 2;
 			break;
 		}
 	}
 	rcu_read_unlock();
 
-	if (WARN_ON_ONCE(idx == -1))
-		return 0;
+	faults = task_faults(p, env.src_nid);
+	update_numa_stats(&env.src_stats, env.src_nid);
 
-	/*
-	 * XXX the below is mostly nicked from wake_affine(); we should
-	 * see about sharing a bit if at all possible; also it might want
-	 * some per entity weight love.
-	 */
-	weight = p->se.load.weight;
-	env.src_stats.load = source_load(env.src_cpu, idx);
-	env.src_stats.eff_load = 100 + (imbalance_pct - 100) / 2;
-	env.src_stats.eff_load *= power_of(env.src_cpu);
-	env.src_stats.eff_load *= env.src_stats.load + effective_load(tg, env.src_cpu, -weight, -weight);
-
-	for_each_cpu(cpu, cpumask_of_node(env.dst_nid)) {
-		env.dst_cpu = cpu;
-		env.dst_stats.load = target_load(cpu, idx);
- 
- 		/* If the CPU is idle, use it */
-		if (!env.dst_stats.load) {
-			env.best_cpu = cpu;
-			goto migrate;
-		}
+	/* Find an alternative node with relatively better statistics */
+	for_each_online_node(nid) {
+		long imp;
 
-		/* Otherwise check the target CPU load */
-		env.dst_stats.eff_load = 100;
-		env.dst_stats.eff_load *= power_of(cpu);
-		env.dst_stats.eff_load *= env.dst_stats.load + effective_load(tg, cpu, weight, weight);
+		if (nid == env.src_nid)
+			continue;
 
-		/*
-		 * Destination is considered balanced if the destination CPU is
-		 * less loaded than the source CPU. Unfortunately there is a
-		 * risk that a task running on a lightly loaded CPU will not
-		 * migrate to its preferred node due to load imbalances.
-		 */
-		balanced = (env.dst_stats.eff_load <= env.src_stats.eff_load);
-		if (!balanced)
+		/* Only consider nodes that recorded more faults */
+		imp = task_faults(p, nid) - faults;
+		if (imp < 0)
 			continue;
 
-		if (env.dst_stats.eff_load < env.best_load) {
-			env.best_load = env.dst_stats.eff_load;
-			env.best_cpu = cpu;
+		env.dst_nid = nid;
+		update_numa_stats(&env.dst_stats, env.dst_nid);
+		for_each_cpu(cpu, cpumask_of_node(nid)) {
+			/* Skip this CPU if the source task cannot migrate */
+			if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+				continue;
+
+			env.dst_cpu = cpu;
+			task_numa_compare(&env, imp);
 		}
 	}
 
-migrate:
-	return migrate_task_to(p, env.best_cpu);
+	/* No better CPU than the current one was found. */
+	if (env.best_cpu == -1)
+		return -EAGAIN;
+
+	if (env.best_task == NULL) {
+		int ret = migrate_task_to(p, env.best_cpu);
+		return ret;
+	}
+
+	ret = migrate_swap(p, env.best_task);
+	put_task_struct(env.best_task);
+	return ret;
 }
 
 /* Attempt to migrate a task to a CPU on the preferred node. */
@@ -1046,7 +1160,7 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for_each_online_node(nid) {
-		unsigned long faults;
+		unsigned long faults = 0;
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
@@ -1056,10 +1170,10 @@ static void task_numa_placement(struct task_struct *p)
 			p->numa_faults[i] >>= 1;
 			p->numa_faults[i] += p->numa_faults_buffer[i];
 			p->numa_faults_buffer[i] = 0;
+
+			faults += p->numa_faults[i];
 		}
 
-		/* Find maximum private faults */
-		faults = p->numa_faults[task_faults_idx(nid, 1)];
 		if (faults > max_faults) {
 			max_faults = faults;
 			max_nid = nid;
@@ -4405,8 +4519,6 @@ static int move_one_task(struct lb_env *env)
 	return 0;
 }
 
-static unsigned long task_h_load(struct task_struct *p);
-
 static const unsigned int sched_nr_migrate_break = 32;
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
