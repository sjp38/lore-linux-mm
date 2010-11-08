Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 587166B00A6
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 18:23:45 -0500 (EST)
Date: Tue, 9 Nov 2010 07:23:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/5] writeback livelock fixes
Message-ID: <20101108232341.GA11382@localhost>
References: <20101108230916.826791396@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20101108230916.826791396@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 09, 2010 at 07:09:16AM +0800, Wu, Fengguang wrote:
> Andrew,
> 
> Here are the two writeback livelock fixes (patch 3, 4) from Jan Kara.
> The series starts with a preparation patch and carries two more debugging
> patches.

Jan: for your convenience, attached is the combined patch for linux-next.

Thanks,
Fengguang

--ibTvN161/egqYuK8
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="wb-livelock-jan.patch"

--- linux-next.orig/fs/fs-writeback.c	2010-11-06 23:55:25.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-07 22:01:15.000000000 +0800
@@ -84,13 +84,9 @@ static inline struct inode *wb_inode(str
 	return list_entry(head, struct inode, i_wb_list);
 }
 
-static void bdi_queue_work(struct backing_dev_info *bdi,
-		struct wb_writeback_work *work)
+/* Wakeup flusher thread or forker thread to fork it. Requires bdi->wb_lock. */
+static void bdi_wakeup_flusher(struct backing_dev_info *bdi)
 {
-	trace_writeback_queue(bdi, work);
-
-	spin_lock_bh(&bdi->wb_lock);
-	list_add_tail(&work->list, &bdi->work_list);
 	if (bdi->wb.task) {
 		wake_up_process(bdi->wb.task);
 	} else {
@@ -98,15 +94,26 @@ static void bdi_queue_work(struct backin
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
+	bdi_wakeup_flusher(bdi);
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
 static void
 __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
-		bool range_cyclic, bool for_background)
+		      bool range_cyclic)
 {
 	struct wb_writeback_work *work;
 
@@ -126,7 +133,6 @@ __bdi_start_writeback(struct backing_dev
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
-	work->for_background = for_background;
 
 	bdi_queue_work(bdi, work);
 }
@@ -144,7 +150,7 @@ __bdi_start_writeback(struct backing_dev
  */
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
 {
-	__bdi_start_writeback(bdi, nr_pages, true, false);
+	__bdi_start_writeback(bdi, nr_pages, true);
 }
 
 /**
@@ -152,13 +158,21 @@ void bdi_start_writeback(struct backing_
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
+	trace_writeback_wake_background(bdi);
+	spin_lock_bh(&bdi->wb_lock);
+	bdi_wakeup_flusher(bdi);
+	spin_unlock_bh(&bdi->wb_lock);
 }
 
 /*
@@ -513,6 +527,7 @@ static int writeback_sb_inodes(struct su
 			 * buffers.  Skip this inode for now.
 			 */
 			redirty_tail(inode);
+			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
 		}
 		spin_unlock(&inode_lock);
 		iput(inode);
@@ -616,6 +631,7 @@ static long wb_writeback(struct bdi_writ
 	};
 	unsigned long oldest_jif;
 	long wrote = 0;
+	long write_chunk;
 	struct inode *inode;
 
 	if (wbc.for_kupdate) {
@@ -628,6 +644,24 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
+	/*
+	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
+	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
+	 * here avoids calling into writeback_inodes_wb() more than once.
+	 *
+	 * The intended call sequence for WB_SYNC_ALL writeback is:
+	 *
+	 *      wb_writeback()
+	 *          writeback_inodes_wb()       <== called only once
+	 *              write_cache_pages()     <== called once for each inode
+	 *                   (quickly) tag currently dirty pages
+	 *                   (maybe slowly) sync all tagged pages
+	 */
+	if (wbc.sync_mode == WB_SYNC_NONE)
+		write_chunk = MAX_WRITEBACK_PAGES;
+	else
+		write_chunk = LONG_MAX;
+
 	wbc.wb_start = jiffies; /* livelock avoidance */
 	for (;;) {
 		/*
@@ -637,6 +671,15 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		/*
+		 * Background writeout and kupdate-style writeback are
+		 * easily livelockable. Stop them if there is other work
+		 * to do so that e.g. sync can proceed.
+		 */
+		if ((work->for_background || work->for_kupdate) &&
+		    !list_empty(&wb->bdi->work_list))
+			break;
+
+		/*
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
@@ -644,7 +687,7 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
@@ -654,8 +697,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
-		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
-		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		work->nr_pages -= write_chunk - wbc.nr_to_write;
+		wrote += write_chunk - wbc.nr_to_write;
 
 		/*
 		 * If we consumed everything, see if we have more
@@ -670,7 +713,7 @@ static long wb_writeback(struct bdi_writ
 		/*
 		 * Did we write something? Try for more
 		 */
-		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
+		if (wbc.nr_to_write < write_chunk)
 			continue;
 		/*
 		 * Nothing written. Wait for some inode to
@@ -707,6 +750,23 @@ get_next_work_item(struct backing_dev_in
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
@@ -782,6 +842,7 @@ long wb_do_writeback(struct bdi_writebac
 	 * Check for periodic writeback, kupdated() style
 	 */
 	wrote += wb_check_old_data_flush(wb);
+	wrote += wb_check_background_flush(wb);
 	clear_bit(BDI_writeback_running, &wb->bdi->state);
 
 	return wrote;
@@ -868,7 +929,7 @@ void wakeup_flusher_threads(long nr_page
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-		__bdi_start_writeback(bdi, nr_pages, false, false);
+		__bdi_start_writeback(bdi, nr_pages, false);
 	}
 	rcu_read_unlock();
 }
--- linux-next.orig/include/trace/events/writeback.h	2010-11-07 21:54:19.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-11-07 21:56:42.000000000 +0800
@@ -81,6 +81,7 @@ DEFINE_EVENT(writeback_class, name, \
 	TP_ARGS(bdi))
 
 DEFINE_WRITEBACK_EVENT(writeback_nowork);
+DEFINE_WRITEBACK_EVENT(writeback_wake_background);
 DEFINE_WRITEBACK_EVENT(writeback_wake_thread);
 DEFINE_WRITEBACK_EVENT(writeback_wake_forker_thread);
 DEFINE_WRITEBACK_EVENT(writeback_bdi_register);

--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
