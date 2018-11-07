Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81A406B053C
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 13:38:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x98-v6so9969462ede.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 10:38:27 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id q17-v6si756857ejp.291.2018.11.07.10.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 10:38:24 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 985851C26DF
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:38:24 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/5] mm: Target compaction on pageblocks that were recently fragmented
Date: Wed,  7 Nov 2018 18:38:22 +0000
Message-Id: <20181107183822.15567-6-mgorman@techsingularity.net>
In-Reply-To: <20181107183822.15567-1-mgorman@techsingularity.net>
References: <20181107183822.15567-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Despite the earlier patches, external fragmentation events are still
inevitable as not all callers can stall or are appropriate to stall.  In the
event the result is a mixed pageblock, it is desirable to move all movable
pages from that block so that unmovable/unreclaimable allocations do not
further pollute the address space. This patch queues such pageblocks for
early compaction and relies on kswapd to wake kcompactd when some pages
are reclaimed. Waking kcompactd after kswapd makes progress is so that
the compaction is more likely to have a suitable migration destination.

This patch may be controversial as there are multiple other design
decisions that can be made. We could refuse to change pageblock ownership
in some cases but great care would need to be taken to avoid premature
OOMs or a livelock. Similarly, we could tag pageblocks as mixed and
search for them but that would increase scanning costs. Finally, there
is a corner case that a mixed pageblock that is after the point where a
free scanner can operate may fail to clean the pageblock but addressing
that would require a fundamental alteration to how compaction works.

Unlike the previous patches, the benefit here is harder to quantify as
any work that is queued may or may not help an allocation request in the
future.  The timing of the allocation stream is critical and detecting
differences in latency may be within the noise.  Hence, the potential
benefit of this patch is more conceptual than quantitive even though
there are some positive results.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.20-rc1 extfrag events < order 9:  1023463
4.20-rc1+patch:                      358574 (65% reduction)
4.20-rc1+patch1-3:                    19274 (98% reduction)
4.20-rc1+patch1-4:                     1351 (99.9% reduction)
4.20-rc1+patch1-5:                     2554 (99.8% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   stall-v2r6         proactive-v2r6
Amean     fault-base-1      648.66 (   0.00%)      655.18 *  -1.00%*
Amean     fault-huge-1      167.79 (   0.00%)      163.00 (   2.85%)

                              4.20.0-rc1             4.20.0-rc1
                              stall-v2r6         proactive-v2r6
Percentage huge-1        1.16 (   0.00%)        0.03 ( -97.14%)

The performance is similar but not necessarily indicative that the patch
had any effect. There was no reported compaction activity so essentially
the patch was a no-op.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc1 extfrag events < order 9:  342549
4.20-rc1+patch:                     337890 ( 1% reduction)
4.20-rc1+patch1-3:                   12801 (96% reduction)
4.20-rc1+patch1-4:                    1511 (99.7% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   stall-v2r6         proactive-v2r6
Amean     fault-base-1    43404.60 (   0.00%)        0.00 ( 100.00%)
Amean     fault-huge-1     1424.32 (   0.00%)      540.99 *  62.02%*

                              4.20.0-rc1             4.20.0-rc1
                              stall-v2r6         proactive-v2r6
Percentage huge-1       99.92 (   0.00%)      100.00 (   0.08%)

Slight increase in fragmentation events but the latency was improved
and THP allocations had a 100% success rate.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.20-rc1 extfrag events < order 9:  209820
4.20-rc1+patch:                     185923 (11% reduction)
4.20-rc1+patch1-3:                   11240 (95% reduction)
4.20-rc1+patch1-4:                   13241 (93% reduction)
4.20-rc1+patch1-5:                   11916 (94% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc1             4.20.0-rc1
                                   stall-v2r6         proactive-v2r6
Amean     fault-base-5     1508.94 (   0.00%)     1545.56 (  -2.43%)
Amean     fault-huge-5      614.88 (   0.00%)      557.46 *   9.34%*

                              4.20.0-rc1             4.20.0-rc1
                              stall-v2r6         proactive-v2r6
Percentage huge-5        3.38 (   0.00%)        4.53 (  33.99%)

Fragmentation-causing events are slightly reduced and there is a slight
improvement in THP allocation latencies and success rates. Remember that
no special effort is being made to allocate THP in this workload.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc1 extfrag events < order 9: 167464
4.20-rc1+patch:                    130081 (22% reduction)
4.20-rc1+patch1-3:                  12057 (92% reduction)
4.20-rc1+patch1-4:                  11060 (93% reduction)
4.20-rc1+patch1-5:                   8903 (95% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   stall-v2r6         proactive-v2r6
Amean     fault-base-5     9363.89 (   0.00%)     9067.00 (   3.17%)
Amean     fault-huge-5     3638.29 (   0.00%)     1509.51 *  58.51%*

thpfioscale Percentage Faults Huge
                              4.20.0-rc1             4.20.0-rc1
                              stall-v2r6         proactive-v2r6
Percentage huge-5       99.27 (   0.00%)       99.93 (   0.67%)

There is a small decrease in fragmentation events but the most notable
part is the decrease in latency with a similarly high THP allocation
success rate.

It is less obvious whether this is a universal win as fragmentation-causing
events were already low and in the case of MADV_HUGEPAGE, the allocation
success rates were already high. However, it's encouraging that the THP
allocation latencies were improved.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/compaction.h        |   4 ++
 include/linux/migrate.h           |   7 +-
 include/linux/mmzone.h            |   4 ++
 include/trace/events/compaction.h |  62 ++++++++++++++++
 mm/compaction.c                   | 145 +++++++++++++++++++++++++++++++++++---
 mm/migrate.c                      |   6 +-
 mm/page_alloc.c                   |   7 ++
 7 files changed, 224 insertions(+), 11 deletions(-)

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
index cffec484ac8a..980fad03ae8e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -497,6 +497,10 @@ struct zone {
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
index ef29490b0f46..0fdeecd47a03 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1915,6 +1915,12 @@ void compaction_unregister_node(struct node *node)
 
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
 
@@ -1938,6 +1944,92 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
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
@@ -1957,7 +2049,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	};
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
-	count_compact_event(KCOMPACTD_WAKE);
 
 	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
 		int status;
@@ -1973,13 +2064,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
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
@@ -2025,6 +2110,19 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
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
 
@@ -2044,6 +2142,7 @@ void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 	if (!kcompactd_node_suitable(pgdat))
 		return;
 
+wake:
 	trace_mm_compaction_wakeup_kcompactd(pgdat->node_id, order,
 							classzone_idx);
 	wake_up_interruptible(&pgdat->kcompactd_wait);
@@ -2076,6 +2175,8 @@ static int kcompactd(void *p)
 				kcompactd_work_requested(pgdat));
 
 		psi_memstall_enter(&pflags);
+		count_compact_event(KCOMPACTD_WAKE);
+		kcompactd_do_queue(pgdat);
 		kcompactd_do_work(pgdat);
 		psi_memstall_leave(&pflags);
 	}
@@ -2083,6 +2184,34 @@ static int kcompactd(void *p)
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
index f7e4bfdc13b7..2ee3c38d2269 100644
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
index 86a6e86c51bb..1e72f757253e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2214,6 +2214,9 @@ static bool steal_suitable_fallback(struct zone *zone, struct page *page,
 	boost_watermark(zone, false);
 	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
 
+	if (start_type == MIGRATE_MOVABLE || old_block_type == MIGRATE_MOVABLE)
+		kcompactd_queue_migration(zone, page);
+
 	if ((alloc_flags & ALLOC_FRAGMENT_STALL) &&
 	    current_order < fragment_stall_order) {
 		return false;
@@ -6457,7 +6460,11 @@ static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
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
