Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 455776B003A
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:46 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 08:49:44 +0100
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2C6316E803F
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:37 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7ngPa138456
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nf55003881
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:42 -0400
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 07/10] sched: Pass hint to active balancer about the task to be chosen
Date: Tue, 30 Jul 2013 13:18:22 +0530
Message-Id: <1375170505-5967-8-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

If a task to be active balanced, which improves the numa affinity is
already chosen, then pass the task to the actual migration.

This helps in 2 ways.
- Dont have to iterate through the list of tasks and again chose a
  task.
- If the chosen task has already moved out of runqueue, avoid moving
  some other task that may or may not provide consolidation.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/sched/fair.c  |   20 +++++++++++++++++++-
 kernel/sched/sched.h |    3 +++
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 17027e0..e04703e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4057,6 +4057,18 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+#ifdef CONFIG_NUMA_BALANCING
+	p = env->src_rq->push_task;
+	if (p) {
+		if (p->on_rq && task_cpu(p) == env->src_rq->cpu) {
+			move_task(p, env);
+			schedstat_inc(env->sd, lb_gained[env->idle]);
+			return 1;
+		}
+		return 0;
+	}
+#endif
+
 again:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
 		if (!preferred_node(p, env))
@@ -5471,6 +5483,9 @@ static int active_load_balance_cpu_stop(void *data)
 	double_unlock_balance(busiest_rq, target_rq);
 out_unlock:
 	busiest_rq->active_balance = 0;
+#ifdef CONFIG_NUMA_BALANCING
+	busiest_rq->push_task = NULL;
+#endif
 	raw_spin_unlock_irq(&busiest_rq->lock);
 	return 0;
 }
@@ -5621,6 +5636,8 @@ select_task_to_pull(struct mm_struct *this_mm, int this_cpu, int nid)
 		rq = cpu_rq(cpu);
 		mm = rq->curr->mm;
 
+		if (rq->push_task)
+			continue;
 		if (mm == this_mm) {
 			if (cpumask_test_cpu(this_cpu, tsk_cpus_allowed(rq->curr)))
 				return rq->curr;
@@ -5823,10 +5840,11 @@ static void rebalance_domains(int cpu, enum cpu_idle_type idle)
 			 * only after active load balance is finished.
 			 */
 			raw_spin_lock_irqsave(&this_rq->lock, flags);
-			if (task_rq(p) == this_rq) {
+			if (task_rq(p) == this_rq && !this_rq->push_task) {
 				if (!this_rq->active_balance) {
 					this_rq->active_balance = 1;
 					this_rq->push_cpu = cpu;
+					this_rq->push_task = p;
 					active_balance = 1;
 				}
 			}
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index cc03cfd..9f60d74 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -484,6 +484,9 @@ struct rq {
 #endif
 
 	struct sched_avg avg;
+#ifdef CONFIG_NUMA_BALANCING
+	struct task_struct *push_task;
+#endif
 };
 
 static inline int cpu_of(struct rq *rq)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
