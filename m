Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3D8916B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 18:38:09 -0400 (EDT)
Date: Fri, 6 Aug 2010 06:39:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/13] writeback: try more writeback as long as
 something was written
Message-ID: <20100805223929.GC5586@localhost>
References: <20100805161051.501816677@intel.com>
 <20100805162434.385571675@intel.com>
 <20100805170016.GE3535@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805170016.GE3535@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 06, 2010 at 01:00:16AM +0800, Jan Kara wrote:
> On Fri 06-08-10 00:11:03, Wu Fengguang wrote:
> > writeback_inodes_wb()/__writeback_inodes_sb() are not aggressive in that
> > they only populate b_io when necessary at entrance time. When the queued
> > set of inodes are all synced, they just return, possibly with
> > wbc.nr_to_write > 0.
> > 
> > For kupdate and background writeback, there may be more eligible inodes
> > sitting in b_dirty when the current set of b_io inodes are completed. So
> > it is necessary to try another round of writeback as long as we made some
> > progress in this round. When there are no more eligible inodes, no more
> > inodes will be enqueued in queue_io(), hence nothing could/will be
> > synced and we may safely bail.
>   This looks like a sane thing to do. Just one comment below...
>  
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c |   19 +++++++++++--------
> >  1 file changed, 11 insertions(+), 8 deletions(-)
> > 
> > --- linux-next.orig/fs/fs-writeback.c	2010-08-05 23:30:27.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c	2010-08-05 23:30:45.000000000 +0800
> > @@ -654,20 +654,23 @@ static long wb_writeback(struct bdi_writ
> >  		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
> >  
> >  		/*
> > -		 * If we consumed everything, see if we have more
> > +		 * Did we write something? Try for more
> > +		 *
> > +		 * This is needed _before_ the b_more_io test because the
> > +		 * background writeback moves inodes to b_io and works on
>   Well, this applies generally to any writeback, not just a background one
> right? Whenever we process all inodes from b_io list and move them
> somewhere else than b_more_io, then this applies. Some new dirty data could
> have arrived while we were doing the write...

Right. Only that it is a requirement for background writeback.
For others this patch is not a necessity.

> I'm just afraid that in some
> pathological cases this could result in bad writeback pattern - like if
> there is some process which manages to dirty just a few pages while we are
> doing writeout, this looping could result in writing just a few pages in
> each round which is bad for fragmentation etc.

Such inodes will be redirty_tail()ed here:

                if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
                        /*
                         * We didn't write back all the pages.  nfs_writepages()
                         * sometimes bales out without doing anything.
                         */
                        inode->i_state |= I_DIRTY_PAGES;
                        if (wbc->nr_to_write <= 0) {
                                /*
                                 * slice used up: queue for next turn
                                 */
                                requeue_io(inode);
                        } else {
                                /*
                                 * Writeback blocked by something other than
                                 * congestion. Delay the inode for some time to
                                 * avoid spinning on the CPU (100% iowait)
                                 * retrying writeback of the dirty page/inode
                                 * that cannot be performed immediately.
                                 */
                                redirty_tail(inode);
                        }

>   Actually, this comment probably also applies to your patch where you
> change the queueing logic in writeback_single_inode(), doesn't it?

Can you elaborate?
 
Thanks,
Fengguang

> 
> > +		 * them in batches (in order to sync old pages first).  The
> > +		 * completion of the current batch does not necessarily mean
> > +		 * the overall work is done.
> >  		 */
> > -		if (wbc.nr_to_write <= 0)
> > +		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
> >  			continue;
> > +
> >  		/*
> > -		 * Didn't write everything and we don't have more IO, bail
> > +		 * Nothing written and no more inodes for IO, bail
> >  		 */
> >  		if (list_empty(&wb->b_more_io))
> >  			break;
> > -		/*
> > -		 * Did we write something? Try for more
> > -		 */
> > -		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
> > -			continue;
> > +
> >  		/*
> >  		 * Nothing written. Wait for some inode to
> >  		 * become available for writeback. Otherwise
> > 
> > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
