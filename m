Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id ECF1A6B0254
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:32:55 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so56836209pac.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:55 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id y3si3627624pdd.227.2015.07.08.04.32.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 04:32:54 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so1009741pdb.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:54 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v7 2/7] zsmalloc: always keep per-class stats
Date: Wed,  8 Jul 2015 20:31:48 +0900
Message-Id: <1436355113-12417-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Always account per-class `zs_size_stat' stats. This data will
help us make better decisions during compaction. We are especially
interested in OBJ_ALLOCATED and OBJ_USED, which can tell us if
class compaction will result in any memory gain.

For instance, we know the number of allocated objects in the class,
the number of objects being used (so we also know how many objects
are not used) and the number of objects per-page. So we can ensure
if we have enough unused objects to form at least one ZS_EMPTY
zspage during compaction.

We calculate this value on per-class basis so we can calculate a
total number of zspages that can be released. Which is exactly what
a shrinker wants to know.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 40 ++++++++--------------------------------
 1 file changed, 8 insertions(+), 32 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2aecdb3..93bb8a7 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -169,14 +169,12 @@ enum zs_stat_type {
 	NR_ZS_STAT_TYPE,
 };
 
-#ifdef CONFIG_ZSMALLOC_STAT
-
-static struct dentry *zs_stat_root;
-
 struct zs_size_stat {
 	unsigned long objs[NR_ZS_STAT_TYPE];
 };
 
+#ifdef CONFIG_ZSMALLOC_STAT
+static struct dentry *zs_stat_root;
 #endif
 
 /*
@@ -201,6 +199,8 @@ static int zs_size_classes;
 static const int fullness_threshold_frac = 4;
 
 struct size_class {
+	spinlock_t lock;
+	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
 	/*
 	 * Size of objects stored in this class. Must be multiple
 	 * of ZS_ALIGN.
@@ -210,16 +210,10 @@ struct size_class {
 
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
 	int pages_per_zspage;
-	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
-	bool huge;
-
-#ifdef CONFIG_ZSMALLOC_STAT
 	struct zs_size_stat stats;
-#endif
-
-	spinlock_t lock;
 
-	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
+	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
+	bool huge;
 };
 
 /*
@@ -441,8 +435,6 @@ static int get_size_class_index(int size)
 	return min(zs_size_classes - 1, idx);
 }
 
-#ifdef CONFIG_ZSMALLOC_STAT
-
 static inline void zs_stat_inc(struct size_class *class,
 				enum zs_stat_type type, unsigned long cnt)
 {
@@ -461,6 +453,8 @@ static inline unsigned long zs_stat_get(struct size_class *class,
 	return class->stats.objs[type];
 }
 
+#ifdef CONFIG_ZSMALLOC_STAT
+
 static int __init zs_stat_init(void)
 {
 	if (!debugfs_initialized())
@@ -576,23 +570,6 @@ static void zs_pool_stat_destroy(struct zs_pool *pool)
 }
 
 #else /* CONFIG_ZSMALLOC_STAT */
-
-static inline void zs_stat_inc(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
-{
-}
-
-static inline void zs_stat_dec(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
-{
-}
-
-static inline unsigned long zs_stat_get(struct size_class *class,
-				enum zs_stat_type type)
-{
-	return 0;
-}
-
 static int __init zs_stat_init(void)
 {
 	return 0;
@@ -610,7 +587,6 @@ static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
 static inline void zs_pool_stat_destroy(struct zs_pool *pool)
 {
 }
-
 #endif
 
 
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
