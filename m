Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6875A6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:12:31 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:12:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/9] mm: compaction: Cache if a pageblock was scanned and
 no pages were isolated
Message-ID: <20120927131224.GD3429@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-9-git-send-email-mgorman@suse.de>
 <20120921143656.60a9a6cd.akpm@linux-foundation.org>
 <20120924093938.GZ11266@suse.de>
 <20120924142644.06c38b80.akpm@linux-foundation.org>
 <20120925091207.GD11266@suse.de>
 <20120925130352.0d60957a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120925130352.0d60957a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 25, 2012 at 01:03:52PM -0700, Andrew Morton wrote:
> On Tue, 25 Sep 2012 10:12:07 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > First, we'd introduce a variant of get_pageblock_migratetype() that returns
> > all the bits for the pageblock flags and then helpers to extract either the
> > migratetype or the PG_migrate_skip. We already are incurring the cost of
> > get_pageblock_migratetype() so it will not be much more expensive than what
> > is already there. If there is an allocation or free within a pageblock that
> > as the PG_migrate_skip bit set then we increment a counter. When the counter
> > reaches some to-be-decided "threshold" then compaction may clear all the
> > bits. This would match the criteria of the clearing being based on activity.
> > 
> > There are four potential problems with this
> > 
> > 1. The logic to retrieve all the bits and split them up will be a little
> >    convulated but maybe it would not be that bad.
> > 
> > 2. The counter is a shared-writable cache line but obviously it could
> >    be moved to vmstat and incremented with inc_zone_page_state to offset
> >    the cost a little.
> > 
> > 3. The biggested weakness is that there is not way to know if the
> >    counter is incremented based on activity in a small subset of blocks.
> > 
> > 4. What should the threshold be?
> > 
> > The first problem is minor but the other three are potentially a mess.
> > Adding another vmstat counter is bad enough in itself but if the counter
> > is incremented based on a small subsets of pageblocks, the hint becomes
> > is potentially useless.
> > 
> > However, does this match what you have in mind or am I over-complicating
> > things?
> 
> Sounds complicated.
> 
> Using wall time really does suck. 

I know, we spent a fair amount of effort getting rid of congestion_wait()
from paths it did not belong to for similar reasons.

> Are you sure you can't think of
> something more logical?
> 

No, I'm not sure.

As a matter of general policy I should not encourage this but apparently
you can nag better code out of me, patch is below :). I would rather it
was added on top rather than merged with the time-based series so it can
be reverted easily if necessary.

> How would we demonstrate the suckage?  What would be the observeable downside of
> switching that 5 seconds to 5 hours?
> 

Reduced allocation success rates.

> > Lets take an unlikely case - 128G single-node machine. That loop count
> > on x86-64 would be 65536. It'll be fast enough, particularly in this
> > path.
> 
> That could easily exceed a millisecond.  Can/should we stick a
> cond_resched() in there?

Ok, I think it is very unlikely but not impossible. I posted a patch for
it already.

Here is a candidate patch that replaces the time heuristic with one that
is based on VM activity. My own testing indicate that scan rates are
slightly higher with this patch than the time heuristic but well within
acceptable limits.

Richard, can you also test this patch and make sure your test case has
not regressed again please?

---8<---
mm: compaction: Clear PG_migrate_skip based on compaction and reclaim activity

Compaction caches if a pageblock was scanned and no pages were isolated
so that the pageblocks can be skipped in the future to reduce scanning.
This information is not cleared by the page allocator based on activity
due to the impact it would have to the page allocator fast paths. Hence
there is a requirement that something clear the cache or pageblocks will
be skipped forever. Currently the cache is cleared if there were a number
of recent allocation failures and it has not been cleared within the last
5 seconds. Time-based decisions like this are terrible as they have no
relationship to VM activity and is basically a big hammer.

Unfortunately, accurate heuristics would add cost to some hot paths so this
patch implements a rough heuristic. There are two cases where the cache
is cleared.

1. If a !kswapd process completes a compaction cycle (migrate and free
   scanner meet), the zone is marked compact_blockskip_flush. When kswapd
   goes to sleep, it will clear the cache. This is expected to be the
   common case where the cache is cleared. It does not really matter if
   kswapd happens to be asleep or going to sleep when the flag is set as
   it will be woken on the next allocation request.

2. If there has been multiple failures recently and compaction just
   finished being deferred then a process will clear the cache and start
   a full scan. This situation happens if there are multiple high-order
   allocation requests under heavy memory pressure.

The clearing of the PG_migrate_skip bits and other scans is inherently
racy but the race is harmless. For allocations that can fail such as
THP, they will simply fail. For requests that cannot fail, they will
retry the allocation. Tests indicated that scanning rates were roughly
similar to when the time-based heuristic was used and the allocation
success rates were similar.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/compaction.h |   15 +++++++++++++
 include/linux/mmzone.h     |    3 ++-
 mm/compaction.c            |   50 ++++++++++++++++++++++++++++++--------------
 mm/page_alloc.c            |    1 +
 mm/vmscan.c                |    8 +++++++
 5 files changed, 60 insertions(+), 17 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0e38a1d..6ecb6dc 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -24,6 +24,7 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync, bool *contended, struct page **page);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
+extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
 /* Do not skip compaction more than 64 times */
@@ -61,6 +62,16 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return zone->compact_considered < defer_limit;
 }
 
+/* Returns true if restarting compaction after many failures */
+static inline bool compaction_restarting(struct zone *zone, int order)
+{
+	if (order < zone->compact_order_failed)
+		return false;
+
+	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
+		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+}
+
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
@@ -74,6 +85,10 @@ static inline int compact_pgdat(pg_data_t *pgdat, int order)
 	return COMPACT_CONTINUE;
 }
 
+static inline void reset_isolation_suitable(pg_data_t *pgdat)
+{
+}
+
 static inline unsigned long compaction_suitable(struct zone *zone, int order)
 {
 	return COMPACT_SKIPPED;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e7792a3..ddce36a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -369,7 +369,8 @@ struct zone {
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
-	unsigned long		compact_blockskip_expire;
+	/* Set to true when the PG_migrate_skip bits should be cleared */
+	bool			compact_blockskip_flush;
 
 	/* pfns where compaction scanners should start */
 	unsigned long		compact_cached_free_pfn;
diff --git a/mm/compaction.c b/mm/compaction.c
index 55d0999..8250b69 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -66,24 +66,15 @@ static inline bool isolation_suitable(struct compact_control *cc,
  * should be skipped for page isolation when the migrate and free page scanner
  * meet.
  */
-static void reset_isolation_suitable(struct zone *zone)
+static void __reset_isolation_suitable(struct zone *zone)
 {
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 	unsigned long pfn;
 
-	/*
-	 * Do not reset more than once every five seconds. If allocations are
-	 * failing sufficiently quickly to allow this to happen then continually
-	 * scanning for compaction is not going to help. The choice of five
-	 * seconds is arbitrary but will mitigate excessive scanning.
-	 */
-	if (time_before(jiffies, zone->compact_blockskip_expire))
-		return;
-
 	zone->compact_cached_migrate_pfn = start_pfn;
 	zone->compact_cached_free_pfn = end_pfn;
-	zone->compact_blockskip_expire = jiffies + (HZ * 5);
+	zone->compact_blockskip_flush = false;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
@@ -102,9 +93,24 @@ static void reset_isolation_suitable(struct zone *zone)
 	}
 }
 
+void reset_isolation_suitable(pg_data_t *pgdat)
+{
+	int zoneid;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		struct zone *zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		/* Only flush if a full compaction finished recently */
+		if (zone->compact_blockskip_flush)
+			__reset_isolation_suitable(zone);
+	}
+}
+
 /*
  * If no pages were isolated then mark this pageblock to be skipped in the
- * future. The information is later cleared by reset_isolation_suitable().
+ * future. The information is later cleared by __reset_isolation_suitable().
  */
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
@@ -827,7 +833,15 @@ static int compact_finished(struct zone *zone,
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
-		reset_isolation_suitable(cc->zone);
+		/*
+		 * Mark that the PG_migrate_skip information should be cleared
+		 * by kswapd when it goes to sleep. kswapd does not set the
+		 * flag itself as the decision to be clear should be directly
+		 * based on an allocation request.
+		 */
+		if (!current_is_kswapd())
+			zone->compact_blockskip_flush = true;
+		
 		return COMPACT_COMPLETE;
 	}
 
@@ -950,9 +964,13 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
 	}
 
-	/* Clear pageblock skip if there are numerous alloc failures */
-	if (zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT)
-		reset_isolation_suitable(zone);
+	/*
+	 * Clear pageblock skip if there were failures recently and compaction
+	 * is about to be retried after being deferred. kswapd does not do
+	 * this reset as it'll reset the cached information when going to sleep.
+	 */
+	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+		__reset_isolation_suitable(zone);
 
 	migrate_prep_local();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ba34eee..0a1906b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2166,6 +2166,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				preferred_zone, migratetype);
 		if (page) {
 got_page:
+			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;
 			if (order >= preferred_zone->compact_order_failed)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f8f56f8..12b5b5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2895,6 +2895,14 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 
+		/*
+		 * Compaction records what page blocks it recently failed to
+		 * isolate pages from and skips them in the future scanning.
+		 * When kswapd is going to sleep, it is reasonable to assume
+		 * that pages and compaction may succeed so reset the cache.
+		 */
+		reset_isolation_suitable(pgdat);
+
 		if (!kthread_should_stop())
 			schedule();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
