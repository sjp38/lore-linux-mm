Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4EA26B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 11:49:15 -0400 (EDT)
Date: Thu, 22 Oct 2009 16:49:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting
	an allocation attempt after direct reclaim failed
Message-ID: <20091022154913.GQ11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-2-git-send-email-mel@csn.ul.ie> <84144f020910220741o51c7e3dajcfd7b78d6dbbc4eb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020910220741o51c7e3dajcfd7b78d6dbbc4eb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 05:41:53PM +0300, Pekka Enberg wrote:
> On Thu, Oct 22, 2009 at 5:22 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > If a direct reclaim makes no forward progress, it considers whether it
> > should go OOM or not. Whether OOM is triggered or not, it may retry the
> > application afterwards. In times past, this would always wake kswapd as well
> > but currently, kswapd is not woken up after direct reclaim fails. For order-0
> > allocations, this makes little difference but if there is a heavy mix of
> > higher-order allocations that direct reclaim is failing for, it might mean
> > that kswapd is not rewoken for higher orders as much as it did previously.
> >
> > This patch wakes up kswapd when an allocation is being retried after a direct
> > reclaim failure. It would be expected that kswapd is already awake, but
> > this has the effect of telling kswapd to reclaim at the higher order as well.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> You seem to have dropped the Reviewed-by tags from me and Christoph
> for this patch.
> 

My apologies. I missed then when going through the old mails.

> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bf72055..dfa4362 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1817,9 +1817,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >        if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
> >                goto nopage;
> >
> > +restart:
> >        wake_all_kswapd(order, zonelist, high_zoneidx);
> >
> > -restart:
> >        /*
> >         * OK, we're below the kswapd watermark and have kicked background
> >         * reclaim. Now things get more complex, so set up alloc_flags according
> > --
> > 1.6.3.3
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
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
