Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 52AAB6B0072
	for <linux-mm@kvack.org>; Sat, 13 Dec 2014 08:45:31 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so6865100pdi.35
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 05:45:31 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id l6si6166179pdr.127.2014.12.13.05.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 13 Dec 2014 05:45:29 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so8955014pad.41
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 05:45:28 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 2/2] mm/zsmalloc: add statistics support
Date: Sat, 13 Dec 2014 21:45:14 +0800
Message-Id: <1418478314-17731-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

As a ram based memory allocator, keep the fragmentation in a low level
is our target. But now we still need to add the debug code in zsmalloc
to get the quantitative data.

After the RFC patch [1], Minchan Kim gave some suggestions.
  [1] https://patchwork.kernel.org/patch/5469301/

This patch adds a new configuration CONFIG_ZSMALLOC_STAT to enable the statistics
collection for developers. Currently only the objects information in each class
are collected. User can get the information via debugfs. For example:

After I copy file jdk-8u25-linux-x64.tar.gz to zram with ext4 filesystem.
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

We can see the overall fragentation is:
    (37022 - 36326) / 37022 = 1.87%

Also from the statistics we know why we got so low fragmentation:
Most of the objects is in class 254 with size 4096 Bytes. The pages in
zspage is 1. And there is only one object in a page. So, No fragmentation
will be produced.

Also we can collect other information and show it to user in the future.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
---
 mm/Kconfig    |   10 ++++
 mm/zsmalloc.c |  164 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 174 insertions(+)

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
index b724039..a8d0020 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -168,6 +168,8 @@ enum fullness_group {
 	ZS_FULL
 };
 
+static int zs_pool_num;
+
 /*
  * number of size_classes
  */
@@ -200,6 +202,11 @@ struct size_class {
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
 	int pages_per_zspage;
 
+#ifdef CONFIG_ZSMALLOC_STAT
+	unsigned long obj_allocated;
+	unsigned long obj_used;
+#endif
+
 	spinlock_t lock;
 
 	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
@@ -221,6 +228,10 @@ struct zs_pool {
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
+
+#ifdef CONFIG_ZSMALLOC_STAT
+	struct dentry *stat_dentry;
+#endif
 };
 
 /*
@@ -942,6 +953,132 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
+
+#ifdef CONFIG_ZSMALLOC_STAT
+#include <linux/debugfs.h>
+
+static struct dentry *zs_stat_root;
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
+static int zs_stats_show(struct seq_file *s, void *v)
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
+
+		obj_allocated = class->obj_allocated;
+		obj_used = class->obj_used;
+		objs_per_zspage = get_maxobj_per_zspage(class->size,
+				class->pages_per_zspage);
+		pages_used = obj_allocated / objs_per_zspage *
+				class->pages_per_zspage;
+
+		spin_unlock(&class->lock);
+
+		seq_printf(s, " %5u %5u    %10lu %10lu %10lu\n", i, class->size,
+					obj_allocated, obj_used, pages_used);
+
+		total_objs += class->obj_allocated;
+		total_used_objs += class->obj_used;
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
+static int zs_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, zs_stats_show, inode->i_private);
+}
+
+static const struct file_operations zs_stats_operations = {
+	.open           = zs_stats_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+static int zs_pool_stat_create(struct zs_pool *pool, int index)
+{
+	char name[10];
+	int ret = 0;
+
+	if (!zs_stat_root) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	snprintf(name, sizeof(name), "pool-%d", index);
+	pool->stat_dentry = debugfs_create_dir(name, zs_stat_root);
+	if (!pool->stat_dentry) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
+			pool->stat_dentry, pool, &zs_stats_operations);
+
+out:
+	return ret;
+}
+
+static void zs_pool_stat_destroy(struct zs_pool *pool)
+{
+	debugfs_remove_recursive(pool->stat_dentry);
+}
+
+#else /* CONFIG_ZSMALLOC_STAT */
+
+static int __init zs_stat_init(void)
+{
+	return 0;
+}
+
+static void __exit zs_stat_exit(void) { }
+
+static inline int zs_pool_stat_create(struct zs_pool *pool, int index)
+{
+	return 0;
+}
+
+static inline void zs_pool_stat_destroy(struct zs_pool *pool) { }
+
+#endif
+
 unsigned long zs_get_total_pages(struct zs_pool *pool)
 {
 	return atomic_long_read(&pool->pages_allocated);
@@ -1075,6 +1212,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
 		spin_lock(&class->lock);
+#ifdef CONFIG_ZSMALLOC_STAT
+		class->obj_allocated += get_maxobj_per_zspage(class->size,
+				class->pages_per_zspage);
+#endif
 	}
 
 	obj = (unsigned long)first_page->freelist;
@@ -1088,6 +1229,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	kunmap_atomic(vaddr);
 
 	first_page->inuse++;
+#ifdef CONFIG_ZSMALLOC_STAT
+	class->obj_used++;
+#endif
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(pool, first_page);
 	spin_unlock(&class->lock);
@@ -1127,12 +1271,19 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 	first_page->freelist = (void *)obj;
 
 	first_page->inuse--;
+#ifdef CONFIG_ZSMALLOC_STAT
+	class->obj_used--;
+#endif
 	fullness = fix_fullness_group(pool, first_page);
 	spin_unlock(&class->lock);
 
 	if (fullness == ZS_EMPTY) {
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
+#ifdef CONFIG_ZSMALLOC_STAT
+		class->obj_allocated -= get_maxobj_per_zspage(class->size,
+				class->pages_per_zspage);
+#endif
 		free_zspage(first_page);
 	}
 }
@@ -1209,6 +1360,10 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 	}
 
 	pool->flags = flags;
+	zs_pool_num++;
+
+	if (zs_pool_stat_create(pool, zs_pool_num))
+		pr_warn("zs pool %d stat initialization failed\n", zs_pool_num);
 
 	return pool;
 
@@ -1241,6 +1396,9 @@ void zs_destroy_pool(struct zs_pool *pool)
 		kfree(class);
 	}
 
+	zs_pool_stat_destroy(pool);
+	zs_pool_num--;
+
 	kfree(pool->size_class);
 	kfree(pool);
 }
@@ -1260,6 +1418,10 @@ static int __init zs_init(void)
 #ifdef CONFIG_ZPOOL
 	zpool_register_driver(&zs_zpool_driver);
 #endif
+
+	if (zs_stat_init())
+		pr_warn("zs stat initialization failed\n");
+
 	return 0;
 }
 
@@ -1269,6 +1431,8 @@ static void __exit zs_exit(void)
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
