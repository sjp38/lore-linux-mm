Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1988F6B026A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so10976061eds.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:50 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id a2si481537edv.415.2018.10.31.09.06.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 09:06:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 1A24B9896F
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:06:47 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/5] mm: Target compaction on pageblocks that were recently fragmented
Date: Wed, 31 Oct 2018 16:06:45 +0000
Message-Id: <20181031160645.7633-6-mgorman@techsingularity.net>
In-Reply-To: <20181031160645.7633-1-mgorman@techsingularity.net>
References: <20181031160645.7633-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Despite the earlier patches, external fragmentation events are still
inevitable as not all callers can stall or are appropriate to stall
(e.g. unmovable allocations that kswapd reclaim will not necessarily
help). In the event there is a mixed pageblock, it's desirable to move all
movable pages from that block so that unmovable/unreclaimable allocations
do not further pollute the address space.

This patch queues such pageblocks for early compaction and relies on
kswapd to wake kcompactd when some pages are reclaimed. Waking kcompactd
after kswapd makes progress is so that the compaction is more likely to
have a suitable migration destination.

This patch may be controversial as there are multiple other design
decisions that can be made. We could refuse to change pageblock ownership
in some cases but great care would need to be taken to avoid premature
OOMs or a livelock. Similarly, we could tag pageblocks as mixed and
search for them but that would increase scanning costs. Finally, there
is a corner case that a mixed pageblock that is after the point where a
free scanner can operate may fail to clean the pageblock but addressing
that would require a fundamental alteration to how compaction works.

Unlike the previous series, this one is harder to prove that it is a benefit
because it ideally require a very long-lived workload that is fragmenting
to show if it's really effective. The timing of such an allocation stream
would be critical and detecting the change would be difficult can be
within the noise. Hence, the potential benefit of this patch is more
conceptual than quantitive even though there are some positive results.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.19 extfrag events < order 0:  71227
4.19+patch1:                    36456 (49% reduction)
4.19+patch1-3:                   4510 (94% reduction)
4.19+patch1-4:                    548 (99% reduction)
4.19+patch1-5:                    422 (99% reduction)

                                       4.19.0                 4.19.0
                                   stall-v1r6         proactive-v1r6
Amean     fault-base-1      839.48 (   0.00%)      860.89 *  -2.55%*
Amean     fault-huge-1      172.74 (   0.00%)      159.49 (   7.67%)

                                  4.19.0                 4.19.0
                              stall-v1r6         proactive-v1r6
Percentage huge-1        1.04 (   0.00%)        2.29 ( 119.35%)

While there is an improvement in the reduction of fragmentation events
and allocation success rates, the differences are marginal enough that
it may not be significant.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0:  40761
4.19+patch1:                    36085 (11% reduction)
4.19+patch1-3:                   1887 (95% reduction)
4.19+patch1-4:                    394 (99% reduction)
4.19+patch1-5:                    440 (99% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                   stall-v1r6         proactive-v1r6
Amean     fault-base-1     3943.28 (   0.00%)     2704.46 *  31.42%*
Amean     fault-huge-1     2739.80 (   0.00%)     2552.13 *   6.85%*

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0
                              stall-v1r6         proactive-v1r6
Percentage huge-1       98.55 (   0.00%)       98.76 (   0.20%)

Slight increase in fragmentation events albeit very small. The latency
is much improved as well as a slight increase in allocation success
rates but this may be a co-incidence of the system state.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.19 extfrag events < order 0:  882868
4.19+patch1:                    476937 (46% reduction)
4.19+patch1-3:                   29044 (97% reduction)
4.19+patch1-4:                   29290 (97% reduction)
4.19+patch1-5:                   30791 (97% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                   stall-v1r6         proactive-v1r6
Amean     fault-base-5     1773.24 (   0.00%)     1519.89 *  14.29%*
Amean     fault-huge-5    17791.20 (   0.00%)      536.44 (  96.98%)

                                  4.19.0                 4.19.0
                              stall-v1r6         proactive-v1r6
Percentage huge-5        0.17 (   0.00%)        0.98 ( 490.00%)

Again, the fragmentation causing events is slightly increased although
this is likely within the noise. The latency is massively improved but
the success rate is only marginally improved. Given the low success rate,
it may be a co-incidence of the exact system state during the test but
the fact it happened on both 1 and 2 socket machines is encouraging.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0: 803099
4.19+patch1:                   654671 (23% reduction)
4.19+patch1-3:                  24352 (97% reduction)
4.19+patch1-4:                  16698 (98% reduction)
4.19+patch1-5:                  32623 (96% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                   stall-v1r6         proactive-v1r6
Amean     fault-base-5     8649.60 (   0.00%)    13074.71 * -51.16%*
Amean     fault-huge-5     2799.82 (   0.00%)     3410.02 * -21.79%*

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0
                              stall-v1r6         proactive-v1r6
Percentage huge-5       77.80 (   0.00%)       83.30 (   7.06%)

This shows an increase in both fragmentation events and latency. However
it is somewhat balanced by the higher allocation success rates which in
themselves can increase fragmentation pressure.

This is less an obvious universal win. It does control fragmentation
better to some extent in that pageblocks can be found faster in some
cases but the nature of the workload makes it less clear-cut.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/compaction.h        |   4 ++
 include/linux/migrate.h           |   7 +-
 include/linux/mmzone.h            |   4 ++
 include/trace/events/compaction.h |  62 ++++++++++++++++
 mm/compaction.c                   | 146 +++++++++++++++++++++++++++++++++++---
 mm/migrate.c                      |   6 +-
 mm/page_alloc.c                   |   7 ++
 7 files changed, 225 insertions(+), 11 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 68250a57aace..1fc1ad055f66 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -177,6 +177,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
+extern void kcompactd_queue_migration(struct zone *zone, struct page *page);
 
 #else
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
@@ -225,6 +226,9 @@ static inline void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_i
 {
 }
 
+static inline void kcompactd_queue_migration(struct zone *zone, struct page *page)
+{
+}
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..f12cee38c0f0 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -61,7 +61,7 @@ static inline struct page *new_page_nodemask(struct page *page,
 
 #ifdef CONFIG_MIGRATION
 
-extern void putback_movable_pages(struct list_head *l);
+extern unsigned int putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *mapping,
 			struct page *newpage, struct page *page,
 			enum migrate_mode mode);
@@ -82,7 +82,10 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		int extra_count);
 #else
 
-static inline void putback_movable_pages(struct list_head *l) {}
+static inline unsigned int putback_movable_pages(struct list_head *l)
+{
+	return 0;
+}
 static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
 		int reason)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 66e71a8ac8a6..0a905add8112 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -495,6 +495,10 @@ struct zone {
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
+
+#define COMPACT_QUEUE_LENGTH 16
+	unsigned long		compact_queue[COMPACT_QUEUE_LENGTH];
+	int			nr_compact;
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff3d766..6b5b61177d8c 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -353,6 +353,68 @@ DEFINE_EVENT(kcompactd_wake_template, mm_compaction_kcompactd_wake,
 	TP_ARGS(nid, order, classzone_idx)
 );
 
+TRACE_EVENT(mm_compaction_wakeup_kcompactd_queue,
+
+	TP_PROTO(
+		int nid,
+		enum zone_type zoneid,
+		unsigned long pfn,
+		int nr_queued),
+
+	TP_ARGS(nid, pfn, zoneid, nr_queued),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(enum zone_type, zoneid)
+		__field(unsigned long, pfn)
+		__field(int, nr_queued)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->zoneid = zoneid;
+		__entry->pfn = pfn;
+		__entry->nr_queued = nr_queued;
+	),
+
+	TP_printk("nid=%d zoneid=%-8s pfn=%lu nr_queued=%d",
+		__entry->nid,
+		__print_symbolic(__entry->zoneid, ZONE_TYPE),
+		__entry->pfn,
+		__entry->nr_queued)
+);
+
+TRACE_EVENT(mm_compaction_kcompactd_migrated,
+
+	TP_PROTO(
+		int nid,
+		enum zone_type zoneid,
+		int nr_migrated,
+		int nr_failed),
+
+	TP_ARGS(nid, zoneid, nr_migrated, nr_failed),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(enum zone_type, zoneid)
+		__field(int, nr_migrated)
+		__field(int, nr_failed)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->zoneid = zoneid,
+		__entry->nr_migrated = nr_migrated;
+		__entry->nr_failed = nr_failed;
+	),
+
+	TP_printk("nid=%d zoneid=%-8s nr_migrated=%d nr_failed=%d",
+		__entry->nid,
+		__print_symbolic(__entry->zoneid, ZONE_TYPE),
+		__entry->nr_migrated,
+		__entry->nr_failed)
+);
+
 #endif /* _TRACE_COMPACTION_H */
 
 /* This part must be outside protection */
diff --git a/mm/compaction.c b/mm/compaction.c
index aa9473a64915..853538e568d9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1914,6 +1914,12 @@ void compaction_unregister_node(struct node *node)
 
 static inline bool kcompactd_work_requested(pg_data_t *pgdat)
 {
+	int zoneid;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++)
+		if (pgdat->node_zones[zoneid].nr_compact)
+			return true;
+
 	return pgdat->kcompactd_max_order > 0 || kthread_should_stop();
 }
 
@@ -1937,6 +1943,93 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	return false;
 }
 
+static void kcompactd_migrate_block(struct compact_control *cc,
+	unsigned long pfn)
+{
+	unsigned long end = min(pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
+	unsigned long total_migrated = 0, total_failed = 0;
+
+	cc->migrate_pfn = pfn;
+	while (pfn && pfn < end) {
+		int err;
+		unsigned long nr_migrated, nr_failed = 0;
+
+		pfn = isolate_migratepages_range(cc, pfn, end);
+		if (!pfn)
+			break;
+
+		nr_migrated = cc->nr_migratepages;
+		err = migrate_pages(&cc->migratepages, compaction_alloc,
+				compaction_free, (unsigned long)cc,
+				cc->mode, MR_COMPACTION);
+		if (err) {
+			nr_failed = putback_movable_pages(&cc->migratepages);
+			nr_migrated -= nr_failed;
+		}
+		cc->nr_migratepages = 0;
+		total_migrated += nr_migrated;
+		total_failed += nr_failed;
+	}
+
+	trace_mm_compaction_kcompactd_migrated(zone_to_nid(cc->zone),
+		zone_idx(cc->zone), total_migrated, total_failed);
+	return;
+}
+
+static void kcompactd_init_cc(struct compact_control *cc, struct zone *zone)
+{
+	cc->nr_freepages = 0;
+	cc->nr_migratepages = 0;
+	cc->total_migrate_scanned = 0;
+	cc->total_free_scanned = 0;
+	cc->zone = zone;
+	INIT_LIST_HEAD(&cc->freepages);
+	INIT_LIST_HEAD(&cc->migratepages);
+}
+
+static void kcompactd_do_queue(pg_data_t *pgdat)
+{
+	/*
+	 * With no special task, compact all zones so that a page of requested
+	 * order is allocatable.
+	 */
+	int zoneid;
+	struct zone *zone;
+	struct compact_control cc = {
+		.order = 0,
+		.total_migrate_scanned = 0,
+		.total_free_scanned = 0,
+		.classzone_idx = 0,
+		.mode = MIGRATE_SYNC,
+		.ignore_skip_hint = true,
+		.gfp_mask = GFP_KERNEL,
+	};
+	trace_mm_compaction_kcompactd_wake(pgdat->node_id, 0, -1);
+
+	migrate_prep();
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		unsigned long pfn = ULONG_MAX;
+		int limit;
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		kcompactd_init_cc(&cc, zone);
+		cc.free_pfn = pageblock_start_pfn(zone_end_pfn(zone) - 1);
+		limit = zone->nr_compact;
+		while (zone->nr_compact && limit--) {
+			unsigned long flags;
+
+			spin_lock_irqsave(&zone->lock, flags);
+			if (zone->nr_compact)
+				pfn = zone->compact_queue[--zone->nr_compact];
+			spin_unlock_irqrestore(&zone->lock, flags);
+			kcompactd_migrate_block(&cc, pfn);
+		}
+	}
+}
+
 static void kcompactd_do_work(pg_data_t *pgdat)
 {
 	/*
@@ -1956,7 +2049,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	};
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
-	count_compact_event(KCOMPACTD_WAKE);
 
 	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
 		int status;
@@ -1972,13 +2064,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 							COMPACT_CONTINUE)
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
-		cc.total_migrate_scanned = 0;
-		cc.total_free_scanned = 0;
-		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
+		kcompactd_init_cc(&cc, zone);
 
 		if (kthread_should_stop())
 			return;
@@ -2024,6 +2110,19 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 {
+	int i;
+
+	/* Wake kcompact if there are compaction queue entries */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *zone = &pgdat->node_zones[i];
+
+		if (!managed_zone(zone))
+			continue;
+
+		if (zone->nr_compact)
+			goto wake;
+	}
+
 	if (!order)
 		return;
 
@@ -2043,6 +2142,7 @@ void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 	if (!kcompactd_node_suitable(pgdat))
 		return;
 
+wake:
 	trace_mm_compaction_wakeup_kcompactd(pgdat->node_id, order,
 							classzone_idx);
 	wake_up_interruptible(&pgdat->kcompactd_wait);
@@ -2072,12 +2172,42 @@ static int kcompactd(void *p)
 		wait_event_freezable(pgdat->kcompactd_wait,
 				kcompactd_work_requested(pgdat));
 
+		count_compact_event(KCOMPACTD_WAKE);
+		kcompactd_do_queue(pgdat);
 		kcompactd_do_work(pgdat);
 	}
 
 	return 0;
 }
 
+/*
+ * Queue a pageblock to have all movable pages migrated from. Note that
+ * kcompactd is not woken at this point. This assumes that kswapd has
+ * been woken to reclaim pages above the boosted watermark. kcompactd
+ * will be woken when kswapd has made progress.
+ */
+void kcompactd_queue_migration(struct zone *zone, struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
+	int nr_queued = -1;
+
+	/* Do not overflow the queue */
+	if (zone->nr_compact == COMPACT_QUEUE_LENGTH)
+		goto trace;
+
+	/* Only queue a pageblock once */
+	for (nr_queued = 0; nr_queued < zone->nr_compact; nr_queued++) {
+		if (zone->compact_queue[nr_queued] == pfn)
+			return;
+	}
+
+	zone->compact_queue[zone->nr_compact++] = pfn;
+
+trace:
+	trace_mm_compaction_wakeup_kcompactd_queue(zone_to_nid(zone),
+		zone_idx(zone), pfn, nr_queued);
+}
+
 /*
  * This kcompactd start function will be called by init and node-hot-add.
  * On node-hot-add, kcompactd will moved to proper cpus if cpus are hot-added.
diff --git a/mm/migrate.c b/mm/migrate.c
index 84381b55b2bd..b8ce5b56a2a9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -164,12 +164,14 @@ void putback_movable_page(struct page *page)
  * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
  * and isolate_huge_page().
  */
-void putback_movable_pages(struct list_head *l)
+unsigned int putback_movable_pages(struct list_head *l)
 {
 	struct page *page;
 	struct page *page2;
+	unsigned int nr_putback = 0;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
+		nr_putback++;
 		if (unlikely(PageHuge(page))) {
 			putback_active_hugepage(page);
 			continue;
@@ -195,6 +197,8 @@ void putback_movable_pages(struct list_head *l)
 			putback_lru_page(page);
 		}
 	}
+
+	return nr_putback;
 }
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63de66b893d3..77bcc35903e0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2190,6 +2190,9 @@ static bool steal_suitable_fallback(struct zone *zone, struct page *page,
 	boost_watermark(zone);
 	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
 
+	if (start_type == MIGRATE_MOVABLE || old_block_type == MIGRATE_MOVABLE)
+		kcompactd_queue_migration(zone, page);
+
 	if ((alloc_flags & ALLOC_FRAGMENT_STALL) &&
 	    current_order < fragment_stall_order) {
 		return false;
@@ -6359,7 +6362,11 @@ static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
 #ifdef CONFIG_COMPACTION
 static void pgdat_init_kcompactd(struct pglist_data *pgdat)
 {
+	int i;
+
 	init_waitqueue_head(&pgdat->kcompactd_wait);
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		pgdat->node_zones[i].nr_compact = 0;
 }
 #else
 static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
-- 
2.16.4
