Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 603D86B0390
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:05:53 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o22so122995323iod.6
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:05:53 -0700 (PDT)
Received: from mail-io0-f196.google.com (mail-io0-f196.google.com. [209.85.223.196])
        by mx.google.com with ESMTPS id r203si1852343itc.71.2017.04.21.05.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:05:52 -0700 (PDT)
Received: by mail-io0-f196.google.com with SMTP id d203so29735351iof.2
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:05:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 01/13] mm: remove return value from init_currently_empty_zone
Date: Fri, 21 Apr 2017 14:05:04 +0200
Message-Id: <20170421120512.23960-2-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

From: Michal Hocko <mhocko@suse.com>

init_currently_empty_zone doesn't have any error to return yet it is
still an int and callers try to be defensive and try to handle potential
error. Remove this nonsense and simplify all callers.

This patch shouldn't have any visible effect

Acked-by: Balbir Singh <bsingharora@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  2 +-
 mm/memory_hotplug.c    | 23 +++++------------------
 mm/page_alloc.c        |  8 ++------
 3 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ebaccd4e7d8c..0fc121bbf4ff 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -771,7 +771,7 @@ enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
 };
-extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
+extern void init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 				     unsigned long size);
 
 extern void lruvec_init(struct lruvec *lruvec);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b63d7d1239df..b93c88125766 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -348,27 +348,20 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
 }
 
-/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
- * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
-static int __ref ensure_zone_is_initialized(struct zone *zone,
+static void __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
 	if (!zone_is_initialized(zone))
-		return init_currently_empty_zone(zone, start_pfn, num_pages);
-
-	return 0;
+		init_currently_empty_zone(zone, start_pfn, num_pages);
 }
 
 static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
-	int ret;
 	unsigned long flags;
 	unsigned long z1_start_pfn;
 
-	ret = ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
-	if (ret)
-		return ret;
+	ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -404,13 +397,10 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
-	int ret;
 	unsigned long flags;
 	unsigned long z2_end_pfn;
 
-	ret = ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
-	if (ret)
-		return ret;
+	ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -481,12 +471,9 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	int nid = pgdat->node_id;
 	int zone_type;
 	unsigned long flags, pfn;
-	int ret;
 
 	zone_type = zone - pgdat->node_zones;
-	ret = ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
-	if (ret)
-		return ret;
+	ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2c687d5cecf..5d72d29a6ece 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5528,7 +5528,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 					 zone_batchsize(zone));
 }
 
-int __meminit init_currently_empty_zone(struct zone *zone,
+void __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
 					unsigned long size)
 {
@@ -5546,8 +5546,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 
 	zone_init_free_lists(zone);
 	zone->initialized = 1;
-
-	return 0;
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
@@ -6010,7 +6008,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	int ret;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -6092,8 +6089,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
 		set_pageblock_order();
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
-		BUG_ON(ret);
+		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
 	}
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
