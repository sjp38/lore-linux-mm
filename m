Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEF8B6B0008
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:01:55 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d1-v6so5162339wrr.4
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:01:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4-v6sor6194264wrp.65.2018.07.25.15.01.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 15:01:54 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v3 5/5] mm/page_alloc: Introduce memhotplug version of free_area_init_core
Date: Thu, 26 Jul 2018 00:01:44 +0200
Message-Id: <20180725220144.11531-6-osalvador@techadventures.net>
In-Reply-To: <20180725220144.11531-1-osalvador@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, we call free_area_init_node() from the memhotplug path.
In there, we set some pgdat's fields, and call calculate_node_totalpages().
calculate_node_totalpages() calculates the # of pages the node has.

Since the node is either new, or we are re-using it, the zones belonging to
this node should not have any pages, so there is no point to calculate this now.

Actually, we set the values to 0 later on with the calls to:

reset_node_managed_pages()
reset_node_present_pages()

The # of pages per zone and the # of pages per zone will be calculated later on
when onlining the pages:

online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_zone_range()
online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_pgdat_range()

This introduces the memhotplug version of free_area_init_core and makes
hotadd_new_pgdat use it.

This function will only be called from memhotplug path:

hotadd_new_pgdat()->free_area_init_core_hotplug().

free_area_init_core_hotplug() performs only a subset of the actions that
free_area_init_core_hotplug() does.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/mm.h  |  1 +
 mm/memory_hotplug.c | 23 +++++++++--------------
 mm/page_alloc.c     | 19 +++++++++++++++++++
 3 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6954ad183159..20430becd908 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2001,6 +2001,7 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern void free_area_init_core_hotplug(int nid);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4eb6e824a80c..bef8a3f7a760 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -978,12 +978,11 @@ static void reset_node_present_pages(pg_data_t *pgdat)
 	pgdat->node_present_pages = 0;
 }
 
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
 	struct pglist_data *pgdat;
-	unsigned long zones_size[MAX_NR_ZONES] = {0};
-	unsigned long zholes_size[MAX_NR_ZONES] = {0};
 	unsigned long start_pfn = PFN_DOWN(start);
 
 	pgdat = NODE_DATA(nid);
@@ -1006,8 +1005,11 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 	/* we can use NODE_DATA(nid) from here */
 
+	pgdat->node_id = nid;
+	pgdat->node_start_pfn = start_pfn;
+
 	/* init node's zones as empty zones, we don't have any present pages.*/
-	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
+	free_area_init_core_hotplug(nid);
 	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
 
 	/*
@@ -1017,18 +1019,11 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	build_all_zonelists(pgdat);
 
 	/*
-	 * zone->managed_pages is set to an approximate value in
-	 * free_area_init_core(), which will cause
-	 * /sys/device/system/node/nodeX/meminfo has wrong data.
-	 * So reset it to 0 before any memory is onlined.
-	 */
+         * When memory is hot-added, all the memory is in offline state. So
+         * clear all zones' present_pages because they will be updated in
+         * online_pages() and offline_pages().
+         */
 	reset_node_managed_pages(pgdat);
-
-	/*
-	 * When memory is hot-added, all the memory is in offline state. So
-	 * clear all zones' present_pages because they will be updated in
-	 * online_pages() and offline_pages().
-	 */
 	reset_node_present_pages(pgdat);
 
 	return pgdat;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a455dc85da19..a36b4db26b50 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6265,6 +6265,25 @@ static void zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
 }
 
 /*
+ * Set up the zone data structures
+ * - init pgdat internals
+ * - init all zones belonging to this node
+ *
+ * NOTE: this function is only called during memory hotplug
+ */
+void __paginginit free_area_init_core_hotplug(int nid)
+{
+	enum zone_type j;
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+	pgdat_init_internals(pgdat);
+	for(j = 0; j < MAX_NR_ZONES; j++) {
+		struct zone *zone = pgdat->node_zones + j;
+		zone_init_internals(zone, j, nid, 0);
+	}
+}
+
+/*
  * Set up the zone data structures:
  *   - mark all pages reserved
  *   - mark all memory queues empty
-- 
2.13.6
