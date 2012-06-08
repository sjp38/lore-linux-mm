Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DF2C76B0072
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 02:39:38 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zram: remove special handle of uncompressed page
Date: Fri,  8 Jun 2012 15:39:27 +0900
Message-Id: <1339137567-29656-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1339137567-29656-1-git-send-email-minchan@kernel.org>
References: <1339137567-29656-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

xvmalloc can't handle PAGE_SIZE page so that zram have to
handle it specially but zsmalloc can do it so let's remove
unnecessary special handling code.

Quote from Nitin
"I think page vs handle distinction was added since xvmalloc could not
handle full page allocation. Now that zsmalloc allows full page
allocation, we can just use it for both cases. This would also allow
removing the ZRAM_UNCOMPRESSED flag. The only downside will be slightly
slower code path for full page allocation but this event is anyways
supposed to be rare, so should be fine."

1. This patch reduces code very much.

 drivers/staging/zram/zram_drv.c   |  104 +++++--------------------------------
 drivers/staging/zram/zram_drv.h   |   17 +-----
 drivers/staging/zram/zram_sysfs.c |    6 +--
 3 files changed, 15 insertions(+), 112 deletions(-)

2. change pages_expand with bad_compress so it can count
   bad compression(above 75%) ratio.

3. remove zobj_header which is for back-reference for defragmentation
   because firstly, it's not used at the moment and zsmalloc can't handle
   bigger size than PAGE_SIZE so zram can't do it any more without redesign.

Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c   |  104 +++++--------------------------------
 drivers/staging/zram/zram_drv.h   |   17 +-----
 drivers/staging/zram/zram_sysfs.c |    6 +--
 3 files changed, 15 insertions(+), 112 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 0cdc303..2036a90 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -136,6 +136,7 @@ static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
 static void zram_free_page(struct zram *zram, size_t index)
 {
 	unsigned long handle = zram->table[index].handle;
+	u16 size = zram->table[index].size;
 
 	if (unlikely(!handle)) {
 		/*
@@ -149,19 +150,14 @@ static void zram_free_page(struct zram *zram, size_t index)
 		return;
 	}
 
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		__free_page((struct page *)handle);
-		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
-		zram_stat_dec(&zram->stats.pages_expand);
-		goto out;
-	}
+	if (unlikely(size > max_zpage_size))
+		zram_stat_dec(&zram->stats.bad_compress);
 
 	zs_free(zram->mem_pool, handle);
 
-	if (zram->table[index].size <= PAGE_SIZE / 2)
+	if (size <= PAGE_SIZE / 2)
 		zram_stat_dec(&zram->stats.good_compress);
 
-out:
 	zram_stat64_sub(zram, &zram->stats.compr_size,
 			zram->table[index].size);
 	zram_stat_dec(&zram->stats.pages_stored);
@@ -182,22 +178,6 @@ static void handle_zero_page(struct bio_vec *bvec)
 	flush_dcache_page(page);
 }
 
-static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
-				     u32 index, int offset)
-{
-	struct page *page = bvec->bv_page;
-	unsigned char *user_mem, *cmem;
-
-	user_mem = kmap_atomic(page);
-	cmem = kmap_atomic((struct page *)zram->table[index].handle);
-
-	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
-	kunmap_atomic(cmem);
-	kunmap_atomic(user_mem);
-
-	flush_dcache_page(page);
-}
-
 static inline int is_partial_io(struct bio_vec *bvec)
 {
 	return bvec->bv_len != PAGE_SIZE;
@@ -209,7 +189,6 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	int ret;
 	size_t clen;
 	struct page *page;
-	struct zobj_header *zheader;
 	unsigned char *user_mem, *cmem, *uncmem = NULL;
 
 	page = bvec->bv_page;
@@ -227,12 +206,6 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		return 0;
 	}
 
-	/* Page is stored uncompressed since it's incompressible */
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		handle_uncompressed_page(zram, bvec, index, offset);
-		return 0;
-	}
-
 	if (is_partial_io(bvec)) {
 		/* Use  a temporary buffer to decompress the page */
 		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
@@ -249,8 +222,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 
 	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle);
 
-	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
-				    zram->table[index].size,
+	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
 				    uncmem, &clen);
 
 	if (is_partial_io(bvec)) {
@@ -278,7 +250,6 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 {
 	int ret;
 	size_t clen = PAGE_SIZE;
-	struct zobj_header *zheader;
 	unsigned char *cmem;
 	unsigned long handle = zram->table[index].handle;
 
@@ -287,18 +258,8 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	/* Page is stored uncompressed since it's incompressible */
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		char *src = kmap_atomic((struct page *)handle);
-		memcpy(mem, src, PAGE_SIZE);
-		kunmap_atomic(src);
-		return 0;
-	}
-
 	cmem = zs_map_object(zram->mem_pool, handle);
-
-	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
-				    zram->table[index].size,
+	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
 				    mem, &clen);
 	zs_unmap_object(zram->mem_pool, handle);
 
@@ -316,11 +277,9 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			   int offset)
 {
 	int ret;
-	u32 store_offset;
 	size_t clen;
 	unsigned long handle;
-	struct zobj_header *zheader;
-	struct page *page, *page_store;
+	struct page *page;
 	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
 
 	page = bvec->bv_page;
@@ -382,31 +341,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		goto out;
 	}
 
-	/*
-	 * Page is incompressible. Store it as-is (uncompressed)
-	 * since we do not want to return too many disk write
-	 * errors which has side effect of hanging the system.
-	 */
-	if (unlikely(clen > max_zpage_size)) {
-		clen = PAGE_SIZE;
-		page_store = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
-		if (unlikely(!page_store)) {
-			pr_info("Error allocating memory for "
-				"incompressible page: %u\n", index);
-			ret = -ENOMEM;
-			goto out;
-		}
+	if (unlikely(clen > max_zpage_size))
+		zram_stat_inc(&zram->stats.bad_compress);
 
-		store_offset = 0;
-		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
-		zram_stat_inc(&zram->stats.pages_expand);
-		handle = (unsigned long)page_store;
-		src = kmap_atomic(page);
-		cmem = kmap_atomic(page_store);
-		goto memstore;
-	}
-
-	handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
+	handle = zs_malloc(zram->mem_pool, clen);
 	if (!handle) {
 		pr_info("Error allocating memory for compressed "
 			"page: %u, size=%zu\n", index, clen);
@@ -415,24 +353,9 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	}
 	cmem = zs_map_object(zram->mem_pool, handle);
 
-memstore:
-#if 0
-	/* Back-reference needed for memory defragmentation */
-	if (!zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)) {
-		zheader = (struct zobj_header *)cmem;
-		zheader->table_idx = index;
-		cmem += sizeof(*zheader);
-	}
-#endif
-
 	memcpy(cmem, src, clen);
 
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		kunmap_atomic(cmem);
-		kunmap_atomic(src);
-	} else {
-		zs_unmap_object(zram->mem_pool, handle);
-	}
+	zs_unmap_object(zram->mem_pool, handle);
 
 	zram->table[index].handle = handle;
 	zram->table[index].size = clen;
@@ -597,10 +520,7 @@ void __zram_reset_device(struct zram *zram)
 		if (!handle)
 			continue;
 
-		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			__free_page((struct page *)handle);
-		else
-			zs_free(zram->mem_pool, handle);
+		zs_free(zram->mem_pool, handle);
 	}
 
 	vfree(zram->table);
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 7a7e256..9711d1e 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -26,18 +26,6 @@
  */
 static const unsigned max_num_devices = 32;
 
-/*
- * Stored at beginning of each compressed object.
- *
- * It stores back-reference to table entry which points to this
- * object. This is required to support memory defragmentation.
- */
-struct zobj_header {
-#if 0
-	u32 table_idx;
-#endif
-};
-
 /*-- Configurable parameters */
 
 /* Default zram disk size: 25% of total RAM */
@@ -68,9 +56,6 @@ static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
 
 /* Flags for zram pages (table[page_no].flags) */
 enum zram_pageflags {
-	/* Page is stored uncompressed */
-	ZRAM_UNCOMPRESSED,
-
 	/* Page consists entirely of zeros */
 	ZRAM_ZERO,
 
@@ -98,7 +83,7 @@ struct zram_stats {
 	u32 pages_zero;		/* no. of zero filled pages */
 	u32 pages_stored;	/* no. of pages currently stored */
 	u32 good_compress;	/* % of pages with compression ratio<=50% */
-	u32 pages_expand;	/* % of incompressible pages */
+	u32 bad_compress;	/* % of pages with compression ratio>=75% */
 };
 
 struct zram {
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index a7f3771..edb0ed4 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -186,10 +186,8 @@ static ssize_t mem_used_total_show(struct device *dev,
 	u64 val = 0;
 	struct zram *zram = dev_to_zram(dev);
 
-	if (zram->init_done) {
-		val = zs_get_total_size_bytes(zram->mem_pool) +
-			((u64)(zram->stats.pages_expand) << PAGE_SHIFT);
-	}
+	if (zram->init_done)
+		val = zs_get_total_size_bytes(zram->mem_pool);
 
 	return sprintf(buf, "%llu\n", val);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
