Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9468B6B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 12:42:55 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so4220208pdj.14
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 09:42:55 -0700 (PDT)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id hb3si5541455pac.326.2013.10.25.09.42.53
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 09:42:54 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id e16so2118506qcx.20
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 09:42:52 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm: get rid of unnecessary overhead of trace_mm_page_alloc_extfrag()
Date: Fri, 25 Oct 2013 12:42:47 -0400
Message-Id: <1382719367-11537-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

In general, every tracepoint should be zero overhead if it is disabled.
However, trace_mm_page_alloc_extfrag() is one of exception. It evaluate
"new_type == start_migratetype" even if tracepoint is disabled.

However, the code can be moved into tracepoint's TP_fast_assign() and
TP_fast_assign exist exactly such purpose. This patch does it.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/trace/events/kmem.h |   10 ++++------
 mm/page_alloc.c             |    5 ++---
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index d0c6134..aece134 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -267,14 +267,12 @@ DEFINE_EVENT_PRINT(mm_page, mm_page_pcpu_drain,
 TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
-			int alloc_order, int fallback_order,
-			int alloc_migratetype, int fallback_migratetype,
-			int change_ownership),
+		int alloc_order, int fallback_order,
+		int alloc_migratetype, int fallback_migratetype, int new_migratetype),
 
 	TP_ARGS(page,
 		alloc_order, fallback_order,
-		alloc_migratetype, fallback_migratetype,
-		change_ownership),
+		alloc_migratetype, fallback_migratetype, new_migratetype),
 
 	TP_STRUCT__entry(
 		__field(	struct page *,	page			)
@@ -291,7 +289,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->fallback_order		= fallback_order;
 		__entry->alloc_migratetype	= alloc_migratetype;
 		__entry->fallback_migratetype	= fallback_migratetype;
-		__entry->change_ownership	= change_ownership;
+		__entry->change_ownership	= (new_migratetype == alloc_migratetype);
 	),
 
 	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4414c9d..58e67ea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1103,9 +1103,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			       is_migrate_cma(migratetype)
 			     ? migratetype : start_migratetype);
 
-			trace_mm_page_alloc_extfrag(page, order,
-				current_order, start_migratetype, migratetype,
-				new_type == start_migratetype);
+			trace_mm_page_alloc_extfrag(page, order, current_order,
+				start_migratetype, migratetype, new_type);
 
 			return page;
 		}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
