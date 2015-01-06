Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 332086B00A8
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 23:02:17 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id p6so352344qcv.20
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 20:02:16 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com. [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id e60si62842794qga.116.2015.01.05.20.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 20:02:15 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id k15so13489287qaq.21
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 20:02:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CADtm3G5Cb2vzVo61qDJ7-1ZNzQ2zOisfjb7GiFXvZR0ocKZy0A@mail.gmail.com>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com> <CADtm3G5Cb2vzVo61qDJ7-1ZNzQ2zOisfjb7GiFXvZR0ocKZy0A@mail.gmail.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Mon, 5 Jan 2015 20:01:45 -0800
Message-ID: <CADtm3G4CEhpmrohufmthB_1a49bKEVdVUAQxjWtigq07G4QeTQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek@jasper.es, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

+linux-mm and linux-kernel (not sure how those got removed from cc,
sorry about that)

On Mon, Jan 5, 2015 at 7:58 PM, Gregory Fong <gregory.0xf0@gmail.com> wrote:
> Hi Joonsoo,
>
> On Wed, May 28, 2014 at 12:04 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 674ade7..ca678b6 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -788,6 +788,56 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
>>  }
>>
>>  #ifdef CONFIG_CMA
>> +void adjust_managed_cma_page_count(struct zone *zone, long count)
>> +{
>> +       unsigned long flags;
>> +       long total, cma, movable;
>> +
>> +       spin_lock_irqsave(&zone->lock, flags);
>> +       zone->managed_cma_pages += count;
>> +
>> +       total = zone->managed_pages;
>> +       cma = zone->managed_cma_pages;
>> +       movable = total - cma - high_wmark_pages(zone);
>> +
>> +       /* No cma pages, so do only movable allocation */
>> +       if (cma <= 0) {
>> +               zone->max_try_movable = pageblock_nr_pages;
>> +               zone->max_try_cma = 0;
>> +               goto out;
>> +       }
>> +
>> +       /*
>> +        * We want to consume cma pages with well balanced ratio so that
>> +        * we have consumed enough cma pages before the reclaim. For this
>> +        * purpose, we can use the ratio, movable : cma. And we doesn't
>> +        * want to switch too frequently, because it prevent allocated pages
>> +        * from beging successive and it is bad for some sorts of devices.
>> +        * I choose pageblock_nr_pages for the minimum amount of successive
>> +        * allocation because it is the size of a huge page and fragmentation
>> +        * avoidance is implemented based on this size.
>> +        *
>> +        * To meet above criteria, I derive following equation.
>> +        *
>> +        * if (movable > cma) then; movable : cma = X : pageblock_nr_pages
>> +        * else (movable <= cma) then; movable : cma = pageblock_nr_pages : X
>> +        */
>> +       if (movable > cma) {
>> +               zone->max_try_movable =
>> +                       (movable * pageblock_nr_pages) / cma;
>> +               zone->max_try_cma = pageblock_nr_pages;
>> +       } else {
>> +               zone->max_try_movable = pageblock_nr_pages;
>> +               zone->max_try_cma = cma * pageblock_nr_pages / movable;
>
> I don't know if anyone's already pointed this out (didn't see anything
> when searching lkml), but while testing this, I noticed this can
> result in a div by zero under memory pressure (movable becomes 0).
> This is not unlikely when the majority of pages are in CMA regions
> (this may seem pathological but we do actually do this right now).
>
> [    0.249674] Division by zero in kernel.
> [    0.249682] CPU: 2 PID: 1 Comm: swapper/0 Not tainted
> 3.14.13-1.3pre-00368-g4d90957-dirty #10
> [    0.249710] [<c001619c>] (unwind_backtrace) from [<c0011fa4>]
> (show_stack+0x10/0x14)
> [    0.249725] [<c0011fa4>] (show_stack) from [<c0538d6c>]
> (dump_stack+0x80/0x90)
> [    0.249740] [<c0538d6c>] (dump_stack) from [<c025e9d0>] (Ldiv0+0x8/0x10)
> [    0.249751] [<c025e9d0>] (Ldiv0) from [<c0094ba4>]
> (adjust_managed_cma_page_count+0x64/0xd8)
> [    0.249762] [<c0094ba4>] (adjust_managed_cma_page_count) from
> [<c00cb2f4>] (cma_release+0xa8/0xe0)
> [    0.249776] [<c00cb2f4>] (cma_release) from [<c0721698>]
> (cma_drvr_probe+0x378/0x470)
> [    0.249787] [<c0721698>] (cma_drvr_probe) from [<c02ce9cc>]
> (platform_drv_probe+0x18/0x48)
> [    0.249799] [<c02ce9cc>] (platform_drv_probe) from [<c02ccfb0>]
> (driver_probe_device+0xac/0x3a4)
> [    0.249808] [<c02ccfb0>] (driver_probe_device) from [<c02cd378>]
> (__driver_attach+0x8c/0x90)
> [    0.249817] [<c02cd378>] (__driver_attach) from [<c02cb390>]
> (bus_for_each_dev+0x60/0x94)
> [    0.249825] [<c02cb390>] (bus_for_each_dev) from [<c02cc674>]
> (bus_add_driver+0x15c/0x218)
> [    0.249834] [<c02cc674>] (bus_add_driver) from [<c02cd9a0>]
> (driver_register+0x78/0xf8)
> [    0.249841] [<c02cd9a0>] (driver_register) from [<c02cea24>]
> (platform_driver_probe+0x20/0xa4)
> [    0.249849] [<c02cea24>] (platform_driver_probe) from [<c0008958>]
> (do_one_initcall+0xd4/0x17c)
> [    0.249857] [<c0008958>] (do_one_initcall) from [<c0719d00>]
> (kernel_init_freeable+0x13c/0x1dc)
> [    0.249864] [<c0719d00>] (kernel_init_freeable) from [<c0534578>]
> (kernel_init+0x8/0xe8)
> [    0.249873] [<c0534578>] (kernel_init) from [<c000ed78>]
> (ret_from_fork+0x14/0x3c)
>
> Could probably just add something above similar to the "no cma pages" case, like
>
> /* No movable pages, so only do CMA allocation */
> if (movable <= 0) {
>         zone->max_try_cma = pageblock_nr_pages;
>         zone->max_try_movable = 0;
>         goto out;
> }
>
>> +       }
>> +
>> +out:
>> +       zone->nr_try_movable = zone->max_try_movable;
>> +       zone->nr_try_cma = zone->max_try_cma;
>> +
>> +       spin_unlock_irqrestore(&zone->lock, flags);
>> +}
>> +
>
> Best regards,
> Gregory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
