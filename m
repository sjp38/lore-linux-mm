Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 9DD1A6B00FF
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:14 -0400 (EDT)
Message-Id: <20120316144241.749359061@chello.nl>
Date: Fri, 16 Mar 2012 15:40:53 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 25/26] sched, numa: Only migrate long-running entities
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-migrate-duration.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

It doesn't make much sense to memory migrate short running things.

Suggested-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/sched/numa.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -15,6 +15,8 @@ struct numa_ops {
 	void		(*mem_migrate)(struct numa_entity *ne, int node);
 	void		(*cpu_migrate)(struct numa_entity *ne, int node);
 
+	u64		(*cpu_runtime)(struct numa_entity *ne);
+
 	bool		(*tryget)(struct numa_entity *ne);
 	void		(*put)(struct numa_entity *ne);
 };
@@ -196,6 +198,21 @@ static void process_mem_migrate(struct n
 	lazy_migrate_process(ne_mm(ne), node);
 }
 
+static u64 process_cpu_runtime(struct numa_entity *ne)
+{
+	struct task_struct *p, *t;
+	u64 runtime = 0;
+
+	rcu_read_lock();
+	t = p = ne_owner(ne);
+	if (p) do {
+		runtime += t->se.sum_exec_runtime; // @#$#@ 32bit
+	} while ((t = next_thread(t)) != p);
+	rcu_read_unlock();
+
+	return runtime;
+}
+
 static bool process_tryget(struct numa_entity *ne)
 {
 	/*
@@ -219,6 +236,8 @@ static const struct numa_ops process_num
 	.mem_migrate	= process_mem_migrate,
 	.cpu_migrate	= process_cpu_migrate,
 
+	.cpu_runtime	= process_cpu_runtime,
+
 	.tryget		= process_tryget,
 	.put		= process_put,
 };
@@ -616,6 +635,14 @@ static bool can_move_ne(struct numa_enti
 	 * XXX: consider mems_allowed, stinking cpusets has mems_allowed
 	 * per task and it can actually differ over a whole process, la-la-la.
 	 */
+
+	/*
+	 * Don't bother migrating memory if there's less than 1 second
+	 * of runtime on the tasks.
+	 */
+	if (ne->nops->cpu_runtime(ne) < NSEC_PER_SEC)
+		return false;
+
 	return true;
 }
 
@@ -1000,6 +1027,20 @@ static void numa_group_cpu_migrate(struc
 	rcu_read_unlock();
 }
 
+static u64 numa_group_cpu_runtime(struct numa_entity *ne)
+{
+	struct numa_group *ng = ne_ng(ne);
+	struct task_struct *p;
+	u64 runtime = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(p, &ng->tasks, ng_entry)
+		runtime += p->se.sum_exec_runtime; // @#$# 32bit
+	rcu_read_unlock();
+
+	return runtime;
+}
+
 static bool numa_group_tryget(struct numa_entity *ne)
 {
 	/*
@@ -1020,6 +1061,8 @@ static const struct numa_ops numa_group_
 	.mem_migrate	= numa_group_mem_migrate,
 	.cpu_migrate	= numa_group_cpu_migrate,
 
+	.cpu_runtime	= numa_group_cpu_runtime,
+
 	.tryget		= numa_group_tryget,
 	.put		= numa_group_put,
 };


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
