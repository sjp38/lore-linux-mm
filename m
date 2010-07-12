Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3DF686B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 18:07:03 -0400 (EDT)
Date: Tue, 13 Jul 2010 08:06:54 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases
Message-ID: <20100712220654.GH25335@dastard>
References: <20100711020656.340075560@intel.com>
 <20100711021749.303817848@intel.com>
 <20100712020842.GC25335@dastard>
 <20100712155239.GC30222@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712155239.GC30222@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 12, 2010 at 11:52:39PM +0800, Wu Fengguang wrote:
> On Mon, Jul 12, 2010 at 10:08:42AM +0800, Dave Chinner wrote:
> > On Sun, Jul 11, 2010 at 10:07:02AM +0800, Wu Fengguang wrote:
> > > -			/*
> > > -			 * akpm: if the caller was the kupdate function we put
> > > -			 * this inode at the head of b_dirty so it gets first
> > > -			 * consideration.  Otherwise, move it to the tail, for
> > > -			 * the reasons described there.  I'm not really sure
> > > -			 * how much sense this makes.  Presumably I had a good
> > > -			 * reasons for doing it this way, and I'd rather not
> > > -			 * muck with it at present.
> > > -			 */
> > > -			if (wbc->for_kupdate) {
> > > +			inode->i_state |= I_DIRTY_PAGES;
> > > +			if (wbc->nr_to_write <= 0) {
> > >  				/*
> > > -				 * For the kupdate function we move the inode
> > > -				 * to b_more_io so it will get more writeout as
> > > -				 * soon as the queue becomes uncongested.
> > > +				 * slice used up: queue for next turn
> > >  				 */
> > > -				inode->i_state |= I_DIRTY_PAGES;
> > > -				if (wbc->nr_to_write <= 0) {
> > > -					/*
> > > -					 * slice used up: queue for next turn
> > > -					 */
> > > -					requeue_io(inode);
> > > -				} else {
> > > -					/*
> > > -					 * somehow blocked: retry later
> > > -					 */
> > > -					redirty_tail(inode);
> > > -				}
> > > +				requeue_io(inode);
> > >  			} else {
> > >  				/*
> > > -				 * Otherwise fully redirty the inode so that
> > > -				 * other inodes on this superblock will get some
> > > -				 * writeout.  Otherwise heavy writing to one
> > > -				 * file would indefinitely suspend writeout of
> > > -				 * all the other files.
> > > +				 * somehow blocked: retry later
> > >  				 */
> > > -				inode->i_state |= I_DIRTY_PAGES;
> > >  				redirty_tail(inode);
> > >  			}
> > 
> > This means that congestion will always trigger redirty_tail(). Is
> > that really what we want for that case?
> 
> This patch actually converts some redirty_tail() cases to use
> requeue_io(), so are reducing the use of redirty_tail(). Also
> recent kernels are blocked _inside_ get_request() on congestion
> instead of returning to writeback_single_inode() on congestion.
> So the "somehow blocked" comment for redirty_tail() no longer includes
> the congestion case.

Shouldn't some of this be in the comment explain why the tail is
redirtied rather than requeued?

> > Also, I'd prefer that the
> > comments remain somewhat more descriptive of the circumstances that
> > we are operating under. Comments like "retry later to avoid blocking
> > writeback of other inodes" is far, far better than "retry later"
> > because it has "why" component that explains the reason for the
> > logic. You may remember why, but I sure won't in a few months time....
> 
> Ah yes the comment is too simple. However the redirty_tail() is not to
> avoid blocking writeback of other inodes, but to avoid eating 100% CPU
> on busy retrying a dirty inode/page that cannot perform writeback for
> a while. (In theory redirty_tail() can still busy retry though, when
> there is only one single dirty inode.) So how about
> 
>         /*
>          * somehow blocked: avoid busy retrying
>          */

IMO, no better than "somehow blocked: retry later" because it
desont' include any of the explanation for the code you just gave
me.  The comment needs to tell us _why_ we are calling
redirty_tail, not what redirty_tail does. Perhaps something like:

	/*
	 * Writeback blocked by something other than congestion.
	 * Redirty the inode to avoid spinning on the CPU retrying
	 * writeback of the dirty page/inode that cannot be
	 * performed immediately. This allows writeback of other
	 * inodes until the blocking condition clears.
	 */

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
