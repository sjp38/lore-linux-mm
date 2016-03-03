Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id F1AFD6B0253
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:48:20 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id w128so16330261pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:20 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 88si4361299pfh.24.2016.03.03.06.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:48:20 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id w128so16330135pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:20 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Date: Thu,  3 Mar 2016 23:45:59 +0900
Message-Id: <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zsmalloc classes are known to be affected by internal fragmentation.

For example, /sys/kernel/debug/zsmalloc/zramX/classes
 class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable
    54   896           1           12           117         57         26                2       12
...
   107  1744           1           23           196         76         84                3       51
   111  1808           0            0            63         63         28                4        0
   126  2048           0          160           568        408        284                1       80
   144  2336          52          620          8631       5747       4932                4     1648
   151  2448         123          406         10090       8736       6054                3      810
   168  2720           0          512         15738      14926      10492                2      540
   190  3072           0            2           136        130        102                3        3
...

demonstrates that class-896 has 12/26=46% of unused pages, class-2336 has
1648/4932=33% of unused pages, etc. And the more classes we will have as
'normal' classes (more than one object per-zspage) the bigger this problem
will grow. The existing compaction relies on a user space (user can trigger
compaction via `compact' zram's sysfs attr) or a shrinker; it does not
happen automatically.

This patch introduces a 'watermark' value of unused pages and schedules a
compaction work on a per-class basis once class's fragmentation becomes
too big. So compaction is not performed in current I/O operation context,
but in workqueue workers later.

The current watermark is set to 40% -- if class has 40+% of `freeable'
pages then compaction work will be scheduled.

TEST
====

  2G zram, ext4, lz0

  iozone -t 1 -R -r 64K -s 1200M -I +Z

                        BASE       PATCHED
"  Initial write "   959670.94    966724.62
"        Rewrite "  1276167.62   1237632.88
"           Read "  3334708.25   3345357.50
"        Re-read "  3405310.75   3337137.25
"   Reverse Read "  3284499.75   3241283.50
"    Stride read "  3293417.75   3268364.00
"    Random read "  3255253.50   3241685.00
" Mixed workload "  3274398.00   3231498.00
"   Random write "  1253207.50   1216247.00
"         Pwrite "   873682.25    877045.81
"          Pread "  3173266.00   3318471.75
"         Fwrite "   881278.38    897622.81
"          Fread "  4397147.00   4501131.50

  iozone -t 3 -R -r 64K -s 60M -I +Z

                        BASE       PATCHED
"  Initial write "  1855931.62   1869576.31
"        Rewrite "  2223531.06   2221543.62
"           Read "  7958435.75   8023044.75
"        Re-read "  7912776.75   8068961.00
"   Reverse Read "  7832227.50   7788237.50
"    Stride read "  7952113.50   7919778.00
"    Random read "  7908816.00   7881792.50
" Mixed workload "  6364520.38   6332493.94
"   Random write "  2230115.69   2176777.19
"         Pwrite "  1915939.31   1929464.75
"          Pread "  3857052.91   3840517.91
"         Fwrite "  2271730.44   2272800.31
"          Fread "  9053867.00   8880966.25

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e72efb1..a4ef7e7 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -219,6 +219,10 @@ struct size_class {
 	int pages_per_zspage;
 	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
 	bool huge;
+
+	bool compact_scheduled;
+	struct zs_pool *pool;
+	struct work_struct compact_work;
 };
 
 /*
@@ -1467,6 +1471,8 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
+static bool class_watermark_ok(struct size_class *class);
+
 void zs_free(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *first_page, *f_page;
@@ -1495,6 +1501,11 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
 		free_zspage(first_page);
+	} else {
+		if (!class_watermark_ok(class) && !class->compact_scheduled) {
+			queue_work(system_long_wq, &class->compact_work);
+			class->compact_scheduled = true;
+		}
 	}
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
@@ -1745,6 +1756,19 @@ static unsigned long zs_can_compact(struct size_class *class)
 	return obj_wasted * class->pages_per_zspage;
 }
 
+static bool class_watermark_ok(struct size_class *class)
+{
+	unsigned long pages_used = zs_stat_get(class, OBJ_ALLOCATED);
+
+	pages_used /= get_maxobj_per_zspage(class->size,
+			class->pages_per_zspage) * class->pages_per_zspage;
+
+	if (!pages_used)
+		return true;
+
+	return (100 * zs_can_compact(class) / pages_used) < 40;
+}
+
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
 	struct zs_compact_control cc;
@@ -1789,9 +1813,17 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
+	class->compact_scheduled = false;
 	spin_unlock(&class->lock);
 }
 
+static void class_compaction_work(struct work_struct *work)
+{
+	struct size_class *class = container_of(work, struct size_class, compact_work);
+
+	__zs_compact(class->pool, class);
+}
+
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
@@ -1948,6 +1980,9 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		if (pages_per_zspage == 1 &&
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
+
+		INIT_WORK(&class->compact_work, class_compaction_work);
+		class->pool = pool;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
 
@@ -1990,6 +2025,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 		if (class->index != i)
 			continue;
 
+		cancel_work_sync(&class->compact_work);
+
 		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
 			if (class->fullness_list[fg]) {
 				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
-- 
2.8.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
