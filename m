Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFE626B03B1
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:17:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u126so47716060qka.9
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:17:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q77si10933143qka.83.2017.06.26.05.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:17:15 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 26/51] block: use bio_for_each_segment_mp() to compute segments count
Date: Mon, 26 Jun 2017 20:10:09 +0800
Message-Id: <20170626121034.3051-27-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Firstly it is more efficient to use bio_for_each_segment_mp()
in both blk_bio_segment_split() and __blk_recalc_rq_segments()
to compute how many segments there are in the bio.

Secondaly once bio_for_each_segment_mp() is used, the bvec
may need to be splitted because its length can be very long
and more than max segment size, so we have to support to split
one bvec into several segments.

Thirdly during splitting mp bvec into segments, max segment
number may be reached, then the bio need to be splitted when
this happens.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 97 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 79 insertions(+), 18 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index c6fcc49b9aea..8d2c2d763456 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -96,6 +96,62 @@ static inline unsigned get_max_io_size(struct request_queue *q,
 	return sectors;
 }
 
+/*
+ * Split the bvec @bv into segments, and update all kinds of
+ * variables.
+ */
+static bool bvec_split_segs(struct request_queue *q, struct bio_vec *bv,
+		unsigned *nsegs, unsigned *last_seg_size,
+		unsigned *front_seg_size, unsigned *sectors)
+{
+	bool need_split = false;
+	unsigned len = bv->bv_len;
+	unsigned total_len = 0;
+	unsigned new_nsegs = 0, seg_size = 0;
+
+	if ((*nsegs >= queue_max_segments(q)) || !len)
+		return need_split;
+
+	/*
+	 * Multipage bvec may be too big to hold in one segment,
+	 * so the current bvec has to be splitted as multiple
+	 * segments.
+	 */
+	while (new_nsegs + *nsegs < queue_max_segments(q)) {
+		seg_size = min(queue_max_segment_size(q), len);
+
+		new_nsegs++;
+		total_len += seg_size;
+		len -= seg_size;
+
+		if ((queue_virt_boundary(q) && ((bv->bv_offset +
+		    total_len) & queue_virt_boundary(q))) || !len)
+			break;
+	}
+
+	/* split in the middle of the bvec */
+	if (len)
+		need_split = true;
+
+	/* update front segment size */
+	if (!*nsegs) {
+		unsigned first_seg_size = seg_size;
+
+		if (new_nsegs > 1)
+			first_seg_size = queue_max_segment_size(q);
+		if (*front_seg_size < first_seg_size)
+			*front_seg_size = first_seg_size;
+	}
+
+	/* update other varibles */
+	*last_seg_size = seg_size;
+	*nsegs += new_nsegs;
+	if (sectors)
+		*sectors += total_len >> 9;
+
+	return need_split;
+}
+
 static struct bio *blk_bio_segment_split(struct request_queue *q,
 					 struct bio *bio,
 					 struct bio_set *bs,
@@ -110,7 +166,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 	const unsigned max_sectors = get_max_io_size(q, bio);
 	unsigned advance = 0;
 
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_segment_mp(bv, bio, iter) {
 		/*
 		 * If the queue doesn't support SG gaps and adding this
 		 * offset would create a gap, disallow it.
@@ -125,8 +181,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			 */
 			if (nsegs < queue_max_segments(q) &&
 			    sectors < max_sectors) {
-				nsegs++;
-				sectors = max_sectors;
+				/* split in the middle of bvec */
+				bv.bv_len = (max_sectors - sectors) << 9;
+				bvec_split_segs(q, &bv, &nsegs,
+						&seg_size,
+						&front_seg_size,
+						&sectors);
 			}
 			goto split;
 		}
@@ -138,10 +198,9 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 				goto new_segment;
 			if (seg_size + bv.bv_len > queue_max_segment_size(q)) {
 				/*
-				 * On assumption is that initial value of
-				 * @seg_size(equals to bv.bv_len) won't be
-				 * bigger than max segment size, but will
-				 * becomes false after multipage bvec comes.
+				 * The initial value of @seg_size won't be
+				 * bigger than max segment size, because we
+				 * split the bvec via bvec_split_segs().
 				 */
 				advance = queue_max_segment_size(q) - seg_size;
 
@@ -173,11 +232,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 		if (nsegs == 1 && seg_size > front_seg_size)
 			front_seg_size = seg_size;
 
-		nsegs++;
 		bvprv = bv;
 		bvprvp = &bvprv;
-		seg_size = bv.bv_len;
-		sectors += bv.bv_len >> 9;
+
+		if (bvec_split_segs(q, &bv, &nsegs, &seg_size,
+					&front_seg_size, &sectors))
+			goto split;
 
 		/* restore the bvec for iterator */
 		if (advance) {
@@ -251,6 +311,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	struct bio_vec bv, bvprv = { NULL };
 	int cluster, prev = 0;
 	unsigned int seg_size, nr_phys_segs;
+	unsigned front_seg_size = bio->bi_seg_front_size;
 	struct bio *fbio, *bbio;
 	struct bvec_iter iter;
 
@@ -271,7 +332,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	seg_size = 0;
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
-		bio_for_each_segment(bv, bio, iter) {
+		bio_for_each_segment_mp(bv, bio, iter) {
 			/*
 			 * If SG merging is disabled, each bio vector is
 			 * a segment
@@ -293,20 +354,20 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 				continue;
 			}
 new_segment:
-			if (nr_phys_segs == 1 && seg_size >
-			    fbio->bi_seg_front_size)
-				fbio->bi_seg_front_size = seg_size;
+			if (nr_phys_segs == 1 && seg_size > front_seg_size)
+				front_seg_size = seg_size;
 
-			nr_phys_segs++;
 			bvprv = bv;
 			prev = 1;
-			seg_size = bv.bv_len;
+			bvec_split_segs(q, &bv, &nr_phys_segs, &seg_size,
+					&front_seg_size, NULL);
 		}
 		bbio = bio;
 	}
 
-	if (nr_phys_segs == 1 && seg_size > fbio->bi_seg_front_size)
-		fbio->bi_seg_front_size = seg_size;
+	if (nr_phys_segs == 1 && seg_size > front_seg_size)
+		front_seg_size = seg_size;
+	fbio->bi_seg_front_size = front_seg_size;
 	if (seg_size > bbio->bi_seg_back_size)
 		bbio->bi_seg_back_size = seg_size;
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
