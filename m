Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 081836B0062
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:47:16 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/16] sched: Select least loaded CPU on preferred NUMA node
Date: Thu, 11 Jul 2013 10:47:00 +0100
Message-Id: <1373536020-2799-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1373536020-2799-1-git-send-email-mgorman@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch replaces find_idlest_cpu_node with task_numa_find_cpu.
find_idlest_cpu_node has two critical limitations. It does not take the
scheduling class into account when calculating the load and it is unsuitable
for using when comparing loads between NUMA nodes.

task_numa_find_cpu uses similar load calculations to wake_affine() when
selecting the least loaded CPU within a scheduling domain common to the
source and destimation nodes. It is not implemented in this patch but
potentially the information can be used to avoid overloading the destination
node relative to the source node.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 96 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 73 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2ab8fa0..aadff22 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -841,29 +841,81 @@ static unsigned int task_scan_max(struct task_struct *p)
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
-static unsigned long weighted_cpuload(const int cpu);
-
-
-static int
-find_idlest_cpu_node(int this_cpu, int nid)
-{
-	unsigned long load, min_load = ULONG_MAX;
-	int i, idlest_cpu = this_cpu;
+static unsigned long source_load(int cpu, int type);
+static unsigned long target_load(int cpu, int type);
+static unsigned long power_of(int cpu);
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
+
+static int task_numa_find_cpu(struct task_struct *p, int nid)
+{
+	int node_cpu = cpumask_first(cpumask_of_node(nid));
+	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
+	unsigned long src_load, dst_load;
+	unsigned long min_load = ULONG_MAX;
+	struct task_group *tg = task_group(p);
+	s64 src_eff_load, dst_eff_load;
+	struct sched_domain *sd;
+	unsigned long weight;
+	int imbalance_pct, idx = -1;
 
-	BUG_ON(cpu_to_node(this_cpu) == nid);
+	/* No harm being optimistic */
+	if (idle_cpu(node_cpu))
+		return node_cpu;
 
+	/*
+	 * Find the lowest common scheduling domain covering the nodes of both
+	 * the CPU the task is currently running on and the target NUMA node.
+	 */
 	rcu_read_lock();
-	for_each_cpu(i, cpumask_of_node(nid)) {
-		load = weighted_cpuload(i);
-
-		if (load < min_load) {
-			min_load = load;
-			idlest_cpu = i;
+	for_each_domain(src_cpu, sd) {
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
+		return src_cpu;
+
+	/*
+	 * XXX the below is mostly nicked from wake_affine(); we should
+	 * see about sharing a bit if at all possible; also it might want
+	 * some per entity weight love.
+	 */
+	weight = p->se.load.weight;
+ 
+	src_load = source_load(src_cpu, idx);
+
+	src_eff_load = 100 + (imbalance_pct - 100) / 2;
+	src_eff_load *= power_of(src_cpu);
+	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
+
+	for_each_cpu(cpu, cpumask_of_node(nid)) {
+		dst_load = target_load(cpu, idx);
+
+		/* If the CPU is idle, use it */
+		if (!dst_load)
+			return dst_cpu;
+
+		/* Otherwise check the target CPU load */
+		dst_eff_load = 100;
+		dst_eff_load *= power_of(cpu);
+		dst_eff_load *= dst_load + effective_load(tg, cpu, weight, weight);
+
+		if (dst_load < min_load) {
+			min_load = dst_load;
+			dst_cpu = cpu;
+		}
+ 	}
+
+	return dst_cpu;
 }
 
 static inline int task_faults_idx(int nid, int priv)
@@ -916,14 +968,12 @@ static void task_numa_placement(struct task_struct *p)
 		int old_migrate_seq = p->numa_migrate_seq;
 
 		/*
-		 * If the task is not on the preferred node then find the most
-		 * idle CPU to migrate to.
+		 * If the task is not on the preferred node then find 
+		 * a suitable CPU to migrate to.
 		 */
 		preferred_cpu = task_cpu(p);
-		if (cpu_to_node(preferred_cpu) != max_nid) {
-			preferred_cpu = find_idlest_cpu_node(preferred_cpu,
-							     max_nid);
-		}
+		if (cpu_to_node(preferred_cpu) != max_nid)
+			preferred_cpu = task_numa_find_cpu(p, max_nid);
 
 		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
@@ -3238,7 +3288,7 @@ static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 }
 #else
 
-static inline unsigned long effective_load(struct task_group *tg, int cpu,
+static unsigned long effective_load(struct task_group *tg, int cpu,
 		unsigned long wl, unsigned long wg)
 {
 	return wl;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
