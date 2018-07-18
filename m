Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2063F6B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:47:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q8-v6so1023235wmc.2
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:47:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o189-v6sor562889wmd.69.2018.07.18.05.47.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 05:47:38 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 2/3] mm/page_alloc: Refactor free_area_init_core
Date: Wed, 18 Jul 2018 14:47:21 +0200
Message-Id: <20180718124722.9872-3-osalvador@techadventures.net>
In-Reply-To: <20180718124722.9872-1-osalvador@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

When free_area_init_core gets called from the memhotplug code,
we only need to perform some of the operations in
there.

Since memhotplug code is the only place where free_area_init_core
gets called while node being still offline, we can better separate
the context from where it is called.

This patch re-structures the code for that purpose.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 94 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 52 insertions(+), 42 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a73305f7c55..d652a3ad720c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6237,6 +6237,40 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
 static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
 #endif
 
+static unsigned long calc_remaining_pages(enum zone_type type, unsigned long freesize,
+								unsigned long size)
+{
+	unsigned long memmap_pages = calc_memmap_size(size, freesize);
+
+	if(!is_highmem_idx(type)) {
+		if (freesize >= memmap_pages) {
+			freesize -= memmap_pages;
+			if (memmap_pages)
+				printk(KERN_DEBUG
+					"  %s zone: %lu pages used for memmap\n",
+					zone_names[type], memmap_pages);
+		} else
+			pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
+				zone_names[type], memmap_pages, freesize);
+	}
+
+	/* Account for reserved pages */
+	if (type == 0 && freesize > dma_reserve) {
+		freesize -= dma_reserve;
+		printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+		zone_names[0], dma_reserve);
+	}
+
+	if (!is_highmem_idx(type))
+		nr_kernel_pages += freesize;
+	/* Charge for highmem memmap if there are enough kernel pages */
+	else if (nr_kernel_pages > memmap_pages * 2)
+		nr_kernel_pages -= memmap_pages;
+	nr_all_pages += freesize;
+
+	return freesize;
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6249,6 +6283,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
+	bool no_hotplug_context;
 
 	pgdat_resize_init(pgdat);
 
@@ -6265,45 +6300,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 	pgdat->per_cpu_nodestats = &boot_nodestats;
 
+	/* Memhotplug is the only place where free_area_init_node gets called
+	 * with the node being still offline.
+	 */
+	no_hotplug_context = node_online(nid);
+
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, freesize, memmap_pages;
-		unsigned long zone_start_pfn = zone->zone_start_pfn;
+		unsigned long size = zone->spanned_pages;
+		unsigned long freesize = zone->present_pages;
 
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
-
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
+		if (no_hotplug_context)
+			freesize = calc_remaining_pages(j, freesize, size);
 
 		/*
 		 * Set an approximate value for lowmem here, it will be adjusted
@@ -6311,6 +6319,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		 * And all highmem pages will be managed by the buddy system.
 		 */
 		zone->managed_pages = freesize;
+
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 #endif
@@ -6320,13 +6329,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone_seqlock_init(zone);
 		zone_pcp_init(zone);
 
-		if (!size)
-			continue;
+		if (size && no_hotplug_context) {
+			unsigned long zone_start_pfn = zone->zone_start_pfn;
 
-		set_pageblock_order();
-		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		init_currently_empty_zone(zone, zone_start_pfn, size);
-		memmap_init(size, nid, j, zone_start_pfn);
+			set_pageblock_order();
+			setup_usemap(pgdat, zone, zone_start_pfn, size);
+			init_currently_empty_zone(zone, zone_start_pfn, size);
+			memmap_init(size, nid, j, zone_start_pfn);
+		}
 	}
 }
 
-- 
2.13.6
