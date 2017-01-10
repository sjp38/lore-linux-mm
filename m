Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F193A6B0253
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 07:56:12 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id n3so85146667wjy.6
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:56:12 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id bn2si1566461wjc.197.2017.01.10.04.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 04:56:11 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id qs7so49875588wjc.1
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:56:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in get_scan_count
Date: Tue, 10 Jan 2017 13:55:51 +0100
Message-Id: <20170110125552.4170-2-mhocko@kernel.org>
In-Reply-To: <20170110125552.4170-1-mhocko@kernel.org>
References: <20170110125552.4170-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

get_scan_count considers the whole node LRU size when
- doing SCAN_FILE due to many page cache inactive pages
- calculating the number of pages to scan

in both cases this might lead to unexpected behavior especially on 32b
systems where we can expect lowmem memory pressure very often.

A large highmem zone can easily distort SCAN_FILE heuristic because
there might be only few file pages from the eligible zones on the node
lru and we would still enforce file lru scanning which can lead to
trashing while we could still scan anonymous pages.

The later use of lruvec_lru_size can be problematic as well. Especially
when there are not many pages from the eligible zones. We would have to
skip over many pages to find anything to reclaim but shrink_node_memcg
would only reduce the remaining number to scan by SWAP_CLUSTER_MAX
at maximum. Therefore we can end up going over a large LRU many times
without actually having chance to reclaim much if anything at all. The
closer we are out of memory on lowmem zone the worse the problem will
be.

Changes since v1
- s@lruvec_lru_size_zone_idx@lruvec_lru_size_eligibe_zones@

Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 069eb637f5f3..137bc85067d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -253,6 +253,32 @@ unsigned long lruvec_zone_lru_size(struct lruvec *lruvec, enum lru_list lru,
 }
 
 /*
+ * Return the number of pages on the given lru which are eligible for the
+ * given zone_idx
+ */
+static unsigned long lruvec_lru_size_eligibe_zones(struct lruvec *lruvec,
+		enum lru_list lru, int zone_idx)
+{
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	unsigned long lru_size;
+	int zid;
+
+	lru_size = lruvec_lru_size(lruvec, lru);
+	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
+		struct zone *zone = &pgdat->node_zones[zid];
+		unsigned long size;
+
+		if (!managed_zone(zone))
+			continue;
+
+		size = lruvec_zone_lru_size(lruvec, lru, zid);
+		lru_size -= min(size, lru_size);
+	}
+
+	return lru_size;
+}
+
+/*
  * Add a shrinker callback to be called from the vm.
  */
 int register_shrinker(struct shrinker *shrinker)
@@ -2213,7 +2239,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size_eligibe_zones(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2280,7 +2306,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size_eligibe_zones(lruvec, lru, sc->reclaim_idx);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
