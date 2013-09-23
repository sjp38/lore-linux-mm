Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id E66956B0031
	for <linux-mm@kvack.org>; Sun, 22 Sep 2013 22:09:26 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so2602006pbc.31
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 19:09:26 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so1676329pab.17
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 19:09:24 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: move pool limit setting from zswap to zbud
Date: Mon, 23 Sep 2013 10:09:11 +0800
Message-Id: <1379902151-15549-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, sjenning@linux.vnet.ibm.com, k.kozlowski@samsung.com, mgorman@suse.de, Bob Liu <bob.liu@oracle.com>

It's more reasonable to set the pool limit in zbud because it's the allocate.
The higher layer should not necessarily care about how many pages are in use
and the allocator is what is responsible for the physical resource and deferring
the sizing of it to a higher layer will complicate the API.

This patch try to move the max pool limit setting from zswap to zbud, after this
patch the reclaim call layer(zswap-->zbud-->zswap) also becomes cleaner
(zbud-->zswap).

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/zbud.h |    1 -
 mm/zbud.c            |   98 ++++++++++++++++++++++++++++++++++++++++----------
 mm/zswap.c           |   56 ++++++-----------------------
 3 files changed, 90 insertions(+), 65 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..7f9ca38 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -14,7 +14,6 @@ void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
 void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
 u64 zbud_get_pool_size(struct zbud_pool *pool);
diff --git a/mm/zbud.c b/mm/zbud.c
index 9451361..1c1acb1 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -69,6 +69,17 @@
 #define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
 #define ZHDR_SIZE_ALIGNED CHUNK_SIZE
 
+static u64 zbud_pool_pages;		/* nr pages allocated by zbud */
+static u64 zbud_compressed_pages;	/* nr compressed pages sotred in zbud pool */
+static u64 zbud_max_pool_pages;		/* max pages can be allocated to zbud pool */
+static u64 zbud_pool_limit_hit;		/* count of pool limit hit */
+static u64 zbud_reclaim_fail;		/* nr reclaim failure after pool limit was reached */
+
+/* The maximum percentage of memory that the compressed pool can occupy */
+static unsigned int zbud_max_pool_percent = 20;
+module_param_named(max_pool_percent,
+			zbud_max_pool_percent, uint, 0644);
+
 /**
  * struct zbud_pool - stores metadata for each zbud pool
  * @lock:	protects all pool fields and first|last_chunk fields of any
@@ -80,7 +91,7 @@
  *		these zbud pages are full
  * @lru:	list tracking the zbud pages in LRU order by most recently
  *		added buddy.
- * @pages_nr:	number of zbud pages in the pool.
+ * @pool_list:	link to global pool list.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
  *
@@ -92,9 +103,14 @@ struct zbud_pool {
 	struct list_head unbuddied[NCHUNKS];
 	struct list_head buddied;
 	struct list_head lru;
-	u64 pages_nr;
+	struct list_head pool_list;
 	struct zbud_ops *ops;
 };
+static DEFINE_SPINLOCK(zbud_pool_lock);
+/*
+ * Glocal pool list, collect all zbud pools protected by zbud_pool_lock.
+ */
+LIST_HEAD(zbud_pool_list);
 
 /*
  * struct zbud_header - zbud page metadata occupying the first chunk of each
@@ -120,6 +136,7 @@ enum buddy {
 	FIRST,
 	LAST
 };
+static int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 
 /* Converts an allocation size in bytes to size in zbud chunks */
 static int size_to_chunks(int size)
@@ -146,6 +163,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
 static void free_zbud_page(struct zbud_header *zhdr)
 {
 	__free_page(virt_to_page(zhdr));
+	zbud_pool_pages--;
 }
 
 /*
@@ -212,8 +230,12 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
-	pool->pages_nr = 0;
 	pool->ops = ops;
+
+	/* Add to global pool list */
+	spin_lock(&zbud_pool_lock);
+	list_add(&pool->pool_list, &zbud_pool_list);
+	spin_unlock(&zbud_pool_lock);
 	return pool;
 }
 
@@ -225,6 +247,9 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
  */
 void zbud_destroy_pool(struct zbud_pool *pool)
 {
+	spin_lock(&zbud_pool_lock);
+	list_del(&pool->pool_list);
+	spin_unlock(&zbud_pool_lock);
 	kfree(pool);
 }
 
@@ -279,15 +304,30 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 
 	/* Couldn't find unbuddied zbud page, create new one */
 	spin_unlock(&pool->lock);
-	page = alloc_page(gfp);
-	if (!page)
+	if (zbud_pool_pages > zbud_max_pool_pages) {
+		struct zbud_pool *zpool;
+		zbud_pool_limit_hit++;
+		list_for_each_entry(zpool, &zbud_pool_list, pool_list) {
+			if (zbud_reclaim_page(zpool, 8))
+				zbud_reclaim_fail++;
+		}
+		/*
+		 * Once reach the limit, don't alloc new page in this
+		 * store.
+		 */
 		return -ENOMEM;
+	} else {
+		page = alloc_page(gfp);
+		if (!page)
+			return -ENOMEM;
+		zbud_pool_pages++;
+	}
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
 	zhdr = init_zbud_page(page);
 	bud = FIRST;
 
 found:
+	zbud_compressed_pages++;
 	if (bud == FIRST)
 		zhdr->first_chunks = chunks;
 	else
@@ -337,6 +377,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	else
 		zhdr->first_chunks = 0;
 
+	zbud_compressed_pages--;
 	if (zhdr->under_reclaim) {
 		/* zbud page is under reclaim, reclaim will free */
 		spin_unlock(&pool->lock);
@@ -350,7 +391,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		/* zbud page is empty, free */
 		list_del(&zhdr->lru);
 		free_zbud_page(zhdr);
-		pool->pages_nr--;
 	} else {
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
@@ -398,7 +438,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * no pages to evict or an eviction handler is not registered, -EAGAIN if
  * the retry limit was hit.
  */
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
+static int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 {
 	int i, ret, freechunks;
 	struct zbud_header *zhdr;
@@ -448,7 +488,6 @@ next:
 			 * return success.
 			 */
 			free_zbud_page(zhdr);
-			pool->pages_nr--;
 			spin_unlock(&pool->lock);
 			return 0;
 		} else if (zhdr->first_chunks == 0 ||
@@ -494,22 +533,45 @@ void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
 {
 }
 
-/**
- * zbud_get_pool_size() - gets the zbud pool size in pages
- * @pool:	pool whose size is being queried
- *
- * Returns: size in pages of the given pool.  The pool lock need not be
- * taken to access pages_nr.
- */
-u64 zbud_get_pool_size(struct zbud_pool *pool)
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+
+static struct dentry *zbud_debugfs_root;
+static int __init zbud_debugfs_init(void)
 {
-	return pool->pages_nr;
+	if (!debugfs_initialized())
+		return -ENODEV;
+
+	zbud_debugfs_root = debugfs_create_dir("zbud", NULL);
+	if (!zbud_debugfs_root)
+		return -ENOMEM;
+
+	debugfs_create_u64("pool_pages", S_IRUGO,
+			zbud_debugfs_root, &zbud_pool_pages);
+	debugfs_create_u64("compressed_pages", S_IRUGO,
+			zbud_debugfs_root, &zbud_compressed_pages);
+	debugfs_create_u64("allowed_max_pool_pages", S_IRUGO,
+			zbud_debugfs_root, &zbud_max_pool_pages);
+	debugfs_create_u64("pool_limit_hit", S_IRUGO,
+			zbud_debugfs_root, &zbud_pool_limit_hit);
+	debugfs_create_u64("reclaim_fail", S_IRUGO,
+			zbud_debugfs_root, &zbud_reclaim_fail);
+
+	return 0;
+}
+#else
+static int __init zbud_debugfs_init(void)
+{
+	return 0;
 }
+#endif
 
 static int __init init_zbud(void)
 {
 	/* Make sure the zbud header will fit in one chunk */
 	BUILD_BUG_ON(sizeof(struct zbud_header) > ZHDR_SIZE_ALIGNED);
+	zbud_max_pool_pages = totalram_pages * zbud_max_pool_percent / 100;
+	zbud_debugfs_init();
 	pr_info("loaded\n");
 	return 0;
 }
diff --git a/mm/zswap.c b/mm/zswap.c
index 841e35f..4a8b3c2 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -45,11 +45,6 @@
 /*********************************
 * statistics
 **********************************/
-/* Number of memory pages used by the compressed pool */
-static u64 zswap_pool_pages;
-/* The number of compressed pages currently stored in zswap */
-static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
-
 /*
  * The statistics below are not protected from concurrent access for
  * performance reasons so they may not be a 100% accurate.  However,
@@ -57,12 +52,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
  * certain event is occurring.
 */
 
-/* Pool limit was hit (see zswap_max_pool_percent) */
-static u64 zswap_pool_limit_hit;
 /* Pages written back when pool limit was reached */
 static u64 zswap_written_back_pages;
-/* Store failed due to a reclaim failure after pool limit was reached */
-static u64 zswap_reject_reclaim_fail;
 /* Compressed page was too big for the allocator to (optimally) store */
 static u64 zswap_reject_compress_poor;
 /* Store failed because underlying allocator could not get memory */
@@ -71,6 +62,10 @@ static u64 zswap_reject_alloc_fail;
 static u64 zswap_reject_kmemcache_fail;
 /* Duplicate store was encountered (rare) */
 static u64 zswap_duplicate_entry;
+/* Succ compressed a page and stored in zswap */
+static u64 zswap_succ_store;
+/* Succ loaded a page from zswap */
+static u64 zswap_succ_load;
 
 /*********************************
 * tunables
@@ -84,11 +79,6 @@ module_param_named(enabled, zswap_enabled, bool, 0);
 static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
 module_param_named(compressor, zswap_compressor, charp, 0);
 
-/* The maximum percentage of memory that the compressed pool can occupy */
-static unsigned int zswap_max_pool_percent = 20;
-module_param_named(max_pool_percent,
-			zswap_max_pool_percent, uint, 0644);
-
 /*********************************
 * compression functions
 **********************************/
@@ -359,15 +349,6 @@ cleanup:
 	return -ENOMEM;
 }
 
-/*********************************
-* helpers
-**********************************/
-static bool zswap_is_full(void)
-{
-	return (totalram_pages * zswap_max_pool_percent / 100 <
-		zswap_pool_pages);
-}
-
 /*
  * Carries out the common pattern of freeing and entry's zsmalloc allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
@@ -376,8 +357,6 @@ static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 {
 	zbud_free(tree->pool, entry->handle);
 	zswap_entry_cache_free(entry);
-	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
 }
 
 /*********************************
@@ -617,16 +596,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		goto reject;
 	}
 
-	/* reclaim space if needed */
-	if (zswap_is_full()) {
-		zswap_pool_limit_hit++;
-		if (zbud_reclaim_page(tree->pool, 8)) {
-			zswap_reject_reclaim_fail++;
-			ret = -ENOMEM;
-			goto reject;
-		}
-	}
-
 	/* allocate entry */
 	entry = zswap_entry_cache_alloc(GFP_KERNEL);
 	if (!entry) {
@@ -686,8 +655,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	spin_unlock(&tree->lock);
 
 	/* update stats */
-	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_succ_store++;
 
 	return 0;
 
@@ -733,6 +701,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	zbud_unmap(tree->pool, entry->handle);
 	BUG_ON(ret);
 
+	zswap_succ_load++;
 	spin_lock(&tree->lock);
 	refcount = zswap_entry_put(entry);
 	if (likely(refcount)) {
@@ -800,7 +769,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
 		zbud_free(tree->pool, entry->handle);
 		zswap_entry_cache_free(entry);
-		atomic_dec(&zswap_stored_pages);
 	}
 	tree->rbroot = RB_ROOT;
 	spin_unlock(&tree->lock);
@@ -856,10 +824,6 @@ static int __init zswap_debugfs_init(void)
 	if (!zswap_debugfs_root)
 		return -ENOMEM;
 
-	debugfs_create_u64("pool_limit_hit", S_IRUGO,
-			zswap_debugfs_root, &zswap_pool_limit_hit);
-	debugfs_create_u64("reject_reclaim_fail", S_IRUGO,
-			zswap_debugfs_root, &zswap_reject_reclaim_fail);
 	debugfs_create_u64("reject_alloc_fail", S_IRUGO,
 			zswap_debugfs_root, &zswap_reject_alloc_fail);
 	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
@@ -870,10 +834,10 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_written_back_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
-	debugfs_create_u64("pool_pages", S_IRUGO,
-			zswap_debugfs_root, &zswap_pool_pages);
-	debugfs_create_atomic_t("stored_pages", S_IRUGO,
-			zswap_debugfs_root, &zswap_stored_pages);
+	debugfs_create_u64("succ_store_page", S_IRUGO,
+			zswap_debugfs_root, &zswap_succ_store);
+	debugfs_create_u64("succ_load_page", S_IRUGO,
+			zswap_debugfs_root, &zswap_succ_load);
 
 	return 0;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
