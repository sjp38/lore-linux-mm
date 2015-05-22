Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 997F2829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:10 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22245523qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:10 -0700 (PDT)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id f8si282040qkh.5.2015.05.22.14.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:09 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so22228666qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:09 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 28/51] writeback, blkcg: restructure blk_{set|clear}_queue_congested()
Date: Fri, 22 May 2015 17:13:42 -0400
Message-Id: <1432329245-5844-29-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

blk_{set|clear}_queue_congested() take @q and set or clear,
respectively, the congestion state of its bdi's root wb.  Because bdi
used to be able to handle congestion state only on the root wb, the
callers of those functions tested whether the congestion is on the
root blkcg and skipped if not.

This is cumbersome and makes implementation of per cgroup
bdi_writeback congestion state propagation difficult.  This patch
renames blk_{set|clear}_queue_congested() to
blk_{set|clear}_congested(), and makes them take request_list instead
of request_queue and test whether the specified request_list is the
root one before updating bdi_writeback congestion state.  This makes
the tests in the callers unnecessary and simplifies them.

As there are no external users of these functions, the definitions are
moved from include/linux/blkdev.h to block/blk-core.c.

This patch doesn't introduce any noticeable behavior difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/blk-core.c       | 62 ++++++++++++++++++++++++++++++--------------------
 include/linux/blkdev.h | 19 ----------------
 2 files changed, 37 insertions(+), 44 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index e0f726f..b457c4f 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -63,6 +63,28 @@ struct kmem_cache *blk_requestq_cachep;
  */
 static struct workqueue_struct *kblockd_workqueue;
 
+static void blk_clear_congested(struct request_list *rl, int sync)
+{
+	if (rl != &rl->q->root_rl)
+		return;
+#ifdef CONFIG_CGROUP_WRITEBACK
+	clear_wb_congested(rl->blkg->wb_congested, sync);
+#else
+	clear_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
+#endif
+}
+
+static void blk_set_congested(struct request_list *rl, int sync)
+{
+	if (rl != &rl->q->root_rl)
+		return;
+#ifdef CONFIG_CGROUP_WRITEBACK
+	set_wb_congested(rl->blkg->wb_congested, sync);
+#else
+	set_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
+#endif
+}
+
 void blk_queue_congestion_threshold(struct request_queue *q)
 {
 	int nr;
@@ -841,13 +863,8 @@ static void __freed_request(struct request_list *rl, int sync)
 {
 	struct request_queue *q = rl->q;
 
-	/*
-	 * bdi isn't aware of blkcg yet.  As all async IOs end up root
-	 * blkcg anyway, just use root blkcg state.
-	 */
-	if (rl == &q->root_rl &&
-	    rl->count[sync] < queue_congestion_off_threshold(q))
-		blk_clear_queue_congested(q, sync);
+	if (rl->count[sync] < queue_congestion_off_threshold(q))
+		blk_clear_congested(rl, sync);
 
 	if (rl->count[sync] + 1 <= q->nr_requests) {
 		if (waitqueue_active(&rl->wait[sync]))
@@ -880,25 +897,25 @@ static void freed_request(struct request_list *rl, unsigned int flags)
 int blk_update_nr_requests(struct request_queue *q, unsigned int nr)
 {
 	struct request_list *rl;
+	int on_thresh, off_thresh;
 
 	spin_lock_irq(q->queue_lock);
 	q->nr_requests = nr;
 	blk_queue_congestion_threshold(q);
+	on_thresh = queue_congestion_on_threshold(q);
+	off_thresh = queue_congestion_off_threshold(q);
 
-	/* congestion isn't cgroup aware and follows root blkcg for now */
-	rl = &q->root_rl;
-
-	if (rl->count[BLK_RW_SYNC] >= queue_congestion_on_threshold(q))
-		blk_set_queue_congested(q, BLK_RW_SYNC);
-	else if (rl->count[BLK_RW_SYNC] < queue_congestion_off_threshold(q))
-		blk_clear_queue_congested(q, BLK_RW_SYNC);
+	blk_queue_for_each_rl(rl, q) {
+		if (rl->count[BLK_RW_SYNC] >= on_thresh)
+			blk_set_congested(rl, BLK_RW_SYNC);
+		else if (rl->count[BLK_RW_SYNC] < off_thresh)
+			blk_clear_congested(rl, BLK_RW_SYNC);
 
-	if (rl->count[BLK_RW_ASYNC] >= queue_congestion_on_threshold(q))
-		blk_set_queue_congested(q, BLK_RW_ASYNC);
-	else if (rl->count[BLK_RW_ASYNC] < queue_congestion_off_threshold(q))
-		blk_clear_queue_congested(q, BLK_RW_ASYNC);
+		if (rl->count[BLK_RW_ASYNC] >= on_thresh)
+			blk_set_congested(rl, BLK_RW_ASYNC);
+		else if (rl->count[BLK_RW_ASYNC] < off_thresh)
+			blk_clear_congested(rl, BLK_RW_ASYNC);
 
-	blk_queue_for_each_rl(rl, q) {
 		if (rl->count[BLK_RW_SYNC] >= q->nr_requests) {
 			blk_set_rl_full(rl, BLK_RW_SYNC);
 		} else {
@@ -1008,12 +1025,7 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
 				}
 			}
 		}
-		/*
-		 * bdi isn't aware of blkcg yet.  As all async IOs end up
-		 * root blkcg anyway, just use root blkcg state.
-		 */
-		if (rl == &q->root_rl)
-			blk_set_queue_congested(q, is_sync);
+		blk_set_congested(rl, is_sync);
 	}
 
 	/*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 89bdef0..3d1065c 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -794,25 +794,6 @@ extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 
 extern void blk_queue_bio(struct request_queue *q, struct bio *bio);
 
-/*
- * A queue has just exitted congestion.  Note this in the global counter of
- * congested queues, and wake up anyone who was waiting for requests to be
- * put back.
- */
-static inline void blk_clear_queue_congested(struct request_queue *q, int sync)
-{
-	clear_bdi_congested(&q->backing_dev_info, sync);
-}
-
-/*
- * A queue has just entered congestion.  Flag that in the queue's VM-visible
- * state flags and increment the global gounter of congested queues.
- */
-static inline void blk_set_queue_congested(struct request_queue *q, int sync)
-{
-	set_bdi_congested(&q->backing_dev_info, sync);
-}
-
 extern void blk_start_queue(struct request_queue *q);
 extern void blk_stop_queue(struct request_queue *q);
 extern void blk_sync_queue(struct request_queue *q);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
