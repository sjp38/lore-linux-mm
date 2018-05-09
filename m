Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5DCB6B030D
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:18 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b10-v6so25728110qto.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h31-v6sor14974356qte.44.2018.05.08.18.34.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:17 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 02/10] block: Convert bio_set to mempool_init()
Date: Tue,  8 May 2018 21:33:50 -0400
Message-Id: <20180509013358.16399-3-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Minor performance improvement by getting rid of pointer indirections
from allocation/freeing fastpaths.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio-integrity.c | 29 ++++++++++++++---------------
 block/bio.c           | 36 +++++++++++++++++-------------------
 include/linux/bio.h   | 10 +++++-----
 3 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/block/bio-integrity.c b/block/bio-integrity.c
index 9cfdd6c83b..add7c7c853 100644
--- a/block/bio-integrity.c
+++ b/block/bio-integrity.c
@@ -56,12 +56,12 @@ struct bio_integrity_payload *bio_integrity_alloc(struct bio *bio,
 	struct bio_set *bs = bio->bi_pool;
 	unsigned inline_vecs;
 
-	if (!bs || !bs->bio_integrity_pool) {
+	if (!bs || !mempool_initialized(&bs->bio_integrity_pool)) {
 		bip = kmalloc(sizeof(struct bio_integrity_payload) +
 			      sizeof(struct bio_vec) * nr_vecs, gfp_mask);
 		inline_vecs = nr_vecs;
 	} else {
-		bip = mempool_alloc(bs->bio_integrity_pool, gfp_mask);
+		bip = mempool_alloc(&bs->bio_integrity_pool, gfp_mask);
 		inline_vecs = BIP_INLINE_VECS;
 	}
 
@@ -74,7 +74,7 @@ struct bio_integrity_payload *bio_integrity_alloc(struct bio *bio,
 		unsigned long idx = 0;
 
 		bip->bip_vec = bvec_alloc(gfp_mask, nr_vecs, &idx,
-					  bs->bvec_integrity_pool);
+					  &bs->bvec_integrity_pool);
 		if (!bip->bip_vec)
 			goto err;
 		bip->bip_max_vcnt = bvec_nr_vecs(idx);
@@ -90,7 +90,7 @@ struct bio_integrity_payload *bio_integrity_alloc(struct bio *bio,
 
 	return bip;
 err:
-	mempool_free(bip, bs->bio_integrity_pool);
+	mempool_free(bip, &bs->bio_integrity_pool);
 	return ERR_PTR(-ENOMEM);
 }
 EXPORT_SYMBOL(bio_integrity_alloc);
@@ -111,10 +111,10 @@ static void bio_integrity_free(struct bio *bio)
 		kfree(page_address(bip->bip_vec->bv_page) +
 		      bip->bip_vec->bv_offset);
 
-	if (bs && bs->bio_integrity_pool) {
-		bvec_free(bs->bvec_integrity_pool, bip->bip_vec, bip->bip_slab);
+	if (bs && mempool_initialized(&bs->bio_integrity_pool)) {
+		bvec_free(&bs->bvec_integrity_pool, bip->bip_vec, bip->bip_slab);
 
-		mempool_free(bip, bs->bio_integrity_pool);
+		mempool_free(bip, &bs->bio_integrity_pool);
 	} else {
 		kfree(bip);
 	}
@@ -465,16 +465,15 @@ EXPORT_SYMBOL(bio_integrity_clone);
 
 int bioset_integrity_create(struct bio_set *bs, int pool_size)
 {
-	if (bs->bio_integrity_pool)
+	if (mempool_initialized(&bs->bio_integrity_pool))
 		return 0;
 
-	bs->bio_integrity_pool = mempool_create_slab_pool(pool_size, bip_slab);
-	if (!bs->bio_integrity_pool)
+	if (mempool_init_slab_pool(&bs->bio_integrity_pool,
+				   pool_size, bip_slab))
 		return -1;
 
-	bs->bvec_integrity_pool = biovec_create_pool(pool_size);
-	if (!bs->bvec_integrity_pool) {
-		mempool_destroy(bs->bio_integrity_pool);
+	if (biovec_init_pool(&bs->bvec_integrity_pool, pool_size)) {
+		mempool_exit(&bs->bio_integrity_pool);
 		return -1;
 	}
 
@@ -484,8 +483,8 @@ EXPORT_SYMBOL(bioset_integrity_create);
 
 void bioset_integrity_free(struct bio_set *bs)
 {
-	mempool_destroy(bs->bio_integrity_pool);
-	mempool_destroy(bs->bvec_integrity_pool);
+	mempool_exit(&bs->bio_integrity_pool);
+	mempool_exit(&bs->bvec_integrity_pool);
 }
 EXPORT_SYMBOL(bioset_integrity_free);
 
diff --git a/block/bio.c b/block/bio.c
index e1708db482..360e9bcea5 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -254,7 +254,7 @@ static void bio_free(struct bio *bio)
 	bio_uninit(bio);
 
 	if (bs) {
-		bvec_free(bs->bvec_pool, bio->bi_io_vec, BVEC_POOL_IDX(bio));
+		bvec_free(&bs->bvec_pool, bio->bi_io_vec, BVEC_POOL_IDX(bio));
 
 		/*
 		 * If we have front padding, adjust the bio pointer before freeing
@@ -262,7 +262,7 @@ static void bio_free(struct bio *bio)
 		p = bio;
 		p -= bs->front_pad;
 
-		mempool_free(p, bs->bio_pool);
+		mempool_free(p, &bs->bio_pool);
 	} else {
 		/* Bio was allocated by bio_kmalloc() */
 		kfree(bio);
@@ -454,7 +454,8 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 		inline_vecs = nr_iovecs;
 	} else {
 		/* should not use nobvec bioset for nr_iovecs > 0 */
-		if (WARN_ON_ONCE(!bs->bvec_pool && nr_iovecs > 0))
+		if (WARN_ON_ONCE(!mempool_initialized(&bs->bvec_pool) &&
+				 nr_iovecs > 0))
 			return NULL;
 		/*
 		 * generic_make_request() converts recursion to iteration; this
@@ -483,11 +484,11 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 		    bs->rescue_workqueue)
 			gfp_mask &= ~__GFP_DIRECT_RECLAIM;
 
-		p = mempool_alloc(bs->bio_pool, gfp_mask);
+		p = mempool_alloc(&bs->bio_pool, gfp_mask);
 		if (!p && gfp_mask != saved_gfp) {
 			punt_bios_to_rescuer(bs);
 			gfp_mask = saved_gfp;
-			p = mempool_alloc(bs->bio_pool, gfp_mask);
+			p = mempool_alloc(&bs->bio_pool, gfp_mask);
 		}
 
 		front_pad = bs->front_pad;
@@ -503,11 +504,11 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 	if (nr_iovecs > inline_vecs) {
 		unsigned long idx = 0;
 
-		bvl = bvec_alloc(gfp_mask, nr_iovecs, &idx, bs->bvec_pool);
+		bvl = bvec_alloc(gfp_mask, nr_iovecs, &idx, &bs->bvec_pool);
 		if (!bvl && gfp_mask != saved_gfp) {
 			punt_bios_to_rescuer(bs);
 			gfp_mask = saved_gfp;
-			bvl = bvec_alloc(gfp_mask, nr_iovecs, &idx, bs->bvec_pool);
+			bvl = bvec_alloc(gfp_mask, nr_iovecs, &idx, &bs->bvec_pool);
 		}
 
 		if (unlikely(!bvl))
@@ -524,7 +525,7 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 	return bio;
 
 err_free:
-	mempool_free(p, bs->bio_pool);
+	mempool_free(p, &bs->bio_pool);
 	return NULL;
 }
 EXPORT_SYMBOL(bio_alloc_bioset);
@@ -1848,11 +1849,11 @@ EXPORT_SYMBOL_GPL(bio_trim);
  * create memory pools for biovec's in a bio_set.
  * use the global biovec slabs created for general use.
  */
-mempool_t *biovec_create_pool(int pool_entries)
+int biovec_init_pool(mempool_t *pool, int pool_entries)
 {
 	struct biovec_slab *bp = bvec_slabs + BVEC_POOL_MAX;
 
-	return mempool_create_slab_pool(pool_entries, bp->slab);
+	return mempool_init_slab_pool(pool, pool_entries, bp->slab);
 }
 
 void bioset_free(struct bio_set *bs)
@@ -1860,8 +1861,8 @@ void bioset_free(struct bio_set *bs)
 	if (bs->rescue_workqueue)
 		destroy_workqueue(bs->rescue_workqueue);
 
-	mempool_destroy(bs->bio_pool);
-	mempool_destroy(bs->bvec_pool);
+	mempool_exit(&bs->bio_pool);
+	mempool_exit(&bs->bvec_pool);
 
 	bioset_integrity_free(bs);
 	bio_put_slab(bs);
@@ -1913,15 +1914,12 @@ struct bio_set *bioset_create(unsigned int pool_size,
 		return NULL;
 	}
 
-	bs->bio_pool = mempool_create_slab_pool(pool_size, bs->bio_slab);
-	if (!bs->bio_pool)
+	if (mempool_init_slab_pool(&bs->bio_pool, pool_size, bs->bio_slab))
 		goto bad;
 
-	if (flags & BIOSET_NEED_BVECS) {
-		bs->bvec_pool = biovec_create_pool(pool_size);
-		if (!bs->bvec_pool)
-			goto bad;
-	}
+	if ((flags & BIOSET_NEED_BVECS) &&
+	    biovec_init_pool(&bs->bvec_pool, pool_size))
+		goto bad;
 
 	if (!(flags & BIOSET_NEED_RESCUER))
 		return bs;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index ce547a25e8..720f7261d0 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -412,7 +412,7 @@ enum {
 	BIOSET_NEED_RESCUER = BIT(1),
 };
 extern void bioset_free(struct bio_set *);
-extern mempool_t *biovec_create_pool(int pool_entries);
+extern int biovec_init_pool(mempool_t *pool, int pool_entries);
 
 extern struct bio *bio_alloc_bioset(gfp_t, unsigned int, struct bio_set *);
 extern void bio_put(struct bio *);
@@ -722,11 +722,11 @@ struct bio_set {
 	struct kmem_cache *bio_slab;
 	unsigned int front_pad;
 
-	mempool_t *bio_pool;
-	mempool_t *bvec_pool;
+	mempool_t bio_pool;
+	mempool_t bvec_pool;
 #if defined(CONFIG_BLK_DEV_INTEGRITY)
-	mempool_t *bio_integrity_pool;
-	mempool_t *bvec_integrity_pool;
+	mempool_t bio_integrity_pool;
+	mempool_t bvec_integrity_pool;
 #endif
 
 	/*
-- 
2.17.0
