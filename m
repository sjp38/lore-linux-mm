Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 21BB96B0069
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:19 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so397032bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:19 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 4/7] workqueue: use new hashtable implementation
Date: Fri,  3 Aug 2012 16:23:05 +0200
Message-Id: <1344003788-1417-5-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Switch workqueues to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the workqueues.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/workqueue.c |   93 ++++++++--------------------------------------------
 1 files changed, 14 insertions(+), 79 deletions(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 692d976..480975d 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -41,6 +41,7 @@
 #include <linux/debug_locks.h>
 #include <linux/lockdep.h>
 #include <linux/idr.h>
+#include <linux/hashtable.h>
 
 #include "workqueue_sched.h"
 
@@ -82,8 +83,6 @@ enum {
 	NR_WORKER_POOLS		= 2,		/* # worker pools per gcwq */
 
 	BUSY_WORKER_HASH_ORDER	= 6,		/* 64 pointers */
-	BUSY_WORKER_HASH_SIZE	= 1 << BUSY_WORKER_HASH_ORDER,
-	BUSY_WORKER_HASH_MASK	= BUSY_WORKER_HASH_SIZE - 1,
 
 	MAX_IDLE_WORKERS_RATIO	= 4,		/* 1/4 of busy can be idle */
 	IDLE_WORKER_TIMEOUT	= 300 * HZ,	/* keep idle ones for 5 mins */
@@ -102,6 +101,8 @@ enum {
 	HIGHPRI_NICE_LEVEL	= -20,
 };
 
+#define worker_hash_cmp(obj, key) ((obj)->current_work == (key))
+
 /*
  * Structure fields follow one of the following exclusion rules.
  *
@@ -180,7 +181,7 @@ struct global_cwq {
 	unsigned int		flags;		/* L: GCWQ_* flags */
 
 	/* workers are chained either in busy_hash or pool idle_list */
-	struct hlist_head	busy_hash[BUSY_WORKER_HASH_SIZE];
+	DEFINE_HASHTABLE(busy_hash, BUSY_WORKER_HASH_ORDER);
 						/* L: hash of busy workers */
 
 	struct worker_pool	pools[2];	/* normal and highpri pools */
@@ -287,10 +288,6 @@ EXPORT_SYMBOL_GPL(system_nrt_freezable_wq);
 	for ((pool) = &(gcwq)->pools[0];				\
 	     (pool) < &(gcwq)->pools[NR_WORKER_POOLS]; (pool)++)
 
-#define for_each_busy_worker(worker, i, pos, gcwq)			\
-	for (i = 0; i < BUSY_WORKER_HASH_SIZE; i++)			\
-		hlist_for_each_entry(worker, pos, &gcwq->busy_hash[i], hentry)
-
 static inline int __next_gcwq_cpu(int cpu, const struct cpumask *mask,
 				  unsigned int sw)
 {
@@ -822,70 +819,11 @@ static inline void worker_clr_flags(struct worker *worker, unsigned int flags)
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
  *
- * Find a worker which is executing @work on @gcwq.  This function is
- * identical to __find_worker_executing_work() except that this
- * function calculates @bwh itself.
+ * Find a worker which is executing @work on @gcwq.
  *
  * CONTEXT:
  * spin_lock_irq(gcwq->lock).
@@ -897,8 +835,8 @@ static struct worker *__find_worker_executing_work(struct global_cwq *gcwq,
 static struct worker *find_worker_executing_work(struct global_cwq *gcwq,
 						 struct work_struct *work)
 {
-	return __find_worker_executing_work(gcwq, busy_worker_head(gcwq, work),
-					    work);
+	return hash_get(&gcwq->busy_hash, work, struct worker,
+		hentry, worker_hash_cmp);
 }
 
 /**
@@ -959,7 +897,7 @@ static bool is_chained_work(struct workqueue_struct *wq)
 		int i;
 
 		spin_lock_irqsave(&gcwq->lock, flags);
-		for_each_busy_worker(worker, i, pos, gcwq) {
+		hash_for_each(i, pos, &gcwq->busy_hash, worker, hentry) {
 			if (worker->task != current)
 				continue;
 			spin_unlock_irqrestore(&gcwq->lock, flags);
@@ -1432,7 +1370,7 @@ retry:
 	wake_up_all(&gcwq->rebind_hold);
 
 	/* rebind busy workers */
-	for_each_busy_worker(worker, i, pos, gcwq) {
+	hash_for_each(i, pos, &gcwq->busy_hash, worker, hentry) {
 		struct work_struct *rebind_work = &worker->rebind_work;
 
 		/* morph UNBOUND to REBIND */
@@ -1932,7 +1870,6 @@ __acquires(&gcwq->lock)
 	struct cpu_workqueue_struct *cwq = get_work_cwq(work);
 	struct worker_pool *pool = worker->pool;
 	struct global_cwq *gcwq = pool->gcwq;
-	struct hlist_head *bwh = busy_worker_head(gcwq, work);
 	bool cpu_intensive = cwq->wq->flags & WQ_CPU_INTENSIVE;
 	work_func_t f = work->func;
 	int work_color;
@@ -1964,7 +1901,7 @@ __acquires(&gcwq->lock)
 	 * already processing the work.  If so, defer the work to the
 	 * currently executing one.
 	 */
-	collision = __find_worker_executing_work(gcwq, bwh, work);
+	collision = find_worker_executing_work(gcwq, work);
 	if (unlikely(collision)) {
 		move_linked_works(work, &collision->scheduled, NULL);
 		return;
@@ -1972,7 +1909,7 @@ __acquires(&gcwq->lock)
 
 	/* claim and process */
 	debug_work_deactivate(work);
-	hlist_add_head(&worker->hentry, bwh);
+	hash_add(&gcwq->busy_hash, &worker->hentry, (long)work);
 	worker->current_work = work;
 	worker->current_cwq = cwq;
 	work_color = get_work_color(work);
@@ -2027,7 +1964,7 @@ __acquires(&gcwq->lock)
 		worker_clr_flags(worker, WORKER_CPU_INTENSIVE);
 
 	/* we're done with it, release */
-	hlist_del_init(&worker->hentry);
+	hash_del(&worker->hentry);
 	worker->current_work = NULL;
 	worker->current_cwq = NULL;
 	cwq_dec_nr_in_flight(cwq, work_color, false);
@@ -3405,7 +3342,7 @@ static void gcwq_unbind_fn(struct work_struct *work)
 		list_for_each_entry(worker, &pool->idle_list, entry)
 			worker->flags |= WORKER_UNBOUND;
 
-	for_each_busy_worker(worker, i, pos, gcwq)
+	hash_for_each(i, pos, &gcwq->busy_hash, worker, hentry)
 		worker->flags |= WORKER_UNBOUND;
 
 	gcwq->flags |= GCWQ_DISASSOCIATED;
@@ -3690,7 +3627,6 @@ out_unlock:
 static int __init init_workqueues(void)
 {
 	unsigned int cpu;
-	int i;
 
 	cpu_notifier(workqueue_cpu_up_callback, CPU_PRI_WORKQUEUE_UP);
 	cpu_notifier(workqueue_cpu_down_callback, CPU_PRI_WORKQUEUE_DOWN);
@@ -3704,8 +3640,7 @@ static int __init init_workqueues(void)
 		gcwq->cpu = cpu;
 		gcwq->flags |= GCWQ_DISASSOCIATED;
 
-		for (i = 0; i < BUSY_WORKER_HASH_SIZE; i++)
-			INIT_HLIST_HEAD(&gcwq->busy_hash[i]);
+		hash_init(&gcwq->busy_hash, BUSY_WORKER_HASH_ORDER);
 
 		for_each_worker_pool(pool, gcwq) {
 			pool->gcwq = gcwq;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
