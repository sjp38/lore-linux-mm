Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 43EB36B0254
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:12 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so100736731pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wf3si6420263pab.166.2015.10.09.18.01.11
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:11 -0700 (PDT)
Subject: [PATCH v2 01/20] block: generic request_queue reference counting
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:28 -0400
Message-ID: <20151010005528.17221.4466.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, ross.zwisler@linux.intel.com, hch@lst.de

Allow pmem, and other synchronous/bio-based block drivers, to fallback
on a per-cpu reference count managed by the core for tracking queue
live/dead state.

The existing per-cpu reference count for the blk_mq case is promoted to
be used in all block i/o scenarios.  This involves initializing it by
default, waiting for it to drop to zero at exit, and holding a live
reference over the invocation of q->make_request_fn() in
generic_make_request().  The blk_mq code continues to take its own
reference per blk_mq request and retains the ability to freeze the
queue, but the check that the queue is frozen is moved to
generic_make_request().

This fixes crash signatures like the following:

 BUG: unable to handle kernel paging request at ffff880140000000
 [..]
 Call Trace:
  [<ffffffff8145e8bf>] ? copy_user_handle_tail+0x5f/0x70
  [<ffffffffa004e1e0>] pmem_do_bvec.isra.11+0x70/0xf0 [nd_pmem]
  [<ffffffffa004e331>] pmem_make_request+0xd1/0x200 [nd_pmem]
  [<ffffffff811c3162>] ? mempool_alloc+0x72/0x1a0
  [<ffffffff8141f8b6>] generic_make_request+0xd6/0x110
  [<ffffffff8141f966>] submit_bio+0x76/0x170
  [<ffffffff81286dff>] submit_bh_wbc+0x12f/0x160
  [<ffffffff81286e62>] submit_bh+0x12/0x20
  [<ffffffff813395bd>] jbd2_write_superblock+0x8d/0x170
  [<ffffffff8133974d>] jbd2_mark_journal_empty+0x5d/0x90
  [<ffffffff813399cb>] jbd2_journal_destroy+0x24b/0x270
  [<ffffffff810bc4ca>] ? put_pwq_unlocked+0x2a/0x30
  [<ffffffff810bc6f5>] ? destroy_workqueue+0x225/0x250
  [<ffffffff81303494>] ext4_put_super+0x64/0x360
  [<ffffffff8124ab1a>] generic_shutdown_super+0x6a/0xf0

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 block/blk-core.c       |   71 +++++++++++++++++++++++++++++++++++++------
 block/blk-mq-sysfs.c   |    6 ----
 block/blk-mq.c         |   80 ++++++++++++++----------------------------------
 block/blk-sysfs.c      |    3 +-
 block/blk.h            |   14 ++++++++
 include/linux/blk-mq.h |    1 -
 include/linux/blkdev.h |    2 +
 7 files changed, 102 insertions(+), 75 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 2eb722d48773..9b4d735cb5b8 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -554,13 +554,10 @@ void blk_cleanup_queue(struct request_queue *q)
 	 * Drain all requests queued before DYING marking. Set DEAD flag to
 	 * prevent that q->request_fn() gets invoked after draining finished.
 	 */
-	if (q->mq_ops) {
-		blk_mq_freeze_queue(q);
-		spin_lock_irq(lock);
-	} else {
-		spin_lock_irq(lock);
+	blk_freeze_queue(q);
+	spin_lock_irq(lock);
+	if (!q->mq_ops)
 		__blk_drain_queue(q, true);
-	}
 	queue_flag_set(QUEUE_FLAG_DEAD, q);
 	spin_unlock_irq(lock);
 
@@ -570,6 +567,7 @@ void blk_cleanup_queue(struct request_queue *q)
 
 	if (q->mq_ops)
 		blk_mq_free_queue(q);
+	percpu_ref_exit(&q->q_usage_counter);
 
 	spin_lock_irq(lock);
 	if (q->queue_lock != &q->__queue_lock)
@@ -629,6 +627,40 @@ struct request_queue *blk_alloc_queue(gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(blk_alloc_queue);
 
+int blk_queue_enter(struct request_queue *q, gfp_t gfp)
+{
+	while (true) {
+		int ret;
+
+		if (percpu_ref_tryget_live(&q->q_usage_counter))
+			return 0;
+
+		if (!(gfp & __GFP_WAIT))
+			return -EBUSY;
+
+		ret = wait_event_interruptible(q->mq_freeze_wq,
+				!atomic_read(&q->mq_freeze_depth) ||
+				blk_queue_dying(q));
+		if (blk_queue_dying(q))
+			return -ENODEV;
+		if (ret)
+			return ret;
+	}
+}
+
+void blk_queue_exit(struct request_queue *q)
+{
+	percpu_ref_put(&q->q_usage_counter);
+}
+
+static void blk_queue_usage_counter_release(struct percpu_ref *ref)
+{
+	struct request_queue *q =
+		container_of(ref, struct request_queue, q_usage_counter);
+
+	wake_up_all(&q->mq_freeze_wq);
+}
+
 struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 {
 	struct request_queue *q;
@@ -690,11 +722,22 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 
 	init_waitqueue_head(&q->mq_freeze_wq);
 
-	if (blkcg_init_queue(q))
+	/*
+	 * Init percpu_ref in atomic mode so that it's faster to shutdown.
+	 * See blk_register_queue() for details.
+	 */
+	if (percpu_ref_init(&q->q_usage_counter,
+				blk_queue_usage_counter_release,
+				PERCPU_REF_INIT_ATOMIC, GFP_KERNEL))
 		goto fail_bdi;
 
+	if (blkcg_init_queue(q))
+		goto fail_ref;
+
 	return q;
 
+fail_ref:
+	percpu_ref_exit(&q->q_usage_counter);
 fail_bdi:
 	bdi_destroy(&q->backing_dev_info);
 fail_split:
@@ -1966,9 +2009,19 @@ void generic_make_request(struct bio *bio)
 	do {
 		struct request_queue *q = bdev_get_queue(bio->bi_bdev);
 
-		q->make_request_fn(q, bio);
+		if (likely(blk_queue_enter(q, __GFP_WAIT) == 0)) {
+
+			q->make_request_fn(q, bio);
+
+			blk_queue_exit(q);
 
-		bio = bio_list_pop(current->bio_list);
+			bio = bio_list_pop(current->bio_list);
+		} else {
+			struct bio *bio_next = bio_list_pop(current->bio_list);
+
+			bio_io_error(bio);
+			bio = bio_next;
+		}
 	} while (bio);
 	current->bio_list = NULL; /* deactivate */
 }
diff --git a/block/blk-mq-sysfs.c b/block/blk-mq-sysfs.c
index 788fffd9b409..6f57a110289c 100644
--- a/block/blk-mq-sysfs.c
+++ b/block/blk-mq-sysfs.c
@@ -413,12 +413,6 @@ static void blk_mq_sysfs_init(struct request_queue *q)
 		kobject_init(&ctx->kobj, &blk_mq_ctx_ktype);
 }
 
-/* see blk_register_queue() */
-void blk_mq_finish_init(struct request_queue *q)
-{
-	percpu_ref_switch_to_percpu(&q->mq_usage_counter);
-}
-
 int blk_mq_register_disk(struct gendisk *disk)
 {
 	struct device *dev = disk_to_dev(disk);
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 7785ae96267a..c371aeda2986 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -77,47 +77,13 @@ static void blk_mq_hctx_clear_pending(struct blk_mq_hw_ctx *hctx,
 	clear_bit(CTX_TO_BIT(hctx, ctx), &bm->word);
 }
 
-static int blk_mq_queue_enter(struct request_queue *q, gfp_t gfp)
-{
-	while (true) {
-		int ret;
-
-		if (percpu_ref_tryget_live(&q->mq_usage_counter))
-			return 0;
-
-		if (!(gfp & __GFP_WAIT))
-			return -EBUSY;
-
-		ret = wait_event_interruptible(q->mq_freeze_wq,
-				!atomic_read(&q->mq_freeze_depth) ||
-				blk_queue_dying(q));
-		if (blk_queue_dying(q))
-			return -ENODEV;
-		if (ret)
-			return ret;
-	}
-}
-
-static void blk_mq_queue_exit(struct request_queue *q)
-{
-	percpu_ref_put(&q->mq_usage_counter);
-}
-
-static void blk_mq_usage_counter_release(struct percpu_ref *ref)
-{
-	struct request_queue *q =
-		container_of(ref, struct request_queue, mq_usage_counter);
-
-	wake_up_all(&q->mq_freeze_wq);
-}
-
 void blk_mq_freeze_queue_start(struct request_queue *q)
 {
 	int freeze_depth;
 
 	freeze_depth = atomic_inc_return(&q->mq_freeze_depth);
 	if (freeze_depth == 1) {
-		percpu_ref_kill(&q->mq_usage_counter);
+		percpu_ref_kill(&q->q_usage_counter);
 		blk_mq_run_hw_queues(q, false);
 	}
 }
@@ -125,18 +91,34 @@ EXPORT_SYMBOL_GPL(blk_mq_freeze_queue_start);
 
 static void blk_mq_freeze_queue_wait(struct request_queue *q)
 {
-	wait_event(q->mq_freeze_wq, percpu_ref_is_zero(&q->mq_usage_counter));
+	wait_event(q->mq_freeze_wq, percpu_ref_is_zero(&q->q_usage_counter));
 }
 
 /*
  * Guarantee no request is in use, so we can change any data structure of
  * the queue afterward.
  */
-void blk_mq_freeze_queue(struct request_queue *q)
+void blk_freeze_queue(struct request_queue *q)
 {
+	/*
+	 * In the !blk_mq case we are only calling this to kill the
+	 * q_usage_counter, otherwise this increases the freeze depth
+	 * and waits for it to return to zero.  For this reason there is
+	 * no blk_unfreeze_queue(), and blk_freeze_queue() is not
+	 * exported to drivers as the only user for unfreeze is blk_mq.
+	 */
 	blk_mq_freeze_queue_start(q);
 	blk_mq_freeze_queue_wait(q);
 }
+
+void blk_mq_freeze_queue(struct request_queue *q)
+{
+	/*
+	 * ...just an alias to keep freeze and unfreeze actions balanced
+	 * in the blk_mq_* namespace
+	 */
+	blk_freeze_queue(q);
+}
 EXPORT_SYMBOL_GPL(blk_mq_freeze_queue);
 
 void blk_mq_unfreeze_queue(struct request_queue *q)
@@ -146,7 +128,7 @@ void blk_mq_unfreeze_queue(struct request_queue *q)
 	freeze_depth = atomic_dec_return(&q->mq_freeze_depth);
 	WARN_ON_ONCE(freeze_depth < 0);
 	if (!freeze_depth) {
-		percpu_ref_reinit(&q->mq_usage_counter);
+		percpu_ref_reinit(&q->q_usage_counter);
 		wake_up_all(&q->mq_freeze_wq);
 	}
 }
@@ -255,7 +237,7 @@ struct request *blk_mq_alloc_request(struct request_queue *q, int rw, gfp_t gfp,
 	struct blk_mq_alloc_data alloc_data;
 	int ret;
 
-	ret = blk_mq_queue_enter(q, gfp);
+	ret = blk_queue_enter(q, gfp);
 	if (ret)
 		return ERR_PTR(ret);
 
@@ -278,7 +260,7 @@ struct request *blk_mq_alloc_request(struct request_queue *q, int rw, gfp_t gfp,
 	}
 	blk_mq_put_ctx(ctx);
 	if (!rq) {
-		blk_mq_queue_exit(q);
+		blk_queue_exit(q);
 		return ERR_PTR(-EWOULDBLOCK);
 	}
 	return rq;
@@ -297,7 +279,7 @@ static void __blk_mq_free_request(struct blk_mq_hw_ctx *hctx,
 
 	clear_bit(REQ_ATOM_STARTED, &rq->atomic_flags);
 	blk_mq_put_tag(hctx, tag, &ctx->last_tag);
-	blk_mq_queue_exit(q);
+	blk_queue_exit(q);
 }
 
 void blk_mq_free_hctx_request(struct blk_mq_hw_ctx *hctx, struct request *rq)
@@ -1176,11 +1158,7 @@ static struct request *blk_mq_map_request(struct request_queue *q,
 	int rw = bio_data_dir(bio);
 	struct blk_mq_alloc_data alloc_data;
 
-	if (unlikely(blk_mq_queue_enter(q, GFP_KERNEL))) {
-		bio_io_error(bio);
-		return NULL;
-	}
-
+	blk_queue_enter_live(q);
 	ctx = blk_mq_get_ctx(q);
 	hctx = q->mq_ops->map_queue(q, ctx->cpu);
 
@@ -1989,14 +1967,6 @@ struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 		hctxs[i]->queue_num = i;
 	}
 
-	/*
-	 * Init percpu_ref in atomic mode so that it's faster to shutdown.
-	 * See blk_register_queue() for details.
-	 */
-	if (percpu_ref_init(&q->mq_usage_counter, blk_mq_usage_counter_release,
-			    PERCPU_REF_INIT_ATOMIC, GFP_KERNEL))
-		goto err_hctxs;
-
 	setup_timer(&q->timeout, blk_mq_rq_timer, (unsigned long) q);
 	blk_queue_rq_timeout(q, set->timeout ? set->timeout : 30 * HZ);
 
@@ -2077,8 +2047,6 @@ void blk_mq_free_queue(struct request_queue *q)
 
 	blk_mq_exit_hw_queues(q, set, set->nr_hw_queues);
 	blk_mq_free_hw_queues(q, set);
-
-	percpu_ref_exit(&q->mq_usage_counter);
 }
 
 /* Basically redo blk_mq_init_queue with queue frozen */
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 3e44a9da2a13..61fc2633bbea 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -599,9 +599,8 @@ int blk_register_queue(struct gendisk *disk)
 	 */
 	if (!blk_queue_init_done(q)) {
 		queue_flag_set_unlocked(QUEUE_FLAG_INIT_DONE, q);
+		percpu_ref_switch_to_percpu(&q->q_usage_counter);
 		blk_queue_bypass_end(q);
-		if (q->mq_ops)
-			blk_mq_finish_init(q);
 	}
 
 	ret = blk_trace_init_sysfs(dev);
diff --git a/block/blk.h b/block/blk.h
index 98614ad37c81..5b2cd393afbe 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -72,6 +72,20 @@ void blk_dequeue_request(struct request *rq);
 void __blk_queue_free_tags(struct request_queue *q);
 bool __blk_end_bidi_request(struct request *rq, int error,
 			    unsigned int nr_bytes, unsigned int bidi_bytes);
+int blk_queue_enter(struct request_queue *q, gfp_t gfp);
+void blk_queue_exit(struct request_queue *q);
+void blk_freeze_queue(struct request_queue *q);
+
+static inline void blk_queue_enter_live(struct request_queue *q)
+{
+	/*
+	 * Given that running in generic_make_request() context
+	 * guarantees that a live reference against q_usage_counter has
+	 * been established, further references under that same context
+	 * need not check that the queue has been frozen (marked dead).
+	 */
+	percpu_ref_get(&q->q_usage_counter);
+}
 
 void blk_rq_timed_out_timer(unsigned long data);
 unsigned long blk_rq_timeout(unsigned long timeout);
diff --git a/include/linux/blk-mq.h b/include/linux/blk-mq.h
index 5e7d43ab61c0..83cc9d4e5455 100644
--- a/include/linux/blk-mq.h
+++ b/include/linux/blk-mq.h
@@ -166,7 +166,6 @@ enum {
 struct request_queue *blk_mq_init_queue(struct blk_mq_tag_set *);
 struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 						  struct request_queue *q);
-void blk_mq_finish_init(struct request_queue *q);
 int blk_mq_register_disk(struct gendisk *);
 void blk_mq_unregister_disk(struct gendisk *);
 
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 19c2e947d4d1..dd761b663e6a 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -450,7 +450,7 @@ struct request_queue {
 #endif
 	struct rcu_head		rcu_head;
 	wait_queue_head_t	mq_freeze_wq;
-	struct percpu_ref	mq_usage_counter;
+	struct percpu_ref	q_usage_counter;
 	struct list_head	all_q_node;
 
 	struct blk_mq_tag_set	*tag_set;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
