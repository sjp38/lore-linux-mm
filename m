Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 335756B0310
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c21so17760077qkg.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13-v6sor14930534qto.22.2018.05.08.18.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:23 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 05/10] block: Add bio_copy_data_iter(), zero_fill_bio_iter()
Date: Tue,  8 May 2018 21:33:53 -0400
Message-Id: <20180509013358.16399-6-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Add versions that take bvec_iter args instead of using bio->bi_iter - to
be used by bcachefs.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c         | 44 ++++++++++++++++++++++++--------------------
 include/linux/bio.h | 18 +++++++++++++++---
 2 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index b7cdad6fc4..d7bd765e9e 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -530,20 +530,20 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 }
 EXPORT_SYMBOL(bio_alloc_bioset);
 
-void zero_fill_bio(struct bio *bio)
+void zero_fill_bio_iter(struct bio *bio, struct bvec_iter start)
 {
 	unsigned long flags;
 	struct bio_vec bv;
 	struct bvec_iter iter;
 
-	bio_for_each_segment(bv, bio, iter) {
+	__bio_for_each_segment(bv, bio, iter, start) {
 		char *data = bvec_kmap_irq(&bv, &flags);
 		memset(data, 0, bv.bv_len);
 		flush_dcache_page(bv.bv_page);
 		bvec_kunmap_irq(data, &flags);
 	}
 }
-EXPORT_SYMBOL(zero_fill_bio);
+EXPORT_SYMBOL(zero_fill_bio_iter);
 
 /**
  * bio_put - release a reference to a bio
@@ -971,28 +971,13 @@ void bio_advance(struct bio *bio, unsigned bytes)
 }
 EXPORT_SYMBOL(bio_advance);
 
-/**
- * bio_copy_data - copy contents of data buffers from one chain of bios to
- * another
- * @src: source bio list
- * @dst: destination bio list
- *
- * If @src and @dst are single bios, bi_next must be NULL - otherwise, treats
- * @src and @dst as linked lists of bios.
- *
- * Stops when it reaches the end of either @src or @dst - that is, copies
- * min(src->bi_size, dst->bi_size) bytes (or the equivalent for lists of bios).
- */
-void bio_copy_data(struct bio *dst, struct bio *src)
+void bio_copy_data_iter(struct bio *dst, struct bvec_iter dst_iter,
+			struct bio *src, struct bvec_iter src_iter)
 {
-	struct bvec_iter src_iter, dst_iter;
 	struct bio_vec src_bv, dst_bv;
 	void *src_p, *dst_p;
 	unsigned bytes;
 
-	src_iter = src->bi_iter;
-	dst_iter = dst->bi_iter;
-
 	while (1) {
 		if (!src_iter.bi_size) {
 			src = src->bi_next;
@@ -1029,6 +1014,25 @@ void bio_copy_data(struct bio *dst, struct bio *src)
 		bio_advance_iter(dst, &dst_iter, bytes);
 	}
 }
+EXPORT_SYMBOL(bio_copy_data_iter);
+
+/**
+ * bio_copy_data - copy contents of data buffers from one chain of bios to
+ * another
+ * @src: source bio list
+ * @dst: destination bio list
+ *
+ * If @src and @dst are single bios, bi_next must be NULL - otherwise, treats
+ * @src and @dst as linked lists of bios.
+ *
+ * Stops when it reaches the end of either @src or @dst - that is, copies
+ * min(src->bi_size, dst->bi_size) bytes (or the equivalent for lists of bios).
+ */
+void bio_copy_data(struct bio *dst, struct bio *src)
+{
+	bio_copy_data_iter(dst, dst->bi_iter,
+			   src, src->bi_iter);
+}
 EXPORT_SYMBOL(bio_copy_data);
 
 struct bio_map_data {
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 91b02520e2..5a6ee955a8 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -67,8 +67,12 @@
 
 #define bio_multiple_segments(bio)				\
 	((bio)->bi_iter.bi_size != bio_iovec(bio).bv_len)
-#define bio_sectors(bio)	((bio)->bi_iter.bi_size >> 9)
-#define bio_end_sector(bio)	((bio)->bi_iter.bi_sector + bio_sectors((bio)))
+
+#define bvec_iter_sectors(iter)	((iter).bi_size >> 9)
+#define bvec_iter_end_sector(iter) ((iter).bi_sector + bvec_iter_sectors((iter)))
+
+#define bio_sectors(bio)	bvec_iter_sectors((bio)->bi_iter)
+#define bio_end_sector(bio)	bvec_iter_end_sector((bio)->bi_iter)
 
 /*
  * Return the data direction, READ or WRITE.
@@ -501,6 +505,8 @@ static inline void bio_flush_dcache_pages(struct bio *bi)
 }
 #endif
 
+extern void bio_copy_data_iter(struct bio *dst, struct bvec_iter dst_iter,
+			       struct bio *src, struct bvec_iter src_iter);
 extern void bio_copy_data(struct bio *dst, struct bio *src);
 extern void bio_free_pages(struct bio *bio);
 
@@ -509,7 +515,13 @@ extern struct bio *bio_copy_user_iov(struct request_queue *,
 				     struct iov_iter *,
 				     gfp_t);
 extern int bio_uncopy_user(struct bio *);
-void zero_fill_bio(struct bio *bio);
+void zero_fill_bio_iter(struct bio *bio, struct bvec_iter iter);
+
+static inline void zero_fill_bio(struct bio *bio)
+{
+	zero_fill_bio_iter(bio, bio->bi_iter);
+}
+
 extern struct bio_vec *bvec_alloc(gfp_t, int, unsigned long *, mempool_t *);
 extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
 extern unsigned int bvec_nr_vecs(unsigned short idx);
-- 
2.17.0
