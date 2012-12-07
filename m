Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 09D2A6B006E
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:41 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277755eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:40 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 2/9] numa, sched: Add tracking of runnable NUMA tasks
Date: Fri,  7 Dec 2012 01:19:19 +0100
Message-Id: <1354839566-15697-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

This is mostly taken from:

  sched: Add adaptive NUMA affinity support

  Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
  Date:   Sun Nov 11 15:09:59 2012 +0100

With some robustness changes to make sure we will dequeue
the same state we enqueued.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/init_task.h |  3 ++-
 include/linux/sched.h     |  2 ++
 kernel/sched/core.c       |  6 ++++++
 kernel/sched/fair.c       | 48 +++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/sched.h      |  3 +++
 5 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index ed98982..a5da0fc 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -145,7 +145,8 @@ extern struct task_group root_task_group;
 
 #ifdef CONFIG_NUMA_BALANCING
 # define INIT_TASK_NUMA(tsk)						\
-	.numa_shared = -1,
+	.numa_shared = -1,						\
+	.numa_shared_enqueue = -1
 #else
 # define INIT_TASK_NUMA(tsk)
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6a29dfd..ee39f6b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1504,6 +1504,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	int numa_shared;
+	int numa_shared_enqueue;
 	int numa_max_node;
 	int numa_scan_seq;
 	unsigned long numa_scan_ts_secs;
@@ -1511,6 +1512,7 @@ struct task_struct {
 	u64 node_stamp;			/* migration stamp  */
 	unsigned long convergence_strength;
 	int convergence_node;
+	unsigned long numa_weight;
 	unsigned long *numa_faults;
 	unsigned long *numa_faults_curr;
 	struct callback_head numa_scan_work;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index cce84c3..a7f0000 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1554,6 +1554,9 @@ static void __sched_fork(struct task_struct *p)
 	}
 
 	p->numa_shared = -1;
+	p->numa_weight = 0;
+	p->numa_shared_enqueue = -1;
+	p->numa_max_node = -1;
 	p->node_stamp = 0ULL;
 	p->convergence_strength		= 0;
 	p->convergence_node		= -1;
@@ -6103,6 +6106,9 @@ void __sched_setnuma(struct rq *rq, struct task_struct *p, int node, int shared)
 	if (running)
 		p->sched_class->put_prev_task(rq, p);
 
+	WARN_ON_ONCE(p->numa_shared_enqueue != -1);
+	WARN_ON_ONCE(p->numa_weight);
+
 	p->numa_shared = shared;
 	p->numa_max_node = node;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 0c83689..8cdbfde 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -801,6 +801,45 @@ static unsigned long task_h_load(struct task_struct *p);
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
+static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
+{
+	int shared = task_numa_shared(p);
+
+	WARN_ON_ONCE(p->numa_weight);
+
+	if (shared != -1) {
+		p->numa_weight = p->se.load.weight;
+		WARN_ON_ONCE(!p->numa_weight);
+		p->numa_shared_enqueue = shared;
+
+		rq->nr_numa_running++;
+		rq->nr_shared_running += shared;
+		rq->nr_ideal_running += (cpu_to_node(task_cpu(p)) == p->numa_max_node);
+		rq->numa_weight += p->numa_weight;
+	} else {
+		if (p->numa_weight) {
+			WARN_ON_ONCE(p->numa_weight);
+			p->numa_weight = 0;
+		}
+	}
+}
+
+static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
+{
+	if (p->numa_shared_enqueue != -1) {
+		rq->nr_numa_running--;
+		rq->nr_shared_running -= p->numa_shared_enqueue;
+		rq->nr_ideal_running -= (cpu_to_node(task_cpu(p)) == p->numa_max_node);
+		rq->numa_weight -= p->numa_weight;
+		p->numa_weight = 0;
+		p->numa_shared_enqueue = -1;
+	} else {
+		if (p->numa_weight) {
+			WARN_ON_ONCE(p->numa_weight);
+			p->numa_weight = 0;
+		}
+	}
+}
 
 /*
  * Scan @scan_size MB every @scan_period after an initial @scan_delay.
@@ -2551,8 +2590,11 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 #else /* !CONFIG_NUMA_BALANCING: */
 #ifdef CONFIG_SMP
 static inline int task_ideal_cpu(struct task_struct *p)				{ return -1; }
+static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)	{ }
 #endif
+static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)	{ }
 static inline void task_tick_numa(struct rq *rq, struct task_struct *curr)	{ }
+static inline void task_numa_migrate(struct task_struct *p, int next_cpu)	{ }
 #endif /* CONFIG_NUMA_BALANCING */
 
 /**************************************************
@@ -2569,6 +2611,7 @@ account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	if (entity_is_task(se)) {
 		struct rq *rq = rq_of(cfs_rq);
 
+		account_numa_enqueue(rq, task_of(se));
 		list_add(&se->group_node, &rq->cfs_tasks);
 	}
 #endif /* CONFIG_SMP */
@@ -2581,9 +2624,10 @@ account_entity_dequeue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 	update_load_sub(&cfs_rq->load, se->load.weight);
 	if (!parent_entity(se))
 		update_load_sub(&rq_of(cfs_rq)->load, se->load.weight);
-	if (entity_is_task(se))
+	if (entity_is_task(se)) {
 		list_del_init(&se->group_node);
-
+		account_numa_dequeue(rq_of(cfs_rq), task_of(se));
+	}
 	cfs_rq->nr_running--;
 }
 
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index f75bf06..f00eb80 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -438,6 +438,9 @@ struct rq {
 	struct list_head cfs_tasks;
 
 #ifdef CONFIG_NUMA_BALANCING
+	unsigned long numa_weight;
+	unsigned long nr_numa_running;
+	unsigned long nr_ideal_running;
 	struct task_struct *curr_buddy;
 #endif
 	unsigned long nr_shared_running;	/* 0 on non-NUMA */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
