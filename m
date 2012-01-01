Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id AE4066B00A4
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:46:38 -0500 (EST)
Received: by iacb35 with SMTP id b35so33333451iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:46:38 -0800 (PST)
Date: Sat, 31 Dec 2011 23:46:35 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/6] mm: remove isolate_pages
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312345250.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

The isolate_pages() level in vmscan.c offers little but indirection:
merge it into isolate_lru_pages() as the compiler does, and use the
names nr_to_scan and nr_scanned in each case.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |   61 ++++++++++++++++++++++----------------------------
 1 file changed, 27 insertions(+), 34 deletions(-)

--- mmotm.orig/mm/vmscan.c	2011-12-30 21:21:34.651338587 -0800
+++ mmotm/mm/vmscan.c	2011-12-30 21:30:02.315350653 -0800
@@ -1136,25 +1136,36 @@ int __isolate_lru_page(struct page *page
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @src:	The LRU list to pull pages off.
+ * @mz:		The mem_cgroup_zone to pull pages from.
  * @dst:	The temp list to put pages on to.
- * @scanned:	The number of pages that were scanned.
+ * @nr_scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
  * @mode:	One of the LRU isolation modes
+ * @active:	True [1] if isolating active pages
  * @file:	True [1] if isolating file [!anon] pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, isolate_mode_t mode,
-		int file)
+		struct mem_cgroup_zone *mz, struct list_head *dst,
+		unsigned long *nr_scanned, int order, isolate_mode_t mode,
+		int active, int file)
 {
+	struct lruvec *lruvec;
+	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
 	unsigned long nr_lumpy_dirty = 0;
 	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
+	int lru = LRU_BASE;
+
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	if (active)
+		lru += LRU_ACTIVE;
+	if (file)
+		lru += LRU_FILE;
+	src = &lruvec->lists[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1263,7 +1274,7 @@ static unsigned long isolate_lru_pages(u
 			nr_lumpy_failed++;
 	}
 
-	*scanned = scan;
+	*nr_scanned = scan;
 
 	trace_mm_vmscan_lru_isolate(order,
 			nr_to_scan, scan,
@@ -1273,23 +1284,6 @@ static unsigned long isolate_lru_pages(u
 	return nr_taken;
 }
 
-static unsigned long isolate_pages(unsigned long nr, struct mem_cgroup_zone *mz,
-				   struct list_head *dst,
-				   unsigned long *scanned, int order,
-				   isolate_mode_t mode, int active, int file)
-{
-	struct lruvec *lruvec;
-	int lru = LRU_BASE;
-
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
-	if (active)
-		lru += LRU_ACTIVE;
-	if (file)
-		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
-				 scanned, order, mode, file);
-}
-
 /*
  * clear_active_flags() is a helper for shrink_active_list(), clearing
  * any active bits from the pages in the list.
@@ -1559,9 +1553,9 @@ shrink_inactive_list(unsigned long nr_to
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_pages(nr_to_scan, mz, &page_list,
-				 &nr_scanned, sc->order,
-				 reclaim_mode, 0, file);
+	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list,
+				     &nr_scanned, sc->order,
+				     reclaim_mode, 0, file);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1700,13 +1694,13 @@ static void move_active_pages_to_lru(str
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
-static void shrink_active_list(unsigned long nr_pages,
+static void shrink_active_list(unsigned long nr_to_scan,
 			       struct mem_cgroup_zone *mz,
 			       struct scan_control *sc,
 			       int priority, int file)
 {
 	unsigned long nr_taken;
-	unsigned long pgscanned;
+	unsigned long nr_scanned;
 	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
@@ -1726,16 +1720,15 @@ static void shrink_active_list(unsigned
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_pages(nr_pages, mz, &l_hold,
-				 &pgscanned, sc->order,
-				 reclaim_mode, 1, file);
-
+	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold,
+				     &nr_scanned, sc->order,
+				     reclaim_mode, 1, file);
 	if (global_reclaim(sc))
-		zone->pages_scanned += pgscanned;
+		zone->pages_scanned += nr_scanned;
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
