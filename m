Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B8D096B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 22:31:08 -0400 (EDT)
Date: Sat, 2 May 2009 10:31:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] vmscan: cleanup the scan batching code
Message-ID: <20090502023125.GA29674@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org> <20090501012212.GA5848@localhost> <20090430194907.82b31565.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090430194907.82b31565.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

The vmscan batching logic is twisting. Move it into a standalone
function nr_scan_try_batch() and document it.  No behavior change.

CC: Nick Piggin <npiggin@suse.de>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mmzone.h |    4 ++--
 mm/page_alloc.c        |    2 +-
 mm/vmscan.c            |   39 ++++++++++++++++++++++++++++-----------
 mm/vmstat.c            |    8 ++++----
 4 files changed, 35 insertions(+), 18 deletions(-)

--- mm.orig/include/linux/mmzone.h
+++ mm/include/linux/mmzone.h
@@ -323,9 +323,9 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
-	struct {
+	struct zone_lru {
 		struct list_head list;
-		unsigned long nr_scan;
+		unsigned long nr_saved_scan;	/* accumulated for batching */
 	} lru[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
--- mm.orig/mm/vmscan.c
+++ mm/mm/vmscan.c
@@ -1450,6 +1450,26 @@ static void get_scan_ratio(struct zone *
 	percent[1] = 100 - percent[0];
 }
 
+/*
+ * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
+ * until we collected @swap_cluster_max pages to scan.
+ */
+static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
+				       unsigned long *nr_saved_scan,
+				       unsigned long swap_cluster_max)
+{
+	unsigned long nr;
+
+	*nr_saved_scan += nr_to_scan;
+	nr = *nr_saved_scan;
+
+	if (nr >= swap_cluster_max)
+		*nr_saved_scan = 0;
+	else
+		nr = 0;
+
+	return nr;
+}
 
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
@@ -1475,14 +1495,11 @@ static void shrink_zone(int priority, st
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;
 		}
-		if (scanning_global_lru(sc)) {
-			zone->lru[l].nr_scan += scan;
-			nr[l] = zone->lru[l].nr_scan;
-			if (nr[l] >= swap_cluster_max)
-				zone->lru[l].nr_scan = 0;
-			else
-				nr[l] = 0;
-		} else
+		if (scanning_global_lru(sc))
+			nr[l] = nr_scan_try_batch(scan,
+						  &zone->lru[l].nr_saved_scan,
+						  swap_cluster_max);
+		else
 			nr[l] = scan;
 	}
 
@@ -2079,11 +2096,11 @@ static void shrink_all_zones(unsigned lo
 						l == LRU_ACTIVE_FILE))
 				continue;
 
-			zone->lru[l].nr_scan += (lru_pages >> prio) + 1;
-			if (zone->lru[l].nr_scan >= nr_pages || pass > 3) {
+			zone->lru[l].nr_saved_scan += (lru_pages >> prio) + 1;
+			if (zone->lru[l].nr_saved_scan >= nr_pages || pass > 3) {
 				unsigned long nr_to_scan;
 
-				zone->lru[l].nr_scan = 0;
+				zone->lru[l].nr_saved_scan = 0;
 				nr_to_scan = min(nr_pages, lru_pages);
 				nr_reclaimed += shrink_list(l, nr_to_scan, zone,
 								sc, prio);
--- mm.orig/mm/vmstat.c
+++ mm/mm/vmstat.c
@@ -729,10 +729,10 @@ static void zoneinfo_show_print(struct s
 		   zone->pages_low,
 		   zone->pages_high,
 		   zone->pages_scanned,
-		   zone->lru[LRU_ACTIVE_ANON].nr_scan,
-		   zone->lru[LRU_INACTIVE_ANON].nr_scan,
-		   zone->lru[LRU_ACTIVE_FILE].nr_scan,
-		   zone->lru[LRU_INACTIVE_FILE].nr_scan,
+		   zone->lru[LRU_ACTIVE_ANON].nr_saved_scan,
+		   zone->lru[LRU_INACTIVE_ANON].nr_saved_scan,
+		   zone->lru[LRU_ACTIVE_FILE].nr_saved_scan,
+		   zone->lru[LRU_INACTIVE_FILE].nr_saved_scan,
 		   zone->spanned_pages,
 		   zone->present_pages);
 
--- mm.orig/mm/page_alloc.c
+++ mm/mm/page_alloc.c
@@ -3544,7 +3544,7 @@ static void __paginginit free_area_init_
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
-			zone->lru[l].nr_scan = 0;
+			zone->lru[l].nr_saved_scan = 0;
 		}
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
