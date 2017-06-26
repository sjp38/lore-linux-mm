Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 006E66B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:19:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h15so46847163qte.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:19:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f28si6797444qte.360.2017.06.26.05.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:19:53 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 40/51] fs/block: convert to bio_for_each_segment_all_sp()
Date: Mon, 26 Jun 2017 20:10:23 +0800
Message-Id: <20170626121034.3051-41-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/block_dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index a57c26bcb970..d82e43bd8e82 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -209,6 +209,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	ssize_t ret;
 	blk_qc_t qc;
 	int i;
+	struct bvec_iter_all bia;
 
 	if ((pos | iov_iter_alignment(iter)) &
 	    (bdev_logical_block_size(bdev) - 1))
@@ -253,7 +254,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_segment_all(bvec, &bio, i) {
+	bio_for_each_segment_all_sp(bvec, &bio, i, bia) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -317,8 +318,9 @@ static void blkdev_bio_end_io(struct bio *bio)
 	} else {
 		struct bio_vec *bvec;
 		int i;
+		struct bvec_iter_all bia;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_segment_all_sp(bvec, bio, i, bia)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
