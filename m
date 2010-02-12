Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 30ACA620015
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:05 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 08/12] Direct compact when a high-order allocation fails
Date: Fri, 12 Feb 2010 12:00:55 +0000
Message-Id: <1265976059-7459-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
---
 include/linux/compaction.h |   16 +++++-
 include/linux/vmstat.h     |    1 +
 mm/compaction.c            |  119 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |   26 ++++++++++
 mm/vmstat.c                |   16 +++++-
 5 files changed, 174 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 6a2eefd..1cf95e2 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,13 +1,25 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
-/* Return values for compact_zone() */
+/* Return values for compact_zone() and try_to_compact_pages() */
 #define COMPACT_INCOMPLETE	0
-#define COMPACT_COMPLETE	1
+#define COMPACT_PARTIAL		1
+#define COMPACT_COMPLETE	2
 
 #ifdef CONFIG_COMPACTION
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
index d7f7236..0ea7a38 100644
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
index f5bd5ed..2c88ca9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -29,6 +29,9 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+
+	unsigned int order;		/* order a direct compactor needs */
+	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
 };
 
@@ -282,10 +285,31 @@ static void update_nr_listpages(struct compact_control *cc)
 static inline int compact_finished(struct zone *zone,
 						struct compact_control *cc)
 {
+	unsigned int order;
+	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
+
 	/* Compaction run completes if the migrate and free scanner meet */
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
 
@@ -341,6 +365,101 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	return ret;
 }
 
+static inline unsigned long compact_zone_order(struct zone *zone,
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
+	int rc = COMPACT_INCOMPLETE;
+
+	/* Check whether it is worth even starting compaction */
+	if (order == 0 || !may_enter_fs || !may_perform_io)
+		return rc;
+
+	/*
+	 * We will not stall if the necessary conditions are not met for
+	 * migration but direct reclaim seems to account stalls similarly
+	 */
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
+		 * index < 500 implies alloc failure is due to lack of memory
+		 *
+		 * XXX: The choice of 500 is arbitrary. Reinvestigate
+		 *      appropriately to determine a sensible default.
+		 *      and what it means when watermarks are also taken
+		 *      into account. Consider making it a sysctl
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d57154..1910b8b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -49,6 +49,7 @@
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <linux/memory.h>
+#include <linux/compaction.h>
 #include <trace/events/kmem.h>
 
 #include <asm/tlbflush.h>
@@ -1728,6 +1729,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
+	/* Try memory compaction for high-order allocations before reclaim */
+	if (order) {
+		*did_some_progress = try_to_compact_pages(zonelist,
+						order, gfp_mask, nodemask);
+		if (*did_some_progress != COMPACT_INCOMPLETE) {
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
index f0930ae..8edbe38 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -500,7 +500,7 @@ static void fill_contig_page_info(struct zone *zone,
  * The value can be used to determine if page reclaim or compaction
  * should be used
  */
-int fragmentation_index(struct zone *zone,
+static int __fragmentation_index(struct zone *zone,
 				unsigned int order,
 				struct contig_page_info *info)
 {
@@ -522,6 +522,15 @@ int fragmentation_index(struct zone *zone,
 	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
 }
 
+/* Same as __fragmentation index but allocs contig_page_info on stack */
+int fragmentation_index(struct zone *zone, unsigned int order)
+{
+	struct contig_page_info info;
+
+	fill_contig_page_info(zone, order, &info);
+	return __fragmentation_index(zone, order, &info);
+}
+
 /*
  * Return an index indicating how much of the available free memory is
  * unusable for an allocation of the requested size.
@@ -558,7 +567,7 @@ static void pagetypeinfo_showfragmentation_print(struct seq_file *m,
 				zone->name, " ");
 	for (order = 0; order < MAX_ORDER; ++order) {
 		fill_contig_page_info(zone, order, &info);
-		seq_printf(m, "%6d ", fragmentation_index(zone, order, &info));
+		seq_printf(m, "%6d ", __fragmentation_index(zone, order, &info));
 	}
 
 	seq_putc(m, '\n');
@@ -856,6 +865,9 @@ static const char * const vmstat_text[] = {
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
