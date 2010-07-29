From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/5] writeback: stop periodic/background work on seeing sync works
Date: Thu, 29 Jul 2010 19:51:44 +0800
Message-ID: <20100729121423.332557547@intel.com>
References: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS9D-0006U4-U5
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:40 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 254AD6B02A8
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:24 -0400 (EDT)
Content-Disposition: inline; filename=writeback-sync-pending.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

The periodic/background writeback can run forever. So when any
sync work is enqueued, increase bdi->sync_works to notify the
active non-sync works to exit. Non-sync works queued after sync
works won't be affected.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |   13 +++++++++++++
 include/linux/backing-dev.h |    6 ++++++
 mm/backing-dev.c            |    1 +
 3 files changed, 20 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-07-29 17:13:23.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-29 17:13:49.000000000 +0800
@@ -80,6 +80,8 @@ static void bdi_queue_work(struct backin
 
 	spin_lock(&bdi->wb_lock);
 	list_add_tail(&work->list, &bdi->work_list);
+	if (work->for_sync)
+		atomic_inc(&bdi->wb.sync_works);
 	spin_unlock(&bdi->wb_lock);
 
 	/*
@@ -633,6 +635,14 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		/*
+		 * background/periodic works can run forever, need to abort
+		 * on seeing any pending sync work, to prevent livelock it.
+		 */
+		if (atomic_read(&wb->sync_works) &&
+		    (work->for_background || work->for_kupdate))
+			break;
+
+		/*
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
@@ -765,6 +775,9 @@ long wb_do_writeback(struct bdi_writebac
 
 		wrote += wb_writeback(wb, work);
 
+		if (work->for_sync)
+			atomic_dec(&wb->sync_works);
+
 		/*
 		 * Notify the caller of completion if this is a synchronous
 		 * work item, otherwise just free it.
--- linux-next.orig/include/linux/backing-dev.h	2010-07-29 17:13:23.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-07-29 17:13:31.000000000 +0800
@@ -50,6 +50,12 @@ struct bdi_writeback {
 
 	unsigned long last_old_flush;		/* last old data flush */
 
+	/*
+	 * sync works queued, background works shall abort on seeing this,
+	 * to prevent livelocking the sync works
+	 */
+	atomic_t sync_works;
+
 	struct task_struct	*task;		/* writeback task */
 	struct list_head	b_dirty;	/* dirty inodes */
 	struct list_head	b_io;		/* parked for writeback */
--- linux-next.orig/mm/backing-dev.c	2010-07-29 17:13:23.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-07-29 17:13:31.000000000 +0800
@@ -257,6 +257,7 @@ static void bdi_wb_init(struct bdi_write
 
 	wb->bdi = bdi;
 	wb->last_old_flush = jiffies;
+	atomic_set(&wb->sync_works, 0);
 	INIT_LIST_HEAD(&wb->b_dirty);
 	INIT_LIST_HEAD(&wb->b_io);
 	INIT_LIST_HEAD(&wb->b_more_io);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
