Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36F36B038D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q39so9390135wrb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z17si3959451wra.327.2017.02.28.13.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:23 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/9] mm: don't avoid high-priority reclaim on unreclaimable nodes
Date: Tue, 28 Feb 2017 16:40:03 -0500
Message-Id: <20170228214007.5621-6-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

246e87a93934 ("memcg: fix get_scan_count() for small targets") sought
to avoid high reclaim priorities for kswapd by forcing it to scan a
minimum amount of pages when lru_pages >> priority yielded nothing.

b95a2f2d486d ("mm: vmscan: convert global reclaim to per-memcg LRU
lists"), due to switching global reclaim to a round-robin scheme over
all cgroups, had to restrict this forceful behavior to unreclaimable
zones in order to prevent massive overreclaim with many cgroups.

The latter patch effectively neutered the behavior completely for all
but extreme memory pressure. But in those situations we might as well
drop the reclaimers to lower priority levels. Remove the check.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 911957b66622..46b6223fe7f3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2129,22 +2129,13 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	int pass;
 
 	/*
-	 * If the zone or memcg is small, nr[l] can be 0.  This
-	 * results in no scanning on this priority and a potential
-	 * priority drop.  Global direct reclaim can go to the next
-	 * zone and tends to have no problems. Global kswapd is for
-	 * zone balancing and it needs to scan a minimum amount. When
+	 * If the zone or memcg is small, nr[l] can be 0. When
 	 * reclaiming for a memcg, a priority drop can cause high
-	 * latencies, so it's better to scan a minimum amount there as
-	 * well.
+	 * latencies, so it's better to scan a minimum amount. When a
+	 * cgroup has already been deleted, scrape out the remaining
+	 * cache forcefully to get rid of the lingering state.
 	 */
-	if (current_is_kswapd()) {
-		if (!pgdat_reclaimable(pgdat))
-			force_scan = true;
-		if (!mem_cgroup_online(memcg))
-			force_scan = true;
-	}
-	if (!global_reclaim(sc))
+	if (!global_reclaim(sc) || !mem_cgroup_online(memcg))
 		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
