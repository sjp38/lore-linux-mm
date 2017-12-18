Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0C616B0273
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:24:57 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id v8so8915854otd.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:24:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e203si3723327oia.330.2017.12.18.04.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:24:56 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 08/45] block: move bio_alloc_pages() to bcache
Date: Mon, 18 Dec 2017 20:22:10 +0800
Message-Id: <20171218122247.3488-9-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bcache is the only user of bio_alloc_pages(), so move this function into
bcache, and avoid it misused in future.

Also rename it as bch_bio_allo_pages() since it is bcache only.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c                   | 28 ----------------------------
 drivers/md/bcache/btree.c     |  2 +-
 drivers/md/bcache/debug.c     |  2 +-
 drivers/md/bcache/movinggc.c  |  2 +-
 drivers/md/bcache/request.c   |  2 +-
 drivers/md/bcache/util.c      | 27 +++++++++++++++++++++++++++
 drivers/md/bcache/util.h      |  1 +
 drivers/md/bcache/writeback.c |  2 +-
 include/linux/bio.h           |  1 -
 9 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 8bfdea58159b..fe1efbeaf4aa 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -969,34 +969,6 @@ void bio_advance(struct bio *bio, unsigned bytes)
 EXPORT_SYMBOL(bio_advance);
 
 /**
- * bio_alloc_pages - allocates a single page for each bvec in a bio
- * @bio: bio to allocate pages for
- * @gfp_mask: flags for allocation
- *
- * Allocates pages up to @bio->bi_vcnt.
- *
- * Returns 0 on success, -ENOMEM on failure. On failure, any allocated pages are
- * freed.
- */
-int bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
-{
-	int i;
-	struct bio_vec *bv;
-
-	bio_for_each_segment_all(bv, bio, i) {
-		bv->bv_page = alloc_page(gfp_mask);
-		if (!bv->bv_page) {
-			while (--bv >= bio->bi_io_vec)
-				__free_page(bv->bv_page);
-			return -ENOMEM;
-		}
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(bio_alloc_pages);
-
-/**
  * bio_copy_data - copy contents of data buffers from one chain of bios to
  * another
  * @src: source bio list
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 02a4cf646fdc..ebb1874218e7 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -419,7 +419,7 @@ static void do_btree_node_write(struct btree *b)
 	SET_PTR_OFFSET(&k.key, 0, PTR_OFFSET(&k.key, 0) +
 		       bset_sector_offset(&b->keys, i));
 
-	if (!bio_alloc_pages(b->bio, __GFP_NOWARN|GFP_NOWAIT)) {
+	if (!bch_bio_alloc_pages(b->bio, __GFP_NOWARN|GFP_NOWAIT)) {
 		int j;
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index c7a02c4900da..879ab21074c6 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -116,7 +116,7 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 		return;
 	check->bi_opf = REQ_OP_READ;
 
-	if (bio_alloc_pages(check, GFP_NOIO))
+	if (bch_bio_alloc_pages(check, GFP_NOIO))
 		goto out_put;
 
 	submit_bio_wait(check);
diff --git a/drivers/md/bcache/movinggc.c b/drivers/md/bcache/movinggc.c
index d50c1c97da68..a24c3a95b2c0 100644
--- a/drivers/md/bcache/movinggc.c
+++ b/drivers/md/bcache/movinggc.c
@@ -162,7 +162,7 @@ static void read_moving(struct cache_set *c)
 		bio_set_op_attrs(bio, REQ_OP_READ, 0);
 		bio->bi_end_io	= read_moving_endio;
 
-		if (bio_alloc_pages(bio, GFP_KERNEL))
+		if (bch_bio_alloc_pages(bio, GFP_KERNEL))
 			goto err;
 
 		trace_bcache_gc_copy(&w->key);
diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
index 643c3021624f..c493fb947dc9 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -841,7 +841,7 @@ static int cached_dev_cache_miss(struct btree *b, struct search *s,
 	cache_bio->bi_private	= &s->cl;
 
 	bch_bio_map(cache_bio, NULL);
-	if (bio_alloc_pages(cache_bio, __GFP_NOWARN|GFP_NOIO))
+	if (bch_bio_alloc_pages(cache_bio, __GFP_NOWARN|GFP_NOIO))
 		goto out_put;
 
 	if (reada)
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index 61813d230015..a23cd6a14b74 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -283,6 +283,33 @@ start:		bv->bv_len	= min_t(size_t, PAGE_SIZE - bv->bv_offset,
 	}
 }
 
+/**
+ * bch_bio_alloc_pages - allocates a single page for each bvec in a bio
+ * @bio: bio to allocate pages for
+ * @gfp_mask: flags for allocation
+ *
+ * Allocates pages up to @bio->bi_vcnt.
+ *
+ * Returns 0 on success, -ENOMEM on failure. On failure, any allocated pages are
+ * freed.
+ */
+int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
+{
+	int i;
+	struct bio_vec *bv;
+
+	bio_for_each_segment_all(bv, bio, i) {
+		bv->bv_page = alloc_page(gfp_mask);
+		if (!bv->bv_page) {
+			while (--bv >= bio->bi_io_vec)
+				__free_page(bv->bv_page);
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * Portions Copyright (c) 1996-2001, PostgreSQL Global Development Group (Any
  * use permitted, subject to terms of PostgreSQL license; see.)
diff --git a/drivers/md/bcache/util.h b/drivers/md/bcache/util.h
index ed5e8a412eb8..4df4c5c1cab2 100644
--- a/drivers/md/bcache/util.h
+++ b/drivers/md/bcache/util.h
@@ -558,6 +558,7 @@ static inline unsigned fract_exp_two(unsigned x, unsigned fract_bits)
 }
 
 void bch_bio_map(struct bio *bio, void *base);
+int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask);
 
 static inline sector_t bdev_sectors(struct block_device *bdev)
 {
diff --git a/drivers/md/bcache/writeback.c b/drivers/md/bcache/writeback.c
index 56a37884ca8b..1ac2af6128b1 100644
--- a/drivers/md/bcache/writeback.c
+++ b/drivers/md/bcache/writeback.c
@@ -278,7 +278,7 @@ static void read_dirty(struct cached_dev *dc)
 		bio_set_dev(&io->bio, PTR_CACHE(dc->disk.c, &w->key, 0)->bdev);
 		io->bio.bi_end_io	= read_dirty_endio;
 
-		if (bio_alloc_pages(&io->bio, GFP_KERNEL))
+		if (bch_bio_alloc_pages(&io->bio, GFP_KERNEL))
 			goto err_free;
 
 		trace_bcache_writeback(&w->key);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 435ddf04e889..367a979fd4a6 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -500,7 +500,6 @@ static inline void bio_flush_dcache_pages(struct bio *bi)
 #endif
 
 extern void bio_copy_data(struct bio *dst, struct bio *src);
-extern int bio_alloc_pages(struct bio *bio, gfp_t gfp);
 extern void bio_free_pages(struct bio *bio);
 
 extern struct bio *bio_copy_user_iov(struct request_queue *,
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
