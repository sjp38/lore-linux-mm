Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 633DE6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 12:52:55 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id tz10so83386963pab.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:52:55 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id m3si11755267pgd.262.2016.10.13.09.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 09:52:35 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hh10so5023126pac.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:52:35 -0700 (PDT)
Date: Thu, 13 Oct 2016 18:52:28 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 3/3] z3fold: add shrinker
Message-Id: <20161013185228.1152daa70ff25257a9effa31@gmail.com>
In-Reply-To: <20161013184758.9ecfd318fa542e14e2d2c5b1@gmail.com>
References: <20161013184758.9ecfd318fa542e14e2d2c5b1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

This patch implements shrinker for z3fold. This shrinker
implementation does not free up any pages directly but it allows
for a denser placement of compressed objects which results in
less actual pages consumed and higher compression ratio therefore.

This patch has been checked with the latest Linus's tree.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 136 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 111 insertions(+), 25 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 10513b5..0b2a0d3 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -27,6 +27,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/preempt.h>
+#include <linux/shrinker.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/zpool.h>
@@ -72,6 +73,7 @@ struct z3fold_ops {
  * @unbuddied_nr:	number of unbuddied z3fold pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @shrinker:	shrinker structure to optimize page layout in background
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -86,6 +88,7 @@ struct z3fold_pool {
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
+	struct shrinker shrinker;
 };
 
 enum buddy {
@@ -136,6 +139,9 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+#define for_each_unbuddied_list_down(_iter, _end) \
+	for ((_iter) = (_end); (_iter) > 0; (_iter)--)
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page)
 {
@@ -211,6 +217,96 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	return nfree;
 }
 
+/* Has to be called with lock held */
+static int z3fold_compact_page(struct z3fold_header *zhdr, bool sync)
+{
+	struct page *page = virt_to_page(zhdr);
+	void *beg = zhdr;
+
+
+	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private)) {
+		if (zhdr->middle_chunks != 0 &&
+		    zhdr->first_chunks == 0 &&
+		    zhdr->last_chunks == 0) {
+			memmove(beg + ZHDR_SIZE_ALIGNED,
+				beg + (zhdr->start_middle << CHUNK_SHIFT),
+				zhdr->middle_chunks << CHUNK_SHIFT);
+			zhdr->first_chunks = zhdr->middle_chunks;
+			zhdr->middle_chunks = 0;
+			zhdr->start_middle = 0;
+			zhdr->first_num++;
+			return 1;
+		}
+		if (sync)
+			goto out;
+
+		/* moving data is expensive, so let's only do that if
+		 * there's substantial gain (2+ chunks)
+		 */
+		if (zhdr->middle_chunks != 0 && zhdr->first_chunks != 0 &&
+		    zhdr->last_chunks == 0 &&
+		    zhdr->start_middle > zhdr->first_chunks + 2) {
+			unsigned short new_start = zhdr->first_chunks + 1;
+			memmove(beg + (new_start << CHUNK_SHIFT),
+				beg + (zhdr->start_middle << CHUNK_SHIFT),
+				zhdr->middle_chunks << CHUNK_SHIFT);
+			zhdr->start_middle = new_start;
+			return 1;
+		}
+		if (zhdr->middle_chunks != 0 && zhdr->last_chunks != 0 &&
+		    zhdr->first_chunks == 0 &&
+		    zhdr->middle_chunks + zhdr->last_chunks <=
+		    NCHUNKS - zhdr->start_middle - 2) {
+			unsigned short new_start = NCHUNKS - zhdr->last_chunks -
+				zhdr->middle_chunks;
+			memmove(beg + (new_start << CHUNK_SHIFT),
+				beg + (zhdr->start_middle << CHUNK_SHIFT),
+				zhdr->middle_chunks << CHUNK_SHIFT);
+			zhdr->start_middle = new_start;
+			return 1;
+		}
+	}
+out:
+	return 0;
+}
+
+static unsigned long z3fold_shrink_count(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
+						shrinker);
+
+	return atomic64_read(&pool->unbuddied_nr);
+}
+
+static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
+						shrinker);
+	struct z3fold_header *zhdr;
+	int i, nr_to_scan = sc->nr_to_scan, nr_shrunk = 0;
+
+	spin_lock(&pool->lock);
+	for_each_unbuddied_list_down(i, NCHUNKS - 3) {
+		if (!list_empty(&pool->unbuddied[i])) {
+			zhdr = list_first_entry(&pool->unbuddied[i],
+						struct z3fold_header, buddy);
+			list_del(&zhdr->buddy);
+			spin_unlock(&pool->lock);
+			nr_shrunk += z3fold_compact_page(zhdr, false);
+			spin_lock(&pool->lock);
+			list_add(&zhdr->buddy,
+				&pool->unbuddied[num_free_chunks(zhdr)]);
+			if (!--nr_to_scan)
+				break;
+		}
+	}
+	spin_unlock(&pool->lock);
+	return nr_shrunk;
+}
+
+
 /*****************
  * API Functions
 *****************/
@@ -230,16 +326,27 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
-		return NULL;
+		goto out;
 	spin_lock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
+	pool->shrinker.count_objects = z3fold_shrink_count;
+	pool->shrinker.scan_objects = z3fold_shrink_scan;
+	pool->shrinker.seeks = DEFAULT_SEEKS;
+	pool->shrinker.batch = NCHUNKS - 4;
+	if (register_shrinker(&pool->shrinker))
+		goto out_free;
 	atomic64_set(&pool->pages_nr, 0);
 	atomic64_set(&pool->unbuddied_nr, 0);
 	pool->ops = ops;
 	return pool;
+
+out_free:
+	kfree(pool);
+out:
+	return NULL;
 }
 
 /**
@@ -250,31 +357,10 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
  */
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
+	unregister_shrinker(&pool->shrinker);
 	kfree(pool);
 }
 
-/* Has to be called with lock held */
-static int z3fold_compact_page(struct z3fold_header *zhdr)
-{
-	struct page *page = virt_to_page(zhdr);
-	void *beg = zhdr;
-
-
-	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
-	    zhdr->middle_chunks != 0 &&
-	    zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-		memmove(beg + ZHDR_SIZE_ALIGNED,
-			beg + (zhdr->start_middle << CHUNK_SHIFT),
-			zhdr->middle_chunks << CHUNK_SHIFT);
-		zhdr->first_chunks = zhdr->middle_chunks;
-		zhdr->middle_chunks = 0;
-		zhdr->start_middle = 0;
-		zhdr->first_num++;
-		return 1;
-	}
-	return 0;
-}
-
 /**
  * z3fold_alloc() - allocates a region of a given size
  * @pool:	z3fold pool from which to allocate
@@ -464,7 +550,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
+		z3fold_compact_page(zhdr, true);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
@@ -596,7 +682,7 @@ next:
 				/* Full, add to buddied list */
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				z3fold_compact_page(zhdr, true);
 				/* add to unbuddied list */
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
