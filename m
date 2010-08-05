From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/13] writeback: merge for_kupdate and !for_kupdate cases
Date: Fri, 06 Aug 2010 00:10:57 +0800
Message-ID: <20100805162433.536198393@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3Ju-0002zj-Ur
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:27 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 56F9F6B02AC
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:38 -0400 (EDT)
Content-Disposition: inline; filename=writeback-merge-kupdate-cases.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Unify the logic for kupdate and non-kupdate cases.
There won't be starvation because the inodes requeued into b_more_io
will later be spliced _after_ the remaining inodes in b_io, hence won't
stand in the way of other inodes in the next run.

It avoids unnecessary redirty_tail() calls, hence the update of
i_dirtied_when. The timestamp update is undesirable because it could
later delay the inode's periodic writeback, or may exclude the inode
from the data integrity sync operation (which checks timestamp to
avoid extra work and livelock).

===
How the redirty_tail() comes about:

It was a long story.. This redirty_tail() was introduced with
wbc.more_io.  The initial patch for more_io actually does not have the
redirty_tail(), and when it's merged, several 100% iowait bug reports
arised:

reiserfs:
        http://lkml.org/lkml/2007/10/23/93

jfs:    
        commit 29a424f28390752a4ca2349633aaacc6be494db5
        JFS: clear PAGECACHE_TAG_DIRTY for no-write pages
        
ext2:   
        http://www.spinics.net/linux/lists/linux-ext4/msg04762.html

They are all old bugs hidden in various filesystems that become
"visible" with the more_io patch. At the time, the ext2 bug is thought
to be "trivial", so not fixed. Instead the following updated more_io
patch with redirty_tail() is merged: 

	http://www.spinics.net/linux/lists/linux-ext4/msg04507.html

This will in general prevent 100% on ext2 and possibly other unknown FS bugs.

CC: Dave Chinner <david@fromorbit.com>
Cc: Martin Bligh <mbligh@google.com>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   43 ++++++++++---------------------------------
 1 file changed, 10 insertions(+), 33 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-08-05 23:21:43.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-08-05 23:22:02.000000000 +0800
@@ -378,45 +378,22 @@ writeback_single_inode(struct inode *ino
 		if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
 			/*
 			 * We didn't write back all the pages.  nfs_writepages()
-			 * sometimes bales out without doing anything. Redirty
-			 * the inode; Move it from b_io onto b_more_io/b_dirty.
+			 * sometimes bales out without doing anything.
 			 */
-			/*
-			 * akpm: if the caller was the kupdate function we put
-			 * this inode at the head of b_dirty so it gets first
-			 * consideration.  Otherwise, move it to the tail, for
-			 * the reasons described there.  I'm not really sure
-			 * how much sense this makes.  Presumably I had a good
-			 * reasons for doing it this way, and I'd rather not
-			 * muck with it at present.
-			 */
-			if (wbc->for_kupdate) {
+			inode->i_state |= I_DIRTY_PAGES;
+			if (wbc->nr_to_write <= 0) {
 				/*
-				 * For the kupdate function we move the inode
-				 * to b_more_io so it will get more writeout as
-				 * soon as the queue becomes uncongested.
+				 * slice used up: queue for next turn
 				 */
-				inode->i_state |= I_DIRTY_PAGES;
-				if (wbc->nr_to_write <= 0) {
-					/*
-					 * slice used up: queue for next turn
-					 */
-					requeue_io(inode);
-				} else {
-					/*
-					 * somehow blocked: retry later
-					 */
-					redirty_tail(inode);
-				}
+				requeue_io(inode);
 			} else {
 				/*
-				 * Otherwise fully redirty the inode so that
-				 * other inodes on this superblock will get some
-				 * writeout.  Otherwise heavy writing to one
-				 * file would indefinitely suspend writeout of
-				 * all the other files.
+				 * Writeback blocked by something other than
+				 * congestion. Delay the inode for some time to
+				 * avoid spinning on the CPU (100% iowait)
+				 * retrying writeback of the dirty page/inode
+				 * that cannot be performed immediately.
 				 */
-				inode->i_state |= I_DIRTY_PAGES;
 				redirty_tail(inode);
 			}
 		} else if (inode->i_state & I_DIRTY) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
