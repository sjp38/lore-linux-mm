Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 877656B007D
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:11:47 -0400 (EDT)
Received: by pvc30 with SMTP id 30so451005pvc.14
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 07:11:56 -0700 (PDT)
Date: Thu, 16 Sep 2010 23:11:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
 there are no congested BDIs or if significant congestion is not being
 encountered in the current zone
Message-ID: <20100916141147.GC16115@barrios-desktop>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
 <1284553671-31574-9-git-send-email-mel@csn.ul.ie>
 <20100916081338.GB16115@barrios-desktop>
 <20100916091824.GB15709@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916091824.GB15709@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 10:18:24AM +0100, Mel Gorman wrote:
> On Thu, Sep 16, 2010 at 05:13:38PM +0900, Minchan Kim wrote:
> > On Wed, Sep 15, 2010 at 01:27:51PM +0100, Mel Gorman wrote:
> > > If wait_iff_congested() is called with no BDI congested, the function simply
> > > calls cond_resched(). In the event there is significant writeback happening
> > > in the zone that is being reclaimed, this can be a poor decision as reclaim
> > > would succeed once writeback was completed. Without any backoff logic,
> > > younger clean pages can be reclaimed resulting in more reclaim overall and
> > > poor performance.
> > 
> > I agree. 
> > 
> > > 
> > > This patch tracks how many pages backed by a congested BDI were found during
> > > scanning. If all the dirty pages encountered on a list isolated from the
> > > LRU belong to a congested BDI, the zone is marked congested until the zone
> > 
> > I am not sure it works well. 
> 
> Check the competion times for the micro-mapped-file-stream benchmark in
> the leader mail. Backing off like this is faster overall for some
> workloads.
> 
> > We just met the condition once but we backoff it until high watermark.
> 
> Reaching the high watermark is considered to be a relieving of pressure.
> 
> > (ex, 32 isolated dirty pages == 32 pages on congestioned bdi)
> > First impression is rather _aggressive_.
> > 
> 
> Yes, it is. I intended to start with something quite aggressive that is
> close to existing behaviour and then experiment with alternatives.

Agree. 

> 
> For example, I considered clearing zone congestion when but nr_bdi_congested
> drops to 0. This would be less aggressive in terms of congestion waiting but
> it is further from todays behaviour. I felt it would be best to introduce
> wait_iff_congested() in one kernel cycle but wait to a later cycle to deviate
> a lot from congestion_wait().

Fair enough. 

> 
> > How about more checking?
> > For example, if above pattern continues repeately above some threshold,
> > we can regard "zone is congested" and then if the pattern isn't repeated 
> > during some threshold, we can regard "zone isn't congested any more.".
> > 
> 
> I also considered these options and got stuck at what the "some
> threshold" is and how to record the history. Should it be recorded on a
> per BDI basis for example? I think all these questions can be answered
> but should be in a different cycle.
> 
> > > reaches the high watermark.  wait_iff_congested() then checks both the
> > > number of congested BDIs and if the current zone is one that has encounted
> > > congestion recently, it will sleep on the congestion queue. Otherwise it
> > > will call cond_reched() to yield the processor if necessary.
> > > 
> > > The end result is that waiting on the congestion queue is avoided when
> > > necessary but when significant congestion is being encountered,
> > > reclaimers and page allocators will back off.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > ---
> > >  include/linux/backing-dev.h |    2 +-
> > >  include/linux/mmzone.h      |    8 ++++
> > >  mm/backing-dev.c            |   23 ++++++++----
> > >  mm/page_alloc.c             |    4 +-
> > >  mm/vmscan.c                 |   83 +++++++++++++++++++++++++++++++++++++------
> > >  5 files changed, 98 insertions(+), 22 deletions(-)
> > > 
> > > diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> > > index 72bb510..f1b402a 100644
> > > --- a/include/linux/backing-dev.h
> > > +++ b/include/linux/backing-dev.h
> > > +static enum bdi_queue_status may_write_to_queue(struct backing_dev_info *bdi,
> > 
> > <snip>
> > 
> > >  			      struct scan_control *sc)
> > >  {
> > > +	enum bdi_queue_status ret = QUEUEWRITE_DENIED;
> > > +
> > >  	if (current->flags & PF_SWAPWRITE)
> > > -		return 1;
> > > +		return QUEUEWRITE_ALLOWED;
> > >  	if (!bdi_write_congested(bdi))
> > > -		return 1;
> > > +		return QUEUEWRITE_ALLOWED;
> > > +	else
> > > +		ret = QUEUEWRITE_CONGESTED;
> > >  	if (bdi == current->backing_dev_info)
> > > -		return 1;
> > > +		return QUEUEWRITE_ALLOWED;
> > >  
> > >  	/* lumpy reclaim for hugepage often need a lot of write */
> > >  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> > > -		return 1;
> > > -	return 0;
> > > +		return QUEUEWRITE_ALLOWED;
> > > +	return ret;
> > >  }
> > 
> > The function can't return QUEUEXXX_DENIED.
> > It can affect disable_lumpy_reclaim. 
> > 
> 
> Yes, but that change was made in "vmscan: Narrow the scenarios lumpy
> reclaim uses synchrounous reclaim". Maybe I am misunderstanding your
> objection.

I means current may_write_to_queue never returns QUEUEWRITE_DENIED.
What's the role of it?

In addition, we don't need disable_lumpy_reclaim_mode() in pageout.
That's because both PAGE_KEEP and PAGE_KEEP_CONGESTED go to keep_locked
and calls disable_lumpy_reclaim_mode at last. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
