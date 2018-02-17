Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 384BB6B0009
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 09:43:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v10so319103pfl.21
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 06:43:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a14si2497668pgd.467.2018.02.17.06.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 06:42:58 -0800 (PST)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
Date: Sat, 17 Feb 2018 16:42:53 +0200
Message-Id: <20180217144253.58604-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

...instead of open coding file operations followed by custom ->open()
callbacks per each attribute.

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---

In v2:
- add tags
- fix compilation issue kbuild bot reported about

 mm/backing-dev.c  | 13 +------------
 mm/memblock.c     | 13 +------------
 mm/percpu-stats.c | 13 +------------
 mm/zsmalloc.c     | 15 ++-------------
 4 files changed, 5 insertions(+), 49 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ffa0c6b9e78a..c05fbe4daa5e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -100,18 +100,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 
 	return 0;
 }
-
-static int bdi_debug_stats_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, bdi_debug_stats_show, inode->i_private);
-}
-
-static const struct file_operations bdi_debug_stats_fops = {
-	.open		= bdi_debug_stats_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
+DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
 
 static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 5a9ca2a1751b..c4a522273664 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1846,18 +1846,7 @@ static int memblock_debug_show(struct seq_file *m, void *private)
 	}
 	return 0;
 }
-
-static int memblock_debug_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, memblock_debug_show, inode->i_private);
-}
-
-static const struct file_operations memblock_debug_fops = {
-	.open = memblock_debug_open,
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
+DEFINE_SHOW_ATTRIBUTE(memblock_debug);
 
 static int __init memblock_init_debugfs(void)
 {
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 7a58460bfd27..063ff60ecd90 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -223,18 +223,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 
 	return 0;
 }
-
-static int percpu_stats_open(struct inode *inode, struct file *filp)
-{
-	return single_open(filp, percpu_stats_show, NULL);
-}
-
-static const struct file_operations percpu_stats_fops = {
-	.open		= percpu_stats_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
+DEFINE_SHOW_ATTRIBUTE(percpu_stats);
 
 static int __init init_percpu_stats_debugfs(void)
 {
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b7f61cd1c709..a583ab111a43 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -642,18 +642,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 
 	return 0;
 }
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
+DEFINE_SHOW_ATTRIBUTE(zs_stats_size);
 
 static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
@@ -672,7 +661,7 @@ static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 	pool->stat_dentry = entry;
 
 	entry = debugfs_create_file("classes", S_IFREG | S_IRUGO,
-			pool->stat_dentry, pool, &zs_stat_size_ops);
+			pool->stat_dentry, pool, &zs_stats_size_fops);
 	if (!entry) {
 		pr_warn("%s: debugfs file entry <%s> creation failed\n",
 				name, "classes");
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
