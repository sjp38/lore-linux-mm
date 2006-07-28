From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210538.30275.44220.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 1/9] oom: use unreclaimable info
Date: Fri, 28 Jul 2006 09:20:52 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

__alloc_pages currently starts shooting if page reclaim has failed to free up
swap_cluster_max pages in one run through the priorities. This is not always a
good indicator on its own, so make use of the all_unreclaimable logic as
well: don't consider going OOM until all zones we're interested in are
unreclaimable.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -62,6 +62,8 @@ struct scan_control {
 	int swap_cluster_max;
 
 	int swappiness;
+
+	int all_unreclaimable;
 };
 
 /*
@@ -925,6 +927,7 @@ static unsigned long shrink_zones(int pr
 	unsigned long nr_reclaimed = 0;
 	int i;
 
+	sc->all_unreclaimable = 1;
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
@@ -941,6 +944,8 @@ static unsigned long shrink_zones(int pr
 		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
+		sc->all_unreclaimable = 0;
+
 		nr_reclaimed += shrink_zone(priority, zone, sc);
 	}
 	return nr_reclaimed;
@@ -1021,6 +1026,9 @@ unsigned long try_to_free_pages(struct z
 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
 			blk_congestion_wait(WRITE, HZ/10);
 	}
+	/* top priority shrink_caches still had more to do? don't OOM, then */
+	if (!sc.all_unreclaimable)
+		ret = 1;
 out:
 	for (i = 0; zones[i] != 0; i++) {
 		struct zone *zone = zones[i];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
