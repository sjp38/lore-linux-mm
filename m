Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5F9828E4
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 02:41:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so218493805pfb.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:41:50 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id h190si2481746pfb.251.2016.06.30.23.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 23:41:49 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hf6so9024750pac.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:41:49 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 2/8] mm/zsmalloc: add per class compact trace event
Date: Fri,  1 Jul 2016 14:41:00 +0800
Message-Id: <1467355266-9735-2-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

add per class compact trace event. It will show how many zs pages
isolated, how many zs pages reclaimed.

----
  <...>-627   [002] ....   192.641122: zs_compact_start: pool zram0
  <...>-627   [002] ....   192.641166: zs_compact_class: class 254: 0 zspage isolated, 0 reclaimed
  <...>-627   [002] ....   192.641169: zs_compact_class: class 202: 0 zspage isolated, 0 reclaimed
  <...>-627   [002] ....   192.641172: zs_compact_class: class 190: 0 zspage isolated, 0 reclaimed
  <...>-627   [002] ....   192.641180: zs_compact_class: class 168: 3 zspage isolated, 1 reclaimed
  <...>-627   [002] ....   192.641190: zs_compact_class: class 151: 3 zspage isolated, 1 reclaimed
  <...>-627   [002] ....   192.641201: zs_compact_class: class 144: 6 zspage isolated, 1 reclaimed
  <...>-627   [002] ....   192.641224: zs_compact_class: class 126: 24 zspage isolated, 12 reclaimed
  <...>-627   [002] ....   192.641261: zs_compact_class: class 111: 10 zspage isolated, 2 reclaimed
kswapd0-627   [002] ....   192.641333: zs_compact_class: class 107: 38 zspage isolated, 8 reclaimed
kswapd0-627   [002] ....   192.641415: zs_compact_class: class 100: 45 zspage isolated, 12 reclaimed
kswapd0-627   [002] ....   192.641481: zs_compact_class: class  94: 24 zspage isolated, 5 reclaimed
kswapd0-627   [002] ....   192.641568: zs_compact_class: class  91: 69 zspage isolated, 14 reclaimed
kswapd0-627   [002] ....   192.641688: zs_compact_class: class  83: 120 zspage isolated, 47 reclaimed
kswapd0-627   [002] ....   192.641765: zs_compact_class: class  76: 34 zspage isolated, 5 reclaimed
kswapd0-627   [002] ....   192.641832: zs_compact_class: class  74: 34 zspage isolated, 6 reclaimed
kswapd0-627   [002] ....   192.641958: zs_compact_class: class  71: 66 zspage isolated, 17 reclaimed
kswapd0-627   [002] ....   192.642000: zs_compact_class: class  67: 17 zspage isolated, 3 reclaimed
kswapd0-627   [002] ....   192.642063: zs_compact_class: class  66: 29 zspage isolated, 5 reclaimed
kswapd0-627   [002] ....   192.642113: zs_compact_class: class  62: 38 zspage isolated, 12 reclaimed
kswapd0-627   [002] ....   192.642143: zs_compact_class: class  58: 8 zspage isolated, 1 reclaimed
kswapd0-627   [002] ....   192.642176: zs_compact_class: class  57: 25 zspage isolated, 5 reclaimed
kswapd0-627   [002] ....   192.642184: zs_compact_class: class  54: 11 zspage isolated, 2 reclaimed
kswapd0-627   [002] ....   192.642191: zs_compact_class: class  52: 5 zspage isolated, 1 reclaimed
kswapd0-627   [002] ....   192.642201: zs_compact_class: class  51: 6 zspage isolated, 1 reclaimed
kswapd0-627   [002] ....   192.642211: zs_compact_class: class  49: 11 zspage isolated, 3 reclaimed
kswapd0-627   [002] ....   192.642216: zs_compact_class: class  46: 2 zspage isolated, 1 reclaimed
kswapd0-627   [002] ....   192.642218: zs_compact_class: class  44: 0 zspage isolated, 0 reclaimed
kswapd0-627   [002] ....   192.642221: zs_compact_class: class  43: 0 zspage isolated, 0 reclaimed
  ...
----

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 include/trace/events/zsmalloc.h | 24 ++++++++++++++++++++++++
 mm/zsmalloc.c                   | 16 +++++++++++++++-
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
index c7a39f4..e745246 100644
--- a/include/trace/events/zsmalloc.h
+++ b/include/trace/events/zsmalloc.h
@@ -46,6 +46,30 @@ TRACE_EVENT(zs_compact_end,
 		  __entry->pages_compacted)
 );
 
+TRACE_EVENT(zs_compact_class,
+
+	TP_PROTO(int class, unsigned long zspage_isolated, unsigned long zspage_reclaimed),
+
+	TP_ARGS(class, zspage_isolated, zspage_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(int, class)
+		__field(unsigned long, zspage_isolated)
+		__field(unsigned long, zspage_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->class = class;
+		__entry->zspage_isolated = zspage_isolated;
+		__entry->zspage_reclaimed = zspage_reclaimed;
+	),
+
+	TP_printk("class %3d: %ld zspage isolated, %ld zspage reclaimed",
+		  __entry->class,
+		  __entry->zspage_isolated,
+		  __entry->zspage_reclaimed)
+);
+
 #endif /* _TRACE_ZSMALLOC_H */
 
 /* This part must be outside protection */
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c7f79d5..405baa5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1780,6 +1780,11 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
+
+	/* zspage isolated */
+	unsigned long nr_isolated;
+	/* zspage reclaimed */
+	unsigned long nr_reclaimed;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -2272,7 +2277,10 @@ static unsigned long zs_can_compact(struct size_class *class)
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
-	struct zs_compact_control cc;
+	struct zs_compact_control cc = {
+		.nr_isolated = 0,
+		.nr_reclaimed = 0,
+	};
 	struct zspage *src_zspage;
 	struct zspage *dst_zspage = NULL;
 
@@ -2282,10 +2290,13 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		if (!zs_can_compact(class))
 			break;
 
+		cc.nr_isolated++;
+
 		cc.index = 0;
 		cc.s_page = get_first_page(src_zspage);
 
 		while ((dst_zspage = isolate_zspage(class, false))) {
+			cc.nr_isolated++;
 			cc.d_page = get_first_page(dst_zspage);
 			/*
 			 * If there is no more space in dst_page, resched
@@ -2304,6 +2315,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, dst_zspage);
 		if (putback_zspage(class, src_zspage) == ZS_EMPTY) {
 			free_zspage(pool, class, src_zspage);
+			cc.nr_reclaimed++;
 			pool->stats.pages_compacted += class->pages_per_zspage;
 		}
 		spin_unlock(&class->lock);
@@ -2315,6 +2327,8 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, src_zspage);
 
 	spin_unlock(&class->lock);
+
+	trace_zs_compact_class(class->index, cc.nr_isolated, cc.nr_reclaimed);
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
