Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 202136B0391
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a6-v6so3312093pll.22
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id s1-v6si20950974pgb.434.2018.05.09.00.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:46 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/6] block: use GFP_NOIO instead of __GFP_DIRECT_RECLAIM
Date: Wed,  9 May 2018 09:54:07 +0200
Message-Id: <20180509075408.16388-6-hch@lst.de>
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

We just can't do I/O when doing block layer requests allocations,
so use GFP_NOIO instead of the even more limited __GFP_DIRECT_RECLAIM.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Hannes Reinecke <hare@suse.com>
---
 block/blk-core.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index cc56e56c2eff..168e43d6398d 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1578,8 +1578,7 @@ static struct request *blk_old_get_request(struct request_queue *q,
 				unsigned int op, blk_mq_req_flags_t flags)
 {
 	struct request *rq;
-	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC :
-			 __GFP_DIRECT_RECLAIM;
+	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC : GFP_NOIO;
 	int ret = 0;
 
 	WARN_ON_ONCE(q->mq_ops);
@@ -2057,7 +2056,7 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	 * Returns with the queue unlocked.
 	 */
 	blk_queue_enter_live(q);
-	req = get_request(q, bio->bi_opf, bio, 0, __GFP_DIRECT_RECLAIM);
+	req = get_request(q, bio->bi_opf, bio, 0, GFP_NOIO);
 	if (IS_ERR(req)) {
 		blk_queue_exit(q);
 		__wbt_done(q->rq_wb, wb_acct);
-- 
2.17.0
