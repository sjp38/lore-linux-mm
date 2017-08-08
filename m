Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1296B04A0
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:50:36 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u19so12609944qtc.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:50:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g52si776534qtg.287.2017.08.08.01.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:50:35 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 22/49] block: blk-merge: try to make front segments in full size
Date: Tue,  8 Aug 2017 16:45:21 +0800
Message-Id: <20170808084548.18963-23-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

When merging one bvec into segment, if the bvec is too big
to merge, current policy is to move the whole bvec into another
new segment.

This patchset changes the policy into trying to maximize size of
front segments, that means in above situation, part of bvec
is merged into current segment, and the remainder is put
into next segment.

This patch prepares for support multipage bvec because
it can be quite common to see this case and we should try
to make front segments in full size.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 49 insertions(+), 5 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index d91f07813dee..aeb8933e6cae 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -108,6 +108,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 	bool do_split = true;
 	struct bio *new = NULL;
 	const unsigned max_sectors = get_max_io_size(q, bio);
+	unsigned advance = 0;
 
 	bio_for_each_segment(bv, bio, iter) {
 		/*
@@ -133,12 +134,32 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 		}
 
 		if (bvprvp && blk_queue_cluster(q)) {
-			if (seg_size + bv.bv_len > queue_max_segment_size(q))
-				goto new_segment;
 			if (!BIOVEC_PHYS_MERGEABLE(bvprvp, &bv))
 				goto new_segment;
 			if (!BIOVEC_SEG_BOUNDARY(q, bvprvp, &bv))
 				goto new_segment;
+			if (seg_size + bv.bv_len > queue_max_segment_size(q)) {
+				/*
+				 * On assumption is that initial value of
+				 * @seg_size(equals to bv.bv_len) won't be
+				 * bigger than max segment size, but will
+				 * becomes false after multipage bvec comes.
+				 */
+				advance = queue_max_segment_size(q) - seg_size;
+
+				if (advance > 0) {
+					seg_size += advance;
+					sectors += advance >> 9;
+					bv.bv_len -= advance;
+					bv.bv_offset += advance;
+				}
+
+				/*
+				 * Still need to put remainder of current
+				 * bvec into a new segment.
+				 */
+				goto new_segment;
+			}
 
 			seg_size += bv.bv_len;
 			bvprv = bv;
@@ -160,6 +181,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 		seg_size = bv.bv_len;
 		sectors += bv.bv_len >> 9;
 
+		/* restore the bvec for iterator */
+		if (advance) {
+			bv.bv_len += advance;
+			bv.bv_offset -= advance;
+			advance = 0;
+		}
 	}
 
 	do_split = false;
@@ -360,16 +387,29 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 {
 
 	int nbytes = bvec->bv_len;
+	unsigned advance = 0;
 
 	if (*sg && *cluster) {
-		if ((*sg)->length + nbytes > queue_max_segment_size(q))
-			goto new_segment;
-
 		if (!BIOVEC_PHYS_MERGEABLE(bvprv, bvec))
 			goto new_segment;
 		if (!BIOVEC_SEG_BOUNDARY(q, bvprv, bvec))
 			goto new_segment;
 
+		/*
+		 * try best to merge part of the bvec into previous
+		 * segment and follow same policy with
+		 * blk_bio_segment_split()
+		 */
+		if ((*sg)->length + nbytes > queue_max_segment_size(q)) {
+			advance = queue_max_segment_size(q) - (*sg)->length;
+			if (advance) {
+				(*sg)->length += advance;
+				bvec->bv_offset += advance;
+				bvec->bv_len -= advance;
+			}
+			goto new_segment;
+		}
+
 		(*sg)->length += nbytes;
 	} else {
 new_segment:
@@ -392,6 +432,10 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 
 		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
 		(*nsegs)++;
+
+		/* for making iterator happy */
+		bvec->bv_offset -= advance;
+		bvec->bv_len += advance;
 	}
 	*bvprv = *bvec;
 }
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
