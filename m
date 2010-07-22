From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/6] writeback: introduce writeback_control.inodes_written
Date: Thu, 22 Jul 2010 13:09:34 +0800
Message-ID: <20100722061823.196659592@intel.com>
References: <20100722050928.653312535@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Obp8A-0003fa-7P
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Jul 2010 08:19:42 +0200
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 539EF6B02A7
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 02:19:28 -0400 (EDT)
Content-Disposition: inline; filename=writeback-inodes_written.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Introduce writeback_control.inodes_written to count successful
->write_inode() calls.  A non-zero value means there are some
progress on writeback, in which case more writeback will be tried.

This prevents aborting a background writeback work prematually when
the current set of inodes for IO happen to be metadata-only dirty.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |    5 +++++
 include/linux/writeback.h |    1 +
 2 files changed, 6 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-07-22 13:07:54.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-22 13:07:58.000000000 +0800
@@ -379,6 +379,8 @@ writeback_single_inode(struct inode *ino
 		int err = write_inode(inode, wbc);
 		if (ret == 0)
 			ret = err;
+		if (!err)
+			wbc->inodes_written++;
 	}
 
 	spin_lock(&inode_lock);
@@ -628,6 +630,7 @@ static long wb_writeback(struct bdi_writ
 
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
+		wbc.inodes_written = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
 		if (work->sb)
@@ -650,6 +653,8 @@ static long wb_writeback(struct bdi_writ
 		 */
 		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
 			continue;
+		if (wbc.inodes_written)
+			continue;
 
 		/*
 		 * Nothing written and no more inodes for IO, bail
--- linux-next.orig/include/linux/writeback.h	2010-07-22 11:24:46.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-07-22 13:07:58.000000000 +0800
@@ -34,6 +34,7 @@ struct writeback_control {
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */
 	long pages_skipped;		/* Pages which were not written */
+	long inodes_written;		/* Number of inodes(metadata) synced */
 
 	/*
 	 * For a_ops->writepages(): is start or end are non-zero then this is


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
