Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD586B0070
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 02:40:46 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so15882966pad.9
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 23:40:46 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id zd8si985828pac.24.2015.01.14.23.40.40
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 23:40:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 3/5] mm/compaction: print current range where compaction work
Date: Thu, 15 Jan 2015 16:41:11 +0900
Message-Id: <1421307673-24084-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It'd be useful to know current range where compaction work for detailed
analysis. With it, we can know pageblock where we actually scan and
isolate, and, how much pages we try in that pageblock and can guess why
it doesn't become freepage with pageblock order roughly.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/compaction.h |   30 +++++++++++++++++++++++-------
 mm/compaction.c                   |    9 ++++++---
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 839f6fa..139020b 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -11,39 +11,55 @@
 
 DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
 
-	TP_PROTO(unsigned long nr_scanned,
+	TP_PROTO(
+		unsigned long start_pfn,
+		unsigned long end_pfn,
+		unsigned long nr_scanned,
 		unsigned long nr_taken),
 
-	TP_ARGS(nr_scanned, nr_taken),
+	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken),
 
 	TP_STRUCT__entry(
+		__field(unsigned long, start_pfn)
+		__field(unsigned long, end_pfn)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_taken)
 	),
 
 	TP_fast_assign(
+		__entry->start_pfn = start_pfn;
+		__entry->end_pfn = end_pfn;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_taken = nr_taken;
 	),
 
-	TP_printk("nr_scanned=%lu nr_taken=%lu",
+	TP_printk("range=(0x%lx ~ 0x%lx) nr_scanned=%lu nr_taken=%lu",
+		__entry->start_pfn,
+		__entry->end_pfn,
 		__entry->nr_scanned,
 		__entry->nr_taken)
 );
 
 DEFINE_EVENT(mm_compaction_isolate_template, mm_compaction_isolate_migratepages,
 
-	TP_PROTO(unsigned long nr_scanned,
+	TP_PROTO(
+		unsigned long start_pfn,
+		unsigned long end_pfn,
+		unsigned long nr_scanned,
 		unsigned long nr_taken),
 
-	TP_ARGS(nr_scanned, nr_taken)
+	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
 );
 
 DEFINE_EVENT(mm_compaction_isolate_template, mm_compaction_isolate_freepages,
-	TP_PROTO(unsigned long nr_scanned,
+
+	TP_PROTO(
+		unsigned long start_pfn,
+		unsigned long end_pfn,
+		unsigned long nr_scanned,
 		unsigned long nr_taken),
 
-	TP_ARGS(nr_scanned, nr_taken)
+	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
 );
 
 TRACE_EVENT(mm_compaction_migratepages,
diff --git a/mm/compaction.c b/mm/compaction.c
index 2d86a20..be28469 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -429,11 +429,12 @@ isolate_fail:
 
 	}
 
+	trace_mm_compaction_isolate_freepages(*start_pfn, blockpfn,
+					nr_scanned, total_isolated);
+
 	/* Record how far we have got within the block */
 	*start_pfn = blockpfn;
 
-	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
-
 	/*
 	 * If strict isolation is requested by CMA then check that all the
 	 * pages requested were isolated. If there were any failures, 0 is
@@ -589,6 +590,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long flags = 0;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
+	unsigned long start_pfn = low_pfn;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -749,7 +751,8 @@ isolate_success:
 	if (low_pfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
-	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
+	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
+						nr_scanned, nr_isolated);
 
 	count_compact_events(COMPACTMIGRATE_SCANNED, nr_scanned);
 	if (nr_isolated)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
