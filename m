Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 25CB76B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 06:43:25 -0400 (EDT)
Date: Thu, 9 Sep 2010 11:43:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
	no congested BDIs or significant writeback
Message-ID: <20100909104307.GN29263@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-4-git-send-email-mel@csn.ul.ie> <20100908142330.416056a1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100908142330.416056a1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 02:23:30PM -0700, Andrew Morton wrote:
> On Mon,  6 Sep 2010 11:47:26 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > If congestion_wait() is called with no BDIs congested, the caller will sleep
> > for the full timeout and this may be an unnecessary sleep. This patch adds
> > a wait_iff_congested() that checks congestion and only sleeps if a BDI is
> > congested or if there is a significant amount of writeback going on in an
> > interesting zone. Else, it calls cond_resched() to ensure the caller is
> > not hogging the CPU longer than its quota but otherwise will not sleep.
> > 
> > This is aimed at reducing some of the major desktop stalls reported during
> > IO. For example, while kswapd is operating, it calls congestion_wait()
> > but it could just have been reclaiming clean page cache pages with no
> > congestion. Without this patch, it would sleep for a full timeout but after
> > this patch, it'll just call schedule() if it has been on the CPU too long.
> > Similar logic applies to direct reclaimers that are not making enough
> > progress.
> > 
> 
> The patch series looks generally good.  Would like to see some testing
> results ;) 

They are all in the leader. They are all based on a test-suite that I'm
bound to stick a README on and release one of these days :/

> A few touchups are planned so I'll await v2.
> 

Good plan.

> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -724,6 +724,7 @@ static wait_queue_head_t congestion_wqh[2] = {
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
> >  	};
> > +static atomic_t nr_bdi_congested[2];
> 
> Let's remember that a queue can get congested because of reads as well
> as writes.  It's very rare for this to happen - it needs either a
> zillion read()ing threads or someone going berzerk with O_DIRECT aio,
> etc.  Probably it doesn't matter much, but for memory reclaim purposes
> read-congestion is somewhat irrelevant and a bit of thought is warranted.
> 

This is an interesting point and would be well worth digging into if
we got a new bug report about stalls under heavy reads.

> vmscan currently only looks at *write* congestion, but in this patch
> you secretly change that logic to newly look at write-or-read
> congestion.  Talk to me.
> 

vmscan currently only looks at write congestion because it's checking the
BLK_RW_ASYNC and all reads will be BLK_RW_SYNC. Currently, this is why we
are only looking at write congestion even though it's approximate, right?

Remember, congestion_wait used to be about READ and WRITE but now it's about
SYNC and ASYNC.

In the patch, there are separate SYNC and ASYNC nr_bdi_congested counters.
wait_iff_congested() is only called for BLK_RW_ASYNC so we still checking
write congestion only.

What stupid thing did I miss?

> >  void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> >  {
> > @@ -731,7 +732,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> >  	wait_queue_head_t *wqh = &congestion_wqh[sync];
> >  
> >  	bit = sync ? BDI_sync_congested : BDI_async_congested;
> > -	clear_bit(bit, &bdi->state);
> > +	if (test_and_clear_bit(bit, &bdi->state))
> > +		atomic_dec(&nr_bdi_congested[sync]);
> >  	smp_mb__after_clear_bit();
> >  	if (waitqueue_active(wqh))
> >  		wake_up(wqh);
> 
> Worried.  Having a single slow disk getting itself gummed up will
> affect the entire machine!
> 

This can already happen today. In fact, I think it's one of the sources of
desktop stalls during IO from https://bugzilla.kernel.org/show_bug.cgi?id=12309
that you brought up a few weeks back. I was tempted to try resolve it in
this patch but thought I was reaching far enough with this series as it was.

> There's potential for pathological corner-case problems here.  "When I
> do a big aio read from /dev/MySuckyUsbStick, all my CPUs get pegged in
> page reclaim!".
> 

I thought it might be enough to just do a huge backup to an external USB
drive. I guess I could make it worse by starting up one copy per CPU
thread preferably to more than one slow USB device.

> What to do?
> 
> Of course, we'd very much prefer to know whether a queue which we're
> interested in for writeback will block when we try to write to it. 
> Much better than looking at all queues.
> 

And somehow reconciling the queue being written to with the zone the pages
are coming from.

> Important question: which of teh current congestion_wait() call sites
> are causing appreciable stalls?
> 

This potentially can be found out from the tracepoints if they record
the stack trace as well. In this patch, I avoided changing all callers to
congestion_wait() and changed a few callers to wait_iff_congested() instead
to limit the scope of what was being changed in this cycle.

> I think a more accurate way of implementing this is to be smarter with
> the may_write_to_queue()->bdi_write_congested() result.  If a previous
> attempt to write off this LRU encountered congestion then fine, call
> congestion_wait().  But if writeback is not hitting
> may_write_to_queue()->bdi_write_congested() then that is the time to
> avoid calling congestion_wait().
> 

I see the logic. If we assume that there is large amounts of anon page
reclaim while writeback is happening to a USB device for example, we would
avoid a stall in this case. It would still encounter a problem if all the
reclaim is from the file LRU and there are a few pages being written to a
USB stick. We'll still wait on congestion even though it might not have been
necessary and it's why I was counting the number of writeback pages versus
the size of the inactive queue and making a decision based on that.


> In other words, save the bdi_write_congested() result in the zone
> struct in some fashion and inspect that before deciding to synchronize
> behind the underlying device's write rate.  Not hitting a congested
> device for this LRU?  Then don't wait for congested devices.
> 

I think the idea has potential. It will take a fair amount of time to work
out the details though. Testing tends to take a *long* time even with
automation.

> > @@ -774,3 +777,62 @@ long congestion_wait(int sync, long timeout)
> >  }
> >  EXPORT_SYMBOL(congestion_wait);
> >  
> > +/**
> > + * congestion_wait - wait for a backing_dev to become uncongested
> > + * @zone: A zone to consider the number of being being written back from
> 
> That comments needs help.
> 

Indeed it does. It currently stands as

/**
 * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a zone to complete writes
 * @zone: A zone to consider the number of being being written back from
 * @sync: SYNC or ASYNC IO
 * @timeout: timeout in jiffies
 *
 * In the event of a congested backing_dev (any backing_dev) or a given zone
 * having a large number of pages in writeback, this waits for up to @timeout
 * jiffies for either a BDI to exit congestion of the given @sync queue.
 *
 * If there is no congestion and few pending writes, then cond_resched()
 * is called to yield the processor if necessary but otherwise does not
 * sleep.

 * The return value is 0 if the sleep is for the full timeout. Otherwise,
 * it is the number of jiffies that were still remaining when the function
 * returned. return_value == timeout implies the function did not sleep.
 */

> > + * @sync: SYNC or ASYNC IO
> > + * @timeout: timeout in jiffies
> > + *
> > + * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> > + * write congestion.'
> 
> write or read congestion!!
> 

I just know I'm going to spot where we wait on read congestion the
second I push send and make a fool of myself :(

> >  If no backing_devs are congested then the number of
> > + * writeback pages in the zone are checked and compared to the inactive
> > + * list. If there is no sigificant writeback or congestion, there is no point
> > + * in sleeping but cond_resched() is called in case the current process has
> > + * consumed its CPU quota.
> > + */
> 
> Document the return value?
> 

What's the fun in that? :)

I included a blurb on the return value in the updated comment above.

> > +long wait_iff_congested(struct zone *zone, int sync, long timeout)
> > +{
> > +	long ret;
> > +	unsigned long start = jiffies;
> > +	DEFINE_WAIT(wait);
> > +	wait_queue_head_t *wqh = &congestion_wqh[sync];
> > +
> > +	/*
> > +	 * If there is no congestion, check the amount of writeback. If there
> > +	 * is no significant writeback and no congestion, just cond_resched
> > +	 */
> > +	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
> > +		unsigned long inactive, writeback;
> > +
> > +		inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> > +				zone_page_state(zone, NR_INACTIVE_ANON);
> > +		writeback = zone_page_state(zone, NR_WRITEBACK);
> > +
> > +		/*
> > +		 * If less than half the inactive list is being written back,
> > +		 * reclaim might as well continue
> > +		 */
> > +		if (writeback < inactive / 2) {
> 
> This is all getting seriously inaccurate :(
> 

We are already woefully inaccurate.

The intention here is to catch where we are not congested but that there
is sufficient writeback in the zone to make it worthwhile waiting for
some of it to complete. Minimally, we have a reasonable expectation that
if writeback is happening that we'll be woken up if we go to sleep on
the congestion queue.

i.e. it's not great but it's better than what we have at the moment which
can be seen from the micro-mapped-file-stream results in the leader. Time to
completion is reduced, sleepy time is reduced while the ratio of scans/writes
does not get worse.


> > +			cond_resched();
> > +
> > +			/* In case we scheduled, work out time remaining */
> > +			ret = timeout - (jiffies - start);
> > +			if (ret < 0)
> > +				ret = 0;
> > +
> > +			goto out;
> > +		}
> > +	}
> > +
> > +	/* Sleep until uncongested or a write happens */
> > +	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> > +	ret = io_schedule_timeout(timeout);
> > +	finish_wait(wqh, &wait);
> > +
> > +out:
> > +	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
> > +					jiffies_to_usecs(jiffies - start));
> 
> Does this tracepoint tell us how often wait_iff_congested() is sleeping
> versus how often it is returning immediately?
> 

Yes. Taking an example from the leader

FTrace Reclaim Statistics: congestion_wait
                                    traceonly-v1r5 nocongest-v1r5 lowlumpy-v1r5     nodirect-v1r5
Direct number congest     waited               499          0          0          0
Direct time   congest     waited           22700ms        0ms        0ms        0ms
Direct full   congest     waited               421          0          0          0
Direct number conditional waited                 0       1214       1242       1290
Direct time   conditional waited               0ms        4ms        0ms        0ms
Direct full   conditional waited               421          0          0          0
KSwapd number congest     waited               257        103         94        104
KSwapd time   congest     waited           22116ms     7344ms     7476ms     7528ms
KSwapd full   congest     waited               203         57         59         56
KSwapd number conditional waited                 0          0          0          0
KSwapd time   conditional waited               0ms        0ms        0ms        0ms
KSwapd full   conditional waited               203         57         59         56

A "full congest waited" is a count of the number of times we slept for
more than the timeout. The trace-only kernel reports that direct reclaimers
slept the full timeout 421 times and kswapd slept for the full timeout 203
times. The patch (nocongest-v1r5) reduces these counts significantly.

The report is from a script that reads ftrace information. It's similar in
operation to what's in Documentation/trace/postprocess/.

> > +	return ret;
> > +}
> > +EXPORT_SYMBOL(wait_iff_congested);
> >
> > ...
> >
> > @@ -1913,10 +1913,28 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >  			sc->may_writepage = 1;
> >  		}
> >  
> > -		/* Take a nap, wait for some writeback to complete */
> > +		/* Take a nap if congested, wait for some writeback */
> >  		if (!sc->hibernation_mode && sc->nr_scanned &&
> > -		    priority < DEF_PRIORITY - 2)
> > -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +		    priority < DEF_PRIORITY - 2) {
> > +			struct zone *active_zone = NULL;
> > +			unsigned long max_writeback = 0;
> > +			for_each_zone_zonelist(zone, z, zonelist,
> > +					gfp_zone(sc->gfp_mask)) {
> > +				unsigned long writeback;
> > +
> > +				/* Initialise for first zone */
> > +				if (active_zone == NULL)
> > +					active_zone = zone;
> > +
> > +				writeback = zone_page_state(zone, NR_WRITEBACK);
> > +				if (writeback > max_writeback) {
> > +					max_writeback = writeback;
> > +					active_zone = zone;
> > +				}
> > +			}
> > +
> > +			wait_iff_congested(active_zone, BLK_RW_ASYNC, HZ/10);
> > +		}
> 
> Again, we would benefit from more accuracy here.  In my above
> suggestion I'm assuming that the (congestion) result of the most recent
> attempt to perform writeback is a predictor of the next attempt.
> 

I suspect you are on to something but it will take me some time to work out
the details and to build a setup involving a few USB sticks to trigger that
test case. What are the possibilities of starting with this heuristic (in
release v2 or v3 of this series) because it improves on what we have today and
then trying out different ideas for how and when to call wait_iff_congested()
in the next cycle?

> Doing that on a kernel-wide basis would be rather inaccurate on large
> machines in some scenarios.  Storing the state info in the zone would
> help.
> 

We are already depending on kernel-wide inaccuracy. The series aims to chip
away at some of the obvious badness to start with.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
