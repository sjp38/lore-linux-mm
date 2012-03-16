Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 41D7A6B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 17:05:13 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 16 Mar 2012 17:05:12 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 15F9338C805A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 17:05:09 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2GL59fm187872
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 17:05:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2GL58xE016615
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 18:05:08 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zsmalloc: add user-definable alloc/free funcs
Date: Fri, 16 Mar 2012 16:04:48 -0500
Message-Id: <1331931888-14175-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch allows a zsmalloc user to define the page
allocation and free functions to be used when growing
or releasing parts of the memory pool.

The functions are passed in the struct zs_pool_ops parameter
of zs_create_pool() at pool creation time.  If this parameter
is NULL, zsmalloc uses alloc_page and __free_page() by default.

While there is no current user of this functionality, zcache
development plans to make use of it in the near future.

Patch applies to Greg's staging-next branch.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c     |    2 +-
 drivers/staging/zram/zram_drv.c          |    3 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |   39 +++++++++++++++++++++++-------
 drivers/staging/zsmalloc/zsmalloc.h      |    8 +++++-
 drivers/staging/zsmalloc/zsmalloc_int.h  |    2 +
 5 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index b698464..7ef5313 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -984,7 +984,7 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
+	cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK, NULL);
 	if (cli->zspool == NULL)
 		goto out;
 #endif
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 7f13819..278eb4d 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -663,7 +663,8 @@ int zram_init_device(struct zram *zram)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
-	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
+	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM,
+					NULL);
 	if (!zram->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		ret = -ENOMEM;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 09caa4f..c8bfb77 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -267,7 +267,7 @@ static unsigned long obj_idx_to_offset(struct page *page,
 	return off + obj_idx * class_size;
 }
 
-static void free_zspage(struct page *first_page)
+static void free_zspage(struct zs_pool *pool, struct page *first_page)
 {
 	struct page *nextp, *tmp;
 
@@ -282,7 +282,7 @@ static void free_zspage(struct page *first_page)
 	first_page->mapping = NULL;
 	first_page->freelist = NULL;
 	reset_page_mapcount(first_page);
-	__free_page(first_page);
+	(*pool->ops->free_page)(first_page);
 
 	/* zspage with only 1 system page */
 	if (!nextp)
@@ -345,7 +345,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 /*
  * Allocate a zspage for the given size class
  */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+static struct page *alloc_zspage(struct zs_pool *pool, struct size_class *class)
 {
 	int i, error;
 	struct page *first_page = NULL;
@@ -365,7 +365,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	for (i = 0; i < class->zspage_order; i++) {
 		struct page *page, *prev_page;
 
-		page = alloc_page(flags);
+		page = (*pool->ops->alloc_page)(pool->flags);
 		if (!page)
 			goto cleanup;
 
@@ -398,7 +398,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 cleanup:
 	if (unlikely(error) && first_page) {
-		free_zspage(first_page);
+		free_zspage(pool, first_page);
 		first_page = NULL;
 	}
 
@@ -482,7 +482,24 @@ fail:
 	return notifier_to_errno(ret);
 }
 
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
+
+static inline struct page *zs_alloc_page(gfp_t flags)
+{
+	return alloc_page(flags);
+}
+
+static inline void zs_free_page(struct page *page)
+{
+	__free_page(page);
+}
+
+static struct zs_pool_ops default_ops = {
+	.alloc_page = zs_alloc_page,
+	.free_page = zs_free_page
+};
+
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags,
+			struct zs_pool_ops *ops)
 {
 	int i, error, ovhd_size;
 	struct zs_pool *pool;
@@ -492,7 +509,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
 	pool = kzalloc(ovhd_size, GFP_KERNEL);
-	if (!pool)
+	if (!pool || (ops && (!ops->alloc_page || !ops->free_page)))
 		return NULL;
 
 	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
@@ -524,6 +541,10 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	pool->flags = flags;
 	pool->name = name;
+	if (ops)
+		pool->ops = ops;
+	else
+		pool->ops = &default_ops;
 
 	error = 0; /* Success */
 
@@ -592,7 +613,7 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
+		first_page = alloc_zspage(pool, class);
 		if (unlikely(!first_page))
 			return NULL;
 
@@ -658,7 +679,7 @@ void zs_free(struct zs_pool *pool, void *obj)
 	spin_unlock(&class->lock);
 
 	if (fullness == ZS_EMPTY)
-		free_zspage(first_page);
+		free_zspage(pool, first_page);
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 949384e..51fb32e 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -17,7 +17,13 @@
 
 struct zs_pool;
 
-struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
+struct zs_pool_ops {
+	struct page * (*alloc_page)(gfp_t);
+	void (*free_page)(struct page *);
+};
+
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags,
+			struct zs_pool_ops *ops);
 void zs_destroy_pool(struct zs_pool *pool);
 
 void *zs_malloc(struct zs_pool *pool, size_t size);
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 92eefc6..ade09c1 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
+#include "zsmalloc.h"
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -146,6 +147,7 @@ struct link_free {
 };
 
 struct zs_pool {
+	struct zs_pool_ops *ops;
 	struct size_class size_class[ZS_SIZE_CLASSES];
 
 	gfp_t flags;	/* allocation flags used when growing pool */
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
