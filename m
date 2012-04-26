Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5C2946B00EB
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:30 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id gg6so999112lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:29 -0700 (PDT)
Subject: [PATCH 10/12] mm/vmscan: push lruvec pointer into get_scan_count()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:26 +0400
Message-ID: <20120426075426.18961.28425.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 258e002..1724ec6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -150,11 +150,6 @@ static bool global_reclaim(struct scan_control *sc)
 }
 #endif
 
-static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
-{
-	return &mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup)->reclaim_stat;
-}
-
 static unsigned long get_lruvec_size(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
@@ -1623,20 +1618,18 @@ static int vmscan_swappiness(struct scan_control *sc)
  *
  * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
-static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
+static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			   unsigned long *nr)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2], denominator;
 	enum lru_list lru;
 	int noswap = 0;
 	bool force_scan = false;
-	struct lruvec *lruvec;
-
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	struct zone *zone = lruvec_zone(lruvec);
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -1648,7 +1641,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && mz->zone->all_unreclaimable)
+	if (current_is_kswapd() && zone->all_unreclaimable)
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -1668,10 +1661,10 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 		get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
 
 	if (global_reclaim(sc)) {
-		free  = zone_page_state(mz->zone, NR_FREE_PAGES);
+		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
-		if (unlikely(file + free <= high_wmark_pages(mz->zone))) {
+		if (unlikely(file + free <= high_wmark_pages(zone))) {
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
@@ -1697,7 +1690,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&mz->zone->lru_lock);
+	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1718,7 +1711,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&mz->zone->lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -1836,7 +1829,7 @@ static void shrink_mem_cgroup_zone(struct mem_cgroup_zone *mz,
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
-	get_scan_count(mz, sc, nr);
+	get_scan_count(lruvec, sc, nr);
 
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
