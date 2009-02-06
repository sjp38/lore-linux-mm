Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 67F596B0047
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:13:12 -0500 (EST)
Message-Id: <20090206031324.004715023@cmpxchg.org>
Date: Fri, 06 Feb 2009 04:11:28 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/3][RFC] swsusp: shrink file cache first
References: <20090206031125.693559239@cmpxchg.org>
Content-Disposition: inline; filename=swsusp-shrink-file-cache-first.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

File cache pages are saved to disk either through normal writeback by
reclaim or by including them in the suspend image written to a
swapfile.

Writing them either way should take the same amount of time but doing
normal writeback and unmap changes the fault behaviour on resume from
prefault to on-demand paging, smoothening out resume and giving
previously cached pages the chance to stay out of memory completely if
they are not used anymore.

Another reason for preferring file page eviction is that the locality
principle is visible in fault patterns and swap might perform really
bad with subsequent faulting of contiguously mapped pages.

Since anon and file pages now live on different lists, selectively
scanning one type only is straight-forward.

This patch also removes the scanning of anon pages without allowing to
swap, which does not make much sense.

The five memory shrinking passes now look like this:

Pass 0:  shrink inactive file cache
This has the best chances of not being used any time soon again after
resume, so trade inactive file cache against space for anon pages.

Pass 1:  shrink file cache
Essentially the same as before but replenish the inactive file list
with borderline active pages.

Pass 2:  shrink all file pages and inactive anon
Reclaim mapped pages file pages and go for aged anon pages as well.

Pass 3:  shrink all file pages and anon
Same as before but also shrink the active anon list to have enough
anon pages for actual reclaim should we need pass 4.

Pass 4:  repeat pass 3

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2069,13 +2069,23 @@ static unsigned long shrink_all_zones(un
 
 		for_each_evictable_lru(l) {
 			enum zone_stat_item ls = NR_LRU_BASE + l;
-			unsigned long lru_pages = zone_page_state(zone, ls);
+			unsigned long lru_pages;
 
-			/* For pass = 0, we don't shrink the active list */
-			if (pass == 0 && (l == LRU_ACTIVE_ANON ||
-						l == LRU_ACTIVE_FILE))
-				continue;
+			switch (pass) {
+			case 0:
+				if (l == LRU_ACTIVE_FILE)
+					continue;
+			case 1:
+				if (l == LRU_INACTIVE_ANON)
+					continue;
+			case 2:
+				if (l == LRU_ACTIVE_ANON)
+					continue;
+			default:
+				break;
+			}
 
+			lru_pages = zone_page_state(zone, ls);
 			zone->lru[l].nr_scan += (lru_pages >> prio) + 1;
 			if (zone->lru[l].nr_scan >= nr_pages || pass > 3) {
 				unsigned long nr_to_scan;
@@ -2134,17 +2144,17 @@ unsigned long shrink_all_memory(unsigned
 
 	/*
 	 * We try to shrink LRUs in 5 passes:
-	 * 0 = Reclaim from inactive_list only
-	 * 1 = Reclaim from active list but don't reclaim mapped
-	 * 2 = 2nd pass of type 1
-	 * 3 = Reclaim mapped (normal reclaim)
-	 * 4 = 2nd pass of type 3
+	 * 0 = Reclaim unmapped inactive file pages
+	 * 1 = Reclaim unmapped file pages
+	 * 2 = Reclaim file and inactive anon pages
+	 * 3 = Reclaim file and anon pages
+	 * 4 = Second pass 3
 	 */
 	for (pass = 0; pass < 5; pass++) {
 		int prio;
 
-		/* Force reclaiming mapped pages in the passes #3 and #4 */
-		if (pass > 2)
+		/* Reclaim mapped pages in higher passes */
+		if (pass > 1)
 			sc.may_swap = 1;
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
