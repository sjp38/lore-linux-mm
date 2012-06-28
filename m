Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C009E6B0072
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:56:55 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 22/40] autonuma: teach CFS about autonuma affinity
Date: Thu, 28 Jun 2012 14:56:02 +0200
Message-Id: <1340888180-15355-23-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

The CFS scheduler is still in charge of all scheduling
decisions. AutoNUMA balancing at times will override those. But
generally we'll just relay on the CFS scheduler to keep doing its
thing, but while preferring the autonuma affine nodes when deciding
to move a process to a different runqueue or when waking it up.

For example the idle balancing, will look into the runqueues of the
busy CPUs, but it'll search first for a task that wants to run into
the idle CPU in AutoNUMA terms (task_autonuma_cpu() being true).

Most of this is encoded in the can_migrate_task becoming AutoNUMA
aware and running two passes for each balancing pass, the first NUMA
aware, and the second one relaxed.

The idle/newidle balancing is always allowed to fallback into
non-affine AutoNUMA tasks. The load_balancing (which is more a
fariness than a performance issue) is instead only able to cross over
the AutoNUMA affinity if the flag controlled by
/sys/kernel/mm/autonuma/scheduler/load_balance_strict is not set (it
is set by default).

Tasks that haven't been fully profiled yet, are not affected by this
because their p->sched_autonuma->autonuma_node is still set to the
original value of -1 and task_autonuma_cpu will always return true in
that case.

Includes fixes from Hillf Danton <dhillf@gmail.com>.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/sched/fair.c |   65 +++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 56 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fa96810..dab9bdd 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/autonuma_sched.h>
 
 #include <trace/events/sched.h>
 
@@ -2621,6 +2622,8 @@ find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu)
 		load = weighted_cpuload(i);
 
 		if (load < min_load || (load == min_load && i == this_cpu)) {
+			if (!task_autonuma_cpu(p, i))
+				continue;
 			min_load = load;
 			idlest = i;
 		}
@@ -2639,24 +2642,27 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	struct sched_domain *sd;
 	struct sched_group *sg;
 	int i;
+	bool idle_target;
 
 	/*
 	 * If the task is going to be woken-up on this cpu and if it is
 	 * already idle, then it is the right target.
 	 */
-	if (target == cpu && idle_cpu(cpu))
+	if (target == cpu && idle_cpu(cpu) && task_autonuma_cpu(p, cpu))
 		return cpu;
 
 	/*
 	 * If the task is going to be woken-up on the cpu where it previously
 	 * ran and if it is currently idle, then it the right target.
 	 */
-	if (target == prev_cpu && idle_cpu(prev_cpu))
+	if (target == prev_cpu && idle_cpu(prev_cpu) &&
+	    task_autonuma_cpu(p, prev_cpu))
 		return prev_cpu;
 
 	/*
 	 * Otherwise, iterate the domains and find an elegible idle cpu.
 	 */
+	idle_target = false;
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 	for_each_lower_domain(sd) {
 		sg = sd->groups;
@@ -2670,9 +2676,18 @@ static int select_idle_sibling(struct task_struct *p, int target)
 					goto next;
 			}
 
-			target = cpumask_first_and(sched_group_cpus(sg),
-					tsk_cpus_allowed(p));
-			goto done;
+			for_each_cpu_and(i, sched_group_cpus(sg),
+						tsk_cpus_allowed(p)) {
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
@@ -2707,7 +2722,8 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 	if (sd_flag & SD_BALANCE_WAKE) {
-		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) &&
+		    task_autonuma_cpu(p, cpu))
 			want_affine = 1;
 		new_cpu = prev_cpu;
 	}
@@ -3072,6 +3088,7 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
+#define LBF_NUMA	0x04
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3142,13 +3159,14 @@ static
 int can_migrate_task(struct task_struct *p, struct lb_env *env)
 {
 	int tsk_cache_hot = 0;
+	struct cpumask *allowed = tsk_cpus_allowed(p);
 	/*
 	 * We do not migrate tasks that are:
 	 * 1) running (obviously), or
 	 * 2) cannot be migrated to this CPU due to cpus_allowed, or
 	 * 3) are cache-hot on their current CPU.
 	 */
-	if (!cpumask_test_cpu(env->dst_cpu, tsk_cpus_allowed(p))) {
+	if (!cpumask_test_cpu(env->dst_cpu, allowed)) {
 		schedstat_inc(p, se.statistics.nr_failed_migrations_affine);
 		return 0;
 	}
@@ -3159,6 +3177,10 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		return 0;
 	}
 
+	if (!sched_autonuma_can_migrate_task(p, env->flags & LBF_NUMA,
+					     env->dst_cpu, env->idle))
+		return 0;
+
 	/*
 	 * Aggressive migration if:
 	 * 1) task is cache cold, or
@@ -3195,6 +3217,8 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
@@ -3209,8 +3233,14 @@ static int move_one_task(struct lb_env *env)
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
 
@@ -3235,6 +3265,8 @@ static int move_tasks(struct lb_env *env)
 	if (env->imbalance <= 0)
 		return 0;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	while (!list_empty(tasks)) {
 		p = list_first_entry(tasks, struct task_struct, se.group_node);
 
@@ -3274,9 +3306,13 @@ static int move_tasks(struct lb_env *env)
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
@@ -3289,6 +3325,17 @@ static int move_tasks(struct lb_env *env)
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
