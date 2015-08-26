Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id D98FD6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:26:20 -0400 (EDT)
Received: by qkda128 with SMTP id a128so74864385qkd.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:26:20 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id r19si39782711qha.4.2015.08.26.11.26.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 11:26:20 -0700 (PDT)
Received: by qkfh127 with SMTP id h127so125041928qkf.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:26:20 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: remove redundant zpool->type string, const-ify zpool_get_type
Date: Wed, 26 Aug 2015 14:26:12 -0400
Message-Id: <1440613572-23521-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dan Streetman <ddstreet@ieee.org>

Make the return type of zpool_get_type const; the string belongs to the
zpool driver and should not be modified.  Remove the redundant type
field in the struct zpool; it is private to zpool.c and isn't needed
since ->driver->type can be used directly.  Add comments indicating
strings must be null-terminated.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 include/linux/zpool.h |  2 +-
 mm/zpool.c            | 14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 42f8ec9..1f405be 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -41,7 +41,7 @@ bool zpool_has_pool(char *type);
 struct zpool *zpool_create_pool(char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
-char *zpool_get_type(struct zpool *pool);
+const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
diff --git a/mm/zpool.c b/mm/zpool.c
index 8f670d3..13f524d 100644
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
@@ -73,6 +71,7 @@ int zpool_unregister_driver(struct zpool_driver *driver)
 }
 EXPORT_SYMBOL(zpool_unregister_driver);
 
+/* this assumes @type is null-terminated. */
 static struct zpool_driver *zpool_get_driver(char *type)
 {
 	struct zpool_driver *driver;
@@ -113,6 +112,8 @@ static void zpool_put_driver(struct zpool_driver *driver)
  * not be loaded, and calling @zpool_create_pool() with the pool type will
  * fail.
  *
+ * The @type string must be null-terminated.
+ *
  * Returns: true if @type pool is available, false if not
  */
 bool zpool_has_pool(char *type)
@@ -145,6 +146,8 @@ EXPORT_SYMBOL(zpool_has_pool);
  *
  * Implementations must guarantee this to be thread-safe.
  *
+ * The @type and @name strings must be null-terminated.
+ *
  * Returns: New zpool on success, NULL on failure.
  */
 struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
@@ -174,7 +177,6 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 		return NULL;
 	}
 
-	zpool->type = driver->type;
 	zpool->driver = driver;
 	zpool->pool = driver->create(name, gfp, ops, zpool);
 	zpool->ops = ops;
@@ -208,7 +210,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
  */
 void zpool_destroy_pool(struct zpool *zpool)
 {
-	pr_debug("destroying pool type %s\n", zpool->type);
+	pr_debug("destroying pool type %s\n", zpool->driver->type);
 
 	spin_lock(&pools_lock);
 	list_del(&zpool->list);
@@ -228,9 +230,9 @@ void zpool_destroy_pool(struct zpool *zpool)
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
