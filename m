Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5D6E6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 09:51:48 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w9-v6so935185plp.0
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 06:51:48 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00123.outbound.protection.outlook.com. [40.107.0.123])
        by mx.google.com with ESMTPS id f9si1261587pgn.723.2018.04.06.06.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 06:51:47 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2-fix
Date: Fri,  6 Apr 2018 16:52:15 +0300
Message-Id: <20180406135215.10057-1-aryabinin@virtuozzo.com>
In-Reply-To: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
References: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

On 04/06/2018 05:13 AM, Shakeel Butt wrote:
> Question: Should this 'flags' be per-node? Is it ok for a congested
> memcg to call wait_iff_congested for all nodes?

Indeed, congestion state should be pre-node. If memcg on node A is
congested, there is no point is stalling memcg reclaim from node B.

Make congestion state per-cgroup-per-node and record it in
'struct mem_cgroup_per_node'.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/memcontrol.h |  5 +++--
 mm/vmscan.c                | 39 +++++++++++++++++++++++++--------------
 2 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8b394bbf1c86..af9eed2e3e04 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -120,6 +120,9 @@ struct mem_cgroup_per_node {
 	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
+	bool			congested;	/* memcg has many dirty pages */
+						/* backed by a congested BDI */
+
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
@@ -189,8 +192,6 @@ struct mem_cgroup {
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
-	unsigned long flags;
-
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99688299eba8..78214c899710 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -200,16 +200,27 @@ static bool sane_reclaim(struct scan_control *sc)
 	return false;
 }
 
-static void set_memcg_bit(enum pgdat_flags flag,
-			struct mem_cgroup *memcg)
+static void set_memcg_congestion(pg_data_t *pgdat,
+				struct mem_cgroup *memcg,
+				bool congested)
 {
-	set_bit(flag, &memcg->flags);
+	struct mem_cgroup_per_node *mz;
+
+	if (!memcg)
+		return;
+
+	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
+	WRITE_ONCE(mz->congested, congested);
 }
 
-static int test_memcg_bit(enum pgdat_flags flag,
+static bool memcg_congested(pg_data_t *pgdat,
 			struct mem_cgroup *memcg)
 {
-	return test_bit(flag, &memcg->flags);
+	struct mem_cgroup_per_node *mz;
+
+	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
+	return READ_ONCE(mz->congested);
+
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
@@ -222,15 +233,16 @@ static bool sane_reclaim(struct scan_control *sc)
 	return true;
 }
 
-static inline void set_memcg_bit(enum pgdat_flags flag,
-				struct mem_cgroup *memcg)
+static inline void set_memcg_congestion(struct pglist_data *pgdat,
+				struct mem_cgroup *memcg, bool congested)
 {
 }
 
-static inline int test_memcg_bit(enum pgdat_flags flag,
-				struct mem_cgroup *memcg)
+static inline bool memcg_congested(struct pglist_data *pgdat,
+			struct mem_cgroup *memcg)
 {
-	return 0;
+	return false;
+
 }
 #endif
 
@@ -2482,7 +2494,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 {
 	return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
-		(memcg && test_memcg_bit(PGDAT_CONGESTED, memcg));
+		(memcg && memcg_congested(pgdat, memcg));
 }
 
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
@@ -2617,7 +2629,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		 */
 		if (!global_reclaim(sc) && sane_reclaim(sc) &&
 		    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
-			set_memcg_bit(PGDAT_CONGESTED, root);
+			set_memcg_congestion(pgdat, root, true);
 
 		/*
 		 * Stall direct reclaim for IO completions if underlying BDIs
@@ -2844,6 +2856,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			continue;
 		last_pgdat = zone->zone_pgdat;
 		snapshot_refaults(sc->target_mem_cgroup, zone->zone_pgdat);
+		set_memcg_congestion(last_pgdat, sc->target_mem_cgroup, false);
 	}
 
 	delayacct_freepages_end();
@@ -3067,7 +3080,6 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 * the priority and make it zero.
 	 */
 	shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
-	clear_bit(PGDAT_CONGESTED, &memcg->flags);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -3113,7 +3125,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	noreclaim_flag = memalloc_noreclaim_save();
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 	memalloc_noreclaim_restore(noreclaim_flag);
-	clear_bit(PGDAT_CONGESTED, &memcg->flags);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
-- 
2.16.1
