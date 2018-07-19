Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF3F6B026B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:27:49 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d10-v6so3659656wrw.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:27:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5-v6sor1201560wml.63.2018.07.19.06.27.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 06:27:47 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Date: Thu, 19 Jul 2018 15:27:38 +0200
Message-Id: <20180719132740.32743-4-osalvador@techadventures.net>
In-Reply-To: <20180719132740.32743-1-osalvador@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

In free_area_init_core we calculate the amount of managed pages
we are left with, by substracting the memmap pages and the pages
reserved for dma.
With the values left, we also account the total of kernel pages and
the total of pages.

Since memmap pages are calculated from zone->spanned_pages,
let us only do these calculcations whenever zone->spanned_pages is greather
than 0.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 73 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 35 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10b754fba5fa..f7a6f4e13f41 100644
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
@@ -6267,43 +6301,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, freesize, memmap_pages;
+		unsigned long size = zone->spanned_pages;
+		unsigned long freesize = zone->present_pages;
 		unsigned long zone_start_pfn = zone->zone_start_pfn;
 
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
+		if (size)
+			freesize = calc_remaining_pages(j, freesize, size);
 
 		/*
 		 * Set an approximate value for lowmem here, it will be adjusted
-- 
2.13.6
