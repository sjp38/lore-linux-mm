Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83F5E6B0491
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:48:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k14so12887872qkl.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:48:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x131si756165qkb.217.2017.08.08.01.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:48:38 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 14/49] block: bounce: avoid direct access to bvec table
Date: Tue,  8 Aug 2017 16:45:13 +0800
Message-Id: <20170808084548.18963-15-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Matthew Wilcox <willy@infradead.org>

We will support multipage bvecs in the future, so change to
iterator way for getting bv_page of bvec from original bio.

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bounce.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/block/bounce.c b/block/bounce.c
index 5793c2dc1a15..e57cf2bdcd27 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -136,21 +136,20 @@ static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 static void bounce_end_io(struct bio *bio, mempool_t *pool)
 {
 	struct bio *bio_orig = bio->bi_private;
-	struct bio_vec *bvec, *org_vec;
+	struct bio_vec *bvec, orig_vec;
 	int i;
-	int start = bio_orig->bi_iter.bi_idx;
+	struct bvec_iter orig_iter = bio_orig->bi_iter;
 
 	/*
 	 * free up bounce indirect pages used
 	 */
 	bio_for_each_segment_all(bvec, bio, i) {
-		org_vec = bio_orig->bi_io_vec + i + start;
-
-		if (bvec->bv_page == org_vec->bv_page)
-			continue;
-
-		dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
-		mempool_free(bvec->bv_page, pool);
+		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
+		if (bvec->bv_page != orig_vec.bv_page) {
+			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
+			mempool_free(bvec->bv_page, pool);
+		}
+		bio_advance_iter(bio_orig, &orig_iter, orig_vec.bv_len);
 	}
 
 	bio_orig->bi_status = bio->bi_status;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
