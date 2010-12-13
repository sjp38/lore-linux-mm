From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 34/47] writeback: trace writeback_single_inode()
Date: Mon, 13 Dec 2010 14:43:23 +0800
Message-ID: <20101213064841.182401884@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Ga-0006Hh-Vy
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:52:13 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 54D696B00C1
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:51 -0500 (EST)
Content-Disposition: inline; filename=writeback-trace-writeback_single_inode.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

It is valuable to know how the inodes are iterated and their IO size.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |   12 +++---
 include/trace/events/writeback.h |   52 +++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-12-09 22:15:49.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-09 22:15:50.000000000 +0800
@@ -331,7 +331,7 @@ writeback_single_inode(struct inode *ino
 {
 	struct address_space *mapping = inode->i_mapping;
 	long per_file_limit = wbc->per_file_limit;
-	long uninitialized_var(nr_to_write);
+	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
 
@@ -351,7 +351,8 @@ writeback_single_inode(struct inode *ino
 		 */
 		if (wbc->sync_mode != WB_SYNC_ALL) {
 			requeue_io(inode);
-			return 0;
+			ret = 0;
+			goto out;
 		}
 
 		/*
@@ -367,10 +368,8 @@ writeback_single_inode(struct inode *ino
 	inode->i_state &= ~I_DIRTY_PAGES;
 	spin_unlock(&inode_lock);
 
-	if (per_file_limit) {
-		nr_to_write = wbc->nr_to_write;
+	if (per_file_limit)
 		wbc->nr_to_write = per_file_limit;
-	}
 
 	ret = do_writepages(mapping, wbc);
 
@@ -446,6 +445,9 @@ writeback_single_inode(struct inode *ino
 		}
 	}
 	inode_sync_complete(inode);
+out:
+	trace_writeback_single_inode(inode, wbc,
+				     nr_to_write - wbc->nr_to_write);
 	return ret;
 }
 
--- linux-next.orig/include/trace/events/writeback.h	2010-12-09 22:15:49.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-12-09 22:21:41.000000000 +0800
@@ -10,6 +10,19 @@
 
 struct wb_writeback_work;
 
+#define show_inode_state(state)					\
+	__print_flags(state, "|",				\
+		{I_DIRTY_SYNC,		"I_DIRTY_SYNC"},	\
+		{I_DIRTY_DATASYNC,	"I_DIRTY_DATASYNC"},	\
+		{I_DIRTY_PAGES,		"I_DIRTY_PAGES"},	\
+		{I_NEW,			"I_NEW"},		\
+		{I_WILL_FREE,		"I_WILL_FREE"},		\
+		{I_FREEING,		"I_FREEING"},		\
+		{I_CLEAR,		"I_CLEAR"},		\
+		{I_SYNC,		"I_SYNC"},		\
+		{I_REFERENCED,		"I_REFERENCED"}		\
+		)
+
 DECLARE_EVENT_CLASS(writeback_work_class,
 	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work),
 	TP_ARGS(bdi, work),
@@ -149,6 +162,45 @@ DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(writeback_single_inode,
+
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 unsigned long wrote
+	),
+
+	TP_ARGS(inode, wbc, wrote),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, ino)
+		__field(unsigned long, state)
+		__field(unsigned long, age)
+		__field(unsigned long, wrote)
+		__field(long, nr_to_write)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->state		= inode->i_state;
+		__entry->age		= (jiffies - inode->dirtied_when) *
+								1000 / HZ;
+		__entry->wrote		= wrote;
+		__entry->nr_to_write	= wbc->nr_to_write;
+	),
+
+	TP_printk("bdi %s: ino=%lu state=%s age=%lu wrote=%lu to_write=%ld",
+		  __entry->name,
+		  __entry->ino,
+		  show_inode_state(__entry->state),
+		  __entry->age,
+		  __entry->wrote,
+		  __entry->nr_to_write
+	)
+);
+
 TRACE_EVENT(balance_dirty_state,
 
 	TP_PROTO(struct address_space *mapping,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
