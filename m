Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 157006B0047
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 07:04:21 -0400 (EDT)
Date: Wed, 8 Sep 2010 12:04:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
	no congested BDIs or significant writeback
Message-ID: <20100908110403.GB29263@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-4-git-send-email-mel@csn.ul.ie> <20100907152533.GB4620@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100907152533.GB4620@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 12:25:33AM +0900, Minchan Kim wrote:
> On Mon, Sep 06, 2010 at 11:47:26AM +0100, Mel Gorman wrote:
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
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> > <SNIP>
> > +/**
> > + * congestion_wait - wait for a backing_dev to become uncongested
>       wait_iff_congested
> 

Fixed, thanks.

> > + * @zone: A zone to consider the number of being being written back from
> > + * @sync: SYNC or ASYNC IO
> > + * @timeout: timeout in jiffies
> > + *
> > + * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> > + * write congestion.  If no backing_devs are congested then the number of
> > + * writeback pages in the zone are checked and compared to the inactive
> > + * list. If there is no sigificant writeback or congestion, there is no point
>                                                 and 
> 

Why and? "or" makes sense because we avoid sleeping on either condition.

> > + * in sleeping but cond_resched() is called in case the current process has
> > + * consumed its CPU quota.
> > + */
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
> I am not sure this is best.
> 

I'm not saying it is. The objective is to identify a situation where
sleeping until the next write or congestion clears is pointless. We have
already identified that we are not congested so the question is "are we
writing a lot at the moment?". The assumption is that if there is a lot
of writing going on, we might as well sleep until one completes rather
than reclaiming more.

This is the first effort at identifying pointless sleeps. Better ones
might be identified in the future but that shouldn't stop us making a
semi-sensible decision now.

> 1. Without considering various speed class storage, could we fix it as half of inactive?

We don't really have a good means of identifying speed classes of
storage. Worse, we are considering on a zone-basis here, not a BDI
basis. The pages being written back in the zone could be backed by
anything so we cannot make decisions based on BDI speed.

> 2. Isn't there any writeback throttling on above layer? Do we care of it in here?
> 

There are but congestion_wait() and now wait_iff_congested() are part of
that. We can see from the figures in the leader that congestion_wait()
is sleeping more than is necessary or smart.

> Just out of curiosity. 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
