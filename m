Message-Id: <20080228192928.648701083@redhat.com>
References: <20080228192908.126720629@redhat.com>
Date: Thu, 28 Feb 2008 14:29:17 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 09/21] (NEW) improve reclaim balancing
Content-Disposition: inline; filename=rvr-05-linux-2.6-limit-direct-reclaim.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- deactivate anonymous pages regardless of the scan ratio
- go through the reclaim loop at least once for the deactivation
- break out of the reclaim loop if we freed sc->swap_cluster_max pages,
  on big systems the nr[FOO] targets can get ridiculously large

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-28 00:29:40.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-28 00:29:46.000000000 -0500
@@ -1302,7 +1302,7 @@ static unsigned long shrink_zone(int pri
 	}
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
-						 nr[LRU_INACTIVE_FILE]) {
+					nr[LRU_INACTIVE_FILE]) {
 		for_each_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
@@ -1315,6 +1315,14 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
+	/*
+	 * Even if we did not try to evict anon pages at all, we want to
+	 * rebalance the anon lru active/inactive ratio.
+	 */
+	if (inactive_anon_low(zone))
+		shrink_list(NR_ACTIVE_ANON, SWAP_CLUSTER_MAX, zone, sc,
+								priority);
+
 	throttle_vm_writeout(sc->gfp_mask);
 	return nr_reclaimed;
 }

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
