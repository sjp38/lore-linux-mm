Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACCE6B2CEE
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:45:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so5635150edd.11
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:45:31 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id l24si321599edr.135.2018.11.23.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:45:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 9B74C1C2CEA
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:45:29 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/5] mm: Move zone watermark accesses behind an accessor
Date: Fri, 23 Nov 2018 11:45:25 +0000
Message-Id: <20181123114528.28802-3-mgorman@techsingularity.net>
In-Reply-To: <20181123114528.28802-1-mgorman@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

This is a preparation patch only, no functional change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  9 +++++----
 mm/compaction.c        |  2 +-
 mm/page_alloc.c        | 12 ++++++------
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 847705a6d0ec..e43e8e79db99 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -269,9 +269,10 @@ enum zone_watermarks {
 	NR_WMARK
 };
 
-#define min_wmark_pages(z) (z->watermark[WMARK_MIN])
-#define low_wmark_pages(z) (z->watermark[WMARK_LOW])
-#define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
+#define min_wmark_pages(z) (z->_watermark[WMARK_MIN])
+#define low_wmark_pages(z) (z->_watermark[WMARK_LOW])
+#define high_wmark_pages(z) (z->_watermark[WMARK_HIGH])
+#define wmark_pages(z, i) (z->_watermark[i])
 
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
@@ -362,7 +363,7 @@ struct zone {
 	/* Read-mostly fields */
 
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
-	unsigned long watermark[NR_WMARK];
+	unsigned long _watermark[NR_WMARK];
 
 	unsigned long nr_reserved_highatomic;
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..ef29490b0f46 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1431,7 +1431,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	if (is_via_compact_memory(order))
 		return COMPACT_CONTINUE;
 
-	watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+	watermark = wmark_pages(zone, alloc_flags & ALLOC_WMARK_MASK);
 	/*
 	 * If watermarks for high-order allocation are already met, there
 	 * should be no need for compaction at all.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f86638aee96a..4ba84cd2977a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3376,7 +3376,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
-		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		mark = wmark_pages(zone, alloc_flags & ALLOC_WMARK_MASK);
 		if (!zone_watermark_fast(zone, order, mark,
 				       ac_classzone_idx(ac), alloc_flags)) {
 			int ret;
@@ -4796,7 +4796,7 @@ long si_mem_available(void)
 		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
 	for_each_zone(zone)
-		wmark_low += zone->watermark[WMARK_LOW];
+		wmark_low += low_wmark_pages(zone);
 
 	/*
 	 * Estimate the amount of memory available for userspace allocations,
@@ -7422,13 +7422,13 @@ static void __setup_per_zone_wmarks(void)
 
 			min_pages = zone->managed_pages / 1024;
 			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
-			zone->watermark[WMARK_MIN] = min_pages;
+			zone->_watermark[WMARK_MIN] = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->watermark[WMARK_MIN] = tmp;
+			zone->_watermark[WMARK_MIN] = tmp;
 		}
 
 		/*
@@ -7440,8 +7440,8 @@ static void __setup_per_zone_wmarks(void)
 			    mult_frac(zone->managed_pages,
 				      watermark_scale_factor, 10000));
 
-		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
+		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
-- 
2.16.4
