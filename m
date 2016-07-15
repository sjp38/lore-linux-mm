Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFFE46B0263
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:34 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id c124so105442360ywd.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:34 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id g134si532530wme.1.2016.07.15.06.09.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 06:09:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 1AF8599317
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:09:27 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/5] mm: show node_pages_scanned per node, not zone
Date: Fri, 15 Jul 2016 14:09:24 +0100
Message-Id: <1468588165-12461-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Minchan Kim <minchan@kernel.org>

The node_pages_scanned represents the number of scanned pages
of node for reclaim so it's pointless to show it as kilobytes.

As well, node_pages_scanned is per-node value, not per-zone.

This patch changes node_pages_scanned per-zone-killobytes
with per-node-count.

Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f80a0e57dcc8..7edd311a63f1 100644
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
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
