Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 816936B0268
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:56:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so20504929pfk.13
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:56:36 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x185si1547143pgx.10.2017.10.25.01.56.33
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 01:56:34 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 8/9] workqueue: Remove unnecessary acquisitions wrt workqueue flush
Date: Wed, 25 Oct 2017 17:56:04 +0900
Message-Id: <1508921765-15396-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

The workqueue added manual acquisitions to catch deadlock cases.
Now crossrelease was introduced, some of those are redundant, since
wait_for_completion() already includes the acquisition for itself.
Remove it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/workqueue.h |  4 ++--
 kernel/workqueue.c        | 19 +++----------------
 2 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index f3c47a0..0544ad3 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -218,7 +218,7 @@ static inline void destroy_delayed_work_on_stack(struct delayed_work *work) { }
 									\
 		__init_work((_work), _onstack);				\
 		(_work)->data = (atomic_long_t) WORK_DATA_INIT();	\
-		lockdep_init_map(&(_work)->lockdep_map, #_work, &__key, 0); \
+		lockdep_init_map(&(_work)->lockdep_map, "(work_completion)"#_work, &__key, 0); \
 		INIT_LIST_HEAD(&(_work)->entry);			\
 		(_work)->func = (_func);				\
 	} while (0)
@@ -399,7 +399,7 @@ enum {
 	static struct lock_class_key __key;				\
 	const char *__lock_name;					\
 									\
-	__lock_name = #fmt#args;					\
+	__lock_name = "(wq_completion)"#fmt#args;			\
 									\
 	__alloc_workqueue_key((fmt), (flags), (max_active),		\
 			      &__key, __lock_name, ##args);		\
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index c77fdf6..ee05d19 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2496,15 +2496,8 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
 	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
 	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
 
-	/*
-	 * Explicitly init the crosslock for wq_barrier::done, make its lock
-	 * key a subkey of the corresponding work. As a result we won't
-	 * build a dependency between wq_barrier::done and unrelated work.
-	 */
-	lockdep_init_map_crosslock((struct lockdep_map *)&barr->done.map,
-				   "(complete)wq_barr::done",
-				   target->lockdep_map.key, 1);
-	__init_completion(&barr->done);
+	init_completion_map(&barr->done, &target->lockdep_map);
+
 	barr->task = current;
 
 	/*
@@ -2610,16 +2603,13 @@ void flush_workqueue(struct workqueue_struct *wq)
 	struct wq_flusher this_flusher = {
 		.list = LIST_HEAD_INIT(this_flusher.list),
 		.flush_color = -1,
-		.done = COMPLETION_INITIALIZER_ONSTACK(this_flusher.done),
+		.done = COMPLETION_INITIALIZER_ONSTACK_MAP(this_flusher.done, wq->lockdep_map),
 	};
 	int next_color;
 
 	if (WARN_ON(!wq_online))
 		return;
 
-	lock_map_acquire(&wq->lockdep_map);
-	lock_map_release(&wq->lockdep_map);
-
 	mutex_lock(&wq->mutex);
 
 	/*
@@ -2882,9 +2872,6 @@ bool flush_work(struct work_struct *work)
 	if (WARN_ON(!wq_online))
 		return false;
 
-	lock_map_acquire(&work->lockdep_map);
-	lock_map_release(&work->lockdep_map);
-
 	if (start_flush_work(work, &barr)) {
 		wait_for_completion(&barr.done);
 		destroy_work_on_stack(&barr.work);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
