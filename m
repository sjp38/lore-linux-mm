Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 24] remove nr_scan_inactive/active
Message-Id: <c8ec651562ad6514753e.1187786928@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778124 -7200
# Node ID c8ec651562ad6514753e408596e30d7d9e448a51
# Parent  b03dfad58a311488ec373c30fd5dc97dc03aecae
remove nr_scan_inactive/active

The older atomic_add/atomic_set were pointless (atomic_set vs atomic_add would
race), but removing them didn't actually remove the race, the race is still
there, for the same reasons atomic_add/set couldn't prevent it. This is really
the kind of code that I dislike because it's sort of buggy, and it shouldn't be
making any measurable difference and when it does something for real it can
only hurt!

The real focus is on shrink_zone (ignore the other places where it's being used
that are even less interesting). Assume two tasks adds to nr_scan_*active at
the same time (first line of the old buggy code), they'll effectively double their
scan rate, for no good reason. What can happen is that instead of scanning
nr_entries each, they'll scan nr_entries*2 each. The more CPUs the bigger the
race and the higher the multiplication effect and the harder it will be to
detect oom. In the case that nr_*active < sc->swap_cluster_max, regardless of
whatever future invocation of alloc_pages, we'll be going down in the
priorities in the current alloc_pages invocation if the DEF_PRIORITY was too
high to make any work, so again accumulating the nr_scan_*active doesn't seem
interesting even when it's smaller than sc->swap_cluster_max. Each task should
work for itself without much care of what the others are doing.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -229,8 +229,6 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
 	struct list_head	inactive_list;
-	unsigned long		nr_scan_active;
-	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2959,8 +2959,6 @@ static void __meminit free_area_init_cor
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
-		zone->nr_scan_active = 0;
-		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
 		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1020,20 +1020,11 @@ static unsigned long shrink_zone(int pri
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
-	zone->nr_scan_active +=
-		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
-		zone->nr_scan_active = 0;
-	else
+	nr_active = zone_page_state(zone, NR_ACTIVE) >> priority;
+	if (nr_active < sc->swap_cluster_max)
 		nr_active = 0;
-
-	zone->nr_scan_inactive +=
-		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
-	else
+	nr_inactive = zone_page_state(zone, NR_INACTIVE) >> priority;
+	if (nr_inactive < sc->swap_cluster_max)
 		nr_inactive = 0;
 
 	while (nr_active || nr_inactive) {
@@ -1500,22 +1491,14 @@ static unsigned long shrink_all_zones(un
 
 		/* For pass = 0 we don't shrink the active list */
 		if (pass > 0) {
-			zone->nr_scan_active +=
-				(zone_page_state(zone, NR_ACTIVE) >> prio) + 1;
-			if (zone->nr_scan_active >= nr_pages || pass > 3) {
-				zone->nr_scan_active = 0;
-				nr_to_scan = min(nr_pages,
-					zone_page_state(zone, NR_ACTIVE));
+			nr_to_scan = (zone_page_state(zone, NR_ACTIVE) >> prio) + 1;
+			if (nr_to_scan >= nr_pages || pass > 3) {
 				shrink_active_list(nr_to_scan, zone, sc, prio);
 			}
 		}
 
-		zone->nr_scan_inactive +=
-			(zone_page_state(zone, NR_INACTIVE) >> prio) + 1;
-		if (zone->nr_scan_inactive >= nr_pages || pass > 3) {
-			zone->nr_scan_inactive = 0;
-			nr_to_scan = min(nr_pages,
-				zone_page_state(zone, NR_INACTIVE));
+		nr_to_scan = (zone_page_state(zone, NR_INACTIVE) >> prio) + 1;
+		if (nr_to_scan >= nr_pages || pass > 3) {
 			ret += shrink_inactive_list(nr_to_scan, zone, sc);
 			if (ret >= nr_pages)
 				return ret;
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -555,7 +555,7 @@ static int zoneinfo_show(struct seq_file
 			   "\n        min      %lu"
 			   "\n        low      %lu"
 			   "\n        high     %lu"
-			   "\n        scanned  %lu (a: %lu i: %lu)"
+			   "\n        scanned  %lu"
 			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone_page_state(zone, NR_FREE_PAGES),
@@ -563,7 +563,6 @@ static int zoneinfo_show(struct seq_file
 			   zone->pages_low,
 			   zone->pages_high,
 			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
 			   zone->spanned_pages,
 			   zone->present_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
