Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C16136B03B3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:17:26 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r30so22181590qtc.5
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:17:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r42si8741541qtc.252.2017.06.26.05.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:17:25 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 27/51] block: use bio_for_each_segment_mp() to map sg
Date: Mon, 26 Jun 2017 20:10:10 +0800
Message-Id: <20170626121034.3051-28-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

It is more efficient to use bio_for_each_segment_mp()
for mapping sg, meantime we have to consider splitting
multipage bvec as done in blk_bio_segment_split().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 72 +++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 52 insertions(+), 20 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 8d2c2d763456..894dcd017b56 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -439,6 +439,56 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 	return 0;
 }
 
+static inline struct scatterlist *blk_next_sg(struct scatterlist **sg,
+		struct scatterlist *sglist)
+{
+	if (!*sg)
+		return sglist;
+	else {
+		/*
+		 * If the driver previously mapped a shorter
+		 * list, we could see a termination bit
+		 * prematurely unless it fully inits the sg
+		 * table on each mapping. We KNOW that there
+		 * must be more entries here or the driver
+		 * would be buggy, so force clear the
+		 * termination bit to avoid doing a full
+		 * sg_init_table() in drivers for each command.
+		 */
+		sg_unmark_end(*sg);
+		return sg_next(*sg);
+	}
+}
+
+static inline unsigned
+blk_bvec_map_sg(struct request_queue *q, struct bio_vec *bvec,
+		struct scatterlist *sglist, struct scatterlist **sg)
+{
+	unsigned nbytes = bvec->bv_len;
+	unsigned nsegs = 0, total = 0;
+
+	while (nbytes > 0) {
+		unsigned seg_size;
+		struct page *pg;
+		unsigned offset, idx;
+
+		*sg = blk_next_sg(sg, sglist);
+
+		seg_size = min(nbytes, queue_max_segment_size(q));
+		offset = (total + bvec->bv_offset) % PAGE_SIZE;
+		idx = (total + bvec->bv_offset) / PAGE_SIZE;
+		pg = nth_page(bvec->bv_page, idx);
+
+		sg_set_page(*sg, pg, seg_size, offset);
+
+		total += seg_size;
+		nbytes -= seg_size;
+		nsegs++;
+	}
+
+	return nsegs;
+}
+
 static inline void
 __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 		     struct scatterlist *sglist, struct bio_vec *bvprv,
@@ -472,25 +522,7 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 		(*sg)->length += nbytes;
 	} else {
 new_segment:
-		if (!*sg)
-			*sg = sglist;
-		else {
-			/*
-			 * If the driver previously mapped a shorter
-			 * list, we could see a termination bit
-			 * prematurely unless it fully inits the sg
-			 * table on each mapping. We KNOW that there
-			 * must be more entries here or the driver
-			 * would be buggy, so force clear the
-			 * termination bit to avoid doing a full
-			 * sg_init_table() in drivers for each command.
-			 */
-			sg_unmark_end(*sg);
-			*sg = sg_next(*sg);
-		}
-
-		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
-		(*nsegs)++;
+		(*nsegs) += blk_bvec_map_sg(q, bvec, sglist, sg);
 
 		/* for making iterator happy */
 		bvec->bv_offset -= advance;
@@ -516,7 +548,7 @@ static int __blk_bios_map_sg(struct request_queue *q, struct bio *bio,
 	int cluster = blk_queue_cluster(q), nsegs = 0;
 
 	for_each_bio(bio)
-		bio_for_each_segment(bvec, bio, iter)
+		bio_for_each_segment_mp(bvec, bio, iter)
 			__blk_segment_map_sg(q, &bvec, sglist, &bvprv, sg,
 					     &nsegs, &cluster);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
