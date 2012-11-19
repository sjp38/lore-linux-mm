Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9CE0F6B0070
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 10:38:21 -0500 (EST)
Received: from eusync2.samsung.com (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDQ0030ORGLH850@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 19 Nov 2012 15:38:45 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync2.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MDQ00LFJRFU7990@eusync2.samsung.com> for linux-mm@kvack.org;
 Mon, 19 Nov 2012 15:38:19 +0000 (GMT)
Message-id: <50AA526A.7080505@samsung.com>
Date: Mon, 19 Nov 2012 16:38:18 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES
 approaches low water mark
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
 <20121114145848.8224e8b0.akpm@linux-foundation.org>
In-reply-to: <20121114145848.8224e8b0.akpm@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On 11/14/2012 11:58 PM, Andrew Morton wrote:
> On Mon, 12 Nov 2012 09:59:42 +0100
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
>
> > It has been observed that system tends to keep a lot of CMA free pages
> > even in very high memory pressure use cases. The CMA fallback for movable
> > pages is used very rarely, only when system is completely pruned from
> > MOVABLE pages, what usually means that the out-of-memory even will be
> > triggered very soon. To avoid such situation and make better use of CMA
> > pages, a heuristics is introduced which turns on CMA fallback for movable
> > pages when the real number of free pages (excluding CMA free pages)
> > approaches low water mark.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> > CC: Michal Nazarewicz <mina86@mina86.com>
> > ---
> >  mm/page_alloc.c |    9 +++++++++
> >  1 file changed, 9 insertions(+)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index fcb9719..90b51f3 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1076,6 +1076,15 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
> >  {
> >  	struct page *page;
> >
> > +#ifdef CONFIG_CMA
> > +	unsigned long nr_free = zone_page_state(zone, NR_FREE_PAGES);
> > +	unsigned long nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
> > +
> > +	if (migratetype == MIGRATE_MOVABLE && nr_cma_free &&
> > +	    nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
> > +		migratetype = MIGRATE_CMA;
> > +#endif /* CONFIG_CMA */
> > +
> >  retry_reserve:
> >  	page = __rmqueue_smallest(zone, order, migratetype);
>
> erk, this is right on the page allocator hotpath.  Bad.

Yes, I know that it adds an overhead to allocation hot path, but I found 
no other
place for such change. Do You have any suggestion where such change can 
be applied
to avoid additional load on hot path?

>
> At the very least, we could code it so it is not quite so dreadfully
> inefficient:
>
> 	if (migratetype == MIGRATE_MOVABLE) {
> 		unsigned long nr_cma_free;
>
> 		nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
> 		if (nr_cma_free) {
> 			unsigned long nr_free;
>
> 			nr_free = zone_page_state(zone, NR_FREE_PAGES);
>
> 			if (nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
> 				migratetype = MIGRATE_CMA;
> 		}
> 	}
>
> but it still looks pretty bad.

Do You want me to resend such patch?

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
