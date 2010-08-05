From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/13] writeback: dont redirty tail an inode with dirty pages
Date: Fri, 06 Aug 2010 00:10:55 +0800
Message-ID: <20100805162433.245060719@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3KI-0003Kf-S4
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:51 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 359576B02BA
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:59 -0400 (EDT)
Content-Disposition: inline; filename=writeback-xfs-fast-redirty.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This extends commit b3af9468ae (writeback: don't delay inodes redirtied
by a fast dirtier) to the !kupdate case.

It also simplifies logic. Note that the I_DIRTY_PAGES test/handling is
merged into the PAGECACHE_TAG_DIRTY case.  I_DIRTY_PAGES (at the line
removed by this patch) means there are _new_ pages get dirtied during
writeback, while PAGECACHE_TAG_DIRTY means there are dirty pages. In
this sense, the PAGECACHE_TAG_DIRTY test covers the I_DIRTY_PAGES case.

In *_set_page_dirty*(), PAGECACHE_TAG_DIRTY is set racelessly, while
I_DIRTY_PAGES might be set on the inode for a page just truncated.  It
has no real impact on this patch -- it's actually slightly better now.

afs_fsync() always set I_DIRTY_PAGES after calling afs_writepages(),
maybe to keep the inode in the dirty list. That's a different code path,
so won't impact the requeue-vs-redirty timing here permenantly.

CC: David Howells <dhowells@redhat.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Christoph Hellwig <hch@infradead.org>
Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-11 09:13:30.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-12 23:26:06.000000000 +0800
@@ -367,18 +367,7 @@ writeback_single_inode(struct inode *ino
 	spin_lock(&inode_lock);
 	inode->i_state &= ~I_SYNC;
 	if (!(inode->i_state & I_FREEING)) {
-		if ((inode->i_state & I_DIRTY_PAGES) && wbc->for_kupdate) {
-			/*
-			 * More pages get dirtied by a fast dirtier.
-			 */
-			goto select_queue;
-		} else if (inode->i_state & I_DIRTY) {
-			/*
-			 * At least XFS will redirty the inode during the
-			 * writeback (delalloc) and on io completion (isize).
-			 */
-			redirty_tail(inode);
-		} else if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
+		if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
 			/*
 			 * We didn't write back all the pages.  nfs_writepages()
 			 * sometimes bales out without doing anything. Redirty
@@ -400,7 +389,6 @@ writeback_single_inode(struct inode *ino
 				 * soon as the queue becomes uncongested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-select_queue:
 				if (wbc->nr_to_write <= 0) {
 					/*
 					 * slice used up: queue for next turn
@@ -423,6 +411,14 @@ select_queue:
 				inode->i_state |= I_DIRTY_PAGES;
 				redirty_tail(inode);
 			}
+		} else if (inode->i_state & I_DIRTY) {
+			/*
+			 * Filesystems can dirty the inode during writeback
+			 * operations, such as delayed allocation during
+			 * submission or metadata updates after data IO
+			 * completion.
+			 */
+			redirty_tail(inode);
 		} else if (atomic_read(&inode->i_count)) {
 			/*
 			 * The inode is clean, inuse


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
