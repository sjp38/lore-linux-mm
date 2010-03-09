Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C9DE96B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 12:35:56 -0500 (EST)
Date: Tue, 9 Mar 2010 17:35:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
	pressure to relieve instead of congestion
Message-ID: <20100309173535.GI4883@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-2-git-send-email-mel@csn.ul.ie> <20100309133513.GL8653@laptop> <20100309141713.GF4883@csn.ul.ie> <20100309150332.GP8653@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100309150332.GP8653@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 10, 2010 at 02:03:32AM +1100, Nick Piggin wrote:
> On Tue, Mar 09, 2010 at 02:17:13PM +0000, Mel Gorman wrote:
> > On Wed, Mar 10, 2010 at 12:35:13AM +1100, Nick Piggin wrote:
> > > On Mon, Mar 08, 2010 at 11:48:21AM +0000, Mel Gorman wrote:
> > > > Under heavy memory pressure, the page allocator may call congestion_wait()
> > > > to wait for IO congestion to clear or a timeout. This is not as sensible
> > > > a choice as it first appears. There is no guarantee that BLK_RW_ASYNC is
> > > > even congested as the pressure could have been due to a large number of
> > > > SYNC reads and the allocator waits for the entire timeout, possibly uselessly.
> > > > 
> > > > At the point of congestion_wait(), the allocator is struggling to get the
> > > > pages it needs and it should back off. This patch puts the allocator to sleep
> > > > on a zone->pressure_wq for either a timeout or until a direct reclaimer or
> > > > kswapd brings the zone over the low watermark, whichever happens first.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > ---
> > > >  include/linux/mmzone.h |    3 ++
> > > >  mm/internal.h          |    4 +++
> > > >  mm/mmzone.c            |   47 +++++++++++++++++++++++++++++++++++++++++++++
> > > >  mm/page_alloc.c        |   50 +++++++++++++++++++++++++++++++++++++++++++----
> > > >  mm/vmscan.c            |    2 +
> > > >  5 files changed, 101 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > > index 30fe668..72465c1 100644
> > > > --- a/include/linux/mmzone.h
> > > > +++ b/include/linux/mmzone.h
> > > > @@ -398,6 +398,9 @@ struct zone {
> > > >  	unsigned long		wait_table_hash_nr_entries;
> > > >  	unsigned long		wait_table_bits;
> > > >  
> > > > +	/* queue for processes waiting for pressure to relieve */
> > > > +	wait_queue_head_t	*pressure_wq;
> > > 
> > > Hmm, processes may be eligible to allocate from > 1 zone, but you
> > > have them only waiting for one. I wonder if we shouldn't wait for
> > > more zones?
> > > 
> > 
> > It's waiting for the zone that is most desirable. If that zones watermarks
> > are met, why would it wait on any other zone?
> 
> I mean the other way around. If that zone's watermarks are not met, then
> why shouldn't it be woken up by other zones reaching their watermarks.
> 

Doing it requires moving to a per-node structure or a global queue. I'd rather
not add hot lines to the node structure (and the associated lookup cost in
the free path) if I can help it. A global queue would work on smaller machines
but I'd be worried about thundering herd problems on larger machines. I know
congestion_wait is already a global queue but IO is a relatively slow event.
Potentially the wakeups from this queue are a lot faster.

Should I just move to a global queue as a starting point and see what
problems are caused later?

> > If you mean that it would
> > wait for any of the eligible zones to meet their watermark, it might have
> > an impact on NUMA locality but it could be managed. It might make sense to
> > wait on a node-based queue rather than a zone if this behaviour was desirable.
> > 
> > > Congestion waiting uses a global waitqueue, which hasn't seemed to
> > > cause a big scalability problem. Would it be better to have a global
> > > waitqueue for this too?
> > > 
> > 
> > Considering that the congestion wait queue is for a relatively slow operation,
> > it would be surprising if lock scalability was noticeable.  Potentially the
> > pressure_wq involves no IO so scalability may be noticeable there.
> > 
> > What would the advantages of a global waitqueue be? Obviously, a smaller
> > memory footprint. A second potential advantage is that on wakeup, it
> > could check the watermarks on multiple zones which might reduce
> > latencies in some cases. Can you think of more compelling reasons?
> 
> Your 2nd advantage is what I mean above.
> 
> 
> > > 
> > > > +void check_zone_pressure(struct zone *zone)
> > > 
> > > I don't really like the name pressure. We use that term for the reclaim
> > > pressure wheras we're just checking watermarks here (actual pressure
> > > could be anything).
> > > 
> > 
> > pressure_wq => watermark_wq
> > check_zone_pressure => check_watermark_wq
> > 
> > ?
> 
> Thanks.
> 
> > 
> > > 
> > > > +{
> > > > +	/* If no process is waiting, nothing to do */
> > > > +	if (!waitqueue_active(zone->pressure_wq))
> > > > +		return;
> > > > +
> > > > +	/* Check if the high watermark is ok for order 0 */
> > > > +	if (zone_watermark_ok(zone, 0, low_wmark_pages(zone), 0, 0))
> > > > +		wake_up_interruptible(zone->pressure_wq);
> > > > +}
> > > 
> > > If you were to do this under the zone lock (in your subsequent patch),
> > > then it could avoid races. I would suggest doing it all as a single
> > > patch and not doing the pressure checks in reclaim at all.
> > > 
> > 
> > That is reasonable. I've already dropped the checks in reclaim because as you
> > say, if the free path check is cheap enough, it's also sufficient. Checking
> > in the reclaim paths as well is redundant.
> > 
> > I'll move the call to check_zone_pressure() within the zone lock to avoid
> > races.
> > 
> > > If you are missing anything, then that needs to be explained and fixed
> > > rather than just adding extra checks.
> > > 
> > > > +
> > > > +/**
> > > > + * zonepressure_wait - Wait for pressure on a zone to ease off
> > > > + * @zone: The zone that is expected to be under pressure
> > > > + * @order: The order the caller is waiting on pages for
> > > > + * @timeout: Wait until pressure is relieved or this timeout is reached
> > > > + *
> > > > + * Waits for up to @timeout jiffies for pressure on a zone to be relieved.
> > > > + * It's considered to be relieved if any direct reclaimer or kswapd brings
> > > > + * the zone above the high watermark
> > > > + */
> > > > +long zonepressure_wait(struct zone *zone, unsigned int order, long timeout)
> > > > +{
> > > > +	long ret;
> > > > +	DEFINE_WAIT(wait);
> > > > +
> > > > +wait_again:
> > > > +	prepare_to_wait(zone->pressure_wq, &wait, TASK_INTERRUPTIBLE);
> > > 
> > > I guess to do it without races you need to check watermark here.
> > > And possibly some barriers if it is done without zone->lock.
> > > 
> > 
> > As watermark checks are already done without the zone->lock and without
> > barriers, why are they needed here? Yes, there are small races. For
> > example, it's possible to hit a window where pages were freed between
> > watermarks were checked and we went to sleep here but that is similar to
> > current behaviour.
> 
> Well with the check in free_pages_bulk then doing another check here
> before the wait should be able to close all lost-wakeup races. I agree
> it is pretty fuzzy heuristics anyway, so these races don't *really*
> matter a lot. But it seems easy to close the races, so I don't see
> why not.
> 

I agree that the window is unnecessarily large. I'll tighten it.,

> 
> > > > +
> > > > +	/*
> > > > +	 * The use of io_schedule_timeout() here means that it gets
> > > > +	 * accounted for as IO waiting. This may or may not be the case
> > > > +	 * but at least this way it gets picked up by vmstat
> > > > +	 */
> > > > +	ret = io_schedule_timeout(timeout);
> > > > +	finish_wait(zone->pressure_wq, &wait);
> > > > +
> > > > +	/* If woken early, check watermarks before continuing */
> > > > +	if (ret && !zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0)) {
> > > > +		timeout = ret;
> > > > +		goto wait_again;
> > > > +	}
> > > 
> > > And then I don't know if we'd really need the extra check here. Might as
> > > well just let the allocator try again and avoid the code?
> > > 
> > 
> > I was considering multiple processes been woken up and racing with each
> > other. I can drop this check though. The worst that happens is multiple
> > processes wake and walk the full zonelist. Some will succeed and others
> > will go back to sleep.
> 
> Yep. And it doesn't really solve that race either becuase the zone
> might subsequently go below the watermark.
> 

True. In theory, the same sort of races currently apply with
congestion_wait() but that's just an excuse. There is a strong
possibility we could behave better with respect to watermarks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
