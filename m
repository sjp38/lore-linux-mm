Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB5686B0163
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:08:19 -0400 (EDT)
Message-Id: <20100913130149.849935145@intel.com>
Date: Mon, 13 Sep 2010 20:31:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/4] writeback: integrated background work
References: <20100913123110.372291929@intel.com>
Content-Disposition: inline; filename=writeback-integrated-background-work.patch
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Check background work whenever the flusher thread wakes up.  The page
reclaim code may lower the soft dirty limit immediately before sending
some work to the flusher thread.

This is also the prerequisite of next patch.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-09-13 19:41:21.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-13 19:49:11.000000000 +0800
@@ -716,6 +716,23 @@ get_next_work_item(struct backing_dev_in
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
@@ -787,6 +804,7 @@ long wb_do_writeback(struct bdi_writebac
 	 * Check for periodic writeback, kupdated() style
 	 */
 	wrote += wb_check_old_data_flush(wb);
+	wrote += wb_check_background_flush(wb);
 	clear_bit(BDI_writeback_running, &wb->bdi->state);
 
 	return wrote;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
