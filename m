Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F48A6B3F8C
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:21:30 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so15447061qtd.20
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:21:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x4si585536qtj.211.2018.11.25.18.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:21:29 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 19/20] block: kill QUEUE_FLAG_NO_SG_MERGE
Date: Mon, 26 Nov 2018 10:17:19 +0800
Message-Id: <20181126021720.19471-20-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

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

Multi-page bvec is enabled now, not doing S/G merging is rather pointless with the
current setup of the I/O path, as it isn't going to save you a significant amount
of cycles.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c      | 31 ++++++-------------------------
 block/blk-mq-debugfs.c |  1 -
 block/blk-mq.c         |  3 ---
 drivers/md/dm-table.c  | 13 -------------
 include/linux/blkdev.h |  1 -
 5 files changed, 6 insertions(+), 43 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 20b5b0c3e182..9a7fd8b1f90a 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -355,8 +355,7 @@ void blk_queue_split(struct request_queue *q, struct bio **bio)
 EXPORT_SYMBOL(blk_queue_split);
 
 static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
-					     struct bio *bio,
-					     bool no_sg_merge)
+					     struct bio *bio)
 {
 	struct bio_vec bv, bvprv = { NULL };
 	unsigned int seg_size, nr_phys_segs;
@@ -382,13 +381,6 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
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
 			if (prev) {
 				if (seg_size + bv.bv_len
 				    > queue_max_segment_size(q))
@@ -418,27 +410,16 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 
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
index a32bb79d6c95..d752fe4461af 100644
--- a/block/blk-mq-debugfs.c
+++ b/block/blk-mq-debugfs.c
@@ -127,7 +127,6 @@ static const char *const blk_queue_flag_name[] = {
 	QUEUE_FLAG_NAME(SAME_FORCE),
 	QUEUE_FLAG_NAME(DEAD),
 	QUEUE_FLAG_NAME(INIT_DONE),
-	QUEUE_FLAG_NAME(NO_SG_MERGE),
 	QUEUE_FLAG_NAME(POLL),
 	QUEUE_FLAG_NAME(WC),
 	QUEUE_FLAG_NAME(FUA),
diff --git a/block/blk-mq.c b/block/blk-mq.c
index b16204df65d1..7b17191d755b 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -2780,9 +2780,6 @@ struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 
 	q->queue_flags |= QUEUE_FLAG_MQ_DEFAULT;
 
-	if (!(set->flags & BLK_MQ_F_SG_MERGE))
-		blk_queue_flag_set(QUEUE_FLAG_NO_SG_MERGE, q);
-
 	q->sg_reserved_size = INT_MAX;
 
 	INIT_DELAYED_WORK(&q->requeue_work, blk_mq_requeue_work);
diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 844f7d0f2ef8..a41832cf0c98 100644
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
index fa263de3f1d1..9c1ae3a62ed3 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -589,7 +589,6 @@ struct request_queue {
 #define QUEUE_FLAG_SAME_FORCE  15	/* force complete on same CPU */
 #define QUEUE_FLAG_DEAD        16	/* queue tear-down finished */
 #define QUEUE_FLAG_INIT_DONE   17	/* queue is initialized */
-#define QUEUE_FLAG_NO_SG_MERGE 18	/* don't attempt to merge SG segments*/
 #define QUEUE_FLAG_POLL	       19	/* IO polling enabled if set */
 #define QUEUE_FLAG_WC	       20	/* Write back caching */
 #define QUEUE_FLAG_FUA	       21	/* device supports FUA writes */
-- 
2.9.5
