Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 05FD06B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:58:07 -0500 (EST)
Subject: [PATCH] mm page reclaim tracepoints update
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-F7f8NDzw0klAB0WaFWJd"
Date: Fri, 13 Nov 2009 14:00:54 -0500
Message-Id: <1258138854.3227.79.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--=-F7f8NDzw0klAB0WaFWJd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I've broken the mm tracepoint up into functional and more useful groups.
This group consists of page reclamation tracepoints, all within vmscan.c
In addition, I moved to TRACE_EVENT definitions in
include/trace/events/kmem.h like the other mm tracepoints rather than
creating a new header file.

1.) mm_kswapd_ran: This tracepoint records how many pages were
reclaimed from kswapd on a per node basis.

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <...>-626   [005]   142.943401: mm_kswapd_ran: node=1
reclaimed=1273
           <...>-626   [005]   143.159882: mm_kswapd_ran: node=1
reclaimed=2473
           <...>-626   [005]   143.226377: mm_kswapd_ran: node=1
reclaimed=4675
           <...>-626   [005]   143.473898: mm_kswapd_ran: node=1
reclaimed=24056
           <...>-625   [000]   151.428285: mm_kswapd_ran: node=0
reclaimed=55816


2.) mm_pagereclaim_reclaimall: This tracepoint records how many pages
were reclaimed due to direct reclaim occurring out of the memory
allocator, on each node and the priority achieved.

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
          memory-9974  [000]   213.795877: mm_directreclaim_reclaimall:
node=0 reclaimed=42 priority=11
          memory-9974  [004]   214.134956: mm_directreclaim_reclaimall:
node=1 reclaimed=52 priority=10
          memory-9974  [007]   214.407464: mm_directreclaim_reclaimall:
node=1 reclaimed=96 priority=10
          memory-9974  [001]   214.577797: mm_directreclaim_reclaimall:
node=0 reclaimed=128 priority=8
          memory-9974  [004]   215.022107: mm_directreclaim_reclaimall:
node=1 reclaimed=64 priority=10


3.) mm_direct_reclaim_reclaimzone: This tracepoint records how many
pages were reclaimed when a numa node was exhausted but other nodes were
not because zone_reclaim_mode was set during boot.


4.) mm_pagereclaim_shrink_zone:  This tracepoint records how many pages
were reclaimed by a single invocation of shrink_zone and the priority.

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         kswapd1-626   [005]   223.090040: mm_pagereclaim_shrinkzone:
reclaimed=63 priority=10
         kswapd0-625   [002]   223.271915: mm_pagereclaim_shrinkzone:
reclaimed=224 priority=10
          memory-9980  [004]   223.465403: mm_pagereclaim_shrinkzone:
reclaimed=50 priority=10
     restorecond-9028  [001]   223.465776: mm_pagereclaim_shrinkzone:
reclaimed=49 priority=10
          memory-9980  [004]   223.469705: mm_pagereclaim_shrinkzone:
reclaimed=93 priority=10


5.) mm_pagereclaim_shrinkactive:  This tracepoint records how many pages
were deactivated and reactivated by a single invocation of
shrink_active_list, whether they were anonymous or pagecache pages and
the priority.

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         kswapd0-625   [000]   141.697105: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=12
         kswapd1-626   [004]   141.917568: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=12
     restorecond-9031  [003]   144.262264: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=12
          memory-9978  [004]   144.301358: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=12
            Xorg-9711  [002]   147.927108: mm_pagereclaim_shrinkactive:
scanned=32, pagecache, priority=7


6.) mm_pagereclaim_shrinkinactive:  This tracepoint records how many
pages were reclaimed and freed by a single invocation of
shrink_inactive_list, the total number of inactive pages scanned and the
priority.

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         kswapd1-626   [005]   124.740577:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=31, priority=10
          memory-9975  [000]   126.175589:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=11
         kswapd0-625   [002]   128.949227:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=11
          memory-9975  [004]   129.547320:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=11
     restorecond-9030  [001]   129.550783:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=11
~                                                                                                                 


When these tracepoints are enabled together its easy and useful to
determine exactly what is being done on the page reclaim logic.  You can
clearly see how many pages are reclaimed by kswapd and direct reclaim,
how the priority is decreasing with each call to shrink_zone and how
effective shrink_active_list and shrink_inactive_list are in reclaiming
memory:

# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         kswapd0-625   [000]   221.037254: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=10
         kswapd0-625   [000]   221.037270: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=10
         kswapd0-625   [000]   221.037286:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=10
         kswapd0-625   [000]   221.037302:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=10
         kswapd0-625   [000]   221.037302: mm_pagereclaim_shrinkzone:
reclaimed=64 priority=10
         kswapd0-625   [000]   221.037386: mm_kswapd_ran: node=0
reclaimed=408

          memory-9973  [006]   221.052384: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=9
          memory-9973  [006]   221.052399: mm_pagereclaim_shrinkactive:
scanned=32, anonymous, priority=9
          memory-9973  [006]   221.052456:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=28, priority=9
          memory-9973  [006]   221.052507:
mm_pagereclaim_shrinkinactive: scanned=32, reclaimed=32, priority=9
          memory-9973  [006]   221.052507: mm_pagereclaim_shrinkzone:
reclaimed=60 priority=9
          memory-9973  [006]   221.052553: mm_directreclaim_reclaimall:
node=1 reclaimed=60 priority=9


Signed-off-by: Larry Woodman <lwooman@redhat.com>

--=-F7f8NDzw0klAB0WaFWJd
Content-Disposition: attachment; filename=upstream.diff
Content-Type: text/x-patch; name=upstream.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eaf46bd..503f9d9 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -4,6 +4,7 @@
 #if !defined(_TRACE_KMEM_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_KMEM_H
 
+#include <linux/fs.h>
 #include <linux/types.h>
 #include <linux/tracepoint.h>
 
@@ -388,6 +389,177 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->alloc_migratetype == __entry->fallback_migratetype)
 );
 
+TRACE_EVENT(mm_pagereclaim_pgout,
+
+	TP_PROTO(struct address_space *mapping, unsigned long offset, int anon),
+
+	TP_ARGS(mapping, offset, anon),
+
+	TP_STRUCT__entry(
+		__field(struct address_space *, mapping)
+		__field(unsigned long, offset)
+		__field(int, anon)
+	),
+
+	TP_fast_assign(
+		__entry->mapping = mapping;
+		__entry->offset = offset;
+		__entry->anon = anon;
+	),
+
+	TP_printk("mapping=%lx, offset=%lx %s",
+		(unsigned long)__entry->mapping, __entry->offset, 
+			__entry->anon ? "anonymous" : "pagecache")
+	);
+
+TRACE_EVENT(mm_pagereclaim_free,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, nr_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->nr_reclaimed = nr_reclaimed;
+	),
+
+	TP_printk("freed=%ld", __entry->nr_reclaimed)
+	);
+
+TRACE_EVENT(mm_kswapd_ran,
+
+	TP_PROTO(struct pglist_data *pgdat, unsigned long reclaimed),
+
+	TP_ARGS(pgdat, reclaimed),
+
+	TP_STRUCT__entry(
+		__field(struct pglist_data *, pgdat)
+		__field(int, node_id)
+		__field(unsigned long, reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->pgdat = pgdat;
+		__entry->node_id = pgdat->node_id;
+		__entry->reclaimed = reclaimed;
+	),
+
+	TP_printk("node=%d reclaimed=%ld", __entry->node_id, __entry->reclaimed)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimall,
+
+	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(node, reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(int, node)
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->node = node;
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("node=%d reclaimed=%ld priority=%ld", __entry->node, __entry->reclaimed, 
+					__entry->priority)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimzone,
+
+	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(node, reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(int, node)
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->node = node;
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("node = %d reclaimed=%ld, priority=%ld",
+			__entry->node, __entry->reclaimed, __entry->priority)
+	);
+TRACE_EVENT(mm_pagereclaim_shrinkzone,
+
+	TP_PROTO(unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("reclaimed=%ld priority=%ld",
+			__entry->reclaimed, __entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkactive,
+
+	TP_PROTO(unsigned long scanned, int file, int priority),
+
+	TP_ARGS(scanned, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("scanned=%ld, %s, priority=%d",
+		__entry->scanned, __entry->file ? "pagecache" : "anonymous",
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive,
+
+	TP_PROTO(unsigned long scanned, unsigned long reclaimed,
+			int priority),
+
+	TP_ARGS(scanned, reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(unsigned long, reclaimed)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("scanned=%ld, reclaimed=%ld, priority=%d",
+		__entry->scanned, __entry->reclaimed, 
+		__entry->priority)
+	);
+
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..874f4b8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <trace/events/kmem.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -421,6 +422,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT,
+						PageAnon(page));
 		return PAGE_SUCCESS;
 	}
 
@@ -801,6 +804,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	trace_mm_pagereclaim_free(nr_reclaimed);
 	return nr_reclaimed;
 }
 
@@ -1240,6 +1244,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 done:
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkinactive(nr_scanned, nr_reclaimed,
+				priority);
 	return nr_reclaimed;
 }
 
@@ -1394,6 +1400,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
+	trace_mm_pagereclaim_shrinkactive(pgscanned, file, priority);
 }
 
 static int inactive_anon_is_low_global(struct zone *zone)
@@ -1645,6 +1652,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	}
 
 	sc->nr_reclaimed = nr_reclaimed;
+	trace_mm_pagereclaim_shrinkzone(nr_reclaimed, priority);
 
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
@@ -1809,6 +1817,8 @@ out:
 	if (priority < 0)
 		priority = 0;
 
+	trace_mm_directreclaim_reclaimall(zonelist[0]._zonerefs->zone->node,
+						sc->nr_reclaimed, priority);
 	if (scanning_global_lru(sc)) {
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
@@ -1930,7 +1940,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	int all_zones_ok;
 	int priority;
 	int i;
-	unsigned long total_scanned;
+	unsigned long total_scanned, total_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
@@ -1949,6 +1959,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	 */
 	int temp_priority[MAX_NR_ZONES];
 
+	total_reclaimed = 0;
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
@@ -2046,12 +2057,15 @@ loop_again:
 			 * zone has way too many pages free already.
 			 */
 			if (!zone_watermark_ok(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
+					8*high_wmark_pages(zone), end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
+				total_reclaimed += sc.nr_reclaimed;
+			}
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+			total_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone_is_all_unreclaimable(zone))
 				continue;
@@ -2122,6 +2136,7 @@ out:
 		goto loop_again;
 	}
 
+	trace_mm_kswapd_ran(pgdat, total_reclaimed);
 	return sc.nr_reclaimed;
 }
 
@@ -2548,7 +2563,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
+	int priority = ZONE_RECLAIM_PRIORITY;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2613,6 +2628,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	trace_mm_directreclaim_reclaimzone(zone->node,
+				sc.nr_reclaimed, priority);
 	return sc.nr_reclaimed >= nr_pages;
 }
 

--=-F7f8NDzw0klAB0WaFWJd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
