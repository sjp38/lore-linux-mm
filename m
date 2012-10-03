Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1AC756B00A2
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
Date: Thu,  4 Oct 2012 01:51:00 +0200
Message-Id: <1349308275-2174-19-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

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
 kernel/sched/fair.c |   67 +++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 0c6bedd..05c5c78 100644
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
@@ -2640,12 +2642,14 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	struct sched_domain *sd;
 	struct sched_group *sg;
 	int i;
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
@@ -2658,6 +2662,7 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	/*
 	 * Otherwise, iterate the domains and find an elegible idle cpu.
 	 */
+	idle_target = false;
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 	for_each_lower_domain(sd) {
 		sg = sd->groups;
@@ -2671,9 +2676,18 @@ static int select_idle_sibling(struct task_struct *p, int target)
 					goto next;
 			}
 
-			target = cpumask_first_and(sched_group_cpus(sg),
-					tsk_cpus_allowed(p));
-			goto done;
+			for_each_cpu_and(i, sched_group_cpus(sg),
+					 tsk_cpus_allowed(p)) {
+				/* Find autonuma cpu only in idle group */
+				if (task_autonuma_cpu(p, i)) {
+					target = i;
+					goto done;
+				}
+				if (!idle_target) {
+					idle_target = true;
+					target = i;
+				}
+			}
 next:
 			sg = sg->next;
 		} while (sg != sd->groups);
@@ -2708,7 +2722,8 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 	if (sd_flag & SD_BALANCE_WAKE) {
-		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) &&
+		    task_autonuma_cpu(p, cpu))
 			want_affine = 1;
 		new_cpu = prev_cpu;
 	}
@@ -3081,6 +3096,7 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
 #define LBF_SOME_PINNED 0x04
+#define LBF_NUMA	0x08
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3160,7 +3176,9 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
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
@@ -3195,6 +3213,10 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		return 0;
 	}
 
+	if (!sched_autonuma_can_migrate_task(p, env->flags & LBF_NUMA,
+					     env->dst_cpu, env->idle))
+		return 0;
+
 	/*
 	 * Aggressive migration if:
 	 * 1) task is cache cold, or
@@ -3231,6 +3253,8 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+	env->flags |= autonuma_possible() ? LBF_NUMA : 0;
+numa_repeat:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
@@ -3245,8 +3269,14 @@ static int move_one_task(struct lb_env *env)
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
 
@@ -3271,6 +3301,8 @@ static int move_tasks(struct lb_env *env)
 	if (env->imbalance <= 0)
 		return 0;
 
+	env->flags |= autonuma_possible() ? LBF_NUMA : 0;
+numa_repeat:
 	while (!list_empty(tasks)) {
 		p = list_first_entry(tasks, struct task_struct, se.group_node);
 
@@ -3310,9 +3342,13 @@ static int move_tasks(struct lb_env *env)
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
@@ -3325,6 +3361,17 @@ static int move_tasks(struct lb_env *env)
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
