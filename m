Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB3C86B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:11:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z16-v6so2011256wrs.22
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:11:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185-v6sor666349wmh.86.2018.07.18.08.11.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 08:11:56 -0700 (PDT)
Date: Wed, 18 Jul 2018 17:11:54 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/3] mm/page_alloc: Refactor free_area_init_core
Message-ID: <20180718151154.GA2875@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-3-osalvador@techadventures.net>
 <20180718133647.GD7193@dhcp22.suse.cz>
 <20180718141226.GA2588@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718141226.GA2588@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed, Jul 18, 2018 at 04:12:26PM +0200, Oscar Salvador wrote:
> On Wed, Jul 18, 2018 at 03:36:47PM +0200, Michal Hocko wrote:
> > I really do not like this if node is offline than only perform half of
> > the function. This will generate more mess in the future. Why don't you
> > simply. If we can split out this code into logical units then let's do
> > that but no, please do not make random ifs for hotplug code paths.
> > Sooner or later somebody will simply don't know what is needed and what
> > is not.
> 
> Yes, you are right.
> I gave it another thought and it was not a really good idea.
> Although I think the code from free_area_init_core can be simplified.
> 
> I will try to come up with something that makes more sense.

I guess we could so something like:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a73305f7c55..70fe4c80643f 100644
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
+		if (freesize)
+

 
So we just do the calculations with the pages (nr_kernel_pages, nr_all_pages, memmap_pages, etc...) 
if freesize is not 0.
Otherwise it does not make sense to do it (AFAICS).
-- 
Oscar Salvador
SUSE L3
