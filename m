Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 55BE46B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:46:44 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 10:46:43 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6DA383E40039
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:32 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PHkT76105366
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:31 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PHkS1A003349
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:28 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/4] staging: zsmalloc: remove unused pool name
Date: Fri, 25 Jan 2013 11:46:16 -0600
Message-Id: <1359135978-15119-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

zs_create_pool() currently takes a name argument which is
never used in any useful way.

This patch removes it.

Acked-by: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Seth Jennnings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zram/zram_drv.c          |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   11 +++--------
 drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 836dccf..2086682 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -565,7 +565,7 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
+	zram->mem_pool = zs_create_pool(GFP_KERNEL);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index f29f170..711a854 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -798,8 +798,7 @@ fail:
 
 /**
  * zs_create_pool - Creates an allocation pool to work from.
- * @name: name of the pool to be created
- * @flags: allocation flags used when growing pool
+ * @flags: allocation flags used to allocate pool metadata
  *
  * This function must be called before anything when using
  * the zsmalloc allocator.
@@ -807,14 +806,11 @@ fail:
  * On success, a pointer to the newly created pool is returned,
  * otherwise NULL.
  */
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
+struct zs_pool *zs_create_pool(gfp_t flags)
 {
 	int i, ovhd_size;
 	struct zs_pool *pool;
 
-	if (!name)
-		return NULL;
-
 	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
 	pool = kzalloc(ovhd_size, flags);
 	if (!pool)
@@ -836,8 +832,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	}
 
-	pool->name = name;
-
 	return pool;
 }
 EXPORT_SYMBOL_GPL(zs_create_pool);
@@ -866,6 +860,7 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
  * @size: size of block to allocate
+ * @flags: gfp flags used when expanding the pool
  *
  * On success, handle to the allocated object is returned,
  * otherwise 0.
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 907ff03..25a4b4d 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -28,7 +28,7 @@ enum zs_mapmode {
 
 struct zs_pool;
 
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
+struct zs_pool *zs_create_pool(gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
 unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
