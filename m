Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7216B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:52:11 -0500 (EST)
Received: by padet14 with SMTP id et14so29924667pad.11
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:10 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id p2si21003881pdb.220.2015.02.23.11.52.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:52:09 -0800 (PST)
Received: by pabrd3 with SMTP id rd3so30034947pab.1
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:08 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v2 2/5] gcma: utilize reserved memory as discardable memory
Date: Tue, 24 Feb 2015 04:54:20 +0900
Message-Id: <1424721263-25314-3-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Because gcma reserves large amount of memory during early boot and let
it be used for contiguous memory requests only, system memory space
efficiency could be degraded if the reserved area being idle. The
problem could be settled by lending the reserved area to other clients.
In this context, we could call contiguous memory requests as first-class
clients and other clients as second-class clients. CMA also shares this
idea using movable pages as second-class clients.

Key point of this idea is, niceness of second-class clients. If
second-class clients does not pay borrowed pages back soon while
first-class clients waiting them, first-class clients could suffer from
slow latency or failure.

For that, gcma restricts second-class clients to use the reserved area
as only easily discardable memory. With the restriction, gcma guarantees
success and fast latency by discarding pages of second-class clients
whenever first-class client needs them.

This commit implements interface and backend of discardable memory
inside gcma. Any subsystem satisfying with discardable memory could be
second-class clients of gcma by using the interface.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/gcma.h |  16 +-
 mm/gcma.c            | 751 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 754 insertions(+), 13 deletions(-)

diff --git a/include/linux/gcma.h b/include/linux/gcma.h
index cda481f..005bf77 100644
--- a/include/linux/gcma.h
+++ b/include/linux/gcma.h
@@ -4,7 +4,21 @@
  * GCMA aims for contiguous memory allocation with success and fast
  * latency guarantee.
  * It reserves large amount of memory and let it be allocated to
- * contiguous memory requests.
+ * contiguous memory requests. Because system memory space efficiency could be
+ * degraded if reserved area being idle, GCMA let the reserved area could be
+ * used by other clients with lower priority.
+ * We call those lower priority clients as second-class clients. In this
+ * context, contiguous memory requests are first-class clients, of course.
+ *
+ * With this idea, gcma withdraw pages being used for second-class clients and
+ * gives them to first-class clients if they required. Because latency
+ * and success of first-class clients depend on speed and availability of
+ * withdrawing, GCMA restricts only easily discardable memory could be used for
+ * second-class clients.
+ *
+ * To support various second-class clients, GCMA provides interface and
+ * backend of discardable memory. Any candiates satisfying with discardable
+ * memory could be second-class client of GCMA using the interface.
  *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
diff --git a/mm/gcma.c b/mm/gcma.c
index 3f6a337..dc70fa8 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -4,7 +4,21 @@
  * GCMA aims for contiguous memory allocation with success and fast
  * latency guarantee.
  * It reserves large amount of memory and let it be allocated to
- * contiguous memory requests.
+ * contiguous memory requests. Because system memory space efficiency could be
+ * degraded if reserved area being idle, GCMA let the reserved area could be
+ * used by other clients with lower priority.
+ * We call those lower priority clients as second-class clients. In this
+ * context, contiguous memory requests are first-class clients, of course.
+ *
+ * With this idea, gcma withdraw pages being used for second-class clients and
+ * gives them to first-class clients if they required. Because latency
+ * and success of first-class clients depend on speed and availability of
+ * withdrawing, GCMA restricts only easily discardable memory could be used for
+ * second-class clients.
+ *
+ * To support various second-class clients, GCMA provides interface and
+ * backend of discardable memory. Any candiates satisfying with discardable
+ * memory could be second-class client of GCMA using the interface.
  *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
@@ -18,6 +32,9 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 
+/* XXX: What's the ideal? */
+#define NR_EVICT_BATCH	32
+
 struct gcma {
 	spinlock_t lock;
 	unsigned long *bitmap;
@@ -36,6 +53,114 @@ static struct gcma_info ginfo = {
 };
 
 /*
+ * Discardable memory(dmem) store and load easily discardable pages inside
+ * gcma area. Because it's discardable memory, loading stored page could fail
+ * anytime.
+ */
+
+/* entry for a discardable page */
+struct dmem_entry {
+	struct rb_node rbnode;
+	struct gcma *gcma;
+	void *key;
+	struct page *page;
+	atomic_t refcount;
+};
+
+/* dmem hash bucket */
+struct dmem_hashbucket {
+	struct dmem *dmem;
+	struct rb_root rbroot;
+	spinlock_t lock;
+};
+
+/* dmem pool */
+struct dmem_pool {
+	struct dmem_hashbucket *hashbuckets;
+};
+
+struct dmem {
+	struct dmem_pool **pools;
+	unsigned nr_pools;
+	unsigned nr_hash;
+	struct kmem_cache *key_cache;
+	size_t bytes_key;
+	struct list_head lru_list;
+	spinlock_t lru_lock;
+
+	unsigned (*hash_key)(void *key);
+	int (*compare)(void *lkey, void *rkey);
+};
+
+static struct kmem_cache *dmem_entry_cache;
+
+static unsigned long dmem_evict_lru(struct dmem *dmem, unsigned long nr_pages);
+
+static struct dmem_hashbucket *dmem_hashbuck(struct page *page)
+{
+	return (struct dmem_hashbucket *)page->mapping;
+}
+
+static void set_dmem_hashbuck(struct page *page, struct dmem_hashbucket *buck)
+{
+	page->mapping = (struct address_space *)buck;
+}
+
+static struct dmem_entry *dmem_entry(struct page *page)
+{
+	return (struct dmem_entry *)page->index;
+}
+
+static void set_dmem_entry(struct page *page, struct dmem_entry *entry)
+{
+	page->index = (pgoff_t)entry;
+}
+
+/*
+ * Flags for status of a page in gcma
+ *
+ * GF_LRU
+ * The page is being used for a dmem and hang on LRU list of the dmem.
+ * It could be discarded for contiguous memory allocation easily.
+ * Protected by dmem->lru_lock.
+ *
+ * GF_RECLAIMING
+ * The page is being discarded for contiguous memory allocation.
+ * It should not be used for dmem anymore.
+ * Protected by dmem->lru_lock.
+ *
+ * GF_ISOLATED
+ * The page is isolated from dmem.
+ * GCMA clients can use the page safely while dmem should not.
+ * Protected by gcma->lock.
+ */
+enum gpage_flags {
+	GF_LRU = 0x1,
+	GF_RECLAIMING = 0x2,
+	GF_ISOLATED = 0x4,
+};
+
+static int gpage_flag(struct page *page, int flag)
+{
+	return page->private & flag;
+}
+
+static void set_gpage_flag(struct page *page, int flag)
+{
+	page->private |= flag;
+}
+
+static void clear_gpage_flag(struct page *page, int flag)
+{
+	page->private &= ~flag;
+}
+
+static void clear_gpage_flagall(struct page *page)
+{
+	page->private = 0;
+}
+
+/*
  * gcma_init - initializes a contiguous memory area
  *
  * @start_pfn	start pfn of contiguous memory area
@@ -93,11 +218,13 @@ static struct page *gcma_alloc_page(struct gcma *gcma)
 	bitmap_set(bitmap, bit, 1);
 	page = pfn_to_page(gcma->base_pfn + bit);
 	spin_unlock(&gcma->lock);
+	clear_gpage_flagall(page);
 
 out:
 	return page;
 }
 
+/* Caller should hold lru_lock */
 static void gcma_free_page(struct gcma *gcma, struct page *page)
 {
 	unsigned long pfn, offset;
@@ -107,36 +234,632 @@ static void gcma_free_page(struct gcma *gcma, struct page *page)
 	spin_lock(&gcma->lock);
 	offset = pfn - gcma->base_pfn;
 
-	bitmap_clear(gcma->bitmap, offset, 1);
+	if (likely(!gpage_flag(page, GF_RECLAIMING))) {
+		bitmap_clear(gcma->bitmap, offset, 1);
+	} else {
+		/*
+		 * The page should be safe to be used for a thread which
+		 * reclaimed the page.
+		 * To prevent further allocation from other thread,
+		 * set bitmap and mark the page as isolated.
+		 */
+		bitmap_set(gcma->bitmap, offset, 1);
+		set_gpage_flag(page, GF_ISOLATED);
+	}
 	spin_unlock(&gcma->lock);
 }
 
 /*
+ * In the case that a entry with the same offset is found, a pointer to
+ * the existing entry is stored in dupentry and the function returns -EEXIST.
+ */
+static int dmem_insert_entry(struct dmem_hashbucket *bucket,
+		struct dmem_entry *entry,
+		struct dmem_entry **dupentry)
+{
+	struct rb_node **link = &bucket->rbroot.rb_node, *parent = NULL;
+	struct dmem_entry *iter;
+	int cmp;
+
+	while (*link) {
+		parent = *link;
+		iter = rb_entry(parent, struct dmem_entry, rbnode);
+		cmp = bucket->dmem->compare(entry->key, iter->key);
+		if (cmp < 0)
+			link = &(*link)->rb_left;
+		else if (cmp > 0)
+			link = &(*link)->rb_right;
+		else {
+			*dupentry = iter;
+			return -EEXIST;
+		}
+	}
+	rb_link_node(&entry->rbnode, parent, link);
+	rb_insert_color(&entry->rbnode, &bucket->rbroot);
+	return 0;
+}
+
+static void dmem_erase_entry(struct dmem_hashbucket *bucket,
+		struct dmem_entry *entry)
+{
+	if (!RB_EMPTY_NODE(&entry->rbnode)) {
+		rb_erase(&entry->rbnode, &bucket->rbroot);
+		RB_CLEAR_NODE(&entry->rbnode);
+	}
+}
+
+static struct dmem_entry *dmem_search_entry(struct dmem_hashbucket *bucket,
+		void *key)
+{
+	struct rb_node *node = bucket->rbroot.rb_node;
+	struct dmem_entry *iter;
+	int cmp;
+
+	while (node) {
+		iter = rb_entry(node, struct dmem_entry, rbnode);
+		cmp = bucket->dmem->compare(key, iter->key);
+		if (cmp < 0)
+			node = node->rb_left;
+		else if (cmp > 0)
+			node = node->rb_right;
+		else
+			return iter;
+	}
+	return NULL;
+}
+
+/* Allocates a page from gcma areas using round-robin way */
+static struct page *dmem_alloc_page(struct dmem *dmem, struct gcma **res_gcma)
+{
+	struct page *page;
+	struct gcma *gcma;
+
+retry:
+	spin_lock(&ginfo.lock);
+	gcma = list_first_entry(&ginfo.head, struct gcma, list);
+	list_move_tail(&gcma->list, &ginfo.head);
+
+	list_for_each_entry(gcma, &ginfo.head, list) {
+		page = gcma_alloc_page(gcma);
+		if (page) {
+			spin_unlock(&ginfo.lock);
+			goto got;
+		}
+	}
+	spin_unlock(&ginfo.lock);
+
+	/*
+	 * Failed to alloc a page from entire gcma. Evict adequate LRU
+	 * discardable pages and try allocation again.
+	 */
+	if (dmem_evict_lru(dmem, NR_EVICT_BATCH))
+		goto retry;
+
+got:
+	*res_gcma = gcma;
+	return page;
+}
+
+/* Should be called from dmem_put only */
+static void dmem_free_entry(struct dmem *dmem, struct dmem_entry *entry)
+{
+	gcma_free_page(entry->gcma, entry->page);
+	kmem_cache_free(dmem->key_cache, entry->key);
+	kmem_cache_free(dmem_entry_cache, entry);
+}
+
+/* Caller should hold hashbucket spinlock */
+static void dmem_get(struct dmem_entry *entry)
+{
+	atomic_inc(&entry->refcount);
+}
+
+/*
+ * Caller should hold hashbucket spinlock and dmem lru_lock.
+ * Remove from the bucket and free it, if nobody reference the entry.
+ */
+static void dmem_put(struct dmem_hashbucket *buck,
+				struct dmem_entry *entry)
+{
+	int refcount = atomic_dec_return(&entry->refcount);
+
+	BUG_ON(refcount < 0);
+
+	if (refcount == 0) {
+		struct page *page = entry->page;
+
+		dmem_erase_entry(buck, entry);
+		list_del(&page->lru);
+		dmem_free_entry(buck->dmem, entry);
+	}
+}
+
+/*
+ * dmem_evict_lru - evict @nr_pages LRU dmem pages
+ *
+ * @dmem	dmem to evict LRU pages from
+ * @nr_pages	number of LRU pages to be evicted
+ *
+ * Returns number of successfully evicted pages
+ */
+static unsigned long dmem_evict_lru(struct dmem *dmem, unsigned long nr_pages)
+{
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry;
+	struct page *page, *n;
+	unsigned long evicted = 0;
+	u8 key[dmem->bytes_key];
+	LIST_HEAD(free_pages);
+
+	spin_lock(&dmem->lru_lock);
+	list_for_each_entry_safe_reverse(page, n, &dmem->lru_list, lru) {
+		entry = dmem_entry(page);
+
+		/*
+		 * the entry could be free by other thread in the while.
+		 * check whether the situation occurred and avoid others to
+		 * free it by compare reference count and increase it
+		 * atomically.
+		 */
+		if (!atomic_inc_not_zero(&entry->refcount))
+			continue;
+
+		clear_gpage_flag(page, GF_LRU);
+		list_move(&page->lru, &free_pages);
+		if (++evicted >= nr_pages)
+			break;
+	}
+	spin_unlock(&dmem->lru_lock);
+
+	list_for_each_entry_safe(page, n, &free_pages, lru) {
+		buck = dmem_hashbuck(page);
+		entry = dmem_entry(page);
+
+		spin_lock(&buck->lock);
+		spin_lock(&dmem->lru_lock);
+		/* drop refcount increased by above loop */
+		memcpy(&key, entry->key, dmem->bytes_key);
+		dmem_put(buck, entry);
+		/* free entry if the entry is still in tree */
+		if (dmem_search_entry(buck, &key))
+			dmem_put(buck, entry);
+		spin_unlock(&dmem->lru_lock);
+		spin_unlock(&buck->lock);
+	}
+
+	return evicted;
+}
+
+/* Caller should hold bucket spinlock */
+static struct dmem_entry *dmem_find_get_entry(struct dmem_hashbucket *buck,
+						void *key)
+{
+	struct dmem_entry *entry;
+
+	assert_spin_locked(&buck->lock);
+	entry = dmem_search_entry(buck, key);
+	if (entry)
+		dmem_get(entry);
+
+	return entry;
+}
+
+static struct dmem_hashbucket *dmem_find_hashbucket(struct dmem *dmem,
+							struct dmem_pool *pool,
+							void *key)
+{
+	return &pool->hashbuckets[dmem->hash_key(key)];
+}
+
+/*
+ * dmem_init_pool - initialize a pool in dmem
+ *
+ * @dmem	dmem of a pool to be initialized
+ * @pool_id	id of a pool to be initialized
+ *
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int dmem_init_pool(struct dmem *dmem, unsigned pool_id)
+{
+	struct dmem_pool *pool;
+	struct dmem_hashbucket *buck;
+	int i;
+
+	pool = kzalloc(sizeof(struct dmem_pool), GFP_KERNEL);
+	if (!pool) {
+		pr_warn("%s: failed to alloc dmem pool %d\n",
+				__func__, pool_id);
+		return -ENOMEM;
+	}
+
+	pool->hashbuckets = kzalloc(
+				sizeof(struct dmem_hashbucket) * dmem->nr_hash,
+				GFP_KERNEL);
+	if (!pool) {
+		pr_warn("%s: failed to alloc hashbuckets\n", __func__);
+		kfree(pool);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < dmem->nr_hash; i++) {
+		buck = &pool->hashbuckets[i];
+		buck->dmem = dmem;
+		buck->rbroot = RB_ROOT;
+		spin_lock_init(&buck->lock);
+	}
+
+	dmem->pools[pool_id] = pool;
+	return 0;
+}
+
+/*
+ * dmem_store_page - store a page in dmem
+ *
+ * Saves content of @page in gcma area and manages it using dmem. The content
+ * could be loaded again from dmem using @key if it has not been discarded for
+ * first-class clients.
+ *
+ * @dmem	dmem to store the page in
+ * @pool_id	id of a dmem pool to store the page in
+ * @key		key of the page to be stored in
+ * @page	page to be stored in
+ *
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int dmem_store_page(struct dmem *dmem, unsigned pool_id, void *key,
+			struct page *page)
+{
+	struct dmem_pool *pool;
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry, *dupentry;
+	struct gcma *gcma;
+	struct page *gcma_page = NULL;
+
+	u8 *src, *dst;
+	int ret;
+
+	pool = dmem->pools[pool_id];
+	if (!pool) {
+		pr_warn("%s: dmem pool for id %d is not exist\n",
+				__func__, pool_id);
+		return -ENODEV;
+	}
+
+	gcma_page = dmem_alloc_page(dmem, &gcma);
+	if (!gcma_page)
+		return -ENOMEM;
+
+	entry = kmem_cache_alloc(dmem_entry_cache, GFP_ATOMIC);
+	if (!entry) {
+		spin_lock(&dmem->lru_lock);
+		gcma_free_page(gcma, gcma_page);
+		spin_unlock(&dmem->lru_lock);
+		return -ENOMEM;
+	}
+
+	entry->gcma = gcma;
+	entry->page = gcma_page;
+	entry->key = kmem_cache_alloc(dmem->key_cache, GFP_ATOMIC);
+	if (!entry->key) {
+		spin_lock(&dmem->lru_lock);
+		gcma_free_page(gcma, gcma_page);
+		spin_unlock(&dmem->lru_lock);
+		kmem_cache_free(dmem_entry_cache, entry);
+		return -ENOMEM;
+	}
+	memcpy(entry->key, key, dmem->bytes_key);
+	atomic_set(&entry->refcount, 1);
+	RB_CLEAR_NODE(&entry->rbnode);
+
+	buck = dmem_find_hashbucket(dmem, pool, entry->key);
+	set_dmem_hashbuck(gcma_page, buck);
+	set_dmem_entry(gcma_page, entry);
+
+	/* copy from orig data to gcma_page */
+	src = kmap_atomic(page);
+	dst = kmap_atomic(gcma_page);
+	memcpy(dst, src, PAGE_SIZE);
+	kunmap_atomic(src);
+	kunmap_atomic(dst);
+
+	spin_lock(&buck->lock);
+	do {
+		/*
+		 * Though this duplication scenario may happen rarely by
+		 * race of dmem client layer, we handle this case here rather
+		 * than fix the client layer because handling the possibility
+		 * of duplicates is part of the tmem ABI.
+		 */
+		ret = dmem_insert_entry(buck, entry, &dupentry);
+		if (ret == -EEXIST) {
+			dmem_erase_entry(buck, dupentry);
+			spin_lock(&dmem->lru_lock);
+			dmem_put(buck, dupentry);
+			spin_unlock(&dmem->lru_lock);
+		}
+	} while (ret == -EEXIST);
+
+	spin_lock(&dmem->lru_lock);
+	set_gpage_flag(gcma_page, GF_LRU);
+	list_add(&gcma_page->lru, &dmem->lru_list);
+	spin_unlock(&dmem->lru_lock);
+	spin_unlock(&buck->lock);
+
+	return ret;
+}
+
+/*
+ * dmem_load_page - load a page stored in dmem using @key
+ *
+ * @dmem	dmem which the page stored in
+ * @pool_id	id of a dmem pool the page stored in
+ * @key		key of the page looking for
+ * @page	page to store the loaded content
+ *
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int dmem_load_page(struct dmem *dmem, unsigned pool_id, void *key,
+			struct page *page)
+{
+	struct dmem_pool *pool;
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry;
+	struct page *gcma_page;
+	u8 *src, *dst;
+
+	pool = dmem->pools[pool_id];
+	if (!pool) {
+		pr_warn("dmem pool for id %d not exist\n", pool_id);
+		return -1;
+	}
+
+	buck = dmem_find_hashbucket(dmem, pool, key);
+
+	spin_lock(&buck->lock);
+	entry = dmem_find_get_entry(buck, key);
+	spin_unlock(&buck->lock);
+	if (!entry)
+		return -1;
+
+	gcma_page = entry->page;
+	src = kmap_atomic(gcma_page);
+	dst = kmap_atomic(page);
+	memcpy(dst, src, PAGE_SIZE);
+	kunmap_atomic(src);
+	kunmap_atomic(dst);
+
+	spin_lock(&buck->lock);
+	spin_lock(&dmem->lru_lock);
+	if (likely(gpage_flag(gcma_page, GF_LRU)))
+		list_move(&gcma_page->lru, &dmem->lru_list);
+	dmem_put(buck, entry);
+	spin_unlock(&dmem->lru_lock);
+	spin_unlock(&buck->lock);
+
+	return 0;
+}
+
+/*
+ * dmem_invalidate_entry - invalidates an entry from dmem
+ *
+ * @dmem	dmem of entry to be invalidated
+ * @pool_id	dmem pool id of entry to be invalidated
+ * @key		key of entry to be invalidated
+ *
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int dmem_invalidate_entry(struct dmem *dmem, unsigned pool_id, void *key)
+{
+	struct dmem_pool *pool;
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry;
+
+	pool = dmem->pools[pool_id];
+	buck = dmem_find_hashbucket(dmem, pool, key);
+
+	spin_lock(&buck->lock);
+	entry = dmem_search_entry(buck, key);
+	if (!entry) {
+		spin_unlock(&buck->lock);
+		return -ENOENT;
+	}
+
+	spin_lock(&dmem->lru_lock);
+	dmem_put(buck, entry);
+	spin_unlock(&dmem->lru_lock);
+	spin_unlock(&buck->lock);
+
+	return 0;
+}
+
+/*
+ * dmem_invalidate_pool - invalidates whole entries in a dmem pool
+ *
+ * @dmem	dmem of pool to be invalidated
+ * @pool_id	id of pool to be invalidated
+ *
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int dmem_invalidate_pool(struct dmem *dmem, unsigned pool_id)
+{
+	struct dmem_pool *pool;
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry, *n;
+	int i;
+
+	pool = dmem->pools[pool_id];
+	if (!pool)
+		return -1;
+
+	for (i = 0; i < dmem->nr_hash; i++) {
+		buck = &pool->hashbuckets[i];
+		spin_lock(&buck->lock);
+		rbtree_postorder_for_each_entry_safe(entry, n, &buck->rbroot,
+							rbnode) {
+			spin_lock(&dmem->lru_lock);
+			dmem_put(buck, entry);
+			spin_unlock(&dmem->lru_lock);
+		}
+		buck->rbroot = RB_ROOT;
+		spin_unlock(&buck->lock);
+	}
+
+	kfree(pool->hashbuckets);
+	kfree(pool);
+	dmem->pools[pool_id] = NULL;
+
+	return 0;
+}
+
+/*
+ * Return 0 if [start_pfn, end_pfn] is isolated.
+ * Otherwise, return first unisolated pfn from the start_pfn.
+ */
+static unsigned long isolate_interrupted(struct gcma *gcma,
+		unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long offset;
+	unsigned long *bitmap;
+	unsigned long pfn, ret = 0;
+	struct page *page;
+
+	spin_lock(&gcma->lock);
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		int set;
+
+		offset = pfn - gcma->base_pfn;
+		bitmap = gcma->bitmap + offset / BITS_PER_LONG;
+
+		set = test_bit(pfn % BITS_PER_LONG, bitmap);
+		if (!set) {
+			ret = pfn;
+			break;
+		}
+
+		page = pfn_to_page(pfn);
+		if (!gpage_flag(page, GF_ISOLATED)) {
+			ret = pfn;
+			break;
+		}
+
+	}
+	spin_unlock(&gcma->lock);
+	return ret;
+}
+
+/*
  * gcma_alloc_contig - allocates contiguous pages
  *
  * @start_pfn	start pfn of requiring contiguous memory area
- * @size	number of pages in requiring contiguous memory area
+ * @size	size of the requiring contiguous memory area
  *
  * Returns 0 on success, error code on failure.
  */
 int gcma_alloc_contig(struct gcma *gcma, unsigned long start_pfn,
 			unsigned long size)
 {
+	LIST_HEAD(free_pages);
+	struct dmem_hashbucket *buck;
+	struct dmem_entry *entry;
+	struct cleancache_dmem_key key;	/* cc key is larger than fs's */
+	struct page *page, *n;
 	unsigned long offset;
+	unsigned long *bitmap;
+	unsigned long pfn;
+	unsigned long orig_start = start_pfn;
+	spinlock_t *lru_lock;
 
-	spin_lock(&gcma->lock);
-	offset = start_pfn - gcma->base_pfn;
+retry:
+	for (pfn = start_pfn; pfn < start_pfn + size; pfn++) {
+		spin_lock(&gcma->lock);
+
+		offset = pfn - gcma->base_pfn;
+		bitmap = gcma->bitmap + offset / BITS_PER_LONG;
+		page = pfn_to_page(pfn);
+
+		if (!test_bit(offset % BITS_PER_LONG, bitmap)) {
+			/* set a bit to prevent allocation for dmem */
+			bitmap_set(gcma->bitmap, offset, 1);
+			set_gpage_flag(page, GF_ISOLATED);
+			spin_unlock(&gcma->lock);
+			continue;
+		}
+		if (gpage_flag(page, GF_ISOLATED)) {
+			spin_unlock(&gcma->lock);
+			continue;
+		}
+
+		/* Someone is using the page so it's complicated :( */
+		spin_unlock(&gcma->lock);
+
+		/* During dmem_store, hashbuck could not be set in page, yet */
+		if (dmem_hashbuck(page) == NULL)
+			continue;
+
+		lru_lock = &dmem_hashbuck(page)->dmem->lru_lock;
+		spin_lock(lru_lock);
+		spin_lock(&gcma->lock);
 
-	if (bitmap_find_next_zero_area(gcma->bitmap, gcma->size, offset,
-				size, 0) != 0) {
+		/* Avoid allocation from other threads */
+		set_gpage_flag(page, GF_RECLAIMING);
+
+		/*
+		 * The page is in LRU and being used by someone. Discard it
+		 * after removing from lru_list.
+		 */
+		if (gpage_flag(page, GF_LRU)) {
+			entry = dmem_entry(page);
+			if (atomic_inc_not_zero(&entry->refcount)) {
+				clear_gpage_flag(page, GF_LRU);
+				list_move(&page->lru, &free_pages);
+				goto next_page;
+			}
+		}
+
+		/*
+		 * The page is
+		 * 1) allocated by others but not yet in LRU in case of
+		 *    dmem_store or
+		 * 2) deleted from LRU but not yet from gcma's bitmap in case
+		 *    of dmem_invalidate or dmem_evict_lru.
+		 * Anycase, the race is small so retry after a while will see
+		 * success. Below isolate_interrupted handles it.
+		 */
+next_page:
 		spin_unlock(&gcma->lock);
-		pr_warn("already allocated region required: %lu, %lu",
-				start_pfn, size);
-		return -EINVAL;
+		spin_unlock(lru_lock);
 	}
 
-	bitmap_set(gcma->bitmap, offset, size);
-	spin_unlock(&gcma->lock);
+	/*
+	 * Since we increased refcount of the page above, we can access
+	 * dmem_entry with safe.
+	 */
+	list_for_each_entry_safe(page, n, &free_pages, lru) {
+		buck = dmem_hashbuck(page);
+		entry = dmem_entry(page);
+		lru_lock = &dmem_hashbuck(page)->dmem->lru_lock;
+
+		spin_lock(&buck->lock);
+		spin_lock(lru_lock);
+		/* drop refcount increased by above loop */
+		memcpy(&key, entry->key, dmem_hashbuck(page)->dmem->bytes_key);
+		dmem_put(buck, entry);
+		/* free entry if the entry is still in tree */
+		if (dmem_search_entry(buck, &key))
+			dmem_put(buck, entry);
+		spin_unlock(lru_lock);
+		spin_unlock(&buck->lock);
+	}
+
+	start_pfn = isolate_interrupted(gcma, orig_start, orig_start + size);
+	if (start_pfn)
+		goto retry;
 
 	return 0;
 }
@@ -162,6 +885,10 @@ static int __init init_gcma(void)
 {
 	pr_info("loading gcma\n");
 
+	dmem_entry_cache = KMEM_CACHE(dmem_entry, 0);
+	if (dmem_entry_cache == NULL)
+		return -ENOMEM;
+
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
