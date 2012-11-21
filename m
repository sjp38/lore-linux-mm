Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3D7186B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 08:25:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1061910pad.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:25:49 -0800 (PST)
Date: Wed, 21 Nov 2012 22:25:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES
 approaches low water mark
Message-ID: <20121121132540.GA2084@barrios>
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
 <20121120000137.GC447@bbox>
 <50AB987F.30002@samsung.com>
 <20121121010556.GD447@bbox>
 <xa1t7gpfgl53.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1t7gpfgl53.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Wed, Nov 21, 2012 at 02:07:04PM +0100, Michal Nazarewicz wrote:
> On Wed, Nov 21 2012, Minchan Kim wrote:
> > So your concern is that too many free pages in MIGRATE_CMA when OOM happens
> > is odd? It's natural with considering CMA design which kernel never fallback
> > non-movable page allocation to CMA area. I guess it's not a your concern.
> >
> > Let's think below extreme cases.
> >
> > = Before =
> >
> > * 1000M DRAM system.
> > * 400M kernel used pages.
> > * 300M movable used pages.
> > * 300M cma freed pages.
> >
> > 1. kernel want to request 400M non-movable memory, additionally.
> > 2. VM start to reclaim 300M movable pages.
> > 3. But it's not enough to meet 400M request.
> > 4. go to OOM. (It's natural)
> >
> > = After(with your patch) =
> >
> > * 1000M DRAM system.
> > * 400M kernel used pages.
> > * 300M movable *freed* pages.
> > * 300M cma used pages(by your patch, I simplified your concept)
> >
> > 1. kernel want to request 400M non-movable memory.
> > 2. 300M movable freed pages isn't enough to meet 400M request.
> > 3. Also, there is no point to reclaim CMA pages for non-movable allocation.
> > 4. go to OOM. (It's natural)
> >
> > There is no difference between before and after in allocation POV.
> > Let's think another example.
> >
> > = Before =
> >
> > * 1000M DRAM system.
> > * 400M kernel used pages.
> > * 300M movable used pages.
> > * 300M cma freed pages.
> >
> > 1. kernel want to request 300M non-movable memory.
> > 2. VM start to reclaim 300M movable pages.
> > 3. It's enough to meet 300M request.
> > 4. happy end
> >
> > = After(with your patch) =
> >
> > * 1000M DRAM system.
> > * 400M kernel used pages.
> > * 300M movable *freed* pages.
> > * 300M cma used pages(by your patch, I simplified your concept)
> >
> > 1. kernel want to request 300M non-movable memory.
> > 2. 300M movable freed pages is enough to meet 300M request.
> > 3. happy end.
> >
> > There is no difference in allocation POV, too.
> 
> The difference thou is that before 30% of memory is wasted (ie. free),
> whereas after all memory is used.  The main point of CMA is to make the
> memory useful if devices are not using it.  Having it not allocated is
> defeating that purpose.

I think it's not a waste because if reclaimed movable pages is working set,
they are soon reloaded to migrate_cma in this time.

> 
> -- 
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
> ..o | Computer Science,  MichaA? a??mina86a?? Nazarewicz    (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--





-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
