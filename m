Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3E656B0253
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 17:58:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e203so133755196itc.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 14:58:15 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q101si1398857ioi.66.2016.10.20.14.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 14:58:15 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id r16so6602863pfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 14:58:15 -0700 (PDT)
Date: Thu, 20 Oct 2016 23:58:02 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 3/3] z3fold: add compaction worker
Message-Id: <20161020235802.c725fe30541f16eae39acd5f@gmail.com>
In-Reply-To: <20161020235017.d68ab1ff83d6f246fa3d7ee2@gmail.com>
References: <20161020235017.d68ab1ff83d6f246fa3d7ee2@gmail.com>
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
 mm/z3fold.c | 166 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 140 insertions(+), 26 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 014d84f..cc26ff5 100644
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
 	rwlock_t lock;
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
@@ -121,6 +128,7 @@ enum z3fold_page_flags {
 	UNDER_RECLAIM = 0,
 	PAGE_HEADLESS,
 	MIDDLE_CHUNK_MAPPED,
+	COMPACTION_DEFERRED,
 };
 
 /*****************
@@ -136,6 +144,9 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+#define for_each_unbuddied_list_reverse(_iter, _end) \
+	for ((_iter) = (_end); (_iter) > 0; (_iter)--)
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page)
 {
@@ -145,6 +156,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(UNDER_RECLAIM, &page->private);
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	clear_bit(COMPACTION_DEFERRED, &page->private);
 
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
@@ -211,6 +223,116 @@ static int num_free_chunks(struct z3fold_header *zhdr)
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
+	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private)) {
+		set_bit(COMPACTION_DEFERRED, &page->private);
+		ret = -1;
+		goto out;
+	}
+
+	clear_bit(COMPACTION_DEFERRED, &page->private);
+	if (zhdr->middle_chunks != 0) {
+		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+			/*
+			 * If we are here, no one can access this page
+			 * except for z3fold_map or z3fold_free. Both
+			 * will wait for page_lock to become free.
+			 */
+			mchunk_memmove(zhdr, 1); /* move to the beginning */
+			zhdr->first_chunks = zhdr->middle_chunks;
+			zhdr->middle_chunks = 0;
+			zhdr->start_middle = 0;
+			zhdr->first_num++;
+			ret = 1;
+			goto out;
+		}
+		if (sync)
+			goto out;
+
+		/*
+		 * These are more complicated cases: first or last object
+		 * may be mapped. Luckily we don't touch these anyway.
+		 *
+		 * NB: moving data is expensive, so let's only do that if
+		 * there's substantial gain (2+ chunks)
+		 */
+		if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+		    zhdr->start_middle > zhdr->first_chunks + 2) {
+			mchunk_memmove(zhdr, zhdr->first_chunks + 1);
+			zhdr->start_middle = zhdr->first_chunks + 1;
+			ret = 1;
+			goto out;
+		}
+		if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+		    zhdr->middle_chunks + zhdr->last_chunks <=
+		    NCHUNKS - zhdr->start_middle - 2) {
+			unsigned short new_start = NCHUNKS - zhdr->last_chunks -
+				zhdr->middle_chunks;
+			mchunk_memmove(zhdr, new_start);
+			zhdr->start_middle = new_start;
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
+	write_lock(&pool->lock);
+	for_each_unbuddied_list_reverse(i, NCHUNKS - 3) {
+		zhdr = list_empty(&pool->unbuddied[i]) ?
+				NULL : list_last_entry(&pool->unbuddied[i],
+				struct z3fold_header, buddy);
+		if (!zhdr)
+			continue;
+		page = virt_to_page(zhdr);
+		if (likely(!test_bit(COMPACTION_DEFERRED, &page->private)))
+			continue;
+		list_del(&zhdr->buddy);
+		ret = z3fold_compact_page(zhdr, false);
+		if (ret < 0)
+			requeue = true;
+		else
+			compacted += ret;
+		write_unlock(&pool->lock);
+		cond_resched();
+		write_lock(&pool->lock);
+		list_add(&zhdr->buddy,
+			&pool->unbuddied[num_free_chunks(zhdr)]);
+		if (compacted >= COMPACTION_BATCH) {
+			requeue = true;
+			break;
+		}
+	}
+	write_unlock(&pool->lock);
+	if (requeue && !delayed_work_pending(&pool->work))
+		queue_delayed_work(pool->compact_wq, &pool->work, HZ);
+}
+
+
 /*****************
  * API Functions
 *****************/
@@ -230,7 +352,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
-		return NULL;
+		goto out;
 	rwlock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
@@ -238,8 +360,17 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	INIT_LIST_HEAD(&pool->lru);
 	atomic64_set(&pool->pages_nr, 0);
 	atomic64_set(&pool->unbuddied_nr, 0);
+	pool->compact_wq = create_singlethread_workqueue(pool->name);
+	if (!pool->compact_wq)
+		goto out;
+	INIT_DELAYED_WORK(&pool->work, z3fold_compact_work);
 	pool->ops = ops;
 	return pool;
+
+out:
+	if (pool)
+		kfree(pool);
+	return NULL;
 }
 
 /**
@@ -250,31 +381,11 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
  */
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
+	if (pool->compact_wq)
+		destroy_workqueue(pool->compact_wq);
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
@@ -464,11 +575,13 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
+		set_bit(COMPACTION_DEFERRED, &page->private);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		list_add_tail(&zhdr->buddy, &pool->unbuddied[freechunks]);
 		atomic64_inc(&pool->unbuddied_nr);
+		if (!delayed_work_pending(&pool->work))
+			queue_delayed_work(pool->compact_wq, &pool->work, HZ);
 	}
 
 	write_unlock(&pool->lock);
@@ -596,7 +709,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				/* Full, add to buddied list */
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				z3fold_compact_page(zhdr, true);
 				/* add to unbuddied list */
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
@@ -725,6 +838,7 @@ static void *z3fold_zpool_create(const char *name, gfp_t gfp,
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
