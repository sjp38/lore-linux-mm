Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88A5A6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:14:25 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 134so22141721qkh.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 01:14:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si1480284qke.151.2017.06.28.01.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 01:14:24 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH] mm/zsmalloc: simplify zs_max_alloc_size handling
Date: Wed, 28 Jun 2017 10:14:20 +0200
Message-Id: <20170628081420.26898-1-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 40f9fb8cffc6 ("mm/zsmalloc: support allocating obj with size of
ZS_MAX_ALLOC_SIZE") fixes a size calculation error that prevented
zsmalloc to allocate an object of the maximal size
(ZS_MAX_ALLOC_SIZE). I think however the fix is unneededly
complicated.

This patch replaces the dynamic calculation of zs_size_classes at init
time by a compile time calculation that uses the DIV_ROUND_UP() macro
already used in get_size_class_index().

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/zsmalloc.c | 52 +++++++++++++++-------------------------------------
 1 file changed, 15 insertions(+), 37 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d41edd2..134024b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -116,6 +116,11 @@
 #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
 
+#define FULLNESS_BITS	2
+#define CLASS_BITS	8
+#define ISOLATED_BITS	3
+#define MAGIC_VAL_BITS	8
+
 #define MAX(a, b) ((a) >= (b) ? (a) : (b))
 /* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
 #define ZS_MIN_ALLOC_SIZE \
@@ -137,6 +142,8 @@
  *  (reason above)
  */
 #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
+#define ZS_SIZE_CLASSES	DIV_ROUND_UP(ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE, \
+				     ZS_SIZE_CLASS_DELTA)
 
 enum fullness_group {
 	ZS_EMPTY,
@@ -169,11 +176,6 @@ static struct vfsmount *zsmalloc_mnt;
 #endif
 
 /*
- * number of size_classes
- */
-static int zs_size_classes;
-
-/*
  * We assign a page to ZS_ALMOST_EMPTY fullness group when:
  *	n <= N / f, where
  * n = number of allocated objects
@@ -244,7 +246,7 @@ struct link_free {
 struct zs_pool {
 	const char *name;
 
-	struct size_class **size_class;
+	struct size_class *size_class[ZS_SIZE_CLASSES];
 	struct kmem_cache *handle_cachep;
 	struct kmem_cache *zspage_cachep;
 
@@ -268,11 +270,6 @@ struct zs_pool {
 #endif
 };
 
-#define FULLNESS_BITS	2
-#define CLASS_BITS	8
-#define ISOLATED_BITS	3
-#define MAGIC_VAL_BITS	8
-
 struct zspage {
 	struct {
 		unsigned int fullness:FULLNESS_BITS;
@@ -551,7 +548,7 @@ static int get_size_class_index(int size)
 		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
 				ZS_SIZE_CLASS_DELTA);
 
-	return min(zs_size_classes - 1, idx);
+	return min((int)ZS_SIZE_CLASSES - 1, idx);
 }
 
 static inline void zs_stat_inc(struct size_class *class,
@@ -610,7 +607,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 			"obj_allocated", "obj_used", "pages_used",
 			"pages_per_zspage", "freeable");
 
-	for (i = 0; i < zs_size_classes; i++) {
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
 		class = pool->size_class[i];
 
 		if (class->index != i)
@@ -1294,17 +1291,6 @@ static int zs_cpu_dead(unsigned int cpu)
 	return 0;
 }
 
-static void __init init_zs_size_classes(void)
-{
-	int nr;
-
-	nr = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1;
-	if ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA)
-		nr += 1;
-
-	zs_size_classes = nr;
-}
-
 static bool can_merge(struct size_class *prev, int pages_per_zspage,
 					int objs_per_zspage)
 {
@@ -2145,7 +2131,7 @@ static void async_free_zspage(struct work_struct *work)
 	struct zs_pool *pool = container_of(work, struct zs_pool,
 					free_work);
 
-	for (i = 0; i < zs_size_classes; i++) {
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
 		class = pool->size_class[i];
 		if (class->index != i)
 			continue;
@@ -2263,7 +2249,7 @@ unsigned long zs_compact(struct zs_pool *pool)
 	int i;
 	struct size_class *class;
 
-	for (i = zs_size_classes - 1; i >= 0; i--) {
+	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
 		class = pool->size_class[i];
 		if (!class)
 			continue;
@@ -2309,7 +2295,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
 			shrinker);
 
-	for (i = zs_size_classes - 1; i >= 0; i--) {
+	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
 		class = pool->size_class[i];
 		if (!class)
 			continue;
@@ -2361,12 +2347,6 @@ struct zs_pool *zs_create_pool(const char *name)
 		return NULL;
 
 	init_deferred_free(pool);
-	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
-			GFP_KERNEL);
-	if (!pool->size_class) {
-		kfree(pool);
-		return NULL;
-	}
 
 	pool->name = kstrdup(name, GFP_KERNEL);
 	if (!pool->name)
@@ -2379,7 +2359,7 @@ struct zs_pool *zs_create_pool(const char *name)
 	 * Iterate reversely, because, size of size_class that we want to use
 	 * for merging should be larger or equal to current size.
 	 */
-	for (i = zs_size_classes - 1; i >= 0; i--) {
+	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
 		int size;
 		int pages_per_zspage;
 		int objs_per_zspage;
@@ -2453,7 +2433,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 	zs_unregister_migration(pool);
 	zs_pool_stat_destroy(pool);
 
-	for (i = 0; i < zs_size_classes; i++) {
+	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
 
@@ -2492,8 +2472,6 @@ static int __init zs_init(void)
 	if (ret)
 		goto hp_setup_fail;
 
-	init_zs_size_classes();
-
 #ifdef CONFIG_ZPOOL
 	zpool_register_driver(&zs_zpool_driver);
 #endif
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
