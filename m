Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A036C6B0087
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:44:00 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/7] mm: compaction: Add trace events for memory compaction activity
Date: Mon, 22 Nov 2010 15:43:49 +0000
Message-Id: <1290440635-30071-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In preparation for a patches promoting the use of memory compaction over lumpy
reclaim, this patch adds trace points for memory compaction activity. Using
them, we can monitor the scanning activity of the migration and free page
scanners as well as the number and success rates of pages passed to page
migration.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/compaction.h |   74 +++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |   14 ++++++-
 2 files changed, 87 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/compaction.h

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
new file mode 100644
index 0000000..388bcdd
--- /dev/null
+++ b/include/trace/events/compaction.h
@@ -0,0 +1,74 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM compaction
+
+#if !defined(_TRACE_COMPACTION_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_COMPACTION_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+#include "gfpflags.h"
+
+DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
+
+	TP_PROTO(unsigned long nr_scanned,
+		unsigned long nr_taken),
+
+	TP_ARGS(nr_scanned, nr_taken),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_taken)
+	),
+
+	TP_fast_assign(
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_taken = nr_taken;
+	),
+
+	TP_printk("nr_scanned=%lu nr_taken=%lu",
+		__entry->nr_scanned,
+		__entry->nr_taken)
+);
+
+DEFINE_EVENT(mm_compaction_isolate_template, mm_compaction_isolate_migratepages,
+
+	TP_PROTO(unsigned long nr_scanned,
+		unsigned long nr_taken),
+
+	TP_ARGS(nr_scanned, nr_taken)
+);
+
+DEFINE_EVENT(mm_compaction_isolate_template, mm_compaction_isolate_freepages,
+	TP_PROTO(unsigned long nr_scanned,
+		unsigned long nr_taken),
+
+	TP_ARGS(nr_scanned, nr_taken)
+);
+
+TRACE_EVENT(mm_compaction_migratepages,
+
+	TP_PROTO(unsigned long nr_migrated,
+		unsigned long nr_failed),
+
+	TP_ARGS(nr_migrated, nr_failed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, nr_migrated)
+		__field(unsigned long, nr_failed)
+	),
+
+	TP_fast_assign(
+		__entry->nr_migrated = nr_migrated;
+		__entry->nr_failed = nr_failed;
+	),
+
+	TP_printk("nr_migrated=%lu nr_failed=%lu",
+		__entry->nr_migrated,
+		__entry->nr_failed)
+);
+
+
+#endif /* _TRACE_COMPACTION_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/compaction.c b/mm/compaction.c
index 4d709ee..bc8eb8a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,6 +16,9 @@
 #include <linux/sysfs.h>
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/compaction.h>
+
 /*
  * compact_control is used to track pages being migrated and the free pages
  * they are being migrated to during memory compaction. The free_pfn starts
@@ -60,7 +63,7 @@ static unsigned long isolate_freepages_block(struct zone *zone,
 				struct list_head *freelist)
 {
 	unsigned long zone_end_pfn, end_pfn;
-	int total_isolated = 0;
+	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor;
 
 	/* Get the last PFN we should scan for free pages at */
@@ -81,6 +84,7 @@ static unsigned long isolate_freepages_block(struct zone *zone,
 
 		if (!pfn_valid_within(blockpfn))
 			continue;
+		nr_scanned++;
 
 		if (!PageBuddy(page))
 			continue;
@@ -100,6 +104,7 @@ static unsigned long isolate_freepages_block(struct zone *zone,
 		}
 	}
 
+	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
 	return total_isolated;
 }
 
@@ -234,6 +239,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
+	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 
 	/* Do not scan outside zone boundaries */
@@ -266,6 +272,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		struct page *page;
 		if (!pfn_valid_within(low_pfn))
 			continue;
+		nr_scanned++;
 
 		/* Get the page and skip if free */
 		page = pfn_to_page(low_pfn);
@@ -281,6 +288,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		list_add(&page->lru, migratelist);
 		mem_cgroup_del_lru(page);
 		cc->nr_migratepages++;
+		nr_isolated++;
 
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
@@ -292,6 +300,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
 	cc->migrate_pfn = low_pfn;
 
+	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
+
 	return cc->nr_migratepages;
 }
 
@@ -402,6 +412,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
 		if (nr_remaining)
 			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
+		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
+						nr_remaining);
 
 		/* Release LRU pages not migrated */
 		if (!list_empty(&cc->migratepages)) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
