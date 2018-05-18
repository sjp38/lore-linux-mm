Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE0626B0588
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:49:57 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t24-v6so6016401qtn.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:49:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m62-v6sor5762973qkf.143.2018.05.18.00.49.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:49:56 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 03/10] block: Add bioset_init()/bioset_exit()
Date: Fri, 18 May 2018 03:49:03 -0400
Message-Id: <20180518074918.13816-6-kent.overstreet@gmail.com>
In-Reply-To: <20180518074918.13816-1-kent.overstreet@gmail.com>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Similarly to mempool_init()/mempool_exit(), take a pointer indirection
out of allocation/freeing by allowing biosets to be embedded in other
structs.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c         | 93 +++++++++++++++++++++++++++++++--------------
 include/linux/bio.h |  2 +
 2 files changed, 67 insertions(+), 28 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 360e9bcea5..980befd919 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1856,21 +1856,83 @@ int biovec_init_pool(mempool_t *pool, int pool_entries)
 	return mempool_init_slab_pool(pool, pool_entries, bp->slab);
 }
 
-void bioset_free(struct bio_set *bs)
+/*
+ * bioset_exit - exit a bioset initialized with bioset_init()
+ *
+ * May be called on a zeroed but uninitialized bioset (i.e. allocated with
+ * kzalloc()).
+ */
+void bioset_exit(struct bio_set *bs)
 {
 	if (bs->rescue_workqueue)
 		destroy_workqueue(bs->rescue_workqueue);
+	bs->rescue_workqueue = NULL;
 
 	mempool_exit(&bs->bio_pool);
 	mempool_exit(&bs->bvec_pool);
 
 	bioset_integrity_free(bs);
-	bio_put_slab(bs);
+	if (bs->bio_slab)
+		bio_put_slab(bs);
+	bs->bio_slab = NULL;
+}
+EXPORT_SYMBOL(bioset_exit);
 
+void bioset_free(struct bio_set *bs)
+{
+	bioset_exit(bs);
 	kfree(bs);
 }
 EXPORT_SYMBOL(bioset_free);
 
+/**
+ * bioset_init - Initialize a bio_set
+ * @pool_size:	Number of bio and bio_vecs to cache in the mempool
+ * @front_pad:	Number of bytes to allocate in front of the returned bio
+ * @flags:	Flags to modify behavior, currently %BIOSET_NEED_BVECS
+ *              and %BIOSET_NEED_RESCUER
+ *
+ * Similar to bioset_create(), but initializes a passed-in bioset instead of
+ * separately allocating it.
+ */
+int bioset_init(struct bio_set *bs,
+		unsigned int pool_size,
+		unsigned int front_pad,
+		int flags)
+{
+	unsigned int back_pad = BIO_INLINE_VECS * sizeof(struct bio_vec);
+
+	bs->front_pad = front_pad;
+
+	spin_lock_init(&bs->rescue_lock);
+	bio_list_init(&bs->rescue_list);
+	INIT_WORK(&bs->rescue_work, bio_alloc_rescue);
+
+	bs->bio_slab = bio_find_or_create_slab(front_pad + back_pad);
+	if (!bs->bio_slab)
+		return -ENOMEM;
+
+	if (mempool_init_slab_pool(&bs->bio_pool, pool_size, bs->bio_slab))
+		goto bad;
+
+	if ((flags & BIOSET_NEED_BVECS) &&
+	    biovec_init_pool(&bs->bvec_pool, pool_size))
+		goto bad;
+
+	if (!(flags & BIOSET_NEED_RESCUER))
+		return 0;
+
+	bs->rescue_workqueue = alloc_workqueue("bioset", WQ_MEM_RECLAIM, 0);
+	if (!bs->rescue_workqueue)
+		goto bad;
+
+	return 0;
+bad:
+	bioset_exit(bs);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(bioset_init);
+
 /**
  * bioset_create  - Create a bio_set
  * @pool_size:	Number of bio and bio_vecs to cache in the mempool
@@ -1895,43 +1957,18 @@ struct bio_set *bioset_create(unsigned int pool_size,
 			      unsigned int front_pad,
 			      int flags)
 {
-	unsigned int back_pad = BIO_INLINE_VECS * sizeof(struct bio_vec);
 	struct bio_set *bs;
 
 	bs = kzalloc(sizeof(*bs), GFP_KERNEL);
 	if (!bs)
 		return NULL;
 
-	bs->front_pad = front_pad;
-
-	spin_lock_init(&bs->rescue_lock);
-	bio_list_init(&bs->rescue_list);
-	INIT_WORK(&bs->rescue_work, bio_alloc_rescue);
-
-	bs->bio_slab = bio_find_or_create_slab(front_pad + back_pad);
-	if (!bs->bio_slab) {
+	if (bioset_init(bs, pool_size, front_pad, flags)) {
 		kfree(bs);
 		return NULL;
 	}
 
-	if (mempool_init_slab_pool(&bs->bio_pool, pool_size, bs->bio_slab))
-		goto bad;
-
-	if ((flags & BIOSET_NEED_BVECS) &&
-	    biovec_init_pool(&bs->bvec_pool, pool_size))
-		goto bad;
-
-	if (!(flags & BIOSET_NEED_RESCUER))
-		return bs;
-
-	bs->rescue_workqueue = alloc_workqueue("bioset", WQ_MEM_RECLAIM, 0);
-	if (!bs->rescue_workqueue)
-		goto bad;
-
 	return bs;
-bad:
-	bioset_free(bs);
-	return NULL;
 }
 EXPORT_SYMBOL(bioset_create);
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 720f7261d0..fa3cf94a50 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -406,6 +406,8 @@ static inline struct bio *bio_next_split(struct bio *bio, int sectors,
 	return bio_split(bio, sectors, gfp, bs);
 }
 
+extern int bioset_init(struct bio_set *, unsigned int, unsigned int, int flags);
+extern void bioset_exit(struct bio_set *);
 extern struct bio_set *bioset_create(unsigned int, unsigned int, int flags);
 enum {
 	BIOSET_NEED_BVECS = BIT(0),
-- 
2.17.0
