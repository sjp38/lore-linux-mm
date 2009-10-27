Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EE3086B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 08:27:12 -0400 (EDT)
Date: Tue, 27 Oct 2009 12:27:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting
	an allocation attempt after direct reclaim failed
Message-ID: <20091027122707.GD8900@csn.ul.ie>
References: <20091026100019.2F4A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0910260005500.15361@chino.kir.corp.google.com> <20091026222159.2F72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091026222159.2F72.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 11:42:55AM +0900, KOSAKI Motohiro wrote:
> > On Mon, 26 Oct 2009, KOSAKI Motohiro wrote:
> > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index bf72055..5a27896 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1899,6 +1899,12 @@ rebalance:
> > >  	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
> > >  		/* Wait for some write requests to complete then retry */
> > >  		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > > +
> > > +		/*
> > > +		 * While we wait congestion wait, Amount of free memory can
> > > +		 * be changed dramatically. Thus, we kick kswapd again.
> > > +		 */
> > > +		wake_all_kswapd(order, zonelist, high_zoneidx);
> > >  		goto rebalance;
> > >  	}
> > >  
> > 
> > We're blocking to finish writeback of the directly reclaimed memory, why 
> > do we need to wake kswapd afterwards?
> 
> the same reason of "goto restart" case. that's my intention.
> if following scenario occur, it is equivalent that we didn't call wake_all_kswapd().
> 
>   1. call congestion_wait()
>   2. kswapd reclaimed lots memory and sleep
>   3. another task consume lots memory
>   4. wakeup from congestion_wait()
> 
> IOW, if we falled into __alloc_pages_slowpath(), we naturally expect
> next page_alloc() don't fall into slowpath. however if kswapd end to
> its work too early, this assumption isn't true.
> 
> Is this too pessimistic assumption?
> 

hmm.

The reason it's not woken in both cases a second time was to match the
behaviour of 2.6.30.  If the direct reclaimer goes asleep and another task
consumes the memory the direct reclaimer freed then the greedy process should
kick kswapd back awake again as free memory goes below the low watermark.

However, if the greedy process was allocating order-0, it's possible that
the watermarks for order-0 are being met leaving kswapd alone where as the
high-order ones are not leaving kswapd to go back asleep or to reclaim at
the wrong order.

It's a functional change but I can add it to the list of things to
consider. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
