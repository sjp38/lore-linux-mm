Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 524118D003A
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 15:59:00 -0400 (EDT)
Date: Wed, 16 Mar 2011 20:58:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110316195844.GD4456@quack.suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <1299623475-5512-4-git-send-email-jack@suse.cz>
 <20110316165331.GA15183@redhat.com>
 <20110316191021.GB4456@quack.suse.cz>
 <20110316193144.GE13562@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110316193144.GE13562@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Wed 16-03-11 15:31:44, Vivek Goyal wrote:
> On Wed, Mar 16, 2011 at 08:10:21PM +0100, Jan Kara wrote:
> > On Wed 16-03-11 12:53:31, Vivek Goyal wrote:
> > > On Tue, Mar 08, 2011 at 11:31:13PM +0100, Jan Kara wrote:
> > > [..]
> > > > +/*
> > > > + * balance_dirty_pages() must be called by processes which are generating dirty
> > > > + * data.  It looks at the number of dirty pages in the machine and will force
> > > > + * the caller to perform writeback if the system is over `vm_dirty_ratio'.
> > > > + * If we're over `background_thresh' then the writeback threads are woken to
> > > > + * perform some writeout.
> > > > + */
> > > > +static void balance_dirty_pages(struct address_space *mapping,
> > > > +				unsigned long write_chunk)
> > > > +{
> > > > +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> > > > +	struct balance_waiter bw;
> > > > +	struct dirty_limit_state st;
> > > > +	int dirty_exceeded = check_dirty_limits(bdi, &st);
> > > > +
> > > > +	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT ||
> > > > +	    (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> > > > +	     !bdi_task_limit_exceeded(&st, current))) {
> > > > +		if (bdi->dirty_exceeded &&
> > > > +		    dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT)
> > > > +			bdi->dirty_exceeded = 0;
> > > >  		/*
> > > > -		 * Increase the delay for each loop, up to our previous
> > > > -		 * default of taking a 100ms nap.
> > > > +		 * In laptop mode, we wait until hitting the higher threshold
> > > > +		 * before starting background writeout, and then write out all
> > > > +		 * the way down to the lower threshold.  So slow writers cause
> > > > +		 * minimal disk activity.
> > > > +		 *
> > > > +		 * In normal mode, we start background writeout at the lower
> > > > +		 * background_thresh, to keep the amount of dirty memory low.
> > > >  		 */
> > > > -		pause <<= 1;
> > > > -		if (pause > HZ / 10)
> > > > -			pause = HZ / 10;
> > > > +		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
> > > > +			bdi_start_background_writeback(bdi);
> > > > +		return;
> > > >  	}
> > > >  
> > > > -	/* Clear dirty_exceeded flag only when no task can exceed the limit */
> > > > -	if (!min_dirty_exceeded && bdi->dirty_exceeded)
> > > > -		bdi->dirty_exceeded = 0;
> > > > +	if (!bdi->dirty_exceeded)
> > > > +		bdi->dirty_exceeded = 1;
> > > >  
> > > > -	if (writeback_in_progress(bdi))
> > > > -		return;
> > > > +	trace_writeback_balance_dirty_pages_waiting(bdi, write_chunk);
> > > > +	/* Kick flusher thread to start doing work if it isn't already */
> > > > +	bdi_start_background_writeback(bdi);
> > > >  
> > > > +	bw.bw_wait_pages = write_chunk;
> > > > +	bw.bw_task = current;
> > > > +	spin_lock(&bdi->balance_lock);
> > > >  	/*
> > > > -	 * In laptop mode, we wait until hitting the higher threshold before
> > > > -	 * starting background writeout, and then write out all the way down
> > > > -	 * to the lower threshold.  So slow writers cause minimal disk activity.
> > > > -	 *
> > > > -	 * In normal mode, we start background writeout at the lower
> > > > -	 * background_thresh, to keep the amount of dirty memory low.
> > > > +	 * First item? Need to schedule distribution of IO completions among
> > > > +	 * items on balance_list
> > > > +	 */
> > > > +	if (list_empty(&bdi->balance_list)) {
> > > > +		bdi->written_start = bdi_stat_sum(bdi, BDI_WRITTEN);
> > > > +		/* FIXME: Delay should be autotuned based on dev throughput */
> > > > +		schedule_delayed_work(&bdi->balance_work, HZ/10);
> > > > +	}
> > > > +	/*
> > > > +	 * Add work to the balance list, from now on the structure is handled
> > > > +	 * by distribute_page_completions()
> > > > +	 */
> > > > +	list_add_tail(&bw.bw_list, &bdi->balance_list);
> > > > +	bdi->balance_waiters++;
> > > Had a query.
> > > 
> > > - What makes sure that flusher thread will not stop writing back till all
> > >   the waiters on the bdi have been woken up. IIUC, flusher thread will 
> > >   stop once global background ratio is with-in limit. Is it possible that
> > >   there are still some waiter on some bdi waiting for more pages to finish
> > >   writeback and that might not happen for sometime. 
> >   Yes, this can possibly happen but once distribute_page_completions()
> > gets called (after a given time), it will notice that we are below limits
> > and wake all waiters.
> > Under normal circumstances, we should have a decent
> > estimate when distribute_page_completions() needs to be called and that
> > should be long before flusher thread finishes it's work. But in cases when
> > a bdi has only a small share of global dirty limit, what you describe can
> > possibly happen.
> 
> So if a bdi share is small then it can happen that global background
> threshold is fine but per bdi threshold is not. That means
> task_bdi_threshold is also above limit and IIUC, distribute_page_completion()
> will not wake up the waiter until bdi_task_limit_exceeded() is in control.
  It will wake them. What you miss is the check right at the beginning of
distribute_page_completions():
      dirty_exceeded = check_dirty_limits(bdi, &st);
      if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
               /* Wakeup everybody */
...

  When we are globally below (background+limit)/2, dirty_exceeded is set to
DIRTY_OK or DIRTY_BACKGROUND and thus we just wake all the waiters.

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
