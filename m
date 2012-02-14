Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id F393F6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 08:28:19 -0500 (EST)
Date: Tue, 14 Feb 2012 21:18:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120214131812.GA17625@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <20120214101931.GB5938@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120214101931.GB5938@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Tue, Feb 14, 2012 at 10:19:31AM +0000, Mel Gorman wrote:
> On Sat, Feb 11, 2012 at 08:44:45PM +0800, Wu Fengguang wrote:
> > <SNIP>
> > --- linux.orig/mm/vmscan.c	2012-02-03 21:42:21.000000000 +0800
> > +++ linux/mm/vmscan.c	2012-02-11 17:28:54.000000000 +0800
> > @@ -813,6 +813,8 @@ static unsigned long shrink_page_list(st
> >  
> >  		if (PageWriteback(page)) {
> >  			nr_writeback++;
> > +			if (PageReclaim(page))
> > +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  			/*
> >  			 * Synchronous reclaim cannot queue pages for
> >  			 * writeback due to the possibility of stack overflow
> 
> I didn't look closely at the rest of the patch, I'm just focusing on the
> congestion_wait part. You called this out yourself but this is in fact
> really really bad. If this is in place and a user copies a large amount of
> data to slow storage like a USB stick, the system will stall severely. A
> parallel streaming reader will certainly have major issues as it will enter
> page reclaim, find a bunch of dirty USB-backed pages at the end of the LRU
> (20% of memory potentially) and stall for HZ/10 on each one of them. How
> badly each process is affected will vary.

Cannot agree any more the principle...me just want to demonstrate the
idea first :-)
 
> For the OOM problem, a more reasonable stopgap might be to identify when
> a process is scanning a memcg at high priority and encountered all
> PageReclaim with no forward progress and to congestion_wait() if that
> situation occurs. A preferable way would be to wait until the flusher
> wakes up a waiter on PageReclaim pages to be written out because we want
> to keep moving way from congestion_wait() if at all possible.

Good points! Below is the more serious page reclaim changes.

The dirty/writeback pages may often come close to each other in the
LRU list, so the local test during a 32-page scan may still trigger
reclaim waits unnecessarily. Some global information on the percent
of dirty/writeback pages in the LRU list may help. Anyway the added
tests should still be much better than no protection.

A global wait queue and reclaim_wait() is introduced. The waiters will
be wakeup when pages are rotated by end_page_writeback() or lru drain.

I have to say its effectiveness depends on the filesystem... ext4
and btrfs do fluent IO completions, so reclaim_wait() works pretty
well:
              dd-14560 [017] ....  1360.894605: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=10000
              dd-14560 [017] ....  1360.904456: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=8000
              dd-14560 [017] ....  1360.908293: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
              dd-14560 [017] ....  1360.923960: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=15000
              dd-14560 [017] ....  1360.927810: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
              dd-14560 [017] ....  1360.931656: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
              dd-14560 [017] ....  1360.943503: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=10000
              dd-14560 [017] ....  1360.953289: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=7000
              dd-14560 [017] ....  1360.957177: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
              dd-14560 [017] ....  1360.972949: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=15000

However XFS does IO completions in very large batches (there may be
only several big IO completions in one second). So reclaim_wait()
mostly end up waiting to the full HZ/10 timeout:

              dd-4177  [008] ....   866.367661: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [010] ....   866.567583: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [012] ....   866.767458: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [013] ....   866.867419: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [008] ....   867.167266: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [010] ....   867.367168: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [012] ....   867.818950: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [013] ....   867.918905: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [013] ....   867.971657: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=52000
              dd-4177  [013] ....   867.971812: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=0
              dd-4177  [008] ....   868.355700: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
              dd-4177  [010] ....   868.700515: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000

> Another possibility would be to relook at LRU_IMMEDIATE but right now it
> requires a page flag and I haven't devised a way around that. Besides,
> it would only address the problem of PageREclaim pages being encountered,
> it would not handle the case where a memcg was filled with PageReclaim pages.

I also considered things like LRU_IMMEDIATE, however got no clear idea yet.
Since the simple "wait on PG_reclaim" approach appears to work for this
memcg dd case, it effectively disables me to think any further ;-)

For the single dd inside memcg, ext4 is now working pretty well, with
least CPU overheads:

(running from another test box, so not directly comparable with old tests)

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.03    0.00    0.85    5.35    0.00   93.77

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  112.00     0.00 57348.00  1024.07    81.66 1045.21   8.93 100.00

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.00    0.00    0.69    4.07    0.00   95.24

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00   142.00    0.00  112.00     0.00 56832.00  1014.86   127.94  790.04   8.93 100.00

And xfs a bit less fluent:

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.00    0.00    3.79    2.54    0.00   93.68

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  108.00     0.00 54644.00  1011.93    48.13 1044.83   8.44  91.20

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.00    0.00    3.38    3.88    0.00   92.74

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  105.00     0.00 53156.00  1012.50   128.50  451.90   9.25  97.10

btrfs also looks good:

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.00    0.00    8.05    3.85    0.00   88.10

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  108.00     0.00 53248.00   986.07    88.11  643.99   9.26 100.00

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
                   0.00    0.00    4.04    2.51    0.00   93.45

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        sda               0.00     0.00    0.00  112.00     0.00 57344.00  1024.00    91.58  998.41   8.93 100.00


Thanks,
Fengguang
---

--- linux.orig/include/linux/backing-dev.h	2012-02-14 19:43:06.000000000 +0800
+++ linux/include/linux/backing-dev.h	2012-02-14 19:49:26.000000000 +0800
@@ -304,6 +304,8 @@ void clear_bdi_congested(struct backing_
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
 long wait_iff_congested(struct zone *zone, int sync, long timeout);
+long reclaim_wait(long timeout);
+void reclaim_rotated(void);
 
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
 {
--- linux.orig/mm/backing-dev.c	2012-02-14 19:26:15.000000000 +0800
+++ linux/mm/backing-dev.c	2012-02-14 20:09:45.000000000 +0800
@@ -873,3 +873,38 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL(wait_iff_congested);
+
+static DECLARE_WAIT_QUEUE_HEAD(reclaim_wqh);
+
+/**
+ * reclaim_wait - wait for some pages being rotated to the LRU tail
+ * @timeout: timeout in jiffies
+ *
+ * Wait until @timeout, or when some (typically PG_reclaim under writeback)
+ * pages rotated to the LRU so that page reclaim can make progress.
+ */
+long reclaim_wait(long timeout)
+{
+	long ret;
+	unsigned long start = jiffies;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(&reclaim_wqh, &wait, TASK_KILLABLE);
+	ret = io_schedule_timeout(timeout);
+	finish_wait(&reclaim_wqh, &wait);
+
+	trace_writeback_reclaim_wait(jiffies_to_usecs(timeout),
+				     jiffies_to_usecs(jiffies - start));
+
+	return ret;
+}
+EXPORT_SYMBOL(reclaim_wait);
+
+void reclaim_rotated()
+{
+	wait_queue_head_t *wqh = &reclaim_wqh;
+
+	if (waitqueue_active(wqh))
+		wake_up(wqh);
+}
+
--- linux.orig/mm/swap.c	2012-02-14 19:40:10.000000000 +0800
+++ linux/mm/swap.c	2012-02-14 19:45:13.000000000 +0800
@@ -253,6 +253,7 @@ static void pagevec_move_tail(struct pag
 
 	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
 	__count_vm_events(PGROTATED, pgmoved);
+	reclaim_rotated();
 }
 
 /*
--- linux.orig/mm/vmscan.c	2012-02-14 17:53:27.000000000 +0800
+++ linux/mm/vmscan.c	2012-02-14 19:44:11.000000000 +0800
@@ -767,7 +767,8 @@ static unsigned long shrink_page_list(st
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_writeback)
+				      unsigned long *ret_nr_writeback,
+				      unsigned long *ret_nr_pgreclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -776,6 +777,7 @@ static unsigned long shrink_page_list(st
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 
 	cond_resched();
 
@@ -813,6 +815,10 @@ static unsigned long shrink_page_list(st
 
 		if (PageWriteback(page)) {
 			nr_writeback++;
+			if (PageReclaim(page))
+				nr_pgreclaim++;
+			else
+				SetPageReclaim(page);
 			/*
 			 * Synchronous reclaim cannot queue pages for
 			 * writeback due to the possibility of stack overflow
@@ -874,12 +880,15 @@ static unsigned long shrink_page_list(st
 			nr_dirty++;
 
 			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but do not writeback
-			 * unless under significant pressure.
+			 * run into the visited page again: we are scanning
+			 * faster than the flusher can writeout dirty pages
 			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
+			if (page_is_file_cache(page) && PageReclaim(page)) {
+				nr_pgreclaim++;
+				goto keep_locked;
+			}
+			if (page_is_file_cache(page) && mapping &&
+			    flush_inode_page(mapping, page, false) >= 0) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1028,6 +1037,7 @@ keep_lumpy:
 	count_vm_events(PGACTIVATE, pgactivate);
 	*ret_nr_dirty += nr_dirty;
 	*ret_nr_writeback += nr_writeback;
+	*ret_nr_pgreclaim += nr_pgreclaim;
 	return nr_reclaimed;
 }
 
@@ -1087,8 +1097,10 @@ int __isolate_lru_page(struct page *page
 	 */
 	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
 		/* All the caller can do on PageWriteback is block */
-		if (PageWriteback(page))
+		if (PageWriteback(page)) {
+			SetPageReclaim(page);
 			return ret;
+		}
 
 		if (PageDirty(page)) {
 			struct address_space *mapping;
@@ -1509,6 +1521,7 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
 	struct zone *zone = mz->zone;
 
@@ -1559,13 +1572,13 @@ shrink_inactive_list(unsigned long nr_to
 	spin_unlock_irq(&zone->lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
-						&nr_dirty, &nr_writeback);
+				&nr_dirty, &nr_writeback, &nr_pgreclaim);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
 		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
-					priority, &nr_dirty, &nr_writeback);
+			priority, &nr_dirty, &nr_writeback, &nr_pgreclaim);
 	}
 
 	spin_lock_irq(&zone->lru_lock);
@@ -1608,6 +1621,8 @@ shrink_inactive_list(unsigned long nr_to
 	 */
 	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+	if (nr_pgreclaim && nr_pgreclaim >= (nr_taken >> (DEF_PRIORITY-priority)))
+		reclaim_wait(HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
@@ -2382,8 +2397,6 @@ static unsigned long do_try_to_free_page
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
