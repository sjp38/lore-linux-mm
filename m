Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 9CC726B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 02:26:19 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so286278pbb.13
        for <linux-mm@kvack.org>; Mon, 20 May 2013 23:26:18 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RFC PATCH] zswap: add zswap shrinker
Date: Tue, 21 May 2013 14:26:07 +0800
Message-Id: <1369117567-26704-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de, riel@redhat.com, dave@sr71.net, hughd@google.com, Bob Liu <bob.liu@oracle.com>

In my understanding, currenlty zswap have a few problems.
1. The zswap pool size is 20% of total memory that's too random and once it
gets full the performance may even worse because everytime pageout() an anon
page two disk-io write ops may happend instead of one.

2. The reclaim hook will only be triggered in frontswap_store().
It may be result that the zswap pool size can't be adjusted in time which may
caused 20% memory lose for other users.

This patch introduce a zswap shrinker, it make the balance that the zswap
pool size will be the same as anon pages in use.
It's more flexiable and the size of zswap pool can be dynamically changed
during different memory situation.

This patch was based on Seth's zswap v12. It's very draft and only compile
tested now.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/zbud.h |    2 +-
 mm/zbud.c            |   17 ++++++++--
 mm/zswap.c           |   84 +++++++++++++++++++++++++++++++++++---------------
 3 files changed, 74 insertions(+), 29 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..afd2eb2 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -14,7 +14,7 @@ void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
+int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries, struct page *page);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
 void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
 u64 zbud_get_pool_size(struct zbud_pool *pool);
diff --git a/mm/zbud.c b/mm/zbud.c
index b10a1f1..3045bfb 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -294,8 +294,15 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	/* Couldn't find unbuddied zbpage, create new one */
 	spin_unlock(&pool->lock);
 	page = alloc_page(gfp);
+	if (!page) {
+		/* Couldn't alloc new page, try to direct reclaim */
+		if (zbud_reclaim_page(pool, 16, page))
+			return -ENOMEM;
+	}
+
 	if (!page)
 		return -ENOMEM;
+
 	spin_lock(&pool->lock);
 	pool->pages_nr++;
 	zbpage = init_zbud_page(page);
@@ -412,7 +419,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * no pages to evict or an eviction handler is not registered, -EAGAIN if
  * the retry limit was hit.
  */
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
+int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries, struct page *page)
 {
 	int i, ret, freechunks;
 	struct zbud_page *zbpage;
@@ -461,8 +468,12 @@ next:
 			 * Both buddies are now free, free the zbpage and
 			 * return success.
 			 */
-			free_zbud_page(zbpage);
-			pool->pages_nr--;
+			if (page)
+				page = &zbpage->page;
+			else {
+				free_zbud_page(zbpage);
+				pool->pages_nr--;
+			}
 			spin_unlock(&pool->lock);
 			return 0;
 		} else if (zbpage->first_chunks == 0 ||
diff --git a/mm/zswap.c b/mm/zswap.c
index 22cc034..9703bb5 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -84,11 +84,6 @@ module_param_named(enabled, zswap_enabled, bool, 0);
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
@@ -362,15 +357,6 @@ cleanup:
 	return -ENOMEM;
 }
 
-/*********************************
-* helpers
-**********************************/
-static inline bool zswap_is_full(void)
-{
-	return (totalram_pages * zswap_max_pool_percent / 100 <
-		zswap_pool_pages);
-}
-
 /*
  * Carries out the common pattern of freeing and entry's zsmalloc allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
@@ -430,6 +416,9 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
+			/* Need more agressive here to alloc memory so that pages in
+			 * zswap pool can be written out to disk and finally can shrink
+			 * zswap pool size.*/
 			new_page = alloc_page(GFP_KERNEL);
 			if (!new_page)
 				break; /* Out of memory */
@@ -620,16 +609,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
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
@@ -650,7 +629,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
+	/* Don't use reserve memory so that system won't enter very bad memory
+	 * situation becasue of zswap*/
+	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC,
 		&handle);
 	if (ret == -E2BIG) {
 		zswap_reject_compress_poor++;
@@ -907,11 +888,60 @@ static inline int __init zswap_debugfs_init(void)
 static inline void __exit zswap_debugfs_exit(void) { }
 #endif
 
+/*
+ * This zswap shrinker interface reduces the number of pageframes
+ * used by zswap to approximately the same as the total number of LRU_ANON
+ * pageframes in use which means 1:1
+ * The policy can be changed if there is better scale proved in future.
+ */
+static int shrink_zswap_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
+{
+	static bool in_progress;
+	int nr_evict = 0;
+	int nr_reclaim = 0;
+	int  global_anon_pages_inuse;
+	struct zswap_tree *tree;
+	int tree_type;
+
+	if (!sc->nr_to_scan)
+		goto skip_evict;
+	/* don't allow more than one eviction thread at a time */
+	if (in_progress)
+		goto skip_evict;
+	in_progress = true;
+
+	global_anon_pages_inuse = global_page_state(NR_LRU_BASE + LRU_ACTIVE_ANON) +
+		global_page_state(NR_LRU_BASE + LRU_INACTIVE_ANON);
+
+	if (zswap_pool_pages > global_anon_pages_inuse)
+		nr_reclaim = zswap_pool_pages - global_anon_pages_inuse;
+	else
+		nr_reclaim = 0;
+
+	while (nr_reclaim > 0)
+		for (tree_type = 0; tree_type < MAX_SWAPFILES; tree_type++) {
+			tree = zswap_trees[tree_type];
+			if (tree) {
+				if (zbud_reclaim_page(tree->pool, 8, NULL))
+					zswap_reject_reclaim_fail++;
+				else {
+					nr_evict++;
+					nr_reclaim--;
+				}
+			}
+		}
+	in_progress = false;
+skip_evict:
+	return nr_evict;
+}
+
 /*********************************
 * module init and exit
 **********************************/
 static int __init init_zswap(void)
 {
+	struct shrinker zswap_shrinker;
 	if (!zswap_enabled)
 		return 0;
 
@@ -931,6 +961,10 @@ static int __init init_zswap(void)
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
 		pr_warn("debugfs initialization failed\n");
+
+	zswap_shrinker.shrink = shrink_zswap_memory;
+	zswap_shrinker.seeks = DEFAULT_SEEKS;
+	register_shrinker(&zswap_shrinker);
 	return 0;
 pcpufail:
 	zswap_comp_exit();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
