Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A829C6B00ED
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:05 -0400 (EDT)
Message-Id: <20120316144240.690180983@chello.nl>
Date: Fri, 16 Mar 2012 15:40:37 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 09/26] sched, mm: Introduce tsk_home_node()
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-foo-1.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Introduce the home-node concept for tasks. In order to keep memory
locality we need to have a something to stay local to, we define the
home-node of a task as the node we prefer to allocate memory from and
prefer to execute on.

These are no hard guarantees, merely preferences. This allows for
optimal resource usage, we can run a task away from the home-node, the
remote memory hit -- while expensive -- is less expensive than not
running at all, or very little, due to severe cpu overload.

Similarly, we can allocate memory from another node if our home-node
is depleted, again, some memory is better than no memory.

This patch merely introduces the basic infrastructure, all policy
comes later.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/init_task.h |    8 ++++++++
 include/linux/sched.h     |    6 ++++++
 kernel/sched/core.c       |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+)

--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -127,6 +127,13 @@ extern struct cred init_cred;
 
 #define INIT_TASK_COMM "swapper"
 
+#ifdef CONFIG_NUMA
+# define INIT_TASK_NUMA(tsk)						\
+	.node = -1,
+#else
+# define INIT_TASK_NUMA(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -192,6 +199,7 @@ extern struct cred init_cred;
 	INIT_FTRACE_GRAPH						\
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
+	INIT_TASK_NUMA(tsk)						\
 }
 
 
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1541,6 +1541,7 @@ struct task_struct {
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
 	short pref_node_fork;
+	int node;
 #endif
 	struct rcu_head rcu;
 
@@ -1615,6 +1616,11 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+static inline int tsk_home_node(struct task_struct *p)
+{
+	return p->node;
+}
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5874,6 +5874,38 @@ __setup("isolcpus=", isolated_cpu_setup)
 
 #ifdef CONFIG_NUMA
 
+/*
+ * Requeues a task ensuring its on the right load-balance list so
+ * that it might get migrated to its new home.
+ *
+ * Note that we cannot actively migrate ourselves since our callers
+ * can be from atomic context. We rely on the regular load-balance
+ * mechanisms to move us around -- its all preference anyway.
+ */
+void sched_setnode(struct task_struct *p, int node)
+{
+	unsigned long flags;
+	int on_rq, running;
+	struct rq *rq;
+
+	rq = task_rq_lock(p, &flags);
+	on_rq = p->on_rq;
+	running = task_current(rq, p);
+
+	if (on_rq)
+		dequeue_task(rq, p, 0);
+	if (running)
+		p->sched_class->put_prev_task(rq, p);
+
+	p->node = node;
+
+	if (running)
+		p->sched_class->set_curr_task(rq);
+	if (on_rq)
+		enqueue_task(rq, p, 0);
+	task_rq_unlock(rq, p, &flags);
+}
+
 /**
  * find_next_best_node - find the next node to include in a sched_domain
  * @node: node whose sched_domain we're building


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
