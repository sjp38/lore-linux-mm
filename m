Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6F90E6B01AD
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 02:09:34 -0400 (EDT)
Date: Fri, 18 Jun 2010 16:09:01 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100618060901.GA6590@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276797878-28893-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Thu, Jun 17, 2010 at 08:04:38PM +0200, Jan Kara wrote:
> This patch changes balance_dirty_pages() throttling so that the function does
> not submit writes on its own but rather waits for flusher thread to do enough
> writes. This has an advantage that we have a single source of IO allowing for
> better writeback locality. Also we do not have to reenter filesystems from a
> non-trivial context.
> 
> The waiting is implemented as follows: Each BDI has a FIFO of wait requests.
> When balance_dirty_pages() finds it needs to throttle the writer, it adds a
> request for writing write_chunk of pages to the FIFO and waits until the
> request is fulfilled or we drop below dirty limits. A flusher thread tracks
> amount of pages it has written and when enough pages are written since the
> first request in the FIFO became first, it wakes up the waiter and removes
> request from the FIFO (thus another request becomes first and flusher thread
> starts writing out on behalf of this request).
> 
> CC: hch@infradead.org
> CC: akpm@linux-foundation.org
> CC: peterz@infradead.org
> CC: wfg@mail.ustc.edu.cn
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/backing-dev.h |   18 +++++
>  include/linux/writeback.h   |    1 +
>  mm/backing-dev.c            |  119 +++++++++++++++++++++++++++++++
>  mm/page-writeback.c         |  164 +++++++++++++++----------------------------
>  4 files changed, 195 insertions(+), 107 deletions(-)
> 
>  This is mostly a proof-of-concept patch. It's mostly untested and probably
> doesn't completely work. I was just thinking about this for some time already
> and would like to get some feedback on the approach...

It matches the way I'd like to see writeback throttling work.
I think this approach is likely to have less jitter and latency
because throttling is not tied to a specific set of pages or IOs to
complete.

> 
> +++ b/mm/backing-dev.c
> @@ -390,6 +390,122 @@ static void sync_supers_timer_fn(unsigned long unused)
>  	bdi_arm_supers_timer();
>  }
>  
> +/*
> + * Remove writer from the list, update wb_written_head as needed
> + *
> + * Needs wb_written_wait.lock held
> + */
> +static void bdi_remove_writer(struct backing_dev_info *bdi,
> +			      struct bdi_written_count *wc)
> +{
> +	int first = 0;
> +
> +	if (bdi->wb_written_list.next == &wc->list)
> +		first = 1;
> +	/* Initialize list so that entry owner knows it's removed */
> +	list_del_init(&wc->list);
> +	if (first) {
> +		if (list_empty(&bdi->wb_written_list)) {
> +			bdi->wb_written_head = ~(u64)0;
> +			return;
> +		}
> +		wc = list_entry(bdi->wb_written_list.next,
> +				struct bdi_written_count,
> +				list);

list_first_entry()?

> +		bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;

The resolution of the percpu counters is an issue here, I think.
percpu counters update in batches of 32 counts per CPU. wc->written
is going to have a value of roughly 8 or 32 depending on whether
bdi->dirty_exceeded is set or not. I note that you take this into
account when checking dirty threshold limits, but it doesn't appear
to be taken in to here.

That means for ratelimits of 8 pages on writes and only one CPU doing
IO completion wakeups are only going to occur in completion batches
of 32 pages. we'll end up with something like:

waiter, written		count at head	count when woken
 A, 8			n			n + 32
 B, 8			n + 32			n + 64
 C, 8			n + 64			n + 96
.....

And so on. This isn't necessarily bad - we'll throttle for longer
than we strictly need to - but the cumulative counter resolution
error gets worse as the number of CPUs doing IO completion grows.
Worst case ends up at for (num cpus * 31) + 1 pages of writeback for
just the first waiter. For an arbitrary FIFO queue of depth d, the
worst case is more like d * (num cpus * 31 + 1).

Hence I think that instead of calculating the next wakeup threshold
when the head changes the wakeup threshold needs to be a function of
the FIFO depth. That is, it is calculated at queueing time from the
current tail of the queue.

e.g. something like this when queuing:

	if (list_empty(&bdi->wb_written_list))
		wc->wakeup_at = bdi_stat(bdi, BDI_WRITTEN) + written;
		bdi->wb_written_head = wc->wakeup_at;
	else {
		tail = list_last_entry(&bdi->wb_written_list);
		wc->wakeup_at = tail->wakeup_at + written;
	}
	list_add_tail(&wc->list, &bdi->wb_written_list);

And this when the wakeup threshold is tripped:

	written = bdi_stat(bdi, BDI_WRITTEN);
	while (!list_empty(&bdi->wb_written_list)) {
		wc = list_first_entry();

		if (wc->wakeup_at > written)
			break;

		list_del_init(wc)
		wakeup(wc)
	}

	if (!list_empty(&bdi->wb_written_list)) {
		wc = list_first_entry();
		bdi->wb_written_head = wc->wakeup_at;
	} else
		bdi->wb_written_head = ~0ULL;

This takes the counter resolution completely out of the picture - if
the counter resolution is 32, and there are 4 waiters on the fifo
each waiting for 8 pages, then a single tick of the counter will
wake them all up.

Other than that, it seems like a good approach to me...

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
