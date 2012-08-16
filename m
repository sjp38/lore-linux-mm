Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3792F6B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 11:40:23 -0400 (EDT)
Date: Thu, 16 Aug 2012 11:35:38 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC][PATCH -mm -v2 1/4] mm,vmscan: track recent pressure on each
 LRU set
Message-ID: <20120816113538.469ccb63@cuia.bos.redhat.com>
In-Reply-To: <20120816113450.52f4e633@cuia.bos.redhat.com>
References: <20120816113450.52f4e633@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: yinghan@google.com, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

Keep track of the recent amount of pressure applied to each LRU list.

This statistic is incremented simultaneously with ->recent_scanned,
however it is aged in a different way. Recent_scanned and recent_rotated
are aged locally for each list, to estimate the fraction of objects
on each list that are in active use.

The recent_pressure statistic is aged globally for all lists. We
can use this to figure out which LRUs we should reclaim from.
Because this figure is only used at reclaim time, we can lazily
age it whenever we consider an lruvec for reclaiming.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h |   10 ++++++++-
 mm/memcontrol.c        |    5 ++++
 mm/swap.c              |    1 +
 mm/vmscan.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f222e06..be93e7e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -189,12 +189,20 @@ struct zone_reclaim_stat {
 	 * The pageout code in vmscan.c keeps track of how many of the
 	 * mem/swap backed and file backed pages are referenced.
 	 * The higher the rotated/scanned ratio, the more valuable
-	 * that cache is.
+	 * that cache is. These numbers are aged separately for each LRU.
 	 *
 	 * The anon LRU stats live in [0], file LRU stats in [1]
 	 */
 	unsigned long		recent_rotated[2];
 	unsigned long		recent_scanned[2];
+	/*
+	 * This number is incremented together with recent_scanned,
+	 * but is aged simultaneously for all LRUs. This allows the
+	 * system to determine which LRUs have already been scanned
+	 * enough, and which should be scanned next.
+	 */
+	unsigned long		recent_pressure[2];
+	unsigned long		recent_pressure_seq;
 };
 
 struct lruvec {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d906b43..a18a0d5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3852,6 +3852,7 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 		struct zone_reclaim_stat *rstat;
 		unsigned long recent_rotated[2] = {0, 0};
 		unsigned long recent_scanned[2] = {0, 0};
+		unsigned long recent_pressure[2] = {0, 0};
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
@@ -3862,11 +3863,15 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 				recent_rotated[1] += rstat->recent_rotated[1];
 				recent_scanned[0] += rstat->recent_scanned[0];
 				recent_scanned[1] += rstat->recent_scanned[1];
+				recent_pressure[0] += rstat->recent_pressure[0];
+				recent_pressure[1] += rstat->recent_pressure[1];
 			}
 		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
 		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
 		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
 		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
+		seq_printf(m, "recent_pressure_anon %lu\n", recent_pressure[0]);
+		seq_printf(m, "recent_pressure_file %lu\n", recent_pressure[1]);
 	}
 #endif
 
diff --git a/mm/swap.c b/mm/swap.c
index 4e7e2ec..0cca972 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -316,6 +316,7 @@ static void update_page_reclaim_stat(struct lruvec *lruvec,
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
 	reclaim_stat->recent_scanned[file]++;
+	reclaim_stat->recent_pressure[file]++;
 	if (rotated)
 		reclaim_stat->recent_rotated[file]++;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a779b03..b0e5495 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1282,6 +1282,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	spin_lock_irq(&zone->lru_lock);
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
+	reclaim_stat->recent_pressure[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
 		if (current_is_kswapd())
@@ -1426,6 +1427,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		zone->pages_scanned += nr_scanned;
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
+	reclaim_stat->recent_pressure[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
@@ -1852,6 +1854,53 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
+/*
+ * Ensure that the ->recent_pressure statistics for this lruvec are
+ * aged to the same degree as those elsewhere in the system, before
+ * we do reclaim on this lruvec or evaluate its reclaim priority.
+ */
+static DEFINE_SPINLOCK(recent_pressure_lock);
+static int recent_pressure_seq;
+static void age_recent_pressure(struct lruvec *lruvec, struct zone *zone)
+{
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	unsigned long anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
+			      get_lru_size(lruvec, LRU_INACTIVE_ANON);
+	unsigned long file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
+			      get_lru_size(lruvec, LRU_INACTIVE_FILE);
+	int shift;
+
+	/*
+	 * Do not bother recalculating unless we are behind with the
+	 * system wide statistics, or our local recent_pressure numbers
+	 * have grown too large. We have to keep the number somewhat
+	 * small, to ensure that reclaim_score returns non-zero.
+	 */
+	if (reclaim_stat->recent_pressure_seq != recent_pressure_seq &&
+			reclaim_stat->recent_pressure[0] < anon / 4 &&
+			reclaim_stat->recent_pressure[1] < file / 4)
+		return;
+
+	spin_lock(&recent_pressure_lock);
+	/*
+	 * If we are aging due to local activity, increment the global
+	 * sequence counter. Leave the global counter alone if we are
+	 * merely playing catchup.
+	 */
+	if (reclaim_stat->recent_pressure_seq == recent_pressure_seq)
+		recent_pressure_seq++;
+	shift = recent_pressure_seq - reclaim_stat->recent_pressure_seq;
+	shift = min(shift, (BITS_PER_LONG-1));
+	reclaim_stat->recent_pressure_seq = recent_pressure_seq;
+	spin_unlock(&recent_pressure_lock);
+
+	/* For every aging interval, do one division by two. */
+	spin_lock_irq(&zone->lru_lock);
+	reclaim_stat->recent_pressure[0] >>= shift;
+	reclaim_stat->recent_pressure[1] >>= shift;
+	spin_unlock_irq(&zone->lru_lock);
+}
+
 static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -1869,6 +1918,8 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 	do {
 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
+		age_recent_pressure(lruvec, zone);
+
 		/*
 		 * Reclaim from mem_cgroup if any of these conditions are met:
 		 * - this is a targetted reclaim ( not global reclaim)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
