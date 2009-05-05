Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43E196B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 07:09:05 -0400 (EDT)
Date: Tue, 5 May 2009 13:06:53 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap has unexpected holes
Message-ID: <20090505110653.GA16649@cmpxchg.org>
References: <20090505082944.GA25904@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090505082944.GA25904@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, linux@arm.linux.org.uk, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, May 05, 2009 at 09:29:44AM +0100, Mel Gorman wrote:
> pfn_valid() is meant to be able to tell if a given PFN has valid memmap
> associated with it or not. In FLATMEM, it is expected that holes always
> have valid memmap as long as there is valid PFNs either side of the hole.
> In SPARSEMEM, it is assumed that a valid section has a memmap for the
> entire section.
> 
> However, ARM and maybe other embedded architectures in the future free
> memmap backing holes to save memory on the assumption the memmap is never
> used. The page_zone() linkages are then broken even though pfn_valid()
> returns true. A walker of the full memmap in this case must do additional
> check to ensure the memmap they are looking at is sane by making sure the
> zone and PFN linkages are still valid. This is expensive, but walkers of
> the full memmap are extremely rare.
> 
> This was caught before for FLATMEM and hacked around but it hits again
> for SPARSEMEM because the page_zone() linkages can look ok where the PFN
> linkages are totally screwed. This looks like a hatchet job but the reality
> is that any clean solution would end up consuming all the memory saved
> by punching these unexpected holes in the memmap. For example, we tried
> marking the memmap within the section invalid but the section size exceeds
> the size of the hole in most cases so pfn_valid() starts returning false
> where valid memmap exists. Shrinking the size of the section would increase
> memory consumption offsetting the gains.
> 
> This patch identifies when an architecture is punching unexpected holes
> in the memmap that the memory model cannot automatically detect. When set,
> walkers of the full memmap must call memmap_valid_within() for each PFN and
> passing in what it expects the page and zone to be for that PFN. If it finds
> the linkages to be broken, it assumes the memmap is invalid for that PFN.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I think we also need to fix up show_mem().  Attached is a
compile-tested patch, please have a look.  I am not sure about memory
hotplug issues but on a quick glance the vmstat stuff seems to be
optimistic as well.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: lib: adjust show_mem() to support memmap holes

Some architectures free the backing of mem_map holes.  pfn_valid() is
not able to report this properly, so a stronger check is needed if the
caller is about to use the page descriptor derived from a pfn.

Change the node walking to zone walking and use memmap_valid_within()
to check for holes.  This is reliable as it additionally checks for
page_zone() and page_to_pfn() coherency.

Not-yet-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 lib/show_mem.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index 238e72a..ed3c3ec 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -11,29 +11,27 @@
 
 void show_mem(void)
 {
-	pg_data_t *pgdat;
 	unsigned long total = 0, reserved = 0, shared = 0,
 		nonshared = 0, highmem = 0;
+	struct zone *zone;
 
 	printk(KERN_INFO "Mem-Info:\n");
 	show_free_areas();
 
-	for_each_online_pgdat(pgdat) {
-		unsigned long i, flags;
+	for_each_populated_zone(zone) {
+		unsigned long start = zone->zone_start_pfn;
+		unsigned long end = start + zone->spanned_pages;
+		unsigned long pfn;
 
-		pgdat_resize_lock(pgdat, &flags);
-		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page;
-			unsigned long pfn = pgdat->node_start_pfn + i;
+		for (pfn = start; pfn < end; pfn++) {
+			struct page *page = pfn_to_page(pfn);
 
-			if (unlikely(!(i % MAX_ORDER_NR_PAGES)))
+			if (unlikely(!(pfn % MAX_ORDER_NR_PAGES)))
 				touch_nmi_watchdog();
 
-			if (!pfn_valid(pfn))
+			if (!memmap_valid_within(pfn, page, zone))
 				continue;
 
-			page = pfn_to_page(pfn);
-
 			if (PageHighMem(page))
 				highmem++;
 
@@ -46,7 +44,6 @@ void show_mem(void)
 
 			total++;
 		}
-		pgdat_resize_unlock(pgdat, &flags);
 	}
 
 	printk(KERN_INFO "%lu pages RAM\n", total);
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
