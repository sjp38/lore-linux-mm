Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B2DC6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:00:31 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1AD0R7S027780
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 22:00:28 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD8EA45DD75
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96D7545DD74
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 841F4E08001
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DAF61DB803C
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] shrink_all_memory() use sc.nr_reclaimed
In-Reply-To: <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com> <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090210215811.7010.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 22:00:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Impact: cleanup

Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
counter into the scan control to accumulate the number of all
reclaimed pages in a reclaim invocation.

shrink_all_memory() can use the same mechanism. it increase code 
consistency.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   49 ++++++++++++++++++++++++-------------------------
 1 file changed, 24 insertions(+), 25 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2004,16 +2004,15 @@ unsigned long global_lru_pages(void)
 #ifdef CONFIG_PM
 /*
  * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
- * from LRU lists system-wide, for given pass and priority, and returns the
- * number of reclaimed pages
+ * from LRU lists system-wide, for given pass and priority.
  *
  * For pass > 3 we also try to shrink the LRU lists that contain a few pages
  */
-static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
+static void shrink_all_zones(unsigned long nr_pages, int prio,
 				      int pass, struct scan_control *sc)
 {
 	struct zone *zone;
-	unsigned long nr_to_scan, ret = 0;
+	unsigned long nr_to_scan;
 	enum lru_list l;
 
 	for_each_zone(zone) {
@@ -2038,15 +2037,13 @@ static unsigned long shrink_all_zones(un
 				nr_to_scan = min(nr_pages,
 					zone_page_state(zone,
 							NR_LRU_BASE + l));
-				ret += shrink_list(l, nr_to_scan, zone,
-								sc, prio);
-				if (ret >= nr_pages)
-					return ret;
+				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
+								zone, sc, prio);
+				if (sc->nr_reclaimed >= nr_pages)
+					return;
 			}
 		}
 	}
-
-	return ret;
 }
 
 /*
@@ -2060,10 +2057,10 @@ static unsigned long shrink_all_zones(un
 unsigned long shrink_all_memory(unsigned long nr_pages)
 {
 	unsigned long lru_pages, nr_slab;
-	unsigned long ret = 0;
 	int pass;
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
+		.nr_reclaimed = 0,
 		.gfp_mask = GFP_KERNEL,
 		.may_swap = 0,
 		.swap_cluster_max = nr_pages,
@@ -2083,8 +2080,8 @@ unsigned long shrink_all_memory(unsigned
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
-		ret += reclaim_state.reclaimed_slab;
-		if (ret >= nr_pages)
+		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		if (sc.nr_reclaimed >= nr_pages)
 			goto out;
 
 		nr_slab -= reclaim_state.reclaimed_slab;
@@ -2108,18 +2105,18 @@ unsigned long shrink_all_memory(unsigned
 		}
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
-			unsigned long nr_to_scan = nr_pages - ret;
+			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
 
 			sc.nr_scanned = 0;
-			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
-			if (ret >= nr_pages)
+			shrink_all_zones(nr_to_scan, prio, pass, &sc);
+			if (sc.nr_reclaimed >= nr_pages)
 				goto out;
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
 					global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-			if (ret >= nr_pages)
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+			if (sc.nr_reclaimed >= nr_pages)
 				goto out;
 
 			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
@@ -2128,21 +2125,23 @@ unsigned long shrink_all_memory(unsigned
 	}
 
 	/*
-	 * If ret = 0, we could not shrink LRUs, but there may be something
-	 * in slab caches
+	 * If sc.nr_reclaimed = 0, we could not shrink LRUs, but there may be
+	 * something in slab caches
 	 */
-	if (!ret) {
+	if (!sc.nr_reclaimed) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
+			shrink_slab(nr_pages, sc.gfp_mask,
+				    global_lru_pages());
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		} while (sc.nr_reclaimed < nr_pages &&
+			 reclaim_state.reclaimed_slab > 0);
 	}
 
 out:
 	current->reclaim_state = NULL;
 
-	return ret;
+	return sc.nr_reclaimed;
 }
 #endif
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
