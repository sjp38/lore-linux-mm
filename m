Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6624D6B0268
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 17:51:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p14so7190935pgq.2
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 14:51:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor3003014pgp.102.2018.01.08.14.51.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 14:51:17 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] zswap: only save zswap header if zpool is shrinkable
Date: Mon,  8 Jan 2018 14:51:01 -0800
Message-Id: <20180108225101.15790-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
as zpool driver because zsmalloc doesn't support eviction.

Add zpool_shrinkable() to detect if zpool is shrinkable, and use
it in zswap to avoid waste memory for zswap header.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 include/linux/zpool.h |  2 ++
 mm/zpool.c            | 17 ++++++++++++++++-
 mm/zsmalloc.c         |  7 -------
 mm/zswap.c            | 20 ++++++++++----------
 4 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 004ba807df96..3f0ac2ab74aa 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -108,4 +108,6 @@ void zpool_register_driver(struct zpool_driver *driver);
 
 int zpool_unregister_driver(struct zpool_driver *driver);
 
+bool zpool_shrinkable(struct zpool *pool);
+
 #endif
diff --git a/mm/zpool.c b/mm/zpool.c
index fd3ff719c32c..839d4234c540 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -296,7 +296,8 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
 int zpool_shrink(struct zpool *zpool, unsigned int pages,
 			unsigned int *reclaimed)
 {
-	return zpool->driver->shrink(zpool->pool, pages, reclaimed);
+	return zpool_shrinkable(zpool) ?
+	       zpool->driver->shrink(zpool->pool, pages, reclaimed) : -EINVAL;
 }
 
 /**
@@ -355,6 +356,20 @@ u64 zpool_get_total_size(struct zpool *zpool)
 	return zpool->driver->total_size(zpool->pool);
 }
 
+/**
+ * zpool_shrinkable() - Test if zpool is shrinkable
+ * @pool	The zpool to test
+ *
+ * Zpool is only shrinkable when it's created with struct
+ * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
+ *
+ * Returns: true if shrinkable; false otherwise.
+ */
+bool zpool_shrinkable(struct zpool *zpool)
+{
+	return zpool->ops && zpool->ops->evict && zpool->driver->shrink;
+}
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Dan Streetman <ddstreet@ieee.org>");
 MODULE_DESCRIPTION("Common API for compressed memory storage");
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 683c0651098c..9cc741bcdb32 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -407,12 +407,6 @@ static void zs_zpool_free(void *pool, unsigned long handle)
 	zs_free(pool, handle);
 }
 
-static int zs_zpool_shrink(void *pool, unsigned int pages,
-			unsigned int *reclaimed)
-{
-	return -EINVAL;
-}
-
 static void *zs_zpool_map(void *pool, unsigned long handle,
 			enum zpool_mapmode mm)
 {
@@ -450,7 +444,6 @@ static struct zpool_driver zs_zpool_driver = {
 	.destroy =	zs_zpool_destroy,
 	.malloc =	zs_zpool_malloc,
 	.free =		zs_zpool_free,
-	.shrink =	zs_zpool_shrink,
 	.map =		zs_zpool_map,
 	.unmap =	zs_zpool_unmap,
 	.total_size =	zs_zpool_total_size,
diff --git a/mm/zswap.c b/mm/zswap.c
index d39581a076c3..15d2ea29a6fa 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -964,11 +964,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	struct zswap_entry *entry, *dupentry;
 	struct crypto_comp *tfm;
 	int ret;
-	unsigned int dlen = PAGE_SIZE, len;
+	unsigned int hlen, dlen = PAGE_SIZE;
 	unsigned long handle;
 	char *buf;
 	u8 *src, *dst;
-	struct zswap_header *zhdr;
+	struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
 
 	if (!zswap_enabled || !tree) {
 		ret = -ENODEV;
@@ -1013,8 +1013,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* store */
-	len = dlen + sizeof(struct zswap_header);
-	ret = zpool_malloc(entry->pool->zpool, len,
+	hlen = zpool_shrinkable(entry->pool->zpool) ? sizeof(zhdr) : 0;
+	ret = zpool_malloc(entry->pool->zpool, hlen + dlen,
 			   __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
 			   &handle);
 	if (ret == -ENOSPC) {
@@ -1025,10 +1025,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		zswap_reject_alloc_fail++;
 		goto put_dstmem;
 	}
-	zhdr = zpool_map_handle(entry->pool->zpool, handle, ZPOOL_MM_RW);
-	zhdr->swpentry = swp_entry(type, offset);
-	buf = (u8 *)(zhdr + 1);
-	memcpy(buf, dst, dlen);
+	buf = zpool_map_handle(entry->pool->zpool, handle, ZPOOL_MM_RW);
+	memcpy(buf, &zhdr, hlen);
+	memcpy(buf + hlen, dst, dlen);
 	zpool_unmap_handle(entry->pool->zpool, handle);
 	put_cpu_var(zswap_dstmem);
 
@@ -1091,8 +1090,9 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* decompress */
 	dlen = PAGE_SIZE;
-	src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
-			ZPOOL_MM_RO) + sizeof(struct zswap_header);
+	src = zpool_map_handle(entry->pool->zpool, entry->handle, ZPOOL_MM_RO);
+	if (zpool_shrinkable(entry->pool->zpool))
+		src += sizeof(struct zswap_header);
 	dst = kmap_atomic(page);
 	tfm = *get_cpu_ptr(entry->pool->tfm);
 	ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
-- 
2.16.0.rc0.223.g4a4ac83678-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
