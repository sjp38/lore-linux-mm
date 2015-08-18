Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 609726B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 16:06:15 -0400 (EDT)
Received: by qgeb6 with SMTP id b6so7807559qge.3
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:06:15 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id b110si33083516qgf.8.2015.08.18.13.06.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 13:06:13 -0700 (PDT)
Received: by qgeb6 with SMTP id b6so7806601qge.3
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:06:13 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 1/2] zpool: define and use max type length
Date: Tue, 18 Aug 2015 16:06:00 -0400
Message-Id: <1439928361-31294-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, kbuild test robot <fengguang.wu@intel.com>, Dan Streetman <ddstreet@ieee.org>

Add ZPOOL_MAX_TYPE_NAME define, and change zpool_driver *type field to
type[ZPOOL_MAX_TYPE_NAME].  Remove redundant type field from struct zpool
and use zpool->driver->type instead.

The define will be used by zswap for its zpool param type name length.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h |  5 +++--
 mm/zpool.c            | 11 ++++-------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 42f8ec9..cf70312 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -41,7 +41,7 @@ bool zpool_has_pool(char *type);
 struct zpool *zpool_create_pool(char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
-char *zpool_get_type(struct zpool *pool);
+const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
@@ -60,6 +60,7 @@ void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
 
 u64 zpool_get_total_size(struct zpool *pool);
 
+#define ZPOOL_MAX_TYPE_NAME 64
 
 /**
  * struct zpool_driver - driver implementation for zpool
@@ -78,7 +79,7 @@ u64 zpool_get_total_size(struct zpool *pool);
  * with zpool.
  */
 struct zpool_driver {
-	char *type;
+	char type[ZPOOL_MAX_TYPE_NAME];
 	struct module *owner;
 	atomic_t refcount;
 	struct list_head list;
diff --git a/mm/zpool.c b/mm/zpool.c
index 8f670d3..8a0ef86 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -18,8 +18,6 @@
 #include <linux/zpool.h>
 
 struct zpool {
-	char *type;
-
 	struct zpool_driver *driver;
 	void *pool;
 	const struct zpool_ops *ops;
@@ -79,7 +77,7 @@ static struct zpool_driver *zpool_get_driver(char *type)
 
 	spin_lock(&drivers_lock);
 	list_for_each_entry(driver, &drivers_head, list) {
-		if (!strcmp(driver->type, type)) {
+		if (!strncmp(driver->type, type, ZPOOL_MAX_TYPE_NAME)) {
 			bool got = try_module_get(driver->owner);
 
 			if (got)
@@ -174,7 +172,6 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 		return NULL;
 	}
 
-	zpool->type = driver->type;
 	zpool->driver = driver;
 	zpool->pool = driver->create(name, gfp, ops, zpool);
 	zpool->ops = ops;
@@ -208,7 +205,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
  */
 void zpool_destroy_pool(struct zpool *zpool)
 {
-	pr_debug("destroying pool type %s\n", zpool->type);
+	pr_debug("destroying pool type %s\n", zpool->driver->type);
 
 	spin_lock(&pools_lock);
 	list_del(&zpool->list);
@@ -228,9 +225,9 @@ void zpool_destroy_pool(struct zpool *zpool)
  *
  * Returns: The type of zpool.
  */
-char *zpool_get_type(struct zpool *zpool)
+const char *zpool_get_type(struct zpool *zpool)
 {
-	return zpool->type;
+	return zpool->driver->type;
 }
 
 /**
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
