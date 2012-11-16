Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1BA6D6B009F
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:51 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 36/43] sched: numa: Introduce tsk_home_node()
Date: Fri, 16 Nov 2012 11:22:46 +0000
Message-Id: <1353064973-26082-37-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Introduce the home-node concept for tasks. In order to keep memory
locality we need to have a something to stay local to, we define the
home-node of a task as the node we prefer to allocate memory from and
prefer to execute on.

These are no hard guarantees, merely soft preferences. This allows for
optimal resource usage, we can run a task away from the home-node, the
remote memory hit -- while expensive -- is less expensive than not
running at all, or very little, due to severe cpu overload.

Similarly, we can allocate memory from another node if our home-node
is depleted, again, some memory is better than no memory.

This patch merely introduces the basic infrastructure, all policy
comes later.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/init_task.h |    8 ++++++++
 include/linux/sched.h     |   10 ++++++++++
 kernel/sched/core.c       |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 6d087c5..fdf0692 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -143,6 +143,13 @@ extern struct task_group root_task_group;
 
 #define INIT_TASK_COMM "swapper"
 
+#ifdef CONFIG_BALANCE_NUMA
+# define INIT_TASK_NUMA(tsk)						\
+	.home_node = -1,
+#else
+# define INIT_TASK_NUMA(tsk)
+#endif
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -210,6 +217,7 @@ extern struct task_group root_task_group;
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
 	INIT_CPUSET_SEQ							\
+	INIT_TASK_NUMA(tsk)						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a2b06ea..b8580f5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1480,6 +1480,7 @@ struct task_struct {
 	short pref_node_fork;
 #endif
 #ifdef CONFIG_BALANCE_NUMA
+	int home_node;
 	int numa_scan_seq;
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
@@ -1569,6 +1570,15 @@ static inline void task_numa_fault(int node, int pages)
 }
 #endif
 
+static inline int tsk_home_node(struct task_struct *p)
+{
+#ifdef CONFIG_BALANCE_NUMA
+	return p->home_node;
+#else
+	return -1;
+#endif
+}
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 047e3c7..55dcf53 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5972,6 +5972,42 @@ static struct sched_domain_topology_level default_topology[] = {
 
 static struct sched_domain_topology_level *sched_domain_topology = default_topology;
 
+#ifdef CONFIG_BALANCE_NUMA
+
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
+	p->home_node = node;
+
+	if (running)
+		p->sched_class->set_curr_task(rq);
+	if (on_rq)
+		enqueue_task(rq, p, 0);
+	task_rq_unlock(rq, p, &flags);
+}
+
+#endif /* CONFIG_BALANCE_NUMA */
+
 #ifdef CONFIG_NUMA
 
 static int sched_domains_numa_levels;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
