Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6C98C6B006C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:52 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277755eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:51 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 8/9] numa, sched: Improve directed convergence
Date: Fri,  7 Dec 2012 01:19:25 +0100
Message-Id: <1354839566-15697-9-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Improve a few aspects of directed convergence, which problems
have become more visible with the improved (and thus more
aggressive) task-flipping code.

We also have the new 'cpupid' sharing info which converges more
precisely and thus highlights weaknesses in group balancing more
visibly:

 - We should only balance over buddy groups that are smaller
   than the other (not fully filled) buddy groups

 - Do not 'spread' buddy groups that fully fill a node

 - Do not 'spread' singular buddy groups

These bugs were prominently visible with certain preemption
options and timings with the previous code as well, so this
is a regression fix as well.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 101 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 71 insertions(+), 30 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fd49920..c393fba 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -926,6 +926,7 @@ static long calc_node_load(int node, bool use_higher)
 	long cpu_load_highfreq;
 	long cpu_load_lowfreq;
 	long cpu_load_curr;
+	long cpu_load_numa;
 	long min_cpu_load;
 	long max_cpu_load;
 	long node_load;
@@ -935,18 +936,22 @@ static long calc_node_load(int node, bool use_higher)
 
 	for_each_cpu(cpu, cpumask_of_node(node)) {
 		struct rq *rq = cpu_rq(cpu);
+		long cpu_load;
 
+		cpu_load_numa		= rq->numa_weight;
 		cpu_load_curr		= rq->load.weight;
 		cpu_load_lowfreq	= rq->cpu_load[NUMA_LOAD_IDX_LOWFREQ];
 		cpu_load_highfreq	= rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
 
-		min_cpu_load = min(min(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
-		max_cpu_load = max(max(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+		min_cpu_load = min(min(min(cpu_load_numa, cpu_load_curr), cpu_load_lowfreq), cpu_load_highfreq);
+		max_cpu_load = max(max(max(cpu_load_numa, cpu_load_curr), cpu_load_lowfreq), cpu_load_highfreq);
 
 		if (use_higher)
-			node_load += max_cpu_load;
+			cpu_load = max_cpu_load;
 		else
-			node_load += min_cpu_load;
+			cpu_load = min_cpu_load;
+
+		node_load += cpu_load;
 	}
 
 	return node_load;
@@ -1087,6 +1092,7 @@ static int find_intranode_imbalance(int this_node, int this_cpu)
 	long cpu_load_lowfreq;
 	long this_cpu_load;
 	long cpu_load_curr;
+	long cpu_load_numa;
 	long min_cpu_load;
 	long cpu_load;
 	int min_cpu;
@@ -1102,14 +1108,15 @@ static int find_intranode_imbalance(int this_node, int this_cpu)
 	for_each_cpu(cpu, cpumask_of_node(this_node)) {
 		struct rq *rq = cpu_rq(cpu);
 
+		cpu_load_numa		= rq->numa_weight;
 		cpu_load_curr		= rq->load.weight;
 		cpu_load_lowfreq	= rq->cpu_load[NUMA_LOAD_IDX_LOWFREQ];
 		cpu_load_highfreq	= rq->cpu_load[NUMA_LOAD_IDX_HIGHFREQ];
 
-		if (cpu == this_cpu) {
-			this_cpu_load = min(min(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
-		}
-		cpu_load = max(max(cpu_load_curr, cpu_load_lowfreq), cpu_load_highfreq);
+		if (cpu == this_cpu)
+			this_cpu_load = min(min(min(cpu_load_numa, cpu_load_curr), cpu_load_lowfreq), cpu_load_highfreq);
+
+		cpu_load = max(max(max(cpu_load_numa, cpu_load_curr), cpu_load_lowfreq), cpu_load_highfreq);
 
 		/* Find the idlest CPU: */
 		if (cpu_load < min_cpu_load) {
@@ -1128,16 +1135,18 @@ static int find_intranode_imbalance(int this_node, int this_cpu)
 /*
  * Search a node for the smallest-group task and return
  * it plus the size of the group it is in.
+ *
+ * TODO: can be done with a single pass.
  */
-static int buddy_group_size(int node, struct task_struct *p)
+static int buddy_group_size(int node, struct task_struct *p, bool *our_group_p)
 {
 	const cpumask_t *node_cpus_mask = cpumask_of_node(node);
 	cpumask_t cpus_to_check_mask;
-	bool our_group_found;
+	bool buddies_group_found;
 	int cpu1, cpu2;
 
 	cpumask_copy(&cpus_to_check_mask, node_cpus_mask);
-	our_group_found = false;
+	buddies_group_found = false;
 
 	if (WARN_ON_ONCE(cpumask_empty(&cpus_to_check_mask)))
 		return 0;
@@ -1156,7 +1165,12 @@ static int buddy_group_size(int node, struct task_struct *p)
 
 			group_size = 1;
 			if (tasks_buddies(group_head, p))
-				our_group_found = true;
+				buddies_group_found = true;
+
+			if (group_head == p) {
+				*our_group_p = true;
+				buddies_group_found = true;
+			}
 
 			/* Non-NUMA-shared tasks are 1-task groups: */
 			if (task_numa_shared(group_head) != 1)
@@ -1169,21 +1183,22 @@ static int buddy_group_size(int node, struct task_struct *p)
 				struct task_struct *p2 = rq2->curr;
 
 				WARN_ON_ONCE(rq1 == rq2);
+				if (p2 == p)
+					*our_group_p = true;
 				if (tasks_buddies(group_head, p2)) {
 					/* 'group_head' and 'rq2->curr' are in the same group: */
 					cpumask_clear_cpu(cpu2, &cpus_to_check_mask);
 					group_size++;
 					if (tasks_buddies(p2, p))
-						our_group_found = true;
+						buddies_group_found = true;
 				}
 			}
 next:
-
 			/*
 			 * If we just found our group and checked all
 			 * node local CPUs then return the result:
 			 */
-			if (our_group_found)
+			if (buddies_group_found)
 				return group_size;
 		}
 	} while (!cpumask_empty(&cpus_to_check_mask));
@@ -1261,8 +1276,15 @@ pick_non_numa_task:
 	return min_group_cpu;
 }
 
-static int find_max_node(struct task_struct *p, int *our_group_size)
+/*
+ * Find the node with the biggest buddy group of ours, but exclude
+ * our own local group on this node and also exclude fully filled
+ * nodes:
+ */
+static int
+find_max_node(struct task_struct *p, int *our_group_size_p, int *max_group_size_p, int full_size)
 {
+	bool our_group = false;
 	int max_group_size;
 	int group_size;
 	int max_node;
@@ -1272,9 +1294,12 @@ static int find_max_node(struct task_struct *p, int *our_group_size)
 	max_node = -1;
 
 	for_each_node(node) {
-		int full_size = cpumask_weight(cpumask_of_node(node));
 
-		group_size = buddy_group_size(node, p);
+		group_size = buddy_group_size(node, p, &our_group);
+		if (our_group) {
+			our_group = false;
+			*our_group_size_p = group_size;
+		}
 		if (group_size == full_size)
 			continue;
 
@@ -1284,7 +1309,7 @@ static int find_max_node(struct task_struct *p, int *our_group_size)
 		}
 	}
 
-	*our_group_size = max_group_size;
+	*max_group_size_p = max_group_size;
 
 	return max_node;
 }
@@ -1460,19 +1485,23 @@ static int find_max_node(struct task_struct *p, int *our_group_size)
  */
 static int improve_group_balance_compress(struct task_struct *p, int this_cpu, int this_node)
 {
-	int our_group_size = -1;
+	int full_size = cpumask_weight(cpumask_of_node(this_node));
+	int max_group_size = -1;
 	int min_group_size = -1;
+	int our_group_size = -1;
 	int max_node;
 	int min_cpu;
 
 	if (!sched_feat(NUMA_GROUP_LB_COMPRESS))
 		return -1;
 
-	max_node = find_max_node(p, &our_group_size);
+	max_node = find_max_node(p, &our_group_size, &max_group_size, full_size);
 	if (max_node == -1)
 		return -1;
+	if (our_group_size == -1)
+		return -1;
 
-	if (WARN_ON_ONCE(our_group_size == -1))
+	if (our_group_size == full_size || our_group_size > max_group_size)
 		return -1;
 
 	/* We are already in the right spot: */
@@ -1517,6 +1546,7 @@ static int improve_group_balance_spread(struct task_struct *p, int this_cpu, int
 	long this_node_load = -1;
 	long delta_load_before;
 	long delta_load_after;
+	int group_count = 0;
 	int idlest_cpu = -1;
 	int cpu1, cpu2;
 
@@ -1585,6 +1615,7 @@ static int improve_group_balance_spread(struct task_struct *p, int this_cpu, int
 				min_group_size = group_size;
 			else
 				min_group_size = min(group_size, min_group_size);
+			group_count++;
 		}
 	} while (!cpumask_empty(&cpus_to_check_mask));
 
@@ -1594,13 +1625,23 @@ static int improve_group_balance_spread(struct task_struct *p, int this_cpu, int
 	 */
 	if (!found_our_group)
 		return -1;
+
 	if (!our_group_smallest)
 		return -1;
+
 	if (WARN_ON_ONCE(min_group_size == -1))
 		return -1;
 	if (WARN_ON_ONCE(our_group_size == -1))
 		return -1;
 
+	/* Since the current task is shared, this should not happen: */
+	if (WARN_ON_ONCE(group_count < 1))
+		return -1;
+
+	/* No point in moving if we are a single group: */
+	if (group_count <= 1)
+		return -1;
+
 	idlest_node = find_idlest_node(&idlest_cpu);
 	if (idlest_node == -1)
 		return -1;
@@ -1622,7 +1663,7 @@ static int improve_group_balance_spread(struct task_struct *p, int this_cpu, int
 	 */
 	delta_load_before = this_node_load - idlest_node_load;
 	delta_load_after = (this_node_load-this_group_load) - (idlest_node_load+this_group_load);
-	
+
 	if (abs(delta_load_after)+SCHED_LOAD_SCALE > abs(delta_load_before))
 		return -1;
 
@@ -1806,7 +1847,7 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p, int *flip_tasks)
 	this_node_capacity	= calc_node_capacity(this_node);
 
 	this_node_overloaded = false;
-	if (this_node_load > this_node_capacity + 512)
+	if (this_node_load > this_node_capacity + SCHED_LOAD_SCALE/2)
 		this_node_overloaded = true;
 
 	/* If we'd stay within this node then stay put: */
@@ -1922,7 +1963,7 @@ static int sched_update_ideal_cpu_private(struct task_struct *p)
 	this_node_capacity	= calc_node_capacity(this_node);
 
 	this_node_overloaded = false;
-	if (this_node_load > this_node_capacity + 512)
+	if (this_node_load > this_node_capacity + SCHED_LOAD_SCALE/2)
 		this_node_overloaded = true;
 
 	if (this_node == min_node)
@@ -1934,8 +1975,8 @@ static int sched_update_ideal_cpu_private(struct task_struct *p)
 
 	WARN_ON_ONCE(max_node_load < min_node_load);
 
-	/* Is the load difference at least 125% of one standard task load? */
-	if (this_node_load - min_node_load < 1536)
+	/* Is the load difference at least 150% of one standard task load? */
+	if (this_node_load - min_node_load < SCHED_LOAD_SCALE*3/2)
 		goto out_check_intranode;
 
 	/*
@@ -5476,7 +5517,7 @@ static bool yield_to_task_fair(struct rq *rq, struct task_struct *p, bool preemp
  *
  * The adjacency matrix of the resulting graph is given by:
  *
- *             log_2 n     
+ *             log_2 n
  *   A_i,j = \Union     (i % 2^k == 0) && i / 2^(k+1) == j / 2^(k+1)  (6)
  *             k = 0
  *
@@ -5522,7 +5563,7 @@ static bool yield_to_task_fair(struct rq *rq, struct task_struct *p, bool preemp
  *
  * [XXX write more on how we solve this.. _after_ merging pjt's patches that
  *      rewrite all of this once again.]
- */ 
+ */
 
 static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
@@ -6133,7 +6174,7 @@ void update_group_power(struct sched_domain *sd, int cpu)
 		/*
 		 * !SD_OVERLAP domains can assume that child groups
 		 * span the current group.
-		 */ 
+		 */
 
 		group = child->groups;
 		do {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
