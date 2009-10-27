Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EAAF46B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:26:55 -0400 (EDT)
Date: Tue, 27 Oct 2009 15:26:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
	high-order watermarks are hit
Message-ID: <20091027152650.GJ8900@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie> <20091026235032.2F78.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091026235032.2F78.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 11:42:58AM +0900, KOSAKI Motohiro wrote:
> > When a high-order allocation fails, kswapd is kicked so that it reclaims
> > at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> > allocations. Something has changed in recent kernels that affect the timing
> > where high-order GFP_ATOMIC allocations are now failing with more frequency,
> > particularly under pressure.
> > 
> > This patch pre-emptively checks if watermarks have been hit after a
> > high-order allocation completes successfully. If the watermarks have been
> > reached, kswapd is woken in the hope it fixes the watermarks before the
> > next GFP_ATOMIC allocation fails.
> > 
> > Warning, this patch is somewhat of a band-aid. If this makes a difference,
> > it still implies that something has changed that is either causing more
> > GFP_ATOMIC allocations to occur (such as the case with iwlagn wireless
> > driver) or make them more likely to fail.
> 
> hmm, I'm confused. this description addressed generic high order allocation.
> but, 
> 
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |   33 ++++++++++++++++++++++-----------
> >  1 files changed, 22 insertions(+), 11 deletions(-)
> > 
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
> 
> __alloc_pages_high_priority() is only called if ALLOC_NO_WATERMARKS.
> ALLOC_NO_WATERMARKS mean PF_MEMALLOC or TIF_MEMDIE and GFP_ATOMIC don't make
> nested alloc_pages() (= don't make PF_MEMALLOC case). 
> Then, I haven't understand why this patch improve iwlagn GFP_ATOMIC case.
> 
> hmm, maybe I missed something. I see the code again tommorow.
> 

The description is misleading but in the patches current form, it makes
a different to Tobias's testing. I still haven't figured out why.

> 
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
> > -- 
> > 1.6.3.3
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
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
