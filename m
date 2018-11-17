Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E779F6B0CAD
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 21:21:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a22-v6so11649710plm.23
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 18:21:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor4220851pgq.13.2018.11.16.18.21.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 18:21:38 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Date: Sat, 17 Nov 2018 10:20:22 +0800
Message-Id: <20181117022022.9956-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Function init_currently_empty_zone() will adjust pgdat->nr_zones and set
it to 'zone_idx(zone) + 1' unconditionally. This is correct in the
normal case, while not exact in hot-plug situation.

This function is used in two places:

  * free_area_init_core()
  * move_pfn_range_to_zone()

In the first case, we are sure zone index increase monotonically. While
in the second one, this is under users control.

One way to reproduce this is:
----------------------------

1. create a virtual machine with empty node1

   -m 4G,slots=32,maxmem=32G \
   -smp 4,maxcpus=8          \
   -numa node,nodeid=0,mem=4G,cpus=0-3 \
   -numa node,nodeid=1,mem=0G,cpus=4-7

2. hot-add cpu 3-7

   cpu-add [3-7]

2. hot-add memory to nod1

   object_add memory-backend-ram,id=ram0,size=1G
   device_add pc-dimm,id=dimm0,memdev=ram0,node=1

3. online memory with following order

   echo online_movable > memory47/state
   echo online > memory40/state

After this, node1 will have its nr_zones equals to (ZONE_NORMAL + 1)
instead of (ZONE_MOVABLE + 1).

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b7cd20dbaef..2d3c54201255 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5823,8 +5823,10 @@ void __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long size)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	int zone_idx = zone_idx(zone) + 1;
 
-	pgdat->nr_zones = zone_idx(zone) + 1;
+	if (zone_idx > pgdat->nr_zones)
+		pgdat->nr_zones = zone_idx;
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-- 
2.15.1
