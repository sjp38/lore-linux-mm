Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9217590008B
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:10:22 -0400 (EDT)
Message-Id: <20110419030532.392203618@intel.com>
Date: Tue, 19 Apr 2011 11:00:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/6] writeback: the kupdate expire timestamp should be a moving target
References: <20110419030003.108796967@intel.com>
Content-Disposition: inline; filename=writeback-moving-target-dirty-expired.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Dynamically compute the dirty expire timestamp at queue_io() time.

writeback_control.older_than_this used to be determined at entrance to
the kupdate writeback work. This _static_ timestamp may go stale if the
kupdate work runs on and on. The flusher may then stuck with some old
busy inodes, never considering newly expired inodes thereafter.

This has two possible problems:

- It is unfair for a large dirty inode to delay (for a long time) the
  writeback of small dirty inodes.

- As time goes by, the large and busy dirty inode may contain only
  _freshly_ dirtied pages. Ignoring newly expired dirty inodes risks
  delaying the expired dirty pages to the end of LRU lists, triggering
  the evil pageout(). Nevertheless this patch merely addresses part
  of the problem.

Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Itaru Kitayama <kitayama@cl.bb4u.ne.jp>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-19 10:18:28.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-19 10:18:29.000000000 +0800
@@ -254,16 +254,23 @@ static void move_expired_inodes(struct l
 				struct list_head *dispatch_queue,
 				struct writeback_control *wbc)
 {
+	unsigned long expire_interval = 0;
+	unsigned long older_than_this;
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
 
+	if (wbc->for_kupdate) {
+		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
+		older_than_this = jiffies - expire_interval;
+	}
+
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
-		if (wbc->older_than_this &&
-		    inode_dirtied_after(inode, *wbc->older_than_this))
+		if (expire_interval &&
+		    inode_dirtied_after(inode, older_than_this))
 			break;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
