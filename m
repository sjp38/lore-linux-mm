From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210547.30275.23248.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 2/9] oom: reclaim_mapped on oom
Date: Fri, 28 Jul 2006 09:21:01 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Potentially it takes several scans of the lru lists before we can even start
reclaiming pages.

mapped pages, with young ptes can take 2 passes on the active list + one on
the inactive list. But reclaim_mapped may not always kick in instantly, so
it could take even more than that.

Raise the threshold for marking a zone as all_unreclaimable from a factor of
4 time the pages in the zone to 6.  Introduce a mechanism to force
reclaim_mapped if we've reached a factor 3 and still haven't made progress.

Previously, a customer doing stress testing was able to easily OOM the box
after using only a small fraction of its swap (~100MB). After the patches, it
would only OOM after having used up all swap (~800MB).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -697,6 +697,11 @@ done:
 	return nr_reclaimed;
 }
 
+static inline int zone_is_near_oom(struct zone *zone)
+{
+	return zone->pages_scanned >= (zone->nr_active + zone->nr_inactive)*3;
+}
+
 /*
  * This moves pages from the active list to the inactive list.
  *
@@ -732,6 +737,9 @@ static void shrink_active_list(unsigned 
 		long distress;
 		long swap_tendency;
 
+		if (zone_is_near_oom(zone))
+			goto force_reclaim_mapped;
+
 		/*
 		 * `distress' is a measure of how much trouble we're having
 		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
@@ -767,6 +775,7 @@ static void shrink_active_list(unsigned 
 		 * memory onto the inactive list.
 		 */
 		if (swap_tendency >= 100)
+force_reclaim_mapped:
 			reclaim_mapped = 1;
 	}
 
@@ -1161,7 +1170,7 @@ scan:
 			if (zone->all_unreclaimable)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				    (zone->nr_active + zone->nr_inactive) * 4)
+				    (zone->nr_active + zone->nr_inactive) * 6)
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
