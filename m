Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD2D6B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 17:34:20 -0400 (EDT)
Date: Thu, 14 Jul 2011 23:34:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Properly reflect task dirty limits in
 dirty_exceeded logic
Message-ID: <20110714213409.GB16415@quack.suse.cz>
References: <1309458764-9153-1-git-send-email-jack@suse.cz>
 <20110704010618.GA3841@localhost>
 <20110711170605.GF5482@quack.suse.cz>
 <20110713230258.GA17011@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110713230258.GA17011@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed 13-07-11 16:02:58, Wu Fengguang wrote:
> On Tue, Jul 12, 2011 at 01:06:05AM +0800, Jan Kara wrote:
> > On Mon 04-07-11 09:06:19, Wu Fengguang wrote:
> > > On Fri, Jul 01, 2011 at 02:32:44AM +0800, Jan Kara wrote:
> > > > We set bdi->dirty_exceeded (and thus ratelimiting code starts to
> > > > call balance_dirty_pages() every 8 pages) when a per-bdi limit is
> > > > exceeded or global limit is exceeded. But per-bdi limit also depends
> > > > on the task. Thus different tasks reach the limit on that bdi at
> > > > different levels of dirty pages. The result is that with current code
> > > > bdi->dirty_exceeded ping-ponged between 1 and 0 depending on which task
> > > > just got into balance_dirty_pages().
> > > > 
> > > > We fix the issue by clearing bdi->dirty_exceeded only when per-bdi amount
> > > > of dirty pages drops below the threshold (7/8 * bdi_dirty_limit) where task
> > > > limits already do not have any influence.
> > > 
> > > The end result, I think, is that the dirty pages are kept more tightly
> > > under control, with the average number a slightly lowered than before. 
> > > This reduces the risk to throttle light dirtiers and hence more
> > > responsive. However it does introduce more overheads by enforcing
> > > balance_dirty_pages() calls on every 8 pages.
> >   Yes. I think this was actually the original intention when the code was
> > written.
> 
> I'm still a bit nervous on the added overheads for the common 1 heavy
> dirty case.  Before patch, the 1 heavy dirty will normally clear
> bdi->dirty_exceeded on leaving balance_dirty_pages(), so it doesn't
> have the burden of rechecking the limit on every 8 pages.
Yes, but if there is 1 heavy dirtier, task_min_dirty_limit() will be
actually equal (or almost equal) to the dirty limit of that task. So that
case won't be really different.

When we will be different is when there are two or more dirtying tasks.
Then we originally cleared dirty_exceeded already at higher level of dirty
pages so we stopped checking after every 8 dirtied pages earlier.
 
> How about this minimal change?
> 
>  static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
>  {
> -       return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION;
> +       return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION / 4;
>  }
> 
> A more complete version will involve changing the function name and
> comment. But the basic rationales are,
> 
> - there is no serious danger of dirty exceeding as long as there are
>   less than 4 heavy dirties
> 
> - tasks dirtying close to 25% pages probably cannot be called light
>   dirtier and there is no need to protect such tasks
  The idea is interesting. The only problem is that we don't want to set
dirty_exceeded too late so that heavy dirtiers won't push light dirtiers
over their limits so easily due to ratelimiting. It did some computations:
We normally ratelimit after 4 MB. Take a low end desktop these days. Say
1 GB of ram, 4 CPUs. So dirty limit will be ~200 MB and the area for task
differentiation ~25 MB. We enter balance_dirty_pages() after dirtying
num_cpu * ratelimit / 2 pages on average which gives 8 MB. So we should
set dirty_exceeded at latest at bdi_dirty / TASK_LIMIT_FRACTION / 2 or
task differentiation would have no effect because of ratelimiting.

So we could change the limit to something like:
bdi_dirty - min(bdi_dirty / TASK_LIMIT_FRACTION, ratelimit_pages *
num_online_cpus / 2 + bdi_dirty / TASK_LIMIT_FRACTION / 16)

But I'm not sure setups where this would make difference are common...

								Honza

> > > > CC: Andrew Morton <akpm@linux-foundation.org>
> > > > CC: Christoph Hellwig <hch@infradead.org>
> > > > CC: Dave Chinner <david@fromorbit.com>
> > > > CC: Wu Fengguang <fengguang.wu@intel.com>
> > > > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > > ---
> > > >  mm/page-writeback.c |   29 ++++++++++++++++++++++-------
> > > >  1 files changed, 22 insertions(+), 7 deletions(-)
> > > > 
> > > >  This is the patch fixing dirty_exceeded logic I promised you last week.
> > > > I based it on current Linus's tree as it is a relatively direct fix so I
> > > > expect it can be somewhere in the beginning of the patch series and merged
> > > > relatively quickly. Can you please add it to your tree? Thanks.
> > > 
> > > OK. I noticed that bdi_thresh is no longer used. What if we just
> > > rename it? But I admit that the patch in its current form looks a bit
> > > more clear in concept.
> >   You are right bdi_thresh is only used for computing task_bdi_thresh and
> > min_task_bdi_thresh now. We could possibly eliminate that one variable but
> > I guess compiler will optimize it away anyway and I find the code more
> > legible when written this way...
> 
> OK.
> 
> Thanks,
> Fengguang
> 
> > > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > > index 31f6988..d8b395f 100644
> > > > --- a/mm/page-writeback.c
> > > > +++ b/mm/page-writeback.c
> > > > @@ -274,12 +274,13 @@ static inline void task_dirties_fraction(struct task_struct *tsk,
> > > >   * effectively curb the growth of dirty pages. Light dirtiers with high enough
> > > >   * dirty threshold may never get throttled.
> > > >   */
> > > > +#define TASK_LIMIT_FRACTION 8
> > > >  static unsigned long task_dirty_limit(struct task_struct *tsk,
> > > >  				       unsigned long bdi_dirty)
> > > >  {
> > > >  	long numerator, denominator;
> > > >  	unsigned long dirty = bdi_dirty;
> > > > -	u64 inv = dirty >> 3;
> > > > +	u64 inv = dirty / TASK_LIMIT_FRACTION;
> > > >  
> > > >  	task_dirties_fraction(tsk, &numerator, &denominator);
> > > >  	inv *= numerator;
> > > > @@ -290,6 +291,12 @@ static unsigned long task_dirty_limit(struct task_struct *tsk,
> > > >  	return max(dirty, bdi_dirty/2);
> > > >  }
> > > >  
> > > > +/* Minimum limit for any task */
> > > > +static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
> > > > +{
> > > > +	return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION;
> > > > +}
> > > > +
> > > >  /*
> > > >   *
> > > >   */
> > > > @@ -483,9 +490,12 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  	unsigned long background_thresh;
> > > >  	unsigned long dirty_thresh;
> > > >  	unsigned long bdi_thresh;
> > > > +	unsigned long task_bdi_thresh;
> > > > +	unsigned long min_task_bdi_thresh;
> > > >  	unsigned long pages_written = 0;
> > > >  	unsigned long pause = 1;
> > > >  	bool dirty_exceeded = false;
> > > > +	bool clear_dirty_exceeded = true;
> > > >  	struct backing_dev_info *bdi = mapping->backing_dev_info;
> > > >  
> > > >  	for (;;) {
> > > > @@ -512,7 +522,8 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  			break;
> > > >  
> > > >  		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> > > > -		bdi_thresh = task_dirty_limit(current, bdi_thresh);
> > > > +		min_task_bdi_thresh = task_min_dirty_limit(bdi_thresh);
> > > > +		task_bdi_thresh = task_dirty_limit(current, bdi_thresh);
> > > >  
> > > >  		/*
> > > >  		 * In order to avoid the stacked BDI deadlock we need
> > > > @@ -524,7 +535,7 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  		 * actually dirty; with m+n sitting in the percpu
> > > >  		 * deltas.
> > > >  		 */
> > > > -		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
> > > > +		if (task_bdi_thresh < 2 * bdi_stat_error(bdi)) {
> > > >  			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> > > >  			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
> > > >  		} else {
> > > > @@ -539,8 +550,11 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  		 * the last resort safeguard.
> > > >  		 */
> > > >  		dirty_exceeded =
> > > > -			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
> > > > -			|| (nr_reclaimable + nr_writeback > dirty_thresh);
> > > > +		  (bdi_nr_reclaimable + bdi_nr_writeback > task_bdi_thresh)
> > > > +		  || (nr_reclaimable + nr_writeback > dirty_thresh);
> > > > +		clear_dirty_exceeded =
> > > > +		  (bdi_nr_reclaimable + bdi_nr_writeback <= min_task_bdi_thresh)
> > > > +		  && (nr_reclaimable + nr_writeback <= dirty_thresh);
> > > >  
> > > >  		if (!dirty_exceeded)
> > > >  			break;
> > > > @@ -558,7 +572,7 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  		 * up.
> > > >  		 */
> > > >  		trace_wbc_balance_dirty_start(&wbc, bdi);
> > > > -		if (bdi_nr_reclaimable > bdi_thresh) {
> > > > +		if (bdi_nr_reclaimable > task_bdi_thresh) {
> > > >  			writeback_inodes_wb(&bdi->wb, &wbc);
> > > >  			pages_written += write_chunk - wbc.nr_to_write;
> > > >  			trace_wbc_balance_dirty_written(&wbc, bdi);
> > > > @@ -578,7 +592,8 @@ static void balance_dirty_pages(struct address_space *mapping,
> > > >  			pause = HZ / 10;
> > > >  	}
> > > >  
> > > > -	if (!dirty_exceeded && bdi->dirty_exceeded)
> > > > +	/* Clear dirty_exceeded flag only when no task can exceed the limit */
> > > > +	if (clear_dirty_exceeded && bdi->dirty_exceeded)
> > > >  		bdi->dirty_exceeded = 0;
> > > >  
> > > >  	if (writeback_in_progress(bdi))
> > > > -- 
> > > > 1.7.1
> > -- 
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
