Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 514716B00EB
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:56:44 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 8so2795700iyl.14
        for <linux-mm@kvack.org>; Thu, 30 Jun 2011 07:56:43 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 09/10] add inorder-lru tracepoints for just measurement
Date: Thu, 30 Jun 2011 23:55:19 +0900
Message-Id: <8186f779cbfa1fbd83420549b4fc25cc9cb71a69.1309444658.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309444657.git.minchan.kim@gmail.com>
References: <cover.1309444657.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309444657.git.minchan.kim@gmail.com>
References: <cover.1309444657.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>

This patch adds some tracepints for see the effect this patch
series. This tracepoints isn't for merge but just see the effect.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/trace/events/inorder_putback.h |   88 ++++++++++++++++++++++++++++++++
 mm/migrate.c                           |    3 +
 mm/swap.c                              |    3 +
 mm/vmscan.c                            |    4 +-
 4 files changed, 96 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/events/inorder_putback.h

diff --git a/include/trace/events/inorder_putback.h b/include/trace/events/inorder_putback.h
new file mode 100644
index 0000000..fe81742
--- /dev/null
+++ b/include/trace/events/inorder_putback.h
@@ -0,0 +1,88 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM inorder_putback
+
+#if !defined(_TRACE_INP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_INP_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(mm_inorder_inorder,
+
+	TP_PROTO(struct page *page,
+		 struct page *old_page,
+		 struct page *prev_page),
+
+	TP_ARGS(page, old_page, prev_page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(struct page *, old_page)
+		__field(struct page *, prev_page)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->old_page = old_page;
+		__entry->prev_page = prev_page;
+	),
+
+	TP_printk("pfn=%lu old pfn=%lu prev_pfn=%lu active=%d",
+		page_to_pfn(__entry->page),
+		page_to_pfn(__entry->old_page),
+		page_to_pfn(__entry->prev_page),
+		PageActive(__entry->prev_page))
+);
+
+TRACE_EVENT(mm_inorder_outoforder,
+	TP_PROTO(struct page *page,
+		 struct page *old_page,
+		 struct page *prev_page),
+
+	TP_ARGS(page, old_page, prev_page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(struct page *, old_page)
+		__field(struct page *, prev_page)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->old_page = old_page;
+		__entry->prev_page = prev_page;
+	),
+
+	TP_printk("pfn=%lu old pfn=%lu prev_pfn=%lu active=%d",
+		page_to_pfn(__entry->page),
+		page_to_pfn(__entry->old_page),
+		__entry->prev_page ? page_to_pfn(__entry->prev_page) : 0,
+		__entry->prev_page ? PageActive(__entry->prev_page) : 0)
+);
+
+TRACE_EVENT(mm_inorder_isolate,
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
+	TP_printk("prev_pfn=%lu pfn=%lu active=%d",
+		page_to_pfn(__entry->prev_page),
+		page_to_pfn(__entry->page), PageActive(__entry->prev_page))
+);
+
+#endif /* _TRACE_INP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/migrate.c b/mm/migrate.c
index cf73477..1267c45 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -39,6 +39,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/inorder_putback.h>
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
diff --git a/mm/swap.c b/mm/swap.c
index 611013d..f2ccf81 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -32,6 +32,7 @@
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 
+#include <trace/events/inorder_putback.h>
 #include "internal.h"
 
 /* How many pages do we try to swap or page in/out together? */
@@ -846,12 +847,14 @@ static void ____pagevec_ilru_add_fn(struct page *page, void *arg, int idx)
 		 */
 		adjust_ilru_list(lru, old_page, page, idx);
 		__add_page_to_lru_list(zone, page, lru, &prev_page->lru);
+		trace_mm_inorder_inorder(page, old_page, prev_page);
 	} else {
 		file = is_file_lru(lru);
 		active = is_active_lru(lru);
 		if (active)
 			SetPageActive(page);
 		add_page_to_lru_list(zone, page, lru);
+		trace_mm_inorder_outoforder(page, old_page, prev_page);
 	}
 
 	update_page_reclaim_stat(zone, page, file, active);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f0e7789..eb26f03 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -50,10 +50,9 @@
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
@@ -1055,6 +1054,7 @@ int isolate_ilru_page(struct page *page, isolate_mode_t mode, int file,
 		}
 
 		*prev_page = lru_to_page(&page->lru);
+		trace_mm_inorder_isolate(*prev_page, page);
 	}
 
 	return ret;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
