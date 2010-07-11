From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/6] writeback: dont redirty tail an inode with dirty pages
Date: Sun, 11 Jul 2010 10:07:00 +0800
Message-ID: <20100711021749.021449821@intel.com>
References: <20100711020656.340075560@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-xfs-fast-redirty.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This avoids delaying writeback for an expired (XFS) inode with lots of
dirty pages, but no active dirtier at the moment. Previously we only do
that for the kupdate case.

CC: Dave Chinner <david@fromorbit.com>
CC: Christoph Hellwig <hch@infradead.org>
Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-11 08:53:44.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-11 08:57:35.000000000 +0800
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
@@ -423,6 +411,12 @@ select_queue:
 				inode->i_state |= I_DIRTY_PAGES;
 				redirty_tail(inode);
 			}
+		} else if (inode->i_state & I_DIRTY) {
+			/*
+			 * At least XFS will redirty the inode during the
+			 * writeback (delalloc) and on io completion (isize).
+			 */
+			redirty_tail(inode);
 		} else if (atomic_read(&inode->i_count)) {
 			/*
 			 * The inode is clean, inuse
