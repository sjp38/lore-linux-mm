Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9826B028F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:58:25 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so43923419qkd.0
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:58:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j129si9978040qkj.265.2018.11.15.00.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:58:24 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V10 18/19] block: kill QUEUE_FLAG_NO_SG_MERGE
Date: Thu, 15 Nov 2018 16:53:05 +0800
Message-Id: <20181115085306.9910-19-ming.lei@redhat.com>
In-Reply-To: <20181115085306.9910-1-ming.lei@redhat.com>
References: <20181115085306.9910-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

Since bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting"),
physical segment number is mainly figured out in blk_queue_split() for
fast path, and the flag of BIO_SEG_VALID is set there too.

Now only blk_recount_segments() and blk_recalc_rq_segments() use this
flag.

Basically blk_recount_segments() is bypassed in fast path given BIO_SEG_VALID
is set in blk_queue_split().

For another user of blk_recalc_rq_segments():

- run in partial completion branch of blk_update_request, which is an unusual case

- run in blk_cloned_rq_check_limits(), still not a big problem if the flag is killed
since dm-rq is the only user.

Multi-page bvec is enabled now, QUEUE_FLAG_NO_SG_MERGE doesn't make sense any more.

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: dm-devel@redhat.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Cc: linux-erofs@lists.ozlabs.org
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: Coly Li <colyli@suse.de>
Cc: linux-bcache@vger.kernel.org
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c      | 31 ++++++-------------------------
 block/blk-mq-debugfs.c |  1 -
 block/blk-mq.c         |  3 ---
 drivers/md/dm-table.c  | 13 -------------
 include/linux/blkdev.h |  1 -
 5 files changed, 6 insertions(+), 43 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 153a659fde74..06be298be332 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -351,8 +351,7 @@ void blk_queue_split(struct request_queue *q, struct bio **bio)
 EXPORT_SYMBOL(blk_queue_split);
 
 static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
-					     struct bio *bio,
-					     bool no_sg_merge)
+					     struct bio *bio)
 {
 	struct bio_vec bv, bvprv = { NULL };
 	int cluster, prev = 0;
@@ -379,13 +378,6 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
 		bio_for_each_bvec(bv, bio, iter) {
-			/*
-			 * If SG merging is disabled, each bio vector is
-			 * a segment
-			 */
-			if (no_sg_merge)
-				goto new_segment;
-
 			if (prev && cluster) {
 				if (seg_size + bv.bv_len
 				    > queue_max_segment_size(q))
@@ -420,27 +412,16 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 
 void blk_recalc_rq_segments(struct request *rq)
 {
-	bool no_sg_merge = !!test_bit(QUEUE_FLAG_NO_SG_MERGE,
-			&rq->q->queue_flags);
-
-	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio,
-			no_sg_merge);
+	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio);
 }
 
 void blk_recount_segments(struct request_queue *q, struct bio *bio)
 {
-	unsigned short seg_cnt = bio_segments(bio);
-
-	if (test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags) &&
-			(seg_cnt < queue_max_segments(q)))
-		bio->bi_phys_segments = seg_cnt;
-	else {
-		struct bio *nxt = bio->bi_next;
+	struct bio *nxt = bio->bi_next;
 
-		bio->bi_next = NULL;
-		bio->bi_phys_segments = __blk_recalc_rq_segments(q, bio, false);
-		bio->bi_next = nxt;
-	}
+	bio->bi_next = NULL;
+	bio->bi_phys_segments = __blk_recalc_rq_segments(q, bio);
+	bio->bi_next = nxt;
 
 	bio_set_flag(bio, BIO_SEG_VALID);
 }
diff --git a/block/blk-mq-debugfs.c b/block/blk-mq-debugfs.c
index f021f4817b80..e188b1090759 100644
--- a/block/blk-mq-debugfs.c
+++ b/block/blk-mq-debugfs.c
@@ -128,7 +128,6 @@ static const char *const blk_queue_flag_name[] = {
 	QUEUE_FLAG_NAME(SAME_FORCE),
 	QUEUE_FLAG_NAME(DEAD),
 	QUEUE_FLAG_NAME(INIT_DONE),
-	QUEUE_FLAG_NAME(NO_SG_MERGE),
 	QUEUE_FLAG_NAME(POLL),
 	QUEUE_FLAG_NAME(WC),
 	QUEUE_FLAG_NAME(FUA),
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 411be60d0cb6..ed484af5744b 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -2755,9 +2755,6 @@ struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 
 	q->queue_flags |= QUEUE_FLAG_MQ_DEFAULT;
 
-	if (!(set->flags & BLK_MQ_F_SG_MERGE))
-		queue_flag_set_unlocked(QUEUE_FLAG_NO_SG_MERGE, q);
-
 	q->sg_reserved_size = INT_MAX;
 
 	INIT_DELAYED_WORK(&q->requeue_work, blk_mq_requeue_work);
diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 9038c302d5c2..22fed6987aea 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -1698,14 +1698,6 @@ static int device_is_not_random(struct dm_target *ti, struct dm_dev *dev,
 	return q && !blk_queue_add_random(q);
 }
 
-static int queue_supports_sg_merge(struct dm_target *ti, struct dm_dev *dev,
-				   sector_t start, sector_t len, void *data)
-{
-	struct request_queue *q = bdev_get_queue(dev->bdev);
-
-	return q && !test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags);
-}
-
 static bool dm_table_all_devices_attribute(struct dm_table *t,
 					   iterate_devices_callout_fn func)
 {
@@ -1902,11 +1894,6 @@ void dm_table_set_restrictions(struct dm_table *t, struct request_queue *q,
 	if (!dm_table_supports_write_zeroes(t))
 		q->limits.max_write_zeroes_sectors = 0;
 
-	if (dm_table_all_devices_attribute(t, queue_supports_sg_merge))
-		blk_queue_flag_clear(QUEUE_FLAG_NO_SG_MERGE, q);
-	else
-		blk_queue_flag_set(QUEUE_FLAG_NO_SG_MERGE, q);
-
 	dm_table_verify_integrity(t);
 
 	/*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index e67ad2dd025e..c5c7799e88c2 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -604,7 +604,6 @@ struct request_queue {
 #define QUEUE_FLAG_SAME_FORCE  15	/* force complete on same CPU */
 #define QUEUE_FLAG_DEAD        16	/* queue tear-down finished */
 #define QUEUE_FLAG_INIT_DONE   17	/* queue is initialized */
-#define QUEUE_FLAG_NO_SG_MERGE 18	/* don't attempt to merge SG segments*/
 #define QUEUE_FLAG_POLL	       19	/* IO polling enabled if set */
 #define QUEUE_FLAG_WC	       20	/* Write back caching */
 #define QUEUE_FLAG_FUA	       21	/* device supports FUA writes */
-- 
2.9.5
