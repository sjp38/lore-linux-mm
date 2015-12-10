Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 853976B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:37 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so46389242pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:37 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wk6si19820155pac.91.2015.12.10.03.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:36 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/7] mm: vmscan: pass memcg to get_scan_count()
Date: Thu, 10 Dec 2015 14:39:15 +0300
Message-ID: <587fef1387d133d77c219c03e7aa371889893c57.1449742560.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

memcg will come in handy in get_scan_count(). It can already be used for
getting swappiness immediately in get_scan_count() instead of passing it
around. The following patches will add more memcg-related values, which
will be used there.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bb01b04154ad..acc6bff84e26 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1957,10 +1957,11 @@ enum scan_balance {
  * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
-static void get_scan_count(struct lruvec *lruvec, int swappiness,
+static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			   struct scan_control *sc, unsigned long *nr,
 			   unsigned long *lru_pages)
 {
+	int swappiness = mem_cgroup_swappiness(memcg);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
 	u64 denominator = 0;	/* gcc */
@@ -2184,9 +2185,10 @@ static inline void init_tlb_ubc(void)
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
-			  struct scan_control *sc, unsigned long *lru_pages)
+static void shrink_zone_memcg(struct zone *zone, struct mem_cgroup *memcg,
+			      struct scan_control *sc, unsigned long *lru_pages)
 {
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2196,7 +2198,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, swappiness, sc, nr, lru_pages);
+	get_scan_count(lruvec, memcg, sc, nr, lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2400,8 +2402,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			unsigned long lru_pages;
 			unsigned long reclaimed;
 			unsigned long scanned;
-			struct lruvec *lruvec;
-			int swappiness;
 
 			if (mem_cgroup_low(root, memcg)) {
 				if (!sc->may_thrash)
@@ -2409,12 +2409,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 				mem_cgroup_events(memcg, MEMCG_LOW, 1);
 			}
 
-			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-			swappiness = mem_cgroup_swappiness(memcg);
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
 
-			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
+			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
 			if (memcg && is_classzone)
@@ -2884,8 +2882,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 	};
-	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-	int swappiness = mem_cgroup_swappiness(memcg);
 	unsigned long lru_pages;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2902,7 +2898,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_lruvec(lruvec, swappiness, &sc, &lru_pages);
+	shrink_zone_memcg(zone, memcg, &sc, &lru_pages);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
