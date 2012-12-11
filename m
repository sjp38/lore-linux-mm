Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id C15596B006E
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:24 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 16:56:23 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F00CF38C8039
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:20 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBBLuK6i292664
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:20 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBBLuJYI026295
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 16:56:20 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/8] staging: zsmalloc: remove unsed pool name
Date: Tue, 11 Dec 2012 15:56:00 -0600
Message-Id: <1355262966-15281-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

zs_create_pool() currently takes a name argument which is
never used in any useful way.

This patch removes it.

Signed-off-by: Seth Jennnings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c     |    2 +-
 drivers/staging/zram/zram_drv.c          |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |    7 +------
 drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
 4 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 674c754..6fa9f9a 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -982,7 +982,7 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->zspool = zs_create_pool("zcache", GFP_KERNEL);
+	cli->zspool = zs_create_pool(GFP_KERNEL);
 	if (cli->zspool == NULL)
 		goto out;
 	idr_init(&cli->tmem_pools);
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 13e9b4b..13d9f6d 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -576,7 +576,7 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
+	zram->mem_pool = zs_create_pool(GFP_KERNEL);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 6ff380e..5e212c0 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -796,14 +796,11 @@ fail:
 	return notifier_to_errno(ret);
 }
 
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
@@ -825,8 +822,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	}
 
-	pool->name = name;
-
 	return pool;
 }
 EXPORT_SYMBOL_GPL(zs_create_pool);
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
