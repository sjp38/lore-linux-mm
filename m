Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D93436B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 07:50:01 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so42147524pac.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:50:01 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id pm10si18979865pac.92.2015.09.10.04.50.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 04:50:01 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so42147280pac.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:50:01 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/2] mm:zsmalloc: constify struct zs_pool name
Date: Thu, 10 Sep 2015 20:48:38 +0900
Message-Id: <1441885718-32580-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey SENOZHATSKY <sergey.senozhatsky@gmail.com>

From: Sergey SENOZHATSKY <sergey.senozhatsky@gmail.com>

Constify `struct zs_pool' ->name.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zpool.h    |  6 ++++--
 include/linux/zsmalloc.h |  2 +-
 mm/zbud.c                |  2 +-
 mm/zpool.c               |  4 ++--
 mm/zsmalloc.c            | 10 +++++-----
 5 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 2c136f4..8edb451 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -38,7 +38,7 @@ enum zpool_mapmode {
 
 bool zpool_has_pool(const char *type);
 
-struct zpool *zpool_create_pool(const char *type, char *name,
+struct zpool *zpool_create_pool(const char *type, const char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
 const char *zpool_get_type(struct zpool *pool);
@@ -83,7 +83,9 @@ struct zpool_driver {
 	atomic_t refcount;
 	struct list_head list;
 
-	void *(*create)(char *name, gfp_t gfp, const struct zpool_ops *ops,
+	void *(*create)(const char *name,
+			gfp_t gfp,
+			const struct zpool_ops *ops,
 			struct zpool *zpool);
 	void (*destroy)(void *pool);
 
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 6398dfa..34eb160 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -41,7 +41,7 @@ struct zs_pool_stats {
 
 struct zs_pool;
 
-struct zs_pool *zs_create_pool(char *name, gfp_t flags);
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
 void zs_destroy_pool(struct zs_pool *pool);
 
 unsigned long zs_malloc(struct zs_pool *pool, size_t size);
diff --git a/mm/zbud.c b/mm/zbud.c
index fa48bcdf..d8a181f 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -137,7 +137,7 @@ static const struct zbud_ops zbud_zpool_ops = {
 	.evict =	zbud_zpool_evict
 };
 
-static void *zbud_zpool_create(char *name, gfp_t gfp,
+static void *zbud_zpool_create(const char *name, gfp_t gfp,
 			       const struct zpool_ops *zpool_ops,
 			       struct zpool *zpool)
 {
diff --git a/mm/zpool.c b/mm/zpool.c
index 2889d0d..1247c28 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -147,8 +147,8 @@ EXPORT_SYMBOL(zpool_has_pool);
  *
  * Returns: New zpool on success, NULL on failure.
  */
-struct zpool *zpool_create_pool(const char *type, char *name, gfp_t gfp,
-		const struct zpool_ops *ops)
+struct zpool *zpool_create_pool(const char *type, const char *name,
+		gfp_t gfp, const struct zpool_ops *ops)
 {
 	struct zpool_driver *driver;
 	struct zpool *zpool;
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..8b8e0da 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -237,7 +237,7 @@ struct link_free {
 };
 
 struct zs_pool {
-	char *name;
+	const char *name;
 
 	struct size_class **size_class;
 	struct kmem_cache *handle_cachep;
@@ -311,7 +311,7 @@ static void record_obj(unsigned long handle, unsigned long obj)
 
 #ifdef CONFIG_ZPOOL
 
-static void *zs_zpool_create(char *name, gfp_t gfp,
+static void *zs_zpool_create(const char *name, gfp_t gfp,
 			     const struct zpool_ops *zpool_ops,
 			     struct zpool *zpool)
 {
@@ -548,7 +548,7 @@ static const struct file_operations zs_stat_size_ops = {
 	.release        = single_release,
 };
 
-static int zs_pool_stat_create(char *name, struct zs_pool *pool)
+static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
 {
 	struct dentry *entry;
 
@@ -588,7 +588,7 @@ static void __exit zs_stat_exit(void)
 {
 }
 
-static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
+static inline int zs_pool_stat_create(const char *name, struct zs_pool *pool)
 {
 	return 0;
 }
@@ -1866,7 +1866,7 @@ static int zs_register_shrinker(struct zs_pool *pool)
  * On success, a pointer to the newly created pool is returned,
  * otherwise NULL.
  */
-struct zs_pool *zs_create_pool(char *name, gfp_t flags)
+struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 {
 	int i;
 	struct zs_pool *pool;
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
