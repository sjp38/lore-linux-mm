Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E2A3E6B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 01:26:09 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fy10so62295964pac.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 22:26:09 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id 70si25179424pfn.223.2016.02.26.22.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 22:26:09 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id fl4so62372391pad.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 22:26:09 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] mm/zsmalloc: add compact column to pool stat
Date: Sat, 27 Feb 2016 15:23:53 +0900
Message-Id: <1456554233-9088-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Add a new column to pool stats, which will tell us class' zs_can_compact()
number, so it will be easier to analyze zsmalloc fragmentation.

At the moment, we have only numbers of FULL and ALMOST_EMPTY classes, but
they don't tell us how badly the class is fragmented internally.

The new /sys/kernel/debug/zsmalloc/zramX/classes output look as follows:

 class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
[..]
    12   224           0            2           146          5          8                4       4
    13   240           0            0             0          0          0                1       0
    14   256           1           13          1840       1672        115                1      10
    15   272           0            0             0          0          0                1       0
[..]
    49   816           0            3           745        735        149                1       2
    51   848           3            4           361        306         76                4       8
    52   864          12           14           378        268         81                3      21
    54   896           1           12           117         57         26                2      12
    57   944           0            0             0          0          0                3       0
[..]
 Total                26          131         12709      10994       1071                      134

For example, from this particular output we can easily conclude that class-896
is heavily fragmented -- it occupies 26 pages, 12 can be freed by compaction.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 43e4cbc..046d364 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -494,6 +494,8 @@ static void __exit zs_stat_exit(void)
 	debugfs_remove_recursive(zs_stat_root);
 }
 
+static unsigned long zs_can_compact(struct size_class *class);
+
 static int zs_stats_size_show(struct seq_file *s, void *v)
 {
 	int i;
@@ -501,14 +503,15 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	struct size_class *class;
 	int objs_per_zspage;
 	unsigned long class_almost_full, class_almost_empty;
-	unsigned long obj_allocated, obj_used, pages_used;
+	unsigned long obj_allocated, obj_used, pages_used, compact;
 	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
 	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
+	unsigned long total_compact = 0;
 
-	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
+	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s %7s\n",
 			"class", "size", "almost_full", "almost_empty",
 			"obj_allocated", "obj_used", "pages_used",
-			"pages_per_zspage");
+			"pages_per_zspage", "compact");
 
 	for (i = 0; i < zs_size_classes; i++) {
 		class = pool->size_class[i];
@@ -521,6 +524,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 		class_almost_empty = zs_stat_get(class, CLASS_ALMOST_EMPTY);
 		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
 		obj_used = zs_stat_get(class, OBJ_USED);
+		compact = zs_can_compact(class);
 		spin_unlock(&class->lock);
 
 		objs_per_zspage = get_maxobj_per_zspage(class->size,
@@ -528,23 +532,25 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 		pages_used = obj_allocated / objs_per_zspage *
 				class->pages_per_zspage;
 
-		seq_printf(s, " %5u %5u %11lu %12lu %13lu %10lu %10lu %16d\n",
+		seq_printf(s, " %5u %5u %11lu %12lu %13lu"
+				" %10lu %10lu %16d %7lu\n",
 			i, class->size, class_almost_full, class_almost_empty,
 			obj_allocated, obj_used, pages_used,
-			class->pages_per_zspage);
+			class->pages_per_zspage, compact);
 
 		total_class_almost_full += class_almost_full;
 		total_class_almost_empty += class_almost_empty;
 		total_objs += obj_allocated;
 		total_used_objs += obj_used;
 		total_pages += pages_used;
+		total_compact += compact;
 	}
 
 	seq_puts(s, "\n");
-	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu\n",
+	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu %16s %7lu\n",
 			"Total", "", total_class_almost_full,
 			total_class_almost_empty, total_objs,
-			total_used_objs, total_pages);
+			total_used_objs, total_pages, "", total_compact);
 
 	return 0;
 }
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
