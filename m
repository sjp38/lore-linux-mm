Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7836B030F
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t3-v6so25759760qto.14
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s48-v6sor16487191qtc.121.2018.05.08.18.34.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:21 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 04/10] block: Use bioset_init() for fs_bio_set
Date: Tue,  8 May 2018 21:33:52 -0400
Message-Id: <20180509013358.16399-5-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Minor optimization - remove a pointer indirection when using fs_bio_set.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c                         | 7 +++----
 block/blk-core.c                    | 2 +-
 drivers/target/target_core_iblock.c | 2 +-
 include/linux/bio.h                 | 4 ++--
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 980befd919..b7cdad6fc4 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -53,7 +53,7 @@ static struct biovec_slab bvec_slabs[BVEC_POOL_NR] __read_mostly = {
  * fs_bio_set is the bio_set containing bio and iovec memory pools used by
  * IO code that does not need private memory pools.
  */
-struct bio_set *fs_bio_set;
+struct bio_set fs_bio_set;
 EXPORT_SYMBOL(fs_bio_set);
 
 /*
@@ -2055,11 +2055,10 @@ static int __init init_bio(void)
 	bio_integrity_init();
 	biovec_init_slabs();
 
-	fs_bio_set = bioset_create(BIO_POOL_SIZE, 0, BIOSET_NEED_BVECS);
-	if (!fs_bio_set)
+	if (bioset_init(&fs_bio_set, BIO_POOL_SIZE, 0, BIOSET_NEED_BVECS))
 		panic("bio: can't allocate bios\n");
 
-	if (bioset_integrity_create(fs_bio_set, BIO_POOL_SIZE))
+	if (bioset_integrity_create(&fs_bio_set, BIO_POOL_SIZE))
 		panic("bio: can't create integrity pool\n");
 
 	return 0;
diff --git a/block/blk-core.c b/block/blk-core.c
index 6d82c4f7fa..66f24798ef 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -3409,7 +3409,7 @@ int blk_rq_prep_clone(struct request *rq, struct request *rq_src,
 	struct bio *bio, *bio_src;
 
 	if (!bs)
-		bs = fs_bio_set;
+		bs = &fs_bio_set;
 
 	__rq_for_each_bio(bio_src, rq_src) {
 		bio = bio_clone_fast(bio_src, gfp_mask, bs);
diff --git a/drivers/target/target_core_iblock.c b/drivers/target/target_core_iblock.c
index 07c814c426..c969c01c7c 100644
--- a/drivers/target/target_core_iblock.c
+++ b/drivers/target/target_core_iblock.c
@@ -164,7 +164,7 @@ static int iblock_configure_device(struct se_device *dev)
 				goto out_blkdev_put;
 			}
 			pr_debug("IBLOCK setup BIP bs->bio_integrity_pool: %p\n",
-				 bs->bio_integrity_pool);
+				 &bs->bio_integrity_pool);
 		}
 		dev->dev_attrib.hw_pi_prot_type = dev->dev_attrib.pi_prot_type;
 	}
diff --git a/include/linux/bio.h b/include/linux/bio.h
index fa3cf94a50..91b02520e2 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -423,11 +423,11 @@ extern void __bio_clone_fast(struct bio *, struct bio *);
 extern struct bio *bio_clone_fast(struct bio *, gfp_t, struct bio_set *);
 extern struct bio *bio_clone_bioset(struct bio *, gfp_t, struct bio_set *bs);
 
-extern struct bio_set *fs_bio_set;
+extern struct bio_set fs_bio_set;
 
 static inline struct bio *bio_alloc(gfp_t gfp_mask, unsigned int nr_iovecs)
 {
-	return bio_alloc_bioset(gfp_mask, nr_iovecs, fs_bio_set);
+	return bio_alloc_bioset(gfp_mask, nr_iovecs, &fs_bio_set);
 }
 
 static inline struct bio *bio_kmalloc(gfp_t gfp_mask, unsigned int nr_iovecs)
-- 
2.17.0
