Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE07828E2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:06:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so24183515pfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:56 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id n128si3051261pfn.256.2016.07.07.02.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:06:55 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id ib6so1268324pad.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:55 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v4 8/8] mm/zsmalloc: add per-class compact trace event
Date: Thu,  7 Jul 2016 17:05:38 +0800
Message-Id: <1467882338-4300-8-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, mingo@redhat.com, rostedt@goodmis.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

add per-class compact trace event to get number of migrated objects
and number of freed pages.

trace log is like below:
----
            bash-3863  [001] ....   141.791366: zs_compact_start: pool zram0
            bash-3863  [001] ....   141.791372: zs_compact: class 254: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791375: zs_compact: class 202: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791385: zs_compact: class 190: 1 objects migrated, 3 pages freed
            bash-3863  [001] ....   141.791393: zs_compact: class 168: 2 objects migrated, 2 pages freed
            bash-3863  [001] ....   141.791396: zs_compact: class 151: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791407: zs_compact: class 144: 5 objects migrated, 4 pages freed
            bash-3863  [001] ....   141.791427: zs_compact: class 126: 8 objects migrated, 8 pages freed
            bash-3863  [001] ....   141.791433: zs_compact: class 111: 1 objects migrated, 4 pages freed
            bash-3863  [001] ....   141.791459: zs_compact: class 107: 18 objects migrated, 12 pages freed
            bash-3863  [001] ....   141.791487: zs_compact: class 100: 18 objects migrated, 16 pages freed
            bash-3863  [001] ....   141.791509: zs_compact: class  94: 18 objects migrated, 9 pages freed
            bash-3863  [001] ....   141.791560: zs_compact: class  91: 44 objects migrated, 24 pages freed
            bash-3863  [001] ....   141.791605: zs_compact: class  83: 35 objects migrated, 20 pages freed
            bash-3863  [001] ....   141.791616: zs_compact: class  76: 8 objects migrated, 4 pages freed
            bash-3863  [001] ....   141.791644: zs_compact: class  74: 21 objects migrated, 9 pages freed
            bash-3863  [001] ....   141.791665: zs_compact: class  71: 18 objects migrated, 10 pages freed
            bash-3863  [001] ....   141.791736: zs_compact: class  67: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791763: zs_compact: class  66: 22 objects migrated, 8 pages freed
            bash-3863  [001] ....   141.791820: zs_compact: class  62: 18 objects migrated, 6 pages freed
            bash-3863  [001] ....   141.791826: zs_compact: class  58: 1 objects migrated, 4 pages freed
            bash-3863  [001] ....   141.791829: zs_compact: class  57: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791834: zs_compact: class  54: 2 objects migrated, 2 pages freed
...
            bash-3863  [001] ....   141.791952: zs_compact: class   4: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791964: zs_compact: class   3: 14 objects migrated, 1 pages freed
            bash-3863  [001] ....   141.791966: zs_compact: class   2: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791968: zs_compact: class   1: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791971: zs_compact: class   0: 0 objects migrated, 0 pages freed
            bash-3863  [001] ....   141.791973: zs_compact_end: pool zram0: 155 pages compacted
----

Also this patch changes trace_zsmalloc_compact_start[end] to
trace_zs_compact_start[end] to keep function naming consistent
with others in zsmalloc.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v4:
    show number of migrated object rather than the number of scanning object
v3:
    add per-class compact trace event - Minchan

    I put this patch from 1/8 to 8/8, since this patch depends on below patch:
       mm/zsmalloc: use obj_index to keep consistent with others
       mm/zsmalloc: take obj index back from find_alloced_obj

v2:
    update commit description
---
 include/trace/events/zsmalloc.h | 40 ++++++++++++++++++++++++++++++----------
 mm/zsmalloc.c                   | 25 +++++++++++++++++--------
 2 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
index 3b6f14e..772cf65 100644
--- a/include/trace/events/zsmalloc.h
+++ b/include/trace/events/zsmalloc.h
@@ -7,7 +7,7 @@
 #include <linux/types.h>
 #include <linux/tracepoint.h>
 
-TRACE_EVENT(zsmalloc_compact_start,
+TRACE_EVENT(zs_compact_start,
 
 	TP_PROTO(const char *pool_name),
 
@@ -25,29 +25,49 @@ TRACE_EVENT(zsmalloc_compact_start,
 		  __entry->pool_name)
 );
 
-TRACE_EVENT(zsmalloc_compact_end,
+TRACE_EVENT(zs_compact_end,
 
-	TP_PROTO(const char *pool_name, unsigned long pages_compacted,
-			unsigned long pages_total_compacted),
+	TP_PROTO(const char *pool_name, unsigned long pages_compacted),
 
-	TP_ARGS(pool_name, pages_compacted, pages_total_compacted),
+	TP_ARGS(pool_name, pages_compacted),
 
 	TP_STRUCT__entry(
 		__field(const char *, pool_name)
 		__field(unsigned long, pages_compacted)
-		__field(unsigned long, pages_total_compacted)
 	),
 
 	TP_fast_assign(
 		__entry->pool_name = pool_name;
 		__entry->pages_compacted = pages_compacted;
-		__entry->pages_total_compacted = pages_total_compacted;
 	),
 
-	TP_printk("pool %s: %ld pages compacted(total %ld)",
+	TP_printk("pool %s: %ld pages compacted",
 		  __entry->pool_name,
-		  __entry->pages_compacted,
-		  __entry->pages_total_compacted)
+		  __entry->pages_compacted)
+);
+
+TRACE_EVENT(zs_compact,
+
+	TP_PROTO(int class, unsigned long nr_migrated_obj, unsigned long nr_freed_pages),
+
+	TP_ARGS(class, nr_migrated_obj, nr_freed_pages),
+
+	TP_STRUCT__entry(
+		__field(int, class)
+		__field(unsigned long, nr_migrated_obj)
+		__field(unsigned long, nr_freed_pages)
+	),
+
+	TP_fast_assign(
+		__entry->class = class;
+		__entry->nr_migrated_obj = nr_migrated_obj;
+		__entry->nr_freed_pages = nr_freed_pages;
+	),
+
+	TP_printk("class %3d: %ld objects migrated, %ld pages freed",
+		  __entry->class,
+		  __entry->nr_migrated_obj,
+		  __entry->nr_freed_pages)
 );
 
 #endif /* _TRACE_ZSMALLOC_H */
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 163bc90..5e5237c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1770,9 +1770,12 @@ struct zs_compact_control {
 	/* Destination page for migration which should be a first page
 	 * of zspage. */
 	struct page *d_page;
-	 /* Starting object index within @s_page which used for live object
-	  * in the subpage. */
+	/* Starting object index within @s_page which used for live object
+	 * in the subpage. */
 	int obj_idx;
+
+	unsigned long nr_migrated_obj;
+	unsigned long nr_freed_pages;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1806,6 +1809,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		free_obj = obj_malloc(class, get_zspage(d_page), handle);
 		zs_object_copy(class, free_obj, used_obj);
 		obj_idx++;
+		cc->nr_migrated_obj++;
 		/*
 		 * record_obj updates handle's value to free_obj and it will
 		 * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
@@ -2264,7 +2268,10 @@ static unsigned long zs_can_compact(struct size_class *class)
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
-	struct zs_compact_control cc;
+	struct zs_compact_control cc = {
+		.nr_migrated_obj = 0,
+		.nr_freed_pages = 0,
+	};
 	struct zspage *src_zspage;
 	struct zspage *dst_zspage = NULL;
 
@@ -2296,7 +2303,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, dst_zspage);
 		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
 			free_zspage(pool, class, src_zspage);
-			pool->stats.pages_compacted += class->pages_per_zspage;
+			cc.nr_freed_pages += class->pages_per_zspage;
 		}
 		spin_unlock(&class->lock);
 		cond_resched();
@@ -2307,6 +2314,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, src_zspage);
 
 	spin_unlock(&class->lock);
+
+	pool->stats.pages_compacted += cc.nr_freed_pages;
+	trace_zs_compact(class->index, cc.nr_migrated_obj, cc.nr_freed_pages);
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
@@ -2315,7 +2325,7 @@ unsigned long zs_compact(struct zs_pool *pool)
 	struct size_class *class;
 	unsigned long pages_compacted_before = pool->stats.pages_compacted;
 
-	trace_zsmalloc_compact_start(pool->name);
+	trace_zs_compact_start(pool->name);
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		class = pool->size_class[i];
@@ -2326,9 +2336,8 @@ unsigned long zs_compact(struct zs_pool *pool)
 		__zs_compact(pool, class);
 	}
 
-	trace_zsmalloc_compact_end(pool->name,
-		pool->stats.pages_compacted - pages_compacted_before,
-		pool->stats.pages_compacted);
+	trace_zs_compact_end(pool->name,
+		pool->stats.pages_compacted - pages_compacted_before);
 
 	return pool->stats.pages_compacted;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
