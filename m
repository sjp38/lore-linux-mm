Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 685676B03C3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 09:56:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l37so10823016wrc.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 06:56:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c41si4659847wrc.279.2017.03.08.06.56.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 06:56:36 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
References: <20161230131412.GI13301@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <33fd268f-05b3-a476-435a-437cbe558107@suse.cz>
Date: Wed, 8 Mar 2017 15:56:33 +0100
MIME-Version: 1.0
In-Reply-To: <20161230131412.GI13301@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/30/2016 02:14 PM, Michal Hocko wrote:
> Hi,
> I didn't originally want to send this proposal because Vlastimil is
> planning to do some work in this area so I've expected him to send
> something similar. But the recent discussion about the THP defrag
> options pushed me to send out my thoughts.
> 
> So what is the problem? The demand for high order pages is growing and
> that seems to be the general trend. The problem is that while they can
> bring performance benefit they can get be really expensive to allocate
> especially when we enter the direct compaction. So we really want to
> prevent from expensive path and defer as much as possible to the
> background. A huge step forward was kcompactd introduced by Vlastimil.
> We are still not there yet though, because it might be already quite
> late when we wakeup_kcompactd(). The memory might be already fragmented
> when we hit there. Moreover we do not have any way to actually tell
> which orders we do care about.
> 
> Therefore I believe we need a watermark based pro-active compaction
> which would keep the background compaction busy as long as we have
> less pages of the configured order. kcompactd should wake up
> periodically, I think, and check for the status so that we can catch
> the fragmentation before we get low on memory.
> The interface could look something like:
> /proc/sys/vm/compact_wmark
> time_period order count
> 
> There are many details that would have to be solved of course - e.g. do
> not burn cycles pointlessly when we know that no further progress can be
> made etc... but in principle the idea show work.
 
OK, LSF/MM is near, so I'll post my approach up for discussion. It's
very RFC state, I've worked at it last year and now I just rebased it to
4.11-rc1 and updated some comments. Maybe I'll manage to do some tests
before LSF/MM, but no guarantees. Comments welcome.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC] mm: make kcompactd more proactive

Kcompactd activity is currently tied to kswapd - it is woken up when kswapd
goes to sleep, and compacts to make a single high-order page available, of
order that was used to wake up kswapd. This leaves the rest of free pages
fragmented and results in direct compaction when the demand for fresh
high-order pages is higher than a single page per kswapd cycle.

Another extreme would be to let kcompactd compact whole zone the same way as
manual compaction from /proc interface. This would be wasteful if the resulting
high-order pages would be split down to base pages for allocations.

This patch aims to adjust the kcompactd effort through observed demand for
high-order pages. This is done by hooking into alloc_pages_slowpath() and
counting (per each order > 0) allocation attempts that would pass the order-0
watermarks, but don't have the high-order page available. This demand is
(currently) recorded per node and then redistributed per zones in each node
according to their relative sizes.

Kcompactd then uses a different termination criteria than direct compaction.
It checks whether for each order, the recorded number of attempted allocations
would fit within the free pages of that order of with possible splitting of
higher orders, assuming there would be no allocations of other orders. This
should make kcompactd effort reflect the high-order demand.

In the worst case, the demand is so high that kcompactd will in fact compact
the whole zone and would have to be run with higher frequency than kswapd to
make a larger difference. That possibility can be explored later.
---
 include/linux/compaction.h |   6 ++
 include/linux/mmzone.h     |   2 +
 mm/compaction.c            | 165 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c            |  12 ++++
 4 files changed, 182 insertions(+), 3 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0d8415820fc3..b342a80bde17 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -176,6 +176,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
+extern void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac);
 
 #else
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
@@ -224,6 +226,10 @@ static inline void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_i
 {
 }
 
+static inline void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac)
+{
+}
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8e02b3750fe0..0943849620ae 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -478,6 +478,7 @@ struct zone {
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
+	unsigned int		compact_free_target[MAX_ORDER];
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -635,6 +636,7 @@ typedef struct pglist_data {
 	enum zone_type kcompactd_classzone_idx;
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
+	atomic_t compact_free_target[MAX_ORDER];
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	/* Lock serializing the migrate rate limiting window */
diff --git a/mm/compaction.c b/mm/compaction.c
index 247a7c421014..8c68ca64c670 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -21,6 +21,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/page_owner.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -1276,6 +1277,34 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
+static bool kcompactd_zone_balanced(struct zone *zone)
+{
+	unsigned int order;
+	unsigned long sum_nr_free = 0;
+
+	//TODO: we should consider whether kcompactd should give up when
+	//NR_FREE_PAGES drops below some point between low and high wmark,
+	//or somehow scale down the free target
+
+	for (order = MAX_ORDER - 1; order > 0; order--) {
+		unsigned long nr_free;
+
+		nr_free = zone->free_area[order].nr_free;
+		sum_nr_free += nr_free;
+
+		if (sum_nr_free < zone->compact_free_target[order])
+			return false;
+
+		/*
+		 * Each free page of current order can fit two pages of the
+		 * lower order.
+		 */
+		sum_nr_free <<= 1UL;
+	}
+
+	return true;
+}
+
 static enum compact_result __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
@@ -1315,6 +1344,14 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 							cc->alloc_flags))
 		return COMPACT_CONTINUE;
 
+	/*
+	 * Compaction that's neither direct nor is_via_compact_memory() has to
+	 * be from kcompactd, which has different criteria.
+	 */
+	if (!cc->direct_compaction)
+		return kcompactd_zone_balanced(zone) ?
+			COMPACT_SUCCESS : COMPACT_CONTINUE;
+
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &zone->free_area[order];
@@ -1869,7 +1906,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	struct zone *zone;
 	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
 
-	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		zone = &pgdat->node_zones[zoneid];
 
 		if (!populated_zone(zone))
@@ -1878,11 +1915,130 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
 					classzone_idx) == COMPACT_CONTINUE)
 			return true;
+
+		// TODO: potentially unsuitable due to low free memory
+		if (!kcompactd_zone_balanced(zone))
+			return true;
 	}
 
 	return false;
 }
 
+void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac)
+{
+	struct zone *zone;
+	struct zoneref *zref;
+	// FIXME: too large for stack?
+	nodemask_t nodes_done = NODE_MASK_NONE;
+
+	// FIXME: spread over nodes instead of increasing all?
+	for_each_zone_zonelist_nodemask(zone, zref, ac->zonelist,
+					ac->high_zoneidx, ac->nodemask) {
+		unsigned long mark;
+		int nid = zone_to_nid(zone);
+
+		if (node_isset(nid, nodes_done))
+			continue;
+
+		if (cpusets_enabled() &&
+				(alloc_flags & ALLOC_CPUSET) &&
+				!cpuset_zone_allowed(zone, gfp_mask))
+			continue;
+
+		/* The high-order allocation should succeed on this node */
+		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		if (zone_watermark_ok(zone, order, mark,
+				       ac_classzone_idx(ac), alloc_flags)) {
+			node_set(nid, nodes_done);
+			continue;
+		}
+
+		/*
+		 * High-order allocation wouldn't succeed. If order-0
+		 * allocations of same total size would pass the watermarks,
+		 * we know it's due to fragmentation, and kcompactd trying
+		 * harder could help.
+		 */
+		mark += (1UL << order) - 1;
+		if (zone_watermark_ok(zone, 0, mark, ac_classzone_idx(ac),
+								alloc_flags)) {
+			/*
+			 * TODO: consider prioritizing based on gfp_mask, e.g.
+			 * THP faults are opportunistic and should not result
+			 * in perpetual kcompactd activity. Allocation attempts
+			 * without easy fallback should be more important.
+			 */
+			atomic_inc(&NODE_DATA(nid)->compact_free_target[order]);
+			node_set(nid, nodes_done);
+		}
+	}
+}
+
+static void kcompactd_adjust_free_targets(pg_data_t *pgdat)
+{
+	unsigned long managed_pages = 0;
+	unsigned long high_wmark = 0;
+	int zoneid, order;
+	struct zone *zone;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		zone = &pgdat->node_zones[zoneid];
+
+		if (!populated_zone(zone))
+			continue;
+
+		managed_pages += zone->managed_pages;
+		high_wmark += high_wmark_pages(zone);
+	}
+
+	if (!managed_pages)
+		return;
+
+	for (order = 1; order < MAX_ORDER; order++) {
+		unsigned long target;
+
+		target = atomic_read(&pgdat->compact_free_target[order]);
+
+		/*
+		 * Limit the target by high wmark worth of pages, otherwise
+		 * kcompactd can't achieve it anyway.
+		 */
+		if ((target << order) > high_wmark) {
+			target = high_wmark >> order;
+			atomic_set(&pgdat->compact_free_target[order], target);
+		}
+
+		if (!target)
+			continue;
+
+		/* Distribute the target among zones */
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+
+			unsigned long zone_target = target;
+
+			zone = &pgdat->node_zones[zoneid];
+
+			if (!populated_zone(zone))
+				continue;
+
+			/* For a single zone on node, take a shortcut */
+			if (managed_pages == zone->managed_pages) {
+				zone->compact_free_target[order] = zone_target;
+				continue;
+			}
+
+			/* Take proportion of zone's page to whole node */
+			zone_target *= zone->managed_pages;
+			/* Round up for remainder of at least 1/2 */
+			zone_target += managed_pages >> 1;
+			zone_target /= managed_pages;
+
+			zone->compact_free_target[order] = zone_target;
+		}
+	}
+}
+
 static void kcompactd_do_work(pg_data_t *pgdat)
 {
 	/*
@@ -1905,7 +2061,9 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 							cc.classzone_idx);
 	count_compact_event(KCOMPACTD_WAKE);
 
-	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
+	kcompactd_adjust_free_targets(pgdat);
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		int status;
 
 		zone = &pgdat->node_zones[zoneid];
@@ -1915,8 +2073,9 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (compaction_deferred(zone, cc.order))
 			continue;
 
-		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
+		if ((compaction_suitable(zone, cc.order, 0, zoneid) !=
 							COMPACT_CONTINUE)
+					&& kcompactd_zone_balanced(zone))
 			continue;
 
 		cc.nr_freepages = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eaa64d2ffdc5..740bcb0ac382 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3697,6 +3697,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/*
+	 * If it looks like increased kcompactd effort could have spared
+	 * us from direct compaction (or allocation failure if we cannot
+	 * compact), increase kcompactd's target.
+	 */
+	if (order > 0)
+		kcompactd_inc_free_target(gfp_mask, order, alloc_flags, ac);
+
+	/*
 	 * For costly allocations, try direct compaction first, as it's likely
 	 * that we have enough base pages and don't need to reclaim. Don't try
 	 * that for allocations that are allowed to ignore watermarks, as the
@@ -5946,6 +5954,7 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
  */
 static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
+	int i;
 	enum zone_type j;
 	int nid = pgdat->node_id;
 	int ret;
@@ -5965,6 +5974,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 #ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pgdat->kcompactd_wait);
+	for (i = 0; i < MAX_ORDER; i++)
+		//FIXME: I can't use ATOMIC_INIT, can I?
+		atomic_set(&pgdat->compact_free_target[i], 0);
 #endif
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
-- 
2.12.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
