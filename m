Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 396D48D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:48:27 -0400 (EDT)
Date: Mon, 14 Mar 2011 21:48:21 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110314204821.GC4998@quack.suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <1299623475-5512-4-git-send-email-jack@suse.cz>
 <20110310000731.GE10346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310000731.GE10346@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Wed 09-03-11 19:07:31, Vivek Goyal wrote:
> > +static void balance_dirty_pages(struct address_space *mapping,
> > +				unsigned long write_chunk)
> > +{
> > +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> > +	struct balance_waiter bw;
> > +	struct dirty_limit_state st;
> > +	int dirty_exceeded = check_dirty_limits(bdi, &st);
> > +
> > +	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT ||
> > +	    (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> > +	     !bdi_task_limit_exceeded(&st, current))) {
> > +		if (bdi->dirty_exceeded &&
> > +		    dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT)
> > +			bdi->dirty_exceeded = 0;
> >  		/*
> > -		 * Increase the delay for each loop, up to our previous
> > -		 * default of taking a 100ms nap.
> > +		 * In laptop mode, we wait until hitting the higher threshold
> > +		 * before starting background writeout, and then write out all
> > +		 * the way down to the lower threshold.  So slow writers cause
> > +		 * minimal disk activity.
> > +		 *
> > +		 * In normal mode, we start background writeout at the lower
> > +		 * background_thresh, to keep the amount of dirty memory low.
> >  		 */
> > -		pause <<= 1;
> > -		if (pause > HZ / 10)
> > -			pause = HZ / 10;
> > +		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
> > +			bdi_start_background_writeback(bdi);
> > +		return;
> >  	}
> >  
> > -	/* Clear dirty_exceeded flag only when no task can exceed the limit */
> > -	if (!min_dirty_exceeded && bdi->dirty_exceeded)
> > -		bdi->dirty_exceeded = 0;
> > +	if (!bdi->dirty_exceeded)
> > +		bdi->dirty_exceeded = 1;
> 
> Will it make sense to move out bdi_task_limit_exceeded() check in a
> separate if condition statement as follows. May be this is little
> easier to read.
> 
> 	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
> 		if (bdi->dirty_exceeded)
> 			bdi->dirty_exceeded = 0;
> 
> 		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
> 			bdi_start_background_writeback(bdi);
> 
> 		return;
> 	}
> 
> 	if (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> 	    !bdi_task_limit_exceeded(&st, current))
> 		return;   
  But then we have to start background writeback here as well. Which is
actually a bug in the original patch as well! So clearly your way is more
readable :) I'll change it. Thanks.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
