Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 679F56B2396
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:25:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u20so2180625qtk.6
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:25:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n127si4589244qkf.230.2018.11.20.19.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 19:25:31 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V11 03/19] block: introduce bio_for_each_bvec()
Date: Wed, 21 Nov 2018 11:23:11 +0800
Message-Id: <20181121032327.8434-4-ming.lei@redhat.com>
In-Reply-To: <20181121032327.8434-1-ming.lei@redhat.com>
References: <20181121032327.8434-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

This helper is used for iterating over multi-page bvec for bio
split & merge code.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 25 ++++++++++++++++++++++---
 include/linux/bvec.h | 36 +++++++++++++++++++++++++++++-------
 2 files changed, 51 insertions(+), 10 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 056fb627edb3..7560209d6a8a 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -76,6 +76,9 @@
 #define bio_data_dir(bio) \
 	(op_is_write(bio_op(bio)) ? WRITE : READ)
 
+#define bio_iter_mp_iovec(bio, iter)				\
+	segment_iter_bvec((bio)->bi_io_vec, (iter))
+
 /*
  * Check whether this bio carries any data or not. A NULL bio is allowed.
  */
@@ -135,18 +138,24 @@ static inline bool bio_full(struct bio *bio)
 #define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
-static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				    unsigned bytes)
+static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				      unsigned bytes, unsigned max_seg_len)
 {
 	iter->bi_sector += bytes >> 9;
 
 	if (bio_no_advance_iter(bio))
 		iter->bi_size -= bytes;
 	else
-		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		__bvec_iter_advance(bio->bi_io_vec, iter, bytes, max_seg_len);
 		/* TODO: It is reasonable to complete bio with error here. */
 }
 
+static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
+				    unsigned bytes)
+{
+	__bio_advance_iter(bio, iter, bytes, PAGE_SIZE);
+}
+
 #define __bio_for_each_segment(bvl, bio, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
@@ -156,6 +165,16 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_bvec(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = bio_iter_mp_iovec((bio), (iter))), 1);	\
+	     __bio_advance_iter((bio), &(iter), (bvl).bv_len, BVEC_MAX_LEN))
+
+/* returns one real segment(multi-page bvec) each time */
+#define bio_for_each_bvec(bvl, bio, iter)			\
+	__bio_for_each_bvec(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index ed90bbf4c9c9..b279218c5c4d 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -25,6 +25,8 @@
 #include <linux/errno.h>
 #include <linux/mm.h>
 
+#define BVEC_MAX_LEN  ((unsigned int)-1)
+
 /*
  * was unsigned short, but we might as well be ready for > 64kB I/O pages
  */
@@ -87,8 +89,15 @@ struct bvec_iter {
 	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
 })
 
-static inline bool bvec_iter_advance(const struct bio_vec *bv,
-		struct bvec_iter *iter, unsigned bytes)
+#define segment_iter_bvec(bvec, iter)				\
+((struct bio_vec) {							\
+	.bv_page	= segment_iter_page((bvec), (iter)),	\
+	.bv_len		= segment_iter_len((bvec), (iter)),	\
+	.bv_offset	= segment_iter_offset((bvec), (iter)),	\
+})
+
+static inline bool __bvec_iter_advance(const struct bio_vec *bv,
+		struct bvec_iter *iter, unsigned bytes, unsigned max_seg_len)
 {
 	if (WARN_ONCE(bytes > iter->bi_size,
 		     "Attempted to advance past end of bvec iter\n")) {
@@ -97,12 +106,18 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	}
 
 	while (bytes) {
-		unsigned iter_len = bvec_iter_len(bv, *iter);
-		unsigned len = min(bytes, iter_len);
+		unsigned segment_len = segment_iter_len(bv, *iter);
 
-		bytes -= len;
-		iter->bi_size -= len;
-		iter->bi_bvec_done += len;
+		if (max_seg_len < BVEC_MAX_LEN)
+			segment_len = min_t(unsigned, segment_len,
+					    max_seg_len -
+					    bvec_iter_offset(bv, *iter));
+
+		segment_len = min(bytes, segment_len);
+
+		bytes -= segment_len;
+		iter->bi_size -= segment_len;
+		iter->bi_bvec_done += segment_len;
 
 		if (iter->bi_bvec_done == __bvec_iter_bvec(bv, *iter)->bv_len) {
 			iter->bi_bvec_done = 0;
@@ -136,6 +151,13 @@ static inline bool bvec_iter_rewind(const struct bio_vec *bv,
 	return true;
 }
 
+static inline bool bvec_iter_advance(const struct bio_vec *bv,
+				     struct bvec_iter *iter,
+				     unsigned bytes)
+{
+	return __bvec_iter_advance(bv, iter, bytes, PAGE_SIZE);
+}
+
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-- 
2.9.5
