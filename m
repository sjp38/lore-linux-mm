Message-ID: <4470232B.7040802@yahoo.com.au>
Date: Sun, 21 May 2006 18:22:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 1/2] mm: detect bad zones
Content-Type: multipart/mixed;
 boundary="------------090604020203090900060402"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090604020203090900060402
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I think the previous few patches / patchsets to handle the unaligned zone
thing aren't exactly what we want (at least, for 2.6.16.stable and 2.6.17).

Firstly, we need to check for buddies outside the zone span, not just those
which are in a different zone.

Secondly, I think aligned zones should be an opt-in thing. Performance hit
is not huge, but potential stability hit is.

-- 
SUSE Labs, Novell Inc.

--------------090604020203090900060402
Content-Type: text/plain;
 name="mm-detect-bad-zones.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-detect-bad-zones.patch"

panic when zones fail correct alignment and other checks.
The alternative could be random and/or undetected corruption later.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-05-19 13:15:51.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2006-05-21 12:22:44.000000000 +1000
@@ -2041,6 +2041,47 @@ static __meminit void zone_pcp_init(stru
 			zone->name, zone->present_pages, batch);
 }
 
+static __meminit void zone_debug_checks(struct zone *zone)
+{
+	unsigned long pfn;
+	unsigned long start = zone->zone_start_pfn;
+	unsigned long end = start + zone->spanned_pages;
+	const unsigned long mask = ((1<<MAX_ORDER)-1);
+	
+	if (start & mask)
+		panic("zone start pfn (%lx) not MAX_ORDER aligned\n", start);
+
+	if (end & mask)
+		panic("zone end pfn (%lx) not MAX_ORDER aligned\n", end);
+
+	for (pfn = start; pfn < end; pfn++) {
+		struct page *page;
+		int order;
+
+#ifndef CONFIG_HOLES_IN_ZONE
+		if (!pfn_valid(pfn))
+			panic("zone pfn (%lx) not valid\n", pfn);
+#endif
+
+		page = pfn_to_page(pfn);
+		if (page_zone(page) != zone)
+			panic("zone page (pfn %lx) in wrong zone\n", pfn);
+
+		for (order = 0; order < MAX_ORDER-1; order++) {
+			struct page *buddy;
+			buddy = __page_find_buddy(page, pfn & mask, order);
+
+#ifndef CONFIG_HOLES_IN_ZONE
+			if (!pfn_valid(page_to_pfn(buddy)))
+				panic("pfn (%lx) buddy (order %d) not valid\n", pfn, order);
+#endif
+
+			if (page_zone(buddy) != zone)
+				panic("pfn (%lx) buddy (order %d) in wrong zone\n", pfn, order);
+		}
+	}
+}
+
 static __meminit void init_currently_empty_zone(struct zone *zone,
 		unsigned long zone_start_pfn, unsigned long size)
 {
@@ -2054,6 +2095,8 @@ static __meminit void init_currently_emp
 	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
 
 	zone_init_free_lists(pgdat, zone, zone->spanned_pages);
+
+	zone_debug_checks(zone);
 }
 
 /*

--------------090604020203090900060402--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
