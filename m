Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 333746B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 17:25:02 -0400 (EDT)
Date: Wed, 8 Sep 2010 14:23:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
 no congested BDIs or significant writeback
Message-Id: <20100908142330.416056a1.akpm@linux-foundation.org>
In-Reply-To: <1283770053-18833-4-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Mon,  6 Sep 2010 11:47:26 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> If congestion_wait() is called with no BDIs congested, the caller will sleep
> for the full timeout and this may be an unnecessary sleep. This patch adds
> a wait_iff_congested() that checks congestion and only sleeps if a BDI is
> congested or if there is a significant amount of writeback going on in an
> interesting zone. Else, it calls cond_resched() to ensure the caller is
> not hogging the CPU longer than its quota but otherwise will not sleep.
> 
> This is aimed at reducing some of the major desktop stalls reported during
> IO. For example, while kswapd is operating, it calls congestion_wait()
> but it could just have been reclaiming clean page cache pages with no
> congestion. Without this patch, it would sleep for a full timeout but after
> this patch, it'll just call schedule() if it has been on the CPU too long.
> Similar logic applies to direct reclaimers that are not making enough
> progress.
> 

The patch series looks generally good.  Would like to see some testing
results ;)  A few touchups are planned so I'll await v2.

> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -724,6 +724,7 @@ static wait_queue_head_t congestion_wqh[2] = {
>  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
>  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
>  	};
> +static atomic_t nr_bdi_congested[2];

Let's remember that a queue can get congested because of reads as well
as writes.  It's very rare for this to happen - it needs either a
zillion read()ing threads or someone going berzerk with O_DIRECT aio,
etc.  Probably it doesn't matter much, but for memory reclaim purposes
read-congestion is somewhat irrelevant and a bit of thought is warranted.

vmscan currently only looks at *write* congestion, but in this patch
you secretly change that logic to newly look at write-or-read
congestion.  Talk to me.

>  void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
>  {
> @@ -731,7 +732,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
>  	wait_queue_head_t *wqh = &congestion_wqh[sync];
>  
>  	bit = sync ? BDI_sync_congested : BDI_async_congested;
> -	clear_bit(bit, &bdi->state);
> +	if (test_and_clear_bit(bit, &bdi->state))
> +		atomic_dec(&nr_bdi_congested[sync]);
>  	smp_mb__after_clear_bit();
>  	if (waitqueue_active(wqh))
>  		wake_up(wqh);

Worried.  Having a single slow disk getting itself gummed up will
affect the entire machine!

There's potential for pathological corner-case problems here.  "When I
do a big aio read from /dev/MySuckyUsbStick, all my CPUs get pegged in
page reclaim!".

What to do?

Of course, we'd very much prefer to know whether a queue which we're
interested in for writeback will block when we try to write to it. 
Much better than looking at all queues.

Important question: which of teh current congestion_wait() call sites
are causing appreciable stalls?

I think a more accurate way of implementing this is to be smarter with
the may_write_to_queue()->bdi_write_congested() result.  If a previous
attempt to write off this LRU encountered congestion then fine, call
congestion_wait().  But if writeback is not hitting
may_write_to_queue()->bdi_write_congested() then that is the time to
avoid calling congestion_wait().

In other words, save the bdi_write_congested() result in the zone
struct in some fashion and inspect that before deciding to synchronize
behind the underlying device's write rate.  Not hitting a congested
device for this LRU?  Then don't wait for congested devices.

> @@ -774,3 +777,62 @@ long congestion_wait(int sync, long timeout)
>  }
>  EXPORT_SYMBOL(congestion_wait);
>  
> +/**
> + * congestion_wait - wait for a backing_dev to become uncongested
> + * @zone: A zone to consider the number of being being written back from

That comments needs help.

> + * @sync: SYNC or ASYNC IO
> + * @timeout: timeout in jiffies
> + *
> + * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> + * write congestion.'

write or read congestion!!

>  If no backing_devs are congested then the number of
> + * writeback pages in the zone are checked and compared to the inactive
> + * list. If there is no sigificant writeback or congestion, there is no point
> + * in sleeping but cond_resched() is called in case the current process has
> + * consumed its CPU quota.
> + */

Document the return value?

> +long wait_iff_congested(struct zone *zone, int sync, long timeout)
> +{
> +	long ret;
> +	unsigned long start = jiffies;
> +	DEFINE_WAIT(wait);
> +	wait_queue_head_t *wqh = &congestion_wqh[sync];
> +
> +	/*
> +	 * If there is no congestion, check the amount of writeback. If there
> +	 * is no significant writeback and no congestion, just cond_resched
> +	 */
> +	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
> +		unsigned long inactive, writeback;
> +
> +		inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> +				zone_page_state(zone, NR_INACTIVE_ANON);
> +		writeback = zone_page_state(zone, NR_WRITEBACK);
> +
> +		/*
> +		 * If less than half the inactive list is being written back,
> +		 * reclaim might as well continue
> +		 */
> +		if (writeback < inactive / 2) {

This is all getting seriously inaccurate :(

> +			cond_resched();
> +
> +			/* In case we scheduled, work out time remaining */
> +			ret = timeout - (jiffies - start);
> +			if (ret < 0)
> +				ret = 0;
> +
> +			goto out;
> +		}
> +	}
> +
> +	/* Sleep until uncongested or a write happens */
> +	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> +	ret = io_schedule_timeout(timeout);
> +	finish_wait(wqh, &wait);
> +
> +out:
> +	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
> +					jiffies_to_usecs(jiffies - start));

Does this tracepoint tell us how often wait_iff_congested() is sleeping
versus how often it is returning immediately?

> +	return ret;
> +}
> +EXPORT_SYMBOL(wait_iff_congested);
>
> ...
>
> @@ -1913,10 +1913,28 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  			sc->may_writepage = 1;
>  		}
>  
> -		/* Take a nap, wait for some writeback to complete */
> +		/* Take a nap if congested, wait for some writeback */
>  		if (!sc->hibernation_mode && sc->nr_scanned &&
> -		    priority < DEF_PRIORITY - 2)
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		    priority < DEF_PRIORITY - 2) {
> +			struct zone *active_zone = NULL;
> +			unsigned long max_writeback = 0;
> +			for_each_zone_zonelist(zone, z, zonelist,
> +					gfp_zone(sc->gfp_mask)) {
> +				unsigned long writeback;
> +
> +				/* Initialise for first zone */
> +				if (active_zone == NULL)
> +					active_zone = zone;
> +
> +				writeback = zone_page_state(zone, NR_WRITEBACK);
> +				if (writeback > max_writeback) {
> +					max_writeback = writeback;
> +					active_zone = zone;
> +				}
> +			}
> +
> +			wait_iff_congested(active_zone, BLK_RW_ASYNC, HZ/10);
> +		}

Again, we would benefit from more accuracy here.  In my above
suggestion I'm assuming that the (congestion) result of the most recent
attempt to perform writeback is a predictor of the next attempt.

Doing that on a kernel-wide basis would be rather inaccurate on large
machines in some scenarios.  Storing the state info in the zone would
help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
