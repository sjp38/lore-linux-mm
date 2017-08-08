Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1D76B0495
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:49:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s26so12659451qts.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:49:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x4si765240qke.376.2017.08.08.01.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:49:31 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 16/49] block: bounce: don't access bio->bi_io_vec in copy_to_high_bio_irq
Date: Tue,  8 Aug 2017 16:45:15 +0800
Message-Id: <20170808084548.18963-17-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

As we need to support multipage bvecs, so don't access bio->bi_io_vec
in copy_to_high_bio_irq(), and just use the standard iterator
to do that.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bounce.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/block/bounce.c b/block/bounce.c
index e57cf2bdcd27..50e965a15295 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -112,24 +112,30 @@ int init_emergency_isa_pool(void)
 static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 {
 	unsigned char *vfrom;
-	struct bio_vec tovec, *fromvec = from->bi_io_vec;
+	struct bio_vec tovec, fromvec;
 	struct bvec_iter iter;
+	/*
+	 * The bio of @from is created by bounce, so we can iterate
+	 * its bvec from start to end, but the @from->bi_iter can't be
+	 * trusted because it might be changed by splitting.
+	 */
+	struct bvec_iter from_iter = BVEC_ITER_ALL_INIT;
 
 	bio_for_each_segment(tovec, to, iter) {
-		if (tovec.bv_page != fromvec->bv_page) {
+		fromvec = bio_iter_iovec(from, from_iter);
+		if (tovec.bv_page != fromvec.bv_page) {
 			/*
 			 * fromvec->bv_offset and fromvec->bv_len might have
 			 * been modified by the block layer, so use the original
 			 * copy, bounce_copy_vec already uses tovec->bv_len
 			 */
-			vfrom = page_address(fromvec->bv_page) +
+			vfrom = page_address(fromvec.bv_page) +
 				tovec.bv_offset;
 
 			bounce_copy_vec(&tovec, vfrom);
 			flush_dcache_page(tovec.bv_page);
 		}
-
-		fromvec++;
+		bio_advance_iter(from, &from_iter, tovec.bv_len);
 	}
 }
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
