Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E08CB6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:46:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x11so2009438pgr.9
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:46:49 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d26si2609845pge.98.2018.02.14.07.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 07:46:48 -0800 (PST)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
Date: Wed, 14 Feb 2018 17:46:44 +0200
Message-Id: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

...instead of open coding file operations followed by custom ->open()
callbacks per each attribute.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 mm/backing-dev.c  | 12 +-----------
 mm/memblock.c     | 12 +-----------
 mm/percpu-stats.c | 12 +-----------
 mm/zsmalloc.c     | 12 +-----------
 4 files changed, 4 insertions(+), 44 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ffa0c6b9e78a..71292de5f026 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -101,17 +101,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	return 0;
 }
 
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
index 5a9ca2a1751b..c2e5925ebdc4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1847,17 +1847,7 @@ static int memblock_debug_show(struct seq_file *m, void *private)
 	return 0;
 }
 
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
index 7a58460bfd27..0305cc4cbc3e 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -224,17 +224,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 	return 0;
 }
 
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
index c3013505c305..1b5cea3fe9fe 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -642,17 +642,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	return 0;
 }
 
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
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
