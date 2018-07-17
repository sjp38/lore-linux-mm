Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 655CB6B000D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:56:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g9-v6so268206wrq.7
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:56:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15-v6sor334253wrg.22.2018.07.17.03.56.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 03:56:55 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 2/3] mm: Refactor free_area_init_core
Date: Tue, 17 Jul 2018 12:56:21 +0200
Message-Id: <20180717105622.12410-3-osalvador@techadventures.net>
In-Reply-To: <20180717105622.12410-1-osalvador@techadventures.net>
References: <20180717105622.12410-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, akpm@linux-foundation.org, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

When free_area_init_core gets called from the memhotplug code,
we do not really need to go through all memmap calculations.

This structures the code a bit better.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 106 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 57 insertions(+), 49 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a73305f7c55..3bf939393ca1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6237,6 +6237,42 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
 static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
 #endif
 
+static void calculate_pages(enum zone_type type, unsigned long *freesize,
+							unsigned long size)
+{
+	/*
+	 * Adjust freesize so that it accounts for how much memory
+	 * is used by this zone for memmap. This affects the watermark
+	 * and per-cpu initialisations
+	 */
+	unsigned long memmap_pages = calc_memmap_size(size, *freesize);
+
+	if (!is_highmem_idx(type)) {
+		if (*freesize >= memmap_pages) {
+			freesize -= memmap_pages;
+			if (memmap_pages)
+				printk(KERN_DEBUG
+					"  %s zone: %lu pages used for memmap\n",
+					zone_names[type], memmap_pages);
+		} else
+			pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
+				zone_names[type], memmap_pages, *freesize);
+	}
+
+	if (type == 0 && *freesize > dma_reserve) {
+		*freesize -= dma_reserve;
+		printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+					zone_names[0], dma_reserve);
+	}
+
+	if (!is_highmem_idx(type))
+		nr_kernel_pages += *freesize;
+	/* Charge for highmem memmap if there are enough kernel pages */
+	else if (nr_kernel_pages > memmap_pages * 2)
+		nr_kernel_pages -= memmap_pages;
+	nr_all_pages += *freesize;
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6267,50 +6303,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, freesize, memmap_pages;
-		unsigned long zone_start_pfn = zone->zone_start_pfn;
-
-		size = zone->spanned_pages;
-		freesize = zone->present_pages;
-
-		/*
-		 * Adjust freesize so that it accounts for how much memory
-		 * is used by this zone for memmap. This affects the watermark
-		 * and per-cpu initialisations
-		 */
-		memmap_pages = calc_memmap_size(size, freesize);
-		if (!is_highmem_idx(j)) {
-			if (freesize >= memmap_pages) {
-				freesize -= memmap_pages;
-				if (memmap_pages)
-					printk(KERN_DEBUG
-					       "  %s zone: %lu pages used for memmap\n",
-					       zone_names[j], memmap_pages);
-			} else
-				pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
-					zone_names[j], memmap_pages, freesize);
-		}
 
-		/* Account for reserved pages */
-		if (j == 0 && freesize > dma_reserve) {
-			freesize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
-					zone_names[0], dma_reserve);
-		}
-
-		if (!is_highmem_idx(j))
-			nr_kernel_pages += freesize;
-		/* Charge for highmem memmap if there are enough kernel pages */
-		else if (nr_kernel_pages > memmap_pages * 2)
-			nr_kernel_pages -= memmap_pages;
-		nr_all_pages += freesize;
-
-		/*
-		 * Set an approximate value for lowmem here, it will be adjusted
-		 * when the bootmem allocator frees pages into the buddy system.
-		 * And all highmem pages will be managed by the buddy system.
-		 */
-		zone->managed_pages = freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 #endif
@@ -6320,13 +6313,28 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		if (!size)
-			continue;
+		if(system_state == SYSTEM_BOOTING) {
+			unsigned long size, freesize;
+			unsigned long zone_start_pfn = zone->zone_start_pfn;
 
-		set_pageblock_order();
-		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		init_currently_empty_zone(zone, zone_start_pfn, size);
-		memmap_init(size, nid, j, zone_start_pfn);
+			size = zone->spanned_pages;
+			freesize = zone->present_pages;
+			calculate_pages(j, &freesize, size);
+
+			/*
+			 * Set an approximate value for lowmem here, it will be adjusted
+			 * when the bootmem allocator frees pages into the buddy system.
+			 * And all highmem pages will be managed by the buddy system.
+			 */
+			zone->managed_pages = freesize;
+			if (!size)
+				continue;
+
+			set_pageblock_order();
+			setup_usemap(pgdat, zone, zone_start_pfn, size);
+			init_currently_empty_zone(zone, zone_start_pfn, size);
+			memmap_init(size, nid, j, zone_start_pfn);
+		}
 	}
 }
 
-- 
2.13.6
