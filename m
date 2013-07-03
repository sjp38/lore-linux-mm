Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id F26A96B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 05:51:05 -0400 (EDT)
Date: Wed, 3 Jul 2013 11:50:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/8] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130703095059.GH23916@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-7-git-send-email-mgorman@suse.de>
 <20130702181522.GC23916@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130702181522.GC23916@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 02, 2013 at 08:15:22PM +0200, Peter Zijlstra wrote:
> 
> 
> Something like this should avoid tasks being lumped back onto one node..
> 
> Compile tested only, need food.

OK, this one actually ran on my system and showed no negative effects on
numa02 -- then again, I didn't have the problem to begin with :/

Srikar, could you see what your 8-node does with this?

I'll go dig around to see where I left my SpecJBB.

---
Subject: sched, numa: Rework direct migration code to take load levels into account

Srikar mentioned he saw the direct migration code bounce all tasks
back to the first node only to be spread out by the regular balancer.

Rewrite the direct migration code to take load balance into account
such that we will not migrate to a cpu if the result is in direct
conflict with the load balance goals.

I removed the clause where we would not migrate towards a cpu that is
already running a task on the right node. If balance allows its
perfectly fine to run two tasks per cpu -- think overloaded scenarios.

There's a few XXXs in there that want consideration, but the code
compiles and runs.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/sched/core.c  |   41 +++++++-----------
 kernel/sched/fair.c  |  115 ++++++++++++++++++++++++++++++++++-----------------
 kernel/sched/sched.h |    2 
 3 files changed, 95 insertions(+), 63 deletions(-)

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1037,6 +1037,23 @@ struct migration_arg {
 
 static int migration_cpu_stop(void *data);
 
+#ifdef CONFIG_NUMA_BALANCING
+int migrate_curr_to(int cpu)
+{
+	struct task_struct *p = current;
+	struct migration_arg arg = { p, cpu };
+	int curr_cpu = task_cpu(p);
+
+	if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		return -EINVAL;
+
+	if (curr_cpu == cpu)
+		return 0;
+
+	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
+}
+#endif
+
 /*
  * wait_task_inactive - wait for a thread to unschedule.
  *
@@ -5188,30 +5205,6 @@ enum s_alloc {
 
 struct sched_domain_topology_level;
 
-#ifdef CONFIG_NUMA_BALANCING
-
-/* Set a tasks preferred NUMA node and reschedule to it */
-void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu)
-{
-	int curr_cpu = task_cpu(p);
-	struct migration_arg arg = { p, idlest_cpu };
-
-	p->numa_preferred_nid = nid;
-	p->numa_migrate_seq = 0;
-
-	/* Do not reschedule if already running on the target CPU */
-	if (idlest_cpu == curr_cpu)
-		return;
-
-	/* Ensure the target CPU is eligible */
-	if (!cpumask_test_cpu(idlest_cpu, tsk_cpus_allowed(p)))
-		return;
-
-	/* Move current running task to idlest CPU on preferred node */
-	stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 typedef struct sched_domain *(*sched_domain_init_f)(struct sched_domain_topology_level *tl, int cpu);
 typedef const struct cpumask *(*sched_domain_mask_f)(int cpu);
 
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -838,34 +838,71 @@ unsigned int sysctl_numa_balancing_scan_
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
-static unsigned long weighted_cpuload(const int cpu);
 
-static int find_idlest_cpu_node(int this_cpu, int nid)
-{
-	unsigned long load, min_load = ULONG_MAX;
-	int i, idlest_cpu = this_cpu;
+static unsigned long source_load(int cpu, int type);
+static unsigned long target_load(int cpu, int type);
+static unsigned long power_of(int cpu);
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
+
+static int task_numa_find_cpu(struct task_struct *p)
+{
+	int nid = p->numa_preferred_nid;
+	int node_cpu = cpumask_first(cpumask_of_node(nid));
+	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
+	unsigned long src_load, dst_load, min_load = ULONG_MAX;
+	struct task_group *tg = task_group(p);
+	s64 src_eff_load, dst_eff_load;
+	struct sched_domain *sd;
+	unsigned long weight;
+	bool balanced;
+	int idx = 0, imbalance_pct = 125;
 
-	BUG_ON(cpu_to_node(this_cpu) == nid);
+	rcu_read_lock();
+	for_each_domain(src_cpu, sd) {
+		if (cpumask_test_cpu(node_cpu, sched_domain_span(sd))) {
+			idx = sd->busy_idx; /* XXX another idx? */
+			imbalance_pct = sd->imbalance_pct;
+			break;
+		}
+	}
+	rcu_read_unlock();
 
-	for_each_cpu(i, cpumask_of_node(nid)) {
-		load = weighted_cpuload(i);
+	/*
+	 * XXX the below is mostly nicked from wake_affine(); we should
+	 * see about sharing a bit if at all possible; also it might want
+	 * some per entity weight love.
+	 */
 
-		if (load < min_load) {
-			struct task_struct *p;
-			struct rq *rq = cpu_rq(i);
+	weight = p->se.load.weight;
 
-			/* Do not preempt a task running on its preferred node */
-			raw_spin_lock_irq(&rq->lock);
-			p = rq->curr;
-			if (p->numa_preferred_nid != nid) {
-				min_load = load;
-				idlest_cpu = i;
-			}
-			raw_spin_unlock_irq(&rq->lock);
+	src_load = source_load(src_cpu, idx);
+
+	src_eff_load = 100 + (imbalance_pct - 100) / 2;
+	src_eff_load *= power_of(src_cpu);
+	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
+
+	for_each_cpu(cpu, cpumask_of_node(nid)) {
+		dst_load = target_load(cpu, idx);
+
+		dst_eff_load = 100;
+		dst_eff_load *= power_of(cpu);
+		dst_eff_load *= dst_load + effective_load(tg, cpu, weight, weight);
+
+		balanced = (dst_eff_load <= src_eff_load);
+
+		/*
+		 * If the dst cpu wasn't idle; don't allow imbalances
+		 */
+		if (dst_load && !balanced)
+			continue;
+
+		if (dst_load < min_load) {
+			min_load = dst_load;
+			dst_cpu = cpu;
 		}
 	}
 
-	return idlest_cpu;
+	return dst_cpu;
 }
 
 static inline int task_faults_idx(int nid, int priv)
@@ -915,29 +952,31 @@ static void task_numa_placement(struct t
 	 * the working set placement.
 	 */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
-		int preferred_cpu;
 		int old_migrate_seq = p->numa_migrate_seq;
 
-		/*
-		 * If the task is not on the preferred node then find the most
-		 * idle CPU to migrate to.
-		 */
-		preferred_cpu = task_cpu(p);
-		if (cpu_to_node(preferred_cpu) != max_nid)
-			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
-							     max_nid);
-
-		sched_setnuma(p, max_nid, preferred_cpu);
+		p->numa_preferred_nid = max_nid;
+		p->numa_migrate_seq = 0;
 
 		/*
 		 * If preferred nodes changes frequently then the scan rate
 		 * will be continually high. Mitigate this by increaseing the
 		 * scan rate only if the task was settled.
 		 */
-		if (old_migrate_seq >= sysctl_numa_balancing_settle_count)
-			p->numa_scan_period = max(p->numa_scan_period >> 1,
-					sysctl_numa_balancing_scan_period_min);
+		if (old_migrate_seq >= sysctl_numa_balancing_settle_count) {
+			p->numa_scan_period =
+				max(p->numa_scan_period >> 1,
+				    sysctl_numa_balancing_scan_period_min);
+		}
 	}
+
+	if (p->numa_preferred_nid == numa_node_id())
+		return;
+
+	/*
+	 * If the task is not on the preferred node then find the most
+	 * idle CPU to migrate to.
+	 */
+	migrate_curr_to(task_numa_find_cpu(p));
 }
 
 /*
@@ -956,7 +995,7 @@ void task_numa_fault(int last_nid, int n
 		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
-		p->numa_faults = kzalloc(size * 4, GFP_KERNEL);
+		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
 		if (!p->numa_faults)
 			return;
 
@@ -968,9 +1007,10 @@ void task_numa_fault(int last_nid, int n
 	 * If pages are properly placed (did not migrate) then scan slower.
 	 * This is reset periodically in case of phase changes
 	 */
-        if (!migrated)
+        if (!migrated) {
 		p->numa_scan_period = min(sysctl_numa_balancing_scan_period_max,
 			p->numa_scan_period + jiffies_to_msecs(10));
+	}
 
 	task_numa_placement(p);
 
@@ -3263,8 +3303,7 @@ static long effective_load(struct task_g
 }
 #else
 
-static inline unsigned long effective_load(struct task_group *tg, int cpu,
-		unsigned long wl, unsigned long wg)
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 {
 	return wl;
 }
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -555,7 +555,7 @@ static inline u64 rq_clock_task(struct r
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void sched_setnuma(struct task_struct *p, int nid, int idlest_cpu);
+extern int migrate_curr_to(int cpu);
 static inline void task_numa_free(struct task_struct *p)
 {
 	kfree(p->numa_faults);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
