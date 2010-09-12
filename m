Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AC82C6B004A
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:37:58 -0400 (EDT)
Received: by pvc30 with SMTP id 30so2070057pvc.14
        for <linux-mm@kvack.org>; Sun, 12 Sep 2010 08:37:56 -0700 (PDT)
Date: Mon, 13 Sep 2010 00:37:44 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
 no congested BDIs or significant writeback
Message-ID: <20100912153744.GA3563@barrios-desktop>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-4-git-send-email-mel@csn.ul.ie>
 <20100907152533.GB4620@barrios-desktop>
 <20100908110403.GB29263@csn.ul.ie>
 <20100908145245.GG4620@barrios-desktop>
 <20100909085436.GJ29263@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100909085436.GJ29263@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 09:54:36AM +0100, Mel Gorman wrote:
> On Wed, Sep 08, 2010 at 11:52:45PM +0900, Minchan Kim wrote:
> > On Wed, Sep 08, 2010 at 12:04:03PM +0100, Mel Gorman wrote:
> > > On Wed, Sep 08, 2010 at 12:25:33AM +0900, Minchan Kim wrote:
> > > > > + * @zone: A zone to consider the number of being being written back from
> > > > > + * @sync: SYNC or ASYNC IO
> > > > > + * @timeout: timeout in jiffies
> > > > > + *
> > > > > + * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> > > > > + * write congestion.  If no backing_devs are congested then the number of
> > > > > + * writeback pages in the zone are checked and compared to the inactive
> > > > > + * list. If there is no sigificant writeback or congestion, there is no point
> > > >                                                 and 
> > > > 
> > > 
> > > Why and? "or" makes sense because we avoid sleeping on either condition.
> > 
> > if (nr_bdi_congested[sync]) == 0) {
> >         if (writeback < inactive / 2) {
> >                 cond_resched();
> >                 ..
> >                 goto out
> >         }
> > }
> > 
> > for avoiding sleeping, above two condition should meet. 
> 
> This is a terrible comment that is badly written. Is this any clearer?
> 
> /**
>  * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a zone to complete writes
>  * @zone: A zone to consider the number of being being written back from
>  * @sync: SYNC or ASYNC IO
>  * @timeout: timeout in jiffies
>  *
>  * In the event of a congested backing_dev (any backing_dev) or a given @zone
>  * having a large number of pages in writeback, this waits for up to @timeout
>  * jiffies for either a BDI to exit congestion or a write to complete.
>  *
>  * If there is no congestion and few pending writes, then cond_resched()
>  * is called to yield the processor if necessary but otherwise does not
>  * sleep.
>  */

Looks good.

> 
> > > 
> > > > > + * in sleeping but cond_resched() is called in case the current process has
> > > > > + * consumed its CPU quota.
> > > > > + */
> > > > > +long wait_iff_congested(struct zone *zone, int sync, long timeout)
> > > > > +{
> > > > > +	long ret;
> > > > > +	unsigned long start = jiffies;
> > > > > +	DEFINE_WAIT(wait);
> > > > > +	wait_queue_head_t *wqh = &congestion_wqh[sync];
> > > > > +
> > > > > +	/*
> > > > > +	 * If there is no congestion, check the amount of writeback. If there
> > > > > +	 * is no significant writeback and no congestion, just cond_resched
> > > > > +	 */
> > > > > +	if (atomic_read(&nr_bdi_congested[sync]) == 0) {
> > > > > +		unsigned long inactive, writeback;
> > > > > +
> > > > > +		inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> > > > > +				zone_page_state(zone, NR_INACTIVE_ANON);
> > > > > +		writeback = zone_page_state(zone, NR_WRITEBACK);
> > > > > +
> > > > > +		/*
> > > > > +		 * If less than half the inactive list is being written back,
> > > > > +		 * reclaim might as well continue
> > > > > +		 */
> > > > > +		if (writeback < inactive / 2) {
> > > > 
> > > > I am not sure this is best.
> > > > 
> > > 
> > > I'm not saying it is. The objective is to identify a situation where
> > > sleeping until the next write or congestion clears is pointless. We have
> > > already identified that we are not congested so the question is "are we
> > > writing a lot at the moment?". The assumption is that if there is a lot
> > > of writing going on, we might as well sleep until one completes rather
> > > than reclaiming more.
> > > 
> > > This is the first effort at identifying pointless sleeps. Better ones
> > > might be identified in the future but that shouldn't stop us making a
> > > semi-sensible decision now.
> > 
> > nr_bdi_congested is no problem since we have used it for a long time.
> > But you added new rule about writeback. 
> > 
> 
> Yes, I'm trying to add a new rule about throttling in the page allocator
> and from vmscan. As you can see from the results in the leader, we are
> currently sleeping more than we need to.

I can see the about avoiding congestion_wait but can't find about 
(writeback < incative / 2) hueristic result. 

> 
> > Why I pointed out is that you added new rule and I hope let others know
> > this change since they have a good idea or any opinions. 
> > I think it's a one of roles as reviewer.
> > 
> 
> Of course.
> 
> > > 
> > > > 1. Without considering various speed class storage, could we fix it as half of inactive?
> > > 
> > > We don't really have a good means of identifying speed classes of
> > > storage. Worse, we are considering on a zone-basis here, not a BDI
> > > basis. The pages being written back in the zone could be backed by
> > > anything so we cannot make decisions based on BDI speed.
> > 
> > True. So it's why I have below question.
> > As you said, we don't have enough information in vmscan.
> > So I am not sure how effective such semi-sensible decision is. 
> > 
> 
> What additional metrics would you apply than the ones I used in the
> leader mail?

effectiveness of (writeback < inactive / 2) heuristic. 

> 
> > I think best is to throttle in page-writeback well. 
> 
> I do not think there is a problem as such in page writeback throttling.
> The problem is that we are going to sleep without any congestion or without
> writes in progress. We sleep for a full timeout in this case for no reason
> and this is what I'm trying to avoid.

Yes. I agree. 
Just my concern is heuristic accuarcy I mentioned.
In your previous verstion, you don't add the heuristic.
But suddenly you added it in this version. 
So I think you have any clue to add it in this version.
Please, write down cause and data if you have. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
