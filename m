Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA6536B006E
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 08:05:22 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so13239855pab.21
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 05:05:22 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id cc10si41878191pdb.37.2014.12.26.05.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 05:05:21 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so13203398pab.7
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 05:05:20 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 1/2] mm/zpool: add name argument to create zpool
Date: Fri, 26 Dec 2014 21:04:55 +0800
Message-Id: <1419599095-4382-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sjennings@variantweb.net, ddstreet@ieee.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Currently the underlay of zpool: zsmalloc/zbud, do not know
who creates them. There is not a method to let zsmalloc/zbud
find which caller they belogs to.

Now we want to add statistics collection in zsmalloc. We need
to name the debugfs dir for each pool created. The way suggested
by Minchan Kim is to use a name passed by caller(such as zram)
to create the zsmalloc pool.
    /sys/kernel/debug/zsmalloc/zram0

This patch adds a argument *name* to zs_create_pool() and other
related functions.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 drivers/block/zram/zram_drv.c |    8 +++++---
 include/linux/zpool.h         |    5 +++--
 include/linux/zsmalloc.h      |    2 +-
 mm/zbud.c                     |    3 ++-
 mm/zpool.c                    |    5 +++--
 mm/zsmalloc.c                 |    6 +++---
 mm/zswap.c                    |    5 +++--
 7 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index bd8bda3..ebae0d9 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -314,9 +314,10 @@ static void zram_meta_free(struct zram_meta *meta)
 	kfree(meta);
 }
 
-static struct zram_meta *zram_meta_alloc(u64 disksize)
+static struct zram_meta *zram_meta_alloc(int device_id, u64 disksize)
 {
 	size_t num_pages;
+	char pool_name[8];
 	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
 	if (!meta)
 		goto out;
@@ -328,7 +329,8 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
 		goto free_meta;
 	}
 
-	meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
+	snprintf(pool_name, sizeof(pool_name), "zram%d", device_id);
+	meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO | __GFP_HIGHMEM);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto free_table;
@@ -765,7 +767,7 @@ static ssize_t disksize_store(struct device *dev,
 		return -EINVAL;
 
 	disksize = PAGE_ALIGN(disksize);
-	meta = zram_meta_alloc(disksize);
+	meta = zram_meta_alloc(zram->disk->first_minor, disksize);
 	if (!meta)
 		return -ENOMEM;
 
diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index f14bd75..56529b3 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -36,7 +36,8 @@ enum zpool_mapmode {
 	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
 };
 
-struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops);
+struct zpool *zpool_create_pool(char *type, char *name,
+			gfp_t gfp, struct zpool_ops *ops);
 
 char *zpool_get_type(struct zpool *pool);
 
@@ -80,7 +81,7 @@ struct zpool_driver {
 	atomic_t refcount;
 	struct list_head list;
 
-	void *(*create)(gfp_t gfp, struct zpool_ops *ops);
+	void *(*create)(char *name, gfp_t gfp, struct zpool_ops *ops);
 	void (*destroy)(void *pool);
 
 	int (*malloc)(void *pool, size_t size, gfp_t gfp,
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 05c2147..3283c6a 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -36,7 +36,7 @@ enum zs_mapmode {
 
 struct zs_pool;
 
-struct zs_pool *zs_create_pool(gfp_t flags);
+struct zs_pool *zs_create_pool(char *name, gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
 unsigned long zs_malloc(struct zs_pool *pool, size_t size);
diff --git a/mm/zbud.c b/mm/zbud.c
index db8de74..6d7f128 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -130,7 +130,8 @@ static struct zbud_ops zbud_zpool_ops = {
 	.evict =	zbud_zpool_evict
 };
 
-static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
+static void *zbud_zpool_create(char *name, gfp_t gfp,
+			struct zpool_ops *zpool_ops)
 {
 	return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
 }
diff --git a/mm/zpool.c b/mm/zpool.c
index 739cdf0..1fa01f6 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -140,7 +140,8 @@ static void zpool_put_driver(struct zpool_driver *driver)
  *
  * Returns: New zpool on success, NULL on failure.
  */
-struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
+struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
+		struct zpool_ops *ops)
 {
 	struct zpool_driver *driver;
 	struct zpool *zpool;
@@ -168,7 +169,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
 
 	zpool->type = driver->type;
 	zpool->driver = driver;
-	zpool->pool = driver->create(gfp, ops);
+	zpool->pool = driver->create(name, gfp, ops);
 	zpool->ops = ops;
 
 	if (!zpool->pool) {
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b724039..2359e61 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -246,9 +246,9 @@ struct mapping_area {
 
 #ifdef CONFIG_ZPOOL
 
-static void *zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
+static void *zs_zpool_create(char *name, gfp_t gfp, struct zpool_ops *zpool_ops)
 {
-	return zs_create_pool(gfp);
+	return zs_create_pool(name, gfp);
 }
 
 static void zs_zpool_destroy(void *pool)
@@ -1148,7 +1148,7 @@ EXPORT_SYMBOL_GPL(zs_free);
  * On success, a pointer to the newly created pool is returned,
  * otherwise NULL.
  */
-struct zs_pool *zs_create_pool(gfp_t flags)
+struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 {
 	int i;
 	struct zs_pool *pool;
diff --git a/mm/zswap.c b/mm/zswap.c
index 373326b..a358823 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -906,11 +906,12 @@ static int __init init_zswap(void)
 
 	pr_info("loading zswap\n");
 
-	zswap_pool = zpool_create_pool(zswap_zpool_type, gfp, &zswap_zpool_ops);
+	zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
+					&zswap_zpool_ops);
 	if (!zswap_pool && strcmp(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT)) {
 		pr_info("%s zpool not available\n", zswap_zpool_type);
 		zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
-		zswap_pool = zpool_create_pool(zswap_zpool_type, gfp,
+		zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
 					&zswap_zpool_ops);
 	}
 	if (!zswap_pool) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
