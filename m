Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 7DAF56B0036
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 04:42:01 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so3802669pdj.2
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 01:42:00 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 3/4] mm: zswap: add supporting for zsmalloc
Date: Sun, 18 Aug 2013 16:40:48 +0800
Message-Id: <1376815249-6611-4-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

Make zswap can use zsmalloc as its allocater.
But note that zsmalloc don't reclaim any zswap pool pages mandatory, if zswap
pool gets full, frontswap_store will be refused unless frontswap_get happened
and freed some space.

The reason of don't implement reclaiming zsmalloc pages from zswap pool is there
is no requiremnet currently.
If we want to do mandatory reclaim, we have to write those pages to real backend
swap devices. But most of current users of zsmalloc are from embeded world,
there is even no real backend swap device.
This action is also the same as privous zram!

For several area, zsmalloc has unpredictable performance characteristics when
reclaiming a single page, then CONFIG_ZBUD are suggested.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/zsmalloc.h |    1 +
 mm/Kconfig               |    4 +++
 mm/zsmalloc.c            |    9 ++++--
 mm/zswap.c               |   73 +++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index fbe6bec..72fc126 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -39,5 +39,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool);
+u64 zs_get_pool_size(struct zs_pool *pool);
 
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 48d1786..d80a575 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -519,6 +519,10 @@ choice
 	  in order to reduce fragmentation and has high compression density.
 	  However, this results in a unpredictable performance characteristics
 	  when reclaiming a single page.
+
+	  Note: By using zsmalloc, no supporting for mandatory reclaiming from
+	  compressed memory pool. If the pool gets full, frontswap_store will
+	  be refused unless frontswap_get happened and freed some space.
 endchoice
 
 config MEM_SOFT_DIRTY
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 4bb275b..9df8d25 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -78,8 +78,7 @@
 #include <linux/hardirq.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
-
-#include "zsmalloc.h"
+#include <linux/zsmalloc.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -1056,6 +1055,12 @@ u64 zs_get_total_size_bytes(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
 
+u64 zs_get_pool_size(struct zs_pool *pool)
+{
+	return zs_get_total_size_bytes(pool) >> PAGE_SHIFT;
+}
+EXPORT_SYMBOL_GPL(zs_get_pool_size);
+
 module_init(zs_init);
 module_exit(zs_exit);
 
diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..8e8dc99 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -34,8 +34,11 @@
 #include <linux/swap.h>
 #include <linux/crypto.h>
 #include <linux/mempool.h>
+#ifdef CONFIG_ZBUD
 #include <linux/zbud.h>
-
+#else
+#include <linux/zsmalloc.h>
+#endif
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
 #include <linux/swapops.h>
@@ -189,7 +192,11 @@ struct zswap_header {
 struct zswap_tree {
 	struct rb_root rbroot;
 	spinlock_t lock;
+#ifdef CONFIG_ZBUD
 	struct zbud_pool *pool;
+#else
+	struct zs_pool *pool;
+#endif
 };
 
 static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
@@ -374,12 +381,21 @@ static bool zswap_is_full(void)
  */
 static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 {
+#ifdef CONFIG_ZBUD
 	zbud_free(tree->pool, entry->handle);
+#else
+	zs_free(tree->pool, entry->handle);
+#endif
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
+#ifdef CONFIG_ZBUD
 	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+#else
+	zswap_pool_pages = zs_get_pool_size(tree->pool);
+#endif
 }
 
+#ifdef CONFIG_ZBUD
 /*********************************
 * writeback code
 **********************************/
@@ -595,6 +611,7 @@ fail:
 	spin_unlock(&tree->lock);
 	return ret;
 }
+#endif
 
 /*********************************
 * frontswap hooks
@@ -620,11 +637,22 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
+#ifdef CONFIG_ZBUD
 		if (zbud_reclaim_page(tree->pool, 8)) {
 			zswap_reject_reclaim_fail++;
 			ret = -ENOMEM;
 			goto reject;
 		}
+#else
+		/*
+		 * zsmalloc has unpredictable performance
+		 * characteristics when reclaiming, so don't support
+		 * mandatory reclaiming from zsmalloc
+		 */
+		zswap_reject_reclaim_fail++;
+		ret = -ENOMEM;
+		goto reject;
+#endif
 	}
 
 	/* allocate entry */
@@ -647,8 +675,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
+#ifdef CONFIG_ZBUD
 	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+			&handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
@@ -658,10 +687,23 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		goto freepage;
 	}
 	zhdr = zbud_map(tree->pool, handle);
+#else
+	handle = zs_malloc(tree->pool, len);
+	if (!handle) {
+		ret = -ENOMEM;
+		zswap_reject_alloc_fail++;
+		goto freepage;
+	}
+	zhdr = zs_map_object(tree->pool, handle, ZS_MM_WO);
+#endif
 	zhdr->swpentry = swp_entry(type, offset);
 	buf = (u8 *)(zhdr + 1);
 	memcpy(buf, dst, dlen);
+#ifdef CONFIG_ZBUD
 	zbud_unmap(tree->pool, handle);
+#else
+	zs_unmap_object(tree->pool, handle);
+#endif
 	put_cpu_var(zswap_dstmem);
 
 	/* populate entry */
@@ -687,8 +729,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
+#ifdef CONFIG_ZBUD
 	zswap_pool_pages = zbud_get_pool_size(tree->pool);
-
+#else
+	zswap_pool_pages = zs_get_pool_size(tree->pool);
+#endif
 	return 0;
 
 freepage:
@@ -724,13 +769,22 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* decompress */
 	dlen = PAGE_SIZE;
+#ifdef CONFIG_ZBUD
 	src = (u8 *)zbud_map(tree->pool, entry->handle) +
-			sizeof(struct zswap_header);
+		sizeof(struct zswap_header);
+#else
+	src = zs_map_object(tree->pool, entry->handle, ZS_MM_RO);
+	src += sizeof(struct zswap_header);
+#endif
 	dst = kmap_atomic(page);
 	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
 		dst, &dlen);
 	kunmap_atomic(dst);
+#ifdef CONFIG_ZBUD
 	zbud_unmap(tree->pool, entry->handle);
+#else
+	zs_unmap_object(tree->pool, entry->handle);
+#endif
 	BUG_ON(ret);
 
 	spin_lock(&tree->lock);
@@ -810,7 +864,11 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	while ((node = rb_first(&tree->rbroot))) {
 		entry = rb_entry(node, struct zswap_entry, rbnode);
 		rb_erase(&entry->rbnode, &tree->rbroot);
+#ifdef CONFIG_ZBUD
 		zbud_free(tree->pool, entry->handle);
+#else
+		zs_free(tree->pool, entry->handle);
+#endif
 		zswap_entry_cache_free(entry);
 		atomic_dec(&zswap_stored_pages);
 	}
@@ -818,9 +876,11 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	spin_unlock(&tree->lock);
 }
 
+#ifdef CONFIG_ZBUD
 static struct zbud_ops zswap_zbud_ops = {
 	.evict = zswap_writeback_entry
 };
+#endif
 
 static void zswap_frontswap_init(unsigned type)
 {
@@ -829,7 +889,12 @@ static void zswap_frontswap_init(unsigned type)
 	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
 	if (!tree)
 		goto err;
+
+#ifdef CONFIG_ZBUD
 	tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
+#else
+	tree->pool = zs_create_pool(GFP_NOWAIT);
+#endif
 	if (!tree->pool)
 		goto freetree;
 	tree->rbroot = RB_ROOT;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
