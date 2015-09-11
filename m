Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA276B0256
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:19:54 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so3415158obb.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:19:54 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id gu1si151932pac.39.2015.09.11.05.19.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 05:19:53 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so73893369pad.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:19:53 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v2 1/2] mm:zpool: constify struct zpool type
Date: Fri, 11 Sep 2015 21:18:36 +0900
Message-Id: <1441973917-6948-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1441973917-6948-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1441973917-6948-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Constify `struct zpool' ->type.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zpool.h | 6 +++---
 mm/zpool.c            | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index c924a28..0ef5581 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -36,10 +36,10 @@ enum zpool_mapmode {
 	ZPOOL_MM_DEFAULT = ZPOOL_MM_RW
 };
 
-struct zpool *zpool_create_pool(char *type, char *name,
+struct zpool *zpool_create_pool(const char *type, char *name,
 			gfp_t gfp, const struct zpool_ops *ops);
 
-char *zpool_get_type(struct zpool *pool);
+const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
@@ -76,7 +76,7 @@ u64 zpool_get_total_size(struct zpool *pool);
  * with zpool.
  */
 struct zpool_driver {
-	char *type;
+	const char *type;
 	struct module *owner;
 	atomic_t refcount;
 	struct list_head list;
diff --git a/mm/zpool.c b/mm/zpool.c
index 68d2dd8..e83fce7 100644
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
 
@@ -114,7 +114,7 @@ static void zpool_put_driver(struct zpool_driver *driver)
  *
  * Returns: New zpool on success, NULL on failure.
  */
-struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
+struct zpool *zpool_create_pool(const char *type, char *name, gfp_t gfp,
 		const struct zpool_ops *ops)
 {
 	struct zpool_driver *driver;
@@ -195,7 +195,7 @@ void zpool_destroy_pool(struct zpool *zpool)
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
