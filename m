Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DAD126B00B0
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:05:09 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so4023151bkc.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:05:09 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC 4/4] workqueue: use new hashtable implementation
Date: Tue, 31 Jul 2012 20:05:20 +0200
Message-Id: <1343757920-19713-5-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, Sasha Levin <levinsasha928@gmail.com>

Switch workqueues to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the workqueues.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/workqueue.c |   91 ++++++++--------------------------------------------
 1 files changed, 14 insertions(+), 77 deletions(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5abf42f..8a9f232 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -41,6 +41,7 @@
 #include <linux/debug_locks.h>
 #include <linux/lockdep.h>
 #include <linux/idr.h>
+#include <linux/hashtable.h>
 
 #include "workqueue_sched.h"
 
@@ -73,8 +74,6 @@ enum {
 	TRUSTEE_DONE		= 4,		/* trustee is done */
 
 	BUSY_WORKER_HASH_ORDER	= 6,		/* 64 pointers */
-	BUSY_WORKER_HASH_SIZE	= 1 << BUSY_WORKER_HASH_ORDER,
-	BUSY_WORKER_HASH_MASK	= BUSY_WORKER_HASH_SIZE - 1,
 
 	MAX_IDLE_WORKERS_RATIO	= 4,		/* 1/4 of busy can be idle */
 	IDLE_WORKER_TIMEOUT	= 300 * HZ,	/* keep idle ones for 5 mins */
@@ -139,6 +138,8 @@ struct worker {
 	struct work_struct	rebind_work;	/* L: rebind worker to cpu */
 };
 
+#define worker_hash_cmp(obj, key) ((obj)->current_work == (key))
+
 /*
  * Global per-cpu workqueue.  There's one and only one for each cpu
  * and all works are queued and processed here regardless of their
@@ -155,7 +156,7 @@ struct global_cwq {
 
 	/* workers are chained either in the idle_list or busy_hash */
 	struct list_head	idle_list;	/* X: list of idle workers */
-	struct hlist_head	busy_hash[BUSY_WORKER_HASH_SIZE];
+	DEFINE_HASHTABLE(busy_hash, BUSY_WORKER_HASH_ORDER);
 						/* L: hash of busy workers */
 
 	struct timer_list	idle_timer;	/* L: worker idle timeout */
@@ -264,10 +265,6 @@ EXPORT_SYMBOL_GPL(system_nrt_freezable_wq);
 #define CREATE_TRACE_POINTS
 #include <trace/events/workqueue.h>
 
-#define for_each_busy_worker(worker, i, pos, gcwq)			\
-	for (i = 0; i < BUSY_WORKER_HASH_SIZE; i++)			\
-		hlist_for_each_entry(worker, pos, &gcwq->busy_hash[i], hentry)
-
 static inline int __next_gcwq_cpu(int cpu, const struct cpumask *mask,
 				  unsigned int sw)
 {
@@ -787,63 +784,6 @@ static inline void worker_clr_flags(struct worker *worker, unsigned int flags)
 }
 
 /**
- * busy_worker_head - return the busy hash head for a work
- * @gcwq: gcwq of interest
- * @work: work to be hashed
- *
- * Return hash head of @gcwq for @work.
- *
- * CONTEXT:
- * spin_lock_irq(gcwq->lock).
- *
- * RETURNS:
- * Pointer to the hash head.
- */
-static struct hlist_head *busy_worker_head(struct global_cwq *gcwq,
-					   struct work_struct *work)
-{
-	const int base_shift = ilog2(sizeof(struct work_struct));
-	unsigned long v = (unsigned long)work;
-
-	/* simple shift and fold hash, do we need something better? */
-	v >>= base_shift;
-	v += v >> BUSY_WORKER_HASH_ORDER;
-	v &= BUSY_WORKER_HASH_MASK;
-
-	return &gcwq->busy_hash[v];
-}
-
-/**
- * __find_worker_executing_work - find worker which is executing a work
- * @gcwq: gcwq of interest
- * @bwh: hash head as returned by busy_worker_head()
- * @work: work to find worker for
- *
- * Find a worker which is executing @work on @gcwq.  @bwh should be
- * the hash head obtained by calling busy_worker_head() with the same
- * work.
- *
- * CONTEXT:
- * spin_lock_irq(gcwq->lock).
- *
- * RETURNS:
- * Pointer to worker which is executing @work if found, NULL
- * otherwise.
- */
-static struct worker *__find_worker_executing_work(struct global_cwq *gcwq,
-						   struct hlist_head *bwh,
-						   struct work_struct *work)
-{
-	struct worker *worker;
-	struct hlist_node *tmp;
-
-	hlist_for_each_entry(worker, tmp, bwh, hentry)
-		if (worker->current_work == work)
-			return worker;
-	return NULL;
-}
-
-/**
  * find_worker_executing_work - find worker which is executing a work
  * @gcwq: gcwq of interest
  * @work: work to find worker for
@@ -862,8 +802,8 @@ static struct worker *__find_worker_executing_work(struct global_cwq *gcwq,
 static struct worker *find_worker_executing_work(struct global_cwq *gcwq,
 						 struct work_struct *work)
 {
-	return __find_worker_executing_work(gcwq, busy_worker_head(gcwq, work),
-					    work);
+	return HASH_GET(gcwq->busy_hash, work, struct worker,
+			hentry, worker_hash_cmp);
 }
 
 /**
@@ -953,7 +893,7 @@ static bool is_chained_work(struct workqueue_struct *wq)
 {
 	unsigned long flags;
 	unsigned int cpu;
-
+	
 	for_each_gcwq_cpu(cpu) {
 		struct global_cwq *gcwq = get_gcwq(cpu);
 		struct worker *worker;
@@ -961,7 +901,7 @@ static bool is_chained_work(struct workqueue_struct *wq)
 		int i;
 
 		spin_lock_irqsave(&gcwq->lock, flags);
-		for_each_busy_worker(worker, i, pos, gcwq) {
+		HASH_FOR_EACH(i, pos, gcwq->busy_hash, worker, hentry) {
 			if (worker->task != current)
 				continue;
 			spin_unlock_irqrestore(&gcwq->lock, flags);
@@ -1797,7 +1737,6 @@ __acquires(&gcwq->lock)
 {
 	struct cpu_workqueue_struct *cwq = get_work_cwq(work);
 	struct global_cwq *gcwq = cwq->gcwq;
-	struct hlist_head *bwh = busy_worker_head(gcwq, work);
 	bool cpu_intensive = cwq->wq->flags & WQ_CPU_INTENSIVE;
 	work_func_t f = work->func;
 	int work_color;
@@ -1818,7 +1757,7 @@ __acquires(&gcwq->lock)
 	 * already processing the work.  If so, defer the work to the
 	 * currently executing one.
 	 */
-	collision = __find_worker_executing_work(gcwq, bwh, work);
+	collision = find_worker_executing_work(gcwq, work);
 	if (unlikely(collision)) {
 		move_linked_works(work, &collision->scheduled, NULL);
 		return;
@@ -1826,7 +1765,7 @@ __acquires(&gcwq->lock)
 
 	/* claim and process */
 	debug_work_deactivate(work);
-	hlist_add_head(&worker->hentry, bwh);
+	HASH_ADD(gcwq->busy_hash, &worker->hentry, work);
 	worker->current_work = work;
 	worker->current_cwq = cwq;
 	work_color = get_work_color(work);
@@ -1889,7 +1828,7 @@ __acquires(&gcwq->lock)
 		worker_clr_flags(worker, WORKER_CPU_INTENSIVE);
 
 	/* we're done with it, release */
-	hlist_del_init(&worker->hentry);
+	HASH_DEL(worker, hentry);
 	worker->current_work = NULL;
 	worker->current_cwq = NULL;
 	cwq_dec_nr_in_flight(cwq, work_color, false);
@@ -3330,7 +3269,7 @@ static int __cpuinit trustee_thread(void *__gcwq)
 	list_for_each_entry(worker, &gcwq->idle_list, entry)
 		worker->flags |= WORKER_ROGUE;
 
-	for_each_busy_worker(worker, i, pos, gcwq)
+	HASH_FOR_EACH(i, pos, gcwq->busy_hash, worker, hentry)
 		worker->flags |= WORKER_ROGUE;
 
 	/*
@@ -3426,7 +3365,7 @@ static int __cpuinit trustee_thread(void *__gcwq)
 	 */
 	WARN_ON(!list_empty(&gcwq->idle_list));
 
-	for_each_busy_worker(worker, i, pos, gcwq) {
+	HASH_FOR_EACH(i, pos, gcwq->busy_hash, worker, hentry) {
 		struct work_struct *rebind_work = &worker->rebind_work;
 
 		/*
@@ -3768,7 +3707,6 @@ out_unlock:
 static int __init init_workqueues(void)
 {
 	unsigned int cpu;
-	int i;
 
 	cpu_notifier(workqueue_cpu_callback, CPU_PRI_WORKQUEUE);
 
@@ -3782,8 +3720,7 @@ static int __init init_workqueues(void)
 		gcwq->flags |= GCWQ_DISASSOCIATED;
 
 		INIT_LIST_HEAD(&gcwq->idle_list);
-		for (i = 0; i < BUSY_WORKER_HASH_SIZE; i++)
-			INIT_HLIST_HEAD(&gcwq->busy_hash[i]);
+		HASH_INIT(gcwq->busy_hash);
 
 		init_timer_deferrable(&gcwq->idle_timer);
 		gcwq->idle_timer.function = idle_worker_timeout;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
