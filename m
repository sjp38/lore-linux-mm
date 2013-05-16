Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 77DF56B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:07:29 -0400 (EDT)
Date: Thu, 16 May 2013 14:07:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/9] mm: vmscan: Block kswapd if it is encountering pages
 under writeback
Message-ID: <20130516130722.GG11497@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <1368432760-21573-8-git-send-email-mgorman@suse.de>
 <20130515143902.2a381d9a5e11298bf58771d8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130515143902.2a381d9a5e11298bf58771d8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 15, 2013 at 02:39:02PM -0700, Andrew Morton wrote:
> On Mon, 13 May 2013 09:12:38 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Historically, kswapd used to congestion_wait() at higher priorities if it
> > was not making forward progress. This made no sense as the failure to make
> > progress could be completely independent of IO. It was later replaced by
> > wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
> > wait on congested zones in balance_pgdat()) as it was duplicating logic
> > in shrink_inactive_list().
> > 
> > This is problematic. If kswapd encounters many pages under writeback and
> > it continues to scan until it reaches the high watermark then it will
> > quickly skip over the pages under writeback and reclaim clean young
> > pages or push applications out to swap.
> > 
> > The use of wait_iff_congested() is not suited to kswapd as it will only
> > stall if the underlying BDI is really congested or a direct reclaimer was
> > unable to write to the underlying BDI. kswapd bypasses the BDI congestion
> > as it sets PF_SWAPWRITE but even if this was taken into account then it
> > would cause direct reclaimers to stall on writeback which is not desirable.
> > 
> > This patch sets a ZONE_WRITEBACK flag if direct reclaim or kswapd is
> > encountering too many pages under writeback. If this flag is set and
> > kswapd encounters a PageReclaim page under writeback then it'll assume
> > that the LRU lists are being recycled too quickly before IO can complete
> > and block waiting for some IO to complete.
> > 
> >
> > ...
> >
> >  		if (PageWriteback(page)) {
> > -			/*
> > -			 * memcg doesn't have any dirty pages throttling so we
> > -			 * could easily OOM just because too many pages are in
> > -			 * writeback and there is nothing else to reclaim.
> > -			 *
> > -			 * Check __GFP_IO, certainly because a loop driver
> > -			 * thread might enter reclaim, and deadlock if it waits
> > -			 * on a page for which it is needed to do the write
> > -			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
> > -			 * but more thought would probably show more reasons.
> > -			 *
> > -			 * Don't require __GFP_FS, since we're not going into
> > -			 * the FS, just waiting on its writeback completion.
> > -			 * Worryingly, ext4 gfs2 and xfs allocate pages with
> > -			 * grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so
> > -			 * testing may_enter_fs here is liable to OOM on them.
> > -			 */
> > -			if (global_reclaim(sc) ||
> > +			/* Case 1 above */
> > +			if (current_is_kswapd() &&
> > +			    PageReclaim(page) &&
> > +			    zone_is_reclaim_writeback(zone)) {
> > +				wait_on_page_writeback(page);
> 
> wait_on_page_writeback() is problematic.
> 
> - The page could be against data which is at the remote end of the
>   disk and the wait takes far too long.
> 
> - The page could be against a really slow device, perhaps one which
>   has a (relatively!) large amount of dirty data pending.
> 

These are both similar points, the page being waited upon could take an
abnormal amount of time to be written due to either slow storage or a
deep writeback queue. This is true.

> - (What happens if the wait is against a page which is backed by a
>   device which is failing or was unplugged or is taking 60 seconds per
>   -EIO or whatever?)
> 
> - (Can the wait be against an NFS/NBD/whatever page whose ethernet
>   cable got unplugged?)
> 

Yes it can and if it happens, kswapd will halt for long periods of time
deferring all reclaim to direct reclaim. The user-visible impact is that
unplugged storage may result in more stalls due to direct reclaim.

The situation gets worse if dirty_ratio amount of pages are backed by
disconnected storage and the storage is unwilling/unable to discard the
data. Eventually such a system will have every dirtying process halt in
balance_dirty_pages. You're correct in pointing out that this patch makes
the situation slightly worse by indirectly adding kswapd to the list of
processes that gets stalled.

> - The termination of wait_on_page_writeback() simply doesn't tell us
>   what we want to know here: that there has been a useful amount of
>   writeback completion against the pages on the tail of this LRU.
> 

Neither does wait_iff_congested() or congestion_wait() if it waits on the
wrong queue, wakes up due to IO completing on an unrelated backing_dev or
wakes up after the timeout with no IO completed.  Even if the congestion
functions wakeup due to IO being complete, there is no guarantee that
the completed IO is for pages at the end of the LRU or even on the same
node. As this was already marked PageReclaim and is under writeback there
is a reasonable assumption it has been on the LRU for some time and that
wait_on_page_writeback() is not necessarily the worst decision. This is
what I was taking into account when choosing wait_on_page_writeback().

However, the unplugged scenario is a good point that would be tricky
to debug and of the choices available, congestion_wait() is better than
wait_iff_congested() in this case. It is guaranteed to stall kswapd and we
*know* at least one page is under writeback so it does not fall foul of the
old situation where we stalled in congestion_wait() when no IO was in flight.

Would you like to replace the patch with this version? It includes a
comment explaining why wait_on_page_writeback() is not used.

---8<---
mm: vmscan: Block kswapd if it is encountering pages under writeback

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
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h |  8 +++++
 mm/vmscan.c            | 80 ++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 66 insertions(+), 22 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2aaf72f..fce64af 100644
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
index d6c916d..45aee36 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -724,25 +724,53 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
+		 *    IO can complete. Waiting on the page itself risks an
+		 *    indefinite stall if it is impossible to writeback the
+		 *    page due to IO error or disconnected storage so instead
+		 *    block for HZ/10 or until some IO completes then clear the
+		 *    ZONE_WRITEBACK flag to recheck if the condition exists.
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
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				zone_clear_flag(zone, ZONE_WRITEBACK);
+
+			/* Case 2 above */
+			} else if (global_reclaim(sc) ||
 			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
 				/*
 				 * This is slightly racy - end_page_writeback()
@@ -757,9 +785,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -1374,8 +1406,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
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
@@ -2669,8 +2703,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
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
@@ -2697,6 +2731,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	if (nr_slab == 0 && !zone_reclaimable(zone))
 		zone->all_unreclaimable = 1;
 
+	zone_clear_flag(zone, ZONE_WRITEBACK);
+
 	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
