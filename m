From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618093042.7790.30669.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 7/7] Compact memory directly by a process when a high-order allocation fails
Date: Mon, 18 Jun 2007 10:30:42 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
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

 include/linux/compaction.h |   12 ++++
 include/linux/vmstat.h     |    1 
 mm/compaction.c            |  103 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |   21 ++++++++
 mm/vmstat.c                |    4 +
 5 files changed, 140 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/compaction.h linux-2.6.22-rc4-mm2-120_compact_direct/include/linux/compaction.h
--- linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/compaction.h	2007-06-15 16:29:08.000000000 +0100
+++ linux-2.6.22-rc4-mm2-120_compact_direct/include/linux/compaction.h	2007-06-15 16:29:20.000000000 +0100
@@ -1,15 +1,25 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
-/* Return values for compact_zone() */
+/* Return values for compact_zone() and try_to_compact_pages() */
 #define COMPACT_INCOMPLETE	0
 #define COMPACT_COMPLETE	1
+#define COMPACT_PARTIAL	2
 
 #ifdef CONFIG_MIGRATION
 
+extern int fragmentation_index(struct zone *zone, unsigned int target_order);
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 				struct file *file, void __user *buffer,
 				size_t *length, loff_t *ppos);
+extern unsigned long try_to_compact_pages(struct zone **zones,
+						int order, gfp_t gfp_mask);
 
+#else
+static inline unsigned long try_to_compact_pages(struct zone **zones,
+						int order, gfp_t gfp_mask)
+{
+	return COMPACT_COMPLETE;
+}
 #endif /* CONFIG_MIGRATION */
 #endif /* _LINUX_COMPACTION_H */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/vmstat.h linux-2.6.22-rc4-mm2-120_compact_direct/include/linux/vmstat.h
--- linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/vmstat.h	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-120_compact_direct/include/linux/vmstat.h	2007-06-15 16:29:20.000000000 +0100
@@ -37,6 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		COMPACTSTALL, COMPACTSUCCESS, COMPACTRACE,
 		NR_VM_EVENT_ITEMS
 };
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/compaction.c linux-2.6.22-rc4-mm2-120_compact_direct/mm/compaction.c
--- linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/compaction.c	2007-06-15 16:29:08.000000000 +0100
+++ linux-2.6.22-rc4-mm2-120_compact_direct/mm/compaction.c	2007-06-15 16:32:27.000000000 +0100
@@ -24,6 +24,8 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	int required_order;		/* order a direct compactor needs */
+	int mtype;			/* type of high-order page required */
 };
 
 static int release_freepages(struct zone *zone, struct list_head *freelist)
@@ -252,10 +254,29 @@ static void update_nr_listpages(struct c
 static inline int compact_finished(struct zone *zone,
 						struct compact_control *cc)
 {
+	int order;
+
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;
 
+	if (cc->required_order == -1)
+		return COMPACT_INCOMPLETE;
+
+	/* Check for page of the appropriate type when direct compacting */
+	for (order = cc->required_order; order < MAX_ORDER; order++) {
+		/*
+		 * If the current order is greater than pageblock_order, then
+		 * the block is eligible for allocation
+		 */
+		if (order >= pageblock_order && zone->free_area[order].nr_free)
+			return COMPACT_PARTIAL;
+
+		/* Otherwise use a page is free and of the right type */
+		if (!list_empty(&zone->free_area[order].free_list[cc->mtype]))
+			return COMPACT_PARTIAL;
+	}
+
 	return COMPACT_INCOMPLETE;
 }
 
@@ -298,6 +319,87 @@ static int compact_zone(struct zone *zon
 	return ret;
 }
 
+static inline unsigned long compact_zone_order(struct zone *zone,
+						int order, gfp_t gfp_mask)
+{
+	struct compact_control cc = {
+		.nr_freepages = 0,
+		.nr_migratepages = 0,
+		.required_order = order,
+		.mtype = allocflags_to_migratetype(gfp_mask),
+	};
+	INIT_LIST_HEAD(&cc.freepages);
+	INIT_LIST_HEAD(&cc.migratepages);
+
+	return compact_zone(zone, &cc);
+}
+
+/**
+ * try_to_compact_pages - Compact memory directly to satisfy a high-order allocation
+ * @zones: The zonelist used for the current allocation
+ * @order: The order of the current allocation
+ * @gfp_mask: The GFP mask of the current allocation
+ *
+ * This is the main entry point for direct page compaction.
+ *
+ * Returns 0 if compaction fails to free a page of the required size and type
+ * Returns non-zero on success
+ */
+unsigned long try_to_compact_pages(struct zone **zones,
+						int order, gfp_t gfp_mask)
+{
+	unsigned long watermark;
+	int may_enter_fs = gfp_mask & __GFP_FS;
+	int may_perform_io = gfp_mask & __GFP_IO;
+	int i;
+	int status = COMPACT_INCOMPLETE;
+
+	/* Check whether it is worth even starting compaction */
+	if (order == 0 || !may_enter_fs || !may_perform_io)
+		return status;
+
+	/* Flush pending updates to the LRU lists on the local CPU */
+	lru_add_drain();
+
+	/* Compact each zone in the list */
+	for (i = 0; zones[i] != NULL; i++) {
+		struct zone *zone = zones[i];
+		int fragindex;
+
+		/*
+		 * If watermarks are not met, compaction will not help.
+		 * Note that we check the watermarks at order-0 as we
+		 * are assuming some free pages will coalesce
+		 */
+		watermark = zone->pages_low + (1 << order);
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			continue;
+
+		/*
+		 * fragmentation index determines if allocation failures are
+		 * due to low memory or external fragmentation
+		 *
+		 * index of -1 implies allocations would succeed
+		 * index < 50 implies alloc failure is due to lack of memory
+		 */
+		fragindex = fragmentation_index(zone, order);
+		if (fragindex < 50)
+			continue;
+
+		status = compact_zone_order(zone, order, gfp_mask);
+		if (status == COMPACT_PARTIAL) {
+			count_vm_event(COMPACTSUCCESS);
+			break;
+		}
+	}
+
+	/* Account for it if we stalled due to compaction */
+	if (status != COMPACT_INCOMPLETE)
+		count_vm_event(COMPACTSTALL);
+
+	return status;
+}
+
 /* Compact all zones within a node */
 int compact_node(int nodeid)
 {
@@ -322,6 +424,7 @@ int compact_node(int nodeid)
 
 		cc.nr_freepages = 0;
 		cc.nr_migratepages = 0;
+		cc.required_order = -1;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/page_alloc.c linux-2.6.22-rc4-mm2-120_compact_direct/mm/page_alloc.c
--- linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/page_alloc.c	2007-06-15 16:28:59.000000000 +0100
+++ linux-2.6.22-rc4-mm2-120_compact_direct/mm/page_alloc.c	2007-06-15 16:29:20.000000000 +0100
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1670,6 +1671,26 @@ nofail_alloc:
 
 	cond_resched();
 
+	/* Try memory compaction for high-order allocations before reclaim */
+	if (order != 0) {
+		drain_all_local_pages();
+		did_some_progress = try_to_compact_pages(zonelist->zones,
+							order, gfp_mask);
+		if (did_some_progress == COMPACT_PARTIAL) {
+			page = get_page_from_freelist(gfp_mask, order,
+						zonelist, alloc_flags);
+
+			if (page)
+				goto got_pg;
+
+			/*
+			 * It's a race if compaction frees a suitable page but
+			 * someone else allocates it
+			 */
+			count_vm_event(COMPACTRACE);
+		}
+	}
+
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	p->flags |= PF_MEMALLOC;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/vmstat.c linux-2.6.22-rc4-mm2-120_compact_direct/mm/vmstat.c
--- linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/vmstat.c	2007-06-15 16:25:55.000000000 +0100
+++ linux-2.6.22-rc4-mm2-120_compact_direct/mm/vmstat.c	2007-06-15 16:29:20.000000000 +0100
@@ -882,6 +882,10 @@ static const char * const vmstat_text[] 
 	"allocstall",
 
 	"pgrotated",
+
+	"compact_stall",
+	"compact_success",
+	"compact_race",
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
