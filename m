Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A10466B010A
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 00:13:06 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so5830780pdb.37
        for <linux-mm@kvack.org>; Sun, 23 Feb 2014 21:13:06 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id gn5si7312026pbc.326.2014.02.23.21.13.04
        for <linux-mm@kvack.org>;
        Sun, 23 Feb 2014 21:13:05 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm/zswap: support multiple swap devices
Date: Mon, 24 Feb 2014 14:13:25 +0900
Message-Id: <1393218805-24924-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cai.liu@samsung.com, weijie.yang.kh@gmail.com, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjennings@variantweb.net>

Cai Liu reporeted that now zbud pool pages counting has a problem
when multiple swap is used because it just counts only one swap
intead of all of swap so zswap cannot control writeback properly.
The result is unnecessary writeback or no writeback when we should
really writeback.

IOW, it made zswap crazy.

Another problem in zswap is following as.
For example, let's assume we use two swap A and B with different
priority and A already has charged 19% long time ago and let's assume
that A swap is full now so VM start to use B so that B has charged 1%
recently. It menas zswap charged (19% + 1%) is full by default.
Then, if VM want to swap out more pages into B, zbud_reclaim_page
would be evict one of pages in B's pool and it would be repeated
continuously. It's totally LRU reverse problem and swap thrashing
in B would happen.

This patch makes zswap consider mutliple swap by creating *a* zbud
pool which will be shared by multiple swap so all of zswap pages
in multiple swap keep order by LRU so it can prevent above two
problems.

Cc: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjennings@variantweb.net>
Reported-by: Cai Liu <cai.liu@samsung.com>
Suggested-by: Weijie Yang <weijie.yang.kh@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zswap.c | 64 ++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 25312eb373a0..7ab2b36e3340 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -89,6 +89,9 @@ static unsigned int zswap_max_pool_percent = 20;
 module_param_named(max_pool_percent,
 			zswap_max_pool_percent, uint, 0644);
 
+/* zbud_pool is shared by all of zswap backend  */
+static struct zbud_pool *shared_mem_pool;
+
 /*********************************
 * compression functions
 **********************************/
@@ -189,7 +192,6 @@ struct zswap_header {
 struct zswap_tree {
 	struct rb_root rbroot;
 	spinlock_t lock;
-	struct zbud_pool *pool;
 };
 
 static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
@@ -285,13 +287,12 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
  * Carries out the common pattern of freeing and entry's zbud allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
  */
-static void zswap_free_entry(struct zswap_tree *tree,
-			struct zswap_entry *entry)
+static void zswap_free_entry(struct zswap_entry *entry)
 {
-	zbud_free(tree->pool, entry->handle);
+	zbud_free(shared_mem_pool, entry->handle);
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_pool_pages = zbud_get_pool_size(shared_mem_pool);
 }
 
 /* caller must hold the tree lock */
@@ -311,7 +312,7 @@ static void zswap_entry_put(struct zswap_tree *tree,
 	BUG_ON(refcount < 0);
 	if (refcount == 0) {
 		zswap_rb_erase(&tree->rbroot, entry);
-		zswap_free_entry(tree, entry);
+		zswap_free_entry(entry);
 	}
 }
 
@@ -545,7 +546,7 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	zbud_unmap(pool, handle);
 	tree = zswap_trees[swp_type(swpentry)];
 	offset = swp_offset(swpentry);
-	BUG_ON(pool != tree->pool);
+	BUG_ON(pool != shared_mem_pool);
 
 	/* find and ref zswap entry */
 	spin_lock(&tree->lock);
@@ -573,13 +574,13 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
 		/* decompress */
 		dlen = PAGE_SIZE;
-		src = (u8 *)zbud_map(tree->pool, entry->handle) +
+		src = (u8 *)zbud_map(shared_mem_pool, entry->handle) +
 			sizeof(struct zswap_header);
 		dst = kmap_atomic(page);
 		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
 				entry->length, dst, &dlen);
 		kunmap_atomic(dst);
-		zbud_unmap(tree->pool, entry->handle);
+		zbud_unmap(shared_mem_pool, entry->handle);
 		BUG_ON(ret);
 		BUG_ON(dlen != PAGE_SIZE);
 
@@ -652,7 +653,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
-		if (zbud_reclaim_page(tree->pool, 8)) {
+		if (zbud_reclaim_page(shared_mem_pool, 8)) {
 			zswap_reject_reclaim_fail++;
 			ret = -ENOMEM;
 			goto reject;
@@ -679,7 +680,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
+	ret = zbud_alloc(shared_mem_pool, len, __GFP_NORETRY | __GFP_NOWARN,
 		&handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
@@ -689,11 +690,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		zswap_reject_alloc_fail++;
 		goto freepage;
 	}
-	zhdr = zbud_map(tree->pool, handle);
+	zhdr = zbud_map(shared_mem_pool, handle);
 	zhdr->swpentry = swp_entry(type, offset);
 	buf = (u8 *)(zhdr + 1);
 	memcpy(buf, dst, dlen);
-	zbud_unmap(tree->pool, handle);
+	zbud_unmap(shared_mem_pool, handle);
 	put_cpu_var(zswap_dstmem);
 
 	/* populate entry */
@@ -716,7 +717,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_pool_pages = zbud_get_pool_size(shared_mem_pool);
 
 	return 0;
 
@@ -752,13 +753,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* decompress */
 	dlen = PAGE_SIZE;
-	src = (u8 *)zbud_map(tree->pool, entry->handle) +
+	src = (u8 *)zbud_map(shared_mem_pool, entry->handle) +
 			sizeof(struct zswap_header);
 	dst = kmap_atomic(page);
 	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
 		dst, &dlen);
 	kunmap_atomic(dst);
-	zbud_unmap(tree->pool, entry->handle);
+	zbud_unmap(shared_mem_pool, entry->handle);
 	BUG_ON(ret);
 
 	spin_lock(&tree->lock);
@@ -804,11 +805,9 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	/* walk the tree and free everything */
 	spin_lock(&tree->lock);
 	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode)
-		zswap_free_entry(tree, entry);
+		zswap_free_entry(entry);
 	tree->rbroot = RB_ROOT;
 	spin_unlock(&tree->lock);
-
-	zbud_destroy_pool(tree->pool);
 	kfree(tree);
 	zswap_trees[type] = NULL;
 }
@@ -822,20 +821,14 @@ static void zswap_frontswap_init(unsigned type)
 	struct zswap_tree *tree;
 
 	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
-	if (!tree)
-		goto err;
-	tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
-	if (!tree->pool)
-		goto freetree;
+	if (!tree) {
+		pr_err("alloc failed, zswap disabled for swap type %d\n", type);
+		return;
+	}
+
 	tree->rbroot = RB_ROOT;
 	spin_lock_init(&tree->lock);
 	zswap_trees[type] = tree;
-	return;
-
-freetree:
-	kfree(tree);
-err:
-	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
 }
 
 static struct frontswap_ops zswap_frontswap_ops = {
@@ -907,9 +900,14 @@ static int __init init_zswap(void)
 		return 0;
 
 	pr_info("loading zswap\n");
+
+	shared_mem_pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
+	if (!shared_mem_pool)
+		goto error;
+
 	if (zswap_entry_cache_create()) {
 		pr_err("entry cache creation failed\n");
-		goto error;
+		goto cachefail;
 	}
 	if (zswap_comp_init()) {
 		pr_err("compressor initialization failed\n");
@@ -919,6 +917,8 @@ static int __init init_zswap(void)
 		pr_err("per-cpu initialization failed\n");
 		goto pcpufail;
 	}
+
+
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
 		pr_warn("debugfs initialization failed\n");
@@ -927,6 +927,8 @@ pcpufail:
 	zswap_comp_exit();
 compfail:
 	zswap_entry_cache_destory();
+cachefail:
+	zbud_destroy_pool(shared_mem_pool);
 error:
 	return -ENOMEM;
 }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
