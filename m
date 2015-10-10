Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7783182F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:44 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so42216406pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:44 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id te5si6495223pab.28.2015.10.09.18.02.43
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:43 -0700 (PDT)
Subject: [PATCH v2 18/20] block: notify queue death confirmation
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:57:00 -0400
Message-ID: <20151010005700.17221.88874.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, ross.zwisler@linux.intel.com, hch@lst.de, linux-kernel@vger.kernel.org

The pmem driver arranges for references to be taken against the queue
while pages it allocated via devm_memremap_pages() are in use.  At
shutdown time, before those pages can be deallocated, they need to be
truncated, unmapped, and guaranteed to be idle.  Scanning the pages to
initiate truncation can only be done once we are certain no new page
references will be taken.  Once the blk queue percpu_ref is confirmed
dead __get_dev_pagemap() will cease allowing new references and we can
reclaim these "device" pages.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 block/blk-core.c       |   12 +++++++++---
 block/blk-mq.c         |   19 +++++++++++++++----
 include/linux/blkdev.h |    4 +++-
 3 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 9b4d735cb5b8..74aaa208a8e9 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -516,6 +516,12 @@ void blk_set_queue_dying(struct request_queue *q)
 }
 EXPORT_SYMBOL_GPL(blk_set_queue_dying);
 
+void blk_wait_queue_dead(struct request_queue *q)
+{
+	wait_event(q->q_freeze_wq, q->q_usage_dead);
+}
+EXPORT_SYMBOL(blk_wait_queue_dead);
+
 /**
  * blk_cleanup_queue - shutdown a request queue
  * @q: request queue to shutdown
@@ -638,7 +644,7 @@ int blk_queue_enter(struct request_queue *q, gfp_t gfp)
 		if (!(gfp & __GFP_WAIT))
 			return -EBUSY;
 
-		ret = wait_event_interruptible(q->mq_freeze_wq,
+		ret = wait_event_interruptible(q->q_freeze_wq,
 				!atomic_read(&q->mq_freeze_depth) ||
 				blk_queue_dying(q));
 		if (blk_queue_dying(q))
@@ -658,7 +664,7 @@ static void blk_queue_usage_counter_release(struct percpu_ref *ref)
 	struct request_queue *q =
 		container_of(ref, struct request_queue, q_usage_counter);
 
-	wake_up_all(&q->mq_freeze_wq);
+	wake_up_all(&q->q_freeze_wq);
 }
 
 struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
@@ -720,7 +726,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->bypass_depth = 1;
 	__set_bit(QUEUE_FLAG_BYPASS, &q->queue_flags);
 
-	init_waitqueue_head(&q->mq_freeze_wq);
+	init_waitqueue_head(&q->q_freeze_wq);
 
 	/*
 	 * Init percpu_ref in atomic mode so that it's faster to shutdown.
diff --git a/block/blk-mq.c b/block/blk-mq.c
index c371aeda2986..d52f9d91f5c1 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -77,13 +77,23 @@ static void blk_mq_hctx_clear_pending(struct blk_mq_hw_ctx *hctx,
 	clear_bit(CTX_TO_BIT(hctx, ctx), &bm->word);
 }
 
+static void blk_confirm_queue_death(struct percpu_ref *ref)
+{
+	struct request_queue *q = container_of(ref, typeof(*q),
+			q_usage_counter);
+
+	q->q_usage_dead = 1;
+	wake_up_all(&q->q_freeze_wq);
+}
+
 void blk_mq_freeze_queue_start(struct request_queue *q)
 {
 	int freeze_depth;
 
 	freeze_depth = atomic_inc_return(&q->mq_freeze_depth);
 	if (freeze_depth == 1) {
-		percpu_ref_kill(&q->q_usage_counter);
+		percpu_ref_kill_and_confirm(&q->q_usage_counter,
+				blk_confirm_queue_death);
 		blk_mq_run_hw_queues(q, false);
 	}
 }
@@ -91,7 +101,7 @@ EXPORT_SYMBOL_GPL(blk_mq_freeze_queue_start);
 
 static void blk_mq_freeze_queue_wait(struct request_queue *q)
 {
-	wait_event(q->mq_freeze_wq, percpu_ref_is_zero(&q->q_usage_counter));
+	wait_event(q->q_freeze_wq, percpu_ref_is_zero(&q->q_usage_counter));
 }
 
 /*
@@ -129,7 +139,8 @@ void blk_mq_unfreeze_queue(struct request_queue *q)
 	WARN_ON_ONCE(freeze_depth < 0);
 	if (!freeze_depth) {
 		percpu_ref_reinit(&q->q_usage_counter);
-		wake_up_all(&q->mq_freeze_wq);
+		q->q_usage_dead = 0;
+		wake_up_all(&q->q_freeze_wq);
 	}
 }
 EXPORT_SYMBOL_GPL(blk_mq_unfreeze_queue);
@@ -148,7 +159,7 @@ void blk_mq_wake_waiters(struct request_queue *q)
 	 * dying, we need to ensure that processes currently waiting on
 	 * the queue are notified as well.
 	 */
-	wake_up_all(&q->mq_freeze_wq);
+	wake_up_all(&q->q_freeze_wq);
 }
 
 bool blk_mq_can_queue(struct blk_mq_hw_ctx *hctx)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index fb3e6886c479..a1340654e360 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -427,6 +427,7 @@ struct request_queue {
 	 */
 	unsigned int		flush_flags;
 	unsigned int		flush_not_queueable:1;
+	unsigned int		q_usage_dead:1;
 	struct blk_flush_queue	*fq;
 
 	struct list_head	requeue_list;
@@ -449,7 +450,7 @@ struct request_queue {
 	struct throtl_data *td;
 #endif
 	struct rcu_head		rcu_head;
-	wait_queue_head_t	mq_freeze_wq;
+	wait_queue_head_t	q_freeze_wq;
 	struct percpu_ref	q_usage_counter;
 	struct list_head	all_q_node;
 
@@ -949,6 +950,7 @@ extern struct request_queue *blk_init_queue_node(request_fn_proc *rfn,
 extern struct request_queue *blk_init_queue(request_fn_proc *, spinlock_t *);
 extern struct request_queue *blk_init_allocated_queue(struct request_queue *,
 						      request_fn_proc *, spinlock_t *);
+extern void blk_wait_queue_dead(struct request_queue *q);
 extern void blk_cleanup_queue(struct request_queue *);
 extern void blk_queue_make_request(struct request_queue *, make_request_fn *);
 extern void blk_queue_bounce_limit(struct request_queue *, u64);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
