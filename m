Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF6BD6B3F70
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:18:50 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z68so18196692qkb.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:18:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x24si7048434qtp.214.2018.11.25.18.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:18:49 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 06/20] block: rename bvec helpers
Date: Mon, 26 Nov 2018 10:17:06 +0800
Message-Id: <20181126021720.19471-7-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

We will support multi-page bvec soon, and have to deal with
single-page vs multi-page bvec. This patch follows Christoph's
suggestion to rename all the following helpers:

	for_each_bvec
	bvec_iter_bvec
	bvec_iter_len
	bvec_iter_page
	bvec_iter_offset

into:
	for_each_segment
	segment_iter_bvec
	segment_iter_len
	segment_iter_page
	segment_iter_offset

so that these helpers named with 'segment' only deal with single-page
bvec, or called segment. We will introduce helpers named with 'bvec'
for multi-page bvec.

bvec_iter_advance() isn't renamed becasue this helper is always operated
on real bvec even though multi-page bvec is supported.

Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 .clang-format                  |  2 +-
 drivers/md/dm-integrity.c      |  2 +-
 drivers/md/dm-io.c             |  4 ++--
 drivers/nvdimm/blk.c           |  4 ++--
 drivers/nvdimm/btt.c           |  4 ++--
 include/linux/bio.h            | 10 +++++-----
 include/linux/bvec.h           | 20 +++++++++++---------
 include/linux/ceph/messenger.h |  2 +-
 lib/iov_iter.c                 |  2 +-
 net/ceph/messenger.c           | 14 +++++++-------
 10 files changed, 33 insertions(+), 31 deletions(-)

diff --git a/.clang-format b/.clang-format
index e6080f5834a3..049200fbab94 100644
--- a/.clang-format
+++ b/.clang-format
@@ -120,7 +120,7 @@ ForEachMacros:
   - 'for_each_available_child_of_node'
   - 'for_each_bio'
   - 'for_each_board_func_rsrc'
-  - 'for_each_bvec'
+  - 'for_each_segment'
   - 'for_each_child_of_node'
   - 'for_each_clear_bit'
   - 'for_each_clear_bit_from'
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index bb3096bf2cc6..bb037ed2b4eb 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -1574,7 +1574,7 @@ static bool __journal_read_write(struct dm_integrity_io *dio, struct bio *bio,
 				char *tag_ptr = journal_entry_tag(ic, je);
 
 				if (bip) do {
-					struct bio_vec biv = bvec_iter_bvec(bip->bip_vec, bip->bip_iter);
+					struct bio_vec biv = segment_iter_bvec(bip->bip_vec, bip->bip_iter);
 					unsigned tag_now = min(biv.bv_len, tag_todo);
 					char *tag_addr;
 					BUG_ON(PageHighMem(biv.bv_page));
diff --git a/drivers/md/dm-io.c b/drivers/md/dm-io.c
index 81ffc59d05c9..d72ec2bdd333 100644
--- a/drivers/md/dm-io.c
+++ b/drivers/md/dm-io.c
@@ -208,8 +208,8 @@ static void list_dp_init(struct dpages *dp, struct page_list *pl, unsigned offse
 static void bio_get_page(struct dpages *dp, struct page **p,
 			 unsigned long *len, unsigned *offset)
 {
-	struct bio_vec bvec = bvec_iter_bvec((struct bio_vec *)dp->context_ptr,
-					     dp->context_bi);
+	struct bio_vec bvec = segment_iter_bvec((struct bio_vec *)dp->context_ptr,
+						dp->context_bi);
 
 	*p = bvec.bv_page;
 	*len = bvec.bv_len;
diff --git a/drivers/nvdimm/blk.c b/drivers/nvdimm/blk.c
index db45c6bbb7bb..dfae945216bb 100644
--- a/drivers/nvdimm/blk.c
+++ b/drivers/nvdimm/blk.c
@@ -89,9 +89,9 @@ static int nd_blk_rw_integrity(struct nd_namespace_blk *nsblk,
 		struct bio_vec bv;
 		void *iobuf;
 
-		bv = bvec_iter_bvec(bip->bip_vec, bip->bip_iter);
+		bv = segment_iter_bvec(bip->bip_vec, bip->bip_iter);
 		/*
-		 * The 'bv' obtained from bvec_iter_bvec has its .bv_len and
+		 * The 'bv' obtained from segment_iter_bvec has its .bv_len and
 		 * .bv_offset already adjusted for iter->bi_bvec_done, and we
 		 * can use those directly
 		 */
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index b123b0dcf274..2bbbc90c7b91 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -1154,9 +1154,9 @@ static int btt_rw_integrity(struct btt *btt, struct bio_integrity_payload *bip,
 		struct bio_vec bv;
 		void *mem;
 
-		bv = bvec_iter_bvec(bip->bip_vec, bip->bip_iter);
+		bv = segment_iter_bvec(bip->bip_vec, bip->bip_iter);
 		/*
-		 * The 'bv' obtained from bvec_iter_bvec has its .bv_len and
+		 * The 'bv' obtained from segment_iter_bvec has its .bv_len and
 		 * .bv_offset already adjusted for iter->bi_bvec_done, and we
 		 * can use those directly
 		 */
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 6f6bc331a5d1..6a0ff02f4d1c 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -48,14 +48,14 @@
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
 
 #define bio_iter_iovec(bio, iter)				\
-	bvec_iter_bvec((bio)->bi_io_vec, (iter))
+	segment_iter_bvec((bio)->bi_io_vec, (iter))
 
 #define bio_iter_page(bio, iter)				\
-	bvec_iter_page((bio)->bi_io_vec, (iter))
+	segment_iter_page((bio)->bi_io_vec, (iter))
 #define bio_iter_len(bio, iter)					\
-	bvec_iter_len((bio)->bi_io_vec, (iter))
+	segment_iter_len((bio)->bi_io_vec, (iter))
 #define bio_iter_offset(bio, iter)				\
-	bvec_iter_offset((bio)->bi_io_vec, (iter))
+	segment_iter_offset((bio)->bi_io_vec, (iter))
 
 #define bio_page(bio)		bio_iter_page((bio), (bio)->bi_iter)
 #define bio_offset(bio)		bio_iter_offset((bio), (bio)->bi_iter)
@@ -733,7 +733,7 @@ static inline bool bioset_initialized(struct bio_set *bs)
 #if defined(CONFIG_BLK_DEV_INTEGRITY)
 
 #define bip_for_each_vec(bvl, bip, iter)				\
-	for_each_bvec(bvl, (bip)->bip_vec, iter, (bip)->bip_iter)
+	for_each_segment(bvl, (bip)->bip_vec, iter, (bip)->bip_iter)
 
 #define bio_for_each_integrity_vec(_bvl, _bio, _iter)			\
 	for_each_bio(_bio)						\
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index ba0ae40e77c9..716a87b26a6a 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -50,23 +50,25 @@ struct bvec_iter {
  */
 #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
 
-#define bvec_iter_page(bvec, iter)				\
+#define segment_iter_page(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_page)
 
-#define bvec_iter_len(bvec, iter)				\
+#define segment_iter_len(bvec, iter)				\
 	min((iter).bi_size,					\
 	    __bvec_iter_bvec((bvec), (iter))->bv_len - (iter).bi_bvec_done)
 
-#define bvec_iter_offset(bvec, iter)				\
+#define segment_iter_offset(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_offset + (iter).bi_bvec_done)
 
-#define bvec_iter_bvec(bvec, iter)				\
+#define segment_iter_bvec(bvec, iter)				\
 ((struct bio_vec) {						\
-	.bv_page	= bvec_iter_page((bvec), (iter)),	\
-	.bv_len		= bvec_iter_len((bvec), (iter)),	\
-	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
+	.bv_page	= segment_iter_page((bvec), (iter)),	\
+	.bv_len		= segment_iter_len((bvec), (iter)),	\
+	.bv_offset	= segment_iter_offset((bvec), (iter)),	\
 })
 
+#define bvec_iter_len  segment_iter_len
+
 static inline bool bvec_iter_advance(const struct bio_vec *bv,
 		struct bvec_iter *iter, unsigned bytes)
 {
@@ -92,10 +94,10 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	return true;
 }
 
-#define for_each_bvec(bvl, bio_vec, iter, start)			\
+#define for_each_segment(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-		((bvl = bvec_iter_bvec((bio_vec), (iter))), 1);	\
+		((bvl = segment_iter_bvec((bio_vec), (iter))), 1);	\
 	     bvec_iter_advance((bio_vec), &(iter), (bvl).bv_len))
 
 /* for iterating one bio from start to end */
diff --git a/include/linux/ceph/messenger.h b/include/linux/ceph/messenger.h
index 800a2128d411..c7e37a7229c4 100644
--- a/include/linux/ceph/messenger.h
+++ b/include/linux/ceph/messenger.h
@@ -155,7 +155,7 @@ struct ceph_bvec_iter {
 									      \
 		__cur_iter = (it)->iter;				      \
 		__cur_iter.bi_size = (n);				      \
-		for_each_bvec(bv, (it)->bvecs, __cur_iter, __cur_iter)	      \
+		for_each_segment(bv, (it)->bvecs, __cur_iter, __cur_iter)     \
 			(void)(BVEC_STEP);				      \
 	}))
 
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 7ebccb5c1637..e34eef12740f 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -65,7 +65,7 @@
 	__start.bi_size = n;				\
 	__start.bi_bvec_done = skip;			\
 	__start.bi_idx = 0;				\
-	for_each_bvec(__v, i->bvec, __bi, __start) {	\
+	for_each_segment(__v, i->bvec, __bi, __start) {	\
 		if (!__v.bv_len)			\
 			continue;			\
 		(void)(STEP);				\
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 57fcc6b4bf6e..c543426ace9f 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -889,17 +889,17 @@ static void ceph_msg_data_bvecs_cursor_init(struct ceph_msg_data_cursor *cursor,
 	cursor->bvec_iter = data->bvec_pos.iter;
 	cursor->bvec_iter.bi_size = cursor->resid;
 
-	BUG_ON(cursor->resid < bvec_iter_len(bvecs, cursor->bvec_iter));
+	BUG_ON(cursor->resid < segment_iter_len(bvecs, cursor->bvec_iter));
 	cursor->last_piece =
-	    cursor->resid == bvec_iter_len(bvecs, cursor->bvec_iter);
+	    cursor->resid == segment_iter_len(bvecs, cursor->bvec_iter);
 }
 
 static struct page *ceph_msg_data_bvecs_next(struct ceph_msg_data_cursor *cursor,
 						size_t *page_offset,
 						size_t *length)
 {
-	struct bio_vec bv = bvec_iter_bvec(cursor->data->bvec_pos.bvecs,
-					   cursor->bvec_iter);
+	struct bio_vec bv = segment_iter_bvec(cursor->data->bvec_pos.bvecs,
+					      cursor->bvec_iter);
 
 	*page_offset = bv.bv_offset;
 	*length = bv.bv_len;
@@ -912,7 +912,7 @@ static bool ceph_msg_data_bvecs_advance(struct ceph_msg_data_cursor *cursor,
 	struct bio_vec *bvecs = cursor->data->bvec_pos.bvecs;
 
 	BUG_ON(bytes > cursor->resid);
-	BUG_ON(bytes > bvec_iter_len(bvecs, cursor->bvec_iter));
+	BUG_ON(bytes > segment_iter_len(bvecs, cursor->bvec_iter));
 	cursor->resid -= bytes;
 	bvec_iter_advance(bvecs, &cursor->bvec_iter, bytes);
 
@@ -925,9 +925,9 @@ static bool ceph_msg_data_bvecs_advance(struct ceph_msg_data_cursor *cursor,
 		return false;	/* more bytes to process in this segment */
 
 	BUG_ON(cursor->last_piece);
-	BUG_ON(cursor->resid < bvec_iter_len(bvecs, cursor->bvec_iter));
+	BUG_ON(cursor->resid < segment_iter_len(bvecs, cursor->bvec_iter));
 	cursor->last_piece =
-	    cursor->resid == bvec_iter_len(bvecs, cursor->bvec_iter);
+	    cursor->resid == segment_iter_len(bvecs, cursor->bvec_iter);
 	return true;
 }
 
-- 
2.9.5
