Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B82036B05C9
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 06:25:12 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 42so9994087lfq.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 03:25:12 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 9si11615685ljo.323.2017.08.02.03.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 03:25:10 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id w199so3460680lff.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 03:25:09 -0700 (PDT)
Date: Wed, 2 Aug 2017 12:25:05 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: use per-cpu unbuddied lists
Message-Id: <20170802122505.e41d5c778a873375bcb0cc19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

z3fold is operating on unbuddied lists in a simple manner: in fact,
it only takes the first entry off the list on a hot path. So if the
z3fold pool is big enough and balanced well enough, considering
only the lists local to the current CPU won't be an issue in any
way, while random I/O performance will go up.

This patch also introduces two worker threads which: one for async
in-page object layout optimization and one for releasing freed
pages.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 479 +++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 344 insertions(+), 135 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 54f63c4a809a..b44ce5059442 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -23,10 +23,13 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/atomic.h>
+#include <linux/cpumask.h>
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/percpu.h>
 #include <linux/preempt.h>
+#include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/zpool.h>
@@ -48,11 +51,15 @@ enum buddy {
 };
 
 /*
- * struct z3fold_header - z3fold page metadata occupying the first chunk of each
+ * struct z3fold_header - z3fold page metadata occupying first chunks of each
  *			z3fold page, except for HEADLESS pages
- * @buddy:	links the z3fold page into the relevant list in the pool
+ * @buddy:		links the z3fold page into the relevant list in the
+ *			pool
  * @page_lock:		per-page lock
- * @refcount:		reference cound for the z3fold page
+ * @refcount:		reference count for the z3fold page
+ * @work:		work_struct for page layout optimization
+ * @pool:		pointer to the pool which this page belongs to
+ * @cpu:		CPU which this page "belongs" to
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
@@ -62,6 +69,9 @@ struct z3fold_header {
 	struct list_head buddy;
 	spinlock_t page_lock;
 	struct kref refcount;
+	struct work_struct work;
+	struct z3fold_pool *pool;
+	short cpu;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
 	unsigned short last_chunks;
@@ -92,28 +102,39 @@ struct z3fold_header {
 
 /**
  * struct z3fold_pool - stores metadata for each z3fold pool
- * @lock:	protects all pool fields and first|last_chunk fields of any
- *		z3fold page in the pool
- * @unbuddied:	array of lists tracking z3fold pages that contain 2- buddies;
- *		the lists each z3fold page is added to depends on the size of
- *		its free region.
+ * @name:	pool name
+ * @lock:	protects pool unbuddied/lru lists
+ * @stale_lock:	protects pool stale page list
+ * @unbuddied:	per-cpu array of lists tracking z3fold pages that contain 2-
+ *		buddies; the list each z3fold page is added to depends on
+ *		the size of its free region.
  * @lru:	list tracking the z3fold pages in LRU order by most recently
  *		added buddy.
+ * @stale:	list of pages marked for freeing
  * @pages_nr:	number of z3fold pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
+ * @compact_wq:	workqueue for page layout background optimization
+ * @release_wq:	workqueue for safe page release
+ * @work:	work_struct for safe page release
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
  */
 struct z3fold_pool {
+	const char *name;
 	spinlock_t lock;
-	struct list_head unbuddied[NCHUNKS];
+	spinlock_t stale_lock;
+	struct list_head *unbuddied;
 	struct list_head lru;
+	struct list_head stale;
 	atomic64_t pages_nr;
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
+	struct workqueue_struct *compact_wq;
+	struct workqueue_struct *release_wq;
+	struct work_struct work;
 };
 
 /*
@@ -122,9 +143,10 @@ struct z3fold_pool {
 enum z3fold_page_flags {
 	PAGE_HEADLESS = 0,
 	MIDDLE_CHUNK_MAPPED,
+	NEEDS_COMPACTING,
+	PAGE_STALE
 };
 
-
 /*****************
  * Helpers
 *****************/
@@ -138,14 +160,19 @@ static int size_to_chunks(size_t size)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
+static void compact_page_work(struct work_struct *w);
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
-static struct z3fold_header *init_z3fold_page(struct page *page)
+static struct z3fold_header *init_z3fold_page(struct page *page,
+					struct z3fold_pool *pool)
 {
 	struct z3fold_header *zhdr = page_address(page);
 
 	INIT_LIST_HEAD(&page->lru);
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	clear_bit(NEEDS_COMPACTING, &page->private);
+	clear_bit(PAGE_STALE, &page->private);
 
 	spin_lock_init(&zhdr->page_lock);
 	kref_init(&zhdr->refcount);
@@ -154,7 +181,10 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	zhdr->last_chunks = 0;
 	zhdr->first_num = 0;
 	zhdr->start_middle = 0;
+	zhdr->cpu = -1;
+	zhdr->pool = pool;
 	INIT_LIST_HEAD(&zhdr->buddy);
+	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
 }
 
@@ -164,21 +194,6 @@ static void free_z3fold_page(struct page *page)
 	__free_page(page);
 }
 
-static void release_z3fold_page(struct kref *ref)
-{
-	struct z3fold_header *zhdr;
-	struct page *page;
-
-	zhdr = container_of(ref, struct z3fold_header, refcount);
-	page = virt_to_page(zhdr);
-
-	if (!list_empty(&zhdr->buddy))
-		list_del(&zhdr->buddy);
-	if (!list_empty(&page->lru))
-		list_del(&page->lru);
-	free_z3fold_page(page);
-}
-
 /* Lock a z3fold page */
 static inline void z3fold_page_lock(struct z3fold_header *zhdr)
 {
@@ -228,6 +243,76 @@ static enum buddy handle_to_buddy(unsigned long handle)
 	return (handle - zhdr->first_num) & BUDDY_MASK;
 }
 
+static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
+{
+	struct page *page = virt_to_page(zhdr);
+	struct z3fold_pool *pool = zhdr->pool;
+
+	WARN_ON(!list_empty(&zhdr->buddy));
+	set_bit(PAGE_STALE, &page->private);
+	spin_lock(&pool->lock);
+	if (!list_empty(&page->lru))
+		list_del(&page->lru);
+	spin_unlock(&pool->lock);
+	if (locked)
+		z3fold_page_unlock(zhdr);
+	spin_lock(&pool->stale_lock);
+	list_add(&zhdr->buddy, &pool->stale);
+	queue_work(pool->release_wq, &pool->work);
+	spin_unlock(&pool->stale_lock);
+}
+
+static void __attribute__((__unused__))
+			release_z3fold_page(struct kref *ref)
+{
+	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
+						refcount);
+	__release_z3fold_page(zhdr, false);
+}
+
+static void release_z3fold_page_locked(struct kref *ref)
+{
+	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
+						refcount);
+	WARN_ON(z3fold_page_trylock(zhdr));
+	__release_z3fold_page(zhdr, true);
+}
+
+static void release_z3fold_page_locked_list(struct kref *ref)
+{
+	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
+					       refcount);
+	spin_lock(&zhdr->pool->lock);
+	list_del_init(&zhdr->buddy);
+	spin_unlock(&zhdr->pool->lock);
+
+	WARN_ON(z3fold_page_trylock(zhdr));
+	__release_z3fold_page(zhdr, true);
+}
+
+static void free_pages_work(struct work_struct *w)
+{
+	struct z3fold_pool *pool = container_of(w, struct z3fold_pool, work);
+
+	spin_lock(&pool->stale_lock);
+	while (!list_empty(&pool->stale)) {
+		struct z3fold_header *zhdr = list_first_entry(&pool->stale,
+						struct z3fold_header, buddy);
+		struct page *page = virt_to_page(zhdr);
+
+		list_del(&zhdr->buddy);
+		if (WARN_ON(!test_bit(PAGE_STALE, &page->private)))
+			continue;
+		clear_bit(NEEDS_COMPACTING, &page->private);
+		spin_unlock(&pool->stale_lock);
+		cancel_work_sync(&zhdr->work);
+		free_z3fold_page(page);
+		cond_resched();
+		spin_lock(&pool->stale_lock);
+	}
+	spin_unlock(&pool->stale_lock);
+}
+
 /*
  * Returns the number of free chunks in a z3fold page.
  * NB: can't be used with HEADLESS pages.
@@ -252,46 +337,6 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	return nfree;
 }
 
-/*****************
- * API Functions
-*****************/
-/**
- * z3fold_create_pool() - create a new z3fold pool
- * @gfp:	gfp flags when allocating the z3fold pool structure
- * @ops:	user-defined operations for the z3fold pool
- *
- * Return: pointer to the new z3fold pool or NULL if the metadata allocation
- * failed.
- */
-static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
-		const struct z3fold_ops *ops)
-{
-	struct z3fold_pool *pool;
-	int i;
-
-	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
-	if (!pool)
-		return NULL;
-	spin_lock_init(&pool->lock);
-	for_each_unbuddied_list(i, 0)
-		INIT_LIST_HEAD(&pool->unbuddied[i]);
-	INIT_LIST_HEAD(&pool->lru);
-	atomic64_set(&pool->pages_nr, 0);
-	pool->ops = ops;
-	return pool;
-}
-
-/**
- * z3fold_destroy_pool() - destroys an existing z3fold pool
- * @pool:	the z3fold pool to be destroyed
- *
- * The pool should be emptied before this function is called.
- */
-static void z3fold_destroy_pool(struct z3fold_pool *pool)
-{
-	kfree(pool);
-}
-
 static inline void *mchunk_memmove(struct z3fold_header *zhdr,
 				unsigned short dst_chunk)
 {
@@ -347,6 +392,117 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 	return 0;
 }
 
+static void do_compact_page(struct z3fold_header *zhdr, bool locked)
+{
+	struct z3fold_pool *pool = zhdr->pool;
+	struct page *page;
+	struct list_head *unbuddied;
+	int fchunks;
+
+	page = virt_to_page(zhdr);
+	if (locked)
+		WARN_ON(z3fold_page_trylock(zhdr));
+	else
+		z3fold_page_lock(zhdr);
+	if (test_bit(PAGE_STALE, &page->private) ||
+	    !test_and_clear_bit(NEEDS_COMPACTING, &page->private)) {
+		z3fold_page_unlock(zhdr);
+		return;
+	}
+	spin_lock(&pool->lock);
+	list_del_init(&zhdr->buddy);
+	spin_unlock(&pool->lock);
+
+	z3fold_compact_page(zhdr);
+	unbuddied = get_cpu_ptr(pool->unbuddied);
+	fchunks = num_free_chunks(zhdr);
+	if (fchunks < NCHUNKS &&
+	    (!zhdr->first_chunks || !zhdr->middle_chunks ||
+			!zhdr->last_chunks)) {
+		/* the page's not completely free and it's unbuddied */
+		spin_lock(&pool->lock);
+		list_add(&zhdr->buddy, &unbuddied[fchunks]);
+		spin_unlock(&pool->lock);
+		zhdr->cpu = smp_processor_id();
+	}
+	put_cpu_ptr(pool->unbuddied);
+	z3fold_page_unlock(zhdr);
+}
+
+static void compact_page_work(struct work_struct *w)
+{
+	struct z3fold_header *zhdr = container_of(w, struct z3fold_header,
+						work);
+
+	do_compact_page(zhdr, false);
+}
+
+
+/*
+ * API Functions
+ */
+
+/**
+ * z3fold_create_pool() - create a new z3fold pool
+ * @name:	pool name
+ * @gfp:	gfp flags when allocating the z3fold pool structure
+ * @ops:	user-defined operations for the z3fold pool
+ *
+ * Return: pointer to the new z3fold pool or NULL if the metadata allocation
+ * failed.
+ */
+static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
+		const struct z3fold_ops *ops)
+{
+	struct z3fold_pool *pool = NULL;
+	int i, cpu;
+
+	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
+	if (!pool)
+		goto out;
+	spin_lock_init(&pool->lock);
+	spin_lock_init(&pool->stale_lock);
+	pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
+	for_each_possible_cpu(cpu) {
+		struct list_head *unbuddied =
+				per_cpu_ptr(pool->unbuddied, cpu);
+		for_each_unbuddied_list(i, 0)
+			INIT_LIST_HEAD(&unbuddied[i]);
+	}
+	INIT_LIST_HEAD(&pool->lru);
+	INIT_LIST_HEAD(&pool->stale);
+	atomic64_set(&pool->pages_nr, 0);
+	pool->name = name;
+	pool->compact_wq = create_singlethread_workqueue(pool->name);
+	if (!pool->compact_wq)
+		goto out;
+	pool->release_wq = create_singlethread_workqueue(pool->name);
+	if (!pool->release_wq)
+		goto out_wq;
+	INIT_WORK(&pool->work, free_pages_work);
+	pool->ops = ops;
+	return pool;
+
+out_wq:
+	destroy_workqueue(pool->compact_wq);
+out:
+	kfree(pool);
+	return NULL;
+}
+
+/**
+ * z3fold_destroy_pool() - destroys an existing z3fold pool
+ * @pool:	the z3fold pool to be destroyed
+ *
+ * The pool should be emptied before this function is called.
+ */
+static void z3fold_destroy_pool(struct z3fold_pool *pool)
+{
+	destroy_workqueue(pool->release_wq);
+	destroy_workqueue(pool->compact_wq);
+	kfree(pool);
+}
+
 /**
  * z3fold_alloc() - allocates a region of a given size
  * @pool:	z3fold pool from which to allocate
@@ -371,8 +527,9 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 {
 	int chunks = 0, i, freechunks;
 	struct z3fold_header *zhdr = NULL;
+	struct page *page = NULL;
 	enum buddy bud;
-	struct page *page;
+	bool can_sleep = (gfp & __GFP_RECLAIM) == __GFP_RECLAIM;
 
 	if (!size || (gfp & __GFP_HIGHMEM))
 		return -EINVAL;
@@ -383,23 +540,57 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
 		bud = HEADLESS;
 	else {
+		struct list_head *unbuddied;
 		chunks = size_to_chunks(size);
 
+lookup:
 		/* First, try to find an unbuddied z3fold page. */
-		zhdr = NULL;
+		unbuddied = get_cpu_ptr(pool->unbuddied);
 		for_each_unbuddied_list(i, chunks) {
-			spin_lock(&pool->lock);
-			zhdr = list_first_entry_or_null(&pool->unbuddied[i],
+			struct list_head *l = &unbuddied[i];
+
+			zhdr = list_first_entry_or_null(READ_ONCE(l),
 						struct z3fold_header, buddy);
-			if (!zhdr || !z3fold_page_trylock(zhdr)) {
-				spin_unlock(&pool->lock);
+
+			if (!zhdr)
 				continue;
+
+			/* Re-check under lock. */
+			spin_lock(&pool->lock);
+			l = &unbuddied[i];
+			if (unlikely(zhdr != list_first_entry(READ_ONCE(l),
+					struct z3fold_header, buddy)) ||
+			    !z3fold_page_trylock(zhdr)) {
+				spin_unlock(&pool->lock);
+				put_cpu_ptr(pool->unbuddied);
+				goto lookup;
 			}
-			kref_get(&zhdr->refcount);
 			list_del_init(&zhdr->buddy);
+			zhdr->cpu = -1;
 			spin_unlock(&pool->lock);
 
 			page = virt_to_page(zhdr);
+			if (test_bit(NEEDS_COMPACTING, &page->private)) {
+				z3fold_page_unlock(zhdr);
+				zhdr = NULL;
+				put_cpu_ptr(pool->unbuddied);
+				if (can_sleep)
+					cond_resched();
+				goto lookup;
+			}
+
+			/*
+			 * this page could not be removed from its unbuddied
+			 * list while pool lock was held, and then we've taken
+			 * page lock so kref_put could not be called before
+			 * we got here, so it's safe to just call kref_get()
+			 */
+			kref_get(&zhdr->refcount);
+			break;
+		}
+		put_cpu_ptr(pool->unbuddied);
+
+		if (zhdr) {
 			if (zhdr->first_chunks == 0) {
 				if (zhdr->middle_chunks != 0 &&
 				    chunks >= zhdr->start_middle)
@@ -411,32 +602,49 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			else if (zhdr->middle_chunks == 0)
 				bud = MIDDLE;
 			else {
-				z3fold_page_unlock(zhdr);
-				spin_lock(&pool->lock);
 				if (kref_put(&zhdr->refcount,
-					     release_z3fold_page))
+					     release_z3fold_page_locked))
 					atomic64_dec(&pool->pages_nr);
-				spin_unlock(&pool->lock);
+				else
+					z3fold_page_unlock(zhdr);
 				pr_err("No free chunks in unbuddied\n");
 				WARN_ON(1);
-				continue;
+				goto lookup;
 			}
 			goto found;
 		}
 		bud = FIRST;
 	}
 
-	/* Couldn't find unbuddied z3fold page, create new one */
-	page = alloc_page(gfp);
+	spin_lock(&pool->stale_lock);
+	zhdr = list_first_entry_or_null(&pool->stale,
+					struct z3fold_header, buddy);
+	/*
+	 * Before allocating a page, let's see if we can take one from the
+	 * stale pages list. cancel_work_sync() can sleep so we must make
+	 * sure it won't be called in case we're in atomic context.
+	 */
+	if (zhdr && (can_sleep || !work_pending(&zhdr->work) ||
+	    !unlikely(work_busy(&zhdr->work)))) {
+		list_del(&zhdr->buddy);
+		clear_bit(NEEDS_COMPACTING, &page->private);
+		spin_unlock(&pool->stale_lock);
+		if (can_sleep)
+			cancel_work_sync(&zhdr->work);
+		page = virt_to_page(zhdr);
+	} else {
+		spin_unlock(&pool->stale_lock);
+		page = alloc_page(gfp);
+	}
+
 	if (!page)
 		return -ENOMEM;
 
 	atomic64_inc(&pool->pages_nr);
-	zhdr = init_z3fold_page(page);
+	zhdr = init_z3fold_page(page, pool);
 
 	if (bud == HEADLESS) {
 		set_bit(PAGE_HEADLESS, &page->private);
-		spin_lock(&pool->lock);
 		goto headless;
 	}
 	z3fold_page_lock(zhdr);
@@ -451,15 +659,21 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
 	}
 
-	spin_lock(&pool->lock);
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
 			zhdr->middle_chunks == 0) {
+		struct list_head *unbuddied = get_cpu_ptr(pool->unbuddied);
+
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		spin_lock(&pool->lock);
+		list_add(&zhdr->buddy, &unbuddied[freechunks]);
+		spin_unlock(&pool->lock);
+		zhdr->cpu = smp_processor_id();
+		put_cpu_ptr(pool->unbuddied);
 	}
 
 headless:
+	spin_lock(&pool->lock);
 	/* Add/move z3fold page to beginning of LRU */
 	if (!list_empty(&page->lru))
 		list_del(&page->lru);
@@ -487,7 +701,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 {
 	struct z3fold_header *zhdr;
-	int freechunks;
 	struct page *page;
 	enum buddy bud;
 
@@ -526,25 +739,27 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		spin_unlock(&pool->lock);
 		free_z3fold_page(page);
 		atomic64_dec(&pool->pages_nr);
-	} else {
-		if (zhdr->first_chunks != 0 || zhdr->middle_chunks != 0 ||
-		    zhdr->last_chunks != 0) {
-			z3fold_compact_page(zhdr);
-			/* Add to the unbuddied list */
-			spin_lock(&pool->lock);
-			if (!list_empty(&zhdr->buddy))
-				list_del(&zhdr->buddy);
-			freechunks = num_free_chunks(zhdr);
-			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
-			spin_unlock(&pool->lock);
-		}
+		return;
+	}
+
+	if (kref_put(&zhdr->refcount, release_z3fold_page_locked_list)) {
+		atomic64_dec(&pool->pages_nr);
+		return;
+	}
+	if (test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
 		z3fold_page_unlock(zhdr);
+		return;
+	}
+	if (zhdr->cpu < 0 || !cpu_online(zhdr->cpu)) {
 		spin_lock(&pool->lock);
-		if (kref_put(&zhdr->refcount, release_z3fold_page))
-			atomic64_dec(&pool->pages_nr);
+		list_del_init(&zhdr->buddy);
 		spin_unlock(&pool->lock);
+		zhdr->cpu = -1;
+		do_compact_page(zhdr, true);
+		return;
 	}
-
+	queue_work_on(zhdr->cpu, pool->compact_wq, &zhdr->work);
+	z3fold_page_unlock(zhdr);
 }
 
 /**
@@ -585,9 +800,10 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
  */
 static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 {
-	int i, ret = 0, freechunks;
-	struct z3fold_header *zhdr;
-	struct page *page;
+	int i, ret = 0;
+	struct z3fold_header *zhdr = NULL;
+	struct page *page = NULL;
+	struct list_head *pos;
 	unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
 
 	spin_lock(&pool->lock);
@@ -600,16 +816,24 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			spin_unlock(&pool->lock);
 			return -EINVAL;
 		}
-		page = list_last_entry(&pool->lru, struct page, lru);
+		list_for_each_prev(pos, &pool->lru) {
+			page = list_entry(pos, struct page, lru);
+			if (test_bit(PAGE_HEADLESS, &page->private))
+				/* candidate found */
+				break;
+
+			zhdr = page_address(page);
+			if (!z3fold_page_trylock(zhdr))
+				continue; /* can't evict at this point */
+			kref_get(&zhdr->refcount);
+			list_del_init(&zhdr->buddy);
+			zhdr->cpu = -1;
+		}
+
 		list_del_init(&page->lru);
+		spin_unlock(&pool->lock);
 
-		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
-			if (!list_empty(&zhdr->buddy))
-				list_del_init(&zhdr->buddy);
-			kref_get(&zhdr->refcount);
-			spin_unlock(&pool->lock);
-			z3fold_page_lock(zhdr);
 			/*
 			 * We need encode the handles before unlocking, since
 			 * we can race with free that will set
@@ -624,11 +848,14 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				middle_handle = encode_handle(zhdr, MIDDLE);
 			if (zhdr->last_chunks)
 				last_handle = encode_handle(zhdr, LAST);
+			/*
+			 * it's safe to unlock here because we hold a
+			 * reference to this page
+			 */
 			z3fold_page_unlock(zhdr);
 		} else {
 			first_handle = encode_handle(zhdr, HEADLESS);
 			last_handle = middle_handle = 0;
-			spin_unlock(&pool->lock);
 		}
 
 		/* Issue the eviction callback(s) */
@@ -652,31 +879,12 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			if (ret == 0) {
 				free_z3fold_page(page);
 				return 0;
-			} else {
-				spin_lock(&pool->lock);
-			}
-		} else {
-			z3fold_page_lock(zhdr);
-			if ((zhdr->first_chunks || zhdr->last_chunks ||
-			     zhdr->middle_chunks) &&
-			    !(zhdr->first_chunks && zhdr->last_chunks &&
-			      zhdr->middle_chunks)) {
-				z3fold_compact_page(zhdr);
-				/* add to unbuddied list */
-				spin_lock(&pool->lock);
-				freechunks = num_free_chunks(zhdr);
-				list_add(&zhdr->buddy,
-					 &pool->unbuddied[freechunks]);
-				spin_unlock(&pool->lock);
-			}
-			z3fold_page_unlock(zhdr);
-			spin_lock(&pool->lock);
-			if (kref_put(&zhdr->refcount, release_z3fold_page)) {
-				spin_unlock(&pool->lock);
-				atomic64_dec(&pool->pages_nr);
-				return 0;
 			}
+		} else if (kref_put(&zhdr->refcount, release_z3fold_page)) {
+			atomic64_dec(&pool->pages_nr);
+			return 0;
 		}
+		spin_lock(&pool->lock);
 
 		/*
 		 * Add to the beginning of LRU.
@@ -795,7 +1003,8 @@ static void *z3fold_zpool_create(const char *name, gfp_t gfp,
 {
 	struct z3fold_pool *pool;
 
-	pool = z3fold_create_pool(gfp, zpool_ops ? &z3fold_zpool_ops : NULL);
+	pool = z3fold_create_pool(name, gfp,
+				zpool_ops ? &z3fold_zpool_ops : NULL);
 	if (pool) {
 		pool->zpool = zpool;
 		pool->zpool_ops = zpool_ops;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
