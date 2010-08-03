Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F33A600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 21:44:19 -0400 (EDT)
Date: Tue, 3 Aug 2010 09:40:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive
 performance and high iowait times
Message-ID: <20100803014009.GC5198@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net>
 <20100802081253.GA27492@localhost>
 <AANLkTi=5074JuygMXPwTy1qSro+WfU2E9jJCd79S8vD6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=5074JuygMXPwTy1qSro+WfU2E9jJCd79S8vD6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "pvz@pvz.pp.se" <pvz@pvz.pp.se>, "bgamari@gmail.com" <bgamari@gmail.com>, "larppaxyz@gmail.com" <larppaxyz@gmail.com>, "seanj@xyke.com" <seanj@xyke.com>, "kernel-bugs.dev1world@spamgourmet.com" <kernel-bugs.dev1world@spamgourmet.com>, "akatopaz@gmail.com" <akatopaz@gmail.com>, "frankrq2009@gmx.com" <frankrq2009@gmx.com>, "thomas.pi@arcor.de" <thomas.pi@arcor.de>, "spawels13@gmail.com" <spawels13@gmail.com>, "vshader@gmail.com" <vshader@gmail.com>, "rockorequin@hotmail.com" <rockorequin@hotmail.com>, "ylalym@gmail.com" <ylalym@gmail.com>, "theholyettlz@googlemail.com" <theholyettlz@googlemail.com>, "hassium@yandex.ru" <hassium@yandex.ru>
List-ID: <linux-mm.kvack.org>

> > So swapping is another major cause of responsiveness lags.
> >
> > I just tested the heavy swapping case with the patches to remove
> > the congestion_wait() and wait_on_page_writeback() stalls on high
> > order allocations. The patches work as expected. No single stall shows
> > up with the debug patch posted in http://lkml.org/lkml/2010/8/1/10.
> >
> > However there are still stalls on get_request_wait():
> > - kswapd trying to pageout anonymous pages
> > - _any_ process in direct reclaim doing pageout()
> >
> > Since 90% pages are dirty anonymous pages, the chances to stall is high.
> > kswapd can hardly make smooth progress. The applications end up doing
> > direct reclaim by themselves, which also ends up stuck in pageout().
> > They are not explicitly stalled in vmscan code, but implicitly in
> > get_request_wait() when trying to swapping out the dirty pages.
> >
> > It sure hurts responsiveness with so many applications stalled on
> > get_request_wait(). But question is, what can we do otherwise? The
> > system is running short of memory and cannot keep up freeing enough
> > memory anyway. So page allocations have to be throttled somewhere..
> >
> > But wait.. What if there are only 50% anonymous pages? In this case
> > applications don't necessarily need to sleep in get_request_wait().
> > The memory pressure is not really high. The poor man's solution is to
> > disable swapping totally, as the bug reporters find to be helpful..
> 
> What you mentioned problem is following as.
> 
> 1. VM pageout many anon page to swap device.
> 2. Swap device starts to congest
> 3. When some application swap-in its page, it would be stalled by 2.

Each swap-in is a SYNC read IO and will be stalled for a while, this
is expected. We expect the block layer to not delay the SYNC IO too
much by the pending ASYNC IOs.

> Or
> 
> 1. So many application start to swap-in
> 2. Swap device starts to congest
> 3. When VM page out some anon page to swap device, it can be stalled by 2.

There are two congestion queues, SYNC and ASYNC. As (3) is ASYNC IO,
so will only block on the congested ASYNC queue in get_request_wait().
The many swap-in reads will sure impact how fast the ASYNC IO queue can
be serviced and increase the chance (3) get blocked, however there are
no direct wait dependencies.

> > One easy fix is to skip swap-out when bdi is congested and priority is
> > close to DEF_PRIORITY. However it would be unfair to selectively
> > (largely in random) keep some pages and reclaim the others that
> > actually have the same age.
> >
> > A more complete fix may be to introduce some swap_out LRU list(s).
> > Pages in it will be swap out as fast as possible by a dedicated
> > kernel thread. And pageout() can freely add pages to it until it
> > grows larger than some threshold, eg. 30% reclaimable memory, at which
> > point pageout() will stall on the list. The basic idea is to switch
> > the random get_request_wait() stalls to some more global wise stalls.
> >
> > Does this sound feasible?
> Tend to agree prevent random sleep.
> But swap_out LRU list is meaningful?
> If VM decides to swap out the page, it is a cold page.
> If we want to batch I/O of swap pages, IMHO it would be better to put
> together swap pages not LRU order but physical block order.

Yeah we can put the to-be-swap-out pages to any data structure.

I find list_head to be convenient because it seems swap-out IOs
are largely sequential ones (in contrast to swap-in). Anyway it may
be the simplest implementation and serve well as the initial step :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
