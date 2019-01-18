Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96A398E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:55:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f17so5240942edm.20
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:55:22 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id w58si5438430edc.162.2019.01.18.09.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:55:20 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 97DFDB8A73
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:55:20 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/22] mm, compaction: Be selective about what pageblocks to clear skip hints
Date: Fri, 18 Jan 2019 17:51:35 +0000
Message-Id: <20190118175136.31341-22-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Pageblock hints are cleared when compaction restarts or kswapd makes enough
progress that it can sleep but it's over-eager in that the bit is cleared
for migration sources with no LRU pages and migration targets with no free
pages. As pageblock skip hint flushes are relatively rare and out-of-band
with respect to kswapd, this patch makes a few more expensive checks to
see if it's appropriate to even clear the bit. Every pageblock that is
not cleared will avoid 512 pages being scanned unnecessarily on x86-64.

The impact is variable with different workloads showing small differences
in latency, success rates and scan rates. This is expected as clearing
the hints is not that common but doing a small amount of work out-of-band
to avoid a large amount of work in-band later is generally a good thing.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |   2 +
 mm/compaction.c        | 125 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 109 insertions(+), 18 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..90c13cdeefb5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -480,6 +480,8 @@ struct zone {
 	unsigned long		compact_cached_free_pfn;
 	/* pfn where async and sync compaction migration scanner should start */
 	unsigned long		compact_cached_migrate_pfn[2];
+	unsigned long		compact_init_migrate_pfn;
+	unsigned long		compact_init_free_pfn;
 #endif
 
 #ifdef CONFIG_COMPACTION
diff --git a/mm/compaction.c b/mm/compaction.c
index 74bf620e3dcd..de558f110319 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -237,6 +237,71 @@ static bool pageblock_skip_persistent(struct page *page)
 	return false;
 }
 
+static bool
+__reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
+							bool check_target)
+{
+	struct page *page = pfn_to_online_page(pfn);
+	struct page *end_page;
+	unsigned long block_pfn;
+
+	if (!page)
+		return false;
+	if (zone != page_zone(page))
+		return false;
+	if (pageblock_skip_persistent(page))
+		return false;
+
+	/*
+	 * If skip is already cleared do no further checking once the
+	 * restart points have been set.
+	 */
+	if (check_source && check_target && !get_pageblock_skip(page))
+		return true;
+
+	/*
+	 * If clearing skip for the target scanner, do not select a
+	 * non-movable pageblock as the starting point.
+	 */
+	if (!check_source && check_target &&
+	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
+		return false;
+
+	/*
+	 * Only clear the hint if a sample indicates there is either a
+	 * free page or an LRU page in the block. One or other condition
+	 * is necessary for the block to be a migration source/target.
+	 */
+	block_pfn = pageblock_start_pfn(pfn);
+	pfn = max(block_pfn, zone->zone_start_pfn);
+	page = pfn_to_page(pfn);
+	if (zone != page_zone(page))
+		return false;
+	pfn = block_pfn + pageblock_nr_pages;
+	pfn = min(pfn, zone_end_pfn(zone));
+	end_page = pfn_to_page(pfn);
+
+	do {
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		if (check_source && PageLRU(page)) {
+			clear_pageblock_skip(page);
+			return true;
+		}
+
+		if (check_target && PageBuddy(page)) {
+			clear_pageblock_skip(page);
+			return true;
+		}
+
+		page += (1 << PAGE_ALLOC_COSTLY_ORDER);
+		pfn += (1 << PAGE_ALLOC_COSTLY_ORDER);
+	} while (page < end_page);
+
+	return false;
+}
+
 /*
  * This function is called to clear all cached information on pageblocks that
  * should be skipped for page isolation when the migrate and free page scanner
@@ -244,30 +309,54 @@ static bool pageblock_skip_persistent(struct page *page)
  */
 static void __reset_isolation_suitable(struct zone *zone)
 {
-	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone_end_pfn(zone);
-	unsigned long pfn;
+	unsigned long migrate_pfn = zone->zone_start_pfn;
+	unsigned long free_pfn = zone_end_pfn(zone);
+	unsigned long reset_migrate = free_pfn;
+	unsigned long reset_free = migrate_pfn;
+	bool source_set = false;
+	bool free_set = false;
 
-	zone->compact_blockskip_flush = false;
+	if (!zone->compact_blockskip_flush)
+		return;
 
-	/* Walk the zone and mark every pageblock as suitable for isolation */
-	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
-		struct page *page;
+	zone->compact_blockskip_flush = false;
 
+	/*
+	 * Walk the zone and update pageblock skip information. Source looks
+	 * for PageLRU while target looks for PageBuddy. When the scanner
+	 * is found, both PageBuddy and PageLRU are checked as the pageblock
+	 * is suitable as both source and target.
+	 */
+	for (; migrate_pfn < free_pfn; migrate_pfn += pageblock_nr_pages,
+					free_pfn -= pageblock_nr_pages) {
 		cond_resched();
 
-		page = pfn_to_online_page(pfn);
-		if (!page)
-			continue;
-		if (zone != page_zone(page))
-			continue;
-		if (pageblock_skip_persistent(page))
-			continue;
+		/* Update the migrate PFN */
+		if (__reset_isolation_pfn(zone, migrate_pfn, true, source_set) &&
+		    migrate_pfn < reset_migrate) {
+			source_set = true;
+			reset_migrate = migrate_pfn;
+			zone->compact_init_migrate_pfn = reset_migrate;
+			zone->compact_cached_migrate_pfn[0] = reset_migrate;
+			zone->compact_cached_migrate_pfn[1] = reset_migrate;
+		}
 
-		clear_pageblock_skip(page);
+		/* Update the free PFN */
+		if (__reset_isolation_pfn(zone, free_pfn, free_set, true) &&
+		    free_pfn > reset_free) {
+			free_set = true;
+			reset_free = free_pfn;
+			zone->compact_init_free_pfn = reset_free;
+			zone->compact_cached_free_pfn = reset_free;
+		}
 	}
 
-	reset_cached_positions(zone);
+	/* Leave no distance if no suitable block was reset */
+	if (reset_migrate >= reset_free) {
+		zone->compact_cached_migrate_pfn[0] = migrate_pfn;
+		zone->compact_cached_migrate_pfn[1] = migrate_pfn;
+		zone->compact_cached_free_pfn = free_pfn;
+	}
 }
 
 void reset_isolation_suitable(pg_data_t *pgdat)
@@ -1190,7 +1279,7 @@ fast_isolate_freepages(struct compact_control *cc)
 	 * If starting the scan, use a deeper search and use the highest
 	 * PFN found if a suitable one is not found.
 	 */
-	if (cc->free_pfn == pageblock_start_pfn(zone_end_pfn(cc->zone) - 1)) {
+	if (cc->free_pfn >= cc->zone->compact_init_free_pfn) {
 		limit = pageblock_nr_pages >> 1;
 		scan_start = true;
 	}
@@ -2015,7 +2104,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			cc->zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 		}
 
-		if (cc->migrate_pfn == start_pfn)
+		if (cc->migrate_pfn <= cc->zone->compact_init_migrate_pfn)
 			cc->whole_zone = true;
 	}
 
-- 
2.16.4
