Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C6576B02A5
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 11:33:33 -0400 (EDT)
Date: Mon, 12 Jul 2010 23:31:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/6] writeback: dont redirty tail an inode with dirty
 pages
Message-ID: <20100712153127.GB30222@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021749.021449821@intel.com>
 <20100712020109.GB25335@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712020109.GB25335@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > +		} else if (inode->i_state & I_DIRTY) {
> > +			/*
> > +			 * At least XFS will redirty the inode during the
> > +			 * writeback (delalloc) and on io completion (isize).
> > +			 */
> > +			redirty_tail(inode);
> 
> I'd drop the mention of XFS here - any filesystem that does delayed
> allocation or unwritten extent conversion after Io completion will
> cause this. Perhaps make the comment:
> 
> 	/*
> 	 * Filesystems can dirty the inode during writeback
> 	 * operations, such as delayed allocation during submission
> 	 * or metadata updates after data IO completion.
> 	 */

Thanks, comments updated accordingly.

---
writeback: don't redirty tail an inode with dirty pages

This avoids delaying writeback for an expired (XFS) inode with lots of
dirty pages, but no active dirtier at the moment. Previously we only do
that for the kupdate case.

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
