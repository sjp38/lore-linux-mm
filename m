Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B255790010B
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 12:15:13 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v8 11/12] writeback: make background writeback cgroup aware
Date: Fri,  3 Jun 2011 09:12:17 -0700
Message-Id: <1307117538-14317-12-git-send-email-gthelen@google.com>
In-Reply-To: <1307117538-14317-1-git-send-email-gthelen@google.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

When the system is under background dirty memory threshold but a cgroup
is over its background dirty memory threshold, then only writeback
inodes associated with the over-limit cgroup(s).

In addition to checking if the system dirty memory usage is over the
system background threshold, over_bground_thresh() also checks if any
cgroups are over their respective background dirty memory thresholds.
The writeback_control.for_cgroup field is set to distinguish between a
system and memcg overage.

If performing cgroup writeback, move_expired_inodes() skips inodes that
do not contribute dirty pages to the cgroup being written back.

After writing some pages, wb_writeback() will call
mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v7:
- over_bground_thresh() now sets shared_inodes=1.  In -v7 per memcg
  background writeback did not, so it did not write pages of shared
  inodes in background writeback.  In the (potentially common) case
  where the system dirty memory usage is below the system background
  dirty threshold but at least one cgroup is over its background dirty
  limit, then per memcg background writeback is queued for any
  over-background-threshold cgroups.  Background writeback should be
  allowed to writeback shared inodes.  The hope is that writing such
  inodes has good chance of cleaning the inodes so they can transition
  from shared to non-shared.  Such a transition is good because then the
  inode will remain unshared until it is written by multiple cgroup.
  Non-shared inodes offer better isolation.

 fs/fs-writeback.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0174fcf..c0bfe62 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -256,14 +256,17 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *tmp_inode;
 	int do_sb_sort = 0;
 
-	while (!list_empty(delaying_queue)) {
-		inode = wb_inode(delaying_queue->prev);
+	list_for_each_entry_safe_reverse(inode, tmp_inode, delaying_queue,
+					 i_wb_list) {
 		if (wbc->older_than_this &&
 		    inode_dirtied_after(inode, *wbc->older_than_this))
 			break;
+		if (wbc->for_cgroup &&
+		    !should_writeback_mem_cgroup_inode(inode, wbc))
+			continue;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
 		sb = inode->i_sb;
@@ -614,14 +617,22 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
  */
 #define MAX_WRITEBACK_PAGES     1024
 
-static inline bool over_bground_thresh(void)
+static inline bool over_bground_thresh(struct bdi_writeback *wb,
+				       struct writeback_control *wbc)
 {
 	unsigned long background_thresh, dirty_thresh;
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh) {
+		wbc->for_cgroup = 0;
+		return true;
+	}
+
+	wbc->for_cgroup = 1;
+	wbc->shared_inodes = 1;
+	return mem_cgroups_over_bground_dirty_thresh();
 }
 
 /*
@@ -700,7 +711,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh())
+		if (work->for_background && !over_bground_thresh(wb, &wbc))
 			break;
 
 		if (work->for_kupdate || work->for_background) {
@@ -729,6 +740,9 @@ retry:
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
 
+		if (write_chunk - wbc.nr_to_write > 0)
+			mem_cgroup_writeback_done();
+
 		/*
 		 * Did we write something? Try for more
 		 *
@@ -809,7 +823,9 @@ static unsigned long get_nr_dirty_pages(void)
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh()) {
+	struct writeback_control wbc;
+
+	if (over_bground_thresh(wb, &wbc)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
