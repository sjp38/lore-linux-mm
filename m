Date: Thu, 15 Aug 2002 21:24:45 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] don't write all inactive pages at once
Message-ID: <Pine.LNX.4.44L.0208152122130.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: billh@gnuppy.monkey.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch, against current 2.4-rmap, makes sure we don't
write the whole inactive dirty list to disk at once and seems to
greatly improve system response time when under swap or other heavy
IO load.

Scanning could be much more efficient by using a marker page or
similar tricks, but for now I'm going for the minimalist approach.
If this thing works I'll make it fancy.

Please test this patch and let me know what you think.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


===== mm/vmscan.c 1.71 vs edited =====
--- 1.71/mm/vmscan.c	Tue Aug  6 15:11:18 2002
+++ edited/mm/vmscan.c	Thu Aug 15 21:11:59 2002
@@ -195,6 +195,7 @@
  * page_launder_zone - clean dirty inactive pages, move to inactive_clean list
  * @zone: zone to free pages in
  * @gfp_mask: what operations we are allowed to do
+ * @full_flush: full-out page flushing, if we couldn't get enough clean pages
  *
  * This function is called when we are low on free / inactive_clean
  * pages, its purpose is to refill the free/clean list as efficiently
@@ -208,19 +209,30 @@
  * This code is heavily inspired by the FreeBSD source code. Thanks
  * go out to Matthew Dillon.
  */
-#define	CAN_DO_FS	((gfp_mask & __GFP_FS) && should_write)
-int page_launder_zone(zone_t * zone, int gfp_mask, int priority)
+int page_launder_zone(zone_t * zone, int gfp_mask, int full_flush)
 {
-	int maxscan, cleaned_pages, target;
-	struct list_head * entry;
+	int maxscan, cleaned_pages, target, maxlaunder, iopages;
+	struct list_head * entry, * next;

 	target = free_plenty(zone);
-	cleaned_pages = 0;
+	cleaned_pages = iopages = 0;
+
+	/* If we can get away with it, only flush 2 MB worth of dirty pages */
+	if (full_flush)
+		maxlaunder = 1000000;
+	else {
+		maxlaunder = min_t(int, 512, zone->inactive_dirty_pages / 4);
+		maxlaunder = max(maxlaunder, free_plenty(zone));
+	}

 	/* The main launder loop. */
+rescan:
 	spin_lock(&pagemap_lru_lock);
-	maxscan = zone->inactive_dirty_pages >> priority;
-	while (maxscan-- && !list_empty(&zone->inactive_dirty_list)) {
+	maxscan = zone->inactive_dirty_pages;
+	entry = zone->inactive_dirty_list.prev;
+	next = entry->prev;
+	while (maxscan-- && !list_empty(&zone->inactive_dirty_list) &&
+			next != &zone->inactive_dirty_list) {
 		struct page * page;

 		/* Low latency reschedule point */
@@ -231,14 +243,20 @@
 			continue;
 		}

-		entry = zone->inactive_dirty_list.prev;
+		entry = next;
+		next = entry->prev;
 		page = list_entry(entry, struct page, lru);

+		/* This page was removed while we looked the other way. */
+		if (!PageInactiveDirty(page))
+			goto rescan;
+
 		if (cleaned_pages > target)
 			break;

-		list_del(entry);
-		list_add(entry, &zone->inactive_dirty_list);
+		/* Stop doing IO if we've laundered too many pages already. */
+		if (maxlaunder < 0)
+			gfp_mask &= ~(__GFP_IO|__GFP_FS);

 		/* Wrong page on list?! (list corruption, should not happen) */
 		if (!PageInactiveDirty(page)) {
@@ -257,7 +275,6 @@

 		/*
 		 * The page is locked. IO in progress?
-		 * Move it to the back of the list.
 		 * Acquire PG_locked early in order to safely
 		 * access page->mapping.
 		 */
@@ -341,10 +358,16 @@
 				spin_unlock(&pagemap_lru_lock);

 				writepage(page);
+				maxlaunder--;
 				page_cache_release(page);

 				spin_lock(&pagemap_lru_lock);
 				continue;
+			} else {
+				UnlockPage(page);
+				list_del(entry);
+				list_add(entry, &zone->inactive_dirty_list);
+				continue;
 			}
 		}

@@ -391,6 +414,7 @@
 				/* failed to drop the buffers so stop here */
 				UnlockPage(page);
 				page_cache_release(page);
+				maxlaunder--;

 				spin_lock(&pagemap_lru_lock);
 				continue;
@@ -443,21 +467,19 @@
  */
 int page_launder(int gfp_mask)
 {
-	int maxtry = 1 << DEF_PRIORITY;
 	struct zone_struct * zone;
 	int freed = 0;

 	/* Global balancing while we have a global shortage. */
-	while (maxtry-- && free_high(ALL_ZONES) >= 0) {
+	if (free_high(ALL_ZONES) >= 0)
 		for_each_zone(zone)
 			if (free_plenty(zone) >= 0)
-				freed += page_launder_zone(zone, gfp_mask, 6);
-	}
+				freed += page_launder_zone(zone, gfp_mask, 0);

 	/* Clean up the remaining zones with a serious shortage, if any. */
 	for_each_zone(zone)
 		if (free_min(zone) >= 0)
-			freed += page_launder_zone(zone, gfp_mask, 0);
+			freed += page_launder_zone(zone, gfp_mask, 1);

 	return freed;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
