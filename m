Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 038EC6B0078
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:34 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 12so3429632pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:33 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 10/10] add inorder-lru tracepoints for just measurement
Date: Tue,  7 Jun 2011 23:38:23 +0900
Message-Id: <9a544a20fd54636003cc5ad9deec63e17530b3c2.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

This patch adds some tracepints for see the effect this patch
series. This tracepoints isn't for merge but just see the effect.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/trace/events/inorder_putback.h |   79 ++++++++++++++++++++++++++++++++
 mm/compaction.c                        |    2 +
 mm/migrate.c                           |    7 +++
 mm/vmscan.c                            |    3 +-
 4 files changed, 89 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/events/inorder_putback.h

diff --git a/include/trace/events/inorder_putback.h b/include/trace/events/inorder_putback.h
new file mode 100644
index 0000000..c615ed8
--- /dev/null
+++ b/include/trace/events/inorder_putback.h
@@ -0,0 +1,79 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM inorder_putback
+
+#if !defined(_TRACE_INP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_INP_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(mm_compaction_inorder,
+
+	TP_PROTO(struct page *page,
+		 struct page *newpage),
+
+	TP_ARGS(page, newpage),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(struct page *, newpage)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->newpage = newpage;
+	),
+
+	TP_printk("pfn=%lu new pfn=%lu",
+		page_to_pfn(__entry->page),
+		page_to_pfn(__entry->newpage))
+);
+
+TRACE_EVENT(mm_compaction_outoforder,
+
+	TP_PROTO(struct page *page,
+		 struct page *newpage),
+
+	TP_ARGS(page, newpage),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(struct page *, newpage)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->newpage = newpage;
+	),
+
+	TP_printk("pfn=%lu new pfn=%lu",
+		page_to_pfn(__entry->page),
+		page_to_pfn(__entry->newpage))
+);
+
+TRACE_EVENT(mm_compact_isolate,
+
+	TP_PROTO(struct page *prev_page,
+		struct page *page),
+
+	TP_ARGS(prev_page, page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, prev_page)
+		__field(struct page *, page)
+	),
+
+	TP_fast_assign(
+		__entry->prev_page = prev_page;
+		__entry->page = page;
+	),
+
+	TP_printk("pfn=%lu prev_pfn=%lu",
+		page_to_pfn(__entry->page),
+		page_to_pfn(__entry->prev_page))
+);
+
+#endif /* _TRACE_INP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/compaction.c b/mm/compaction.c
index 29e6aa9..1041251 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,6 +16,7 @@
 #include <linux/sysfs.h>
 #include "internal.h"
 
+#include <trace/events/inorder_putback.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
@@ -334,6 +335,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		if (__isolate_lru_page(page, mode, 0, &prev_page) != 0)
 			continue;
 
+		trace_mm_compact_isolate(prev_page, page);
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
diff --git a/mm/migrate.c b/mm/migrate.c
index a57f60b..2a8f713 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -39,6 +39,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/inorder_putback.h>
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -96,10 +99,12 @@ void putback_ilru_pages(struct inorder_lru *l)
 		spin_lock_irq(&zone->lru_lock);
 		prev = page->ilru.prev_page;
 		if (same_lru(page, prev)) {
+			trace_mm_compaction_inorder(page, page);
 			putback_page_to_lru(page, prev);
 			spin_unlock_irq(&zone->lru_lock);
 		}
 		else {
+			trace_mm_compaction_outoforder(page, page);
 			spin_unlock_irq(&zone->lru_lock);
 			putback_lru_page(page);
 		}
@@ -899,6 +904,7 @@ void __put_ilru_pages(struct page *page, struct page *newpage,
 	if (page && same_lru(page, prev_page)) {
 		putback_page_to_lru(newpage, prev_page);
 		spin_unlock_irq(&zone->lru_lock);
+		trace_mm_compaction_inorder(page, newpage);
 		/*
 		 * The newpage will replace LRU position of old page and
 		 * old one would be freed. So let's adjust prev_page of pages
@@ -909,6 +915,7 @@ void __put_ilru_pages(struct page *page, struct page *newpage,
 	}
 	else {
 		spin_unlock_irq(&zone->lru_lock);
+		trace_mm_compaction_inorder(page, newpage);
 		putback_lru_page(newpage);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7668e8d..5af1ba0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -49,10 +49,9 @@
 #include <linux/swapops.h>
 
 #include "internal.h"
-
+#include <trace/events/inorder_putback.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
-
 /*
  * reclaim_mode determines how the inactive list is shrunk
  * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
