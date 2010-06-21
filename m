Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22DE26B01CF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:36:57 -0400 (EDT)
Date: Tue, 22 Jun 2010 01:36:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100621233628.GL3828@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100618060901.GA6590@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Fri 18-06-10 16:09:01, Dave Chinner wrote:
> On Thu, Jun 17, 2010 at 08:04:38PM +0200, Jan Kara wrote:
> > This patch changes balance_dirty_pages() throttling so that the function does
> > not submit writes on its own but rather waits for flusher thread to do enough
> > writes. This has an advantage that we have a single source of IO allowing for
> > better writeback locality. Also we do not have to reenter filesystems from a
> > non-trivial context.
> > 
> > The waiting is implemented as follows: Each BDI has a FIFO of wait requests.
> > When balance_dirty_pages() finds it needs to throttle the writer, it adds a
> > request for writing write_chunk of pages to the FIFO and waits until the
> > request is fulfilled or we drop below dirty limits. A flusher thread tracks
> > amount of pages it has written and when enough pages are written since the
> > first request in the FIFO became first, it wakes up the waiter and removes
> > request from the FIFO (thus another request becomes first and flusher thread
> > starts writing out on behalf of this request).
> > 
> > CC: hch@infradead.org
> > CC: akpm@linux-foundation.org
> > CC: peterz@infradead.org
> > CC: wfg@mail.ustc.edu.cn
> > Signed-off-by: Jan Kara <jack@suse.cz>
...
> > +		wc = list_entry(bdi->wb_written_list.next,
> > +				struct bdi_written_count,
> > +				list);
> 
> list_first_entry()?
  Done, thanks.

> 
> > +		bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
> 
> The resolution of the percpu counters is an issue here, I think.
> percpu counters update in batches of 32 counts per CPU. wc->written
> is going to have a value of roughly 8 or 32 depending on whether
> bdi->dirty_exceeded is set or not. I note that you take this into
> account when checking dirty threshold limits, but it doesn't appear
> to be taken in to here.
  Hmm, are you sure about the number of pages? I think that the ratelimits
you speak about influence only how often we *check* the limits. Looking at
sync_writeback_pages() I see:
static inline long sync_writeback_pages(unsigned long dirtied)
{
        if (dirtied < ratelimit_pages)
                dirtied = ratelimit_pages;

        return dirtied + dirtied / 2;
}

  So it returns at least ratelimit_pages * 3/2. Now ratelimit_pages is
computed in writeback_set_ratelimit() and for most machines I expect the
math there to end up with ratelimit_pages == 1024. So we enter
balance_dirty_pages with number 1536... That being said, the error of
percpu counters can still be significant - with 16 CPUs doing completion
the average error is 384 (on your max_cpus == 512 machine - our distro
kernels have that too).

> That means for ratelimits of 8 pages on writes and only one CPU doing
> IO completion wakeups are only going to occur in completion batches
> of 32 pages. we'll end up with something like:
> 
> waiter, written		count at head	count when woken
>  A, 8			n			n + 32
>  B, 8			n + 32			n + 64
>  C, 8			n + 64			n + 96
> .....
> 
> And so on. This isn't necessarily bad - we'll throttle for longer
> than we strictly need to - but the cumulative counter resolution
> error gets worse as the number of CPUs doing IO completion grows.
> Worst case ends up at for (num cpus * 31) + 1 pages of writeback for
> just the first waiter. For an arbitrary FIFO queue of depth d, the
> worst case is more like d * (num cpus * 31 + 1).
  Hmm, I don't see how the error would depend on the FIFO depth. I'd rather
think that the number of written pages after which a thread is woken is a
random variable equally distributed in a range
<wanted_nr - max_counter_err, wanted_nr + max_counter_err>. And over time
(or with more threads in the queue) these errors cancel out... Now as I
wrote above the error for single waiter might be just too large to accept
but I just wanted to argue here that I don't see how it would be getting
worse with more waiters.

> Hence I think that instead of calculating the next wakeup threshold
> when the head changes the wakeup threshold needs to be a function of
> the FIFO depth. That is, it is calculated at queueing time from the
> current tail of the queue.
> 
> e.g. something like this when queuing:
> 
> 	if (list_empty(&bdi->wb_written_list))
> 		wc->wakeup_at = bdi_stat(bdi, BDI_WRITTEN) + written;
> 		bdi->wb_written_head = wc->wakeup_at;
> 	else {
> 		tail = list_last_entry(&bdi->wb_written_list);
> 		wc->wakeup_at = tail->wakeup_at + written;
> 	}
> 	list_add_tail(&wc->list, &bdi->wb_written_list);
  I specifically wanted to avoid computing the wake up time while queueing
because if some thread quits the queue (a signal is currently probably the
only good reason; if a system gets below dirty limits for a short while so
that only a few threads notice is an arguable reason), you would need to
recompute them or live with waiting unnecessarily long.
  But we could compute next wake up time from wb_written_head (when valid)
which would make more sense. I like that.

> And this when the wakeup threshold is tripped:
> 
> 	written = bdi_stat(bdi, BDI_WRITTEN);
> 	while (!list_empty(&bdi->wb_written_list)) {
> 		wc = list_first_entry();
> 
> 		if (wc->wakeup_at > written)
> 			break;
> 
> 		list_del_init(wc)
> 		wakeup(wc)
> 	}
> 
> 	if (!list_empty(&bdi->wb_written_list)) {
> 		wc = list_first_entry();
> 		bdi->wb_written_head = wc->wakeup_at;
> 	} else
> 		bdi->wb_written_head = ~0ULL;
> 
> This takes the counter resolution completely out of the picture - if
> the counter resolution is 32, and there are 4 waiters on the fifo
> each waiting for 8 pages, then a single tick of the counter will
> wake them all up.
  Yeah, this would work with what I suggest above too. One just has to
write the loop carefully enough ;). Thanks for great suggestions.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
