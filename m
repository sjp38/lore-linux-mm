From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/13] writeback: make nr_to_write a per-file limit
Date: Wed, 17 Nov 2010 12:27:33 +0800
Message-ID: <20101117042850.839706840@intel.com>
References: <20101117042720.033773013@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PIZga-0001o2-QI
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Nov 2010 05:31:57 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F4286B0108
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:31:55 -0500 (EST)
Content-Disposition: inline; filename=writeback-single-file-limit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This ensures full 4MB (or larger) writeback size for large dirty files.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |   11 +++++++++++
 include/linux/writeback.h |    1 +
 2 files changed, 12 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-11-15 19:52:39.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-15 21:31:50.000000000 +0800
@@ -330,6 +330,8 @@ static int
 writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct address_space *mapping = inode->i_mapping;
+	long per_file_limit = wbc->per_file_limit;
+	long nr_to_write;
 	unsigned dirty;
 	int ret;
 
@@ -365,8 +367,16 @@ writeback_single_inode(struct inode *ino
 	inode->i_state &= ~I_DIRTY_PAGES;
 	spin_unlock(&inode_lock);
 
+	if (per_file_limit) {
+		nr_to_write = wbc->nr_to_write;
+		wbc->nr_to_write = per_file_limit;
+	}
+
 	ret = do_writepages(mapping, wbc);
 
+	if (per_file_limit)
+		wbc->nr_to_write += nr_to_write - per_file_limit;
+
 	/*
 	 * Make sure to wait on the data before writing out the metadata.
 	 * This is important for filesystems that modify metadata on data
@@ -698,6 +708,7 @@ static long wb_writeback(struct bdi_writ
 
 		wbc.more_io = 0;
 		wbc.nr_to_write = write_chunk;
+		wbc.per_file_limit = write_chunk;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
--- linux-next.orig/include/linux/writeback.h	2010-11-15 19:52:39.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-11-15 21:31:50.000000000 +0800
@@ -43,6 +43,7 @@ struct writeback_control {
 					   extra jobs and livelock */
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */
+	long per_file_limit;		/* Write this many pages for one file */
 	long pages_skipped;		/* Pages which were not written */
 
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
