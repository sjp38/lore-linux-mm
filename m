Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3893C9003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 07:58:21 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so38677801pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:58:21 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id sy6si34388121pab.74.2015.07.07.04.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 04:58:20 -0700 (PDT)
Received: by pddu5 with SMTP id u5so37302041pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:58:19 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v6 6/7] zsmalloc: account the number of compacted pages
Date: Tue,  7 Jul 2015 20:57:00 +0900
Message-Id: <1436270221-17844-7-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Compaction returns back to zram the number of migrated objects,
which is quite uninformative -- we have objects of different
sizes so user space cannot obtain any valuable data from that
number. Change compaction to operate in terms of pages and
return back to compaction issuer the number of pages that
were freed during compaction. So from now on we will export
more meaningful value in zram<id>/mm_stat -- the number of freed
(compacted) pages.

This requires:
(a) a rename of `num_migrated' to 'pages_compacted'
(b) a internal API change -- return first_page's fullness_group
from putback_zspage(), so we know when putback_zspage() did
free_zspage(). It helps us to account compaction stats correctly.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/blockdev/zram.txt |  3 ++-
 drivers/block/zram/zram_drv.c   |  2 +-
 include/linux/zsmalloc.h        |  4 ++--
 mm/zsmalloc.c                   | 27 +++++++++++++++++----------
 4 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index c4de576..62435bb 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -144,7 +144,8 @@ mem_used_max      RW    the maximum amount memory zram have consumed to
                         store compressed data
 mem_limit         RW    the maximum amount of memory ZRAM can use to store
                         the compressed data
-num_migrated      RO    the number of objects migrated migrated by compaction
+pages_compacted   RO    the number of pages freed during compaction
+                        (available only via zram<id>/mm_stat node)
 compact           WO    trigger memory compaction
 
 WARNING
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index aa22fe07..1bcbc19 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -448,7 +448,7 @@ static ssize_t mm_stat_show(struct device *dev,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.zero_pages),
-			pool_stats.num_migrated);
+			pool_stats.pages_compacted);
 	up_read(&zram->init_lock);
 
 	return ret;
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 9340fce..cda4ad4 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -35,8 +35,8 @@ enum zs_mapmode {
 };
 
 struct zs_pool_stats {
-	/* How many objects were migrated */
-	u64		num_migrated;
+	/* How many pages were migrated (freed) */
+	u64		pages_compacted;
 };
 
 struct zs_pool;
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index db3cb2d..13f2c4a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1589,8 +1589,6 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* How many of objects were migrated */
-	int nr_migrated;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1627,7 +1625,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-		cc->nr_migrated++;
 	}
 
 	/* Remember last position in this iteration */
@@ -1653,8 +1650,17 @@ static struct page *isolate_target_page(struct size_class *class)
 	return page;
 }
 
-static void putback_zspage(struct zs_pool *pool, struct size_class *class,
-				struct page *first_page)
+/*
+ * putback_zspage - add @first_page into right class's fullness list
+ * @pool: target pool
+ * @class: destination class
+ * @first_page: target page
+ *
+ * Return @fist_page's fullness_group
+ */
+static enum fullness_group putback_zspage(struct zs_pool *pool,
+			struct size_class *class,
+			struct page *first_page)
 {
 	enum fullness_group fullness;
 
@@ -1672,6 +1678,8 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
 
 		free_zspage(first_page);
 	}
+
+	return fullness;
 }
 
 static struct page *isolate_source_page(struct size_class *class)
@@ -1713,7 +1721,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	struct page *src_page;
 	struct page *dst_page = NULL;
 
-	cc.nr_migrated = 0;
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
@@ -1742,7 +1749,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			break;
 
 		putback_zspage(pool, class, dst_page);
-		putback_zspage(pool, class, src_page);
+		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
+			pool->stats.pages_compacted +=
+				get_pages_per_zspage(class->size);
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
@@ -1751,8 +1760,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	pool->stats.num_migrated += cc.nr_migrated;
-
 	spin_unlock(&class->lock);
 }
 
@@ -1770,7 +1777,7 @@ unsigned long zs_compact(struct zs_pool *pool)
 		__zs_compact(pool, class);
 	}
 
-	return pool->stats.num_migrated;
+	return pool->stats.pages_compacted;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
