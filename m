Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8D5280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 05:40:19 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so60940468pdb.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 02:40:19 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id qv6si13490859pab.172.2015.07.03.02.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 02:40:18 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQW009O0O727Q00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Jul 2015 10:40:14 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH 1/2] mm: zpool: Constify the zpool_ops
Date: Fri, 03 Jul 2015 18:40:12 +0900
Message-id: <1435916413-6475-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

The structure zpool_ops is not modified so make the pointer to it as
pointer to const.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zpool.h | 4 ++--
 mm/zbud.c             | 4 ++--
 mm/zpool.c            | 4 ++--
 mm/zsmalloc.c         | 3 ++-
 mm/zswap.c            | 2 +-
 5 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index d30eff3d84d5..c924a28d9805 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -37,7 +37,7 @@ enum zpool_mapmode {
 };
 
 struct zpool *zpool_create_pool(char *type, char *name,
-			gfp_t gfp, struct zpool_ops *ops);
+			gfp_t gfp, const struct zpool_ops *ops);
 
 char *zpool_get_type(struct zpool *pool);
 
@@ -81,7 +81,7 @@ struct zpool_driver {
 	atomic_t refcount;
 	struct list_head list;
 
-	void *(*create)(char *name, gfp_t gfp, struct zpool_ops *ops,
+	void *(*create)(char *name, gfp_t gfp, const struct zpool_ops *ops,
 			struct zpool *zpool);
 	void (*destroy)(void *pool);
 
diff --git a/mm/zbud.c b/mm/zbud.c
index f3bf6f7627d8..6f8158d64864 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -99,7 +99,7 @@ struct zbud_pool {
 	struct zbud_ops *ops;
 #ifdef CONFIG_ZPOOL
 	struct zpool *zpool;
-	struct zpool_ops *zpool_ops;
+	const struct zpool_ops *zpool_ops;
 #endif
 };
 
@@ -138,7 +138,7 @@ static struct zbud_ops zbud_zpool_ops = {
 };
 
 static void *zbud_zpool_create(char *name, gfp_t gfp,
-			       struct zpool_ops *zpool_ops,
+			       const struct zpool_ops *zpool_ops,
 			       struct zpool *zpool)
 {
 	struct zbud_pool *pool;
diff --git a/mm/zpool.c b/mm/zpool.c
index 722a4f60e90b..951db32b833f 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -22,7 +22,7 @@ struct zpool {
 
 	struct zpool_driver *driver;
 	void *pool;
-	struct zpool_ops *ops;
+	const struct zpool_ops *ops;
 
 	struct list_head list;
 };
@@ -115,7 +115,7 @@ static void zpool_put_driver(struct zpool_driver *driver)
  * Returns: New zpool on success, NULL on failure.
  */
 struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
-		struct zpool_ops *ops)
+		const struct zpool_ops *ops)
 {
 	struct zpool_driver *driver;
 	struct zpool *zpool;
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0a7f81aa2249..6e139d381d80 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -309,7 +309,8 @@ static void record_obj(unsigned long handle, unsigned long obj)
 
 #ifdef CONFIG_ZPOOL
 
-static void *zs_zpool_create(char *name, gfp_t gfp, struct zpool_ops *zpool_ops,
+static void *zs_zpool_create(char *name, gfp_t gfp,
+			     const struct zpool_ops *zpool_ops,
 			     struct zpool *zpool)
 {
 	return zs_create_pool(name, gfp);
diff --git a/mm/zswap.c b/mm/zswap.c
index 2d5727baed59..017a3f50725d 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -816,7 +816,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	zswap_trees[type] = NULL;
 }
 
-static struct zpool_ops zswap_zpool_ops = {
+static const struct zpool_ops zswap_zpool_ops = {
 	.evict = zswap_writeback_entry
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
