Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBAE9C001D
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:21 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so7076972pab.26
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:21 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 32/63] sched: Avoid overloading CPUs on a preferred NUMA node
Date: Mon,  7 Oct 2013 11:29:10 +0100
Message-Id: <1381141781-10992-33-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch replaces find_idlest_cpu_node with task_numa_find_cpu.
find_idlest_cpu_node has two critical limitations. It does not take the
scheduling class into account when calculating the load and it is unsuitable
for using when comparing loads between NUMA nodes.

task_numa_find_cpu uses similar load calculations to wake_affine() when
selecting the least loaded CPU within a scheduling domain common to the
source and destimation nodes. It avoids causing CPU load imbalances in
the machine by refusing to migrate if the relative load on the target
CPU is higher than the source CPU.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 131 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 102 insertions(+), 29 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1789e3c..fd6e9e1 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -901,28 +901,114 @@ static inline unsigned long task_faults(struct task_struct *p, int nid)
 }
 
 static unsigned long weighted_cpuload(const int cpu);
+static unsigned long source_load(int cpu, int type);
+static unsigned long target_load(int cpu, int type);
+static unsigned long power_of(int cpu);
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
 
+struct numa_stats {
+	unsigned long load;
+	s64 eff_load;
+	unsigned long faults;
+};
 
-static int
-find_idlest_cpu_node(int this_cpu, int nid)
-{
-	unsigned long load, min_load = ULONG_MAX;
-	int i, idlest_cpu = this_cpu;
+struct task_numa_env {
+	struct task_struct *p;
 
-	BUG_ON(cpu_to_node(this_cpu) == nid);
+	int src_cpu, src_nid;
+	int dst_cpu, dst_nid;
 
-	rcu_read_lock();
-	for_each_cpu(i, cpumask_of_node(nid)) {
-		load = weighted_cpuload(i);
+	struct numa_stats src_stats, dst_stats;
 
-		if (load < min_load) {
-			min_load = load;
-			idlest_cpu = i;
+	unsigned long best_load;
+	int best_cpu;
+};
+
+static int task_numa_migrate(struct task_struct *p)
+{
+	int node_cpu = cpumask_first(cpumask_of_node(p->numa_preferred_nid));
+	struct task_numa_env env = {
+		.p = p,
+		.src_cpu = task_cpu(p),
+		.src_nid = cpu_to_node(task_cpu(p)),
+		.dst_cpu = node_cpu,
+		.dst_nid = p->numa_preferred_nid,
+		.best_load = ULONG_MAX,
+		.best_cpu = task_cpu(p),
+	};
+	struct sched_domain *sd;
+	int cpu;
+	struct task_group *tg = task_group(p);
+	unsigned long weight;
+	bool balanced;
+	int imbalance_pct, idx = -1;
+
+	/*
+	 * Find the lowest common scheduling domain covering the nodes of both
+	 * the CPU the task is currently running on and the target NUMA node.
+	 */
+	rcu_read_lock();
+	for_each_domain(env.src_cpu, sd) {
+		if (cpumask_test_cpu(node_cpu, sched_domain_span(sd))) {
+			/*
+			 * busy_idx is used for the load decision as it is the
+			 * same index used by the regular load balancer for an
+			 * active cpu.
+			 */
+			idx = sd->busy_idx;
+			imbalance_pct = sd->imbalance_pct;
+			break;
 		}
 	}
 	rcu_read_unlock();
 
-	return idlest_cpu;
+	if (WARN_ON_ONCE(idx == -1))
+		return 0;
+
+	/*
+	 * XXX the below is mostly nicked from wake_affine(); we should
+	 * see about sharing a bit if at all possible; also it might want
+	 * some per entity weight love.
+	 */
+	weight = p->se.load.weight;
+	env.src_stats.load = source_load(env.src_cpu, idx);
+	env.src_stats.eff_load = 100 + (imbalance_pct - 100) / 2;
+	env.src_stats.eff_load *= power_of(env.src_cpu);
+	env.src_stats.eff_load *= env.src_stats.load + effective_load(tg, env.src_cpu, -weight, -weight);
+
+	for_each_cpu(cpu, cpumask_of_node(env.dst_nid)) {
+		env.dst_cpu = cpu;
+		env.dst_stats.load = target_load(cpu, idx);
+
+		/* If the CPU is idle, use it */
+		if (!env.dst_stats.load) {
+			env.best_cpu = cpu;
+			goto migrate;
+		}
+
+		/* Otherwise check the target CPU load */
+		env.dst_stats.eff_load = 100;
+		env.dst_stats.eff_load *= power_of(cpu);
+		env.dst_stats.eff_load *= env.dst_stats.load + effective_load(tg, cpu, weight, weight);
+
+		/*
+		 * Destination is considered balanced if the destination CPU is
+		 * less loaded than the source CPU. Unfortunately there is a
+		 * risk that a task running on a lightly loaded CPU will not
+		 * migrate to its preferred node due to load imbalances.
+		 */
+		balanced = (env.dst_stats.eff_load <= env.src_stats.eff_load);
+		if (!balanced)
+			continue;
+
+		if (env.dst_stats.eff_load < env.best_load) {
+			env.best_load = env.dst_stats.eff_load;
+			env.best_cpu = cpu;
+		}
+	}
+
+migrate:
+	return migrate_task_to(p, env.best_cpu);
 }
 
 static void task_numa_placement(struct task_struct *p)
@@ -966,22 +1052,10 @@ static void task_numa_placement(struct task_struct *p)
 	 * the working set placement.
 	 */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
-		int preferred_cpu;
-
-		/*
-		 * If the task is not on the preferred node then find the most
-		 * idle CPU to migrate to.
-		 */
-		preferred_cpu = task_cpu(p);
-		if (cpu_to_node(preferred_cpu) != max_nid) {
-			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
-							     max_nid);
-		}
-
 		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
 		p->numa_migrate_seq = 1;
-		migrate_task_to(p, preferred_cpu);
+		task_numa_migrate(p);
 	}
 }
 
@@ -3292,7 +3366,7 @@ static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 {
 	struct sched_entity *se = tg->se[cpu];
 
-	if (!tg->parent)	/* the trivial, non-cgroup case */
+	if (!tg->parent || !wl)	/* the trivial, non-cgroup case */
 		return wl;
 
 	for_each_sched_entity(se) {
@@ -3345,8 +3419,7 @@ static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 }
 #else
 
-static inline unsigned long effective_load(struct task_group *tg, int cpu,
-		unsigned long wl, unsigned long wg)
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 {
 	return wl;
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
