Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id C69186B003A
	for <linux-mm@kvack.org>; Sat, 24 May 2014 15:07:58 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id i57so5258895yha.26
        for <linux-mm@kvack.org>; Sat, 24 May 2014 12:07:58 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id m60si10919379yhe.191.2014.05.24.12.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 May 2014 12:07:58 -0700 (PDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so5034204ykp.34
        for <linux-mm@kvack.org>; Sat, 24 May 2014 12:07:58 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv3 5/6] mm/zpool: update zswap to use zpool
Date: Sat, 24 May 2014 15:06:08 -0400
Message-Id: <1400958369-3588-6-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Change zswap to use the zpool api instead of directly using zbud.
Add a boot-time param to allow selecting which zpool implementation
to use, with zbud as the default.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Weijie Yang <weijie.yang@samsung.com>
---

Changes since v2 : https://lkml.org/lkml/2014/5/7/894
  -change zswap to select ZPOOL instead of ZBUD
  -only try zbud default if not already tried

Changes since v1 https://lkml.org/lkml/2014/4/19/102
 -since zpool fallback is removed, manually fall back to zbud if
  specified type fails


 mm/Kconfig |  2 +-
 mm/zswap.c | 76 +++++++++++++++++++++++++++++++++++++-------------------------
 2 files changed, 46 insertions(+), 32 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 00f7720..5ae0016 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -531,7 +531,7 @@ config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
 	depends on FRONTSWAP && CRYPTO=y
 	select CRYPTO_LZO
-	select ZBUD
+	select ZPOOL
 	default n
 	help
 	  A lightweight compressed cache for swap pages.  It takes
diff --git a/mm/zswap.c b/mm/zswap.c
index 1cc6770..3b54715 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -34,7 +34,7 @@
 #include <linux/swap.h>
 #include <linux/crypto.h>
 #include <linux/mempool.h>
-#include <linux/zbud.h>
+#include <linux/zpool.h>
 
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
@@ -45,8 +45,8 @@
 /*********************************
 * statistics
 **********************************/
-/* Number of memory pages used by the compressed pool */
-static u64 zswap_pool_pages;
+/* Total bytes used by the compressed storage */
+static u64 zswap_pool_total_size;
 /* The number of compressed pages currently stored in zswap */
 static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
 
@@ -89,8 +89,13 @@ static unsigned int zswap_max_pool_percent = 20;
 module_param_named(max_pool_percent,
 			zswap_max_pool_percent, uint, 0644);
 
-/* zbud_pool is shared by all of zswap backend  */
-static struct zbud_pool *zswap_pool;
+/* Compressed storage to use */
+#define ZSWAP_ZPOOL_DEFAULT "zbud"
+static char *zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
+module_param_named(zpool, zswap_zpool_type, charp, 0444);
+
+/* zpool is shared by all of zswap backend  */
+static struct zpool *zswap_pool;
 
 /*********************************
 * compression functions
@@ -168,7 +173,7 @@ static void zswap_comp_exit(void)
  *            be held while changing the refcount.  Since the lock must
  *            be held, there is no reason to also make refcount atomic.
  * offset - the swap offset for the entry.  Index into the red-black tree.
- * handle - zbud allocation handle that stores the compressed page data
+ * handle - zpool allocation handle that stores the compressed page data
  * length - the length in bytes of the compressed page data.  Needed during
  *          decompression
  */
@@ -284,15 +289,15 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
 }
 
 /*
- * Carries out the common pattern of freeing and entry's zbud allocation,
+ * Carries out the common pattern of freeing and entry's zpool allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
  */
 static void zswap_free_entry(struct zswap_entry *entry)
 {
-	zbud_free(zswap_pool, entry->handle);
+	zpool_free(zswap_pool, entry->handle);
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(zswap_pool);
+	zswap_pool_total_size = zpool_get_total_size(zswap_pool);
 }
 
 /* caller must hold the tree lock */
@@ -409,7 +414,7 @@ cleanup:
 static bool zswap_is_full(void)
 {
 	return totalram_pages * zswap_max_pool_percent / 100 <
-		zswap_pool_pages;
+		DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
 }
 
 /*********************************
@@ -525,7 +530,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
  * the swap cache, the compressed version stored by zswap can be
  * freed.
  */
-static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
+static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 {
 	struct zswap_header *zhdr;
 	swp_entry_t swpentry;
@@ -541,9 +546,9 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	};
 
 	/* extract swpentry from data */
-	zhdr = zbud_map(pool, handle);
+	zhdr = zpool_map_handle(pool, handle, ZPOOL_MM_RO);
 	swpentry = zhdr->swpentry; /* here */
-	zbud_unmap(pool, handle);
+	zpool_unmap_handle(pool, handle);
 	tree = zswap_trees[swp_type(swpentry)];
 	offset = swp_offset(swpentry);
 
@@ -573,13 +578,13 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
 		/* decompress */
 		dlen = PAGE_SIZE;
-		src = (u8 *)zbud_map(zswap_pool, entry->handle) +
-			sizeof(struct zswap_header);
+		src = (u8 *)zpool_map_handle(zswap_pool, entry->handle,
+				ZPOOL_MM_RO) + sizeof(struct zswap_header);
 		dst = kmap_atomic(page);
 		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
 				entry->length, dst, &dlen);
 		kunmap_atomic(dst);
-		zbud_unmap(zswap_pool, entry->handle);
+		zpool_unmap_handle(zswap_pool, entry->handle);
 		BUG_ON(ret);
 		BUG_ON(dlen != PAGE_SIZE);
 
@@ -652,7 +657,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
-		if (zbud_reclaim_page(zswap_pool, 8)) {
+		if (zpool_shrink(zswap_pool, PAGE_SIZE)) {
 			zswap_reject_reclaim_fail++;
 			ret = -ENOMEM;
 			goto reject;
@@ -679,7 +684,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(zswap_pool, len, &handle);
+	ret = zpool_malloc(zswap_pool, len, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
@@ -688,11 +693,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		zswap_reject_alloc_fail++;
 		goto freepage;
 	}
-	zhdr = zbud_map(zswap_pool, handle);
+	zhdr = zpool_map_handle(zswap_pool, handle, ZPOOL_MM_RW);
 	zhdr->swpentry = swp_entry(type, offset);
 	buf = (u8 *)(zhdr + 1);
 	memcpy(buf, dst, dlen);
-	zbud_unmap(zswap_pool, handle);
+	zpool_unmap_handle(zswap_pool, handle);
 	put_cpu_var(zswap_dstmem);
 
 	/* populate entry */
@@ -715,7 +720,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(zswap_pool);
+	zswap_pool_total_size = zpool_get_total_size(zswap_pool);
 
 	return 0;
 
@@ -751,13 +756,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* decompress */
 	dlen = PAGE_SIZE;
-	src = (u8 *)zbud_map(zswap_pool, entry->handle) +
-			sizeof(struct zswap_header);
+	src = (u8 *)zpool_map_handle(zswap_pool, entry->handle,
+			ZPOOL_MM_RO) + sizeof(struct zswap_header);
 	dst = kmap_atomic(page);
 	ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
 		dst, &dlen);
 	kunmap_atomic(dst);
-	zbud_unmap(zswap_pool, entry->handle);
+	zpool_unmap_handle(zswap_pool, entry->handle);
 	BUG_ON(ret);
 
 	spin_lock(&tree->lock);
@@ -810,7 +815,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	zswap_trees[type] = NULL;
 }
 
-static struct zbud_ops zswap_zbud_ops = {
+static struct zpool_ops zswap_zpool_ops = {
 	.evict = zswap_writeback_entry
 };
 
@@ -868,8 +873,8 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_written_back_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
-	debugfs_create_u64("pool_pages", S_IRUGO,
-			zswap_debugfs_root, &zswap_pool_pages);
+	debugfs_create_u64("pool_total_size", S_IRUGO,
+			zswap_debugfs_root, &zswap_pool_total_size);
 	debugfs_create_atomic_t("stored_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_stored_pages);
 
@@ -894,17 +899,26 @@ static void __exit zswap_debugfs_exit(void) { }
 **********************************/
 static int __init init_zswap(void)
 {
+	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
+
 	if (!zswap_enabled)
 		return 0;
 
 	pr_info("loading zswap\n");
 
-	zswap_pool = zbud_create_pool(__GFP_NORETRY | __GFP_NOWARN,
-			&zswap_zbud_ops);
+	zswap_pool = zpool_create_pool(zswap_zpool_type, gfp, &zswap_zpool_ops);
+	if (!zswap_pool && strcmp(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT)) {
+		pr_info("%s zpool not available\n", zswap_zpool_type);
+		zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
+		zswap_pool = zpool_create_pool(zswap_zpool_type, gfp,
+					       &zswap_zpool_ops);
+	}
 	if (!zswap_pool) {
-		pr_err("zbud pool creation failed\n");
+		pr_err("%s zpool not available\n", zswap_zpool_type);
+		pr_err("zpool creation failed\n");
 		goto error;
 	}
+	pr_info("using %s pool\n", zswap_zpool_type);
 
 	if (zswap_entry_cache_create()) {
 		pr_err("entry cache creation failed\n");
@@ -928,7 +942,7 @@ pcpufail:
 compfail:
 	zswap_entry_cache_destory();
 cachefail:
-	zbud_destroy_pool(zswap_pool);
+	zpool_destroy_pool(zswap_pool);
 error:
 	return -ENOMEM;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
