Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFE76B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:32:41 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id he10so34602512wjc.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:32:41 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id dy10si6825914wjb.80.2016.12.16.04.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 04:32:40 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so5153307wma.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:32:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: simplify node/zone name printing
Date: Fri, 16 Dec 2016 13:32:32 +0100
Message-Id: <20161216123232.26307-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

show_node currently only prints Node id while it is always followed by
printing zone->name. As the node information is conditional to
CONFIG_NUMA we have to be careful to always terminate the previous
continuation line before printing the zone name. This is quite ugly
and easy to mess up. Let's rename show_node to show_zone_node and
make sure that it will always start at a new line. We can drop the ugly
printk(KERN_CONT "\n") from show_free_areas.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this has been sitting in my tree since oct and I completely forgot about
it. Does this look like a reasonable clean up to you?

 mm/page_alloc.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f2c9e535f7f..5324efa8b9d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4120,10 +4120,12 @@ unsigned long nr_free_pagecache_pages(void)
 	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
 }
 
-static inline void show_node(struct zone *zone)
+static inline void show_zone_node(struct zone *zone)
 {
 	if (IS_ENABLED(CONFIG_NUMA))
-		printk("Node %d ", zone_to_nid(zone));
+		printk("Node %d %s", zone_to_nid(zone), zone->name);
+	else
+		printk("%s: ", zone->name);
 }
 
 long si_mem_available(void)
@@ -4371,9 +4373,8 @@ void show_free_areas(unsigned int filter)
 		for_each_online_cpu(cpu)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 
-		show_node(zone);
+		show_zone_node(zone);
 		printk(KERN_CONT
-			"%s"
 			" free:%lukB"
 			" min:%lukB"
 			" low:%lukB"
@@ -4396,7 +4397,6 @@ void show_free_areas(unsigned int filter)
 			" local_pcp:%ukB"
 			" free_cma:%lukB"
 			"\n",
-			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
@@ -4421,7 +4421,6 @@ void show_free_areas(unsigned int filter)
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
-		printk(KERN_CONT "\n");
 	}
 
 	for_each_populated_zone(zone) {
@@ -4431,8 +4430,7 @@ void show_free_areas(unsigned int filter)
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
-		show_node(zone);
-		printk(KERN_CONT "%s: ", zone->name);
+		show_zone_node(zone);
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
