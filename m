Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 22B9E6B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 05:13:36 -0400 (EDT)
Date: Fri, 23 Oct 2009 10:13:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
	high-order watermarks are hit
Message-ID: <20091023091334.GV11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 12:41:42PM -0700, David Rientjes wrote:
> On Thu, 22 Oct 2009, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 7f2aa3e..851df40 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1596,6 +1596,17 @@ try_next_zone:
> >  	return page;
> >  }
> >  
> > +static inline
> > +void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> > +						enum zone_type high_zoneidx)
> > +{
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +
> > +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > +		wakeup_kswapd(zone, order);
> > +}
> > +
> >  static inline int
> >  should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> >  				unsigned long pages_reclaimed)
> > @@ -1730,18 +1741,18 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
> >  			congestion_wait(BLK_RW_ASYNC, HZ/50);
> >  	} while (!page && (gfp_mask & __GFP_NOFAIL));
> >  
> > -	return page;
> > -}
> > -
> > -static inline
> > -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> > -						enum zone_type high_zoneidx)
> > -{
> > -	struct zoneref *z;
> > -	struct zone *zone;
> > +	/*
> > +	 * If after a high-order allocation we are now below watermarks,
> > +	 * pre-emptively kick kswapd rather than having the next allocation
> > +	 * fail and have to wake up kswapd, potentially failing GFP_ATOMIC
> > +	 * allocations or entering direct reclaim
> > +	 */
> > +	if (unlikely(order) && page && !zone_watermark_ok(preferred_zone, order,
> > +				preferred_zone->watermark[ALLOC_WMARK_LOW],
> > +				zone_idx(preferred_zone), ALLOC_WMARK_LOW))
> > +		wake_all_kswapd(order, zonelist, high_zoneidx);
> >  
> > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > -		wakeup_kswapd(zone, order);
> > +	return page;
> >  }
> >  
> >  static inline int
> 
> Hmm, is this really supposed to be added to __alloc_pages_high_priority()?  
> By the patch description I was expecting kswapd to be woken up 
> preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and 
> we're known to have just allocated at a higher order, not just when 
> current was oom killed (when we should already be freeing a _lot_ of 
> memory soon) or is doing a higher order allocation during direct reclaim.
> 

It was a somewhat arbitrary choice to have it trigger in the event high
priority allocations were happening frequently.

> For the best coverage, it would have to be add the branch to the fastpath.  

Agreed - specifically at the end of __alloc_pages_nodemask()

> That seems fine for a debugging aid and to see if progress is being made 
> on the GFP_ATOMIC allocation issues, but doesn't seem like it should make 
> its way to mainline, the subsequent GFP_ATOMIC allocation could already be 
> happening and in the page allocator's slowpath at this point that this 
> wakeup becomes unnecessary.
> 
> If this is moved to the fastpath, why is this wake_all_kswapd() and not
> wakeup_kswapd(preferred_zone, order)?  Do we need to kick kswapd in all 
> zones even though they may be free just because preferred_zone is now 
> below the watermark?
> 

It probably makes no difference as zones are checked for their watermarks
before any real work happens. However, even if this patch makes a difference,
I don't want to see it merged.  At best, it is an extremely heavy-handed
hack which is why I asked for it to be tested in isolation. It shouldn't
be necessary at all because sort of pre-emptive waking of kswapd was never
necessary before.

> Wouldn't it be better to do this on page_zone(page) instead of 
> preferred_zone anyway?
> 

No. The preferred_zone is the zone we should be allocating from. If we
failed to allocate from it, it implies the watermarks are not being met
so we want to wake it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
