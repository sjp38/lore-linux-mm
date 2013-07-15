Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 144466B0069
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:20:39 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/18] sched: Swap tasks when reschuling if a CPU on a target node is imbalanced
Date: Mon, 15 Jul 2013 16:20:20 +0100
Message-Id: <1373901620-2021-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The scheduler avoids adding load imbalance when scheduling a task on its
preferred node. This unfortunately can mean that a task continues access
remote memory. In the event the CPUs are relatively imbalanced this
patch will check if the task running on the target CPU can be swapped
with. An attempt will be made to swap with the task if it is not running
on its preferred node and that moving it would not impair its locality.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/core.c  | 39 +++++++++++++++++++++++++++++++++++++--
 kernel/sched/fair.c  | 46 +++++++++++++++++++++++++++++++++++++++++-----
 kernel/sched/sched.h |  3 ++-
 3 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 53d8465..d679b01 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4857,10 +4857,13 @@ fail:
 
 #ifdef CONFIG_NUMA_BALANCING
 /* Migrate current task p to target_cpu */
-int migrate_task_to(struct task_struct *p, int target_cpu)
+int migrate_task_to(struct task_struct *p, int target_cpu,
+		    struct task_struct *swap_p)
 {
 	struct migration_arg arg = { p, target_cpu };
 	int curr_cpu = task_cpu(p);
+	struct rq *rq;
+	int retval;
 
 	if (curr_cpu == target_cpu)
 		return 0;
@@ -4868,7 +4871,39 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
 	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
 		return -EINVAL;
 
-	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
+	if (swap_p == NULL)
+		return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
+
+	/* Make sure the target is still running the expected task */
+	rq = cpu_rq(target_cpu);
+	local_irq_disable();
+	raw_spin_lock(&rq->lock);
+	if (rq->curr != swap_p) {
+		raw_spin_unlock(&rq->lock);
+		local_irq_enable();
+		return -EINVAL;
+	}
+
+	/* Take a reference on the running task on the target cpu */
+	get_task_struct(swap_p);
+	raw_spin_unlock(&rq->lock);
+	local_irq_enable();
+
+	/* Move current running task to target CPU */
+	retval = stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
+	if (raw_smp_processor_id() != target_cpu) {
+		put_task_struct(swap_p);
+		return retval;
+	}
+
+	/* Move the remote task to the CPU just vacated */
+	local_irq_disable();
+	if (raw_smp_processor_id() == target_cpu)
+		__migrate_task(swap_p, target_cpu, curr_cpu);
+	local_irq_enable();
+
+	put_task_struct(swap_p);
+	return retval;
 }
 #endif
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 07a9f40..7a8f768 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -851,10 +851,12 @@ static unsigned long target_load(int cpu, int type);
 static unsigned long power_of(int cpu);
 static long effective_load(struct task_group *tg, int cpu, long wl, long wg);
 
-static int task_numa_find_cpu(struct task_struct *p, int nid)
+static int task_numa_find_cpu(struct task_struct *p, int nid,
+			      struct task_struct **swap_p)
 {
 	int node_cpu = cpumask_first(cpumask_of_node(nid));
 	int cpu, src_cpu = task_cpu(p), dst_cpu = src_cpu;
+	int src_cpu_node = cpu_to_node(src_cpu);
 	unsigned long src_load, dst_load;
 	unsigned long min_load = ULONG_MAX;
 	struct task_group *tg = task_group(p);
@@ -864,6 +866,8 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
 	bool balanced;
 	int imbalance_pct, idx = -1;
 
+	*swap_p = NULL;
+
 	/* No harm being optimistic */
 	if (idle_cpu(node_cpu))
 		return node_cpu;
@@ -904,6 +908,8 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
 	src_eff_load *= src_load + effective_load(tg, src_cpu, -weight, -weight);
 
 	for_each_cpu(cpu, cpumask_of_node(nid)) {
+		struct task_struct *swap_candidate = NULL;
+
 		dst_load = target_load(cpu, idx);
 
 		/* If the CPU is idle, use it */
@@ -922,12 +928,41 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
 		 * migrate to its preferred node due to load imbalances.
 		 */
 		balanced = (dst_eff_load <= src_eff_load);
-		if (!balanced)
-			continue;
+		if (!balanced) {
+			struct rq *rq = cpu_rq(cpu);
+			unsigned long src_faults, dst_faults;
+
+			/* Do not move tasks off their preferred node */
+			if (rq->curr->numa_preferred_nid == nid)
+				continue;
+
+			/* Do not attempt an illegal migration */
+			if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(rq->curr)))
+				continue;
+
+			/*
+			 * Do not impair locality for the swap candidate.
+			 * Destination for the swap candidate is the source cpu
+			 */
+			if (rq->curr->numa_faults) {
+				src_faults = rq->curr->numa_faults[task_faults_idx(nid, 1)];
+				dst_faults = rq->curr->numa_faults[task_faults_idx(src_cpu_node, 1)];
+				if (src_faults > dst_faults)
+					continue;
+			}
+
+			/*
+			 * The destination is overloaded but running a task
+			 * that is not running on its preferred node. Consider
+			 * swapping the CPU tasks are running on.
+			 */
+			swap_candidate = rq->curr;
+		}
 
 		if (dst_load < min_load) {
 			min_load = dst_load;
 			dst_cpu = cpu;
+			*swap_p = swap_candidate;
 		}
 	}
 
@@ -938,6 +973,7 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
 static void numa_migrate_preferred(struct task_struct *p)
 {
 	int preferred_cpu = task_cpu(p);
+	struct task_struct *swap_p;
 
 	/* Success if task is already running on preferred CPU */
 	p->numa_migrate_retry = 0;
@@ -945,8 +981,8 @@ static void numa_migrate_preferred(struct task_struct *p)
 		return;
 
 	/* Otherwise, try migrate to a CPU on the preferred node */
-	preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid);
-	if (migrate_task_to(p, preferred_cpu) != 0)
+	preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid, &swap_p);
+	if (migrate_task_to(p, preferred_cpu, swap_p) != 0)
 		p->numa_migrate_retry = jiffies + HZ*5;
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 795346d..90ded64 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -504,7 +504,8 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
 #ifdef CONFIG_NUMA_BALANCING
-extern int migrate_task_to(struct task_struct *p, int cpu);
+extern int migrate_task_to(struct task_struct *p, int cpu,
+			   struct task_struct *swap_p);
 static inline void task_numa_free(struct task_struct *p)
 {
 	kfree(p->numa_faults);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
