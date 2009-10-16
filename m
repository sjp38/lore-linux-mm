Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 81C146B004F
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 18:32:38 -0400 (EDT)
Date: Fri, 16 Oct 2009 23:32:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] page allocator: Direct reclaim should always obey
	watermarks
Message-ID: <20091016223237.GE32397@csn.ul.ie>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <1255689446-3858-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0910161204140.21328@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0910161204140.21328@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 12:07:07PM -0700, David Rientjes wrote:
> On Fri, 16 Oct 2009, Mel Gorman wrote:
> 
> > ALLOC_NO_WATERMARKS should be cleared when trying to allocate from the
> > free-lists after a direct reclaim. If it's not, __GFP_NOFAIL allocations
> > from a process that is exiting can ignore watermarks. __GFP_NOFAIL is not
> > often used but the journal layer is one of those places. This is suspected of
> > causing an increase in the number of GFP_ATOMIC allocation failures reported.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index dfa4362..a3e5fed 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1860,7 +1860,8 @@ rebalance:
> >  	page = __alloc_pages_direct_reclaim(gfp_mask, order,
> >  					zonelist, high_zoneidx,
> >  					nodemask,
> > -					alloc_flags, preferred_zone,
> > +					alloc_flags & ~ALLOC_NO_WATERMARKS,
> > +					preferred_zone,
> >  					migratetype, &did_some_progress);
> >  	if (page)
> >  		goto got_pg;
> 
> I don't get it.  __alloc_pages_high_priority() will already loop 
> indefinitely if ALLOC_NO_WATERMARKS is set and its a __GFP_NOFAIL 
> allocation.  How do we even reach this code in such a condition?
> 

Frans, you reported that both patches in combination reduced the number
of failures. Was it in fact just the kswapd change that made the
difference?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
