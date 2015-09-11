Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1726B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 18:22:11 -0400 (EDT)
Received: by qkap81 with SMTP id p81so38106297qka.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:22:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d19si2120048qhc.106.2015.09.11.15.22.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 15:22:10 -0700 (PDT)
Date: Fri, 11 Sep 2015 15:21:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm:zpool: constify struct zpool type
Message-Id: <20150911152155.425f590018c01e689f2361e2@linux-foundation.org>
In-Reply-To: <1441885718-32580-2-git-send-email-sergey.senozhatsky@gmail.com>
References: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
	<1441885718-32580-2-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, 10 Sep 2015 20:48:37 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> From: Sergey SENOZHATSKY <sergey.senozhatsky@gmail.com>
> 
> Constify `struct zpool' ->type.
> 

I think I prefer Dan's patch, which deletes stuff:

From: Dan Streetman <ddstreet@ieee.org>
Subject: zpool: remove redundant zpool->type string, const-ify zpool_get_type

Make the return type of zpool_get_type const; the string belongs to the
zpool driver and should not be modified.  Remove the redundant type field
in the struct zpool; it is private to zpool.c and isn't needed since
->driver->type can be used directly.  Add comments indicating strings must
be null-terminated.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/zpool.h |    2 +-
 mm/zpool.c            |   14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff -puN include/linux/zpool.h~zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type include/linux/zpool.h
--- a/include/linux/zpool.h~zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type
+++ a/include/linux/zpool.h
@@ -41,7 +41,7 @@ bool zpool_has_pool(char *type);
 struct zpool *zpool_create_pool(char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
-char *zpool_get_type(struct zpool *pool);
+const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
diff -puN mm/zpool.c~zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type mm/zpool.c
--- a/mm/zpool.c~zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type
+++ a/mm/zpool.c
@@ -18,8 +18,6 @@
 #include <linux/zpool.h>
 
 struct zpool {
-	char *type;
-
 	struct zpool_driver *driver;
 	void *pool;
 	const struct zpool_ops *ops;
@@ -73,6 +71,7 @@ int zpool_unregister_driver(struct zpool
 }
 EXPORT_SYMBOL(zpool_unregister_driver);
 
+/* this assumes @type is null-terminated. */
 static struct zpool_driver *zpool_get_driver(char *type)
 {
 	struct zpool_driver *driver;
@@ -113,6 +112,8 @@ static void zpool_put_driver(struct zpoo
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
@@ -174,7 +177,6 @@ struct zpool *zpool_create_pool(char *ty
 		return NULL;
 	}
 
-	zpool->type = driver->type;
 	zpool->driver = driver;
 	zpool->pool = driver->create(name, gfp, ops, zpool);
 	zpool->ops = ops;
@@ -208,7 +210,7 @@ struct zpool *zpool_create_pool(char *ty
  */
 void zpool_destroy_pool(struct zpool *zpool)
 {
-	pr_debug("destroying pool type %s\n", zpool->type);
+	pr_debug("destroying pool type %s\n", zpool->driver->type);
 
 	spin_lock(&pools_lock);
 	list_del(&zpool->list);
@@ -228,9 +230,9 @@ void zpool_destroy_pool(struct zpool *zp
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
