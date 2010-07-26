Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B8846006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 08:29:52 -0400 (EDT)
Date: Mon, 26 Jul 2010 20:29:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20100726122932.GA11947@localhost>
References: <20100722050928.653312535@intel.com>
 <20100722061822.906037624@intel.com>
 <20100723181521.GC20540@quack.suse.cz>
 <20100726115153.GF6284@localhost>
 <20100726121258.GE3280@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726121258.GE3280@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 08:12:59PM +0800, Jan Kara wrote:
> On Mon 26-07-10 19:51:53, Wu Fengguang wrote:
> > On Sat, Jul 24, 2010 at 02:15:21AM +0800, Jan Kara wrote:
> > > On Thu 22-07-10 13:09:32, Wu Fengguang wrote:
> > > > A background flush work may run for ever. So it's reasonable for it to
> > > > mimic the kupdate behavior of syncing old/expired inodes first.
> > > > 
> > > > The policy is
> > > > - enqueue all newly expired inodes at each queue_io() time
> > > > - retry with halfed expire interval until get some inodes to sync
> > >   Hmm, this logic looks a bit arbitrary to me. What I actually don't like
> > > very much about this that when there aren't inodes older than say 2
> > > seconds, you'll end up queueing just inodes between 2s and 1s. So I'd
> > > rather just queue inodes older than the limit and if there are none, just
> > > queue all other dirty inodes.
> > 
> > You are proposing
> > 
> > -				expire_interval >>= 1;
> > +				expire_interval = 0;
> > 
> > IMO this does not really simplify code or concept. If we can get the
> > "smoother" behavior in original patch without extra cost, why not? 
>   I agree there's no substantial code simplification. But I see a
> substantial "behavior" simplification (just two sweeps instead of 10 or
> so). But I don't really insist on the two sweeps, it's just that I don't
> see a justification for the exponencial back off here... I mean what's the
> point if the interval we queue gets really small? Why not just use
> expire_interval/2 as a step if you want a smoother behavior?

Yeah, the _non-linear_ backoff is not good. You have a point about the
behavior simplification, and it does remove one line. So I'll follow
your way.

Thanks,
Fengguang
---
Subject: writeback: sync expired inodes first in background writeback
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Wed Jul 21 20:11:53 CST 2010

A background flush work may run for ever. So it's reasonable for it to
mimic the kupdate behavior of syncing old/expired inodes first.

The policy is
- enqueue all newly expired inodes at each queue_io() time
- enqueue all dirty inodes if there are no more expired inodes to sync

This will help reduce the number of dirty pages encountered by page
reclaim, eg. the pageout() calls. Normally older inodes contain older
dirty pages, which are more close to the end of the LRU lists. So
syncing older inodes first helps reducing the dirty pages reached by
the page reclaim code.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-26 20:19:01.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-26 20:25:01.000000000 +0800
@@ -217,14 +217,14 @@ static void move_expired_inodes(struct l
 				struct writeback_control *wbc)
 {
 	unsigned long expire_interval = 0;
-	unsigned long older_than_this;
+	unsigned long older_than_this = 0; /* reset to kill gcc warning */
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
 
-	if (wbc->for_kupdate) {
+	if (wbc->for_kupdate || wbc->for_background) {
 		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
 		older_than_this = jiffies - expire_interval;
 	}
@@ -232,8 +232,14 @@ static void move_expired_inodes(struct l
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
 		if (expire_interval &&
-		    inode_dirtied_after(inode, older_than_this))
-			break;
+		    inode_dirtied_after(inode, older_than_this)) {
+			if (wbc->for_background &&
+			    list_empty(dispatch_queue) && list_empty(&tmp)) {
+				expire_interval = 0;
+				continue;
+			} else
+				break;
+		}
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
 		sb = inode->i_sb;
@@ -521,7 +527,8 @@ void writeback_inodes_wb(struct bdi_writ
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -550,7 +557,7 @@ static void __writeback_inodes_sb(struct
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
