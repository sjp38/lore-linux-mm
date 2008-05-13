Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m4DBwRwr129246
	for <linux-mm@kvack.org>; Tue, 13 May 2008 11:58:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DBwQ642818168
	for <linux-mm@kvack.org>; Tue, 13 May 2008 12:58:26 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DBwQb2022259
	for <linux-mm@kvack.org>; Tue, 13 May 2008 12:58:26 +0100
Date: Tue, 13 May 2008 13:58:25 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: memory_hotplug: always initialize pageblock bitmap.
Message-ID: <20080513115825.GB12339@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com> <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com> <20080510124501.GA4796@osiris.boeblingen.de.ibm.com> <20080512105500.ff89c0d3.kamezawa.hiroyu@jp.fujitsu.com> <20080512181928.cd41c055.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080512181928.cd41c055.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Trying to online a new memory section that was added via memory hotplug
sometimes results in crashes when the new pages are added via __free_page.
Reason for that is that the pageblock bitmap isn't initialized and hence
contains random stuff.  That means that get_pageblock_migratetype() returns
also random stuff and therefore

	list_add(&page->lru,
		&zone->free_area[order].free_list[migratetype]);

in __free_one_page() tries to do a list_add to something that isn't even
necessarily a list.

This happens since 86051ca5eaf5e560113ec7673462804c54284456
("mm: fix usemap initialization") which makes sure that the pageblock
bitmap gets only initialized for pages present in a zone.
Unfortunately for hot-added memory the zones "grow" after the memmap
and the pageblock memmap have been initialized. Which means that the
new pages have an unitialized bitmap.
To solve this the calls to grow_zone_span() and grow_pgdat_span() are
moved to __add_zone() just before the initialization happens.

The patch also moves the two functions since __add_zone() is the only
caller and I didn't want to add a forward declaration.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |   83 +++++++++++++++++++++++++++-------------------------
 mm/page_alloc.c     |    3 -
 2 files changed, 45 insertions(+), 41 deletions(-)

Index: linux-2.6/mm/memory_hotplug.c
===================================================================
--- linux-2.6.orig/mm/memory_hotplug.c
+++ linux-2.6/mm/memory_hotplug.c
@@ -159,17 +159,58 @@ void register_page_bootmem_info_node(str
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
+static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
+			   unsigned long end_pfn)
+{
+	unsigned long old_zone_end_pfn;
+
+	zone_span_writelock(zone);
+
+	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	if (start_pfn < zone->zone_start_pfn)
+		zone->zone_start_pfn = start_pfn;
+
+	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
+				zone->zone_start_pfn;
+
+	zone_span_writeunlock(zone);
+}
+
+static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
+			    unsigned long end_pfn)
+{
+	unsigned long old_pgdat_end_pfn =
+		pgdat->node_start_pfn + pgdat->node_spanned_pages;
+
+	if (start_pfn < pgdat->node_start_pfn)
+		pgdat->node_start_pfn = start_pfn;
+
+	pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
+					pgdat->node_start_pfn;
+}
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
@@ -295,36 +336,6 @@ int __remove_pages(struct zone *zone, un
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
 
-static void grow_zone_span(struct zone *zone,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long old_zone_end_pfn;
-
-	zone_span_writelock(zone);
-
-	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	if (start_pfn < zone->zone_start_pfn)
-		zone->zone_start_pfn = start_pfn;
-
-	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
-				zone->zone_start_pfn;
-
-	zone_span_writeunlock(zone);
-}
-
-static void grow_pgdat_span(struct pglist_data *pgdat,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long old_pgdat_end_pfn =
-		pgdat->node_start_pfn + pgdat->node_spanned_pages;
-
-	if (start_pfn < pgdat->node_start_pfn)
-		pgdat->node_start_pfn = start_pfn;
-
-	pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
-					pgdat->node_start_pfn;
-}
-
 void online_page(struct page *page)
 {
 	totalram_pages++;
@@ -363,7 +374,6 @@ static int online_pages_range(unsigned l
 
 int online_pages(unsigned long pfn, unsigned long nr_pages)
 {
-	unsigned long flags;
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
@@ -391,11 +401,6 @@ int online_pages(unsigned long pfn, unsi
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
