Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0D126B03A9
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:16:30 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o142so48268488qke.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:16:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si11067905qkb.378.2017.06.26.05.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:16:29 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 22/51] block: introduce bio_for_each_segment_mp()
Date: Mon, 26 Jun 2017 20:10:05 +0800
Message-Id: <20170626121034.3051-23-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This helper is used to iterate multipage bvec and it is
required in bio_clone().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 39 ++++++++++++++++++++++++++++++++++-----
 include/linux/bvec.h | 37 ++++++++++++++++++++++++++++++++-----
 2 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index d425be4d1ced..bdbc9480229d 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -68,6 +68,9 @@
 #define bio_data_dir(bio) \
 	(op_is_write(bio_op(bio)) ? WRITE : READ)
 
+#define bio_iter_iovec_mp(bio, iter)				\
+	bvec_iter_bvec_mp((bio)->bi_io_vec, (iter))
+
 /*
  * Check whether this bio carries any data or not. A NULL bio is allowed.
  */
@@ -163,15 +166,31 @@ static inline void *bio_data(struct bio *bio)
 #define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
-static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				    unsigned bytes)
+static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				      unsigned bytes, bool mp)
 {
 	iter->bi_sector += bytes >> 9;
 
-	if (bio_no_advance_iter(bio))
+	if (bio_no_advance_iter(bio)) {
 		iter->bi_size -= bytes;
-	else
-		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+	} else {
+		if (!mp)
+			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		else
+			bvec_iter_advance_mp(bio->bi_io_vec, iter, bytes);
+	}
+}
+
+static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				    unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, false);
+}
+
+static inline void bio_advance_iter_mp(struct bio *bio, struct bvec_iter *iter,
+				       unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, true);
 }
 
 #define __bio_for_each_segment(bvl, bio, iter, start)			\
@@ -187,6 +206,16 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_segment_mp(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = bio_iter_iovec_mp((bio), (iter))), 1);		\
+	     bio_advance_iter_mp((bio), &(iter), (bvl).bv_len))
+
+/* returns one real segment(multipage bvec) each time */
+#define bio_for_each_segment_mp(bvl, bio, iter)				\
+	__bio_for_each_segment_mp(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 61632e9db3b8..5c51c58fe202 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -128,16 +128,29 @@ struct bvec_iter {
 	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
 })
 
-static inline void bvec_iter_advance(const struct bio_vec *bv,
-				     struct bvec_iter *iter,
-				     unsigned bytes)
+#define bvec_iter_bvec_mp(bvec, iter)				\
+((struct bio_vec) {						\
+	.bv_page	= bvec_iter_page_mp((bvec), (iter)),	\
+	.bv_len		= bvec_iter_len_mp((bvec), (iter)),	\
+	.bv_offset	= bvec_iter_offset_mp((bvec), (iter)),	\
+})
+
+static inline void __bvec_iter_advance(const struct bio_vec *bv,
+				       struct bvec_iter *iter,
+				       unsigned bytes, bool mp)
 {
 	WARN_ONCE(bytes > iter->bi_size,
 		  "Attempted to advance past end of bvec iter\n");
 
 	while (bytes) {
-		unsigned iter_len = bvec_iter_len(bv, *iter);
-		unsigned len = min(bytes, iter_len);
+		unsigned len;
+
+		if (mp)
+			len = bvec_iter_len_mp(bv, *iter);
+		else
+			len = bvec_iter_len_sp(bv, *iter);
+
+		len = min(bytes, len);
 
 		bytes -= len;
 		iter->bi_size -= len;
@@ -150,6 +163,20 @@ static inline void bvec_iter_advance(const struct bio_vec *bv,
 	}
 }
 
+static inline void bvec_iter_advance(const struct bio_vec *bv,
+				     struct bvec_iter *iter,
+				     unsigned bytes)
+{
+	__bvec_iter_advance(bv, iter, bytes, false);
+}
+
+static inline void bvec_iter_advance_mp(const struct bio_vec *bv,
+					struct bvec_iter *iter,
+					unsigned bytes)
+{
+	__bvec_iter_advance(bv, iter, bytes, true);
+}
+
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
