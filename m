Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 4BB816B006E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:25:06 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 13:25:05 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 74E7D3E4004C
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 13:24:56 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07KOxKY025692
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:25:00 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07KOwWS004437
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:24:58 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv2 3/9] staging: zsmalloc: add page alloc/free callbacks
Date: Mon,  7 Jan 2013 14:24:34 -0600
Message-Id: <1357590280-31535-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch allows users of zsmalloc to register the
allocation and free routines used by zsmalloc to obtain
more pages for the memory pool.  This allows the user
more control over zsmalloc pool policy and behavior.

If the user does not wish to control this, alloc_page() and
__free_page() are used by default.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c     |    2 +-
 drivers/staging/zram/zram_drv.c          |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   43 ++++++++++++++++++++++--------
 drivers/staging/zsmalloc/zsmalloc.h      |    8 +++++-
 4 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 6fa9f9a..e3e533b 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -982,7 +982,7 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->zspool = zs_create_pool(GFP_KERNEL);
+	cli->zspool = zs_create_pool(GFP_KERNEL, NULL);
 	if (cli->zspool == NULL)
 		goto out;
 	idr_init(&cli->tmem_pools);
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 13d9f6d..0357903 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -576,7 +576,7 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool(GFP_KERNEL);
+	zram->mem_pool = zs_create_pool(GFP_KERNEL, NULL);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 5e212c0..825e124 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -205,7 +205,7 @@ struct link_free {
 
 struct zs_pool {
 	struct size_class size_class[ZS_SIZE_CLASSES];
-	const char *name;
+	struct zs_ops *ops;
 };
 
 /*
@@ -240,6 +240,21 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
+/* default page alloc/free ops */
+struct page *zs_alloc_page(gfp_t flags)
+{
+	return alloc_page(flags);
+}
+
+void zs_free_page(struct page *page)
+{
+	__free_page(page);
+}
+
+struct zs_ops zs_default_ops = {
+	.alloc = zs_alloc_page,
+	.free = zs_free_page
+};
 
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
@@ -476,7 +491,7 @@ static void reset_page(struct page *page)
 	reset_page_mapcount(page);
 }
 
-static void free_zspage(struct page *first_page)
+static void free_zspage(struct zs_ops *ops, struct page *first_page)
 {
 	struct page *nextp, *tmp, *head_extra;
 
@@ -486,7 +501,7 @@ static void free_zspage(struct page *first_page)
 	head_extra = (struct page *)page_private(first_page);
 
 	reset_page(first_page);
-	__free_page(first_page);
+	ops->free(first_page);
 
 	/* zspage with only 1 system page */
 	if (!head_extra)
@@ -495,10 +510,10 @@ static void free_zspage(struct page *first_page)
 	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
 		list_del(&nextp->lru);
 		reset_page(nextp);
-		__free_page(nextp);
+		ops->free(nextp);
 	}
 	reset_page(head_extra);
-	__free_page(head_extra);
+	ops->free(head_extra);
 }
 
 /* Initialize a newly allocated zspage */
@@ -550,7 +565,8 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 /*
  * Allocate a zspage for the given size class
  */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+static struct page *alloc_zspage(struct zs_ops *ops, struct size_class *class,
+				gfp_t flags)
 {
 	int i, error;
 	struct page *first_page = NULL, *uninitialized_var(prev_page);
@@ -570,7 +586,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page;
 
-		page = alloc_page(flags);
+		page = ops->alloc(flags);
 		if (!page)
 			goto cleanup;
 
@@ -602,7 +618,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 cleanup:
 	if (unlikely(error) && first_page) {
-		free_zspage(first_page);
+		free_zspage(ops, first_page);
 		first_page = NULL;
 	}
 
@@ -796,7 +812,7 @@ fail:
 	return notifier_to_errno(ret);
 }
 
-struct zs_pool *zs_create_pool(gfp_t flags)
+struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops)
 {
 	int i, ovhd_size;
 	struct zs_pool *pool;
@@ -822,6 +838,11 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 
 	}
 
+	if (ops)
+		pool->ops = ops;
+	else
+		pool->ops = &zs_default_ops;
+
 	return pool;
 }
 EXPORT_SYMBOL_GPL(zs_create_pool);
@@ -877,7 +898,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags)
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, flags);
+		first_page = alloc_zspage(pool->ops, class, flags);
 		if (unlikely(!first_page))
 			return 0;
 
@@ -943,7 +964,7 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 	spin_unlock(&class->lock);
 
 	if (fullness == ZS_EMPTY)
-		free_zspage(first_page);
+		free_zspage(pool->ops, first_page);
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 25a4b4d..eb6efb6 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -14,6 +14,7 @@
 #define _ZS_MALLOC_H_
 
 #include <linux/types.h>
+#include <linux/mm_types.h>
 
 /*
  * zsmalloc mapping modes
@@ -26,9 +27,14 @@ enum zs_mapmode {
 	ZS_MM_WO /* write-only (no copy-in at map time) */
 };
 
+struct zs_ops {
+	struct page * (*alloc)(gfp_t);
+	void (*free)(struct page *);
+};
+
 struct zs_pool;
 
-struct zs_pool *zs_create_pool(gfp_t flags);
+struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
 void zs_destroy_pool(struct zs_pool *pool);
 
 unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
