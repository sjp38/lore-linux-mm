Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21B966B0083
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 04:59:09 -0400 (EDT)
Date: Thu, 9 Sep 2010 09:58:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
	no congested BDIs or significant writeback
Message-ID: <20100909085853.GK29263@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-4-git-send-email-mel@csn.ul.ie> <20100909120231.fe6d3078.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100909120231.fe6d3078.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 12:02:31PM +0900, KAMEZAWA Hiroyuki wrote:
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
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/backing-dev.h      |    2 +-
> >  include/trace/events/writeback.h |    7 ++++
> >  mm/backing-dev.c                 |   66 ++++++++++++++++++++++++++++++++++++-
> >  mm/page_alloc.c                  |    4 +-
> >  mm/vmscan.c                      |   26 ++++++++++++--
> >  5 files changed, 96 insertions(+), 9 deletions(-)
> > 
> > diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> > index 35b0074..f1b402a 100644
> > --- a/include/linux/backing-dev.h
> > +++ b/include/linux/backing-dev.h
> > @@ -285,7 +285,7 @@ enum {
> >  void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
> >  void set_bdi_congested(struct backing_dev_info *bdi, int sync);
> >  long congestion_wait(int sync, long timeout);
> > -
> > +long wait_iff_congested(struct zone *zone, int sync, long timeout);
> >  
> >  static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
> >  {
> > diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
> > index 275d477..eeaf1f5 100644
> > --- a/include/trace/events/writeback.h
> > +++ b/include/trace/events/writeback.h
> > @@ -181,6 +181,13 @@ DEFINE_EVENT(writeback_congest_waited_template, writeback_congestion_wait,
> >  	TP_ARGS(usec_timeout, usec_delayed)
> >  );
> >  
> > +DEFINE_EVENT(writeback_congest_waited_template, writeback_wait_iff_congested,
> > +
> > +	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
> > +
> > +	TP_ARGS(usec_timeout, usec_delayed)
> > +);
> > +
> >  #endif /* _TRACE_WRITEBACK_H */
> >  
> >  /* This part must be outside protection */
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 298975a..94b5433 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -724,6 +724,7 @@ static wait_queue_head_t congestion_wqh[2] = {
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
> >  	};
> > +static atomic_t nr_bdi_congested[2];
> >  
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
> > @@ -743,7 +745,8 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
> >  	enum bdi_state bit;
> >  
> >  	bit = sync ? BDI_sync_congested : BDI_async_congested;
> > -	set_bit(bit, &bdi->state);
> > +	if (!test_and_set_bit(bit, &bdi->state))
> > +		atomic_inc(&nr_bdi_congested[sync]);
> >  }
> >  EXPORT_SYMBOL(set_bdi_congested);
> >  
> > @@ -774,3 +777,62 @@ long congestion_wait(int sync, long timeout)
> >  }
> >  EXPORT_SYMBOL(congestion_wait);
> >  
> > +/**
> > + * congestion_wait - wait for a backing_dev to become uncongested
> > + * @zone: A zone to consider the number of being being written back from
> > + * @sync: SYNC or ASYNC IO
> > + * @timeout: timeout in jiffies
> > + *
> > + * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
> > + * write congestion.  If no backing_devs are congested then the number of
> > + * writeback pages in the zone are checked and compared to the inactive
> > + * list. If there is no sigificant writeback or congestion, there is no point
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
> Hmm..can't we have a way that "find a page which can be just dropped without writeback"
> rather than sleeping ?

Sure, just scan for clean pages but then younger clean pages would be reclaimed
before old dirty pages because we were not waiting on writeback. It's a
significant change.

> I think we can throttole the number of victims for avoidng I/O
> congestion as pages/tick....if exhausted, ok, we should sleep.
> 

I think it would be tricky to throttle based on time effectively. I find
it easier to think about throttling in terms of congested device, number
of dirty pages in a zone or number of pages currently being written back
because these are events that can prevent reclaim taking place.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
