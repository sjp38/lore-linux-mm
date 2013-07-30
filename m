Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id BA49F6B0036
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:14 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:49:14 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id EDDEE38C8027
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:08 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nAnp162154
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7n9Fl010824
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:10 -0400
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 03/10] sched: Select a better task to pull across node using iterations
Date: Tue, 30 Jul 2013 13:18:18 +0530
Message-Id: <1375170505-5967-4-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

While selecting a task to pull across a node, try to choose a task that
improves locatity. i.e choose a task that has more affinity to the
destination node.

To achieve this, parse the list of tasks in multiple iterations. For now
choose just two iterations.  In the first iteration, a task is chosen to
move if and only if moving such a task helps improve node locality.  In
the last iteration, choose the default behaviour, i.e, a task is chosen
irrespective of whether it improves node locality or not.(behaviour
before this change). This iteration logic is only for cross node
migration and with CONFIG_NUMA_BALANCING enabled.

So if there are two tasks in a runq, both eligible to be migrated to
another runq belonging to a different node, then this change tries to
chose a task among the two that improves locality.

Similar logic was first used in Peter Zijlstra's numa core.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3df7f76..8fcbf96 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3906,6 +3906,7 @@ struct lb_env {
 	unsigned int		loop;
 	unsigned int		loop_break;
 	unsigned int		loop_max;
+	unsigned int		iterations;
 };
 
 /*
@@ -4030,6 +4031,21 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	return 1;
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+static bool preferred_node(struct task_struct *p, struct lb_env *env)
+{
+	if (!(env->sd->flags & SD_NUMA))
+		return false;
+
+	return (can_numa_migrate_task(p, env->dst_rq, env->src_rq) == 1);
+}
+#else
+static bool preferred_node(struct task_struct *p, struct lb_env *env)
+{
+	return false;
+}
+#endif
+
 /*
  * move_one_task tries to move exactly one task from busiest to this_rq, as
  * part of active balancing operations within "domain".
@@ -4041,7 +4057,11 @@ static int move_one_task(struct lb_env *env)
 {
 	struct task_struct *p, *n;
 
+again:
 	list_for_each_entry_safe(p, n, &env->src_rq->cfs_tasks, se.group_node) {
+		if (!preferred_node(p, env))
+			continue;
+
 		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
 			continue;
 
@@ -4049,6 +4069,7 @@ static int move_one_task(struct lb_env *env)
 			continue;
 
 		move_task(p, env);
+
 		/*
 		 * Right now, this is only the second place move_task()
 		 * is called, so we can safely collect move_task()
@@ -4057,6 +4078,9 @@ static int move_one_task(struct lb_env *env)
 		schedstat_inc(env->sd, lb_gained[env->idle]);
 		return 1;
 	}
+	if (!env->iterations++)
+		goto again;
+
 	return 0;
 }
 
@@ -4096,6 +4120,9 @@ static int move_tasks(struct lb_env *env)
 			break;
 		}
 
+		if (!preferred_node(p, env))
+			goto next;
+
 		if (throttled_lb_pair(task_group(p), env->src_cpu, env->dst_cpu))
 			goto next;
 
@@ -5099,6 +5126,7 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 		.idle		= idle,
 		.loop_break	= sched_nr_migrate_break,
 		.cpus		= cpus,
+		.iterations	= 1,
 	};
 
 	cpumask_copy(cpus, cpu_active_mask);
@@ -5130,6 +5158,12 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 	ld_moved = 0;
 	lb_iterations = 1;
 	if (busiest->nr_running > 1) {
+#ifdef CONFIG_NUMA_BALANCING
+		if (sd->flags & SD_NUMA) {
+			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu))
+				env.iterations = 0;
+		}
+#endif
 		/*
 		 * Attempt to move tasks. If find_busiest_group has found
 		 * an imbalance but busiest->nr_running <= 1, the group is
@@ -5160,6 +5194,12 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 			goto more_balance;
 		}
 
+		if (!ld_moved && !env.iterations++) {
+			env.loop	 = 0;
+			env.loop_break	 = sched_nr_migrate_break;
+			goto more_balance;
+		}
+
 		/*
 		 * some other cpu did the load balance for us.
 		 */
@@ -5407,8 +5447,16 @@ static int active_load_balance_cpu_stop(void *data)
 			.src_cpu	= busiest_rq->cpu,
 			.src_rq		= busiest_rq,
 			.idle		= CPU_IDLE,
+			.iterations	= 1,
 		};
 
+#ifdef CONFIG_NUMA_BALANCING
+		if ((sd->flags & SD_NUMA)) {
+			if (cpu_to_node(env.dst_cpu) != cpu_to_node(env.src_cpu))
+				env.iterations = 0;
+		}
+#endif
+
 		schedstat_inc(sd, alb_count);
 
 		if (move_one_task(&env))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
