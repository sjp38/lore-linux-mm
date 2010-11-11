Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBF356B0071
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 14:07:09 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] mm,vmscan: Convert lumpy_mode into a bitmask
Date: Thu, 11 Nov 2010 19:07:02 +0000
Message-Id: <1289502424-12661-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1289502424-12661-1-git-send-email-mel@csn.ul.ie>
References: <1289502424-12661-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently lumpy_mode is an enum and determines if lumpy reclaim is off,
syncronous or asyncronous. In preparation for using compaction instead of
lumpy reclaim, this patch converts the flags into a bitmap.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |    6 +++---
 mm/vmscan.c                   |   37 +++++++++++++++++++------------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c255fcc..be76429 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -25,13 +25,13 @@
 
 #define trace_reclaim_flags(page, sync) ( \
 	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
 	)
 
 #define trace_shrink_flags(file, sync) ( \
-	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_MIXED : \
+	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_MIXED : \
 			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
-	(sync == LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	(sync & LUMPY_MODE_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8a6fdc..ffa438e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -51,11 +51,11 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
-enum lumpy_mode {
-	LUMPY_MODE_NONE,
-	LUMPY_MODE_ASYNC,
-	LUMPY_MODE_SYNC,
-};
+typedef unsigned __bitwise__ lumpy_mode;
+#define LUMPY_MODE_SINGLE		((__force lumpy_mode)0x01u)
+#define LUMPY_MODE_ASYNC		((__force lumpy_mode)0x02u)
+#define LUMPY_MODE_SYNC			((__force lumpy_mode)0x04u)
+#define LUMPY_MODE_CONTIGRECLAIM	((__force lumpy_mode)0x08u)
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
@@ -88,7 +88,7 @@ struct scan_control {
 	 * Intend to reclaim enough continuous memory rather than reclaim
 	 * enough amount of memory. i.e, mode for high order allocation.
 	 */
-	enum lumpy_mode lumpy_reclaim_mode;
+	lumpy_mode lumpy_reclaim_mode;
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
@@ -274,13 +274,13 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 				   bool sync)
 {
-	enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
+	lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
 
 	/*
 	 * Some reclaim have alredy been failed. No worth to try synchronous
 	 * lumpy reclaim.
 	 */
-	if (sync && sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
+	if (sync && sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
 		return;
 
 	/*
@@ -288,17 +288,18 @@ static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
 	 * trouble getting a small set of contiguous pages, we
 	 * will reclaim both active and inactive pages.
 	 */
+	sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->lumpy_reclaim_mode = mode;
+		sc->lumpy_reclaim_mode |= mode;
 	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->lumpy_reclaim_mode = mode;
+		sc->lumpy_reclaim_mode |= mode;
 	else
-		sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+		sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
 }
 
 static void disable_lumpy_reclaim_mode(struct scan_control *sc)
 {
-	sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
+	sc->lumpy_reclaim_mode = LUMPY_MODE_SINGLE | LUMPY_MODE_ASYNC;
 }
 
 static inline int is_page_cache_freeable(struct page *page)
@@ -429,7 +430,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		 * first attempt to free a range of pages fails.
 		 */
 		if (PageWriteback(page) &&
-		    sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC)
+		    (sc->lumpy_reclaim_mode & LUMPY_MODE_SYNC))
 			wait_on_page_writeback(page);
 
 		if (!PageWriteback(page)) {
@@ -615,7 +616,7 @@ static enum page_references page_check_references(struct page *page,
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
-	if (sc->lumpy_reclaim_mode != LUMPY_MODE_NONE)
+	if (sc->lumpy_reclaim_mode & LUMPY_MODE_CONTIGRECLAIM)
 		return PAGEREF_RECLAIM;
 
 	/*
@@ -732,7 +733,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * for any page for which writeback has already
 			 * started.
 			 */
-			if (sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC &&
+			if ((sc->lumpy_reclaim_mode & LUMPY_MODE_SYNC) &&
 			    may_enter_fs)
 				wait_on_page_writeback(page);
 			else {
@@ -1317,7 +1318,7 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
 		return false;
 
 	/* Only stall on lumpy reclaim */
-	if (sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
+	if (sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE)
 		return false;
 
 	/* If we have relaimed everything on the isolated list, no stall */
@@ -1368,7 +1369,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode == LUMPY_MODE_NONE ?
+			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
 					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, 0, file);
 		zone->pages_scanned += nr_scanned;
@@ -1381,7 +1382,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
-			sc->lumpy_reclaim_mode == LUMPY_MODE_NONE ?
+			sc->lumpy_reclaim_mode & LUMPY_MODE_SINGLE ?
 					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, sc->mem_cgroup,
 			0, file);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
