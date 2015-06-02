Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDAA900015
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 12:49:38 -0400 (EDT)
Received: by oifu123 with SMTP id u123so130316000oif.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 09:49:38 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id k7si11185880oes.103.2015.06.02.09.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 09:49:37 -0700 (PDT)
Received: by oihb142 with SMTP id b142so130182660oih.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 09:49:37 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: remove zpool_evict
Date: Tue,  2 Jun 2015 12:49:25 -0400
Message-Id: <1433263765-30772-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Remove zpool_evict helper function.  As zbud is currently the only zpool
implementation that supports eviction, add zpool and zpool_ops references
to struct zbud_pool and directly call zpool_ops->evict(zpool, handle) on
eviction.

Currently zpool provides the zpool_evict helper which locks the zpool list
lock and searches through all pools to find the specific one matching the
caller, and call the corresponding zpool_ops->evict function.  However,
this is unnecessary, as the zbud pool can simply keep a reference to the
zpool that created it, as well as the zpool_ops, and directly call the
zpool_ops->evict function, when it needs to evict a page.  This avoids
a spinlock and list search in zpool for each eviction.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h |  5 ++---
 mm/zbud.c             | 23 +++++++++++++++++++----
 mm/zpool.c            | 29 +----------------------------
 mm/zsmalloc.c         |  3 ++-
 4 files changed, 24 insertions(+), 36 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 56529b3..d30eff3 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -81,7 +81,8 @@ struct zpool_driver {
 	atomic_t refcount;
 	struct list_head list;
 
-	void *(*create)(char *name, gfp_t gfp, struct zpool_ops *ops);
+	void *(*create)(char *name, gfp_t gfp, struct zpool_ops *ops,
+			struct zpool *zpool);
 	void (*destroy)(void *pool);
 
 	int (*malloc)(void *pool, size_t size, gfp_t gfp,
@@ -102,6 +103,4 @@ void zpool_register_driver(struct zpool_driver *driver);
 
 int zpool_unregister_driver(struct zpool_driver *driver);
 
-int zpool_evict(void *pool, unsigned long handle);
-
 #endif
diff --git a/mm/zbud.c b/mm/zbud.c
index 2ee4e45..f3bf6f7 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -97,6 +97,10 @@ struct zbud_pool {
 	struct list_head lru;
 	u64 pages_nr;
 	struct zbud_ops *ops;
+#ifdef CONFIG_ZPOOL
+	struct zpool *zpool;
+	struct zpool_ops *zpool_ops;
+#endif
 };
 
 /*
@@ -123,7 +127,10 @@ struct zbud_header {
 
 static int zbud_zpool_evict(struct zbud_pool *pool, unsigned long handle)
 {
-	return zpool_evict(pool, handle);
+	if (pool->zpool && pool->zpool_ops && pool->zpool_ops->evict)
+		return pool->zpool_ops->evict(pool->zpool, handle);
+	else
+		return -ENOENT;
 }
 
 static struct zbud_ops zbud_zpool_ops = {
@@ -131,9 +138,17 @@ static struct zbud_ops zbud_zpool_ops = {
 };
 
 static void *zbud_zpool_create(char *name, gfp_t gfp,
-			struct zpool_ops *zpool_ops)
+			       struct zpool_ops *zpool_ops,
+			       struct zpool *zpool)
 {
-	return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
+	struct zbud_pool *pool;
+
+	pool = zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
+	if (pool) {
+		pool->zpool = zpool;
+		pool->zpool_ops = zpool_ops;
+	}
+	return pool;
 }
 
 static void zbud_zpool_destroy(void *pool)
@@ -292,7 +307,7 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 	struct zbud_pool *pool;
 	int i;
 
-	pool = kmalloc(sizeof(struct zbud_pool), gfp);
+	pool = kzalloc(sizeof(struct zbud_pool), gfp);
 	if (!pool)
 		return NULL;
 	spin_lock_init(&pool->lock);
diff --git a/mm/zpool.c b/mm/zpool.c
index bacdab6..6a19c97 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -73,33 +73,6 @@ int zpool_unregister_driver(struct zpool_driver *driver)
 }
 EXPORT_SYMBOL(zpool_unregister_driver);
 
-/**
- * zpool_evict() - evict callback from a zpool implementation.
- * @pool:	pool to evict from.
- * @handle:	handle to evict.
- *
- * This can be used by zpool implementations to call the
- * user's evict zpool_ops struct evict callback.
- */
-int zpool_evict(void *pool, unsigned long handle)
-{
-	struct zpool *zpool;
-
-	spin_lock(&pools_lock);
-	list_for_each_entry(zpool, &pools_head, list) {
-		if (zpool->pool == pool) {
-			spin_unlock(&pools_lock);
-			if (!zpool->ops || !zpool->ops->evict)
-				return -EINVAL;
-			return zpool->ops->evict(zpool, handle);
-		}
-	}
-	spin_unlock(&pools_lock);
-
-	return -ENOENT;
-}
-EXPORT_SYMBOL(zpool_evict);
-
 static struct zpool_driver *zpool_get_driver(char *type)
 {
 	struct zpool_driver *driver;
@@ -170,7 +143,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 
 	zpool->type = driver->type;
 	zpool->driver = driver;
-	zpool->pool = driver->create(name, gfp, ops);
+	zpool->pool = driver->create(name, gfp, ops, zpool);
 	zpool->ops = ops;
 
 	if (!zpool->pool) {
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 08bd7a3..dd196c4 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -312,7 +312,8 @@ static void record_obj(unsigned long handle, unsigned long obj)
 
 #ifdef CONFIG_ZPOOL
 
-static void *zs_zpool_create(char *name, gfp_t gfp, struct zpool_ops *zpool_ops)
+static void *zs_zpool_create(char *name, gfp_t gfp, struct zpool_ops *zpool_ops,
+			     struct zpool *zpool)
 {
 	return zs_create_pool(name, gfp);
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
