From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases
Date: Sun, 11 Jul 2010 10:07:02 +0800
Message-ID: <20100711021749.303817848@intel.com>
References: <20100711020656.340075560@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-merge-kupdate-cases.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Unify the logic for kupdate and non-kupdate cases.
There won't be starvation because the inodes requeued into b_more_io
will later be spliced _after_ the remaining inodes in b_io, hence won't
stand in the way of other inodes in the next run.

It avoids unnecessary redirty_tail() calls, hence the update of
i_dirtied_when. The timestamp update is undesirable because it could
later delay the inode's periodic writeback, or exclude the inode from
the data integrity sync operation (which will check timestamp to avoid
extra work and livelock).

CC: Dave Chinner <david@fromorbit.com>
Cc: Martin Bligh <mbligh@google.com>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   39 ++++++---------------------------------
 1 file changed, 6 insertions(+), 33 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-11 09:13:32.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-11 09:13:36.000000000 +0800
@@ -373,45 +373,18 @@ writeback_single_inode(struct inode *ino
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
+				 * somehow blocked: retry later
 				 */
-				inode->i_state |= I_DIRTY_PAGES;
 				redirty_tail(inode);
 			}
 		} else if (inode->i_state & I_DIRTY) {


