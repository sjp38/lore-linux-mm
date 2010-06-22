Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 73D636B01AC
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 01:45:36 -0400 (EDT)
Date: Tue, 22 Jun 2010 15:44:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622054409.GP7869@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621233628.GL3828@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 01:36:29AM +0200, Jan Kara wrote:
> On Fri 18-06-10 16:09:01, Dave Chinner wrote:
> > On Thu, Jun 17, 2010 at 08:04:38PM +0200, Jan Kara wrote:
> > > This patch changes balance_dirty_pages() throttling so that the function does
> > > not submit writes on its own but rather waits for flusher thread to do enough
> > > writes. This has an advantage that we have a single source of IO allowing for
> > > better writeback locality. Also we do not have to reenter filesystems from a
> > > non-trivial context.
> > > 
> > > The waiting is implemented as follows: Each BDI has a FIFO of wait requests.
> > > When balance_dirty_pages() finds it needs to throttle the writer, it adds a
> > > request for writing write_chunk of pages to the FIFO and waits until the
> > > request is fulfilled or we drop below dirty limits. A flusher thread tracks
> > > amount of pages it has written and when enough pages are written since the
> > > first request in the FIFO became first, it wakes up the waiter and removes
> > > request from the FIFO (thus another request becomes first and flusher thread
> > > starts writing out on behalf of this request).
> > > 
> > > CC: hch@infradead.org
> > > CC: akpm@linux-foundation.org
> > > CC: peterz@infradead.org
> > > CC: wfg@mail.ustc.edu.cn
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> ...
> > > +		wc = list_entry(bdi->wb_written_list.next,
> > > +				struct bdi_written_count,
> > > +				list);
> > 
> > list_first_entry()?
>   Done, thanks.
> 
> > 
> > > +		bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
> > 
> > The resolution of the percpu counters is an issue here, I think.
> > percpu counters update in batches of 32 counts per CPU. wc->written
> > is going to have a value of roughly 8 or 32 depending on whether
> > bdi->dirty_exceeded is set or not. I note that you take this into
> > account when checking dirty threshold limits, but it doesn't appear
> > to be taken in to here.
>   Hmm, are you sure about the number of pages? I think that the ratelimits
> you speak about influence only how often we *check* the limits. Looking at
> sync_writeback_pages() I see:
> static inline long sync_writeback_pages(unsigned long dirtied)
> {
>         if (dirtied < ratelimit_pages)
>                 dirtied = ratelimit_pages;
> 
>         return dirtied + dirtied / 2;
> }

It's declared as:

  39 /*
  40  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  41  * will look to see if it needs to force writeback or throttling.
  42  */
  43 static long ratelimit_pages = 32;

>   So it returns at least ratelimit_pages * 3/2. Now ratelimit_pages is
> computed in writeback_set_ratelimit() and for most machines I expect the
> math there to end up with ratelimit_pages == 1024. So we enter
> balance_dirty_pages with number 1536...

But I missed this. That means we typically will check every 1024
pages until dirty_exceeded is set, then we'll check every 8 pages.

> That being said, the error of
> percpu counters can still be significant - with 16 CPUs doing completion
> the average error is 384 (on your max_cpus == 512 machine - our distro
> kernels have that too).

The error gets larger as the number of CPUs goes up - Peter pointed
that out because:

#define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))

So for a system reporting nr_cpu_ids = 32 (as my 8 core nehalem
server currently reports), the error could be 16 * 48 = 768.

> > That means for ratelimits of 8 pages on writes and only one CPU doing
> > IO completion wakeups are only going to occur in completion batches
> > of 32 pages. we'll end up with something like:
> > 
> > waiter, written		count at head	count when woken
> >  A, 8			n			n + 32
> >  B, 8			n + 32			n + 64
> >  C, 8			n + 64			n + 96
> > .....
> > 
> > And so on. This isn't necessarily bad - we'll throttle for longer
> > than we strictly need to - but the cumulative counter resolution
> > error gets worse as the number of CPUs doing IO completion grows.
> > Worst case ends up at for (num cpus * 31) + 1 pages of writeback for
> > just the first waiter. For an arbitrary FIFO queue of depth d, the
> > worst case is more like d * (num cpus * 31 + 1).
>   Hmm, I don't see how the error would depend on the FIFO depth.

It's the cumulative error that depends on the FIFO depth, not the
error seen by a single waiter.

>   I'd rather
> think that the number of written pages after which a thread is woken is a
> random variable equally distributed in a range
> <wanted_nr - max_counter_err, wanted_nr + max_counter_err>.

Right, that the error range seenby a single waiter. i.e. between

	bdi->wb_written_head = bdi_stat(written) + wc->pages_to_wait_for;

If we only want to wait for, say, 10 pages from a counter value of
N, the per-cpu counter increments in batches of BDI_STAT_BATCH.
Hence the first time we see bdi_stat(written) pass
bdi->wb_written_head will be when it reaches (N + BDI_STAT_BATCH).
We will have waited (BDI_STAT_BATCH - 10) pages more than we needed
to. i.e the wait time is a minimum of roundup(pages_to_wait_for,
BDI_STAT_BATCH).

> And over time
> (or with more threads in the queue) these errors cancel out... Now as I
> wrote above the error for single waiter might be just too large to accept
> but I just wanted to argue here that I don't see how it would be getting
> worse with more waiters.

That's where I think you go wrong - the error occurs when we remove
the waiter at the head of the queue, so each subsequent waiter has a
resolution error introduced. These will continue to aggregate as
long as there are more waiters on the queue.

e.g if we've got 3 waiters of 10 pages each, they should all be
woken after 30 pages have been cleared. Instead, the first is only
woken after the counter ticks (BDI_STAT_BATCH), then the second is
queued, and it doesn't get woken for another counter tick. Similarly
for the third waiter. When the third waiter is woken, it has waited
for 3 * BDI_STAT_BATCH pages. In reality, what we realy wanted was
all three waiters to be woken by the time 30 pages had been written
back. i.e. the last waiter waited for (3 * (BDI_STAT_BATCH - 10)),
which in general terms gives a wait overshoot for any given waiter of
roughly (queue depth when queued * BDI_STAT_BATCH * nr_cpu_ids) pages.

However, if we calculate the wakeup time when we queue, each waiter
ends up with a wakeup time of N + 10, N + 20, and N + 30, and the
counter tick resolution is taken out of the picture. i.e. if the
tick is 8, then the first wakeup occurs after 2 counter ticks, the
second is woken after 3 counter ticks and the last is woken after 4
counter ticks. If the counter tick is >= 32, then all three will be
woken on the first counter tick. In this case, the worst case wait
overshoot for any waiter regardless of queue depth is
(BDI_STAT_BATCH * nr_cpu_ids) pages.


> > Hence I think that instead of calculating the next wakeup threshold
> > when the head changes the wakeup threshold needs to be a function of
> > the FIFO depth. That is, it is calculated at queueing time from the
> > current tail of the queue.
> > 
> > e.g. something like this when queuing:
> > 
> > 	if (list_empty(&bdi->wb_written_list))
> > 		wc->wakeup_at = bdi_stat(bdi, BDI_WRITTEN) + written;
> > 		bdi->wb_written_head = wc->wakeup_at;
> > 	else {
> > 		tail = list_last_entry(&bdi->wb_written_list);
> > 		wc->wakeup_at = tail->wakeup_at + written;
> > 	}
> > 	list_add_tail(&wc->list, &bdi->wb_written_list);
>   I specifically wanted to avoid computing the wake up time while queueing
> because if some thread quits the queue (a signal is currently probably the
> only good reason;

Fair point.

> if a system gets below dirty limits for a short while so
> that only a few threads notice is an arguable reason), you would need to
> recompute them or live with waiting unnecessarily long.

I'd suggest that we shouldn't be waking waiters prematurely if we've
dropped below the dirty threshold - we need some hysteresis in the
system to prevent oscillating rapidly around the threshold. If we
are not issuing IO, then if we don't damp the wakeup frequency we
could easily thrash around the threshold.

I'd prefer to strip down the mechanism to the simplest, most
accurate form before trying to add "interesting" tweaks like faster
wakeup semantics at dirty thresholds....

>   But we could compute next wake up time from wb_written_head (when valid)
> which would make more sense. I like that.

Yes, I think that would work because everything would then be delta
values from a constant base - it just delays the wakeup threshold
calculation until the waiter hits the head of the queue.....

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
