Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D327F6B0038
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 09:04:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/10] mm: vmscan: Obey proportional scanning requirements for kswapd
Date: Sun, 17 Mar 2013 13:04:08 +0000
Message-Id: <1363525456-10448-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Simplistically, the anon and file LRU lists are scanned proportionally
depending on the value of vm.swappiness although there are other factors
taken into account by get_scan_count().  The patch "mm: vmscan: Limit
the number of pages kswapd reclaims" limits the number of pages kswapd
reclaims but it breaks this proportional scanning and may evenly shrink
anon/file LRUs regardless of vm.swappiness.

This patch preserves the proportional scanning and reclaim. It does mean
that kswapd will reclaim more than requested but the number of pages will
be related to the high watermark.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 52 +++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4835a7a..182ff15 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1815,6 +1815,45 @@ out:
 	}
 }
 
+static void recalculate_scan_count(unsigned long nr_reclaimed,
+		unsigned long nr_to_reclaim,
+		unsigned long nr[NR_LRU_LISTS])
+{
+	enum lru_list l;
+
+	/*
+	 * For direct reclaim, reclaim the number of pages requested. Less
+	 * care is taken to ensure that scanning for each LRU is properly
+	 * proportional. This is unfortunate and is improper aging but
+	 * minimises the amount of time a process is stalled.
+	 */
+	if (!current_is_kswapd()) {
+		if (nr_reclaimed >= nr_to_reclaim) {
+			for_each_evictable_lru(l)
+				nr[l] = 0;
+		}
+		return;
+	}
+
+	/*
+	 * For kswapd, reclaim at least the number of pages requested.
+	 * However, ensure that LRUs shrink by the proportion requested
+	 * by get_scan_count() so vm.swappiness is obeyed.
+	 */
+	if (nr_reclaimed >= nr_to_reclaim) {
+		unsigned long min = ULONG_MAX;
+
+		/* Find the LRU with the fewest pages to reclaim */
+		for_each_evictable_lru(l)
+			if (nr[l] < min)
+				min = nr[l];
+
+		/* Normalise the scan counts so kswapd scans proportionally */
+		for_each_evictable_lru(l)
+			nr[l] -= min;
+	}
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -1841,17 +1880,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 							    lruvec, sc);
 			}
 		}
-		/*
-		 * On large memory systems, scan >> priority can become
-		 * really large. This is fine for the starting priority;
-		 * we want to put equal scanning pressure on each zone.
-		 * However, if the VM has a harder time of freeing pages,
-		 * with multiple processes reclaiming pages, the total
-		 * freeing target can get unreasonably large.
-		 */
-		if (nr_reclaimed >= nr_to_reclaim &&
-		    sc->priority < DEF_PRIORITY)
-			break;
+
+		recalculate_scan_count(nr_reclaimed, nr_to_reclaim, nr);
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
