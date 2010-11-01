Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 030658D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 09:15:50 -0400 (EDT)
Date: Mon, 1 Nov 2010 20:14:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/2] writeback: integrated background writeback work
Message-ID: <20101101121408.GB9006@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100914124033.GA4874@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

Check whether background writeback is needed after finishing each
work.

When bdi flusher thread finishes doing some work check whether any
kind of background writeback needs to be done (either because
dirty_background_ratio is exceeded or because we need to start
flushing old inodes). If so, just do background write back.

This way, bdi_start_background_writeback() just needs to wake up the
flusher thread. It will do background writeback as soon as there is no
other work.

This is a preparatory patch for the next patch which stops background
writeback as soon as there is other work to do.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   61 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 46 insertions(+), 15 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-10-31 19:03:58.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-01 19:31:54.000000000 +0800
@@ -79,13 +79,9 @@ static inline struct backing_dev_info *i
 	return sb->s_bdi;
 }
 
-static void bdi_queue_work(struct backing_dev_info *bdi,
-		struct wb_writeback_work *work)
+/* Wakeup flusher thread or forker thread to fork it. Requires bdi->wb_lock. */
+static void _bdi_wakeup_flusher(struct backing_dev_info *bdi)
 {
-	trace_writeback_queue(bdi, work);
-
-	spin_lock_bh(&bdi->wb_lock);
-	list_add_tail(&work->list, &bdi->work_list);
 	if (bdi->wb.task) {
 		wake_up_process(bdi->wb.task);
 	} else {
@@ -93,15 +89,26 @@ static void bdi_queue_work(struct backin
 		 * The bdi thread isn't there, wake up the forker thread which
 		 * will create and run it.
 		 */
-		trace_writeback_nothread(bdi, work);
 		wake_up_process(default_backing_dev_info.wb.task);
 	}
+}
+
+static void bdi_queue_work(struct backing_dev_info *bdi,
+			   struct wb_writeback_work *work)
+{
+	trace_writeback_queue(bdi, work);
+
+	spin_lock_bh(&bdi->wb_lock);
+	list_add_tail(&work->list, &bdi->work_list);
+	if (!bdi->wb.task)
+		trace_writeback_nothread(bdi, work);
+	_bdi_wakeup_flusher(bdi);
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		bool range_cyclic, bool for_background)
+		      bool range_cyclic)
 {
 	struct wb_writeback_work *work;
 
@@ -121,7 +128,6 @@ __bdi_start_writeback(struct backing_dev
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
-	work->for_background = for_background;
 
 	bdi_queue_work(bdi, work);
 }
@@ -139,7 +145,7 @@ __bdi_start_writeback(struct backing_dev
  */
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
 {
-	__bdi_start_writeback(bdi, nr_pages, true, false);
+	__bdi_start_writeback(bdi, nr_pages, true);
 }
 
 /**
@@ -147,13 +153,20 @@ void bdi_start_writeback(struct backing_
  * @bdi: the backing device to write from
  *
  * Description:
- *   This does WB_SYNC_NONE background writeback. The IO is only
- *   started when this function returns, we make no guarentees on
- *   completion. Caller need not hold sb s_umount semaphore.
+ *   This makes sure WB_SYNC_NONE background writeback happens. When
+ *   this function returns, it is only guaranteed that for given BDI
+ *   some IO is happening if we are over background dirty threshold.
+ *   Caller need not hold sb s_umount semaphore.
  */
 void bdi_start_background_writeback(struct backing_dev_info *bdi)
 {
-	__bdi_start_writeback(bdi, LONG_MAX, true, true);
+	/*
+	 * We just wake up the flusher thread. It will perform background
+	 * writeback as soon as there is no other work to do.
+	 */
+	spin_lock_bh(&bdi->wb_lock);
+	_bdi_wakeup_flusher(bdi);
+	spin_unlock_bh(&bdi->wb_lock);
 }
 
 /*
@@ -724,6 +737,23 @@ get_next_work_item(struct backing_dev_in
 	return work;
 }
 
+static long wb_check_background_flush(struct bdi_writeback *wb)
+{
+	if (over_bground_thresh()) {
+
+		struct wb_writeback_work work = {
+			.nr_pages	= LONG_MAX,
+			.sync_mode	= WB_SYNC_NONE,
+			.for_background	= 1,
+			.range_cyclic	= 1,
+		};
+
+		return wb_writeback(wb, &work);
+	}
+
+	return 0;
+}
+
 static long wb_check_old_data_flush(struct bdi_writeback *wb)
 {
 	unsigned long expired;
@@ -795,6 +825,7 @@ long wb_do_writeback(struct bdi_writebac
 	 * Check for periodic writeback, kupdated() style
 	 */
 	wrote += wb_check_old_data_flush(wb);
+	wrote += wb_check_background_flush(wb);
 	clear_bit(BDI_writeback_running, &wb->bdi->state);
 
 	return wrote;
@@ -881,7 +912,7 @@ void wakeup_flusher_threads(long nr_page
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false, false);
+		__bdi_start_writeback(bdi, nr_pages, false);
 	}
 	rcu_read_unlock();
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
