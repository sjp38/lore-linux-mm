Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3D076B026A
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:28:12 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 105so8821726oth.22
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:28:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f32si838830oth.244.2017.12.18.04.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:28:11 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 19/45] block: introduce bio_for_each_segment()
Date: Mon, 18 Dec 2017 20:22:21 +0800
Message-Id: <20171218122247.3488-20-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This helper is used to iterate multipage bvec for bio spliting/merge,
and it is required in bio_clone_bioset() too, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 34 +++++++++++++++++++++++++++++++---
 include/linux/bvec.h | 36 ++++++++++++++++++++++++++++++++----
 2 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 95ca5ddc72ef..0cb29c73ff27 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -76,6 +76,9 @@
 #define bio_data_dir(bio) \
 	(op_is_write(bio_op(bio)) ? WRITE : READ)
 
+#define bio_iter_seg_iovec(bio, iter)				\
+	bvec_iter_segment_bvec((bio)->bi_io_vec, (iter))
+
 /*
  * Check whether this bio carries any data or not. A NULL bio is allowed.
  */
@@ -156,8 +159,8 @@ static inline void *bio_data(struct bio *bio)
 #define bio_for_each_page_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
-static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				    unsigned bytes)
+static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				      unsigned bytes, bool seg)
 {
 	iter->bi_sector += bytes >> 9;
 
@@ -165,11 +168,26 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 		iter->bi_size -= bytes;
 		iter->bi_done += bytes;
 	} else {
-		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		if (!seg)
+			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		else
+			bvec_iter_seg_advance(bio->bi_io_vec, iter, bytes);
 		/* TODO: It is reasonable to complete bio with error here. */
 	}
 }
 
+static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				    unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, false);
+}
+
+static inline void bio_advance_seg_iter(struct bio *bio, struct bvec_iter *iter,
+				       unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, true);
+}
+
 static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 		unsigned int bytes)
 {
@@ -193,6 +211,16 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_page(bvl, bio, iter)				\
 	__bio_for_each_page(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_segment(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = bio_iter_seg_iovec((bio), (iter))), 1);		\
+	     bio_advance_seg_iter((bio), &(iter), (bvl).bv_len))
+
+/* returns one real segment(multipage bvec) each time */
+#define bio_for_each_segment(bvl, bio, iter)			\
+	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_pages(struct bio *bio)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 2433c73fa5ea..84c395feed49 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -126,8 +126,16 @@ struct bvec_iter {
 	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
 })
 
-static inline bool bvec_iter_advance(const struct bio_vec *bv,
-		struct bvec_iter *iter, unsigned bytes)
+#define bvec_iter_segment_bvec(bvec, iter)				\
+((struct bio_vec) {							\
+	.bv_page	= bvec_iter_segment_page((bvec), (iter)),	\
+	.bv_len		= bvec_iter_segment_len((bvec), (iter)),	\
+	.bv_offset	= bvec_iter_segment_offset((bvec), (iter)),	\
+})
+
+static inline bool __bvec_iter_advance(const struct bio_vec *bv,
+				       struct bvec_iter *iter,
+				       unsigned bytes, bool segment)
 {
 	if (WARN_ONCE(bytes > iter->bi_size,
 		     "Attempted to advance past end of bvec iter\n")) {
@@ -136,8 +144,14 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	}
 
 	while (bytes) {
-		unsigned iter_len = bvec_iter_len(bv, *iter);
-		unsigned len = min(bytes, iter_len);
+		unsigned len;
+
+		if (segment)
+			len = bvec_iter_segment_len(bv, *iter);
+		else
+			len = bvec_iter_len(bv, *iter);
+
+		len = min(bytes, len);
 
 		bytes -= len;
 		iter->bi_size -= len;
@@ -176,6 +190,20 @@ static inline bool bvec_iter_rewind(const struct bio_vec *bv,
 	return true;
 }
 
+static inline bool bvec_iter_advance(const struct bio_vec *bv,
+				     struct bvec_iter *iter,
+				     unsigned bytes)
+{
+	return __bvec_iter_advance(bv, iter, bytes, false);
+}
+
+static inline bool bvec_iter_seg_advance(const struct bio_vec *bv,
+					 struct bvec_iter *iter,
+					 unsigned bytes)
+{
+	return __bvec_iter_advance(bv, iter, bytes, true);
+}
+
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
