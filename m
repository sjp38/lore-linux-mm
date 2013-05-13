Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 02C876B0033
	for <linux-mm@kvack.org>; Mon, 13 May 2013 06:21:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: Add tracepoints for LRU activation and insertions
Date: Mon, 13 May 2013 11:21:19 +0100
Message-Id: <1368440482-27909-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1368440482-27909-1-git-send-email-mgorman@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

Using these tracepoints it is possible to model LRU activity and the
average residency of pages of different types. This can be used to
debug problems related to premature reclaim of pages of particular
types.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/pagemap.h | 89 ++++++++++++++++++++++++++++++++++++++++++
 mm/swap.c                      |  5 +++
 2 files changed, 94 insertions(+)
 create mode 100644 include/trace/events/pagemap.h

diff --git a/include/trace/events/pagemap.h b/include/trace/events/pagemap.h
new file mode 100644
index 0000000..1c9fabd
--- /dev/null
+++ b/include/trace/events/pagemap.h
@@ -0,0 +1,89 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM pagemap
+
+#if !defined(_TRACE_PAGEMAP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGEMAP_H
+
+#include <linux/tracepoint.h>
+#include <linux/mm.h>
+
+#define	PAGEMAP_MAPPED		0x0001u
+#define PAGEMAP_ANONYMOUS	0x0002u
+#define PAGEMAP_FILE		0x0004u
+#define PAGEMAP_SWAPCACHE	0x0008u
+#define PAGEMAP_SWAPBACKED	0x0010u
+#define PAGEMAP_MAPPEDDISK	0x0020u
+#define PAGEMAP_BUFFERS		0x0040u
+
+#define trace_pagemap_flags(page) ( \
+	(PageAnon(page)		? PAGEMAP_ANONYMOUS  : PAGEMAP_FILE) | \
+	(page_mapped(page)	? PAGEMAP_MAPPED     : 0) | \
+	(PageSwapCache(page)	? PAGEMAP_SWAPCACHE  : 0) | \
+	(PageSwapBacked(page)	? PAGEMAP_SWAPBACKED : 0) | \
+	(PageMappedToDisk(page)	? PAGEMAP_MAPPEDDISK : 0) | \
+	(page_has_private(page) ? PAGEMAP_BUFFERS    : 0) \
+	)
+
+TRACE_EVENT(mm_lru_insertion,
+
+	TP_PROTO(
+		struct page *page,
+		unsigned long pfn,
+		int lru,
+		unsigned long flags
+	),
+
+	TP_ARGS(page, pfn, lru, flags),
+
+	TP_STRUCT__entry(
+		__field(struct page *,	page	)
+		__field(unsigned long,	pfn	)
+		__field(int,		lru	)
+		__field(unsigned long,	flags	)
+	),
+
+	TP_fast_assign(
+		__entry->page	= page;
+		__entry->pfn	= pfn;
+		__entry->lru	= lru;
+		__entry->flags	= flags;
+	),
+
+	/* Flag format is based on page-types.c formatting for pagemap */
+	TP_printk("page=%p pfn=%lu lru=%d flags=%s%s%s%s%s%s",
+			__entry->page,
+			__entry->pfn,
+			__entry->lru,
+			__entry->flags & PAGEMAP_MAPPED		? "M" : " ",
+			__entry->flags & PAGEMAP_ANONYMOUS	? "a" : "f",
+			__entry->flags & PAGEMAP_SWAPCACHE	? "s" : " ",
+			__entry->flags & PAGEMAP_SWAPBACKED	? "b" : " ",
+			__entry->flags & PAGEMAP_MAPPEDDISK	? "d" : " ",
+			__entry->flags & PAGEMAP_BUFFERS	? "B" : " ")
+);
+
+TRACE_EVENT(mm_lru_activate,
+
+	TP_PROTO(struct page *page, unsigned long pfn),
+
+	TP_ARGS(page, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct page *,	page	)
+		__field(unsigned long,	pfn	)
+	),
+
+	TP_fast_assign(
+		__entry->page	= page;
+		__entry->pfn	= pfn;
+	),
+
+	/* Flag format is based on page-types.c formatting for pagemap */
+	TP_printk("page=%p pfn=%lu", __entry->page, __entry->pfn)
+
+);
+
+#endif /* _TRACE_PAGEMAP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/swap.c b/mm/swap.c
index 8a529a0..c612a6a 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -33,6 +33,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/pagemap.h>
+
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
@@ -383,6 +386,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(page, lruvec, lru);
+		trace_mm_lru_activate(page, page_to_pfn(page));
 
 		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(lruvec, file, 1);
@@ -802,6 +806,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 		SetPageActive(page);
 	add_page_to_lru_list(page, lruvec, lru);
 	update_page_reclaim_stat(lruvec, file, active);
+	trace_mm_lru_insertion(page, page_to_pfn(page), lru, trace_pagemap_flags(page));
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
