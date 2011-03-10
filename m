Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BA9598D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 19:07:52 -0500 (EST)
Date: Wed, 9 Mar 2011 19:07:31 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110310000731.GE10346@redhat.com>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <1299623475-5512-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299623475-5512-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Tue, Mar 08, 2011 at 11:31:13PM +0100, Jan Kara wrote:
> This patch changes balance_dirty_pages() throttling so that the function does
> not submit writes on its own but rather waits for flusher thread to do enough
> writes. This has an advantage that we have a single source of IO allowing for
> better writeback locality. Also we do not have to reenter filesystems from a
> non-trivial context.
> 
> The waiting is implemented as follows: Whenever we decide to throttle a task in
> balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> against that bdi and goes to sleep waiting to receive specified amount of page
> IO completions. Once in a while (currently HZ/10, later the interval should be
> autotuned based on observed IO completion rate), accumulated page IO
> completions are distributed equally among waiting tasks.
> 
> This waiting scheme has been chosen so that waiting time in
> balance_dirty_pages() is proportional to
>   number_waited_pages * number_of_waiters.
> In particular it does not depend on the total number of pages being waited for,
> thus providing possibly a fairer results. Note that the dependency on the
> number of waiters is inevitable, since all the waiters compete for a common
> resource so their number has to be somehow reflected in waiting time.
> 
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Christoph Hellwig <hch@infradead.org>
> CC: Dave Chinner <david@fromorbit.com>
> CC: Wu Fengguang <fengguang.wu@intel.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/backing-dev.h      |    7 +
>  include/linux/writeback.h        |    1 +
>  include/trace/events/writeback.h |   65 +++++++-
>  mm/backing-dev.c                 |    8 +
>  mm/page-writeback.c              |  345 +++++++++++++++++++++++++-------------
>  5 files changed, 310 insertions(+), 116 deletions(-)
> 

[..]
> +/*
> + * balance_dirty_pages() must be called by processes which are generating dirty
> + * data.  It looks at the number of dirty pages in the machine and will force
> + * the caller to perform writeback if the system is over `vm_dirty_ratio'.
> + * If we're over `background_thresh' then the writeback threads are woken to
> + * perform some writeout.
> + */
> +static void balance_dirty_pages(struct address_space *mapping,
> +				unsigned long write_chunk)
> +{
> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	struct balance_waiter bw;
> +	struct dirty_limit_state st;
> +	int dirty_exceeded = check_dirty_limits(bdi, &st);
> +
> +	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT ||
> +	    (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
> +	     !bdi_task_limit_exceeded(&st, current))) {
> +		if (bdi->dirty_exceeded &&
> +		    dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT)
> +			bdi->dirty_exceeded = 0;
>  		/*
> -		 * Increase the delay for each loop, up to our previous
> -		 * default of taking a 100ms nap.
> +		 * In laptop mode, we wait until hitting the higher threshold
> +		 * before starting background writeout, and then write out all
> +		 * the way down to the lower threshold.  So slow writers cause
> +		 * minimal disk activity.
> +		 *
> +		 * In normal mode, we start background writeout at the lower
> +		 * background_thresh, to keep the amount of dirty memory low.
>  		 */
> -		pause <<= 1;
> -		if (pause > HZ / 10)
> -			pause = HZ / 10;
> +		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
> +			bdi_start_background_writeback(bdi);
> +		return;
>  	}
>  
> -	/* Clear dirty_exceeded flag only when no task can exceed the limit */
> -	if (!min_dirty_exceeded && bdi->dirty_exceeded)
> -		bdi->dirty_exceeded = 0;
> +	if (!bdi->dirty_exceeded)
> +		bdi->dirty_exceeded = 1;

Will it make sense to move out bdi_task_limit_exceeded() check in a
separate if condition statement as follows. May be this is little
easier to read.

	if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
		if (bdi->dirty_exceeded)
			bdi->dirty_exceeded = 0;

		if (!laptop_mode && dirty_exceeded == DIRTY_EXCEED_BACKGROUND)
			bdi_start_background_writeback(bdi);

		return;
	}

	if (dirty_exceeded == DIRTY_MAY_EXCEED_LIMIT &&
	    !bdi_task_limit_exceeded(&st, current))
		return;   

	/* Either task is throttled or we crossed global dirty ratio */
	if (!bdi->dirty_exceeded)
		bdi->dirty_exceeded = 1;

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
