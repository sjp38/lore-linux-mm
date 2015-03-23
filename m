Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 68F888296B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:08:24 -0400 (EDT)
Received: by qcto4 with SMTP id o4so136809613qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:24 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id f35si11172859qkf.126.2015.03.22.22.08.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:08:23 -0700 (PDT)
Received: by qgep97 with SMTP id p97so5819873qge.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:23 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 18/18] mm: vmscan: remove memcg stalling on writeback pages during direct reclaim
Date: Mon, 23 Mar 2015 01:07:47 -0400
Message-Id: <1427087267-16592-19-git-send-email-tj@kernel.org>
In-Reply-To: <1427087267-16592-1-git-send-email-tj@kernel.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

Because writeback wasn't cgroup aware before, the usual dirty
throttling mechanism in balance_dirty_pages() didn't work for
processes under memcg limit.  The writeback path didn't know how much
memory is available or how fast the dirty pages are being written out
for a given memcg and balance_dirty_pages() didn't have any measure of
IO back pressure for the memcg.

To work around the issue, memcg implemented an ad-hoc dirty throttling
mechanism in the direct reclaim path by stalling on pages under
writeback which are encountered during direct reclaim scan.  This is
rather ugly and crude - none of the configurability, fairness, or
bandwidth-proportional distribution of the normal path.

The previous patches implemented proper memcg aware dirty throttling
and the ad-hoc mechanism is no longer necessary.  Remove it.

Note: I removed the parts which seemed obvious and it behaves fine
      while testing but my understanding of this code path is
      rudimentary and it's quite possible that I got something wrong.
      Please let me know if I got some wrong or more global_reclaim()
      sites should be updated.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vmscan.c | 109 ++++++++++++++++++------------------------------------------
 1 file changed, 33 insertions(+), 76 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9f8d3c0..d084c95 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -929,53 +929,24 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			nr_congested++;
 
 		/*
-		 * If a page at the tail of the LRU is under writeback, there
-		 * are three cases to consider.
-		 *
-		 * 1) If reclaim is encountering an excessive number of pages
-		 *    under writeback and this page is both under writeback and
-		 *    PageReclaim then it indicates that pages are being queued
-		 *    for IO but are being recycled through the LRU before the
-		 *    IO can complete. Waiting on the page itself risks an
-		 *    indefinite stall if it is impossible to writeback the
-		 *    page due to IO error or disconnected storage so instead
-		 *    note that the LRU is being scanned too quickly and the
-		 *    caller can stall after page list has been processed.
-		 *
-		 * 2) Global reclaim encounters a page, memcg encounters a
-		 *    page that is not marked for immediate reclaim or
-		 *    the caller does not have __GFP_IO. In this case mark
-		 *    the page for immediate reclaim and continue scanning.
-		 *
-		 *    __GFP_IO is checked  because a loop driver thread might
-		 *    enter reclaim, and deadlock if it waits on a page for
-		 *    which it is needed to do the write (loop masks off
-		 *    __GFP_IO|__GFP_FS for this reason); but more thought
-		 *    would probably show more reasons.
-		 *
-		 *    Don't require __GFP_FS, since we're not going into the
-		 *    FS, just waiting on its writeback completion. Worryingly,
-		 *    ext4 gfs2 and xfs allocate pages with
-		 *    grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so testing
-		 *    may_enter_fs here is liable to OOM on them.
-		 *
-		 * 3) memcg encounters a page that is not already marked
-		 *    PageReclaim. memcg does not have any dirty pages
-		 *    throttling so we could easily OOM just because too many
-		 *    pages are in writeback and there is nothing else to
-		 *    reclaim. Wait for the writeback to complete.
+		 * A page at the tail of the LRU is under writeback.  If
+		 * reclaim is encountering an excessive number of pages
+		 * under writeback and this page is both under writeback
+		 * and PageReclaim then it indicates that pages are being
+		 * queued for IO but are being recycled through the LRU
+		 * before the IO can complete.  Waiting on the page itself
+		 * risks an indefinite stall if it is impossible to
+		 * writeback the page due to IO error or disconnected
+		 * storage so instead note that the LRU is being scanned
+		 * too quickly and the caller can stall after page list has
+		 * been processed.
 		 */
 		if (PageWriteback(page)) {
-			/* Case 1 above */
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
 			    test_bit(ZONE_WRITEBACK, &zone->flags)) {
 				nr_immediate++;
-				goto keep_locked;
-
-			/* Case 2 above */
-			} else if (global_reclaim(sc) ||
-			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
+			} else {
 				/*
 				 * This is slightly racy - end_page_writeback()
 				 * might have just cleared PageReclaim, then
@@ -989,13 +960,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 */
 				SetPageReclaim(page);
 				nr_writeback++;
-
-				goto keep_locked;
-
-			/* Case 3 above */
-			} else {
-				wait_on_page_writeback(page);
 			}
+			goto keep_locked;
 		}
 
 		if (!force_reclaim)
@@ -1423,9 +1389,6 @@ static int too_many_isolated(struct zone *zone, int file,
 	if (current_is_kswapd())
 		return 0;
 
-	if (!global_reclaim(sc))
-		return 0;
-
 	if (file) {
 		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
 		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
@@ -1615,35 +1578,29 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		set_bit(ZONE_WRITEBACK, &zone->flags);
 
 	/*
-	 * memcg will stall in page writeback so only consider forcibly
-	 * stalling for global reclaim
+	 * Tag a zone as congested if all the dirty pages scanned were
+	 * backed by a congested BDI and wait_iff_congested will stall.
 	 */
-	if (global_reclaim(sc)) {
-		/*
-		 * Tag a zone as congested if all the dirty pages scanned were
-		 * backed by a congested BDI and wait_iff_congested will stall.
-		 */
-		if (nr_dirty && nr_dirty == nr_congested)
-			set_bit(ZONE_CONGESTED, &zone->flags);
+	if (nr_dirty && nr_dirty == nr_congested)
+		set_bit(ZONE_CONGESTED, &zone->flags);
 
-		/*
-		 * If dirty pages are scanned that are not queued for IO, it
-		 * implies that flushers are not keeping up. In this case, flag
-		 * the zone ZONE_DIRTY and kswapd will start writing pages from
-		 * reclaim context.
-		 */
-		if (nr_unqueued_dirty == nr_taken)
-			set_bit(ZONE_DIRTY, &zone->flags);
+	/*
+	 * If dirty pages are scanned that are not queued for IO, it
+	 * implies that flushers are not keeping up. In this case, flag the
+	 * zone ZONE_DIRTY and kswapd will start writing pages from reclaim
+	 * context.
+	 */
+	if (nr_unqueued_dirty == nr_taken)
+		set_bit(ZONE_DIRTY, &zone->flags);
 
-		/*
-		 * If kswapd scans pages marked marked for immediate
-		 * reclaim and under writeback (nr_immediate), it implies
-		 * that pages are cycling through the LRU faster than
-		 * they are written so also forcibly stall.
-		 */
-		if (nr_immediate && current_may_throttle())
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
-	}
+	/*
+	 * If kswapd scans pages marked marked for immediate reclaim and
+	 * under writeback (nr_immediate), it implies that pages are
+	 * cycling through the LRU faster than they are written so also
+	 * forcibly stall.
+	 */
+	if (nr_immediate && current_may_throttle())
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 	/*
 	 * Stall direct reclaim for IO completions if underlying BDIs or zone
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
