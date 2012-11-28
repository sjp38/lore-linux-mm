Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BE4326B006E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 21:36:02 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/3] zram: get rid of lockdep warning
Date: Wed, 28 Nov 2012 11:35:46 +0900
Message-Id: <1354070146-18619-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1354070146-18619-1-git-send-email-minchan@kernel.org>
References: <1354070146-18619-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan@kernel.org>

Lockdep complains about recursive deadlock of zram->init_lock.
[1] made it false positive because we can't request IO to zram
before setting disksize. Anyway, we should shut lockdep up to
avoid many reporting from user.

This patch allocates zram's metadata out of lock so we can fix it.
In addition, this patch replace GFP_KERNEL with GFP_NOIO/GFP_ATOMIC
in request handle path for partion I/O.

[1] zram: give up lazy initialization of zram metadata

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c   |  139 ++++++++++++-------------------------
 drivers/staging/zram/zram_drv.h   |   12 +++-
 drivers/staging/zram/zram_sysfs.c |   13 ++--
 3 files changed, 63 insertions(+), 101 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index e04aefc..a19059e 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -71,22 +71,22 @@ static void zram_stat64_inc(struct zram *zram, u64 *v)
 	zram_stat64_add(zram, v, 1);
 }
 
-static int zram_test_flag(struct zram *zram, u32 index,
+static int zram_test_flag(struct zram_meta *meta, u32 index,
 			enum zram_pageflags flag)
 {
-	return zram->table[index].flags & BIT(flag);
+	return meta->table[index].flags & BIT(flag);
 }
 
-static void zram_set_flag(struct zram *zram, u32 index,
+static void zram_set_flag(struct zram_meta *meta, u32 index,
 			enum zram_pageflags flag)
 {
-	zram->table[index].flags |= BIT(flag);
+	meta->table[index].flags |= BIT(flag);
 }
 
-static void zram_clear_flag(struct zram *zram, u32 index,
+static void zram_clear_flag(struct zram_meta *meta, u32 index,
 			enum zram_pageflags flag)
 {
-	zram->table[index].flags &= ~BIT(flag);
+	meta->table[index].flags &= ~BIT(flag);
 }
 
 static int page_zero_filled(void *ptr)
@@ -106,16 +106,17 @@ static int page_zero_filled(void *ptr)
 
 static void zram_free_page(struct zram *zram, size_t index)
 {
-	unsigned long handle = zram->table[index].handle;
-	u16 size = zram->table[index].size;
+	struct zram_meta *meta = zram->meta;
+	unsigned long handle = meta->table[index].handle;
+	u16 size = meta->table[index].size;
 
 	if (unlikely(!handle)) {
 		/*
 		 * No memory is allocated for zero filled pages.
 		 * Simply clear zero page flag.
 		 */
-		if (zram_test_flag(zram, index, ZRAM_ZERO)) {
-			zram_clear_flag(zram, index, ZRAM_ZERO);
+		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
+			zram_clear_flag(meta, index, ZRAM_ZERO);
 			zram_stat_dec(&zram->stats.pages_zero);
 		}
 		return;
@@ -124,17 +125,17 @@ static void zram_free_page(struct zram *zram, size_t index)
 	if (unlikely(size > max_zpage_size))
 		zram_stat_dec(&zram->stats.bad_compress);
 
-	zs_free(zram->mem_pool, handle);
+	zs_free(meta->mem_pool, handle);
 
 	if (size <= PAGE_SIZE / 2)
 		zram_stat_dec(&zram->stats.good_compress);
 
 	zram_stat64_sub(zram, &zram->stats.compr_size,
-			zram->table[index].size);
+			meta->table[index].size);
 	zram_stat_dec(&zram->stats.pages_stored);
 
-	zram->table[index].handle = 0;
-	zram->table[index].size = 0;
+	meta->table[index].handle = 0;
+	meta->table[index].size = 0;
 }
 
 static void handle_zero_page(struct bio_vec *bvec)
@@ -159,20 +160,21 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 	int ret = LZO_E_OK;
 	size_t clen = PAGE_SIZE;
 	unsigned char *cmem;
-	unsigned long handle = zram->table[index].handle;
+	struct zram_meta *meta = zram->meta;
+	unsigned long handle = meta->table[index].handle;
 
-	if (!handle || zram_test_flag(zram, index, ZRAM_ZERO)) {
+	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
 		memset(mem, 0, PAGE_SIZE);
 		return 0;
 	}
 
-	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
-	if (zram->table[index].size == PAGE_SIZE)
+	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+	if (meta->table[index].size == PAGE_SIZE)
 		memcpy(mem, cmem, PAGE_SIZE);
 	else
-		ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
+		ret = lzo1x_decompress_safe(cmem, meta->table[index].size,
 						mem, &clen);
-	zs_unmap_object(zram->mem_pool, handle);
+	zs_unmap_object(meta->mem_pool, handle);
 
 	/* Should NEVER happen. Return bio error if it does. */
 	if (unlikely(ret != LZO_E_OK)) {
@@ -190,11 +192,11 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	int ret;
 	struct page *page;
 	unsigned char *user_mem, *uncmem = NULL;
-
+	struct zram_meta *meta = zram->meta;
 	page = bvec->bv_page;
 
-	if (unlikely(!zram->table[index].handle) ||
-			zram_test_flag(zram, index, ZRAM_ZERO)) {
+	if (unlikely(!meta->table[index].handle) ||
+			zram_test_flag(meta, index, ZRAM_ZERO)) {
 		handle_zero_page(bvec);
 		return 0;
 	}
@@ -202,7 +204,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	user_mem = kmap_atomic(page);
 	if (is_partial_io(bvec))
 		/* Use  a temporary buffer to decompress the page */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		uncmem = kmalloc(PAGE_SIZE, GFP_ATOMIC);
 	else
 		uncmem = user_mem;
 
@@ -241,16 +243,17 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	unsigned long handle;
 	struct page *page;
 	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
+	struct zram_meta *meta = zram->meta;
 
 	page = bvec->bv_page;
-	src = zram->compress_buffer;
+	src = meta->compress_buffer;
 
 	if (is_partial_io(bvec)) {
 		/*
 		 * This is a partial IO. We need to read the full page
 		 * before to write the changes.
 		 */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
 		if (!uncmem) {
 			pr_info("Error allocating temp memory!\n");
 			ret = -ENOMEM;
@@ -267,8 +270,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	 * System overwrites unused sectors. Free memory associated
 	 * with this sector now.
 	 */
-	if (zram->table[index].handle ||
-	    zram_test_flag(zram, index, ZRAM_ZERO))
+	if (meta->table[index].handle ||
+	    zram_test_flag(meta, index, ZRAM_ZERO))
 		zram_free_page(zram, index);
 
 	user_mem = kmap_atomic(page);
@@ -284,13 +287,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		if (is_partial_io(bvec))
 			kfree(uncmem);
 		zram_stat_inc(&zram->stats.pages_zero);
-		zram_set_flag(zram, index, ZRAM_ZERO);
+		zram_set_flag(meta, index, ZRAM_ZERO);
 		ret = 0;
 		goto out;
 	}
 
 	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
-			       zram->compress_workmem);
+			       meta->compress_workmem);
 
 	kunmap_atomic(user_mem);
 	if (is_partial_io(bvec))
@@ -307,21 +310,21 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		clen = PAGE_SIZE;
 	}
 
-	handle = zs_malloc(zram->mem_pool, clen);
+	handle = zs_malloc(meta->mem_pool, clen);
 	if (!handle) {
 		pr_info("Error allocating memory for compressed "
 			"page: %u, size=%zu\n", index, clen);
 		ret = -ENOMEM;
 		goto out;
 	}
-	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
+	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
 
 	memcpy(cmem, src, clen);
 
-	zs_unmap_object(zram->mem_pool, handle);
+	zs_unmap_object(meta->mem_pool, handle);
 
-	zram->table[index].handle = handle;
-	zram->table[index].size = clen;
+	meta->table[index].handle = handle;
+	meta->table[index].size = clen;
 
 	/* Update stats */
 	zram_stat64_add(zram, &zram->stats.compr_size, clen);
@@ -463,33 +466,24 @@ error:
 void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
+	struct zram_meta *meta;
 
 	if (!zram->init_done)
 		goto out;
 
+	meta = zram->meta;
 	zram->init_done = 0;
-
-	/* Free various per-device buffers */
-	kfree(zram->compress_workmem);
-	free_pages((unsigned long)zram->compress_buffer, 1);
-
-	zram->compress_workmem = NULL;
-	zram->compress_buffer = NULL;
-
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = zram->table[index].handle;
+		unsigned long handle = meta->table[index].handle;
 		if (!handle)
 			continue;
 
-		zs_free(zram->mem_pool, handle);
+		zs_free(meta->mem_pool, handle);
 	}
 
-	vfree(zram->table);
-	zram->table = NULL;
-
-	zs_destroy_pool(zram->mem_pool);
-	zram->mem_pool = NULL;
+	zram_meta_free(zram->meta);
+	zram->meta = NULL;
 
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
@@ -506,11 +500,8 @@ void zram_reset_device(struct zram *zram)
 }
 
 /* zram->init_lock should be held */
-int zram_init_device(struct zram *zram)
+void zram_init_device(struct zram *zram, struct zram_meta *meta)
 {
-	int ret;
-	size_t num_pages;
-
 	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
 		pr_info(
 		"There is little point creating a zram of greater than "
@@ -525,51 +516,13 @@ int zram_init_device(struct zram *zram)
 		);
 	}
 
-	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
-	if (!zram->compress_workmem) {
-		pr_err("Error allocating compressor working memory!\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
-	zram->compress_buffer =
-		(void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, 1);
-	if (!zram->compress_buffer) {
-		pr_err("Error allocating compressor buffer space\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
-	num_pages = zram->disksize >> PAGE_SHIFT;
-	zram->table = vzalloc(num_pages * sizeof(*zram->table));
-	if (!zram->table) {
-		pr_err("Error allocating zram address table\n");
-		ret = -ENOMEM;
-		goto fail_no_table;
-	}
-
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
-	if (!zram->mem_pool) {
-		pr_err("Error creating memory pool\n");
-		ret = -ENOMEM;
-		goto fail;
-	}
-
+	zram->meta = meta;
 	zram->init_done = 1;
 
 	pr_debug("Initialization done!\n");
-	return 0;
-
-fail_no_table:
-	/* To prevent accessing table entries during cleanup */
-	zram->disksize = 0;
-fail:
-	__zram_reset_device(zram);
-	pr_err("Initialization failed: err=%d\n", ret);
-	return ret;
 }
 
 static void zram_slot_free_notify(struct block_device *bdev,
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 5b671d1..2d1a3f1 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -83,11 +83,15 @@ struct zram_stats {
 	u32 bad_compress;	/* % of pages with compression ratio>=75% */
 };
 
-struct zram {
-	struct zs_pool *mem_pool;
+struct zram_meta {
 	void *compress_workmem;
 	void *compress_buffer;
 	struct table *table;
+	struct zs_pool *mem_pool;
+};
+
+struct zram {
+	struct zram_meta *meta;
 	spinlock_t stat64_lock;	/* protect 64-bit stats */
 	struct rw_semaphore lock; /* protect compression buffers and table
 				   * against concurrent read and writes */
@@ -111,7 +115,9 @@ unsigned int zram_get_num_devices(void);
 extern struct attribute_group zram_disk_attr_group;
 #endif
 
-extern int zram_init_device(struct zram *zram);
 extern void zram_reset_device(struct zram *zram);
+extern struct zram_meta *zram_meta_alloc(u64 disksize);
+extern void zram_meta_free(struct zram_meta *meta);
+extern void zram_init_device(struct zram *zram, struct zram_meta *meta);
 
 #endif
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index 369db12..f41a0e6 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -56,24 +56,26 @@ static ssize_t disksize_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
 	u64 disksize;
+	struct zram_meta *meta;
 	struct zram *zram = dev_to_zram(dev);
 
 	disksize = memparse(buf, NULL);
 	if (!disksize)
 		return -EINVAL;
-
+	disksize = PAGE_ALIGN(disksize);
+	meta = zram_meta_alloc(disksize);
 	down_write(&zram->init_lock);
 	if (zram->init_done) {
 		up_write(&zram->init_lock);
+		zram_meta_free(meta);
 		pr_info("Cannot change disksize for initialized device\n");
 		return -EBUSY;
 	}
 
-	zram->disksize = PAGE_ALIGN(disksize);
+	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	zram_init_device(zram);
+	zram_init_device(zram, meta);
 	up_write(&zram->init_lock);
-
 	return len;
 }
 
@@ -182,9 +184,10 @@ static ssize_t mem_used_total_show(struct device *dev,
 {
 	u64 val = 0;
 	struct zram *zram = dev_to_zram(dev);
+	struct zram_meta *meta = zram->meta;
 
 	if (zram->init_done)
-		val = zs_get_total_size_bytes(zram->mem_pool);
+		val = zs_get_total_size_bytes(meta->mem_pool);
 
 	return sprintf(buf, "%llu\n", val);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
