Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DABC6B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:52:20 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q62so166938949oih.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 21:52:20 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p75si7110272ioo.101.2016.07.14.21.52.18
        for <linux-mm@kvack.org>;
        Thu, 14 Jul 2016 21:52:19 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: show node_pages_scanned per node, not zone
Date: Fri, 15 Jul 2016 13:52:16 +0900
Message-Id: <1468558336-14379-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

The node_pages_scanned represents the number of scanned pages
of node for reclaim so it's pointless to show it as kilobytes.

As well, node_pages_scanned is per-node value, not per-zone.

This patch changes node_pages_scannerd per-zone-killobytes
with per-node-count.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f80a0e5..7edd311 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4345,6 +4345,7 @@ void show_free_areas(unsigned int filter)
 #endif
 			" writeback_tmp:%lukB"
 			" unstable:%lukB"
+			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -4367,6 +4368,7 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_SHMEM)),
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
+			node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -4397,7 +4399,6 @@ void show_free_areas(unsigned int filter)
 			" free_pcp:%lukB"
 			" local_pcp:%ukB"
 			" free_cma:%lukB"
-			" node_pages_scanned:%lu"
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
@@ -4415,8 +4416,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
-			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
+			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(" %ld", zone->lowmem_reserve[i]);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
