Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 78C278D0016
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:52 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:51 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 31/33] sched: Use the ideal CPU to drive active balancing
Date: Thu, 22 Nov 2012 23:49:52 +0100
Message-Id: <1353624594-1118-32-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Use our shared/private distinction to allow the separate
handling of 'private' versus 'shared' workloads, which enables
the active-balancing of them:

 - private tasks, via the sched_update_ideal_cpu_private() function,
   try to 'spread' the system as evenly as possible.

 - shared-access tasks that also share their mm (threads), via the
   sched_update_ideal_cpu_shared() function, try to 'compress'
   with other shared tasks on as few nodes as possible.

   [ We'll be able to extend this grouping beyond threads in the
     future, by using the existing p->shared_buddy directed graph. ]

Introduce the sched_rebalance_to() primitive to trigger active rebalancing.

The result of this patch is 2-3 times faster convergence and
much more stable convergence points.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h   |   1 +
 kernel/sched/core.c     |  19 ++++
 kernel/sched/fair.c     | 244 +++++++++++++++++++++++++++++++++++++++++++++---
 kernel/sched/features.h |   7 +-
 kernel/sched/sched.h    |   1 +
 5 files changed, 257 insertions(+), 15 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 696492e..8bc3a03 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2020,6 +2020,7 @@ task_sched_runtime(struct task_struct *task);
 /* sched_exec is called by processes performing an exec */
 #ifdef CONFIG_SMP
 extern void sched_exec(void);
+extern void sched_rebalance_to(int dest_cpu);
 #else
 #define sched_exec()   {}
 #endif
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 794efa0..93f2561 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2596,6 +2596,22 @@ unlock:
 	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
 }
 
+/*
+ * sched_rebalance_to()
+ *
+ * Active load-balance to a target CPU.
+ */
+void sched_rebalance_to(int dest_cpu)
+{
+	struct task_struct *p = current;
+	struct migration_arg arg = { p, dest_cpu };
+
+	if (!cpumask_test_cpu(dest_cpu, tsk_cpus_allowed(p)))
+		return;
+
+	stop_one_cpu(raw_smp_processor_id(), migration_cpu_stop, &arg);
+}
+
 #endif
 
 DEFINE_PER_CPU(struct kernel_stat, kstat);
@@ -4753,6 +4769,9 @@ static int __migrate_task(struct task_struct *p, int src_cpu, int dest_cpu)
 done:
 	ret = 1;
 fail:
+#ifdef CONFIG_NUMA_BALANCING
+	rq_dest->curr_buddy = NULL;
+#endif
 	double_rq_unlock(rq_src, rq_dest);
 	raw_spin_unlock(&p->pi_lock);
 	return ret;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index a5f3ad7..8aa4b36 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -848,6 +848,181 @@ static int task_ideal_cpu(struct task_struct *p)
 	return p->ideal_cpu;
 }
 
+
+static int sched_update_ideal_cpu_shared(struct task_struct *p)
+{
+	int full_buddies;
+	int max_buddies;
+	int target_cpu;
+	int ideal_cpu;
+	int this_cpu;
+	int this_node;
+	int best_node;
+	int buddies;
+	int node;
+	int cpu;
+
+	if (!sched_feat(PUSH_SHARED_BUDDIES))
+		return -1;
+
+	ideal_cpu = -1;
+	best_node = -1;
+	max_buddies = 0;
+	this_cpu = task_cpu(p);
+	this_node = cpu_to_node(this_cpu);
+
+	for_each_online_node(node) {
+		full_buddies = cpumask_weight(cpumask_of_node(node));
+
+		buddies = 0;
+		target_cpu = -1;
+
+		for_each_cpu(cpu, cpumask_of_node(node)) {
+			struct task_struct *curr;
+			struct rq *rq;
+
+			WARN_ON_ONCE(cpu_to_node(cpu) != node);
+
+			rq = cpu_rq(cpu);
+
+			/*
+			 * Don't take the rq lock for scalability,
+			 * we only rely on rq->curr statistically:
+			 */
+			curr = ACCESS_ONCE(rq->curr);
+
+			if (curr == p) {
+				buddies += 1;
+				continue;
+			}
+
+			/* Pick up idle tasks immediately: */
+			if (curr == rq->idle && !rq->curr_buddy)
+				target_cpu = cpu;
+
+			/* Leave alone non-NUMA tasks: */
+			if (task_numa_shared(curr) < 0)
+				continue;
+
+			/* Private task is an easy target: */
+			if (task_numa_shared(curr) == 0) {
+				if (!rq->curr_buddy)
+					target_cpu = cpu;
+				continue;
+			}
+			if (curr->mm != p->mm) {
+				/* Leave alone different groups on their ideal node: */
+				if (cpu_to_node(curr->ideal_cpu) == node)
+					continue;
+				if (!rq->curr_buddy)
+					target_cpu = cpu;
+				continue;
+			}
+
+			buddies++;
+		}
+		WARN_ON_ONCE(buddies > full_buddies);
+
+		/* Don't go to a node that is already at full capacity: */
+		if (buddies == full_buddies)
+			continue;
+
+		if (!buddies)
+			continue;
+
+		if (buddies > max_buddies && target_cpu != -1) {
+			max_buddies = buddies;
+			best_node = node;
+			WARN_ON_ONCE(target_cpu == -1);
+			ideal_cpu = target_cpu;
+		}
+	}
+
+	WARN_ON_ONCE(best_node == -1 && ideal_cpu != -1);
+	WARN_ON_ONCE(best_node != -1 && ideal_cpu == -1);
+
+	this_node = cpu_to_node(this_cpu);
+
+	/* If we'd stay within this node then stay put: */
+	if (ideal_cpu == -1 || cpu_to_node(ideal_cpu) == this_node)
+		ideal_cpu = this_cpu;
+
+	return ideal_cpu;
+}
+
+static int sched_update_ideal_cpu_private(struct task_struct *p)
+{
+	int full_idles;
+	int this_idles;
+	int max_idles;
+	int target_cpu;
+	int ideal_cpu;
+	int best_node;
+	int this_node;
+	int this_cpu;
+	int idles;
+	int node;
+	int cpu;
+
+	if (!sched_feat(PUSH_PRIVATE_BUDDIES))
+		return -1;
+
+	ideal_cpu = -1;
+	best_node = -1;
+	max_idles = 0;
+	this_idles = 0;
+	this_cpu = task_cpu(p);
+	this_node = cpu_to_node(this_cpu);
+
+	for_each_online_node(node) {
+		full_idles = cpumask_weight(cpumask_of_node(node));
+
+		idles = 0;
+		target_cpu = -1;
+
+		for_each_cpu(cpu, cpumask_of_node(node)) {
+			struct rq *rq;
+
+			WARN_ON_ONCE(cpu_to_node(cpu) != node);
+
+			rq = cpu_rq(cpu);
+			if (rq->curr == rq->idle) {
+				if (!rq->curr_buddy)
+					target_cpu = cpu;
+				idles++;
+			}
+		}
+		WARN_ON_ONCE(idles > full_idles);
+
+		if (node == this_node)
+			this_idles = idles;
+
+		if (!idles)
+			continue;
+
+		if (idles > max_idles && target_cpu != -1) {
+			max_idles = idles;
+			best_node = node;
+			WARN_ON_ONCE(target_cpu == -1);
+			ideal_cpu = target_cpu;
+		}
+	}
+
+	WARN_ON_ONCE(best_node == -1 && ideal_cpu != -1);
+	WARN_ON_ONCE(best_node != -1 && ideal_cpu == -1);
+
+	/* If the target is not idle enough, skip: */
+	if (max_idles <= this_idles+1)
+		ideal_cpu = this_cpu;
+		
+	/* If we'd stay within this node then stay put: */
+	if (ideal_cpu == -1 || cpu_to_node(ideal_cpu) == this_node)
+		ideal_cpu = this_cpu;
+
+	return ideal_cpu;
+}
+
+
 /*
  * Called for every full scan - here we consider switching to a new
  * shared buddy, if the one we found during this scan is good enough:
@@ -862,7 +1037,6 @@ static void shared_fault_full_scan_done(struct task_struct *p)
 		WARN_ON_ONCE(!p->shared_buddy_curr);
 		p->shared_buddy			= p->shared_buddy_curr;
 		p->shared_buddy_faults		= p->shared_buddy_faults_curr;
-		p->ideal_cpu			= p->ideal_cpu_curr;
 
 		goto clear_buddy;
 	}
@@ -891,14 +1065,13 @@ static void task_numa_placement(struct task_struct *p)
 	unsigned long total[2] = { 0, 0 };
 	unsigned long faults, max_faults = 0;
 	int node, priv, shared, max_node = -1;
+	int this_node;
 
 	if (p->numa_scan_seq == seq)
 		return;
 
 	p->numa_scan_seq = seq;
 
-	shared_fault_full_scan_done(p);
-
 	/*
 	 * Update the fault average with the result of the latest
 	 * scan:
@@ -926,10 +1099,7 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	if (max_node != p->numa_max_node) {
-		sched_setnuma(p, max_node, task_numa_shared(p));
-		goto out_backoff;
-	}
+	shared_fault_full_scan_done(p);
 
 	p->numa_migrate_seq++;
 	if (sched_feat(NUMA_SETTLE) &&
@@ -942,14 +1112,55 @@ static void task_numa_placement(struct task_struct *p)
 	 * the impact of a little private memory accesses.
 	 */
 	shared = (total[0] >= total[1] / 2);
-	if (shared != task_numa_shared(p)) {
-		sched_setnuma(p, p->numa_max_node, shared);
+	if (shared)
+		p->ideal_cpu = sched_update_ideal_cpu_shared(p);
+	else
+		p->ideal_cpu = sched_update_ideal_cpu_private(p);
+
+	if (p->ideal_cpu >= 0) {
+		/* Filter migrations a bit - the same target twice in a row is picked: */
+		if (p->ideal_cpu == p->ideal_cpu_candidate) {
+			max_node = cpu_to_node(p->ideal_cpu);
+		} else {
+			p->ideal_cpu_candidate = p->ideal_cpu;
+			max_node = -1;
+		}
+	} else {
+		if (max_node < 0)
+			max_node = p->numa_max_node;
+	}
+
+	if (shared != task_numa_shared(p) || (max_node != -1 && max_node != p->numa_max_node)) {
+
 		p->numa_migrate_seq = 0;
-		goto out_backoff;
+		/*
+		 * Fix up node migration fault statistics artifact, as we
+		 * migrate to another node we'll soon bring over our private
+		 * working set - generating 'shared' faults as that happens.
+		 * To counter-balance this effect, move this node's private
+		 * stats to the new node.
+		 */
+		if (max_node != -1 && p->numa_max_node != -1 && max_node != p->numa_max_node) {
+			int idx_oldnode = p->numa_max_node*2 + 1;
+			int idx_newnode = max_node*2 + 1;
+
+			p->numa_faults[idx_newnode] += p->numa_faults[idx_oldnode];
+			p->numa_faults[idx_oldnode] = 0;
+		}
+		sched_setnuma(p, max_node, shared);
+	} else {
+		/* node unchanged, back off: */
+		p->numa_scan_period = min(p->numa_scan_period * 2, sysctl_sched_numa_scan_period_max);
+	}
+
+	this_node = cpu_to_node(task_cpu(p));
+
+	if (max_node >= 0 && p->ideal_cpu >= 0 && max_node != this_node) {
+		struct rq *rq = cpu_rq(p->ideal_cpu);
+
+		rq->curr_buddy = p;
+		sched_rebalance_to(p->ideal_cpu);
 	}
-	return;
-out_backoff:
-	p->numa_scan_period = min(p->numa_scan_period * 2, sysctl_sched_numa_scan_period_max);
 }
 
 /*
@@ -1051,6 +1262,8 @@ void task_numa_fault(int node, int last_cpu, int pages)
 	int priv = (task_cpu(p) == last_cpu);
 	int idx = 2*node + priv;
 
+	WARN_ON_ONCE(last_cpu == -1 || node == -1);
+
 	if (unlikely(!p->numa_faults)) {
 		int entries = 2*nr_node_ids;
 		int size = sizeof(*p->numa_faults) * entries;
@@ -3545,6 +3758,11 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 	if (p->nr_cpus_allowed == 1)
 		return prev_cpu;
 
+#ifdef CONFIG_NUMA_BALANCING
+	if (sched_feat(WAKE_ON_IDEAL_CPU) && p->ideal_cpu >= 0)
+		return p->ideal_cpu;
+#endif
+
 	if (sd_flag & SD_BALANCE_WAKE) {
 		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
 			want_affine = 1;
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 737d2c8..c868a66 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -68,11 +68,14 @@ SCHED_FEAT(RT_RUNTIME_SHARE, true)
 SCHED_FEAT(LB_MIN, false)
 SCHED_FEAT(IDEAL_CPU,			true)
 SCHED_FEAT(IDEAL_CPU_THREAD_BIAS,	false)
+SCHED_FEAT(PUSH_PRIVATE_BUDDIES,	true)
+SCHED_FEAT(PUSH_SHARED_BUDDIES,		true)
+SCHED_FEAT(WAKE_ON_IDEAL_CPU,		false)
 
 #ifdef CONFIG_NUMA_BALANCING
 /* Do the working set probing faults: */
 SCHED_FEAT(NUMA,             true)
-SCHED_FEAT(NUMA_FAULTS_UP,   true)
-SCHED_FEAT(NUMA_FAULTS_DOWN, true)
+SCHED_FEAT(NUMA_FAULTS_UP,   false)
+SCHED_FEAT(NUMA_FAULTS_DOWN, false)
 SCHED_FEAT(NUMA_SETTLE,      true)
 #endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index bb9475c..810a1a0 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -441,6 +441,7 @@ struct rq {
 	unsigned long numa_weight;
 	unsigned long nr_numa_running;
 	unsigned long nr_ideal_running;
+	struct task_struct *curr_buddy;
 #endif
 	unsigned long nr_shared_running;	/* 0 on non-NUMA */
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
