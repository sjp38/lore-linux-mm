Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 843C9900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:05:01 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so12285295pac.2
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:01 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id qz4si10597087pac.210.2015.06.05.05.05.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:05:00 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so14451020pdj.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:00 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 4/8] zsmalloc: always keep per-class stats
Date: Fri,  5 Jun 2015 21:03:54 +0900
Message-Id: <1433505838-23058-5-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

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
---
 mm/zsmalloc.c | 49 ++++++++++++-------------------------------------
 1 file changed, 12 insertions(+), 37 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b94e281..0453347 100644
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
@@ -201,25 +199,21 @@ static int zs_size_classes;
 static const int fullness_threshold_frac = 3;
 
 struct size_class {
+	spinlock_t		lock;
+	struct page		*fullness_list[_ZS_NR_FULLNESS_GROUPS];
 	/*
 	 * Size of objects stored in this class. Must be multiple
 	 * of ZS_ALIGN.
 	 */
-	int size;
-	unsigned int index;
+	int			size;
+	unsigned int		index;
 
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
-	int pages_per_zspage;
-	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
-	bool huge;
-
-#ifdef CONFIG_ZSMALLOC_STAT
-	struct zs_size_stat stats;
-#endif
-
-	spinlock_t lock;
+	int			pages_per_zspage;
+	struct zs_size_stat	stats;
 
-	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
+	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
+	bool			huge;
 };
 
 /*
@@ -440,8 +434,6 @@ static int get_size_class_index(int size)
 	return min(zs_size_classes - 1, idx);
 }
 
-#ifdef CONFIG_ZSMALLOC_STAT
-
 static inline void zs_stat_inc(struct size_class *class,
 				enum zs_stat_type type, unsigned long cnt)
 {
@@ -460,6 +452,8 @@ static inline unsigned long zs_stat_get(struct size_class *class,
 	return class->stats.objs[type];
 }
 
+#ifdef CONFIG_ZSMALLOC_STAT
+
 static int __init zs_stat_init(void)
 {
 	if (!debugfs_initialized())
@@ -575,23 +569,6 @@ static void zs_pool_stat_destroy(struct zs_pool *pool)
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
@@ -609,7 +586,6 @@ static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
 static inline void zs_pool_stat_destroy(struct zs_pool *pool)
 {
 }
-
 #endif
 
 
@@ -1691,7 +1667,6 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
 			class->size, class->pages_per_zspage));
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
-
 		free_zspage(first_page);
 	}
 }
-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
