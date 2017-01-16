Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E95DB6B0253
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:33:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so29608199wmd.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:33:38 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id b58si14637615wrb.1.2017.01.16.11.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 11:33:37 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id d140so16652368wmd.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:33:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] Reverted "mm: bail out in shrink_inactive_list()"
Date: Mon, 16 Jan 2017 20:33:17 +0100
Message-Id: <20170116193317.20390-3-mhocko@kernel.org>
In-Reply-To: <20170116193317.20390-1-mhocko@kernel.org>
References: <20170116160123.GB30300@cmpxchg.org>
 <20170116193317.20390-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This reverts 91dcade47a3d0e7c31464ef05f56c08e92a0e9c2.
inactive_reclaimable_pages shouldn't be needed anymore since that
get_scan_count is aware of the eligble zones ("mm, vmscan: consider
eligible zones in get_scan_count").

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a88e222784ea..486ba6d7dc4c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1700,30 +1700,6 @@ static int current_may_throttle(void)
 		bdi_write_congested(current->backing_dev_info);
 }
 
-static bool inactive_reclaimable_pages(struct lruvec *lruvec,
-				struct scan_control *sc, enum lru_list lru)
-{
-	int zid;
-	struct zone *zone;
-	int file = is_file_lru(lru);
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-
-	if (!global_reclaim(sc))
-		return true;
-
-	for (zid = sc->reclaim_idx; zid >= 0; zid--) {
-		zone = &pgdat->node_zones[zid];
-		if (!managed_zone(zone))
-			continue;
-
-		if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
-				LRU_FILE * file) >= SWAP_CLUSTER_MAX)
-			return true;
-	}
-
-	return false;
-}
-
 /*
  * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
@@ -1742,9 +1718,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	if (!inactive_reclaimable_pages(lruvec, sc, lru))
-		return 0;
-
 	while (unlikely(too_many_isolated(pgdat, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
