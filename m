Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 344CA6B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 14:14:56 -0400 (EDT)
Date: Sun, 5 Sep 2010 19:14:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
	direct reclaim allocation fails
Message-ID: <20100905181443.GG8384@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie> <20100903160026.564fdcc9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100903160026.564fdcc9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 04:00:26PM -0700, Andrew Morton wrote:
> On Fri,  3 Sep 2010 10:08:46 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When under significant memory pressure, a process enters direct reclaim
> > and immediately afterwards tries to allocate a page. If it fails and no
> > further progress is made, it's possible the system will go OOM. However,
> > on systems with large amounts of memory, it's possible that a significant
> > number of pages are on per-cpu lists and inaccessible to the calling
> > process. This leads to a process entering direct reclaim more often than
> > it should increasing the pressure on the system and compounding the problem.
> > 
> > This patch notes that if direct reclaim is making progress but
> > allocations are still failing that the system is already under heavy
> > pressure. In this case, it drains the per-cpu lists and tries the
> > allocation a second time before continuing.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Reviewed-by: Christoph Lameter <cl@linux.com>
> > ---
> >  mm/page_alloc.c |   20 ++++++++++++++++----
> >  1 files changed, 16 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bbaa959..750e1dc 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1847,6 +1847,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  	struct page *page = NULL;
> >  	struct reclaim_state reclaim_state;
> >  	struct task_struct *p = current;
> > +	bool drained = false;
> >  
> >  	cond_resched();
> >  
> > @@ -1865,14 +1866,25 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  
> >  	cond_resched();
> >  
> > -	if (order != 0)
> > -		drain_all_pages();
> > +	if (unlikely(!(*did_some_progress)))
> > +		return NULL;
> >  
> > -	if (likely(*did_some_progress))
> > -		page = get_page_from_freelist(gfp_mask, nodemask, order,
> > +retry:
> > +	page = get_page_from_freelist(gfp_mask, nodemask, order,
> >  					zonelist, high_zoneidx,
> >  					alloc_flags, preferred_zone,
> >  					migratetype);
> > +
> > +	/*
> > +	 * If an allocation failed after direct reclaim, it could be because
> > +	 * pages are pinned on the per-cpu lists. Drain them and try again
> > +	 */
> > +	if (!page && !drained) {
> > +		drain_all_pages();
> > +		drained = true;
> > +		goto retry;
> > +	}
> > +
> >  	return page;
> >  }
> 
> The patch looks reasonable.
> 
> But please take a look at the recent thread "mm: minute-long livelocks
> in memory reclaim".  There, people are pointing fingers at that
> drain_all_pages() call, suspecting that it's causing huge IPI storms.
> 

I'm aware of it.

> Dave was going to test this theory but afaik hasn't yet done so.  It
> would be nice to tie these threads together if poss?
> 

I was waiting to hear the results of the test. Certainly it seemed very
plausible that this patch would help it. I also have a hunch that the
congestion_wait() problems are cropping up. I have a revised patch
series that might close the rest of the problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
