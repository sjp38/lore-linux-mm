Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 5B8486B006E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:27:06 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 13:27:04 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C2A04C4000F
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 13:24:49 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07KOuHq281172
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:24:57 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07KOtkW004047
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:24:55 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv2 2/9] staging: zsmalloc: remove unsed pool name
Date: Mon,  7 Jan 2013 14:24:33 -0600
Message-Id: <1357590280-31535-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
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
