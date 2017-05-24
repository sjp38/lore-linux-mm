Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD93E6B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 08:24:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a203so23433642wma.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:24:19 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 61si19278008wrp.328.2017.05.24.05.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 05:24:18 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d127so46966262wmf.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:24:18 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm, memory_hotplug: drop artificial restriction on online/offline
Date: Wed, 24 May 2017 14:24:10 +0200
Message-Id: <20170524122411.25212-2-mhocko@kernel.org>
In-Reply-To: <20170524122411.25212-1-mhocko@kernel.org>
References: <20170524122411.25212-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
memory") has added can_offline_normal which checks the amount of
memory in !movable zones as long as CONFIG_MOVABLE_NODE is disable.
It disallows to offline memory if there is nothing left with a
justification that "memory-management acts bad when we have nodes which
is online but don't have any normal memory".

74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
memory") has introduced a restriction that every numa node has to have
at least some memory in !movable zones before a first movable memory
can be onlined if !CONFIG_MOVABLE_NODE with the same justification

While it is true that not having _any_ memory for kernel allocations on
a NUMA node is far from great and such a node would be quite subotimal
because all kernel allocations will have to fallback to another NUMA
node but there is no reason to disallow such a configuration in
principle.

Besides that there is not really a big difference to have one memblock
for ZONE_NORMAL available or none. With 128MB size memblocks the system
might trash on the kernel allocations requests anyway. It is really
hard to draw a line on how much normal memory is really sufficient so
we have to rely on administrator to configure system sanely therefore
drop the artificial restriction and remove can_offline_normal and
can_online_high_movable altogether.

Signed-off-by: Michal Hocko <mhocko@suse.com>

mm, memory_hotplug: drop can_online_high_movable

 because "memory-management acts
bad when we have nodes which is online but don't have any normal memory.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 58 -----------------------------------------------------
 1 file changed, 58 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 599c675ad538..10052c2fd400 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -763,23 +763,6 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	return 0;
 }
 
-#ifdef CONFIG_MOVABLE_NODE
-/*
- * When CONFIG_MOVABLE_NODE, we permit onlining of a node which doesn't have
- * normal memory.
- */
-static bool can_online_high_movable(int nid)
-{
-	return true;
-}
-#else /* CONFIG_MOVABLE_NODE */
-/* ensure every online node has NORMAL memory */
-static bool can_online_high_movable(int nid)
-{
-	return node_state(nid, N_NORMAL_MEMORY);
-}
-#endif /* CONFIG_MOVABLE_NODE */
-
 /* check which state of node_states will be changed when online memory */
 static void node_states_check_changes_online(unsigned long nr_pages,
 	struct zone *zone, struct memory_notify *arg)
@@ -979,9 +962,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
 		return -EINVAL;
 
-	if (online_type == MMOP_ONLINE_MOVABLE && !can_online_high_movable(nid))
-		return -EINVAL;
-
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
 
@@ -1579,41 +1559,6 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
-#ifdef CONFIG_MOVABLE_NODE
-/*
- * When CONFIG_MOVABLE_NODE, we permit offlining of a node which doesn't have
- * normal memory.
- */
-static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
-{
-	return true;
-}
-#else /* CONFIG_MOVABLE_NODE */
-/* ensure the node has NORMAL memory if it is still online */
-static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
-{
-	struct pglist_data *pgdat = zone->zone_pgdat;
-	unsigned long present_pages = 0;
-	enum zone_type zt;
-
-	for (zt = 0; zt <= ZONE_NORMAL; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
-
-	if (present_pages > nr_pages)
-		return true;
-
-	present_pages = 0;
-	for (; zt <= ZONE_MOVABLE; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
-
-	/*
-	 * we can't offline the last normal memory until all
-	 * higher memory is offlined.
-	 */
-	return present_pages == 0;
-}
-#endif /* CONFIG_MOVABLE_NODE */
-
 static int __init cmdline_parse_movable_node(char *p)
 {
 #ifdef CONFIG_MOVABLE_NODE
@@ -1741,9 +1686,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
-	if (zone_idx(zone) <= ZONE_NORMAL && !can_offline_normal(zone, nr_pages))
-		return -EINVAL;
-
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
 				       MIGRATE_MOVABLE, true);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
