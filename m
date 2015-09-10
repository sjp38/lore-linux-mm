Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA0E6B0255
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 07:49:57 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so42145978pac.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:49:57 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id uy2si18977011pac.86.2015.09.10.04.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 04:49:56 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so41239138pad.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:49:56 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/2] mm:zpool: constify struct zpool type
Date: Thu, 10 Sep 2015 20:48:37 +0900
Message-Id: <1441885718-32580-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey SENOZHATSKY <sergey.senozhatsky@gmail.com>

From: Sergey SENOZHATSKY <sergey.senozhatsky@gmail.com>

Constify `struct zpool' ->type.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zpool.h |  8 ++++----
 mm/zpool.c            | 10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 42f8ec9..2c136f4 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -36,12 +36,12 @@ enum zpool_mapmode {
 	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
 };
 
-bool zpool_has_pool(char *type);
+bool zpool_has_pool(const char *type);
 
-struct zpool *zpool_create_pool(char *type, char *name,
+struct zpool *zpool_create_pool(const char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
-char *zpool_get_type(struct zpool *pool);
+const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
@@ -78,7 +78,7 @@ u64 zpool_get_total_size(struct zpool *pool);
  * with zpool.
  */
 struct zpool_driver {
-	char *type;
+	const char *type;
 	struct module *owner;
 	atomic_t refcount;
 	struct list_head list;
diff --git a/mm/zpool.c b/mm/zpool.c
index 8f670d3..2889d0d 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -18,7 +18,7 @@
 #include <linux/zpool.h>
 
 struct zpool {
-	char *type;
+	const char *type;
 
 	struct zpool_driver *driver;
 	void *pool;
@@ -73,7 +73,7 @@ int zpool_unregister_driver(struct zpool_driver *driver)
 }
 EXPORT_SYMBOL(zpool_unregister_driver);
 
-static struct zpool_driver *zpool_get_driver(char *type)
+static struct zpool_driver *zpool_get_driver(const char *type)
 {
 	struct zpool_driver *driver;
 
@@ -115,7 +115,7 @@ static void zpool_put_driver(struct zpool_driver *driver)
  *
  * Returns: true if @type pool is available, false if not
  */
-bool zpool_has_pool(char *type)
+bool zpool_has_pool(const char *type)
 {
 	struct zpool_driver *driver = zpool_get_driver(type);
 
@@ -147,7 +147,7 @@ EXPORT_SYMBOL(zpool_has_pool);
  *
  * Returns: New zpool on success, NULL on failure.
  */
-struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
+struct zpool *zpool_create_pool(const char *type, char *name, gfp_t gfp,
 		const struct zpool_ops *ops)
 {
 	struct zpool_driver *driver;
@@ -228,7 +228,7 @@ void zpool_destroy_pool(struct zpool *zpool)
  *
  * Returns: The type of zpool.
  */
-char *zpool_get_type(struct zpool *zpool)
+const char *zpool_get_type(struct zpool *zpool)
 {
 	return zpool->type;
 }
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
