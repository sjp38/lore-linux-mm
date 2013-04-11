Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 781656B003A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:58:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering pages under writeback
Date: Thu, 11 Apr 2013 20:57:55 +0100
Message-Id: <1365710278-6807-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1365710278-6807-1-git-send-email-mgorman@suse.de>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Historically, kswapd used to congestion_wait() at higher priorities if it
was not making forward progress. This made no sense as the failure to make
progress could be completely independent of IO. It was later replaced by
wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
wait on congested zones in balance_pgdat()) as it was duplicating logic
in shrink_inactive_list().

This is problematic. If kswapd encounters many pages under writeback and
it continues to scan until it reaches the high watermark then it will
quickly skip over the pages under writeback and reclaim clean young
pages or push applications out to swap.

The use of wait_iff_congested() is not suited to kswapd as it will only
stall if the underlying BDI is really congested or a direct reclaimer was
unable to write to the underlying BDI. kswapd bypasses the BDI congestion
as it sets PF_SWAPWRITE but even if this was taken into account then it
would cause direct reclaimers to stall on writeback which is not desirable.

This patch sets a ZONE_WRITEBACK flag if direct reclaim or kswapd is
encountering too many pages under writeback. If this flag is set and
kswapd encounters a PageReclaim page under writeback then it'll assume
that the LRU lists are being recycled too quickly before IO can complete
and block waiting for some IO to complete.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/mmzone.h |  8 ++++++
 mm/vmscan.c            | 78 ++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 64 insertions(+), 22 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ecf0c7d..264e203 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -499,6 +499,9 @@ typedef enum {
 					 * many dirty file pages at the tail
 					 * of the LRU.
 					 */
+	ZONE_WRITEBACK,			/* reclaim scanning has recently found
+					 * many pages under writeback
+					 */
 } zone_flags_t;
 
 static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
@@ -526,6 +529,11 @@ static inline int zone_is_reclaim_dirty(const struct zone *zone)
 	return test_bit(ZONE_TAIL_LRU_DIRTY, &zone->flags);
 }
 
+static inline int zone_is_reclaim_writeback(const struct zone *zone)
+{
+	return test_bit(ZONE_WRITEBACK, &zone->flags);
+}
+
 static inline int zone_is_reclaim_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 22e8ca9..a20f2a9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -723,25 +723,51 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
+		/*
+		 * If a page at the tail of the LRU is under writeback, there
+		 * are three cases to consider.
+		 *
+		 * 1) If reclaim is encountering an excessive number of pages
+		 *    under writeback and this page is both under writeback and
+		 *    PageReclaim then it indicates that pages are being queued
+		 *    for IO but are being recycled through the LRU before the
+		 *    IO can complete. In this case, wait on the IO to complete
+		 *    and then clear the ZONE_WRITEBACK flag to recheck if the
+		 *    condition exists.
+		 *
+		 * 2) Global reclaim encounters a page, memcg encounters a
+		 *    page that is not marked for immediate reclaim or
+		 *    the caller does not have __GFP_IO. In this case mark
+		 *    the page for immediate reclaim and continue scanning.
+		 *
+		 *    __GFP_IO is checked  because a loop driver thread might
+		 *    enter reclaim, and deadlock if it waits on a page for
+		 *    which it is needed to do the write (loop masks off
+		 *    __GFP_IO|__GFP_FS for this reason); but more thought
+		 *    would probably show more reasons.
+		 *
+		 *    Don't require __GFP_FS, since we're not going into the
+		 *    FS, just waiting on its writeback completion. Worryingly,
+		 *    ext4 gfs2 and xfs allocate pages with
+		 *    grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so testing
+		 *    may_enter_fs here is liable to OOM on them.
+		 *
+		 * 3) memcg encounters a page that is not already marked
+		 *    PageReclaim. memcg does not have any dirty pages
+		 *    throttling so we could easily OOM just because too many
+		 *    pages are in writeback and there is nothing else to
+		 *    reclaim. Wait for the writeback to complete.
+		 */
 		if (PageWriteback(page)) {
-			/*
-			 * memcg doesn't have any dirty pages throttling so we
-			 * could easily OOM just because too many pages are in
-			 * writeback and there is nothing else to reclaim.
-			 *
-			 * Check __GFP_IO, certainly because a loop driver
-			 * thread might enter reclaim, and deadlock if it waits
-			 * on a page for which it is needed to do the write
-			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
-			 * but more thought would probably show more reasons.
-			 *
-			 * Don't require __GFP_FS, since we're not going into
-			 * the FS, just waiting on its writeback completion.
-			 * Worryingly, ext4 gfs2 and xfs allocate pages with
-			 * grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so
-			 * testing may_enter_fs here is liable to OOM on them.
-			 */
-			if (global_reclaim(sc) ||
+			/* Case 1 above */
+			if (current_is_kswapd() &&
+			    PageReclaim(page) &&
+			    zone_is_reclaim_writeback(zone)) {
+				wait_on_page_writeback(page);
+				zone_clear_flag(zone, ZONE_WRITEBACK);
+
+			/* Case 2 above */
+			} else if (global_reclaim(sc) ||
 			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
 				/*
 				 * This is slightly racy - end_page_writeback()
@@ -756,9 +782,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 */
 				SetPageReclaim(page);
 				nr_writeback++;
+
 				goto keep_locked;
+
+			/* Case 3 above */
+			} else {
+				wait_on_page_writeback(page);
 			}
-			wait_on_page_writeback(page);
 		}
 
 		if (!force_reclaim)
@@ -1373,8 +1403,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 *                     isolated page is PageWriteback
 	 */
 	if (nr_writeback && nr_writeback >=
-			(nr_taken >> (DEF_PRIORITY - sc->priority)))
+			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+		zone_set_flag(zone, ZONE_WRITEBACK);
+	}
 
 	/*
 	 * Similarly, if many dirty pages are encountered that are not
@@ -2658,8 +2690,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  * the high watermark.
  *
  * Returns true if kswapd scanned at least the requested number of pages to
- * reclaim. This is used to determine if the scanning priority needs to be
- * raised.
+ * reclaim or if the lack of progress was due to pages under writeback.
+ * This is used to determine if the scanning priority needs to be raised.
  */
 static bool kswapd_shrink_zone(struct zone *zone,
 			       struct scan_control *sc,
@@ -2686,6 +2718,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	if (nr_slab == 0 && !zone_reclaimable(zone))
 		zone->all_unreclaimable = 1;
 
+	zone_clear_flag(zone, ZONE_WRITEBACK);
+
 	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
