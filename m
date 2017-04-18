Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 619E56B03AB
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 20:06:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m1so100708061pgd.13
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:06:22 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id r17si12669148pge.276.2017.04.17.17.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 17:06:21 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id i5so72318498pfc.2
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:06:21 -0700 (PDT)
Date: Mon, 17 Apr 2017 17:06:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
not swap anon pages just because free+file is low'") reintroduces is to
prefer swapping anonymous memory rather than trashing the file lru.

If all anonymous memory is unevictable, however, this insistance on
SCAN_ANON ends up thrashing that lru instead.

Check that enough evictable anon memory is actually on this lruvec before
insisting on SCAN_ANON.  SWAP_CLUSTER_MAX is used as the threshold to
determine if only scanning anon is beneficial.

Otherwise, fallback to balanced reclaim so the file lru doesn't remain
untouched.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmscan.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2186,26 +2186,31 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
 	if (global_reclaim(sc)) {
-		unsigned long pgdatfile;
-		unsigned long pgdatfree;
-		int z;
-		unsigned long total_high_wmark = 0;
-
-		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
-		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
-			   node_page_state(pgdat, NR_INACTIVE_FILE);
-
-		for (z = 0; z < MAX_NR_ZONES; z++) {
-			struct zone *zone = &pgdat->node_zones[z];
-			if (!managed_zone(zone))
-				continue;
+		anon = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON, sc->reclaim_idx) +
+		       lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx);
+		if (likely(anon >= SWAP_CLUSTER_MAX)) {
+			unsigned long total_high_wmark = 0;
+			unsigned long pgdatfile;
+			unsigned long pgdatfree;
+			int z;
+
+			pgdatfree = sum_zone_node_page_state(pgdat->node_id,
+							     NR_FREE_PAGES);
+			pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
+				    node_page_state(pgdat, NR_INACTIVE_FILE);
+
+			for (z = 0; z < MAX_NR_ZONES; z++) {
+				struct zone *zone = &pgdat->node_zones[z];
+				if (!managed_zone(zone))
+					continue;
 
-			total_high_wmark += high_wmark_pages(zone);
-		}
+				total_high_wmark += high_wmark_pages(zone);
+			}
 
-		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
-			scan_balance = SCAN_ANON;
-			goto out;
+			if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
+				scan_balance = SCAN_ANON;
+				goto out;
+			}
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
