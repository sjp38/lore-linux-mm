Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EE8D36B0073
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:01 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 18/36] autonuma: teach CFS about autonuma affinity
Date: Wed, 22 Aug 2012 16:59:02 +0200
Message-Id: <1345647560-30387-19-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

The CFS scheduler is still in charge of all scheduling decisions. At
times, however, AutoNUMA balancing will override them.

Generally, we'll just rely on the CFS scheduler to keep doing its
thing, while preferring the task's AutoNUMA affine node when deciding
to move a task to a different runqueue or when waking it up.

For example, idle balancing, while looking into the runqueues of busy
CPUs, will first look for a task that "wants" to run on the NUMA node
of this idle CPU (one where task_autonuma_cpu() returns true).

Most of this is encoded in can_migrate_task becoming AutoNUMA aware
and running two passes for each balancing pass, the first NUMA aware,
and the second one relaxed.

Idle or newidle balancing is always allowed to fall back to scheduling
non-affine AutoNUMA tasks (ones with task_selected_nid set to another
node). Load_balancing, which affects fairness more than performance,
is only able to schedule against AutoNUMA affinity if the flag
/sys/kernel/mm/autonuma/scheduler/load_balance_strict is not set.

Tasks that haven't been fully profiled yet, are not affected by this
because their p->task_autonuma->task_selected_nid is still set to the
original value of -1 and task_autonuma_cpu will always return true in
that case.

Includes fixes from Hillf Danton <dhillf@gmail.com>.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/sched/fair.c |   71 ++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 59 insertions(+), 12 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 677b99e..560a170 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2622,6 +2622,8 @@ find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu)
 		load = weighted_cpuload(i);
 
 		if (load < min_load || (load == min_load && i == this_cpu)) {
+			if (!task_autonuma_cpu(p, i))
+				continue;
 			min_load = load;
 			idlest = i;
 		}
@@ -2638,31 +2640,43 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	int cpu = smp_processor_id();
 	int prev_cpu = task_cpu(p);
 	struct sched_domain *sd;
+	bool idle_target;
 
 	/*
-	 * If the task is going to be woken-up on this cpu and if it is
-	 * already idle, then it is the right target.
+	 * If the task is going to be woken-up on this cpu and if it
+	 * is already idle and if this cpu is in the AutoNUMA selected
+	 * NUMA node, then it is the right target.
 	 */
-	if (target == cpu && idle_cpu(cpu))
+	if (target == cpu && idle_cpu(cpu) && task_autonuma_cpu(p, cpu))
 		return cpu;
 
 	/*
-	 * If the task is going to be woken-up on the cpu where it previously
-	 * ran and if it is currently idle, then it the right target.
+	 * If the task is going to be woken-up on the cpu where it
+	 * previously ran and if it is currently idle and if the cpu
+	 * where it run previously is in the AutoNUMA selected node,
+	 * then it the right target.
 	 */
-	if (target == prev_cpu && idle_cpu(prev_cpu))
+	if (target == prev_cpu && idle_cpu(prev_cpu) &&
+	    task_autonuma_cpu(p, prev_cpu))
 		return prev_cpu;
 
 	/*
 	 * Otherwise, check assigned siblings to find an elegible idle cpu.
 	 */
+	idle_target = false;
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 
 	for_each_lower_domain(sd) {
 		if (!cpumask_test_cpu(sd->idle_buddy, tsk_cpus_allowed(p)))
 			continue;
-		if (idle_cpu(sd->idle_buddy))
-			return sd->idle_buddy;
+		if (idle_cpu(sd->idle_buddy)) {
+			if (task_autonuma_cpu(p, sd->idle_buddy))
+				return sd->idle_buddy;
+			else if (!idle_target) {
+				idle_target = true;
+				target = sd->idle_buddy;
+			}
+		}
 	}
 
 	return target;
@@ -2694,7 +2708,8 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 	if (sd_flag & SD_BALANCE_WAKE) {
-		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) &&
+		    task_autonuma_cpu(p, cpu))
 			want_affine = 1;
 		new_cpu = prev_cpu;
 	}
@@ -3067,6 +3082,7 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
 #define LBF_SOME_PINNED 0x04
+#define LBF_NUMA	0x08
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3146,7 +3162,9 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	 * We do not migrate tasks that are:
 	 * 1) running (obviously), or
 	 * 2) cannot be migrated to this CPU due to cpus_allowed, or
-	 * 3) are cache-hot on their current CPU.
+	 * 3) are cache-hot on their current CPU, or
+	 * 4) going to be migrated to a dst_cpu not in the selected NUMA node
+	 *    if LBF_NUMA is set.
 	 */
 	if (!cpumask_test_cpu(env->dst_cpu, tsk_cpus_allowed(p))) {
 		int new_dst_cpu;
@@ -3181,6 +3199,10 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		return 0;
 	}
 
+	if (!sched_autonuma_can_migrate_task(p, env->flags & LBF_NUMA,
+					     env->dst_cpu, env->idle))
+		return 0;
+
 	/*
 	 * Aggressive migration if:
 	 * 1) task is cache cold, or
@@ -3217,6 +3239,8 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
@@ -3231,8 +3255,14 @@ static int move_one_task(struct lb_env *env)
 		 * stats here rather than inside move_task().
 		 */
 		schedstat_inc(env->sd, lb_gained[env->idle]);
+		env->flags &= ~LBF_NUMA;
 		return 1;
 	}
+	if (env->flags & LBF_NUMA) {
+		env->flags &= ~LBF_NUMA;
+		goto numa_repeat;
+	}
+
 	return 0;
 }
 
@@ -3257,6 +3287,8 @@ static int move_tasks(struct lb_env *env)
 	if (env->imbalance <= 0)
 		return 0;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	while (!list_empty(tasks)) {
 		p = list_first_entry(tasks, struct task_struct, se.group_node);
 
@@ -3296,9 +3328,13 @@ static int move_tasks(struct lb_env *env)
 		 * kernels will stop after the first task is pulled to minimize
 		 * the critical section.
 		 */
-		if (env->idle == CPU_NEWLY_IDLE)
-			break;
+		if (env->idle == CPU_NEWLY_IDLE) {
+			env->flags &= ~LBF_NUMA;
+			goto out;
+		}
 #endif
+		/* not idle anymore after pulling first task */
+		env->idle = CPU_NOT_IDLE;
 
 		/*
 		 * We only want to steal up to the prescribed amount of
@@ -3311,6 +3347,17 @@ static int move_tasks(struct lb_env *env)
 next:
 		list_move_tail(&p->se.group_node, tasks);
 	}
+	if ((env->flags & (LBF_NUMA|LBF_NEED_BREAK)) == LBF_NUMA) {
+		env->flags &= ~LBF_NUMA;
+		if (env->imbalance > 0) {
+			env->loop = 0;
+			env->loop_break = sched_nr_migrate_break;
+			goto numa_repeat;
+		}
+	}
+#ifdef CONFIG_PREEMPT
+out:
+#endif
 
 	/*
 	 * Right now, this is one of only two places move_task() is called,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
