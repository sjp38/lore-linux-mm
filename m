Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D6A646B00C5
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:25 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476620eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:25 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 41/52] sched: Move the NUMA placement logic to a worklet
Date: Sun,  2 Dec 2012 19:43:33 +0100
Message-Id: <1354473824-19229-42-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

As an implementational detail, to be able to do directed task placement
we have to change how task_numa_fault() interfaces with the scheduler:
instead of the placement logic being executed directly from the fault
path we now trigger a worklet, similarly to how we do the NUMA
hinting fault work.

This moves placement into process context and allows the execution of the
directed task-flipping code via sched_rebalance_to().

This further decouples the NUMA hinting fault engine from
the actual NUMA placement logic.

[ Also move __sched_fork() out of preemptible context. ]

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |   3 +-
 kernel/sched/core.c   |  25 ++++++++-
 kernel/sched/fair.c   | 153 +++++++++++++++++++++++++++++++-------------------
 kernel/sched/sched.h  |   5 ++
 4 files changed, 126 insertions(+), 60 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 696492e..ce9ccd7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1512,7 +1512,8 @@ struct task_struct {
 	unsigned long numa_weight;
 	unsigned long *numa_faults;
 	unsigned long *numa_faults_curr;
-	struct callback_head numa_work;
+	struct callback_head numa_scan_work;
+	struct callback_head numa_placement_work;
 
 	struct task_struct *shared_buddy, *shared_buddy_curr;
 	unsigned long shared_buddy_faults, shared_buddy_faults_curr;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index cad6c89..05d4e1d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -39,6 +39,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/debug_locks.h>
 #include <linux/perf_event.h>
+#include <linux/task_work.h>
 #include <linux/security.h>
 #include <linux/notifier.h>
 #include <linux/profile.h>
@@ -1558,7 +1559,6 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_migrate_seq = 2;
 	p->numa_faults = NULL;
 	p->numa_scan_period = sysctl_sched_numa_scan_delay;
-	p->numa_work.next = &p->numa_work;
 
 	p->shared_buddy = NULL;
 	p->shared_buddy_faults = 0;
@@ -1570,6 +1570,25 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_policy.v.preferred_node = 0;
 	p->numa_policy.v.nodes = node_online_map;
 
+	init_task_work(&p->numa_scan_work, task_numa_scan_work);
+	p->numa_scan_work.next = &p->numa_scan_work;
+
+	init_task_work(&p->numa_placement_work, task_numa_placement_work);
+	p->numa_placement_work.next = &p->numa_placement_work;
+
+	if (p->mm) {
+		int entries = 2*nr_node_ids;
+		int size = sizeof(*p->numa_faults) * entries;
+
+		/*
+		 * For efficiency reasons we allocate ->numa_faults[]
+		 * and ->numa_faults_curr[] at once and split the
+		 * buffer we get. They are separate otherwise.
+		 */
+		p->numa_faults = kzalloc(2*size, GFP_KERNEL);
+		if (p->numa_faults)
+			p->numa_faults_curr = p->numa_faults + entries;
+	}
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
@@ -1579,9 +1598,11 @@ static void __sched_fork(struct task_struct *p)
 void sched_fork(struct task_struct *p)
 {
 	unsigned long flags;
-	int cpu = get_cpu();
+	int cpu;
 
 	__sched_fork(p);
+
+	cpu = get_cpu();
 	/*
 	 * We mark the process as running here. This guarantees that
 	 * nobody will actually run it, and a signal or other external
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f0d3876..fda1b63 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1063,19 +1063,18 @@ clear_buddy:
 	p->ideal_cpu_curr		= -1;
 }
 
-static void task_numa_placement(struct task_struct *p)
+/*
+ * Called every couple of hundred milliseconds in the task's
+ * execution life-time, this function decides whether to
+ * change placement parameters:
+ */
+static void task_numa_placement_tick(struct task_struct *p)
 {
-	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	unsigned long total[2] = { 0, 0 };
 	unsigned long faults, max_faults = 0;
 	int node, priv, shared, max_node = -1;
 	int this_node;
 
-	if (p->numa_scan_seq == seq)
-		return;
-
-	p->numa_scan_seq = seq;
-
 	/*
 	 * Update the fault average with the result of the latest
 	 * scan:
@@ -1279,44 +1278,25 @@ void task_numa_fault(int node, int last_cpu, int pages)
 	int priv = (task_cpu(p) == last_cpu);
 	int idx = 2*node + priv;
 
-	WARN_ON_ONCE(last_cpu < 0 || node < 0);
-
-	if (unlikely(!p->numa_faults)) {
-		int entries = 2*nr_node_ids;
-		int size = sizeof(*p->numa_faults) * entries;
-
-		p->numa_faults = kzalloc(2*size, GFP_KERNEL);
-		if (!p->numa_faults)
-			return;
-		/*
-		 * For efficiency reasons we allocate ->numa_faults[]
-		 * and ->numa_faults_curr[] at once and split the
-		 * buffer we get. They are separate otherwise.
-		 */
-		p->numa_faults_curr = p->numa_faults + entries;
-	}
+	WARN_ON_ONCE(last_cpu == -1 || node == -1);
+	BUG_ON(!p->numa_faults);
 
 	p->numa_faults_curr[idx] += pages;
 	shared_fault_tick(p, node, last_cpu, pages);
-	task_numa_placement(p);
 }
 
 /*
  * The expensive part of numa migration is done from task_work context.
  * Triggered from task_tick_numa().
  */
-void task_numa_work(struct callback_head *work)
+void task_numa_placement_work(struct callback_head *work)
 {
-	long pages_total, pages_left, pages_changed;
-	unsigned long migrate, next_scan, now = jiffies;
-	unsigned long start0, start, end;
 	struct task_struct *p = current;
-	struct mm_struct *mm = p->mm;
-	struct vm_area_struct *vma;
 
-	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
+	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_placement_work));
 
 	work->next = work; /* protect against double add */
+
 	/*
 	 * Who cares about NUMA placement when they're dying.
 	 *
@@ -1328,6 +1308,29 @@ void task_numa_work(struct callback_head *work)
 	if (p->flags & PF_EXITING)
 		return;
 
+	task_numa_placement_tick(p);
+}
+
+/*
+ * The expensive part of numa migration is done from task_work context.
+ * Triggered from task_tick_numa().
+ */
+void task_numa_scan_work(struct callback_head *work)
+{
+	long pages_total, pages_left, pages_changed;
+	unsigned long migrate, next_scan, now = jiffies;
+	unsigned long start0, start, end;
+	struct task_struct *p = current;
+	struct mm_struct *mm = p->mm;
+	struct vm_area_struct *vma;
+
+	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_scan_work));
+
+	work->next = work; /* protect against double add */
+
+	if (p->flags & PF_EXITING)
+		return;
+
 	/*
 	 * Enforce maximal scan/migration frequency..
 	 */
@@ -1383,15 +1386,12 @@ out:
 /*
  * Drive the periodic memory faults..
  */
-void task_tick_numa(struct rq *rq, struct task_struct *curr)
+static void task_tick_numa_scan(struct rq *rq, struct task_struct *curr)
 {
-	struct callback_head *work = &curr->numa_work;
+	struct callback_head *work = &curr->numa_scan_work;
 	u64 period, now;
 
-	/*
-	 * We don't care about NUMA placement if we don't have memory.
-	 */
-	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
+	if (work->next != work)
 		return;
 
 	/*
@@ -1403,28 +1403,67 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	now = curr->se.sum_exec_runtime;
 	period = (u64)curr->numa_scan_period * NSEC_PER_MSEC;
 
-	if (now - curr->node_stamp > period) {
-		curr->node_stamp += period;
-		curr->numa_scan_period = sysctl_sched_numa_scan_period_min;
+	if (now - curr->node_stamp <= period)
+		return;
 
-		/*
-		 * We are comparing runtime to wall clock time here, which
-		 * puts a maximum scan frequency limit on the task work.
-		 *
-		 * This, together with the limits in task_numa_work() filters
-		 * us from over-sampling if there are many threads: if all
-		 * threads happen to come in at the same time we don't create a
-		 * spike in overhead.
-		 *
-		 * We also avoid multiple threads scanning at once in parallel to
-		 * each other.
-		 */
-		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
-			init_task_work(work, task_numa_work); /* TODO: move this into sched_fork() */
-			task_work_add(curr, work, true);
-		}
-	}
+	curr->node_stamp += period;
+	curr->numa_scan_period = sysctl_sched_numa_scan_period_min;
+
+	/*
+	 * We are comparing runtime to wall clock time here, which
+	 * puts a maximum scan frequency limit on the task work.
+	 *
+	 * This, together with the limits in task_numa_work() filters
+	 * us from over-sampling if there are many threads: if all
+	 * threads happen to come in at the same time we don't create a
+	 * spike in overhead.
+	 *
+	 * We also avoid multiple threads scanning at once in parallel to
+	 * each other.
+	 */
+	if (time_before(jiffies, curr->mm->numa_next_scan))
+		return;
+
+	task_work_add(curr, work, true);
 }
+
+/*
+ * Drive the placement logic:
+ */
+static void task_tick_numa_placement(struct rq *rq, struct task_struct *curr)
+{
+	struct callback_head *work = &curr->numa_placement_work;
+	int seq;
+
+	if (work->next != work)
+		return;
+
+	/*
+	 * Check whether we should run task_numa_placement(),
+	 * and if yes, activate the worklet:
+	 */
+	seq = ACCESS_ONCE(curr->mm->numa_scan_seq);
+
+	if (curr->numa_scan_seq == seq)
+		return;
+
+	curr->numa_scan_seq = seq;
+	task_work_add(curr, work, true);
+}
+
+static void task_tick_numa(struct rq *rq, struct task_struct *curr)
+{
+	/*
+	 * We don't care about NUMA placement if we don't have memory
+	 * or are exiting:
+	 */
+	if (!curr->mm || (curr->flags & PF_EXITING))
+		return;
+
+	task_tick_numa_scan(rq, curr);
+	task_tick_numa_placement(rq, curr);
+}
+
 #else /* !CONFIG_NUMA_BALANCING: */
 #ifdef CONFIG_SMP
 static inline int task_ideal_cpu(struct task_struct *p)				{ return -1; }
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index c4d15fd..f46405e 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -1261,6 +1261,11 @@ static inline u64 irq_time_read(int cpu)
 #endif /* CONFIG_64BIT */
 #endif /* CONFIG_IRQ_TIME_ACCOUNTING */
 
+#ifdef CONFIG_NUMA_BALANCING
+extern void task_numa_scan_work(struct callback_head *work);
+extern void task_numa_placement_work(struct callback_head *work);
+#endif
+
 #ifdef CONFIG_SMP
 extern void sched_rebalance_to(int dest_cpu, int flip_tasks);
 #else
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
