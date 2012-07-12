Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D48036B0069
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:50:50 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/3 v3] memory-hotplug: fix kswapd looping forever problem
Date: Thu, 12 Jul 2012 11:50:49 +0900
Message-Id: <1342061449-29590-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1342061449-29590-1-git-send-email-minchan@kernel.org>
References: <1342061449-29590-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>, Minchan Kim <minchan@kernel.org>

When hotplug offlining happens on zone A, it starts to mark freed page
as MIGRATE_ISOLATE type in buddy for preventing further allocation.
(MIGRATE_ISOLATE is very irony type because it's apparently on buddy
but we can't allocate them).
When the memory shortage happens during hotplug offlining,
current task starts to reclaim, then wake up kswapd.
Kswapd checks watermark, then go sleep because current zone_watermark_ok_safe
doesn't consider MIGRATE_ISOLATE freed page count.
Current task continue to reclaim in direct reclaim path without kswapd's helping.
The problem is that zone->all_unreclaimable is set by only kswapd
so that current task would be looping forever like below.

__alloc_pages_slowpath
restart:
	wake_all_kswapd
rebalance:
	__alloc_pages_direct_reclaim
		do_try_to_free_pages
			if global_reclaim && !all_unreclaimable
				return 1; /* It means we did did_some_progress */
	skip __alloc_pages_may_oom
	should_alloc_retry
		goto rebalance;

If we apply KOSAKI's patch[1] which doesn't depends on kswapd
about setting zone->all_unreclaimable, we can solve this problem
by killing some task in direct reclaim path. But it doesn't wake up kswapd, still.
It could be a problem still if other subsystem needs GFP_ATOMIC request.
So kswapd should consider MIGRATE_ISOLATE when it calculate free pages
BEFORE going sleep.

This patch counts the number of MIGRATE_ISOLATE page block and
zone_watermark_ok_safe will consider it if the system has such blocks
(fortunately, it's very rare so no problem in POV overhead and kswapd is never
hotpath).

Copy/modify from Mel's quote
"
Ideal solution would be "allocating" the pageblock.
It would keep the free space accounting as it is but historically,
memory hotplug didn't allocate pages because it would be difficult to
detect if a pageblock was isolated or if part of some balloon.
Allocating just full pageblocks would work around this, However,
it would play very badly with CMA.
"

[1] http://lkml.org/lkml/2012/6/14/74

* from v2
 - rebased on mmotm-2012-07-10-16-59
 - Add Tested-by

* from v1
 - add changelog
 - make functions simple
 - remove atomic variable
 - discard exact isolated free page accounting.
 - rebased on next-20120626

Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Tested-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    8 ++++++++
 mm/page_alloc.c        |   31 +++++++++++++++++++++++++++++++
 mm/page_isolation.c    |   29 +++++++++++++++++++++++++++--
 3 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3219014..3bd253e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -477,6 +477,14 @@ struct zone {
 	 * rarely used fields:
 	 */
 	const char		*name;
+#ifdef CONFIG_MEMORY_ISOLATION
+	/*
+	 * the number of MIGRATE_ISOLATE *pageblock*.
+	 * We need this for free page counting. Look at zone_watermark_ok_safe.
+	 * It's protected by zone->lock
+	 */
+	int		nr_pageblock_isolate;
+#endif
 } ____cacheline_internodealigned_in_smp;
 
 typedef enum {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 627653c..980c75b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -218,6 +218,11 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
+/*
+ * NOTE:
+ * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) directly.
+ * Instead, use {un}set_pageblock_isolate.
+ */
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
@@ -1618,6 +1623,23 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	return true;
 }
 
+#ifdef CONFIG_MEMORY_ISOLATION
+static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
+{
+	unsigned long nr_pages = 0;
+
+	if (unlikely(zone->nr_pageblock_isolate)) {
+		nr_pages = zone->nr_pageblock_isolate * pageblock_nr_pages;
+	}
+	return nr_pages;
+}
+#else
+static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
+{
+	return 0;
+}
+#endif
+
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
@@ -1633,6 +1655,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
 
+	/*
+	 * If the zone has MIGRATE_ISOLATE type free page,
+	 * we should consider it. nr_zone_isolate_freepages is never
+	 * accurate so kswapd might not sleep although she can.
+	 * But it's more desirable for memory hotplug rather than
+	 * forever sleep which cause livelock in direct reclaim path.
+	 */
+	free_pages -= nr_zone_isolate_freepages(z);
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
 								free_pages);
 }
@@ -4397,6 +4427,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		lruvec_init(&zone->lruvec, zone);
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
+		zone->nr_pageblock_isolate = 0;
 		if (!size)
 			continue;
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index fb482cf..64abb33 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -8,6 +8,31 @@
 #include <linux/memory.h>
 #include "internal.h"
 
+/* called by holding zone->lock */
+static void set_pageblock_isolate(struct zone *zone, struct page *page)
+{
+	BUG_ON(page_zone(page) != zone);
+
+	if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
+		return;
+
+	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+	zone->nr_pageblock_isolate++;
+}
+
+/* called by holding zone->lock */
+static void restore_pageblock_isolate(struct zone *zone, struct page *page,
+		int migratetype)
+{
+	BUG_ON(page_zone(page) != zone);
+	if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE))
+		return;
+
+	BUG_ON(zone->nr_pageblock_isolate <= 0);
+	set_pageblock_migratetype(page, migratetype);
+	zone->nr_pageblock_isolate--;
+}
+
 int set_migratetype_isolate(struct page *page)
 {
 	struct zone *zone;
@@ -54,7 +79,7 @@ int set_migratetype_isolate(struct page *page)
 
 out:
 	if (!ret) {
-		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+		set_pageblock_isolate(zone, page);
 		move_freepages_block(zone, page, MIGRATE_ISOLATE);
 	}
 
@@ -72,8 +97,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	set_pageblock_migratetype(page, migratetype);
 	move_freepages_block(zone, page, migratetype);
+	restore_pageblock_isolate(zone, page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
