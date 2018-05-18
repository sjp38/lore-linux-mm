Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0C96B058D
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:50:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y62-v6so6200843qkb.15
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:50:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t29-v6sor5684591qtg.13.2018.05.18.00.50.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:50:08 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 06/10] block: Split out bio_list_copy_data()
Date: Fri, 18 May 2018 03:49:09 -0400
Message-Id: <20180518074918.13816-12-kent.overstreet@gmail.com>
In-Reply-To: <20180518074918.13816-1-kent.overstreet@gmail.com>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Found a bug (with ASAN) where we were passing a bio to bio_copy_data()
with bi_next not NULL, when it should have been - a driver had left
bi_next set to something after calling bio_endio().

Since the normal case is only copying single bios, split out
bio_list_copy_data() to avoid more bugs like this in the future.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c             | 83 +++++++++++++++++++++++++----------------
 drivers/block/pktcdvd.c |  2 +-
 include/linux/bio.h     |  5 ++-
 3 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index d7bd765e9e..c58544d4bc 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -971,32 +971,16 @@ void bio_advance(struct bio *bio, unsigned bytes)
 }
 EXPORT_SYMBOL(bio_advance);
 
-void bio_copy_data_iter(struct bio *dst, struct bvec_iter dst_iter,
-			struct bio *src, struct bvec_iter src_iter)
+void bio_copy_data_iter(struct bio *dst, struct bvec_iter *dst_iter,
+			struct bio *src, struct bvec_iter *src_iter)
 {
 	struct bio_vec src_bv, dst_bv;
 	void *src_p, *dst_p;
 	unsigned bytes;
 
-	while (1) {
-		if (!src_iter.bi_size) {
-			src = src->bi_next;
-			if (!src)
-				break;
-
-			src_iter = src->bi_iter;
-		}
-
-		if (!dst_iter.bi_size) {
-			dst = dst->bi_next;
-			if (!dst)
-				break;
-
-			dst_iter = dst->bi_iter;
-		}
-
-		src_bv = bio_iter_iovec(src, src_iter);
-		dst_bv = bio_iter_iovec(dst, dst_iter);
+	while (src_iter->bi_size && dst_iter->bi_size) {
+		src_bv = bio_iter_iovec(src, *src_iter);
+		dst_bv = bio_iter_iovec(dst, *dst_iter);
 
 		bytes = min(src_bv.bv_len, dst_bv.bv_len);
 
@@ -1010,31 +994,66 @@ void bio_copy_data_iter(struct bio *dst, struct bvec_iter dst_iter,
 		kunmap_atomic(dst_p);
 		kunmap_atomic(src_p);
 
-		bio_advance_iter(src, &src_iter, bytes);
-		bio_advance_iter(dst, &dst_iter, bytes);
+		bio_advance_iter(src, src_iter, bytes);
+		bio_advance_iter(dst, dst_iter, bytes);
 	}
 }
 EXPORT_SYMBOL(bio_copy_data_iter);
 
 /**
- * bio_copy_data - copy contents of data buffers from one chain of bios to
- * another
- * @src: source bio list
- * @dst: destination bio list
- *
- * If @src and @dst are single bios, bi_next must be NULL - otherwise, treats
- * @src and @dst as linked lists of bios.
+ * bio_copy_data - copy contents of data buffers from one bio to another
+ * @src: source bio
+ * @dst: destination bio
  *
  * Stops when it reaches the end of either @src or @dst - that is, copies
  * min(src->bi_size, dst->bi_size) bytes (or the equivalent for lists of bios).
  */
 void bio_copy_data(struct bio *dst, struct bio *src)
 {
-	bio_copy_data_iter(dst, dst->bi_iter,
-			   src, src->bi_iter);
+	struct bvec_iter src_iter = src->bi_iter;
+	struct bvec_iter dst_iter = dst->bi_iter;
+
+	bio_copy_data_iter(dst, &dst_iter, src, &src_iter);
 }
 EXPORT_SYMBOL(bio_copy_data);
 
+/**
+ * bio_list_copy_data - copy contents of data buffers from one chain of bios to
+ * another
+ * @src: source bio list
+ * @dst: destination bio list
+ *
+ * Stops when it reaches the end of either the @src list or @dst list - that is,
+ * copies min(src->bi_size, dst->bi_size) bytes (or the equivalent for lists of
+ * bios).
+ */
+void bio_list_copy_data(struct bio *dst, struct bio *src)
+{
+	struct bvec_iter src_iter = src->bi_iter;
+	struct bvec_iter dst_iter = dst->bi_iter;
+
+	while (1) {
+		if (!src_iter.bi_size) {
+			src = src->bi_next;
+			if (!src)
+				break;
+
+			src_iter = src->bi_iter;
+		}
+
+		if (!dst_iter.bi_size) {
+			dst = dst->bi_next;
+			if (!dst)
+				break;
+
+			dst_iter = dst->bi_iter;
+		}
+
+		bio_copy_data_iter(dst, &dst_iter, src, &src_iter);
+	}
+}
+EXPORT_SYMBOL(bio_list_copy_data);
+
 struct bio_map_data {
 	int is_our_pages;
 	struct iov_iter iter;
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index c61d20c9f3..00ea788b17 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -1285,7 +1285,7 @@ static void pkt_start_write(struct pktcdvd_device *pd, struct packet_data *pkt)
 	 * Fill-in bvec with data from orig_bios.
 	 */
 	spin_lock(&pkt->lock);
-	bio_copy_data(pkt->w_bio, pkt->orig_bios.head);
+	bio_list_copy_data(pkt->w_bio, pkt->orig_bios.head);
 
 	pkt_set_state(pkt, PACKET_WRITE_WAIT_STATE);
 	spin_unlock(&pkt->lock);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 5a6ee955a8..98b175cc00 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -505,9 +505,10 @@ static inline void bio_flush_dcache_pages(struct bio *bi)
 }
 #endif
 
-extern void bio_copy_data_iter(struct bio *dst, struct bvec_iter dst_iter,
-			       struct bio *src, struct bvec_iter src_iter);
+extern void bio_copy_data_iter(struct bio *dst, struct bvec_iter *dst_iter,
+			       struct bio *src, struct bvec_iter *src_iter);
 extern void bio_copy_data(struct bio *dst, struct bio *src);
+extern void bio_list_copy_data(struct bio *dst, struct bio *src);
 extern void bio_free_pages(struct bio *bio);
 
 extern struct bio *bio_copy_user_iov(struct request_queue *,
-- 
2.17.0
