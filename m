Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 543546B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 06:37:22 -0400 (EDT)
Date: Thu, 1 Aug 2013 12:37:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH,RFC] numa,sched: use group fault statistics in numa
 placement
Message-ID: <20130801103713.GO3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130801022319.4a6a977a@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801022319.4a6a977a@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 01, 2013 at 02:23:19AM -0400, Rik van Riel wrote:
> Subject: [PATCH,RFC] numa,sched: use group fault statistics in numa placement
> 
> Here is a quick strawman on how the group fault stuff could be used
> to help pick the best node for a task. This is likely to be quite
> suboptimal and in need of tweaking. My main goal is to get this to
> Peter & Mel before it's breakfast time on their side of the Atlantic...
> 
> This goes on top of "sched, numa: Use {cpu, pid} to create task groups for shared faults"
> 
> Enjoy :)
> 
> +	/*
> +	 * Should we stay on our own, or move in with the group?
> +	 * The absolute count of faults may not be useful, but comparing
> +	 * the fraction of accesses in each top node may give us a hint
> +	 * where to start looking for a migration target.
> +	 *
> +	 *  max_group_faults     max_faults
> +	 * ------------------ > ------------
> +	 * total_group_faults   total_faults
> +	 */
> +	if (max_group_nid >= 0 && max_group_nid != max_nid) {
> +		if (max_group_faults * total_faults >
> +				max_faults * total_group_faults)
> +			max_nid = max_group_nid;
> +	}

This makes sense.. another part of the problem, which you might already
have spotted is selecting a task to swap with. 

If you only look at per task faults its often impossible to find a
suitable swap task because moving you to a more suitable node would
degrade the other task -- below a patch you've already seen but I
haven't yet posted because I'm not at all sure its something 'sane' :-)

With group information your case might be stronger because you already
have many tasks on that node.

Still there's the tie where there's two groups with each exactly half
their tasks crossed between two nodes. I suppose we should forcefully
tie break in this case.

And all this while also maintaining the invariants placed by the regular
balancer. It would be no good to move tasks about if the balancer would
then have to shuffle stuff right back (or worse) in order to maintain
fairness.

---
Subject: sched, numa: Alternative migration scheme
From: Peter Zijlstra <peterz@infradead.org>
Date: Sun Jul 21 23:12:13 CEST 2013


Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/sched/fair.c |  260 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 187 insertions(+), 73 deletions(-)

--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -816,6 +816,8 @@ update_stats_curr_start(struct cfs_rq *c
  * Scheduling class queueing methods:
  */
 
+static unsigned long task_h_load(struct task_struct *p);
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * Approximate time to scan a full NUMA task in ms. The task scan period is
@@ -885,92 +887,206 @@ static inline int task_faults_idx(int ni
 	return 2 * nid + priv;
 }
 
+static inline unsigned long task_faults(struct task_struct *p, int nid)
+{
+	if (!p->numa_faults)
+		return 0;
+
+	return p->numa_faults[2*nid] + p->numa_faults[2*nid+1];
+}
+
+static unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
 static unsigned long power_of(int cpu);
 static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
 
-static int task_numa_find_cpu(struct task_struct *p, int nid)
+struct numa_stats {
+	unsigned long nr_running;
+	unsigned long load;
+	unsigned long power;
+	unsigned long capacity;
+	int has_capacity;
+};
+
+/*
+ * XXX borrowed from update_sg_lb_stats
+ */
+static void update_numa_stats(struct numa_stats *ns, int nid)
 {
-	int node_cpu = cpumask_first(cpumask_of_node(nid));
-	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
-	unsigned long src_load, dst_load;
-	unsigned long min_load = ULONG_MAX;
-	struct task_group *tg = task_group(p);
-	s64 src_eff_load, dst_eff_load;
-	struct sched_domain *sd;
-	unsigned long weight;
-	bool balanced;
-	int imbalance_pct, idx = -1;
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
+struct task_numa_env {
+	struct task_struct *p;
+
+	int src_cpu, src_nid;
+	int dst_cpu, dst_nid;
+
+	struct numa_stats src_stats, dst_stats;
+
+	int imbalance_pct, idx;
+
+	struct task_struct *best_task;
+	long best_imp;
+	int best_cpu;
+};
+
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
+static void task_numa_compare(struct task_numa_env *env, long imp)
+{
+	struct rq *src_rq = cpu_rq(env->src_cpu);
+	struct rq *dst_rq = cpu_rq(env->dst_cpu);
+	struct task_struct *cur;
+	unsigned long dst_load, src_load;
+	unsigned long load;
+
+	rcu_read_lock();
+	cur = ACCESS_ONCE(dst_rq->curr);
+	if (cur->pid == 0) /* idle */
+		cur = NULL;
+
+	if (cur) {
+		imp += task_faults(cur, env->src_nid) -
+		       task_faults(cur, env->dst_nid);
+	}
+
+	if (imp < env->best_imp)
+		goto unlock;
+
+	if (!cur) {
+		/* If there's room for an extra task; go ahead */
+		if (env->dst_stats.has_capacity)
+			goto assign;
+
+		/* If we're both over-capacity; balance */
+		if (!env->src_stats.has_capacity)
+			goto balance;
+
+		goto unlock;
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
 
-	/* No harm being optimistic */
-	if (idle_cpu(node_cpu))
-		return node_cpu;
+	if (src_load * env->imbalance_pct < dst_load * 100)
+		goto unlock;
+
+assign:
+	task_numa_assign(env, cur, imp);
+unlock:
+	rcu_read_unlock();
+}
+
+static int task_numa_migrate(struct task_struct *p)
+{
+	struct task_numa_env env = {
+		.p = p,
+
+		.src_cpu = task_cpu(p),
+		.src_nid = cpu_to_node(task_cpu(p)),
+
+		.imbalance_pct = 112,
+
+		.best_task = NULL,
+		.best_imp = 0,
+		.best_cpu = -1
+	};
+	struct sched_domain *sd;
+	unsigned long faults;
+	int nid, cpu, ret;
 
 	/*
 	 * Find the lowest common scheduling domain covering the nodes of both
 	 * the CPU the task is currently running on and the target NUMA node.
 	 */
 	rcu_read_lock();
-	for_each_domain(src_cpu, sd) {
-		if (cpumask_test_cpu(node_cpu, sched_domain_span(sd))) {
-			/*
-			 * busy_idx is used for the load decision as it is the
-			 * same index used by the regular load balancer for an
-			 * active cpu.
-			 */
-			idx = sd->busy_idx;
-			imbalance_pct = sd->imbalance_pct;
+	for_each_domain(env.src_cpu, sd) {
+		if (cpumask_intersects(cpumask_of_node(env.src_nid), sched_domain_span(sd))) {
+			env.imbalance_pct = 100 + (sd->imbalance_pct - 100) / 2;
 			break;
 		}
 	}
 	rcu_read_unlock();
 
-	if (WARN_ON_ONCE(idx == -1))
-		return src_cpu;
+	faults = task_faults(p, env.src_nid);
+	update_numa_stats(&env.src_stats, env.src_nid);
 
-	/*
-	 * XXX the below is mostly nicked from wake_affine(); we should
-	 * see about sharing a bit if at all possible; also it might want
-	 * some per entity weight love.
-	 */
-	weight = p->se.load.weight;
+	for_each_online_node(nid) {
+		long imp;
 
-	src_load = source_load(src_cpu, idx);
-
-	src_eff_load = 100 + (imbalance_pct - 100) / 2;
-	src_eff_load *= power_of(src_cpu);
-	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
-
-	for_each_cpu(cpu, cpumask_of_node(nid)) {
-		dst_load = target_load(cpu, idx);
-
-		/* If the CPU is idle, use it */
-		if (!dst_load)
-			return cpu;
-
-		/* Otherwise check the target CPU load */
-		dst_eff_load = 100;
-		dst_eff_load *= power_of(cpu);
-		dst_eff_load *= dst_load + effective_load(tg, cpu, weight, weight);
+		if (nid == env.src_nid)
+			continue;
 
-		/*
-		 * Destination is considered balanced if the destination CPU is
-		 * less loaded than the source CPU. Unfortunately there is a
-		 * risk that a task running on a lightly loaded CPU will not
-		 * migrate to its preferred node due to load imbalances.
-		 */
-		balanced = (dst_eff_load <= src_eff_load);
-		if (!balanced)
+		imp = task_faults(p, nid) - faults;
+		if (imp < 0)
 			continue;
 
-		if (dst_load < min_load) {
-			min_load = dst_load;
-			dst_cpu = cpu;
+		env.dst_nid = nid;
+		update_numa_stats(&env.dst_stats, env.dst_nid);
+		for_each_cpu(cpu, cpumask_of_node(nid)) {
+			env.dst_cpu = cpu;
+			task_numa_compare(&env, imp);
 		}
 	}
 
-	return dst_cpu;
+	if (env.best_cpu == -1)
+		return -EAGAIN;
+
+	if (env.best_task == NULL)
+		return migrate_task_to(p, env.best_cpu);
+
+	ret = migrate_swap(p, env.best_task);
+	put_task_struct(env.best_task);
+	return ret;
 }
 
 /* Attempt to migrate a task to a CPU on the preferred node. */
@@ -983,10 +1099,13 @@ static void numa_migrate_preferred(struc
 	if (cpu_to_node(preferred_cpu) == p->numa_preferred_nid)
 		return;
 
-	/* Otherwise, try migrate to a CPU on the preferred node */
-	preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid);
-	if (migrate_task_to(p, preferred_cpu) != 0)
-		p->numa_migrate_retry = jiffies + HZ*5;
+	if (!sched_feat(NUMA_BALANCE))
+		return;
+
+	task_numa_migrate(p);
+
+	/* Try again until we hit the preferred node */
+	p->numa_migrate_retry = jiffies + HZ/10;
 }
 
 static void task_numa_placement(struct task_struct *p)
@@ -1003,7 +1122,7 @@ static void task_numa_placement(struct t
 
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
-		unsigned long faults;
+		unsigned long faults = 0;
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
@@ -1013,19 +1132,16 @@ static void task_numa_placement(struct t
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
 		}
 	}
 
-	if (!sched_feat(NUMA_BALANCE))
-		return;
-
 	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 		int old_migrate_seq = p->numa_migrate_seq;
@@ -3342,7 +3458,7 @@ static long effective_load(struct task_g
 {
 	struct sched_entity *se = tg->se[cpu];
 
-	if (!tg->parent)	/* the trivial, non-cgroup case */
+	if (!tg->parent || !wl)	/* the trivial / non-cgroup case */
 		return wl;
 
 	for_each_sched_entity(se) {
@@ -4347,8 +4463,6 @@ static int move_one_task(struct lb_env *
 	return 0;
 }
 
-static unsigned long task_h_load(struct task_struct *p);
-
 static const unsigned int sched_nr_migrate_break = 32;
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
