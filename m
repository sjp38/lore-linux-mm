Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 09F3F6B00E7
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:11:40 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 23/39] autonuma: teach CFS about autonuma affinity
Date: Mon, 26 Mar 2012 19:46:10 +0200
Message-Id: <1332783986-24195-24-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

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

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/sched/fair.c |   57 ++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 0c60f46..166168d 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/profile.h>
 #include <linux/interrupt.h>
+#include <linux/autonuma_sched.h>
 
 #include <trace/events/sched.h>
 
@@ -2618,6 +2619,8 @@ find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu)
 
 	/* Traverse only the allowed CPUs */
 	for_each_cpu_and(i, sched_group_cpus(group), tsk_cpus_allowed(p)) {
+		if (task_autonuma_cpu(p, i))
+			continue;
 		load = weighted_cpuload(i);
 
 		if (load < min_load || (load == min_load && i == this_cpu)) {
@@ -2639,24 +2642,28 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	struct sched_domain *sd;
 	struct sched_group *sg;
 	int i;
+	bool numa;
 
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
+	numa = true;
+again:
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 	for_each_lower_domain(sd) {
 		sg = sd->groups;
@@ -2666,7 +2673,8 @@ static int select_idle_sibling(struct task_struct *p, int target)
 				goto next;
 
 			for_each_cpu(i, sched_group_cpus(sg)) {
-				if (!idle_cpu(i))
+				if (!idle_cpu(i) ||
+				    (numa && !task_autonuma_cpu(p, i)))
 					goto next;
 			}
 
@@ -2677,6 +2685,10 @@ next:
 			sg = sg->next;
 		} while (sg != sd->groups);
 	}
+	if (numa) {
+		numa = false;
+		goto again;
+	}
 done:
 	return target;
 }
@@ -2707,7 +2719,8 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		return prev_cpu;
 
 	if (sd_flag & SD_BALANCE_WAKE) {
-		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)) &&
+		    task_autonuma_cpu(p, cpu))
 			want_affine = 1;
 		new_cpu = prev_cpu;
 	}
@@ -3075,6 +3088,7 @@ static unsigned long __read_mostly max_load_balance_interval = HZ/10;
 
 #define LBF_ALL_PINNED	0x01
 #define LBF_NEED_BREAK	0x02
+#define LBF_NUMA	0x04
 
 struct lb_env {
 	struct sched_domain	*sd;
@@ -3145,13 +3159,14 @@ static
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
@@ -3162,6 +3177,10 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		return 0;
 	}
 
+	if (!sched_autonuma_can_migrate_task(p, env->flags & LBF_NUMA,
+					     env->dst_cpu, env->idle, allowed))
+		return 0;
+
 	/*
 	 * Aggressive migration if:
 	 * 1) task is cache cold, or
@@ -3198,6 +3217,8 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
@@ -3212,8 +3233,14 @@ static int move_one_task(struct lb_env *env)
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
 
@@ -3236,6 +3263,8 @@ static int move_tasks(struct lb_env *env)
 	if (env->load_move <= 0)
 		return 0;
 
+	env->flags |= LBF_NUMA;
+numa_repeat:
 	while (!list_empty(tasks)) {
 		p = list_first_entry(tasks, struct task_struct, se.group_node);
 
@@ -3275,9 +3304,13 @@ static int move_tasks(struct lb_env *env)
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
@@ -3290,6 +3323,16 @@ static int move_tasks(struct lb_env *env)
 next:
 		list_move_tail(&p->se.group_node, tasks);
 	}
+	if (env->flags & LBF_NUMA) {
+		env->flags &= ~LBF_NUMA;
+		if (env->load_move > 0) {
+			env->loop = 0;
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
