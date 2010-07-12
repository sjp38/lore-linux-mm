Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E0D346B024D
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 11:52:48 -0400 (EDT)
Date: Mon, 12 Jul 2010 23:52:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases
Message-ID: <20100712155239.GC30222@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021749.303817848@intel.com>
 <20100712020842.GC25335@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712020842.GC25335@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 12, 2010 at 10:08:42AM +0800, Dave Chinner wrote:
> On Sun, Jul 11, 2010 at 10:07:02AM +0800, Wu Fengguang wrote:
> > Unify the logic for kupdate and non-kupdate cases.
> > There won't be starvation because the inodes requeued into b_more_io
> > will later be spliced _after_ the remaining inodes in b_io, hence won't
> > stand in the way of other inodes in the next run.
> > 
> > It avoids unnecessary redirty_tail() calls, hence the update of
> > i_dirtied_when. The timestamp update is undesirable because it could
> > later delay the inode's periodic writeback, or exclude the inode from
> > the data integrity sync operation (which will check timestamp to avoid
> > extra work and livelock).
> > 
> > CC: Dave Chinner <david@fromorbit.com>
> > Cc: Martin Bligh <mbligh@google.com>
> > Cc: Michael Rubin <mrubin@google.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c |   39 ++++++---------------------------------
> >  1 file changed, 6 insertions(+), 33 deletions(-)
> > 
> > --- linux-next.orig/fs/fs-writeback.c	2010-07-11 09:13:32.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c	2010-07-11 09:13:36.000000000 +0800
> > @@ -373,45 +373,18 @@ writeback_single_inode(struct inode *ino
> >  		if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
> >  			/*
> >  			 * We didn't write back all the pages.  nfs_writepages()
> > -			 * sometimes bales out without doing anything. Redirty
> > -			 * the inode; Move it from b_io onto b_more_io/b_dirty.
> > +			 * sometimes bales out without doing anything.
> >  			 */
> > -			/*
> > -			 * akpm: if the caller was the kupdate function we put
> > -			 * this inode at the head of b_dirty so it gets first
> > -			 * consideration.  Otherwise, move it to the tail, for
> > -			 * the reasons described there.  I'm not really sure
> > -			 * how much sense this makes.  Presumably I had a good
> > -			 * reasons for doing it this way, and I'd rather not
> > -			 * muck with it at present.
> > -			 */
> > -			if (wbc->for_kupdate) {
> > +			inode->i_state |= I_DIRTY_PAGES;
> > +			if (wbc->nr_to_write <= 0) {
> >  				/*
> > -				 * For the kupdate function we move the inode
> > -				 * to b_more_io so it will get more writeout as
> > -				 * soon as the queue becomes uncongested.
> > +				 * slice used up: queue for next turn
> >  				 */
> > -				inode->i_state |= I_DIRTY_PAGES;
> > -				if (wbc->nr_to_write <= 0) {
> > -					/*
> > -					 * slice used up: queue for next turn
> > -					 */
> > -					requeue_io(inode);
> > -				} else {
> > -					/*
> > -					 * somehow blocked: retry later
> > -					 */
> > -					redirty_tail(inode);
> > -				}
> > +				requeue_io(inode);
> >  			} else {
> >  				/*
> > -				 * Otherwise fully redirty the inode so that
> > -				 * other inodes on this superblock will get some
> > -				 * writeout.  Otherwise heavy writing to one
> > -				 * file would indefinitely suspend writeout of
> > -				 * all the other files.
> > +				 * somehow blocked: retry later
> >  				 */
> > -				inode->i_state |= I_DIRTY_PAGES;
> >  				redirty_tail(inode);
> >  			}
> 
> This means that congestion will always trigger redirty_tail(). Is
> that really what we want for that case?

This patch actually converts some redirty_tail() cases to use
requeue_io(), so are reducing the use of redirty_tail(). Also
recent kernels are blocked _inside_ get_request() on congestion
instead of returning to writeback_single_inode() on congestion.
So the "somehow blocked" comment for redirty_tail() no longer includes
the congestion case.

> Also, I'd prefer that the
> comments remain somewhat more descriptive of the circumstances that
> we are operating under. Comments like "retry later to avoid blocking
> writeback of other inodes" is far, far better than "retry later"
> because it has "why" component that explains the reason for the
> logic. You may remember why, but I sure won't in a few months time....

Ah yes the comment is too simple. However the redirty_tail() is not to
avoid blocking writeback of other inodes, but to avoid eating 100% CPU
on busy retrying a dirty inode/page that cannot perform writeback for
a while. (In theory redirty_tail() can still busy retry though, when
there is only one single dirty inode.) So how about

        /*
         * somehow blocked: avoid busy retrying
         */

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
