Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 380746B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 16:39:00 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so55276057pab.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 13:39:00 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id 5si4687186pfx.116.2016.10.12.13.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 13:38:59 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id fn2so2844309pad.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 13:38:59 -0700 (PDT)
Date: Wed, 12 Oct 2016 22:38:51 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v3] z3fold: add shrinker
Message-Id: <20161012223851.0474f69cfdd6ad990e3b1dae@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

This patch implements shrinker for z3fold. This shrinker
implementation does not free up any pages directly but it allows
for a denser placement of compressed objects which results in
less actual pages consumed and higher compression ratio therefore.

This patch has been checked with the latest Linus's tree.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 157 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 132 insertions(+), 25 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8f9e89c..8d35b4a 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/zpool.h>
+#include <linux/shrinker.h>
 
 /*****************
  * Structures
@@ -69,8 +70,10 @@ struct z3fold_ops {
  * @lru:	list tracking the z3fold pages in LRU order by most recently
  *		added buddy.
  * @pages_nr:	number of z3fold pages in the pool.
+ * @unbuddied_nr:	number of unbuddied z3fold pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @shrinker:	shrinker structure to optimize page layout in background
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -81,9 +84,11 @@ struct z3fold_pool {
 	struct list_head buddied;
 	struct list_head lru;
 	u64 pages_nr;
+	u64 unbuddied_nr;
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
+	struct shrinker shrinker;
 };
 
 enum buddy {
@@ -134,6 +139,9 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+#define for_each_unbuddied_list_down(_iter, _end) \
+	for ((_iter) = (_end); (_iter) > 0; (_iter)--)
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page)
 {
@@ -209,6 +217,100 @@ static int num_free_chunks(struct z3fold_header *zhdr)
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
+	return pool->unbuddied_nr;
+}
+
+static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
+						shrinker);
+	struct z3fold_header *zhdr;
+	int i, nr_to_scan = sc->nr_to_scan;
+
+	spin_lock(&pool->lock);
+
+	for_each_unbuddied_list_down(i, NCHUNKS - 3) {
+		if (!list_empty(&pool->unbuddied[i])) {
+			zhdr = list_first_entry(&pool->unbuddied[i],
+						struct z3fold_header, buddy);
+			if (z3fold_compact_page(zhdr, false)) {
+				int nchunks = num_free_chunks(zhdr);
+				list_del(&zhdr->buddy);
+				list_add(&zhdr->buddy,
+					&pool->unbuddied[nchunks]);
+			}
+			if (!--nr_to_scan)
+				break;
+			spin_unlock(&pool->lock);
+			cond_resched();
+			spin_lock(&pool->lock);
+		}
+	}
+	spin_unlock(&pool->lock);
+	return 0;
+}
+
+
 /*****************
  * API Functions
 *****************/
@@ -228,15 +330,26 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 
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
+	if (register_shrinker(&pool->shrinker))
+		goto out_free;
 	pool->pages_nr = 0;
+	pool->unbuddied_nr = 0;
 	pool->ops = ops;
 	return pool;
+
+out_free:
+	kfree(pool);
+out:
+	return NULL;
 }
 
 /**
@@ -247,31 +360,10 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
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
@@ -334,6 +426,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 					continue;
 				}
 				list_del(&zhdr->buddy);
+				pool->unbuddied_nr--;
 				goto found;
 			}
 		}
@@ -369,6 +462,7 @@ found:
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		pool->unbuddied_nr++;
 	} else {
 		/* Add to buddied list */
 		list_add(&zhdr->buddy, &pool->buddied);
@@ -412,6 +506,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* HEADLESS page stored */
 		bud = HEADLESS;
 	} else {
+		if (zhdr->first_chunks == 0 ||
+		    zhdr->middle_chunks == 0 ||
+		    zhdr->last_chunks == 0)
+			pool->unbuddied_nr--;
+
 		bud = handle_to_buddy(handle);
 
 		switch (bud) {
@@ -428,6 +527,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		default:
 			pr_err("%s: unknown bud %d\n", __func__, bud);
 			WARN_ON(1);
+			pool->unbuddied_nr++;
 			spin_unlock(&pool->lock);
 			return;
 		}
@@ -453,10 +553,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		pool->pages_nr--;
 	} else {
-		z3fold_compact_page(zhdr);
+		z3fold_compact_page(zhdr, true);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		pool->unbuddied_nr++;
 	}
 
 	spin_unlock(&pool->lock);
@@ -520,6 +621,11 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			list_del(&zhdr->buddy);
+			if (zhdr->first_chunks == 0 ||
+			    zhdr->middle_chunks == 0 ||
+			    zhdr->last_chunks == 0)
+				pool->unbuddied_nr--;
+
 			/*
 			 * We need encode the handles before unlocking, since
 			 * we can race with free that will set
@@ -579,11 +685,12 @@ next:
 				/* Full, add to buddied list */
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				z3fold_compact_page(zhdr, true);
 				/* add to unbuddied list */
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
 					 &pool->unbuddied[freechunks]);
+				pool->unbuddied_nr++;
 			}
 		}
 
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
