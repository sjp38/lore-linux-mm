Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AB3386B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 15:00:30 -0500 (EST)
Received: by wmec201 with SMTP id c201so154264660wme.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 12:00:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bi6si68932210wjb.3.2015.11.30.12.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 12:00:29 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/2] mm: page_alloc: generalize the dirty balance reserve
Date: Mon, 30 Nov 2015 15:00:21 -0500
Message-Id: <1448913622-24198-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The dirty balance reserve that dirty throttling has to consider is
merely memory not available to userspace allocations. There is nothing
writeback-specific about it. Generalize the name so that it's reusable
outside of that context.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  6 +++---
 include/linux/swap.h   |  1 -
 mm/page-writeback.c    | 14 ++++++++++++--
 mm/page_alloc.c        | 21 +++------------------
 4 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..9134ae3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -361,10 +361,10 @@ struct zone {
 	struct per_cpu_pageset __percpu *pageset;
 
 	/*
-	 * This is a per-zone reserve of pages that should not be
-	 * considered dirtyable memory.
+	 * This is a per-zone reserve of pages that are not available
+	 * to userspace allocations.
 	 */
-	unsigned long		dirty_balance_reserve;
+	unsigned long		totalreserve_pages;
 
 #ifndef CONFIG_SPARSEMEM
 	/*
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dcc..066bd21 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -287,7 +287,6 @@ static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
-extern unsigned long dirty_balance_reserve;
 extern unsigned long nr_free_buffer_pages(void);
 extern unsigned long nr_free_pagecache_pages(void);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2c90357..8e5f2fd 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -278,7 +278,12 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
 	unsigned long nr_pages;
 
 	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
-	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
+	/*
+	 * Pages reserved for the kernel should not be considered
+	 * dirtyable, to prevent a situation where reclaim has to
+	 * clean pages in order to balance the zones.
+	 */
+	nr_pages -= min(nr_pages, zone->totalreserve_pages);
 
 	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
 	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
@@ -332,7 +337,12 @@ static unsigned long global_dirtyable_memory(void)
 	unsigned long x;
 
 	x = global_page_state(NR_FREE_PAGES);
-	x -= min(x, dirty_balance_reserve);
+	/*
+	 * Pages reserved for the kernel should not be considered
+	 * dirtyable, to prevent a situation where reclaim has to
+	 * clean pages in order to balance the zones.
+	 */
+	x -= min(x, totalreserve_pages);
 
 	x += global_page_state(NR_INACTIVE_FILE);
 	x += global_page_state(NR_ACTIVE_FILE);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a3c66..e786d7e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -114,13 +114,6 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 unsigned long totalcma_pages __read_mostly;
-/*
- * When calculating the number of globally allowed dirty pages, there
- * is a certain number of per-zone reserves that should not be
- * considered dirtyable memory.  This is the sum of those reserves
- * over all existing zones that contribute dirtyable memory.
- */
-unsigned long dirty_balance_reserve __read_mostly;
 
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
@@ -5955,20 +5948,12 @@ static void calculate_totalreserve_pages(void)
 
 			if (max > zone->managed_pages)
 				max = zone->managed_pages;
+
+			zone->totalreserve_pages = max;
+
 			reserve_pages += max;
-			/*
-			 * Lowmem reserves are not available to
-			 * GFP_HIGHUSER page cache allocations and
-			 * kswapd tries to balance zones to their high
-			 * watermark.  As a result, neither should be
-			 * regarded as dirtyable memory, to prevent a
-			 * situation where reclaim has to clean pages
-			 * in order to balance the zones.
-			 */
-			zone->dirty_balance_reserve = max;
 		}
 	}
-	dirty_balance_reserve = reserve_pages;
 	totalreserve_pages = reserve_pages;
 }
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
