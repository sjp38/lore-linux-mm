Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 649636B000C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:01:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f13-v6so3682577wmb.4
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:01:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor1449666wmd.76.2018.07.25.15.01.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 15:01:54 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v3 4/5] mm/page_alloc: Move initialization of node and zones to an own function
Date: Thu, 26 Jul 2018 00:01:43 +0200
Message-Id: <20180725220144.11531-5-osalvador@techadventures.net>
In-Reply-To: <20180725220144.11531-1-osalvador@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, whenever a new node is created/re-used from the memhotplug path,
we call free_area_init_node()->free_area_init_core().
But there is some code that we do not really need to run when we are coming
from such path.

free_area_init_core() performs the following actions:

1) Initializes pgdat internals, such as spinlock, waitqueues and more.
2) Account # nr_all_pages and nr_kernel_pages. These values are used later on
   when creating hash tables.
3) Account number of managed_pages per zone, substracting dma_reserved and memmap pages.
4) Initializes some fields of the zone structure data
5) Calls init_currently_empty_zone to initialize all the freelists
6) Calls memmap_init to initialize all pages belonging to certain zone

When called from memhotplug path, free_area_init_core() only performs actions #1 and #4.

Action #2 is pointless as the zones do not have any pages since either the node was freed,
or we are re-using it, eitherway all zones belonging to this node should have 0 pages.
For the same reason, action #3 results always in manages_pages being 0.

Action #5 and #6 are performed later on when onlining the pages:
 online_pages()->move_pfn_range_to_zone()->init_currently_empty_zone()
 online_pages()->move_pfn_range_to_zone()->memmap_init_zone()

This patch moves the node/zone initializtion to their own function, so it allows us
to create a small version of free_area_init_core(next patch), where we only perform:

1) Initialization of pgdat internals, such as spinlock, waitqueues and more
4) Initialization of some fields of the zone structure data

This patch only introduces these two functions.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/page_alloc.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e84a17a5030..a455dc85da19 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6237,21 +6237,9 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
 static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
 #endif
 
-/*
- * Set up the zone data structures:
- *   - mark all pages reserved
- *   - mark all memory queues empty
- *   - clear the memory bitmaps
- *
- * NOTE: pgdat should get zeroed by caller.
- */
-static void __paginginit free_area_init_core(struct pglist_data *pgdat)
+static void __paginginit pgdat_init_internals(struct pglist_data *pgdat)
 {
-	enum zone_type j;
-	int nid = pgdat->node_id;
-
 	pgdat_resize_init(pgdat);
-
 	pgdat_init_numabalancing(pgdat);
 	pgdat_init_split_queue(pgdat);
 	pgdat_init_kcompactd(pgdat);
@@ -6262,7 +6250,35 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
 	lruvec_init(node_lruvec(pgdat));
+}
+
+static void zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
+							unsigned long remaining_pages)
+{
+	zone->managed_pages = remaining_pages;
+	zone_set_nid(zone, nid);
+	zone->name = zone_names[idx];
+	zone->zone_pgdat = NODE_DATA(nid);
+	spin_lock_init(&zone->lock);
+	zone_seqlock_init(zone);
+	zone_pcp_init(zone);
+}
+
+/*
+ * Set up the zone data structures:
+ *   - mark all pages reserved
+ *   - mark all memory queues empty
+ *   - clear the memory bitmaps
+ *
+ * NOTE: pgdat should get zeroed by caller.
+ * NOTE: this function is only called during early init.
+ */
+static void __paginginit free_area_init_core(struct pglist_data *pgdat)
+{
+	enum zone_type j;
+	int nid = pgdat->node_id;
 
+	pgdat_init_internals(pgdat);
 	pgdat->per_cpu_nodestats = &boot_nodestats;
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
@@ -6310,13 +6326,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		 * when the bootmem allocator frees pages into the buddy system.
 		 * And all highmem pages will be managed by the buddy system.
 		 */
-		zone->managed_pages = freesize;
-		zone_set_nid(zone, nid);
-		zone->name = zone_names[j];
-		zone->zone_pgdat = pgdat;
-		spin_lock_init(&zone->lock);
-		zone_seqlock_init(zone);
-		zone_pcp_init(zone);
+		zone_init_internals(zone, j, nid, freesize);
 
 		if (!size)
 			continue;
-- 
2.13.6
