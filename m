Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F96F6B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 17:33:24 -0400 (EDT)
Date: Wed, 19 May 2010 23:32:51 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/5] vmscan: fix unmapping behaviour for RECLAIM_SWAP
Message-ID: <20100519213251.GA2868@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
 <20100430224315.912441727@cmpxchg.org>
 <20100512122434.2133.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100512122434.2133.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 13, 2010 at 12:02:53PM +0900, KOSAKI Motohiro wrote:
> sorry for the long delayed review.

Yeah, I'm a bit on the slow side as well these days.  No problem.

> > The RECLAIM_SWAP flag in zone_reclaim_mode controls whether
> > zone_reclaim() is allowed to swap or not (obviously).
> > 
> > This is currently implemented by allowing or forbidding reclaim to
> > unmap pages, which also controls reclaim of shared pages and is thus
> > not appropriate.
> > 
> > We can do better by using the sc->may_swap parameter instead, which
> > controls whether the anon lists are scanned.
> > 
> > Unmapping of pages is then allowed per default from zone_reclaim().
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmscan.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2563,8 +2563,8 @@ static int __zone_reclaim(struct zone *z
> >  	int priority;
> >  	struct scan_control sc = {
> >  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> > -		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> > -		.may_swap = 1,
> > +		.may_unmap = 1,
> > +		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> >  		.nr_to_reclaim = max_t(unsigned long, nr_pages,
> >  				       SWAP_CLUSTER_MAX),
> >  		.gfp_mask = gfp_mask,
> 
> About half years ago, I did post exactly same patch. but at that time,
> it got Mel's objection. after some discution we agreed to merge
> documentation change instead code fix.

Interesting, let me dig through the archives.

> So, now the documentation describe clearly 4th bit meant no unmap.
> Please drop this, instead please make s/RECLAIM_SWAP/RECLAIM_MAPPED/ patch.

Yep.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
