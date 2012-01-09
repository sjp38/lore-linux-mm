Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 11B866B0069
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 17:52:33 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Jan 2012 17:52:32 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09MqTM6314266
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 17:52:29 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09MqSjA006020
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 17:52:29 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 4/5] staging: zram: replace xvmalloc with zsmalloc
Date: Mon,  9 Jan 2012 16:51:59 -0600
Message-Id: <1326149520-31720-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

From: Nitin Gupta <ngupta@vflare.org>

Replaces xvmalloc with zsmalloc as the compressed page allocator
for zram

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zram/Kconfig      |    6 +--
 drivers/staging/zram/Makefile     |    1 -
 drivers/staging/zram/zram_drv.c   |   89 ++++++++++++++++---------------------
 drivers/staging/zram/zram_drv.h   |   10 ++--
 drivers/staging/zram/zram_sysfs.c |    2 +-
 5 files changed, 46 insertions(+), 62 deletions(-)

diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
index 3bec4db..ee23a86 100644
--- a/drivers/staging/zram/Kconfig
+++ b/drivers/staging/zram/Kconfig
@@ -1,11 +1,7 @@
-config XVMALLOC
-	bool
-	default n
-
 config ZRAM
 	tristate "Compressed RAM block device support"
 	depends on BLOCK && SYSFS
-	select XVMALLOC
+	select ZSMALLOC
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
diff --git a/drivers/staging/zram/Makefile b/drivers/staging/zram/Makefile
index 2a6d321..7f4a301 100644
--- a/drivers/staging/zram/Makefile
+++ b/drivers/staging/zram/Makefile
@@ -1,4 +1,3 @@
 zram-y	:=	zram_drv.o zram_sysfs.o
 
 obj-$(CONFIG_ZRAM)	+=	zram.o
-obj-$(CONFIG_XVMALLOC)	+=	xvmalloc.o
\ No newline at end of file
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 09de99f..91a2c87 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -135,13 +135,9 @@ static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
 
 static void zram_free_page(struct zram *zram, size_t index)
 {
-	u32 clen;
-	void *obj;
+	void *handle = zram->table[index].handle;
 
-	struct page *page = zram->table[index].page;
-	u32 offset = zram->table[index].offset;
-
-	if (unlikely(!page)) {
+	if (unlikely(!handle)) {
 		/*
 		 * No memory is allocated for zero filled pages.
 		 * Simply clear zero page flag.
@@ -154,27 +150,24 @@ static void zram_free_page(struct zram *zram, size_t index)
 	}
 
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		clen = PAGE_SIZE;
-		__free_page(page);
+		__free_page(handle);
 		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_dec(&zram->stats.pages_expand);
 		goto out;
 	}
 
-	obj = kmap_atomic(page, KM_USER0) + offset;
-	clen = xv_get_object_size(obj) - sizeof(struct zobj_header);
-	kunmap_atomic(obj, KM_USER0);
+	zs_free(zram->mem_pool, handle);
 
-	xv_free(zram->mem_pool, page, offset);
-	if (clen <= PAGE_SIZE / 2)
+	if (zram->table[index].size <= PAGE_SIZE / 2)
 		zram_stat_dec(&zram->stats.good_compress);
 
 out:
-	zram_stat64_sub(zram, &zram->stats.compr_size, clen);
+	zram_stat64_sub(zram, &zram->stats.compr_size,
+			zram->table[index].size);
 	zram_stat_dec(&zram->stats.pages_stored);
 
-	zram->table[index].page = NULL;
-	zram->table[index].offset = 0;
+	zram->table[index].handle = NULL;
+	zram->table[index].size = 0;
 }
 
 static void handle_zero_page(struct bio_vec *bvec)
@@ -196,7 +189,7 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
 	unsigned char *user_mem, *cmem;
 
 	user_mem = kmap_atomic(page, KM_USER0);
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1);
+	cmem = kmap_atomic(zram->table[index].handle, KM_USER1);
 
 	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
 	kunmap_atomic(cmem, KM_USER1);
@@ -227,7 +220,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	}
 
 	/* Requested page is not present in compressed area */
-	if (unlikely(!zram->table[index].page)) {
+	if (unlikely(!zram->table[index].handle)) {
 		pr_debug("Read before write: sector=%lu, size=%u",
 			 (ulong)(bio->bi_sector), bio->bi_size);
 		handle_zero_page(bvec);
@@ -254,11 +247,10 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		uncmem = user_mem;
 	clen = PAGE_SIZE;
 
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
-		zram->table[index].offset;
+	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle);
 
 	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
-				    xv_get_object_size(cmem) - sizeof(*zheader),
+				    zram->table[index].size,
 				    uncmem, &clen);
 
 	if (is_partial_io(bvec)) {
@@ -267,7 +259,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		kfree(uncmem);
 	}
 
-	kunmap_atomic(cmem, KM_USER1);
+	zs_unmap_object(zram->mem_pool, zram->table[index].handle);
 	kunmap_atomic(user_mem, KM_USER0);
 
 	/* Should NEVER happen. Return bio error if it does. */
@@ -290,13 +282,12 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 	unsigned char *cmem;
 
 	if (zram_test_flag(zram, index, ZRAM_ZERO) ||
-	    !zram->table[index].page) {
+	    !zram->table[index].handle) {
 		memset(mem, 0, PAGE_SIZE);
 		return 0;
 	}
 
-	cmem = kmap_atomic(zram->table[index].page, KM_USER0) +
-		zram->table[index].offset;
+	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle);
 
 	/* Page is stored uncompressed since it's incompressible */
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
@@ -306,9 +297,9 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 	}
 
 	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
-				    xv_get_object_size(cmem) - sizeof(*zheader),
+				    zram->table[index].size,
 				    mem, &clen);
-	kunmap_atomic(cmem, KM_USER0);
+	zs_unmap_object(zram->mem_pool, zram->table[index].handle);
 
 	/* Should NEVER happen. Return bio error if it does. */
 	if (unlikely(ret != LZO_E_OK)) {
@@ -326,6 +317,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	int ret;
 	u32 store_offset;
 	size_t clen;
+	void *handle;
 	struct zobj_header *zheader;
 	struct page *page, *page_store;
 	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
@@ -355,7 +347,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	 * System overwrites unused sectors. Free memory associated
 	 * with this sector now.
 	 */
-	if (zram->table[index].page ||
+	if (zram->table[index].handle ||
 	    zram_test_flag(zram, index, ZRAM_ZERO))
 		zram_free_page(zram, index);
 
@@ -407,26 +399,22 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		store_offset = 0;
 		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_inc(&zram->stats.pages_expand);
-		zram->table[index].page = page_store;
+		handle = page_store;
 		src = kmap_atomic(page, KM_USER0);
+		cmem = kmap_atomic(page_store, KM_USER1);
 		goto memstore;
 	}
 
-	if (xv_malloc(zram->mem_pool, clen + sizeof(*zheader),
-		      &zram->table[index].page, &store_offset,
-		      GFP_NOIO | __GFP_HIGHMEM)) {
+	handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
+	if (!handle) {
 		pr_info("Error allocating memory for compressed "
 			"page: %u, size=%zu\n", index, clen);
 		ret = -ENOMEM;
 		goto out;
 	}
+	cmem = zs_map_object(zram->mem_pool, handle);
 
 memstore:
-	zram->table[index].offset = store_offset;
-
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
-		zram->table[index].offset;
-
 #if 0
 	/* Back-reference needed for memory defragmentation */
 	if (!zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)) {
@@ -438,9 +426,15 @@ memstore:
 
 	memcpy(cmem, src, clen);
 
-	kunmap_atomic(cmem, KM_USER1);
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
+	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
+		kunmap_atomic(cmem, KM_USER1);
 		kunmap_atomic(src, KM_USER0);
+	} else {
+		zs_unmap_object(zram->mem_pool, handle);
+	}
+
+	zram->table[index].handle = handle;
+	zram->table[index].size = clen;
 
 	/* Update stats */
 	zram_stat64_add(zram, &zram->stats.compr_size, clen);
@@ -598,25 +592,20 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		struct page *page;
-		u16 offset;
-
-		page = zram->table[index].page;
-		offset = zram->table[index].offset;
-
-		if (!page)
+		void *handle = zram->table[index].handle;
+		if (!handle)
 			continue;
 
 		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			__free_page(page);
+			__free_page(handle);
 		else
-			xv_free(zram->mem_pool, page, offset);
+			zs_free(zram->mem_pool, handle);
 	}
 
 	vfree(zram->table);
 	zram->table = NULL;
 
-	xv_destroy_pool(zram->mem_pool);
+	zs_destroy_pool(zram->mem_pool);
 	zram->mem_pool = NULL;
 
 	/* Reset stats */
@@ -673,7 +662,7 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = xv_create_pool();
+	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index e5cd246..572faa8 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -18,7 +18,7 @@
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 
-#include "xvmalloc.h"
+#include "../zsmalloc/zsmalloc.h"
 
 /*
  * Some arbitrary value. This is just to catch
@@ -51,7 +51,7 @@ static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
 
 /*
  * NOTE: max_zpage_size must be less than or equal to:
- *   XV_MAX_ALLOC_SIZE - sizeof(struct zobj_header)
+ *   ZS_MAX_ALLOC_SIZE - sizeof(struct zobj_header)
  * otherwise, xv_malloc() would always return failure.
  */
 
@@ -81,8 +81,8 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct table {
-	struct page *page;
-	u16 offset;
+	void *handle;
+	u16 size;	/* object size (excluding header) */
 	u8 count;	/* object ref count (not yet used) */
 	u8 flags;
 } __attribute__((aligned(4)));
@@ -102,7 +102,7 @@ struct zram_stats {
 };
 
 struct zram {
-	struct xv_pool *mem_pool;
+	struct zs_pool *mem_pool;
 	void *compress_workmem;
 	void *compress_buffer;
 	struct table *table;
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index 0ea8ed2..ea2f269 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -187,7 +187,7 @@ static ssize_t mem_used_total_show(struct device *dev,
 	struct zram *zram = dev_to_zram(dev);
 
 	if (zram->init_done) {
-		val = xv_get_total_size_bytes(zram->mem_pool) +
+		val = zs_get_total_size_bytes(zram->mem_pool) +
 			((u64)(zram->stats.pages_expand) << PAGE_SHIFT);
 	}
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
