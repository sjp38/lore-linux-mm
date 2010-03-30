Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02F8F6B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:14:57 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 11/14] Direct compact when a high-order allocation fails
Date: Tue, 30 Mar 2010 10:14:46 +0100
Message-Id: <1269940489-5776-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ordinarily when a high-order allocation fails, direct reclaim is entered to
free pages to satisfy the allocation.  With this patch, it is determined if
an allocation failed due to external fragmentation instead of low memory
and if so, the calling process will compact until a suitable page is
freed. Compaction by moving pages in memory is considerably cheaper than
paging out to disk and works where there are locked pages or no swap. If
compaction fails to free a page of a suitable size, then reclaim will
still occur.

Direct compaction returns as soon as possible. As each block is compacted,
it is checked if a suitable page has been freed and if so, it returns.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/compaction.h |   20 ++++++--
 include/linux/vmstat.h     |    1 +
 mm/compaction.c            |  117 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |   31 ++++++++++++
 mm/vmstat.c                |   15 +++++-
 5 files changed, 178 insertions(+), 6 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index c4ab05f..faa3faf 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,15 +1,27 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
-/* Return values for compact_zone() */
-#define COMPACT_INCOMPLETE	0
-#define COMPACT_PARTIAL		1
-#define COMPACT_COMPLETE	2
+/* Return values for compact_zone() and try_to_compact_pages() */
+#define COMPACT_SKIPPED		0
+#define COMPACT_INCOMPLETE	1
+#define COMPACT_PARTIAL		2
+#define COMPACT_COMPLETE	3
 
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
+
+extern int fragmentation_index(struct zone *zone, unsigned int order);
+extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
+			int order, gfp_t gfp_mask, nodemask_t *mask);
+#else
+static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
+			int order, gfp_t gfp_mask, nodemask_t *nodemask)
+{
+	return COMPACT_INCOMPLETE;
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 56e4b44..b4b4d34 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -44,6 +44,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
+		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index b058bae..e8ef511 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -35,6 +35,8 @@ struct compact_control {
 	unsigned long nr_anon;
 	unsigned long nr_file;
 
+	unsigned int order;		/* order a direct compactor needs */
+	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
 };
 
@@ -327,6 +329,9 @@ static void update_nr_listpages(struct compact_control *cc)
 static int compact_finished(struct zone *zone,
 						struct compact_control *cc)
 {
+	unsigned int order;
+	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
+
 	if (fatal_signal_pending(current))
 		return COMPACT_PARTIAL;
 
@@ -334,6 +339,24 @@ static int compact_finished(struct zone *zone,
 	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;
 
+	/* Compaction run is not finished if the watermark is not met */
+	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
+		return COMPACT_INCOMPLETE;
+
+	if (cc->order == -1)
+		return COMPACT_INCOMPLETE;
+
+	/* Direct compactor: Is a suitable page free? */
+	for (order = cc->order; order < MAX_ORDER; order++) {
+		/* Job done if page is free of the right migratetype */
+		if (!list_empty(&zone->free_area[order].free_list[cc->migratetype]))
+			return COMPACT_PARTIAL;
+
+		/* Job done if allocation would set block type */
+		if (order >= pageblock_order && zone->free_area[order].nr_free)
+			return COMPACT_PARTIAL;
+	}
+
 	return COMPACT_INCOMPLETE;
 }
 
@@ -379,6 +402,99 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	return ret;
 }
 
+static unsigned long compact_zone_order(struct zone *zone,
+						int order, gfp_t gfp_mask)
+{
+	struct compact_control cc = {
+		.nr_freepages = 0,
+		.nr_migratepages = 0,
+		.order = order,
+		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.zone = zone,
+	};
+	INIT_LIST_HEAD(&cc.freepages);
+	INIT_LIST_HEAD(&cc.migratepages);
+
+	return compact_zone(zone, &cc);
+}
+
+/**
+ * try_to_compact_pages - Direct compact to satisfy a high-order allocation
+ * @zonelist: The zonelist used for the current allocation
+ * @order: The order of the current allocation
+ * @gfp_mask: The GFP mask of the current allocation
+ * @nodemask: The allowed nodes to allocate from
+ *
+ * This is the main entry point for direct page compaction.
+ */
+unsigned long try_to_compact_pages(struct zonelist *zonelist,
+			int order, gfp_t gfp_mask, nodemask_t *nodemask)
+{
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	int may_enter_fs = gfp_mask & __GFP_FS;
+	int may_perform_io = gfp_mask & __GFP_IO;
+	unsigned long watermark;
+	struct zoneref *z;
+	struct zone *zone;
+	int rc = COMPACT_SKIPPED;
+
+	/*
+	 * Check whether it is worth even starting compaction. The order check is
+	 * made because an assumption is made that the page allocator can satisfy
+	 * the "cheaper" orders without taking special steps
+	 */
+	if (order <= PAGE_ALLOC_COSTLY_ORDER || !may_enter_fs || !may_perform_io)
+		return rc;
+
+	count_vm_event(COMPACTSTALL);
+
+	/* Compact each zone in the list */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
+								nodemask) {
+		int fragindex;
+		int status;
+
+		/*
+		 * Watermarks for order-0 must be met for compaction. Note
+		 * the 2UL. This is because during migration, copies of
+		 * pages need to be allocated and for a short time, the
+		 * footprint is higher
+		 */
+		watermark = low_wmark_pages(zone) + (2UL << order);
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			continue;
+
+		/*
+		 * fragmentation index determines if allocation failures are
+		 * due to low memory or external fragmentation
+		 *
+		 * index of -1 implies allocations might succeed depending
+		 * 	on watermarks
+		 * index towards 0 implies failure is due to lack of memory
+		 * index towards 1000 implies failure is due to fragmentation
+		 *
+		 * Only compact if a failure would be due to fragmentation.
+		 */
+		fragindex = fragmentation_index(zone, order);
+		if (fragindex >= 0 && fragindex <= 500)
+			continue;
+
+		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
+			rc = COMPACT_PARTIAL;
+			break;
+		}
+
+		status = compact_zone_order(zone, order, gfp_mask);
+		rc = max(status, rc);
+
+		if (zone_watermark_ok(zone, order, watermark, 0, 0))
+			break;
+	}
+
+	return rc;
+}
+
+
 /* Compact all zones within a node */
 static int compact_node(int nid)
 {
@@ -403,6 +519,7 @@ static int compact_node(int nid)
 		cc.nr_freepages = 0;
 		cc.nr_migratepages = 0;
 		cc.zone = zone;
+		cc.order = -1;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3cf947d..7a2e4a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -49,6 +49,7 @@
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <linux/memory.h>
+#include <linux/compaction.h>
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
 
@@ -1768,6 +1769,36 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
+	/* Try memory compaction for high-order allocations before reclaim */
+	if (order) {
+		*did_some_progress = try_to_compact_pages(zonelist,
+						order, gfp_mask, nodemask);
+		if (*did_some_progress != COMPACT_SKIPPED) {
+
+			/* Page migration frees to the PCP lists but we want merging */
+			drain_pages(get_cpu());
+			put_cpu();
+
+			page = get_page_from_freelist(gfp_mask, nodemask,
+					order, zonelist, high_zoneidx,
+					alloc_flags, preferred_zone,
+					migratetype);
+			if (page) {
+				__count_vm_event(COMPACTSUCCESS);
+				return page;
+			}
+
+			/*
+			 * It's bad if compaction run occurs and fails.
+			 * The most likely reason is that pages exist,
+			 * but not enough to satisfy watermarks.
+			 */
+			count_vm_event(COMPACTFAIL);
+
+			cond_resched();
+		}
+	}
+
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	p->flags |= PF_MEMALLOC;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3a69b48..2780a36 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -561,7 +561,7 @@ static int unusable_show(struct seq_file *m, void *arg)
  * The value can be used to determine if page reclaim or compaction
  * should be used
  */
-int fragmentation_index(unsigned int order, struct contig_page_info *info)
+int __fragmentation_index(unsigned int order, struct contig_page_info *info)
 {
 	unsigned long requested = 1UL << order;
 
@@ -581,6 +581,14 @@ int fragmentation_index(unsigned int order, struct contig_page_info *info)
 	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
 }
 
+/* Same as __fragmentation index but allocs contig_page_info on stack */
+int fragmentation_index(struct zone *zone, unsigned int order)
+{
+	struct contig_page_info info;
+
+	fill_contig_page_info(zone, order, &info);
+	return __fragmentation_index(order, &info);
+}
 
 static void extfrag_show_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
@@ -596,7 +604,7 @@ static void extfrag_show_print(struct seq_file *m,
 				zone->name);
 	for (order = 0; order < MAX_ORDER; ++order) {
 		fill_contig_page_info(zone, order, &info);
-		index = fragmentation_index(order, &info);
+		index = __fragmentation_index(order, &info);
 		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
 	}
 
@@ -896,6 +904,9 @@ static const char * const vmstat_text[] = {
 	"compact_blocks_moved",
 	"compact_pages_moved",
 	"compact_pagemigrate_failed",
+	"compact_stall",
+	"compact_fail",
+	"compact_success",
 
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
