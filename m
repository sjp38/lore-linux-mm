Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DAE128D0014
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:41 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:41 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 27/33] sched: Track groups of shared tasks
Date: Thu, 22 Nov 2012 23:49:48 +0100
Message-Id: <1353624594-1118-28-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

To be able to cluster memory-related tasks more efficiently, introduce
a new metric that tracks the 'best' buddy task

Track our "memory buddies": the tasks we actively share memory with.

Firstly we establish the identity of some other task that we are
sharing memory with by looking at rq[page::last_cpu].curr - i.e.
we check the task that is running on that CPU right now.

This is not entirely correct as this task might have scheduled or
migrate ther - but statistically there will be correlation to the
tasks that we share memory with, and correlation is all we need.

We map out the relation itself by filtering out the highest address
ask that is below our own task address, per working set scan
iteration.

This creates a natural ordering relation between groups of tasks:

    t1 < t2 < t3 < t4

    t1->memory_buddy == NULL
    t2->memory_buddy == t1
    t3->memory_buddy == t2
    t4->memory_buddy == t3

The load-balancer can then use this information to speed up NUMA
convergence, by moving such tasks together if capacity and load
constraints allow it.

(This is all statistical so there are no preemption or locking worries.)

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/sched.h |   5 ++
 kernel/sched/core.c   |   5 ++
 kernel/sched/fair.c   | 144 ++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 151 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 92b41b4..be73297 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1513,6 +1513,11 @@ struct task_struct {
 	unsigned long *numa_faults;
 	unsigned long *numa_faults_curr;
 	struct callback_head numa_work;
+
+	struct task_struct *shared_buddy, *shared_buddy_curr;
+	unsigned long shared_buddy_faults, shared_buddy_faults_curr;
+	int ideal_cpu, ideal_cpu_curr;
+
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index ec3cc74..39cf991 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1558,6 +1558,11 @@ static void __sched_fork(struct task_struct *p)
 	p->numa_faults = NULL;
 	p->numa_scan_period = sysctl_sched_numa_scan_delay;
 	p->numa_work.next = &p->numa_work;
+
+	p->shared_buddy = NULL;
+	p->shared_buddy_faults = 0;
+	p->ideal_cpu = -1;
+	p->ideal_cpu_curr = -1;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1ab11be..67f7fd2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -840,6 +840,43 @@ static void task_numa_migrate(struct task_struct *p, int next_cpu)
 	p->numa_migrate_seq = 0;
 }
 
+/*
+ * Called for every full scan - here we consider switching to a new
+ * shared buddy, if the one we found during this scan is good enough:
+ */
+static void shared_fault_full_scan_done(struct task_struct *p)
+{
+	/*
+	 * If we have a new maximum rate buddy task then pick it
+	 * as our new best friend:
+	 */
+	if (p->shared_buddy_faults_curr > p->shared_buddy_faults) {
+		WARN_ON_ONCE(!p->shared_buddy_curr);
+		p->shared_buddy			= p->shared_buddy_curr;
+		p->shared_buddy_faults		= p->shared_buddy_faults_curr;
+		p->ideal_cpu			= p->ideal_cpu_curr;
+
+		goto clear_buddy;
+	}
+	/*
+	 * If the new buddy is lower rate than the previous average
+	 * fault rate then don't switch buddies yet but lower the average by
+	 * averaging in the new rate, with a 1/3 weight.
+	 *
+	 * Eventually, if the current buddy is not a buddy anymore
+	 * then we'll switch away from it: a higher rate buddy will
+	 * replace it.
+	 */
+	p->shared_buddy_faults *= 3;
+	p->shared_buddy_faults += p->shared_buddy_faults_curr;
+	p->shared_buddy_faults /= 4;
+
+clear_buddy:
+	p->shared_buddy_curr		= NULL;
+	p->shared_buddy_faults_curr	= 0;
+	p->ideal_cpu_curr		= -1;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
@@ -852,6 +889,8 @@ static void task_numa_placement(struct task_struct *p)
 
 	p->numa_scan_seq = seq;
 
+	shared_fault_full_scan_done(p);
+
 	/*
 	 * Update the fault average with the result of the latest
 	 * scan:
@@ -906,23 +945,122 @@ out_backoff:
 }
 
 /*
+ * Track our "memory buddies" the tasks we actively share memory with.
+ *
+ * Firstly we establish the identity of some other task that we are
+ * sharing memory with by looking at rq[page::last_cpu].curr - i.e.
+ * we check the task that is running on that CPU right now.
+ *
+ * This is not entirely correct as this task might have scheduled or
+ * migrate ther - but statistically there will be correlation to the
+ * tasks that we share memory with, and correlation is all we need.
+ *
+ * We map out the relation itself by filtering out the highest address
+ * ask that is below our own task address, per working set scan
+ * iteration.
+ *
+ * This creates a natural ordering relation between groups of tasks:
+ *
+ *     t1 < t2 < t3 < t4
+ *
+ *     t1->memory_buddy == NULL
+ *     t2->memory_buddy == t1
+ *     t3->memory_buddy == t2
+ *     t4->memory_buddy == t3
+ *
+ * The load-balancer can then use this information to speed up NUMA
+ * convergence, by moving such tasks together if capacity and load
+ * constraints allow it.
+ *
+ * (This is all statistical so there are no preemption or locking worries.)
+ */
+static void shared_fault_tick(struct task_struct *this_task, int node, int last_cpu, int pages)
+{
+	struct task_struct *last_task;
+	struct rq *last_rq;
+	int last_node;
+	int this_node;
+	int this_cpu;
+
+	last_node = cpu_to_node(last_cpu);
+	this_cpu  = raw_smp_processor_id();
+	this_node = cpu_to_node(this_cpu);
+
+	/* Ignore private memory access faults: */
+	if (last_cpu == this_cpu)
+		return;
+
+	/*
+	 * Ignore accesses from foreign nodes to our memory.
+	 *
+	 * Yet still recognize tasks accessing a third node - i.e. one that is
+	 * remote to both of them.
+	 */
+	if (node != this_node)
+		return;
+
+	/* We are in a shared fault - see which task we relate to: */
+	last_rq = cpu_rq(last_cpu);
+	last_task = last_rq->curr;
+
+	/* Task might be gone from that runqueue already: */
+	if (!last_task || last_task == last_rq->idle)
+		return;
+
+	if (last_task == this_task->shared_buddy_curr)
+		goto out_hit;
+
+	/* Order our memory buddies by address: */
+	if (last_task >= this_task)
+		return;
+
+	if (this_task->shared_buddy_curr > last_task)
+		return;
+
+	/* New shared buddy! */
+	this_task->shared_buddy_curr = last_task;
+	this_task->shared_buddy_faults_curr = 0;
+	this_task->ideal_cpu_curr = last_rq->cpu;
+
+out_hit:
+	/*
+	 * Give threads that we share a process with an advantage,
+	 * but don't stop the discovery of process level sharing
+	 * either:
+	 */
+	if (this_task->mm == last_task->mm)
+		pages *= 2;
+
+	this_task->shared_buddy_faults_curr += pages;
+}
+
+/*
  * Got a PROT_NONE fault for a page on @node.
  */
 void task_numa_fault(int node, int last_cpu, int pages)
 {
 	struct task_struct *p = current;
 	int priv = (task_cpu(p) == last_cpu);
+	int idx = 2*node + priv;
 
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
+		int entries = 2*nr_node_ids;
+		int size = sizeof(*p->numa_faults) * entries;
 
-		p->numa_faults = kzalloc(size, GFP_KERNEL);
+		p->numa_faults = kzalloc(2*size, GFP_KERNEL);
 		if (!p->numa_faults)
 			return;
+		/*
+		 * For efficiency reasons we allocate ->numa_faults[]
+		 * and ->numa_faults_curr[] at once and split the
+		 * buffer we get. They are separate otherwise.
+		 */
+		p->numa_faults_curr = p->numa_faults + entries;
 	}
 
+	p->numa_faults_curr[idx] += pages;
+	shared_fault_tick(p, node, last_cpu, pages);
 	task_numa_placement(p);
-	p->numa_faults[2*node + priv] += pages;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
