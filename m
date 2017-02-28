Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 704F56B038F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m70so1187493wma.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f200si4351122wme.108.2017.02.28.13.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:26 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/9] mm: don't avoid high-priority reclaim on memcg limit reclaim
Date: Tue, 28 Feb 2017 16:40:04 -0500
Message-Id: <20170228214007.5621-7-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

246e87a93934 ("memcg: fix get_scan_count() for small targets") sought
to avoid high reclaim priorities for memcg by forcing it to scan a
minimum amount of pages when lru_pages >> priority yielded nothing.
This was done at a time when reclaim decisions like dirty throttling
were tied to the priority level.

Nowadays, the only meaningful thing still tied to priority dropping
below DEF_PRIORITY - 2 is gating whether laptop_mode=1 is generally
allowed to write. But that is from an era where direct reclaim was
still allowed to call ->writepage, and kswapd nowadays avoids writes
until it's scanned every clean page in the system. Potential changes
to how quick sc->may_writepage could trigger are of little concern.

Remove the force_scan stuff, as well as the ugly multi-pass target
calculation that it necessitated.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 94 ++++++++++++++++++++++++-------------------------------------
 1 file changed, 37 insertions(+), 57 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 46b6223fe7f3..8cff6e2cd02c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2122,21 +2122,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	unsigned long anon_prio, file_prio;
 	enum scan_balance scan_balance;
 	unsigned long anon, file;
-	bool force_scan = false;
 	unsigned long ap, fp;
 	enum lru_list lru;
-	bool some_scanned;
-	int pass;
-
-	/*
-	 * If the zone or memcg is small, nr[l] can be 0. When
-	 * reclaiming for a memcg, a priority drop can cause high
-	 * latencies, so it's better to scan a minimum amount. When a
-	 * cgroup has already been deleted, scrape out the remaining
-	 * cache forcefully to get rid of the lingering state.
-	 */
-	if (!global_reclaim(sc) || !mem_cgroup_online(memcg))
-		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
@@ -2267,55 +2254,48 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
-	some_scanned = false;
-	/* Only use force_scan on second pass. */
-	for (pass = 0; !some_scanned && pass < 2; pass++) {
-		*lru_pages = 0;
-		for_each_evictable_lru(lru) {
-			int file = is_file_lru(lru);
-			unsigned long size;
-			unsigned long scan;
-
-			size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-			scan = size >> sc->priority;
-
-			if (!scan && pass && force_scan)
-				scan = min(size, SWAP_CLUSTER_MAX);
-
-			switch (scan_balance) {
-			case SCAN_EQUAL:
-				/* Scan lists relative to size */
-				break;
-			case SCAN_FRACT:
-				/*
-				 * Scan types proportional to swappiness and
-				 * their relative recent reclaim efficiency.
-				 */
-				scan = div64_u64(scan * fraction[file],
-							denominator);
-				break;
-			case SCAN_FILE:
-			case SCAN_ANON:
-				/* Scan one type exclusively */
-				if ((scan_balance == SCAN_FILE) != file) {
-					size = 0;
-					scan = 0;
-				}
-				break;
-			default:
-				/* Look ma, no brain */
-				BUG();
-			}
+	*lru_pages = 0;
+	for_each_evictable_lru(lru) {
+		int file = is_file_lru(lru);
+		unsigned long size;
+		unsigned long scan;
 
-			*lru_pages += size;
-			nr[lru] = scan;
+		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
+		scan = size >> sc->priority;
+		/*
+		 * If the cgroup's already been deleted, make sure to
+		 * scrape out the remaining cache.
+		 */
+		if (!scan && !mem_cgroup_online(memcg))
+			scan = min(size, SWAP_CLUSTER_MAX);
 
+		switch (scan_balance) {
+		case SCAN_EQUAL:
+			/* Scan lists relative to size */
+			break;
+		case SCAN_FRACT:
 			/*
-			 * Skip the second pass and don't force_scan,
-			 * if we found something to scan.
+			 * Scan types proportional to swappiness and
+			 * their relative recent reclaim efficiency.
 			 */
-			some_scanned |= !!scan;
+			scan = div64_u64(scan * fraction[file],
+					 denominator);
+			break;
+		case SCAN_FILE:
+		case SCAN_ANON:
+			/* Scan one type exclusively */
+			if ((scan_balance == SCAN_FILE) != file) {
+				size = 0;
+				scan = 0;
+			}
+			break;
+		default:
+			/* Look ma, no brain */
+			BUG();
 		}
+
+		*lru_pages += size;
+		nr[lru] = scan;
 	}
 }
 
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
