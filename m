Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 50F4F6B0073
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:55:54 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so1142626pdj.41
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 04:55:54 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id by8si551598pdb.138.2014.12.19.04.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 04:55:52 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so1162876pad.27
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 04:55:51 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2] mm/zsmalloc: add statistics support
Date: Fri, 19 Dec 2014 20:55:19 +0800
Message-Id: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Keeping fragmentation of zsmalloc in a low level is our target. But now
we still need to add the debug code in zsmalloc to get the quantitative data.

This patch adds a new configuration CONFIG_ZSMALLOC_STAT to enable the
statistics collection for developers. Currently only the objects statatitics
in each class are collected. User can get the information via debugfs.
     cat /sys/kernel/debug/zsmalloc/pool-1/...

For example:

After I copied "jdk-8u25-linux-x64.tar.gz" to zram with ext4 filesystem:
 class  size obj_allocated   obj_used pages_used
     0    32             0          0          0
     1    48           256         12          3
     2    64            64         14          1
     3    80            51          7          1
     4    96           128          5          3
     5   112            73          5          2
     6   128            32          4          1
     7   144             0          0          0
     8   160             0          0          0
     9   176             0          0          0
    10   192             0          0          0
    11   208             0          0          0
    12   224             0          0          0
    13   240             0          0          0
    14   256            16          1          1
    15   272            15          9          1
    16   288             0          0          0
    17   304             0          0          0
    18   320             0          0          0
    19   336             0          0          0
    20   352             0          0          0
    21   368             0          0          0
    22   384             0          0          0
    23   400             0          0          0
    24   416             0          0          0
    25   432             0          0          0
    26   448             0          0          0
    27   464             0          0          0
    28   480             0          0          0
    29   496            33          1          4
    30   512             0          0          0
    31   528             0          0          0
    32   544             0          0          0
    33   560             0          0          0
    34   576             0          0          0
    35   592             0          0          0
    36   608             0          0          0
    37   624             0          0          0
    38   640             0          0          0
    40   672             0          0          0
    42   704             0          0          0
    43   720            17          1          3
    44   736             0          0          0
    46   768             0          0          0
    49   816             0          0          0
    51   848             0          0          0
    52   864            14          1          3
    54   896             0          0          0
    57   944            13          1          3
    58   960             0          0          0
    62  1024             4          1          1
    66  1088            15          2          4
    67  1104             0          0          0
    71  1168             0          0          0
    74  1216             0          0          0
    76  1248             0          0          0
    83  1360             3          1          1
    91  1488            11          1          4
    94  1536             0          0          0
   100  1632             5          1          2
   107  1744             0          0          0
   111  1808             9          1          4
   126  2048             4          4          2
   144  2336             7          3          4
   151  2448             0          0          0
   168  2720            15         15         10
   190  3072            28         27         21
   202  3264             0          0          0
   254  4096         36209      36209      36209

 Total               37022      36326      36288

We can calculate the overall fragentation by the last line:
    Total               37022      36326      36288
    (37022 - 36326) / 37022 = 1.87%

Also by analysing objects alocated in every class we know why we got so low fragmentation:
    Most of the allocated objects is in <class 254>. And there is only 1 page in class
    254 zspage.  So, No fragmentation will be introduced by allocating objs in class 254.

To let users know which zsmalloc pool he is using, an API get_zs_pool_index() is exported.
User can call it to get the zs pool index after zs pool is populated.

And you can collect other zsmalloc statistics as you need and analyse them.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>

---
V1 -> V2:
    create and use zs_size_stat to store the zs stat - Minchan
    use pool->index to associate zs pool and block device - Minchan
    export get_zs_pool_index() to zsmalloc user - Minchan
    Fix race for zs pool index increasement - Minchan
    patch description change - Minchan
    propagate error to user when zs_stat_init() is failed - Minchan
---
 include/linux/zsmalloc.h |    9 ++
 mm/Kconfig               |   10 ++
 mm/zsmalloc.c            |  246 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 261 insertions(+), 4 deletions(-)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 05c2147..e79201c 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -48,4 +48,13 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
 
+#ifdef CONFIG_ZSMALLOC_STAT
+int get_zs_pool_index(struct zs_pool *pool);
+#else
+static inline int get_zs_pool_index(struct zs_pool *pool)
+{
+	return -1;
+}
+#endif
+
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..95c5728 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -601,6 +601,16 @@ config PGTABLE_MAPPING
 	  You can check speed with zsmalloc benchmark:
 	  https://github.com/spartacus06/zsmapbench
 
+config ZSMALLOC_STAT
+	bool "Export zsmalloc statistics"
+	depends on ZSMALLOC
+	select DEBUG_FS
+	help
+	  This option enables code in the zsmalloc to collect various
+	  statistics about whats happening in zsmalloc and exports that
+	  information to userspace via debugfs.
+	  If unsure, say N.
+
 config GENERIC_EARLY_IOREMAP
 	bool
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b724039..8f9bb61 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -91,6 +91,7 @@
 #include <linux/hardirq.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
+#include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
 
@@ -168,6 +169,23 @@ enum fullness_group {
 	ZS_FULL
 };
 
+enum zs_stat_type {
+	OBJ_ALLOCATED,
+	OBJ_USED,
+};
+
+#ifdef CONFIG_ZSMALLOC_STAT
+
+static atomic_t zs_pool_index = ATOMIC_INIT(0);
+static struct dentry *zs_stat_root;
+
+struct zs_size_stat {
+	unsigned long obj_allocated;
+	unsigned long obj_used;
+};
+
+#endif
+
 /*
  * number of size_classes
  */
@@ -200,6 +218,10 @@ struct size_class {
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
 	int pages_per_zspage;
 
+#ifdef CONFIG_ZSMALLOC_STAT
+	struct zs_size_stat stats;
+#endif
+
 	spinlock_t lock;
 
 	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
@@ -221,6 +243,11 @@ struct zs_pool {
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
+
+#ifdef CONFIG_ZSMALLOC_STAT
+	int index;
+	struct dentry *stat_dentry;
+#endif
 };
 
 /*
@@ -942,6 +969,187 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
+#ifdef CONFIG_ZSMALLOC_STAT
+
+static inline void zs_stat_inc(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+	if (type == OBJ_ALLOCATED)
+		class->stats.obj_allocated += cnt;
+	else if (type == OBJ_USED)
+		class->stats.obj_used += cnt;
+}
+
+static inline void zs_stat_dec(struct size_class *class,
+				enum zs_stat_type type, unsigned long cnt)
+{
+	if (type == OBJ_ALLOCATED)
+		class->stats.obj_allocated -= cnt;
+	else if (type == OBJ_USED)
+		class->stats.obj_used -= cnt;
+}
+
+static inline unsigned long zs_stat_get(struct size_class *class,
+				enum zs_stat_type type)
+{
+	if (type == OBJ_ALLOCATED)
+		return class->stats.obj_allocated;
+	else if (type == OBJ_USED)
+		return class->stats.obj_used;
+
+	return 0;
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
+	struct zs_pool *pool = (struct zs_pool *)s->private;
+	struct size_class *class;
+	int objs_per_zspage;
+	unsigned long obj_allocated, obj_used, pages_used;
+	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
+
+	seq_printf(s, " %5s %5s %13s %10s %10s\n", "class", "size",
+				"obj_allocated", "obj_used", "pages_used");
+
+	for (i = 0; i < zs_size_classes; i++) {
+		class = pool->size_class[i];
+
+		if (class->index != i)
+			continue;
+
+		spin_lock(&class->lock);
+		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
+		obj_used = zs_stat_get(class, OBJ_USED);
+		spin_unlock(&class->lock);
+
+		objs_per_zspage = get_maxobj_per_zspage(class->size,
+				class->pages_per_zspage);
+		pages_used = obj_allocated / objs_per_zspage *
+				class->pages_per_zspage;
+
+		seq_printf(s, " %5u %5u    %10lu %10lu %10lu\n", i,
+			class->size, obj_allocated, obj_used, pages_used);
+
+		total_objs += obj_allocated;
+		total_used_objs += obj_used;
+		total_pages += pages_used;
+	}
+
+	seq_puts(s, "\n");
+	seq_printf(s, " %5s %5s    %10lu %10lu %10lu\n", "Total", "",
+			total_objs, total_used_objs, total_pages);
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
+static int zs_pool_stat_create(struct zs_pool *pool)
+{
+	char name[10];
+	struct dentry *entry;
+
+	if (!zs_stat_root)
+		return -ENODEV;
+
+	pool->index = atomic_inc_return(&zs_pool_index);
+	snprintf(name, sizeof(name), "pool-%d", pool->index);
+	entry = debugfs_create_dir(name, zs_stat_root);
+	if (!entry) {
+		pr_warn("pool %d, debugfs dir <%s> creation failed\n",
+				pool->index, name);
+		return -ENOMEM;
+	}
+	pool->stat_dentry = entry;
+
+	entry = debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
+			pool->stat_dentry, pool, &zs_stat_size_ops);
+	if (!entry) {
+		pr_warn("pool %d, debugfs file entry <%s> creation failed\n",
+				pool->index, "obj_in_classes");
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
+int get_zs_pool_index(struct zs_pool *pool)
+{
+	return pool->index;
+}
+EXPORT_SYMBOL_GPL(get_zs_pool_index);
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
+static inline int zs_pool_stat_create(struct zs_pool *pool)
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
 unsigned long zs_get_total_pages(struct zs_pool *pool)
 {
 	return atomic_long_read(&pool->pages_allocated);
@@ -1074,7 +1282,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
+
 		spin_lock(&class->lock);
+		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
 	}
 
 	obj = (unsigned long)first_page->freelist;
@@ -1088,6 +1299,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	kunmap_atomic(vaddr);
 
 	first_page->inuse++;
+	zs_stat_inc(class, OBJ_USED, 1);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(pool, first_page);
 	spin_unlock(&class->lock);
@@ -1128,6 +1340,12 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 
 	first_page->inuse--;
 	fullness = fix_fullness_group(pool, first_page);
+
+	zs_stat_dec(class, OBJ_USED, 1);
+	if (fullness == ZS_EMPTY)
+		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
+				class->size, class->pages_per_zspage));
+
 	spin_unlock(&class->lock);
 
 	if (fullness == ZS_EMPTY) {
@@ -1210,6 +1428,9 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 
 	pool->flags = flags;
 
+	if (zs_pool_stat_create(pool))
+		pr_warn("zs pool stat initialization failed\n");
+
 	return pool;
 
 err:
@@ -1222,6 +1443,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	zs_pool_stat_destroy(pool);
+
 	for (i = 0; i < zs_size_classes; i++) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
@@ -1250,17 +1473,30 @@ static int __init zs_init(void)
 {
 	int ret = zs_register_cpu_notifier();
 
-	if (ret) {
-		zs_unregister_cpu_notifier();
-		return ret;
-	}
+	if (ret)
+		goto notifier_fail;
 
 	init_zs_size_classes();
 
 #ifdef CONFIG_ZPOOL
 	zpool_register_driver(&zs_zpool_driver);
 #endif
+
+	ret = zs_stat_init();
+	if (ret) {
+		pr_err("zs stat initialization failed\n");
+		goto stat_fail;
+	}
 	return 0;
+
+stat_fail:
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&zs_zpool_driver);
+#endif
+notifier_fail:
+	zs_unregister_cpu_notifier();
+
+	return ret;
 }
 
 static void __exit zs_exit(void)
@@ -1269,6 +1505,8 @@ static void __exit zs_exit(void)
 	zpool_unregister_driver(&zs_zpool_driver);
 #endif
 	zs_unregister_cpu_notifier();
+
+	zs_stat_exit();
 }
 
 module_init(zs_init);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
