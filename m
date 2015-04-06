Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 811436B006E
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 01:37:25 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so34317525pdb.0
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:25 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id d9si5030835pat.84.2015.04.05.22.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Apr 2015 22:37:24 -0700 (PDT)
Received: by pddn5 with SMTP id n5so34208060pdd.2
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:24 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 2/9] tracing, mm: Record pfn instead of pointer to struct page
Date: Mon,  6 Apr 2015 14:36:09 +0900
Message-Id: <1428298576-9785-3-git-send-email-namhyung@kernel.org>
In-Reply-To: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

The struct page is opaque for userspace tools, so it'd be better to save
pfn in order to identify page frames.

The textual output of $debugfs/tracing/trace file remains unchanged and
only raw (binary) data format is changed - but thanks to libtraceevent,
userspace tools which deal with the raw data (like perf and trace-cmd)
can parse the format easily.  So impact on the userspace will also be
minimal.

Based-on-patch-by: Joonsoo Kim <js1304@gmail.com>
Acked-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
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
2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
