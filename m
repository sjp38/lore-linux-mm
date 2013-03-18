From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
Date: Mon, 18 Mar 2013 19:08:50 +0800
Message-ID: <30781.6345165067$1363604998@news.gmane.org>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-7-git-send-email-mgorman@suse.de>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UHXwX-0003sf-EX
	for glkm-linux-mm-2@m.gmane.org; Mon, 18 Mar 2013 12:09:29 +0100
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E68676B003B
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:08:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 18 Mar 2013 21:02:37 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C62772CE8055
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:08:52 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2IAu1u849938648
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 21:56:02 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2IB8pgi016176
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:08:52 +1100
Content-Disposition: inline
In-Reply-To: <1363525456-10448-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 01:04:12PM +0000, Mel Gorman wrote:
>Currently kswapd queues dirty pages for writeback if scanning at an elevated
>priority but the priority kswapd scans at is not related to the number
>of unqueued dirty encountered.  Since commit "mm: vmscan: Flatten kswapd
>priority loop", the priority is related to the size of the LRU and the
>zone watermark which is no indication as to whether kswapd should write
>pages or not.
>
>This patch tracks if an excessive number of unqueued dirty pages are being
>encountered at the end of the LRU.  If so, it indicates that dirty pages
>are being recycled before flusher threads can clean them and flags the
>zone so that kswapd will start writing pages until the zone is balanced.
>
>Signed-off-by: Mel Gorman <mgorman@suse.de>
>---
> include/linux/mmzone.h |  8 ++++++++
> mm/vmscan.c            | 29 +++++++++++++++++++++++------
> 2 files changed, 31 insertions(+), 6 deletions(-)
>
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index ede2749..edd6b98 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -495,6 +495,9 @@ typedef enum {
> 	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> 					 * a congested BDI
> 					 */
>+	ZONE_DIRTY,			/* reclaim scanning has recently found
>+					 * many dirty file pages
>+					 */
> } zone_flags_t;
>
> static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
>@@ -517,6 +520,11 @@ static inline int zone_is_reclaim_congested(const struct zone *zone)
> 	return test_bit(ZONE_CONGESTED, &zone->flags);
> }
>
>+static inline int zone_is_reclaim_dirty(const struct zone *zone)
>+{
>+	return test_bit(ZONE_DIRTY, &zone->flags);
>+}
>+
> static inline int zone_is_reclaim_locked(const struct zone *zone)
> {
> 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index af3bb6f..493728b 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -675,13 +675,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> 				      struct zone *zone,
> 				      struct scan_control *sc,
> 				      enum ttu_flags ttu_flags,
>-				      unsigned long *ret_nr_dirty,
>+				      unsigned long *ret_nr_unqueued_dirty,
> 				      unsigned long *ret_nr_writeback,
> 				      bool force_reclaim)
> {
> 	LIST_HEAD(ret_pages);
> 	LIST_HEAD(free_pages);
> 	int pgactivate = 0;
>+	unsigned long nr_unqueued_dirty = 0;
> 	unsigned long nr_dirty = 0;
> 	unsigned long nr_congested = 0;
> 	unsigned long nr_reclaimed = 0;
>@@ -807,14 +808,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> 		if (PageDirty(page)) {
> 			nr_dirty++;
>
>+			if (!PageWriteback(page))
>+				nr_unqueued_dirty++;
>+
> 			/*
> 			 * Only kswapd can writeback filesystem pages to
>-			 * avoid risk of stack overflow but do not writeback
>-			 * unless under significant pressure.
>+			 * avoid risk of stack overflow but only writeback
>+			 * if many dirty pages have been encountered.
> 			 */
> 			if (page_is_file_cache(page) &&
> 					(!current_is_kswapd() ||
>-					 sc->priority >= DEF_PRIORITY - 2)) {
>+					 !zone_is_reclaim_dirty(zone))) {
> 				/*
> 				 * Immediately reclaim when written back.
> 				 * Similar in principal to deactivate_page()
>@@ -959,7 +963,7 @@ keep:
> 	list_splice(&ret_pages, page_list);
> 	count_vm_events(PGACTIVATE, pgactivate);
> 	mem_cgroup_uncharge_end();
>-	*ret_nr_dirty += nr_dirty;
>+	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
> 	*ret_nr_writeback += nr_writeback;
> 	return nr_reclaimed;
> }
>@@ -1372,6 +1376,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> 			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>
>+	/*
>+	 * Similarly, if many dirty pages are encountered that are not
>+	 * currently being written then flag that kswapd should start
>+	 * writing back pages.
>+	 */
>+	if (global_reclaim(sc) && nr_dirty &&
>+			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
>+		zone_set_flag(zone, ZONE_DIRTY);
>+
> 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> 		zone_idx(zone),
> 		nr_scanned, nr_reclaimed,
>@@ -2735,8 +2748,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> 				end_zone = i;
> 				break;
> 			} else {
>-				/* If balanced, clear the congested flag */
>+				/*
>+				 * If balanced, clear the dirty and congested
>+				 * flags
>+				 */
> 				zone_clear_flag(zone, ZONE_CONGESTED);
>+				zone_clear_flag(zone, ZONE_DIRTY);

Hi Mel,

There are two places in balance_pgdat clear ZONE_CONGESTED flag, one
is during scan zone which have free_pages <= high_wmark_pages(zone), the 
other one is zone get balanced after reclaim, it seems that you miss the 
later one.

Regards,
Wanpeng Li 

> 			}
> 		}
>
>-- 
>1.8.1.4
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
