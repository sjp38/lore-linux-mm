Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A11A6B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:38:31 -0400 (EDT)
Date: Thu, 22 Oct 2009 17:37:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] page allocator: Do not allow interrupts to use
	ALLOC_HARDER
Message-ID: <20091022163752.GU11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-3-git-send-email-mel@csn.ul.ie> <20091022183303.2448942d.skraw@ithnet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091022183303.2448942d.skraw@ithnet.com>
Sender: owner-linux-mm@kvack.org
To: Stephan von Krawczynski <skraw@ithnet.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 06:33:03PM +0200, Stephan von Krawczynski wrote:
> On Thu, 22 Oct 2009 15:22:33 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Commit 341ce06f69abfafa31b9468410a13dbd60e2b237 altered watermark logic
> > slightly by allowing rt_tasks that are handling an interrupt to set
> > ALLOC_HARDER. This patch brings the watermark logic more in line with
> > 2.6.30.
> > 
> > [rientjes@google.com: Spotted the problem]
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index dfa4362..7f2aa3e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1769,7 +1769,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> >  		 */
> >  		alloc_flags &= ~ALLOC_CPUSET;
> > -	} else if (unlikely(rt_task(p)))
> > +	} else if (unlikely(rt_task(p)) && !in_interrupt())
> >  		alloc_flags |= ALLOC_HARDER;
> >  
> >  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> > -- 
> > 1.6.3.3
> > 
> 
> Is it correct that this one applies offset -54 lines in 2.6.31.4 ? 
> 

In this case, it's ok. It's just a harmless heads-up that the kernel
looks slightly different than expected. I posted a 2.6.31.4 version of
the two patches that cause real problems.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
