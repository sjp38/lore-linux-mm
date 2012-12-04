Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 47A356B0068
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 17:10:06 -0500 (EST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCH] mm: Use aligned zone start for pfn_to_bitidx calculation
Date: Tue,  4 Dec 2012 14:10:01 -0800
Message-Id: <1354659001-13673-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

The current calculation in pfn_to_bitidx assumes that
(pfn - zone->zone_start_pfn) >> pageblock_order will return the
same bit for all pfn in a pageblock. If zone_start_pfn is not
aligned to pageblock_nr_pages, this may not always be correct.

Consider the following with pageblock order = 10, zone start 2MB:

pfn     | pfn - zone start | (pfn - zone start) >> page block order
----------------------------------------------------------------
0x26000 | 0x25e00	   |  0x97
0x26100 | 0x25f00	   |  0x97
0x26200 | 0x26000	   |  0x98
0x26300 | 0x26100	   |  0x98

This means that calling {get,set}_pageblock_migratetype on a single
page will not set the migratetype for the full block. The correct
fix is to round down zone_start_pfn for the bit index calculation.
Rather than do this calculation everytime, store this precalcualted
algined start in the zone structure to allow the actual start_pfn to
be used elsewhere.

Change-Id: I13e2f53f50db294f38ec86138c17c6fe29f0ee82
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 include/linux/mmzone.h |    6 ++++++
 mm/page_alloc.c        |    4 +++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 08f74e6..0a5471b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -467,6 +467,12 @@ struct zone {
 	struct pglist_data	*zone_pgdat;
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
+	/*
+	 * the starting pfn of the zone may not be aligned to the pageblock
+	 * size which can throw off calculation of the pageblock flags.
+	 * This is the precomputed aligned start of the zone
+	 */
+	unsigned long		aligned_start_pfn;
 
 	/*
 	 * zone_start_pfn, spanned_pages and present_pages are all
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3142e8..d78e1d6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3968,6 +3968,8 @@ __meminit int init_currently_empty_zone(struct zone *zone,
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;
+	zone->aligned_start_pfn = round_down(zone_start_pfn,
+						pageblock_nr_pages);
 
 	mminit_dprintk(MMINIT_TRACE, "memmap_init",
 			"Initialising map node %d zone %lu pfns %lu -> %lu\n",
@@ -5424,7 +5426,7 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
 	pfn &= (PAGES_PER_SECTION-1);
 	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #else
-	pfn = pfn - zone->zone_start_pfn;
+	pfn = pfn - zone->aligned_start_pfn;
 	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #endif /* CONFIG_SPARSEMEM */
 }
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
