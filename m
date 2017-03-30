Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF85B6B03A2
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k22so8174612wrk.5
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:05 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id 126si11783186wmt.160.2017.03.30.04.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:04 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id u18so11423168wrc.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:04 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] mm: remove return value from init_currently_empty_zone
Date: Thu, 30 Mar 2017 13:54:51 +0200
Message-Id: <20170330115454.32154-4-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-1-mhocko@kernel.org>
References: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

init_currently_empty_zone doesn't have any error to return yet it is
still an int and callers try to be defensive and try to handle potential
error. Remove this nonsense and simplify all callers.

This patch shouldn't have any visible effect

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  2 +-
 mm/memory_hotplug.c    | 25 ++++++-------------------
 mm/page_alloc.c        |  6 ++----
 3 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dbe3b32fe85d..c86c78617d17 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -768,7 +768,7 @@ enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
 };
-extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
+extern void init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 				     unsigned long size);
 
 extern void lruvec_init(struct lruvec *lruvec);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 699f5a2a8efd..056dbbe6d20e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -343,27 +343,20 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
 }
 
-/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
- * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
-static int __ref ensure_zone_is_initialized(struct zone *zone,
+static void __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
-	if (zone_is_empty(zone))
-		return init_currently_empty_zone(zone, start_pfn, num_pages);
-
-	return 0;
+	if (!zone_is_empty(zone))
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
 
@@ -399,13 +392,10 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
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
 
@@ -476,12 +466,9 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
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
index af58b51c5897..c6127f1a62e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5518,7 +5518,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 					 zone_batchsize(zone));
 }
 
-int __meminit init_currently_empty_zone(struct zone *zone,
+void __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
 					unsigned long size)
 {
@@ -5997,7 +5997,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	int ret;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -6079,8 +6078,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 
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
