Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEE06B0266
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:31:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 5-v6so15530122qke.19
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:31:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x186-v6si1880391qkd.254.2018.06.09.05.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:31:37 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 05/30] block: introduce bio_for_each_chunk()
Date: Sat,  9 Jun 2018 20:29:49 +0800
Message-Id: <20180609123014.8861-6-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

This helper is used to iterate multipage bvec for bio spliting/merge,
and it is required in bio_clone_bioset() too, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 34 +++++++++++++++++++++++++++++++---
 include/linux/bvec.h | 36 ++++++++++++++++++++++++++++++++----
 2 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 397a38aca182..e9f74c73bbe6 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -80,6 +80,9 @@
 #define bio_data_dir(bio) \
 	(op_is_write(bio_op(bio)) ? WRITE : READ)
 
+#define bio_iter_chunk_iovec(bio, iter)				\
+	bvec_iter_chunk_bvec((bio)->bi_io_vec, (iter))
+
 /*
  * Check whether this bio carries any data or not. A NULL bio is allowed.
  */
@@ -165,8 +168,8 @@ static inline bool bio_full(struct bio *bio)
 #define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
-static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				    unsigned bytes)
+static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				      unsigned bytes, bool chunk)
 {
 	iter->bi_sector += bytes >> 9;
 
@@ -174,11 +177,26 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 		iter->bi_size -= bytes;
 		iter->bi_done += bytes;
 	} else {
-		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		if (!chunk)
+			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		else
+			bvec_iter_chunk_advance(bio->bi_io_vec, iter, bytes);
 		/* TODO: It is reasonable to complete bio with error here. */
 	}
 }
 
+static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				    unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, false);
+}
+
+static inline void bio_advance_chunk_iter(struct bio *bio, struct bvec_iter *iter,
+				       unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, true);
+}
+
 static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 		unsigned int bytes)
 {
@@ -202,6 +220,16 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_chunk(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = bio_iter_chunk_iovec((bio), (iter))), 1);	\
+	     bio_advance_chunk_iter((bio), &(iter), (bvl).bv_len))
+
+/* returns one real segment(multipage bvec) each time */
+#define bio_for_each_chunk(bvl, bio, iter)			\
+	__bio_for_each_chunk(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 52c90ea1a96a..9e082d023392 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -126,8 +126,16 @@ struct bvec_iter {
 	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
 })
 
-static inline bool bvec_iter_advance(const struct bio_vec *bv,
-		struct bvec_iter *iter, unsigned bytes)
+#define bvec_iter_chunk_bvec(bvec, iter)				\
+((struct bio_vec) {							\
+	.bv_page	= bvec_iter_chunk_page((bvec), (iter)),	\
+	.bv_len		= bvec_iter_chunk_len((bvec), (iter)),	\
+	.bv_offset	= bvec_iter_chunk_offset((bvec), (iter)),	\
+})
+
+static inline bool __bvec_iter_advance(const struct bio_vec *bv,
+				       struct bvec_iter *iter,
+				       unsigned bytes, bool chunk)
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
+		if (chunk)
+			len = bvec_iter_chunk_len(bv, *iter);
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
+static inline bool bvec_iter_chunk_advance(const struct bio_vec *bv,
+					   struct bvec_iter *iter,
+					   unsigned bytes)
+{
+	return __bvec_iter_advance(bv, iter, bytes, true);
+}
+
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-- 
2.9.5
