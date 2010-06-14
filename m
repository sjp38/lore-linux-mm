Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6506B01C8
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:17:58 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 01/12] tracing, vmscan: Add trace events for kswapd wakeup, sleeping and direct reclaim
Date: Mon, 14 Jun 2010 12:17:42 +0100
Message-Id: <1276514273-27693-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds two trace events for kswapd waking up and going asleep for
the purposes of tracking kswapd activity and two trace events for direct
reclaim beginning and ending. The information can be used to work out how
much time a process or the system is spending on the reclamation of pages
and in the case of direct reclaim, how many pages were reclaimed for that
process.  High frequency triggering of these events could point to memory
pressure problems.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/gfpflags.h |   37 +++++++++++++
 include/trace/events/kmem.h     |   38 +-------------
 include/trace/events/vmscan.h   |  115 +++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                     |   24 +++++++--
 4 files changed, 173 insertions(+), 41 deletions(-)
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h

diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
new file mode 100644
index 0000000..e3615c0
--- /dev/null
+++ b/include/trace/events/gfpflags.h
@@ -0,0 +1,37 @@
+/*
+ * The order of these masks is important. Matching masks will be seen
+ * first and the left over flags will end up showing by themselves.
+ *
+ * For example, if we have GFP_KERNEL before GFP_USER we wil get:
+ *
+ *  GFP_KERNEL|GFP_HARDWALL
+ *
+ * Thus most bits set go first.
+ */
+#define show_gfp_flags(flags)						\
+	(flags) ? __print_flags(flags, "|",				\
+	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
+	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
+	{(unsigned long)GFP_USER,		"GFP_USER"},		\
+	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
+	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
+	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
+	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
+	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
+	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
+	{(unsigned long)__GFP_WAIT,		"GFP_WAIT"},		\
+	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
+	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
+	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
+	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
+	{(unsigned long)__GFP_NOFAIL,		"GFP_NOFAIL"},		\
+	{(unsigned long)__GFP_NORETRY,		"GFP_NORETRY"},		\
+	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
+	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
+	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
+	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
+	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
+	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
+	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
+	) : "GFP_NOWAIT"
+
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 3adca0c..a9c87ad 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -6,43 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/tracepoint.h>
-
-/*
- * The order of these masks is important. Matching masks will be seen
- * first and the left over flags will end up showing by themselves.
- *
- * For example, if we have GFP_KERNEL before GFP_USER we wil get:
- *
- *  GFP_KERNEL|GFP_HARDWALL
- *
- * Thus most bits set go first.
- */
-#define show_gfp_flags(flags)						\
-	(flags) ? __print_flags(flags, "|",				\
-	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
-	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
-	{(unsigned long)GFP_USER,		"GFP_USER"},		\
-	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
-	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
-	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
-	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
-	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
-	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
-	{(unsigned long)__GFP_WAIT,		"GFP_WAIT"},		\
-	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
-	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
-	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
-	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
-	{(unsigned long)__GFP_NOFAIL,		"GFP_NOFAIL"},		\
-	{(unsigned long)__GFP_NORETRY,		"GFP_NORETRY"},		\
-	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
-	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
-	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
-	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
-	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
-	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
-	) : "GFP_NOWAIT"
+#include "gfpflags.h"
 
 DECLARE_EVENT_CLASS(kmem_alloc,
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
new file mode 100644
index 0000000..f76521f
--- /dev/null
+++ b/include/trace/events/vmscan.h
@@ -0,0 +1,115 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM vmscan
+
+#if !defined(_TRACE_VMSCAN_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_VMSCAN_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+#include "gfpflags.h"
+
+TRACE_EVENT(mm_vmscan_kswapd_sleep,
+
+	TP_PROTO(int nid),
+
+	TP_ARGS(nid),
+
+	TP_STRUCT__entry(
+		__field(	int,	nid	)
+	),
+
+	TP_fast_assign(
+		__entry->nid	= nid;
+	),
+
+	TP_printk("nid=%d", __entry->nid)
+);
+
+TRACE_EVENT(mm_vmscan_kswapd_wake,
+
+	TP_PROTO(int nid, int order),
+
+	TP_ARGS(nid, order),
+
+	TP_STRUCT__entry(
+		__field(	int,	nid	)
+		__field(	int,	order	)
+	),
+
+	TP_fast_assign(
+		__entry->nid	= nid;
+		__entry->order	= order;
+	),
+
+	TP_printk("nid=%d order=%d", __entry->nid, __entry->order)
+);
+
+TRACE_EVENT(mm_vmscan_wakeup_kswapd,
+
+	TP_PROTO(int nid, int zid, int order),
+
+	TP_ARGS(nid, zid, order),
+
+	TP_STRUCT__entry(
+		__field(	int,		nid	)
+		__field(	int,		zid	)
+		__field(	int,		order	)
+	),
+
+	TP_fast_assign(
+		__entry->nid		= nid;
+		__entry->zid		= zid;
+		__entry->order		= order;
+	),
+
+	TP_printk("nid=%d zid=%d order=%d",
+		__entry->nid,
+		__entry->zid,
+		__entry->order)
+);
+
+TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
+
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+
+	TP_ARGS(order, may_writepage, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(	int,	order		)
+		__field(	int,	may_writepage	)
+		__field(	gfp_t,	gfp_flags	)
+	),
+
+	TP_fast_assign(
+		__entry->order		= order;
+		__entry->may_writepage	= may_writepage;
+		__entry->gfp_flags	= gfp_flags;
+	),
+
+	TP_printk("order=%d may_writepage=%d gfp_flags=%s",
+		__entry->order,
+		__entry->may_writepage,
+		show_gfp_flags(__entry->gfp_flags))
+);
+
+TRACE_EVENT(mm_vmscan_direct_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	nr_reclaimed	)
+	),
+
+	TP_fast_assign(
+		__entry->nr_reclaimed	= nr_reclaimed;
+	),
+
+	TP_printk("nr_reclaimed=%lu", __entry->nr_reclaimed)
+);
+
+#endif /* _TRACE_VMSCAN_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..6bfb579 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -48,6 +48,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/vmscan.h>
+
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -1886,6 +1889,7 @@ out:
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
+	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
@@ -1898,7 +1902,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.nodemask = nodemask,
 	};
 
-	return do_try_to_free_pages(zonelist, &sc);
+	trace_mm_vmscan_direct_reclaim_begin(order,
+				sc.may_writepage,
+				gfp_mask);
+
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+
+	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
+
+	return nr_reclaimed;
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
@@ -2297,9 +2309,10 @@ static int kswapd(void *p)
 				 * premature sleep. If not, then go fully
 				 * to sleep until explicitly woken up
 				 */
-				if (!sleeping_prematurely(pgdat, order, remaining))
+				if (!sleeping_prematurely(pgdat, order, remaining)) {
+					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 					schedule();
-				else {
+				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
 					else
@@ -2319,8 +2332,10 @@ static int kswapd(void *p)
 		 * We can speed up thawing tasks if we don't call balance_pgdat
 		 * after returning from the refrigerator
 		 */
-		if (!ret)
+		if (!ret) {
+			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
 			balance_pgdat(pgdat, order);
+		}
 	}
 	return 0;
 }
@@ -2340,6 +2355,7 @@ void wakeup_kswapd(struct zone *zone, int order)
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
+	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 		return;
 	if (!waitqueue_active(&pgdat->kswapd_wait))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
