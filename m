Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2806B00AC
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 03:23:37 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so29918707pdi.35
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 00:23:37 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ym5si23241688pac.188.2015.01.06.00.23.34
        for <linux-mm@kvack.org>;
        Tue, 06 Jan 2015 00:23:36 -0800 (PST)
Date: Tue, 6 Jan 2015 17:23:29 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20150106082329.GB18346@js1304-P5Q-DELUXE>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
 <CADtm3G5Cb2vzVo61qDJ7-1ZNzQ2zOisfjb7GiFXvZR0ocKZy0A@mail.gmail.com>
 <CADtm3G4CEhpmrohufmthB_1a49bKEVdVUAQxjWtigq07G4QeTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADtm3G4CEhpmrohufmthB_1a49bKEVdVUAQxjWtigq07G4QeTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek@jasper.es, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 05, 2015 at 08:01:45PM -0800, Gregory Fong wrote:
> +linux-mm and linux-kernel (not sure how those got removed from cc,
> sorry about that)
> 
> On Mon, Jan 5, 2015 at 7:58 PM, Gregory Fong <gregory.0xf0@gmail.com> wrote:
> > Hi Joonsoo,
> >
> > On Wed, May 28, 2014 at 12:04 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index 674ade7..ca678b6 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -788,6 +788,56 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
> >>  }
> >>
> >>  #ifdef CONFIG_CMA
> >> +void adjust_managed_cma_page_count(struct zone *zone, long count)
> >> +{
> >> +       unsigned long flags;
> >> +       long total, cma, movable;
> >> +
> >> +       spin_lock_irqsave(&zone->lock, flags);
> >> +       zone->managed_cma_pages += count;
> >> +
> >> +       total = zone->managed_pages;
> >> +       cma = zone->managed_cma_pages;
> >> +       movable = total - cma - high_wmark_pages(zone);
> >> +
> >> +       /* No cma pages, so do only movable allocation */
> >> +       if (cma <= 0) {
> >> +               zone->max_try_movable = pageblock_nr_pages;
> >> +               zone->max_try_cma = 0;
> >> +               goto out;
> >> +       }
> >> +
> >> +       /*
> >> +        * We want to consume cma pages with well balanced ratio so that
> >> +        * we have consumed enough cma pages before the reclaim. For this
> >> +        * purpose, we can use the ratio, movable : cma. And we doesn't
> >> +        * want to switch too frequently, because it prevent allocated pages
> >> +        * from beging successive and it is bad for some sorts of devices.
> >> +        * I choose pageblock_nr_pages for the minimum amount of successive
> >> +        * allocation because it is the size of a huge page and fragmentation
> >> +        * avoidance is implemented based on this size.
> >> +        *
> >> +        * To meet above criteria, I derive following equation.
> >> +        *
> >> +        * if (movable > cma) then; movable : cma = X : pageblock_nr_pages
> >> +        * else (movable <= cma) then; movable : cma = pageblock_nr_pages : X
> >> +        */
> >> +       if (movable > cma) {
> >> +               zone->max_try_movable =
> >> +                       (movable * pageblock_nr_pages) / cma;
> >> +               zone->max_try_cma = pageblock_nr_pages;
> >> +       } else {
> >> +               zone->max_try_movable = pageblock_nr_pages;
> >> +               zone->max_try_cma = cma * pageblock_nr_pages / movable;
> >
> > I don't know if anyone's already pointed this out (didn't see anything
> > when searching lkml), but while testing this, I noticed this can
> > result in a div by zero under memory pressure (movable becomes 0).
> > This is not unlikely when the majority of pages are in CMA regions
> > (this may seem pathological but we do actually do this right now).

Hello,

Yes, you are right. Thanks for pointing this out.
I will fix it on next version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
