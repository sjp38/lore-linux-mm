Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55CB66B0294
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:47:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c4-v6so2919677qtp.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:47:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j23-v6si13371qtl.150.2018.05.24.20.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:47:50 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 05/33] block: introduce bio_for_each_segment()
Date: Fri, 25 May 2018 11:45:53 +0800
Message-Id: <20180525034621.31147-6-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This helper is used to iterate multipage bvec for bio spliting/merge,
and it is required in bio_clone_bioset() too, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 34 +++++++++++++++++++++++++++++++---
 include/linux/bvec.h | 36 ++++++++++++++++++++++++++++++++----
 2 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 7f92af1299ad..3d3795b9a353 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -80,6 +80,9 @@
 #define bio_data_dir(bio) \
 	(op_is_write(bio_op(bio)) ? WRITE : READ)
 
+#define bio_iter_seg_iovec(bio, iter)				\
+	bvec_iter_segment_bvec((bio)->bi_io_vec, (iter))
+
 /*
  * Check whether this bio carries any data or not. A NULL bio is allowed.
  */
@@ -160,8 +163,8 @@ static inline void *bio_data(struct bio *bio)
 #define bio_for_each_page_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
-static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				    unsigned bytes)
+static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				      unsigned bytes, bool seg)
 {
 	iter->bi_sector += bytes >> 9;
 
@@ -169,11 +172,26 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
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
@@ -197,6 +215,16 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
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
