Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54BD96B04D3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:55:04 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d136so12892862qkg.11
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:55:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t35si780539qte.301.2017.08.08.01.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:55:03 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 48/49] block: enable multipage bvecs
Date: Tue,  8 Aug 2017 16:45:47 +0800
Message-Id: <20170808084548.18963-49-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This patch pulls the trigger for multipage bvecs.

Now any request queue which supports queue cluster
will see multipage bvecs.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/block/bio.c b/block/bio.c
index fd6a055f491c..a5f7fd4ef818 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -844,6 +844,11 @@ int bio_add_page(struct bio *bio, struct page *page,
 	 * a consecutive offset.  Optimize this special case.
 	 */
 	if (bio->bi_vcnt > 0) {
+		struct request_queue *q = NULL;
+
+		if (bio->bi_bdev)
+			q = bdev_get_queue(bio->bi_bdev);
+
 		bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
 
 		if (page == bv->bv_page &&
@@ -851,6 +856,14 @@ int bio_add_page(struct bio *bio, struct page *page,
 			bv->bv_len += len;
 			goto done;
 		}
+
+		/* disable multipage bvec too if cluster isn't enabled */
+		if (q && blk_queue_cluster(q) &&
+		    (bvec_to_phys(bv) + bv->bv_len ==
+		     page_to_phys(page) + offset)) {
+			bv->bv_len += len;
+			goto done;
+		}
 	}
 
 	if (bio->bi_vcnt >= bio->bi_max_vecs)
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
