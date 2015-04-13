Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id F29276B006C
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 18:15:22 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so937728igb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 15:15:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id qf9si89524icb.62.2015.04.13.15.15.22
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 15:15:22 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 1/5] tracing, mm: Record pfn instead of pointer to struct page
Date: Mon, 13 Apr 2015 19:14:58 -0300
Message-Id: <1428963302-31538-2-git-send-email-acme@kernel.org>
In-Reply-To: <1428963302-31538-1-git-send-email-acme@kernel.org>
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

The struct page is opaque for userspace tools, so it'd be better to save
pfn in order to identify page frames.

The textual output of $debugfs/tracing/trace file remains unchanged and
only raw (binary) data format is changed - but thanks to libtraceevent,
userspace tools which deal with the raw data (like perf and trace-cmd)
can parse the format easily.  So impact on the userspace will also be
minimal.

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Based-on-patch-by: Joonsoo Kim <js1304@gmail.com>
Acked-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1428298576-9785-3-git-send-email-namhyung@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/trace/events/filemap.h |  8 ++++----
 include/trace/events/kmem.h    | 42 +++++++++++++++++++++---------------------
 include/trace/events/vmscan.h  |  8 ++++----
 3 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
index 0421f49a20f7..42febb6bc1d5 100644
--- a/include/trace/events/filemap.h
+++ b/include/trace/events/filemap.h
@@ -18,14 +18,14 @@ DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
 	TP_ARGS(page),
 
 	TP_STRUCT__entry(
-		__field(struct page *, page)
+		__field(unsigned long, pfn)
 		__field(unsigned long, i_ino)
 		__field(unsigned long, index)
 		__field(dev_t, s_dev)
 	),
 
 	TP_fast_assign(
-		__entry->page = page;
+		__entry->pfn = page_to_pfn(page);
 		__entry->i_ino = page->mapping->host->i_ino;
 		__entry->index = page->index;
 		if (page->mapping->host->i_sb)
@@ -37,8 +37,8 @@ DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
 	TP_printk("dev %d:%d ino %lx page=%p pfn=%lu ofs=%lu",
 		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
 		__entry->i_ino,
-		__entry->page,
-		page_to_pfn(__entry->page),
+		pfn_to_page(__entry->pfn),
+		__entry->pfn,
 		__entry->index << PAGE_SHIFT)
 );
 
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 4ad10baecd4d..81ea59812117 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -154,18 +154,18 @@ TRACE_EVENT(mm_page_free,
 	TP_ARGS(page, order),
 
 	TP_STRUCT__entry(
-		__field(	struct page *,	page		)
+		__field(	unsigned long,	pfn		)
 		__field(	unsigned int,	order		)
 	),
 
 	TP_fast_assign(
-		__entry->page		= page;
+		__entry->pfn		= page_to_pfn(page);
 		__entry->order		= order;
 	),
 
 	TP_printk("page=%p pfn=%lu order=%d",
-			__entry->page,
-			page_to_pfn(__entry->page),
+			pfn_to_page(__entry->pfn),
+			__entry->pfn,
 			__entry->order)
 );
 
@@ -176,18 +176,18 @@ TRACE_EVENT(mm_page_free_batched,
 	TP_ARGS(page, cold),
 
 	TP_STRUCT__entry(
-		__field(	struct page *,	page		)
+		__field(	unsigned long,	pfn		)
 		__field(	int,		cold		)
 	),
 
 	TP_fast_assign(
-		__entry->page		= page;
+		__entry->pfn		= page_to_pfn(page);
 		__entry->cold		= cold;
 	),
 
 	TP_printk("page=%p pfn=%lu order=0 cold=%d",
-			__entry->page,
-			page_to_pfn(__entry->page),
+			pfn_to_page(__entry->pfn),
+			__entry->pfn,
 			__entry->cold)
 );
 
@@ -199,22 +199,22 @@ TRACE_EVENT(mm_page_alloc,
 	TP_ARGS(page, order, gfp_flags, migratetype),
 
 	TP_STRUCT__entry(
-		__field(	struct page *,	page		)
+		__field(	unsigned long,	pfn		)
 		__field(	unsigned int,	order		)
 		__field(	gfp_t,		gfp_flags	)
 		__field(	int,		migratetype	)
 	),
 
 	TP_fast_assign(
-		__entry->page		= page;
+		__entry->pfn		= page ? page_to_pfn(page) : -1UL;
 		__entry->order		= order;
 		__entry->gfp_flags	= gfp_flags;
 		__entry->migratetype	= migratetype;
 	),
 
 	TP_printk("page=%p pfn=%lu order=%d migratetype=%d gfp_flags=%s",
-		__entry->page,
-		__entry->page ? page_to_pfn(__entry->page) : 0,
+		__entry->pfn != -1UL ? pfn_to_page(__entry->pfn) : NULL,
+		__entry->pfn != -1UL ? __entry->pfn : 0,
 		__entry->order,
 		__entry->migratetype,
 		show_gfp_flags(__entry->gfp_flags))
@@ -227,20 +227,20 @@ DECLARE_EVENT_CLASS(mm_page,
 	TP_ARGS(page, order, migratetype),
 
 	TP_STRUCT__entry(
-		__field(	struct page *,	page		)
+		__field(	unsigned long,	pfn		)
 		__field(	unsigned int,	order		)
 		__field(	int,		migratetype	)
 	),
 
 	TP_fast_assign(
-		__entry->page		= page;
+		__entry->pfn		= page ? page_to_pfn(page) : -1UL;
 		__entry->order		= order;
 		__entry->migratetype	= migratetype;
 	),
 
 	TP_printk("page=%p pfn=%lu order=%u migratetype=%d percpu_refill=%d",
-		__entry->page,
-		__entry->page ? page_to_pfn(__entry->page) : 0,
+		__entry->pfn != -1UL ? pfn_to_page(__entry->pfn) : NULL,
+		__entry->pfn != -1UL ? __entry->pfn : 0,
 		__entry->order,
 		__entry->migratetype,
 		__entry->order == 0)
@@ -260,7 +260,7 @@ DEFINE_EVENT_PRINT(mm_page, mm_page_pcpu_drain,
 	TP_ARGS(page, order, migratetype),
 
 	TP_printk("page=%p pfn=%lu order=%d migratetype=%d",
-		__entry->page, page_to_pfn(__entry->page),
+		pfn_to_page(__entry->pfn), __entry->pfn,
 		__entry->order, __entry->migratetype)
 );
 
@@ -275,7 +275,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		alloc_migratetype, fallback_migratetype),
 
 	TP_STRUCT__entry(
-		__field(	struct page *,	page			)
+		__field(	unsigned long,	pfn			)
 		__field(	int,		alloc_order		)
 		__field(	int,		fallback_order		)
 		__field(	int,		alloc_migratetype	)
@@ -284,7 +284,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 	),
 
 	TP_fast_assign(
-		__entry->page			= page;
+		__entry->pfn			= page_to_pfn(page);
 		__entry->alloc_order		= alloc_order;
 		__entry->fallback_order		= fallback_order;
 		__entry->alloc_migratetype	= alloc_migratetype;
@@ -294,8 +294,8 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 	),
 
 	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
-		__entry->page,
-		page_to_pfn(__entry->page),
+		pfn_to_page(__entry->pfn),
+		__entry->pfn,
 		__entry->alloc_order,
 		__entry->fallback_order,
 		pageblock_order,
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 69590b6ffc09..f66476b96264 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -336,18 +336,18 @@ TRACE_EVENT(mm_vmscan_writepage,
 	TP_ARGS(page, reclaim_flags),
 
 	TP_STRUCT__entry(
-		__field(struct page *, page)
+		__field(unsigned long, pfn)
 		__field(int, reclaim_flags)
 	),
 
 	TP_fast_assign(
-		__entry->page = page;
+		__entry->pfn = page_to_pfn(page);
 		__entry->reclaim_flags = reclaim_flags;
 	),
 
 	TP_printk("page=%p pfn=%lu flags=%s",
-		__entry->page,
-		page_to_pfn(__entry->page),
+		pfn_to_page(__entry->pfn),
+		__entry->pfn,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
