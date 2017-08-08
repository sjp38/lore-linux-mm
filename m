Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32ED76B04AA
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:51:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s26so12675917qts.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:51:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n188si782581qkb.219.2017.08.08.01.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:51:30 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 27/49] block: bio: introduce single/multi page version of bio_for_each_segment_all()
Date: Tue,  8 Aug 2017 16:45:26 +0800
Message-Id: <20170808084548.18963-28-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This patches introduce bio_for_each_segment_all_sp() and
bio_for_each_segment_all_mp().

bio_for_each_segment_all_sp() is for replacing bio_for_each_segment_all()
in case that the returned bvec has to be single page bvec.

bio_for_each_segment_all_mp() is for replacing bio_for_each_segment_all()
in case that user wants to update the returned bvec via the pointer.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h       | 24 ++++++++++++++++++++++++
 include/linux/blk_types.h |  6 ++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index ac8248558ab4..cd43b4b80472 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -232,6 +232,30 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment_mp(bvl, bio, iter)				\
 	__bio_for_each_segment_mp(bvl, bio, iter, (bio)->bi_iter)
 
+/*
+ * This helper returns each bvec stored in bvec table directly,
+ * so the returned bvec points to one multipage bvec in the table
+ * and caller can update the bvec via the returnd pointer.
+ */
+#define bio_for_each_segment_all_mp(bvl, bio, i)                       \
+	bio_for_each_segment_all((bvl), (bio), (i))
+
+/*
+ * This helper returns singlepage bvec to caller, and the sp bvec
+ * is generated in-flight from multipage bvec stored in bvec table.
+ * So we can _not_ change the bvec stored in bio->bi_io_vec[] via
+ * this helper.
+ *
+ * If someone need to update bvec in the table, please use
+ * bio_for_each_segment_all_mp() and make sure it is correctly used
+ * since the bvec points to one multipage bvec.
+ */
+#define bio_for_each_segment_all_sp(bvl, bio, i, bi)			\
+	for ((bi).iter = BVEC_ITER_ALL_INIT, i = 0, bvl = &(bi).bv;	\
+	     (bi).iter.bi_idx < (bio)->bi_vcnt &&			\
+		(((bi).bv = bio_iter_iovec((bio), (bi).iter)), 1);	\
+	     bio_advance_iter((bio), &(bi).iter, (bi).bv.bv_len), i++)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index d2eb87c84d82..99b47b7204fe 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -119,6 +119,12 @@ struct bio {
 
 #define BIO_RESET_BYTES		offsetof(struct bio, bi_max_vecs)
 
+/* this iter is only for implementing bio_for_each_segment_rd() */
+struct bvec_iter_all {
+	struct bvec_iter	iter;
+	struct bio_vec		bv;      /* in-flight singlepage bvec */
+};
+
 /*
  * bio flags
  */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
