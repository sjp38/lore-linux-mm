Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 426896B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 06:03:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c2-v6so4474679edi.20
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:03:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4-v6sor956610edq.9.2018.07.20.03.03.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 03:03:28 -0700 (PDT)
Date: Fri, 20 Jul 2018 12:03:27 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180720100327.GA19478@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
 <20180719151555.GH7193@dhcp22.suse.cz>
 <20180719205235.GA14010@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719205235.GA14010@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 19, 2018 at 10:52:35PM +0200, Oscar Salvador wrote:
> On Thu, Jul 19, 2018 at 05:15:55PM +0200, Michal Hocko wrote:
> > Your changelog doesn't really explain the motivation. Does the change
> > help performance? Is this a pure cleanup?
> 
> Hi Michal,
> 
> Sorry to not have explained this better from the very beginning.
> 
> It should help a bit in performance terms as we would be skipping those
> condition checks and assignations for zones that do not have any pages.
> It is not a huge win, but I think that skipping code we do not really need to run
> is worh to have.
> 
> > The function is certainly not an example of beauty. It is more an
> > example of changes done on top of older ones without much thinking. But
> > I do not see your change would make it so much better. I would consider
> > it a much nicer cleanup if it was split into logical units each doing
> > one specific thing.
> 
> About the cleanup, I thought that moving that block of code to a separate function
> would make the code easier to follow.
> If you think that this is still not enough, I can try to split it and see the outcome.

I tried to split it innto three logical blocks:

- Substract memmap pages
- Substract dma reserves
- Account kernel pages (nr_kernel_pages and nr_total_pages)

Is this something that makes sense to you:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10b754fba5fa..1397dcdd4a3c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6237,6 +6237,47 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
 static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
 #endif
 
+static void account_kernel_pages(enum zone_type j, unsigned long freesize,
+						unsigned long memmap_pages)
+{
+	if (!is_highmem_idx(j))
+		nr_kernel_pages += freesize;
+	/* Charge for highmem memmap if there are enough kernel pages */
+	else if (nr_kernel_pages > memmap_pages * 2)
+		 nr_kernel_pages -= memmap_pages;
+	nr_all_pages += freesize;
+}
+
+static unsigned long substract_dma_reserves(unsigned long freesize)
+{
+	/* Account for reserved pages */
+	if (freesize > dma_reserve) {
+		freesize -= dma_reserve;
+		printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+					zone_names[0], dma_reserve);
+	}
+
+	return freesize;
+}
+
+static unsigned long substract_memmap_pages(unsigned long freesize, unsigned long memmap_pages)
+{
+	/*
+	 * Adjust freesize so that it accounts for how much memory
+	 * is used by this zone for memmap. This affects the watermark
+	 * and per-cpu initialisations
+	 */
+	if (freesize >= memmap_pages) {
+		freesize -= memmap_pages;
+		if (memmap_pages)
+			printk(KERN_DEBUG "  %s zone: %lu pages used for memmap\n",
+							zone_names[j], memmap_pages);
+	} else
+		pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
+				zone_names[j], memmap_pages, freesize);
+	return freesize;
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6267,44 +6308,20 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, freesize, memmap_pages;
+		unsigned long size = zone->spanned_pages
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
+		if (size) {
+			unsigned long memmap_pages = calc_memmap_size(size, freesize);
+			if (!is_highmem_idx(j))
+				freesize =  substract_memmap_pages(freesize, memmap_pages);
 
-		/* Account for reserved pages */
-		if (j == 0 && freesize > dma_reserve) {
-			freesize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
-					zone_names[0], dma_reserve);
+			if (j == ZONE_DMA)
+				freesize = substract_dma_reserves(freesize);
+			account_kernel_pages(j, freesize, memmap_pages);
 		}
 
-		if (!is_highmem_idx(j))
-			nr_kernel_pages += freesize;
-		/* Charge for highmem memmap if there are enough kernel pages */
-		else if (nr_kernel_pages > memmap_pages * 2)
-			nr_kernel_pages -= memmap_pages;
-		nr_all_pages += freesize;

Thanks
-- 
Oscar Salvador
SUSE L3
