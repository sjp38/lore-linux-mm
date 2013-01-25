Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id D93DE6B0008
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:46:37 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 10:46:36 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1501B3E4003D
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:28 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PHkTxq233224
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:29 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PHkQk6003075
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:46:28 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 1/4] staging: zsmalloc: add gfp flags to zs_create_pool
Date: Fri, 25 Jan 2013 11:46:15 -0600
Message-Id: <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

zs_create_pool() currently takes a gfp flags argument
that is used when growing the memory pool.  However
it is not used in allocating the metadata for the pool
itself.  That is currently hardcoded to GFP_KERNEL.

zswap calls zs_create_pool() at swapon time which is done
in atomic context, resulting in a "might sleep" warning.

This patch changes the meaning of the flags argument in
zs_create_pool() to mean the flags for the metadata allocation,
and adds a flags argument to zs_malloc that will be used for
memory pool growth if required.

Acked-by: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zram/zram_drv.c          |    4 ++--
 drivers/staging/zsmalloc/zsmalloc-main.c |    9 +++------
 drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 6762b99..836dccf 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -325,7 +325,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		clen = PAGE_SIZE;
 	}
 
-	handle = zs_malloc(zram->mem_pool, clen);
+	handle = zs_malloc(zram->mem_pool, clen, GFP_NOIO | __GFP_HIGHMEM);
 	if (!handle) {
 		pr_info("Error allocating memory for compressed "
 			"page: %u, size=%zu\n", index, clen);
@@ -565,7 +565,7 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
+	zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index eb00772..f29f170 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -205,8 +205,6 @@ struct link_free {
 
 struct zs_pool {
 	struct size_class size_class[ZS_SIZE_CLASSES];
-
-	gfp_t flags;	/* allocation flags used when growing pool */
 	const char *name;
 };
 
@@ -818,7 +816,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		return NULL;
 
 	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	pool = kzalloc(ovhd_size, flags);
 	if (!pool)
 		return NULL;
 
@@ -838,7 +836,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	}
 
-	pool->flags = flags;
 	pool->name = name;
 
 	return pool;
@@ -874,7 +871,7 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * otherwise 0.
  * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
  */
-unsigned long zs_malloc(struct zs_pool *pool, size_t size)
+unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags)
 {
 	unsigned long obj;
 	struct link_free *link;
@@ -896,7 +893,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
+		first_page = alloc_zspage(class, flags);
 		if (unlikely(!first_page))
 			return 0;
 
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index de2e8bf..907ff03 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -31,7 +31,7 @@ struct zs_pool;
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
-unsigned long zs_malloc(struct zs_pool *pool, size_t size);
+unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
 void zs_free(struct zs_pool *pool, unsigned long obj);
 
 void *zs_map_object(struct zs_pool *pool, unsigned long handle,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
