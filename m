Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 536036B0069
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 10:04:43 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] Revert "mm: have order > 0 compaction start off where it left"
Date: Thu, 20 Sep 2012 15:04:33 +0100
Message-Id: <1348149875-29678-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-1-git-send-email-mgorman@suse.de>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts commit 7db8889a (mm: have order > 0 compaction start off
where it left) and commit de74f1cc (mm: have order > 0 compaction start
near a pageblock with free pages). These patches were a good idea and
tests confirmed that they massively reduced the amount of scanning but
the implementation is complex and tricky to understand. A later patch
will cache what pageblocks should be skipped and reimplements the
concept of compact_cached_free_pfn on top for both migration and
free scanners.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    4 ---
 mm/compaction.c        |   65 ++++--------------------------------------------
 mm/internal.h          |    6 -----
 mm/page_alloc.c        |    5 ----
 4 files changed, 5 insertions(+), 75 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..603d0b5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -368,10 +368,6 @@ struct zone {
 	 */
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
-#if defined CONFIG_COMPACTION || defined CONFIG_CMA
-	/* pfn where the last incremental compaction isolated free pages */
-	unsigned long		compact_cached_free_pfn;
-#endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
diff --git a/mm/compaction.c b/mm/compaction.c
index 70c7cbd..6058822 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -481,20 +481,6 @@ next_pageblock:
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
 /*
- * Returns the start pfn of the last page block in a zone.  This is the starting
- * point for full compaction of a zone.  Compaction searches for free pages from
- * the end of each zone, while isolate_freepages_block scans forward inside each
- * page block.
- */
-static unsigned long start_free_pfn(struct zone *zone)
-{
-	unsigned long free_pfn;
-	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	free_pfn &= ~(pageblock_nr_pages-1);
-	return free_pfn;
-}
-
-/*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
@@ -562,19 +548,8 @@ static void isolate_freepages(struct zone *zone,
 		 * looking for free pages, the search will restart here as
 		 * page migration may have returned some pages to the allocator
 		 */
-		if (isolated) {
+		if (isolated)
 			high_pfn = max(high_pfn, pfn);
-
-			/*
-			 * If the free scanner has wrapped, update
-			 * compact_cached_free_pfn to point to the highest
-			 * pageblock with free pages. This reduces excessive
-			 * scanning of full pageblocks near the end of the
-			 * zone
-			 */
-			if (cc->order > 0 && cc->wrapped)
-				zone->compact_cached_free_pfn = high_pfn;
-		}
 	}
 
 	/* split_free_page does not map the pages */
@@ -582,11 +557,6 @@ static void isolate_freepages(struct zone *zone,
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
-
-	/* If compact_cached_free_pfn is reset then set it now */
-	if (cc->order > 0 && !cc->wrapped &&
-			zone->compact_cached_free_pfn == start_free_pfn(zone))
-		zone->compact_cached_free_pfn = high_pfn;
 }
 
 /*
@@ -682,26 +652,8 @@ static int compact_finished(struct zone *zone,
 	if (fatal_signal_pending(current))
 		return COMPACT_PARTIAL;
 
-	/*
-	 * A full (order == -1) compaction run starts at the beginning and
-	 * end of a zone; it completes when the migrate and free scanner meet.
-	 * A partial (order > 0) compaction can start with the free scanner
-	 * at a random point in the zone, and may have to restart.
-	 */
-	if (cc->free_pfn <= cc->migrate_pfn) {
-		if (cc->order > 0 && !cc->wrapped) {
-			/* We started partway through; restart at the end. */
-			unsigned long free_pfn = start_free_pfn(zone);
-			zone->compact_cached_free_pfn = free_pfn;
-			cc->free_pfn = free_pfn;
-			cc->wrapped = 1;
-			return COMPACT_CONTINUE;
-		}
-		return COMPACT_COMPLETE;
-	}
-
-	/* We wrapped around and ended up where we started. */
-	if (cc->wrapped && cc->free_pfn <= cc->start_free_pfn)
+	/* Compaction run completes if the migrate and free scanner meet */
+	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;
 
 	/*
@@ -799,15 +751,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	/* Setup to move all movable pages to the end of the zone */
 	cc->migrate_pfn = zone->zone_start_pfn;
-
-	if (cc->order > 0) {
-		/* Incremental compaction. Start where the last one stopped. */
-		cc->free_pfn = zone->compact_cached_free_pfn;
-		cc->start_free_pfn = cc->free_pfn;
-	} else {
-		/* Order == -1 starts at the end of the zone. */
-		cc->free_pfn = start_free_pfn(zone);
-	}
+	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
+	cc->free_pfn &= ~(pageblock_nr_pages-1);
 
 	migrate_prep_local();
 
diff --git a/mm/internal.h b/mm/internal.h
index 4bd7c0e..04ab01a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -118,14 +118,8 @@ struct compact_control {
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
-	unsigned long start_free_pfn;	/* where we started the search */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
-	bool wrapped;			/* Order > 0 compactions are
-					   incremental, once free_pfn
-					   and migrate_pfn meet, we restart
-					   from the top of the zone;
-					   remember we wrapped around. */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c66fb87..46b2db3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4438,11 +4438,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
-#if defined CONFIG_COMPACTION || defined CONFIG_CMA
-		zone->compact_cached_free_pfn = zone->zone_start_pfn +
-						zone->spanned_pages;
-		zone->compact_cached_free_pfn &= ~(pageblock_nr_pages-1);
-#endif
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
