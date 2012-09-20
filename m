Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 565DE6B0072
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 10:04:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/6] mm: compaction: Restart compaction from near where it left off
Date: Thu, 20 Sep 2012 15:04:35 +0100
Message-Id: <1348149875-29678-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-1-git-send-email-mgorman@suse.de>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is almost entirely based on Rik's previous patches and discussions
with him about how this might be implemented.

Order > 0 compaction stops when enough free pages of the correct page
order have been coalesced.  When doing subsequent higher order allocations,
it is possible for compaction to be invoked many times.

However, the compaction code always starts out looking for things to compact
at the start of the zone, and for free pages to compact things to at the
end of the zone.

This can cause quadratic behaviour, with isolate_freepages starting at
the end of the zone each time, even though previous invocations of the
compaction code already filled up all free memory on that end of the zone.
This can cause isolate_freepages to take enormous amounts of CPU with
certain workloads on larger memory systems.

This patch caches where the migration and free scanner should start from on
subsequent compaction invocations using the pageblock-skip information. When
compaction starts it begins from the cached restart points and will
update the cached restart points until a page is isolated or a pageblock
is skipped that would have been scanned by synchronous compaction.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    4 ++++
 mm/compaction.c        |   54 ++++++++++++++++++++++++++++++++++++++++--------
 mm/internal.h          |    4 ++++
 3 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a456361..e7792a3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -370,6 +370,10 @@ struct zone {
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 	unsigned long		compact_blockskip_expire;
+
+	/* pfns where compaction scanners should start */
+	unsigned long		compact_cached_free_pfn;
+	unsigned long		compact_cached_migrate_pfn;
 #endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
diff --git a/mm/compaction.c b/mm/compaction.c
index fae0011..45a17c9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -79,6 +79,9 @@ static void reset_isolation_suitable(struct zone *zone)
 	 */
 	if (time_before(jiffies, zone->compact_blockskip_expire))
 		return;
+
+	zone->compact_cached_migrate_pfn = start_pfn;
+	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_expire = jiffies + (HZ * 5);
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
@@ -99,13 +102,29 @@ static void reset_isolation_suitable(struct zone *zone)
  * If no pages were isolated then mark this pageblock to be skipped in the
  * future. The information is later cleared by reset_isolation_suitable().
  */
-static void update_pageblock_skip(struct page *page, unsigned long nr_isolated)
+static void update_pageblock_skip(struct compact_control *cc,
+			struct page *page, unsigned long nr_isolated,
+			bool migrate_scanner)
 {
+	struct zone *zone = cc->zone;
 	if (!page)
 		return;
 
-	if (!nr_isolated)
+	if (!nr_isolated) {
+		unsigned long pfn = page_to_pfn(page);
 		set_pageblock_skip(page);
+
+		/* Update where compaction should restart */
+		if (migrate_scanner) {
+			if (!cc->finished_update_migrate &&
+			    pfn > zone->compact_cached_migrate_pfn)
+				zone->compact_cached_migrate_pfn = pfn;
+		} else {
+			if (!cc->finished_update_free &&
+			    pfn < zone->compact_cached_free_pfn)
+				zone->compact_cached_free_pfn = pfn;
+		}
+	}
 }
 
 static inline bool should_release_lock(spinlock_t *lock)
@@ -257,7 +276,7 @@ out:
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(valid_page, total_isolated);
+		update_pageblock_skip(cc, valid_page, total_isolated, false);
 
 	return total_isolated;
 }
@@ -472,6 +491,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 */
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
+			cc->finished_update_migrate = true;
 			goto next_pageblock;
 		}
 
@@ -520,6 +540,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
+		cc->finished_update_migrate = true;
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
@@ -546,7 +567,7 @@ next_pageblock:
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (low_pfn == end_pfn)
-		update_pageblock_skip(valid_page, nr_isolated);
+		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
@@ -627,8 +648,10 @@ static void isolate_freepages(struct zone *zone,
 		 * looking for free pages, the search will restart here as
 		 * page migration may have returned some pages to the allocator
 		 */
-		if (isolated)
+		if (isolated) {
+			cc->finished_update_free = true;
 			high_pfn = max(high_pfn, pfn);
+		}
 	}
 
 	/* split_free_page does not map the pages */
@@ -818,6 +841,8 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	ret = compaction_suitable(zone, cc->order);
 	switch (ret) {
@@ -830,10 +855,21 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		;
 	}
 
-	/* Setup to move all movable pages to the end of the zone */
-	cc->migrate_pfn = zone->zone_start_pfn;
-	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
-	cc->free_pfn &= ~(pageblock_nr_pages-1);
+	/*
+	 * Setup to move all movable pages to the end of the zone. Used cached
+	 * information on where the scanners should start but check that it
+	 * is initialised by ensuring the values are within zone boundaries.
+	 */
+	cc->migrate_pfn = zone->compact_cached_migrate_pfn;
+	cc->free_pfn = zone->compact_cached_free_pfn;
+	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
+		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
+		zone->compact_cached_free_pfn = cc->free_pfn;
+	}
+	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
+		cc->migrate_pfn = start_pfn;
+		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
+	}
 
 	/* Clear pageblock skip if there are numerous alloc failures */
 	if (zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT)
diff --git a/mm/internal.h b/mm/internal.h
index aeae7eb..d5c1163 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -121,6 +121,10 @@ struct compact_control {
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool finished_update_free;	/* True when the zone cached pfns are
+					 * no longer being updated
+					 */
+	bool finished_update_migrate;
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
