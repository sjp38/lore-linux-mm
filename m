Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id F23666B0037
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:47:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/16] sched: Track NUMA hinting faults on per-node basis
Date: Thu, 11 Jul 2013 10:46:46 +0100
Message-Id: <1373536020-2799-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1373536020-2799-1-git-send-email-mgorman@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch tracks what nodes numa hinting faults were incurred on.  Greater
weight is given if the pages were to be migrated on the understanding
that such faults cost significantly more. If a task has paid the cost to
migrating data to that node then in the future it would be preferred if the
task did not migrate the data again unnecessarily. This information is later
used to schedule a task on the node incurring the most NUMA hinting faults.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  2 ++
 kernel/sched/core.c   |  3 +++
 kernel/sched/fair.c   | 12 +++++++++++-
 kernel/sched/sched.h  | 11 +++++++++++
 4 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..72861b4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1505,6 +1505,8 @@ struct task_struct {
 	unsigned int numa_scan_period;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
+
+	unsigned long *numa_faults;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 67d0465..f332ec0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1594,6 +1594,7 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_migrate_seq = p->mm ? p->mm->numa_scan_seq - 1 : 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_work.next = &p->numa_work;
+	p->numa_faults = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
@@ -1853,6 +1854,8 @@ static void finish_task_switch(struct rq *rq, struct task_struct *prev)
 	if (mm)
 		mmdrop(mm);
 	if (unlikely(prev_state == TASK_DEAD)) {
+		task_numa_free(prev);
+
 		/*
 		 * Remove function-return probe instances associated with this
 		 * task and put them back on the free list.
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7a33e59..904fd6f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -815,7 +815,14 @@ void task_numa_fault(int node, int pages, bool migrated)
 	if (!sched_feat_numa(NUMA))
 		return;
 
-	/* FIXME: Allocate task-specific structure for placement policy here */
+	/* Allocate buffer to track faults on a per-node basis */
+	if (unlikely(!p->numa_faults)) {
+		int size = sizeof(*p->numa_faults) * nr_node_ids;
+
+		p->numa_faults = kzalloc(size, GFP_KERNEL);
+		if (!p->numa_faults)
+			return;
+	}
 
 	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
@@ -826,6 +833,9 @@ void task_numa_fault(int node, int pages, bool migrated)
 			p->numa_scan_period + jiffies_to_msecs(10));
 
 	task_numa_placement(p);
+
+	/* Record the fault, double the weight if pages were migrated */
+	p->numa_faults[node] += pages << migrated;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index cc03cfd..c5f773d 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -503,6 +503,17 @@ DECLARE_PER_CPU(struct rq, runqueues);
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define raw_rq()		(&__raw_get_cpu_var(runqueues))
 
+#ifdef CONFIG_NUMA_BALANCING
+static inline void task_numa_free(struct task_struct *p)
+{
+	kfree(p->numa_faults);
+}
+#else /* CONFIG_NUMA_BALANCING */
+static inline void task_numa_free(struct task_struct *p)
+{
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_SMP
 
 #define rcu_dereference_check_sched_domain(p) \
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
