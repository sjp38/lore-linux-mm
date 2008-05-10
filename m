Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m4ACj2Cb439312
	for <linux-mm@kvack.org>; Sat, 10 May 2008 12:45:02 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4ACj2vf3960846
	for <linux-mm@kvack.org>; Sat, 10 May 2008 14:45:02 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4ACj2hJ020997
	for <linux-mm@kvack.org>; Sat, 10 May 2008 14:45:02 +0200
Date: Sat, 10 May 2008 14:45:01 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] memory_hotplug: always initialize pageblock bitmap.
Message-ID: <20080510124501.GA4796@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com> <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 03:39:10PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 9 May 2008 08:06:09 +0200
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > Trying to online a new memory section that was added via memory hotplug
> > sometimes results in crashes when the new pages are added via
> > __free_page. Reason for that is that the pageblock bitmap isn't
> > initialized and hence contains random stuff.
> 
> Hmm, curious. In my understanding, memmap_init_zone() initializes it.
> 
>  __add_pages()
> 	-> __add_section()
> 		-> sparse-add_one_section() // allocate usemap
> 		-> __add_zone()
> 			-> memmap_init_zone() // reset pageblock's bitmap 
> 
> Can't memmap_init_zone() does proper initialization ?
> ........................
> Ah, ok. I see. grow_zone_span() is not called at __add_zone(), then,
> memmap_init_zone() doesn't initialize usemap because memmap is not in zone's
> range.

Now I got it. So my patch was incorrect, it just worked around the crash.

> Recently, I added a check "zone's start_pfn < pfn < zone's end"
> to memmap_init_zone()'s usemap initialization for !SPARSEMEM case bug FIX.
> (and I think the fix itself is sane.)

Oh, you broke memory hot-add on -stable ;)

> How about calling grow_pgdat_span()/grow_zone_span() from __add_zone() ?

Like this?

Note that this patch is on top of the other patch I already sent, but
reverts it...

This works for me. A final version (if this is acceptable) should move
the grow* functions also.

---
 mm/memory_hotplug.c |   28 +++++++++++++++++++---------
 mm/page_alloc.c     |    3 +--
 2 files changed, 20 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/memory_hotplug.c
===================================================================
--- linux-2.6.orig/mm/memory_hotplug.c
+++ linux-2.6/mm/memory_hotplug.c
@@ -159,17 +159,33 @@ void register_page_bootmem_info_node(str
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
+static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
+			   unsigned long end_pfn);
+static void grow_pgdat_span(struct pglist_data *pgdat,
+			    unsigned long start_pfn, unsigned long end_pfn);
+
 static int __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
 	int zone_type;
+	unsigned long flags;
 
 	zone_type = zone - pgdat->node_zones;
-	if (!zone->wait_table)
-		return init_currently_empty_zone(zone, phys_start_pfn,
-						 nr_pages, MEMMAP_HOTPLUG);
+	if (!zone->wait_table) {
+		int ret;
+
+		ret = init_currently_empty_zone(zone, phys_start_pfn,
+						nr_pages, MEMMAP_HOTPLUG);
+		if (ret)
+			return ret;
+	}
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
+	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
+			phys_start_pfn + nr_pages);
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;
@@ -363,7 +379,6 @@ static int online_pages_range(unsigned l
 
 int online_pages(unsigned long pfn, unsigned long nr_pages)
 {
-	unsigned long flags;
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
@@ -391,11 +406,6 @@ int online_pages(unsigned long pfn, unsi
 	 * memory_block->state_mutex.
 	 */
 	zone = page_zone(pfn_to_page(pfn));
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, pfn, pfn + nr_pages);
-	grow_pgdat_span(zone->zone_pgdat, pfn, pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
-
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
 	 * This means the page allocator ignores this zone.
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -2862,8 +2862,6 @@ __meminit int init_currently_empty_zone(
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
-
 	zone_init_free_lists(zone);
 
 	return 0;
@@ -3433,6 +3431,7 @@ static void __paginginit free_area_init_
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
 		BUG_ON(ret);
+		memmap_init(size, nid, j, zone_start_pfn);
 		zone_start_pfn += size;
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
