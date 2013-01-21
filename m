Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5B06E6B0009
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 00:21:38 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 3/4] zram: get rid of lockdep warning
Date: Mon, 21 Jan 2013 14:21:30 +0900
Message-Id: <1358745691-4556-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1358745691-4556-1-git-send-email-minchan@kernel.org>
References: <1358745691-4556-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, Minchan Kim <minchan@kernel.org>

Lockdep complains about recursive deadlock of zram->init_lock.
[1] made it false positive because we can't request IO to zram
before setting disksize. Anyway, we should shut lockdep up to
avoid many reporting from user.

Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c   |  115 +++++++++++++++++++------------------
 drivers/staging/zram/zram_drv.h   |   12 +++-
 drivers/staging/zram/zram_sysfs.c |   10 +++-
 3 files changed, 79 insertions(+), 58 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index e95e37c..1f6938a 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -462,19 +462,12 @@ error:
 void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
+	struct zram_meta meta;
 
 	if (!zram->init_done)
 		goto out;
 
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
 		unsigned long handle = zram->table[index].handle;
@@ -484,11 +477,11 @@ void __zram_reset_device(struct zram *zram)
 		zs_free(zram->mem_pool, handle);
 	}
 
-	vfree(zram->table);
-	zram->table = NULL;
-
-	zs_destroy_pool(zram->mem_pool);
-	zram->mem_pool = NULL;
+	meta.compress_workmem = zram->compress_workmem;
+	meta.compress_buffer = zram->compress_buffer;
+	meta.table = zram->table;
+	meta.mem_pool = zram->mem_pool;
+	zram_meta_free(&meta);
 
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
@@ -505,12 +498,59 @@ void zram_reset_device(struct zram *zram)
 	up_write(&zram->init_lock);
 }
 
-/* zram->init_lock should be held */
-int zram_init_device(struct zram *zram)
+void zram_meta_free(struct zram_meta *meta)
+{
+	zs_destroy_pool(meta->mem_pool);
+	kfree(meta->compress_workmem);
+	free_pages((unsigned long)meta->compress_buffer, 1);
+	vfree(meta->table);
+	kfree(meta);
+}
+
+int zram_meta_alloc(struct zram_meta *meta, u64 disksize)
 {
-	int ret;
 	size_t num_pages;
 
+	meta->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
+	if (!meta->compress_workmem) {
+		pr_err("Error allocating compressor working memory!\n");
+		goto out;
+	}
+
+	meta->compress_buffer =
+			(void *)__get_free_pages(GFP_KERNEL|__GFP_ZERO, 1);
+	if (!meta->compress_buffer) {
+		pr_err("Error allocating compressor buffer space\n");
+		goto free_workmem;
+	}
+
+	num_pages = disksize >> PAGE_SHIFT;
+	meta->table = vzalloc(num_pages * sizeof(*meta->table));
+	if (!meta->table) {
+		pr_err("Error allocating zram address table\n");
+		goto free_buffer;
+	}
+
+	meta->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
+	if (!meta->mem_pool) {
+		pr_err("Error creating memory pool\n");
+		goto free_table;
+	}
+
+	return 0;
+
+free_table:
+	vfree(meta->table);
+free_buffer:
+	free_pages((unsigned long)meta->compress_buffer, 1);
+free_workmem:
+	kfree(meta->compress_workmem);
+out:
+	return -ENOMEM;
+}
+
+void zram_init_device(struct zram *zram, struct zram_meta *meta)
+{
 	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
 		pr_info(
 		"There is little point creating a zram of greater than "
@@ -525,51 +565,16 @@ int zram_init_device(struct zram *zram)
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
+	zram->mem_pool = meta->mem_pool;
+	zram->compress_workmem = meta->compress_workmem;
+	zram->compress_buffer = meta->compress_buffer;
+	zram->table = meta->table;
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
index 5b671d1..fbe7db0 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -83,11 +83,19 @@ struct zram_stats {
 	u32 bad_compress;	/* % of pages with compression ratio>=75% */
 };
 
+struct zram_meta {
+	void *compress_workmem;
+	void *compress_buffer;
+	struct table *table;
+	struct zs_pool *mem_pool;
+};
+
 struct zram {
 	struct zs_pool *mem_pool;
 	void *compress_workmem;
 	void *compress_buffer;
 	struct table *table;
+
 	spinlock_t stat64_lock;	/* protect 64-bit stats */
 	struct rw_semaphore lock; /* protect compression buffers and table
 				   * against concurrent read and writes */
@@ -111,7 +119,9 @@ unsigned int zram_get_num_devices(void);
 extern struct attribute_group zram_disk_attr_group;
 #endif
 
-extern int zram_init_device(struct zram *zram);
 extern void zram_reset_device(struct zram *zram);
+extern int zram_meta_alloc(struct zram_meta *meta, u64 disksize);
+extern void zram_meta_free(struct zram_meta *meta);
+extern void zram_init_device(struct zram *zram, struct zram_meta *meta);
 
 #endif
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index 369db12..31433ef 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -56,22 +56,28 @@ static ssize_t disksize_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
 	u64 disksize;
+	struct zram_meta meta;
 	struct zram *zram = dev_to_zram(dev);
 
 	disksize = memparse(buf, NULL);
 	if (!disksize)
 		return -EINVAL;
 
+	disksize = PAGE_ALIGN(disksize);
+	if (zram_meta_alloc(&meta, disksize))
+		return -ENOMEM;
+
 	down_write(&zram->init_lock);
 	if (zram->init_done) {
 		up_write(&zram->init_lock);
+		zram_meta_free(&meta);
 		pr_info("Cannot change disksize for initialized device\n");
 		return -EBUSY;
 	}
 
-	zram->disksize = PAGE_ALIGN(disksize);
+	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	zram_init_device(zram);
+	zram_init_device(zram, &meta);
 	up_write(&zram->init_lock);
 
 	return len;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
