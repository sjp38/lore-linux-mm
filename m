Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8B1C6B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 08:05:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so136711317pfk.2
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 05:05:28 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g78si22387410pfe.9.2016.10.15.05.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 05:05:28 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i85so5693219pfa.0
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 05:05:28 -0700 (PDT)
Date: Sat, 15 Oct 2016 14:05:20 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v5 3/3] z3fold: add shrinker
Message-Id: <20161015140520.ee52a80c92c50214a6614977@gmail.com>
In-Reply-To: <20161015135632.541010b55bec496e2cae056e@gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
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

This update removes z3fold page compaction from the freeing path
since we can rely on shrinker to do the job. Also, a new flag
UNDER_COMPACTION is introduced to protect against two threads
trying to compact the same page.

This patch has been checked with the latest Linus's tree.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 144 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 119 insertions(+), 25 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 10513b5..8f84d3c 100644
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
@@ -121,6 +124,7 @@ enum z3fold_page_flags {
 	UNDER_RECLAIM = 0,
 	PAGE_HEADLESS,
 	MIDDLE_CHUNK_MAPPED,
+	UNDER_COMPACTION,
 };
 
 /*****************
@@ -136,6 +140,9 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+#define for_each_unbuddied_list_down(_iter, _end) \
+	for ((_iter) = (_end); (_iter) > 0; (_iter)--)
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page)
 {
@@ -145,6 +152,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(UNDER_RECLAIM, &page->private);
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	clear_bit(UNDER_COMPACTION, &page->private);
 
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
@@ -211,6 +219,103 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	return nfree;
 }
 
+/* Has to be called with lock held */
+static int z3fold_compact_page(struct z3fold_header *zhdr, bool sync)
+{
+	struct page *page = virt_to_page(zhdr);
+	void *beg = zhdr;
+
+
+	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
+	    !test_bit(UNDER_RECLAIM, &page->private) &&
+	    !test_bit(UNDER_COMPACTION, &page->private)) {
+		set_bit(UNDER_COMPACTION, &page->private);
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
+			clear_bit(UNDER_COMPACTION, &page->private);
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
+			clear_bit(UNDER_COMPACTION, &page->private);
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
+			clear_bit(UNDER_COMPACTION, &page->private);
+			return 1;
+		}
+	}
+out:
+	clear_bit(UNDER_COMPACTION, &page->private);
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
@@ -230,7 +335,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
-		return NULL;
+		goto out;
 	spin_lock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
@@ -238,8 +343,19 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	INIT_LIST_HEAD(&pool->lru);
 	atomic64_set(&pool->pages_nr, 0);
 	atomic64_set(&pool->unbuddied_nr, 0);
+	pool->shrinker.count_objects = z3fold_shrink_count;
+	pool->shrinker.scan_objects = z3fold_shrink_scan;
+	pool->shrinker.seeks = DEFAULT_SEEKS;
+	pool->shrinker.batch = NCHUNKS - 4;
+	if (register_shrinker(&pool->shrinker))
+		goto out_free;
 	pool->ops = ops;
 	return pool;
+
+out_free:
+	kfree(pool);
+out:
+	return NULL;
 }
 
 /**
@@ -250,31 +366,10 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
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
@@ -464,7 +559,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
@@ -596,7 +690,7 @@ next:
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
