Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B302D6B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:52 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so30698695pdb.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:52 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id da10si3540689pdb.126.2015.03.03.21.00.44
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:45 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 7/7] zsmalloc: add fullness into stat
Date: Wed,  4 Mar 2015 14:01:32 +0900
Message-Id: <1425445292-29061-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

During investigating compaction, fullness information of each class
is helpful for investigating how the compaction works well.
With that, we could know how compaction works well more clear
on each size class.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 349 +++++++++++++++++++++++++++++++---------------------------
 1 file changed, 184 insertions(+), 165 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c3d9676e47c4..53b6f627edaa 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -196,6 +196,8 @@ enum fullness_group {
 enum zs_stat_type {
 	OBJ_ALLOCATED,
 	OBJ_USED,
+	CLASS_ALMOST_FULL,
+	CLASS_ALMOST_EMPTY,
 	NR_ZS_STAT_TYPE,
 };
 
@@ -411,6 +413,11 @@ static struct zpool_driver zs_zpool_driver = {
 MODULE_ALIAS("zpool-zsmalloc");
 #endif /* CONFIG_ZPOOL */
 
+static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
+{
+	return pages_per_zspage * PAGE_SIZE / size;
+}
+
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
@@ -464,6 +471,179 @@ static int get_size_class_index(int size)
 	return min(zs_size_classes - 1, idx);
 }
 
+#ifdef CONFIG_ZSMALLOC_STAT
+
+static inline void zs_stat_inc(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+	class->stats.objs[type] += cnt;
+}
+
+static inline void zs_stat_dec(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+	class->stats.objs[type] -= cnt;
+}
+
+static inline unsigned long zs_stat_get(struct size_class *class,
+				enum zs_stat_type type)
+{
+	return class->stats.objs[type];
+}
+
+static int __init zs_stat_init(void)
+{
+	if (!debugfs_initialized())
+		return -ENODEV;
+
+	zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
+	if (!zs_stat_root)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __exit zs_stat_exit(void)
+{
+	debugfs_remove_recursive(zs_stat_root);
+}
+
+static int zs_stats_size_show(struct seq_file *s, void *v)
+{
+	int i;
+	struct zs_pool *pool = s->private;
+	struct size_class *class;
+	int objs_per_zspage;
+	unsigned long class_almost_full, class_almost_empty;
+	unsigned long obj_allocated, obj_used, pages_used;
+	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
+	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
+
+	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
+			"class", "size", "almost_full", "almost_empty",
+			"obj_allocated", "obj_used", "pages_used",
+			"pages_per_zspage");
+
+	for (i = 0; i < zs_size_classes; i++) {
+		class = pool->size_class[i];
+
+		if (class->index != i)
+			continue;
+
+		spin_lock(&class->lock);
+		class_almost_full = zs_stat_get(class, CLASS_ALMOST_FULL);
+		class_almost_empty = zs_stat_get(class, CLASS_ALMOST_EMPTY);
+		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
+		obj_used = zs_stat_get(class, OBJ_USED);
+		spin_unlock(&class->lock);
+
+		objs_per_zspage = get_maxobj_per_zspage(class->size,
+				class->pages_per_zspage);
+		pages_used = obj_allocated / objs_per_zspage *
+				class->pages_per_zspage;
+
+		seq_printf(s, " %5u %5u %11lu %12lu %13lu %10lu %10lu %16d\n",
+			i, class->size, class_almost_full, class_almost_empty,
+			obj_allocated, obj_used, pages_used,
+			class->pages_per_zspage);
+
+		total_class_almost_full += class_almost_full;
+		total_class_almost_empty += class_almost_empty;
+		total_objs += obj_allocated;
+		total_used_objs += obj_used;
+		total_pages += pages_used;
+	}
+
+	seq_puts(s, "\n");
+	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu\n",
+			"Total", "", total_class_almost_full,
+			total_class_almost_empty, total_objs,
+			total_used_objs, total_pages);
+
+	return 0;
+}
+
+static int zs_stats_size_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, zs_stats_size_show, inode->i_private);
+}
+
+static const struct file_operations zs_stat_size_ops = {
+	.open           = zs_stats_size_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static int zs_pool_stat_create(char *name, struct zs_pool *pool)
+{
+	struct dentry *entry;
+
+	if (!zs_stat_root)
+		return -ENODEV;
+
+	entry = debugfs_create_dir(name, zs_stat_root);
+	if (!entry) {
+		pr_warn("debugfs dir <%s> creation failed\n", name);
+		return -ENOMEM;
+	}
+	pool->stat_dentry = entry;
+
+	entry = debugfs_create_file("classes", S_IFREG | S_IRUGO,
+			pool->stat_dentry, pool, &zs_stat_size_ops);
+	if (!entry) {
+		pr_warn("%s: debugfs file entry <%s> creation failed\n",
+				name, "classes");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void zs_pool_stat_destroy(struct zs_pool *pool)
+{
+	debugfs_remove_recursive(pool->stat_dentry);
+}
+
+#else /* CONFIG_ZSMALLOC_STAT */
+
+static inline void zs_stat_inc(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+}
+
+static inline void zs_stat_dec(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+}
+
+static inline unsigned long zs_stat_get(struct size_class *class,
+				enum zs_stat_type type)
+{
+	return 0;
+}
+
+static int __init zs_stat_init(void)
+{
+	return 0;
+}
+
+static void __exit zs_stat_exit(void)
+{
+}
+
+static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
+{
+	return 0;
+}
+
+static inline void zs_pool_stat_destroy(struct zs_pool *pool)
+{
+}
+
+#endif
+
+
 /*
  * For each size class, zspages are divided into different groups
  * depending on how "full" they are. This was done so that we could
@@ -513,6 +693,8 @@ static void insert_zspage(struct page *page, struct size_class *class,
 		list_add_tail(&page->lru, &(*head)->lru);
 
 	*head = page;
+	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
+			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
 
 /*
@@ -538,6 +720,8 @@ static void remove_zspage(struct page *page, struct size_class *class,
 					struct page, lru);
 
 	list_del_init(&page->lru);
+	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
+			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
 
 /*
@@ -1056,11 +1240,6 @@ static void init_zs_size_classes(void)
 	zs_size_classes = nr;
 }
 
-static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
-{
-	return pages_per_zspage * PAGE_SIZE / size;
-}
-
 static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 {
 	if (prev->pages_per_zspage != pages_per_zspage)
@@ -1080,166 +1259,6 @@ static bool zspage_full(struct page *page)
 	return page->inuse == page->objects;
 }
 
-#ifdef CONFIG_ZSMALLOC_STAT
-
-static inline void zs_stat_inc(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
-{
-	class->stats.objs[type] += cnt;
-}
-
-static inline void zs_stat_dec(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
-{
-	class->stats.objs[type] -= cnt;
-}
-
-static inline unsigned long zs_stat_get(struct size_class *class,
-				enum zs_stat_type type)
-{
-	return class->stats.objs[type];
-}
-
-static int __init zs_stat_init(void)
-{
-	if (!debugfs_initialized())
-		return -ENODEV;
-
-	zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
-	if (!zs_stat_root)
-		return -ENOMEM;
-
-	return 0;
-}
-
-static void __exit zs_stat_exit(void)
-{
-	debugfs_remove_recursive(zs_stat_root);
-}
-
-static int zs_stats_size_show(struct seq_file *s, void *v)
-{
-	int i;
-	struct zs_pool *pool = s->private;
-	struct size_class *class;
-	int objs_per_zspage;
-	unsigned long obj_allocated, obj_used, pages_used;
-	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
-
-	seq_printf(s, " %5s %5s %13s %10s %10s\n", "class", "size",
-				"obj_allocated", "obj_used", "pages_used");
-
-	for (i = 0; i < zs_size_classes; i++) {
-		class = pool->size_class[i];
-
-		if (class->index != i)
-			continue;
-
-		spin_lock(&class->lock);
-		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
-		obj_used = zs_stat_get(class, OBJ_USED);
-		spin_unlock(&class->lock);
-
-		objs_per_zspage = get_maxobj_per_zspage(class->size,
-				class->pages_per_zspage);
-		pages_used = obj_allocated / objs_per_zspage *
-				class->pages_per_zspage;
-
-		seq_printf(s, " %5u %5u    %10lu %10lu %10lu\n", i,
-			class->size, obj_allocated, obj_used, pages_used);
-
-		total_objs += obj_allocated;
-		total_used_objs += obj_used;
-		total_pages += pages_used;
-	}
-
-	seq_puts(s, "\n");
-	seq_printf(s, " %5s %5s    %10lu %10lu %10lu\n", "Total", "",
-			total_objs, total_used_objs, total_pages);
-
-	return 0;
-}
-
-static int zs_stats_size_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, zs_stats_size_show, inode->i_private);
-}
-
-static const struct file_operations zs_stat_size_ops = {
-	.open           = zs_stats_size_open,
-	.read           = seq_read,
-	.llseek         = seq_lseek,
-	.release        = single_release,
-};
-
-static int zs_pool_stat_create(char *name, struct zs_pool *pool)
-{
-	struct dentry *entry;
-
-	if (!zs_stat_root)
-		return -ENODEV;
-
-	entry = debugfs_create_dir(name, zs_stat_root);
-	if (!entry) {
-		pr_warn("debugfs dir <%s> creation failed\n", name);
-		return -ENOMEM;
-	}
-	pool->stat_dentry = entry;
-
-	entry = debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
-			pool->stat_dentry, pool, &zs_stat_size_ops);
-	if (!entry) {
-		pr_warn("%s: debugfs file entry <%s> creation failed\n",
-				name, "obj_in_classes");
-		return -ENOMEM;
-	}
-
-	return 0;
-}
-
-static void zs_pool_stat_destroy(struct zs_pool *pool)
-{
-	debugfs_remove_recursive(pool->stat_dentry);
-}
-
-#else /* CONFIG_ZSMALLOC_STAT */
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
-static int __init zs_stat_init(void)
-{
-	return 0;
-}
-
-static void __exit zs_stat_exit(void)
-{
-}
-
-static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
-{
-	return 0;
-}
-
-static inline void zs_pool_stat_destroy(struct zs_pool *pool)
-{
-}
-
-#endif
-
 unsigned long zs_get_total_pages(struct zs_pool *pool)
 {
 	return atomic_long_read(&pool->pages_allocated);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
