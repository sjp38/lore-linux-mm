Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 08E666B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 17:51:21 -0400 (EDT)
Date: Wed, 8 Aug 2012 17:48:28 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC][PATCH -mm 2/3] mm,vmscan: reclaim from highest score cgroups
Message-ID: <20120808174828.56ffa9e7@cuia.bos.redhat.com>
In-Reply-To: <20120808174549.1b10d51a@cuia.bos.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

Instead of doing a round robin reclaim over all the cgroups in a
zone, we pick the lruvec with the top score and reclaim from that.

We keep reclaiming from that lruvec until we have reclaimed enough
pages (common for direct reclaim), or that lruvec's score drops in
half. We keep reclaiming from the zone until we have reclaimed enough
pages, or have scanned more than the number of reclaimable pages shifted
by the reclaim priority.

As an additional change, targeted cgroup reclaim now reclaims from
the highest priority lruvec. This is because when a cgroup hierarchy
hits its limit, the best lruvec to reclaim from may be different than
whatever lruvec is the first we run into iterating from the hierarchy's
"root".

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |  118 ++++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 81 insertions(+), 37 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b0e5495..1a9688b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1901,6 +1901,57 @@ static void age_recent_pressure(struct lruvec *lruvec, struct zone *zone)
 	spin_unlock_irq(&zone->lru_lock);
 }
 
+/*
+ * The higher the LRU score, the more desirable it is to reclaim
+ * from this LRU set first. The score is a function of the fraction
+ * of recently scanned pages on the LRU that are in active use,
+ * as well as the size of the list and the amount of memory pressure
+ * that has been put on this LRU recently.
+ *
+ *          recent_scanned        size
+ * score =  -------------- x --------------- x adjustment
+ *          recent_rotated   recent_pressure
+ *
+ * The maximum score of the anon and file list in this lruvec
+ * is returned. Adjustments are made for the file LRU having
+ * lots of inactive pages (mostly streaming IO), or the memcg
+ * being over its soft limit.
+ *
+ * This function should return a positive number for any lruvec
+ * with more than a handful of resident pages, because recent_scanned
+ * should always be larger than recent_rotated, and the size should
+ * always be larger than recent_pressure.
+ */
+static u64 reclaim_score(struct mem_cgroup *memcg,
+			 struct lruvec *lruvec)
+{
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	u64 anon, file;
+
+	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
+	        get_lru_size(lruvec, LRU_INACTIVE_ANON);
+	anon *= reclaim_stat->recent_scanned[0];
+	anon /= (reclaim_stat->recent_rotated[0] + 1);
+	anon /= (reclaim_stat->recent_pressure[0] + 1);
+
+	file = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
+	       get_lru_size(lruvec, LRU_INACTIVE_FILE);
+	file *= reclaim_stat->recent_scanned[1];
+	file /= (reclaim_stat->recent_rotated[1] + 1);
+	file /= (reclaim_stat->recent_pressure[1] + 1);
+
+	/*
+	 * Give a STRONG preference to reclaiming memory from lruvecs
+	 * that belong to a cgroup that is over its soft limit.
+	 */
+	if (mem_cgroup_over_soft_limit(memcg)) {
+		file *= 10000;
+		anon *= 10000;
+	}
+
+	return max(anon, file);
+}
+
 static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -1908,11 +1959,14 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		.zone = zone,
 		.priority = sc->priority,
 	};
+	unsigned long nr_scanned = sc->nr_scanned;
 	struct mem_cgroup *memcg;
-	bool over_softlimit, ignore_softlimit = false;
+	struct lruvec *victim;
+	u64 score, max_score;
 
 restart:
-	over_softlimit = false;
+	max_score = 0;
+	victim = NULL;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
@@ -1920,48 +1974,38 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 
 		age_recent_pressure(lruvec, zone);
 
-		/*
-		 * Reclaim from mem_cgroup if any of these conditions are met:
-		 * - this is a targetted reclaim ( not global reclaim)
-		 * - reclaim priority is less than  DEF_PRIORITY - 2
-		 * - mem_cgroup or its ancestor ( not including root cgroup)
-		 * exceeds its soft limit
-		 *
-		 * Note: The priority check is a balance of how hard to
-		 * preserve the pages under softlimit. If the memcgs of the
-		 * zone having trouble to reclaim pages above their softlimit,
-		 * we have to reclaim under softlimit instead of burning more
-		 * cpu cycles.
-		 */
-		if (ignore_softlimit || !global_reclaim(sc) ||
-				sc->priority < DEF_PRIORITY - 2 ||
-				mem_cgroup_over_soft_limit(memcg)) {
-			shrink_lruvec(lruvec, sc);
+		score = reclaim_score(memcg, lruvec);
 
-			over_softlimit = true;
+		/* Pick the lruvec with the highest score. */
+		if (score > max_score) {
+			max_score = score;
+			victim = lruvec;
 		}
 
-		/*
-		 * Limit reclaim has historically picked one memcg and
-		 * scanned it with decreasing priority levels until
-		 * nr_to_reclaim had been reclaimed.  This priority
-		 * cycle is thus over after a single memcg.
-		 *
-		 * Direct reclaim and kswapd, on the other hand, have
-		 * to scan all memory cgroups to fulfill the overall
-		 * scan target for the zone.
-		 */
-		if (!global_reclaim(sc)) {
-			mem_cgroup_iter_break(root, memcg);
-			break;
-		}
 		memcg = mem_cgroup_iter(root, memcg, &reclaim);
 	} while (memcg);
 
-	if (!over_softlimit) {
-		ignore_softlimit = true;
+	/* No lruvec in our set is suitable for reclaiming. */
+	if (!victim)
+		return;
+
+	/*
+	 * Reclaim from the top scoring lruvec until we freed enough
+	 * pages, or its reclaim priority has halved.
+	 */
+	do {
+		shrink_lruvec(victim, sc);
+		score = reclaim_score(memcg, victim);
+	} while (sc->nr_to_reclaim > 0 && score > max_score / 2);
+
+	/*
+	 * Do we need to reclaim more pages?
+	 * Did we scan fewer pages than the current priority allows?
+	 */
+	if (sc->nr_to_reclaim > 0 &&
+			sc->nr_scanned + nr_scanned <
+			zone_reclaimable_pages(zone) >> sc->priority)
 		goto restart;
-	}
 }
 
 /* Returns true if compaction should go ahead for a high-order request */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
