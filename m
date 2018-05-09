Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4A86B038E
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so8564749pfe.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id y40-v6si25918734pla.470.2018.05.09.00.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:40 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/6] block: pass an explicit gfp_t to get_request
Date: Wed,  9 May 2018 09:54:06 +0200
Message-Id: <20180509075408.16388-5-hch@lst.de>
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

blk_old_get_request already has it at hand, and in blk_queue_bio, which
is the fast path, it is constant.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Hannes Reinecke <hare@suse.com>
---
 block/blk-core.c          | 14 +++++++-------
 drivers/scsi/scsi_error.c |  4 ----
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 5013027eae70..cc56e56c2eff 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1333,6 +1333,7 @@ int blk_update_nr_requests(struct request_queue *q, unsigned int nr)
  * @op: operation and flags
  * @bio: bio to allocate request for (can be %NULL)
  * @flags: BLQ_MQ_REQ_* flags
+ * @gfp_mask: allocator flags
  *
  * Get a free request from @q.  This function may fail under memory
  * pressure or if @q is dead.
@@ -1342,7 +1343,7 @@ int blk_update_nr_requests(struct request_queue *q, unsigned int nr)
  * Returns request pointer on success, with @q->queue_lock *not held*.
  */
 static struct request *__get_request(struct request_list *rl, unsigned int op,
-				     struct bio *bio, blk_mq_req_flags_t flags)
+		struct bio *bio, blk_mq_req_flags_t flags, gfp_t gfp_mask)
 {
 	struct request_queue *q = rl->q;
 	struct request *rq;
@@ -1351,8 +1352,6 @@ static struct request *__get_request(struct request_list *rl, unsigned int op,
 	struct io_cq *icq = NULL;
 	const bool is_sync = op_is_sync(op);
 	int may_queue;
-	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC :
-			 __GFP_DIRECT_RECLAIM;
 	req_flags_t rq_flags = RQF_ALLOCED;
 
 	lockdep_assert_held(q->queue_lock);
@@ -1516,6 +1515,7 @@ static struct request *__get_request(struct request_list *rl, unsigned int op,
  * @op: operation and flags
  * @bio: bio to allocate request for (can be %NULL)
  * @flags: BLK_MQ_REQ_* flags.
+ * @gfp: allocator flags
  *
  * Get a free request from @q.  If %BLK_MQ_REQ_NOWAIT is set in @flags,
  * this function keeps retrying under memory pressure and fails iff @q is dead.
@@ -1525,7 +1525,7 @@ static struct request *__get_request(struct request_list *rl, unsigned int op,
  * Returns request pointer on success, with @q->queue_lock *not held*.
  */
 static struct request *get_request(struct request_queue *q, unsigned int op,
-				   struct bio *bio, blk_mq_req_flags_t flags)
+		struct bio *bio, blk_mq_req_flags_t flags, gfp_t gfp)
 {
 	const bool is_sync = op_is_sync(op);
 	DEFINE_WAIT(wait);
@@ -1537,7 +1537,7 @@ static struct request *get_request(struct request_queue *q, unsigned int op,
 
 	rl = blk_get_rl(q, bio);	/* transferred to @rq on success */
 retry:
-	rq = __get_request(rl, op, bio, flags);
+	rq = __get_request(rl, op, bio, flags, gfp);
 	if (!IS_ERR(rq))
 		return rq;
 
@@ -1591,7 +1591,7 @@ static struct request *blk_old_get_request(struct request_queue *q,
 	if (ret)
 		return ERR_PTR(ret);
 	spin_lock_irq(q->queue_lock);
-	rq = get_request(q, op, NULL, flags);
+	rq = get_request(q, op, NULL, flags, gfp_mask);
 	if (IS_ERR(rq)) {
 		spin_unlock_irq(q->queue_lock);
 		blk_queue_exit(q);
@@ -2057,7 +2057,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	 * Returns with the queue unlocked.
 	 */
 	blk_queue_enter_live(q);
-	req = get_request(q, bio->bi_opf, bio, 0);
+	req = get_request(q, bio->bi_opf, bio, 0, __GFP_DIRECT_RECLAIM);
 	if (IS_ERR(req)) {
 		blk_queue_exit(q);
 		__wbt_done(q->rq_wb, wb_acct);
diff --git a/drivers/scsi/scsi_error.c b/drivers/scsi/scsi_error.c
index 61d280f560df..b36e73090018 100644
--- a/drivers/scsi/scsi_error.c
+++ b/drivers/scsi/scsi_error.c
@@ -1933,10 +1933,6 @@ static void scsi_eh_lock_door(struct scsi_device *sdev)
 	struct request *req;
 	struct scsi_request *rq;
 
-	/*
-	 * blk_get_request with GFP_KERNEL (__GFP_RECLAIM) sleeps until a
-	 * request becomes available
-	 */
 	req = blk_get_request(sdev->request_queue, REQ_OP_SCSI_IN, 0);
 	if (IS_ERR(req))
 		return;
-- 
2.17.0
