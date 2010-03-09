Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8DD6B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 08:35:25 -0500 (EST)
Date: Wed, 10 Mar 2010 00:35:13 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
 pressure to relieve instead of congestion
Message-ID: <20100309133513.GL8653@laptop>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
 <1268048904-19397-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1268048904-19397-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 08, 2010 at 11:48:21AM +0000, Mel Gorman wrote:
> Under heavy memory pressure, the page allocator may call congestion_wait()
> to wait for IO congestion to clear or a timeout. This is not as sensible
> a choice as it first appears. There is no guarantee that BLK_RW_ASYNC is
> even congested as the pressure could have been due to a large number of
> SYNC reads and the allocator waits for the entire timeout, possibly uselessly.
> 
> At the point of congestion_wait(), the allocator is struggling to get the
> pages it needs and it should back off. This patch puts the allocator to sleep
> on a zone->pressure_wq for either a timeout or until a direct reclaimer or
> kswapd brings the zone over the low watermark, whichever happens first.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h |    3 ++
>  mm/internal.h          |    4 +++
>  mm/mmzone.c            |   47 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c        |   50 +++++++++++++++++++++++++++++++++++++++++++----
>  mm/vmscan.c            |    2 +
>  5 files changed, 101 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 30fe668..72465c1 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -398,6 +398,9 @@ struct zone {
>  	unsigned long		wait_table_hash_nr_entries;
>  	unsigned long		wait_table_bits;
>  
> +	/* queue for processes waiting for pressure to relieve */
> +	wait_queue_head_t	*pressure_wq;

Hmm, processes may be eligible to allocate from > 1 zone, but you
have them only waiting for one. I wonder if we shouldn't wait for
more zones?

Congestion waiting uses a global waitqueue, which hasn't seemed to
cause a big scalability problem. Would it be better to have a global
waitqueue for this too?


> +void check_zone_pressure(struct zone *zone)

I don't really like the name pressure. We use that term for the reclaim
pressure wheras we're just checking watermarks here (actual pressure
could be anything).


> +{
> +	/* If no process is waiting, nothing to do */
> +	if (!waitqueue_active(zone->pressure_wq))
> +		return;
> +
> +	/* Check if the high watermark is ok for order 0 */
> +	if (zone_watermark_ok(zone, 0, low_wmark_pages(zone), 0, 0))
> +		wake_up_interruptible(zone->pressure_wq);
> +}

If you were to do this under the zone lock (in your subsequent patch),
then it could avoid races. I would suggest doing it all as a single
patch and not doing the pressure checks in reclaim at all.

If you are missing anything, then that needs to be explained and fixed
rather than just adding extra checks.

> +
> +/**
> + * zonepressure_wait - Wait for pressure on a zone to ease off
> + * @zone: The zone that is expected to be under pressure
> + * @order: The order the caller is waiting on pages for
> + * @timeout: Wait until pressure is relieved or this timeout is reached
> + *
> + * Waits for up to @timeout jiffies for pressure on a zone to be relieved.
> + * It's considered to be relieved if any direct reclaimer or kswapd brings
> + * the zone above the high watermark
> + */
> +long zonepressure_wait(struct zone *zone, unsigned int order, long timeout)
> +{
> +	long ret;
> +	DEFINE_WAIT(wait);
> +
> +wait_again:
> +	prepare_to_wait(zone->pressure_wq, &wait, TASK_INTERRUPTIBLE);

I guess to do it without races you need to check watermark here.
And possibly some barriers if it is done without zone->lock.

> +
> +	/*
> +	 * The use of io_schedule_timeout() here means that it gets
> +	 * accounted for as IO waiting. This may or may not be the case
> +	 * but at least this way it gets picked up by vmstat
> +	 */
> +	ret = io_schedule_timeout(timeout);
> +	finish_wait(zone->pressure_wq, &wait);
> +
> +	/* If woken early, check watermarks before continuing */
> +	if (ret && !zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0)) {
> +		timeout = ret;
> +		goto wait_again;
> +	}

And then I don't know if we'd really need the extra check here. Might as
well just let the allocator try again and avoid the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
