Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C930D6B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:36:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k64so46531063itb.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:36:56 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id t29si24324102ioe.145.2016.10.19.09.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 09:36:56 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id k64so1884051itb.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:36:56 -0700 (PDT)
Date: Wed, 19 Oct 2016 18:36:52 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 3/3] z3fold: add compaction worker
Message-Id: <20161019183652.2fc38b6b7eae22a8ebaae1d6@gmail.com>
In-Reply-To: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com>
References: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

This patch implements compaction worker thread for z3fold. This
worker does not free up any pages directly but it allows for a
denser placement of compressed objects which results in less
actual pages consumed and higher compression ratio therefore.

This patch has been checked with the latest Linus's tree.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 159 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 133 insertions(+), 26 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 329bc26..580a732 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -27,6 +27,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/preempt.h>
+#include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/zpool.h>
@@ -59,6 +60,7 @@ struct z3fold_ops {
 
 /**
  * struct z3fold_pool - stores metadata for each z3fold pool
+ * @name:	pool name
  * @lock:	protects all pool fields and first|last_chunk fields of any
  *		z3fold page in the pool
  * @unbuddied:	array of lists tracking z3fold pages that contain 2- buddies;
@@ -72,11 +74,14 @@ struct z3fold_ops {
  * @unbuddied_nr:	number of unbuddied z3fold pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @compact_wq:	workqueue for page layout background optimization
+ * @work:	compaction work item
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
  */
 struct z3fold_pool {
+	const char *name;
 	spinlock_t lock;
 	struct list_head unbuddied[NCHUNKS];
 	struct list_head buddied;
@@ -86,6 +91,8 @@ struct z3fold_pool {
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
+	struct workqueue_struct *compact_wq;
+	struct delayed_work work;
 };
 
 enum buddy {
@@ -123,6 +130,7 @@ enum z3fold_page_flags {
 	UNDER_RECLAIM = 0,
 	PAGE_HEADLESS,
 	MIDDLE_CHUNK_MAPPED,
+	COMPACTION_DEFERRED,
 };
 
 /*****************
@@ -138,6 +146,9 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+#define for_each_unbuddied_list_reverse(_iter, _end) \
+	for ((_iter) = (_end); (_iter) > 0; (_iter)--)
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page)
 {
@@ -147,6 +158,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(UNDER_RECLAIM, &page->private);
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	clear_bit(COMPACTION_DEFERRED, &page->private);
 
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
@@ -219,6 +231,113 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	return nfree;
 }
 
+static inline void *mchunk_memmove(struct z3fold_header *zhdr,
+				unsigned short dst_chunk)
+{
+	void *beg = zhdr;
+	return memmove(beg + (dst_chunk << CHUNK_SHIFT),
+		       beg + (zhdr->start_middle << CHUNK_SHIFT),
+		       zhdr->middle_chunks << CHUNK_SHIFT);
+}
+
+static int z3fold_compact_page(struct z3fold_header *zhdr, bool sync)
+{
+	struct page *page = virt_to_page(zhdr);
+	int ret = 0;
+
+	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private) ||
+	    test_bit(UNDER_RECLAIM, &page->private)) {
+		set_bit(COMPACTION_DEFERRED, &page->private);
+		ret = -1;
+		goto out;
+	}
+
+	clear_bit(COMPACTION_DEFERRED, &page->private);
+	if (zhdr->middle_chunks != 0) {
+		    if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+			raw_spin_lock(&zhdr->page_lock);
+			mchunk_memmove(zhdr, 1); /* move to the beginning */
+			zhdr->first_chunks = zhdr->middle_chunks;
+			zhdr->middle_chunks = 0;
+			zhdr->start_middle = 0;
+			zhdr->first_num++;
+			raw_spin_unlock(&zhdr->page_lock);
+			ret = 1;
+			goto out;
+		}
+		if (sync)
+			goto out;
+
+		/* moving data is expensive, so let's only do that if
+		 * there's substantial gain (2+ chunks)
+		 */
+		if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+		    zhdr->start_middle > zhdr->first_chunks + 2) {
+			raw_spin_lock(&zhdr->page_lock);
+			mchunk_memmove(zhdr, zhdr->first_chunks + 1);
+			zhdr->start_middle = zhdr->first_chunks + 1;
+			raw_spin_unlock(&zhdr->page_lock);
+			ret = 1;
+			goto out;
+		}
+		if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+		    zhdr->middle_chunks + zhdr->last_chunks <=
+		    NCHUNKS - zhdr->start_middle - 2) {
+			unsigned short new_start = NCHUNKS - zhdr->last_chunks -
+				zhdr->middle_chunks;
+			raw_spin_lock(&zhdr->page_lock);
+			mchunk_memmove(zhdr, new_start);
+			zhdr->start_middle = new_start;
+			raw_spin_unlock(&zhdr->page_lock);
+			ret = 1;
+			goto out;
+		}
+	}
+out:
+	return ret;
+}
+
+#define COMPACTION_BATCH	(NCHUNKS/2)
+static void z3fold_compact_work(struct work_struct *w)
+{
+	struct z3fold_pool *pool = container_of(to_delayed_work(w),
+						struct z3fold_pool, work);
+	struct z3fold_header *zhdr;
+	struct page *page;
+	int i, ret, compacted = 0;
+	bool requeue = false;
+
+	spin_lock(&pool->lock);
+	for_each_unbuddied_list_reverse(i, NCHUNKS - 3) {
+		zhdr = list_first_entry_or_null(&pool->unbuddied[i],
+						struct z3fold_header, buddy);
+		if (!zhdr)
+			continue;
+		page = virt_to_page(zhdr);
+		if (likely(!test_bit(COMPACTION_DEFERRED, &page->private)))
+			continue;
+		list_del(&zhdr->buddy);
+		spin_unlock(&pool->lock);
+		ret = z3fold_compact_page(zhdr, false);
+		if (ret < 0)
+			requeue = true;
+		else
+			compacted += ret;
+		cond_resched();
+		spin_lock(&pool->lock);
+		list_add_tail(&zhdr->buddy,
+			&pool->unbuddied[num_free_chunks(zhdr)]);
+		if (compacted >= COMPACTION_BATCH) {
+			requeue = true;
+			break;
+		}
+	}
+	spin_unlock(&pool->lock);
+	if (requeue && !delayed_work_pending(&pool->work))
+		queue_delayed_work(pool->compact_wq, &pool->work, HZ);
+}
+
+
 /*****************
  * API Functions
 *****************/
@@ -238,7 +357,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
-		return NULL;
+		goto out;
 	spin_lock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
@@ -246,8 +365,13 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	INIT_LIST_HEAD(&pool->lru);
 	atomic64_set(&pool->pages_nr, 0);
 	atomic64_set(&pool->unbuddied_nr, 0);
+	pool->compact_wq = create_singlethread_workqueue(pool->name);
+	INIT_DELAYED_WORK(&pool->work, z3fold_compact_work);
 	pool->ops = ops;
 	return pool;
+
+out:
+	return NULL;
 }
 
 /**
@@ -258,32 +382,11 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
  */
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
+	if (pool->compact_wq)
+		destroy_workqueue(pool->compact_wq);
 	kfree(pool);
 }
 
-static int z3fold_compact_page(struct z3fold_header *zhdr)
-{
-	struct page *page = virt_to_page(zhdr);
-	void *beg = zhdr;
-
-
-	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
-	    zhdr->middle_chunks != 0 &&
-	    zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-		raw_spin_lock(&zhdr->page_lock);
-		memmove(beg + ZHDR_SIZE_ALIGNED,
-			beg + (zhdr->start_middle << CHUNK_SHIFT),
-			zhdr->middle_chunks << CHUNK_SHIFT);
-		zhdr->first_chunks = zhdr->middle_chunks;
-		zhdr->middle_chunks = 0;
-		zhdr->start_middle = 0;
-		zhdr->first_num++;
-		raw_spin_unlock(&zhdr->page_lock);
-		return 1;
-	}
-	return 0;
-}
-
 /**
  * z3fold_alloc() - allocates a region of a given size
  * @pool:	z3fold pool from which to allocate
@@ -474,16 +577,19 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* z3fold page is empty, free */
 		list_del(&page->lru);
 		clear_bit(PAGE_HEADLESS, &page->private);
+		clear_bit(COMPACTION_DEFERRED, &page->private);
 		free_z3fold_page(zhdr);
 		spin_unlock(&pool->lock);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
+		set_bit(COMPACTION_DEFERRED, &page->private);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
 		spin_unlock(&pool->lock);
 		atomic64_inc(&pool->unbuddied_nr);
+		if (!delayed_work_pending(&pool->work))
+			queue_delayed_work(pool->compact_wq, &pool->work, HZ);
 	}
 }
 
@@ -609,7 +715,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				/* Full, add to buddied list */
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				z3fold_compact_page(zhdr, true);
 				/* add to unbuddied list */
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
@@ -734,6 +840,7 @@ static void *z3fold_zpool_create(const char *name, gfp_t gfp,
 	if (pool) {
 		pool->zpool = zpool;
 		pool->zpool_ops = zpool_ops;
+		pool->name = name;
 	}
 	return pool;
 }
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
