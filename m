Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 6DCC96B00B3
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:50:49 -0500 (EST)
Received: from eusync3.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDU00BFBHD3OB70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Nov 2012 15:51:03 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync3.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MDU00G6UHCLY520@eusync3.samsung.com> for linux-mm@kvack.org;
 Wed, 21 Nov 2012 15:50:47 +0000 (GMT)
Message-id: <50ACF855.7010506@samsung.com>
Date: Wed, 21 Nov 2012 16:50:45 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES
 approaches low water mark
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
 <20121120000137.GC447@bbox> <50AB987F.30002@samsung.com>
 <20121121010556.GD447@bbox>
In-reply-to: <20121121010556.GD447@bbox>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On 11/21/2012 2:05 AM, Minchan Kim wrote:
> On Tue, Nov 20, 2012 at 03:49:35PM +0100, Marek Szyprowski wrote:
> > Hello,
> >
> > On 11/20/2012 1:01 AM, Minchan Kim wrote:
> > >Hi Marek,
> > >
> > >On Mon, Nov 12, 2012 at 09:59:42AM +0100, Marek Szyprowski wrote:
> > >> It has been observed that system tends to keep a lot of CMA free pages
> > >> even in very high memory pressure use cases. The CMA fallback for movable
> > >
> > >CMA free pages are just fallback for movable pages so if user requires many
> > >user pages, it ends up consuming cma free pages after out of movable pages.
> > >What do you mean that system tend to keep free pages even in very
> > >high memory pressure?
> > >> pages is used very rarely, only when system is completely pruned from
> > >> MOVABLE pages, what usually means that the out-of-memory even will be
> > >> triggered very soon. To avoid such situation and make better use of CMA
> > >
> > >Why does OOM is triggered very soon if movable pages are burned out while
> > >there are many cma pages?
> > >
> > >It seems I can't understand your point quitely.
> > >Please make your problem clear for silly me to understand clearly.
> >
> > Right now running out of 'plain' movable pages is the only possibility to
> > get movable pages allocated from CMA. On the other hand running out of
> > 'plain' movable pages is very deadly for the system, as movable pageblocks
> > are also the main fallbacks for reclaimable and non-movable pages.
> >
> > Then, once we run out of movable pages and kernel needs non-mobable or
> > reclaimable page (what happens quite often), it usually triggers OOM to
> > satisfy the memory needs. Such OOM is very strange, especially on a system
> > with dozen of megabytes of CMA memory, having most of them free at the OOM
> > event. By high memory pressure I mean the high memory usage.
>
> So your concern is that too many free pages in MIGRATE_CMA when OOM happens
> is odd? It's natural with considering CMA design which kernel never fallback
> non-movable page allocation to CMA area. I guess it's not a your concern.

My concern is how to minimize memory waste with CMA.

> Let's think below extreme cases.
>
> = Before =
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable used pages.
> * 300M cma freed pages.
>
> 1. kernel want to request 400M non-movable memory, additionally.
> 2. VM start to reclaim 300M movable pages.
> 3. But it's not enough to meet 400M request.
> 4. go to OOM. (It's natural)
>
> = After(with your patch) =
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable *freed* pages.
> * 300M cma used pages(by your patch, I simplified your concept)
>
> 1. kernel want to request 400M non-movable memory.
> 2. 300M movable freed pages isn't enough to meet 400M request.
> 3. Also, there is no point to reclaim CMA pages for non-movable allocation.
> 4. go to OOM. (It's natural)
>
> There is no difference between before and after in allocation POV.
> Let's think another example.
>
> = Before =
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable used pages.
> * 300M cma freed pages.
>
> 1. kernel want to request 300M non-movable memory.
> 2. VM start to reclaim 300M movable pages.
> 3. It's enough to meet 300M request.
> 4. happy end
>
> = After(with your patch) =
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable *freed* pages.
> * 300M cma used pages(by your patch, I simplified your concept)
>
> 1. kernel want to request 300M non-movable memory.
> 2. 300M movable freed pages is enough to meet 300M request.
> 3. happy end.
>
> There is no difference in allocation POV, too.

Those cases are just theoretical, out-of-real live examples. In real world
kernel allocates (and frees) non-movable memory in small portions while
system is running. Typically keeping some amount of free 'plain' movable
pages is enough to make kernel happy about any kind of allocations
(especially non-movable). This requirement is in complete contrast to the
current fallback mechanism, which activates only when kernel runs out of
movable pages completely.

> So I guess that if you see OOM while there are many movable pages,
> I think principal problem is VM reclaimer which should try to reclaim
> best effort if there are freeable movable pages. If VM reclaimer has
> some problem for your workload, firstly we should try fix it rather than
> adding such heuristic to hot path. Otherwise, if you see OOM while there
> are many free CMA pages, it's not odd to me.

Frankly I don't see how reclaim procedure can ensure that it will be
always possible to allocate non-movable pages with current fallback 
mechanism,
which is used only when kernel runs out of pages of a given type. Could you
explain how would You like to change the reclaim procedure to avoid the 
above
situation?

> > This patch introduces a heuristics which let kernel to consume free CMA
> > pages before it runs out of 'plain' movable pages, what is usually enough to
> > keep some spare movable pages for emergency cases before the reclaim occurs.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
