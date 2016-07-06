Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14FC2828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:26:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so492834612pfx.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:55 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id wk4si2621034pab.65.2016.07.05.23.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:26:54 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so20990423pfb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:54 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3 8/8] mm/zsmalloc: add per-class compact trace event
Date: Wed,  6 Jul 2016 14:23:53 +0800
Message-Id: <1467786233-4481-8-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

add per-class compact trace event to get scanned objects and freed pages
number.
trace log is like below:
----
         kswapd0-629   [001] ....   293.161053: zs_compact_start: pool zram0
         kswapd0-629   [001] ....   293.161056: zs_compact: class 254: 0 objects scanned, 0 pages freed
         kswapd0-629   [001] ....   293.161057: zs_compact: class 202: 0 objects scanned, 0 pages freed
         kswapd0-629   [001] ....   293.161062: zs_compact: class 190: 1 objects scanned, 3 pages freed
         kswapd0-629   [001] ....   293.161063: zs_compact: class 168: 0 objects scanned, 0 pages freed
         kswapd0-629   [001] ....   293.161065: zs_compact: class 151: 0 objects scanned, 0 pages freed
         kswapd0-629   [001] ....   293.161073: zs_compact: class 144: 4 objects scanned, 8 pages freed
         kswapd0-629   [001] ....   293.161087: zs_compact: class 126: 20 objects scanned, 10 pages freed
         kswapd0-629   [001] ....   293.161095: zs_compact: class 111: 6 objects scanned, 8 pages freed
         kswapd0-629   [001] ....   293.161122: zs_compact: class 107: 27 objects scanned, 27 pages freed
         kswapd0-629   [001] ....   293.161157: zs_compact: class 100: 36 objects scanned, 24 pages freed
         kswapd0-629   [001] ....   293.161173: zs_compact: class  94: 10 objects scanned, 15 pages freed
         kswapd0-629   [001] ....   293.161221: zs_compact: class  91: 30 objects scanned, 40 pages freed
         kswapd0-629   [001] ....   293.161256: zs_compact: class  83: 120 objects scanned, 30 pages freed
         kswapd0-629   [001] ....   293.161266: zs_compact: class  76: 8 objects scanned, 8 pages freed
         kswapd0-629   [001] ....   293.161282: zs_compact: class  74: 20 objects scanned, 15 pages freed
         kswapd0-629   [001] ....   293.161306: zs_compact: class  71: 40 objects scanned, 20 pages freed
         kswapd0-629   [001] ....   293.161313: zs_compact: class  67: 8 objects scanned, 6 pages freed
...
         kswapd0-629   [001] ....   293.161454: zs_compact: class   0: 0 objects scanned, 0 pages freed
         kswapd0-629   [001] ....   293.161455: zs_compact_end: pool zram0: 301 pages compacted
----

Also this patch changes trace_zsmalloc_compact_start[end] to
trace_zs_compact_start[end] to keep function naming consistent
with others in zsmalloc.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v3:
    add per-class compact trace event - Minchan

    I put this patch from 1/8 to 8/8, since this patch depends on below patch:
       mm/zsmalloc: use obj_index to keep consistent with others
       mm/zsmalloc: take obj index back from find_alloced_obj

v2:
    update commit description
---
 include/trace/events/zsmalloc.h | 40 ++++++++++++++++++++++++++++++----------
 mm/zsmalloc.c                   | 26 ++++++++++++++++++--------
 2 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
index 3b6f14e..96fcca8 100644
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
+	TP_PROTO(int class, unsigned long nr_scanned_obj, unsigned long nr_freed_pages),
+
+	TP_ARGS(class, nr_scanned_obj, nr_freed_pages),
+
+	TP_STRUCT__entry(
+		__field(int, class)
+		__field(unsigned long, nr_scanned_obj)
+		__field(unsigned long, nr_freed_pages)
+	),
+
+	TP_fast_assign(
+		__entry->class = class;
+		__entry->nr_scanned_obj = nr_scanned_obj;
+		__entry->nr_freed_pages = nr_freed_pages;
+	),
+
+	TP_printk("class %3d: %ld objects scanned, %ld pages freed",
+		  __entry->class,
+		  __entry->nr_scanned_obj,
+		  __entry->nr_freed_pages)
 );
 
 #endif /* _TRACE_ZSMALLOC_H */
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 17d3f53..3a1315e 100644
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
+	unsigned long nr_scanned_obj;
+	unsigned long nr_freed_pages;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1818,6 +1821,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		obj_free(class, used_obj);
 	}
 
+	cc->nr_scanned_obj += obj_idx - cc->obj_idx;
+
 	/* Remember last position in this iteration */
 	cc->s_page = s_page;
 	cc->obj_idx = obj_idx;
@@ -2264,7 +2269,10 @@ static unsigned long zs_can_compact(struct size_class *class)
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
-	struct zs_compact_control cc;
+	struct zs_compact_control cc = {
+		.nr_scanned_obj = 0,
+		.nr_freed_pages = 0,
+	};
 	struct zspage *src_zspage;
 	struct zspage *dst_zspage = NULL;
 
@@ -2296,7 +2304,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, dst_zspage);
 		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
 			free_zspage(pool, class, src_zspage);
-			pool->stats.pages_compacted += class->pages_per_zspage;
+			cc.nr_freed_pages += class->pages_per_zspage;
 		}
 		spin_unlock(&class->lock);
 		cond_resched();
@@ -2307,6 +2315,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, src_zspage);
 
 	spin_unlock(&class->lock);
+
+	pool->stats.pages_compacted += cc.nr_freed_pages;
+	trace_zs_compact(class->index, cc.nr_scanned_obj, cc.nr_freed_pages);
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
@@ -2315,7 +2326,7 @@ unsigned long zs_compact(struct zs_pool *pool)
 	struct size_class *class;
 	unsigned long pages_compacted_before = pool->stats.pages_compacted;
 
-	trace_zsmalloc_compact_start(pool->name);
+	trace_zs_compact_start(pool->name);
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		class = pool->size_class[i];
@@ -2326,9 +2337,8 @@ unsigned long zs_compact(struct zs_pool *pool)
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
