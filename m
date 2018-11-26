Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B12B16B3F67
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:18:16 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so18029306qka.10
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:18:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i66si542736qkc.207.2018.11.25.18.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:18:15 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 03/20] block: remove the "cluster" flag
Date: Mon, 26 Nov 2018 10:17:03 +0800
Message-Id: <20181126021720.19471-4-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

From: Christoph Hellwig <hch@lst.de>

The cluster flag implements some very old SCSI behavior.  As far as I
can tell the original intent was to enable or disable any kind of
segment merging.  But the actually visible effect to the LLDD is that
it limits each segments to be inside a single page, which we can
also affect by setting the maximum segment size and the segment
boundary.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Replace virt boundary with segment boundary limit.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c       | 20 ++++++++------------
 block/blk-settings.c    |  3 ---
 block/blk-sysfs.c       |  5 +----
 drivers/scsi/scsi_lib.c | 20 ++++++++++++++++----
 include/linux/blkdev.h  |  6 ------
 5 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 6be04ef8da5b..e69d8f8ba819 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -195,7 +195,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			goto split;
 		}
 
-		if (bvprvp && blk_queue_cluster(q)) {
+		if (bvprvp) {
 			if (seg_size + bv.bv_len > queue_max_segment_size(q))
 				goto new_segment;
 			if (!biovec_phys_mergeable(q, bvprvp, &bv))
@@ -295,10 +295,10 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 					     bool no_sg_merge)
 {
 	struct bio_vec bv, bvprv = { NULL };
-	int cluster, prev = 0;
 	unsigned int seg_size, nr_phys_segs;
 	struct bio *fbio, *bbio;
 	struct bvec_iter iter;
+	bool prev = false;
 
 	if (!bio)
 		return 0;
@@ -313,7 +313,6 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	}
 
 	fbio = bio;
-	cluster = blk_queue_cluster(q);
 	seg_size = 0;
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
@@ -325,7 +324,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 			if (no_sg_merge)
 				goto new_segment;
 
-			if (prev && cluster) {
+			if (prev) {
 				if (seg_size + bv.bv_len
 				    > queue_max_segment_size(q))
 					goto new_segment;
@@ -343,7 +342,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 
 			nr_phys_segs++;
 			bvprv = bv;
-			prev = 1;
+			prev = true;
 			seg_size = bv.bv_len;
 		}
 		bbio = bio;
@@ -396,9 +395,6 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 {
 	struct bio_vec end_bv = { NULL }, nxt_bv;
 
-	if (!blk_queue_cluster(q))
-		return 0;
-
 	if (bio->bi_seg_back_size + nxt->bi_seg_front_size >
 	    queue_max_segment_size(q))
 		return 0;
@@ -415,12 +411,12 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 static inline void
 __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 		     struct scatterlist *sglist, struct bio_vec *bvprv,
-		     struct scatterlist **sg, int *nsegs, int *cluster)
+		     struct scatterlist **sg, int *nsegs)
 {
 
 	int nbytes = bvec->bv_len;
 
-	if (*sg && *cluster) {
+	if (*sg) {
 		if ((*sg)->length + nbytes > queue_max_segment_size(q))
 			goto new_segment;
 		if (!biovec_phys_mergeable(q, bvprv, bvec))
@@ -466,12 +462,12 @@ static int __blk_bios_map_sg(struct request_queue *q, struct bio *bio,
 {
 	struct bio_vec bvec, bvprv = { NULL };
 	struct bvec_iter iter;
-	int cluster = blk_queue_cluster(q), nsegs = 0;
+	int nsegs = 0;
 
 	for_each_bio(bio)
 		bio_for_each_segment(bvec, bio, iter)
 			__blk_segment_map_sg(q, &bvec, sglist, &bvprv, sg,
-					     &nsegs, &cluster);
+					     &nsegs);
 
 	return nsegs;
 }
diff --git a/block/blk-settings.c b/block/blk-settings.c
index 3abe831e92c8..3e7038e475ee 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -56,7 +56,6 @@ void blk_set_default_limits(struct queue_limits *lim)
 	lim->alignment_offset = 0;
 	lim->io_opt = 0;
 	lim->misaligned = 0;
-	lim->cluster = 1;
 	lim->zoned = BLK_ZONED_NONE;
 }
 EXPORT_SYMBOL(blk_set_default_limits);
@@ -547,8 +546,6 @@ int blk_stack_limits(struct queue_limits *t, struct queue_limits *b,
 	t->io_min = max(t->io_min, b->io_min);
 	t->io_opt = lcm_not_zero(t->io_opt, b->io_opt);
 
-	t->cluster &= b->cluster;
-
 	/* Physical block size a multiple of the logical block size? */
 	if (t->physical_block_size & (t->logical_block_size - 1)) {
 		t->physical_block_size = t->logical_block_size;
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 80eef48fddc8..ef7b844a3e00 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -132,10 +132,7 @@ static ssize_t queue_max_integrity_segments_show(struct request_queue *q, char *
 
 static ssize_t queue_max_segment_size_show(struct request_queue *q, char *page)
 {
-	if (blk_queue_cluster(q))
-		return queue_var_show(queue_max_segment_size(q), (page));
-
-	return queue_var_show(PAGE_SIZE, (page));
+	return queue_var_show(queue_max_segment_size(q), page);
 }
 
 static ssize_t queue_logical_block_size_show(struct request_queue *q, char *page)
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 0df15cb738d2..78d6d05992b0 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -1810,6 +1810,8 @@ static int scsi_map_queues(struct blk_mq_tag_set *set)
 void __scsi_init_queue(struct Scsi_Host *shost, struct request_queue *q)
 {
 	struct device *dev = shost->dma_dev;
+	unsigned max_segment_size = dma_get_max_seg_size(dev);
+	unsigned long segment_boundary = shost->dma_boundary;
 
 	/*
 	 * this limit is imposed by hardware restrictions
@@ -1828,13 +1830,23 @@ void __scsi_init_queue(struct Scsi_Host *shost, struct request_queue *q)
 	blk_queue_max_hw_sectors(q, shost->max_sectors);
 	if (shost->unchecked_isa_dma)
 		blk_queue_bounce_limit(q, BLK_BOUNCE_ISA);
-	blk_queue_segment_boundary(q, shost->dma_boundary);
 	dma_set_seg_boundary(dev, shost->dma_boundary);
 
-	blk_queue_max_segment_size(q, dma_get_max_seg_size(dev));
+	/*
+	 * Clustering is a really old concept from the stone age of Linux
+	 * SCSI support.  But the basic idea is that we never give the
+	 * driver a segment that spans multiple pages.  For that we need
+	 * to limit the segment size, and set the segment boundary so that
+	 * we never merge a second segment which is no page aligned.
+	 */
+	if (!shost->use_clustering) {
+		max_segment_size = min_t(unsigned, max_segment_size, PAGE_SIZE);
+		segment_boundary = min_t(unsigned, segment_boundary,
+					 PAGE_SIZE - 1);
+	}
 
-	if (!shost->use_clustering)
-		q->limits.cluster = 0;
+	blk_queue_max_segment_size(q, max_segment_size);
+	blk_queue_segment_boundary(q, segment_boundary);
 
 	/*
 	 * Set a reasonable default alignment:  The larger of 32-byte (dword),
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 9b53db06ad08..399a7a415609 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -341,7 +341,6 @@ struct queue_limits {
 
 	unsigned char		misaligned;
 	unsigned char		discard_misaligned;
-	unsigned char		cluster;
 	unsigned char		raid_partial_stripes_expensive;
 	enum blk_zoned_model	zoned;
 };
@@ -660,11 +659,6 @@ static inline bool queue_is_mq(struct request_queue *q)
 	return q->mq_ops;
 }
 
-static inline unsigned int blk_queue_cluster(struct request_queue *q)
-{
-	return q->limits.cluster;
-}
-
 static inline enum blk_zoned_model
 blk_queue_zoned_model(struct request_queue *q)
 {
-- 
2.9.5
