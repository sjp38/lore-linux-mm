Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 187C982F69
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 03:25:13 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id g6so106261053igt.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 00:25:13 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id o67si45683434ioo.211.2016.02.23.00.25.11
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 00:25:12 -0800 (PST)
Date: Tue, 23 Feb 2016 17:25:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160223082532.GG27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
 <20160222023432.GC27829@bbox>
 <20160222035954.GC11961@swordfish>
 <20160222044145.GE27829@bbox>
 <20160222104325.GA4859@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222104325.GA4859@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 07:43:25PM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 13:41), Minchan Kim wrote:
> [..]
> > > oh, sure.
> > > 
> > > so let's keep dynamic page allocation out of sight for now.
> > > I'll do more tests with the increase ORDER and if it's OK then
> > > hopefully we can just merge it, it's quite simple and shouldn't
> > > interfere with any of the changes you are about to introduce.
> > 
> > Thanks.
> > 
> > And as another idea, we could try fallback approach that
> > we couldn't meet nr_pages to minimize wastage so let's fallback
> > to order-0 page like as-is. It will enhance, at least than now
> > with small-amount of code compared to dynmaic page allocation.
> 
> 
> speaking of fallback,
> with bigger ZS_MAX_ZSPAGE_ORDER 'normal' classes also become bigger.
> 
> PATCHED
> 
>      6   128           0            1            96         78          3                1
>      7   144           0            1           256        104          9                9
>      8   160           0            1           128         80          5                5
>      9   176           0            1           256         78         11               11
>     10   192           1            1           128         99          6                3
>     11   208           0            1           256         52         13               13
>     12   224           1            1           512        472         28                7
>     13   240           0            1           256         70         15               15
>     14   256           1            1            64         49          4                1
>     15   272           0            1            60         48          4                1
> 
> 
> BASE
> 
>      6   128           0            1            96         83          3                1
>      7   144           0            1           170        113          6                3
>      8   160           0            1           102         72          4                2
>      9   176           1            0            93         75          4                4
>     10   192           0            1           128        104          6                3
>     11   208           1            1            78         52          4                2
>     12   224           1            1           511        475         28                4
>     13   240           1            1            85         73          5                1
>     14   256           1            1            64         53          4                1
>     15   272           1            0            45         43          3                1
> 
> 
> _techically_, zsmalloc is correct.
> for instance, in 11 pages we can store 4096 * 11 / 176 == 256 objects.
> 256 * 176 == 45056, which is 4096 * 11. so if zspage for class_size 176 will contain 11
> order-0 pages, we can count on 0 bytes of unused space once zspage will become ZS_FULL.
> 
> but it's ugly, because I think this will introduce bigger internal fragmentation, which,
> in some cases, can be handled by compaction, but I'd prefer to touch only ->huge classes
> and keep the existing behaviour for normal classes.
> 
> so I'm currently thinking of doing something like this
> 
> #define ZS_MAX_ZSPAGE_ORDER	2
> #define ZS_MAX_HUGE_ZSPAGE_ORDER	4
> #define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
> #define ZS_MAX_PAGES_PER_HUGE_ZSPAGE (_AC(1, UL) << ZS_MAX_HUGE_ZSPAGE_ORDER)
> 
> 
> so, normal classes have ORDER of 2. huge classes, however, as a fallback, can grow
> up to ZS_MAX_HUGE_ZSPAGE_ORDER pages.
> 
> 
> extend only ->huge classes: pages == 1 && get_maxobj_per_zspage(class_size, pages) == 1.
> 
> like this:
> 
> static int __get_pages_per_zspage(int class_size, int max_pages)
> {
>         int i, max_usedpc = 0;
>         /* zspage order which gives maximum used size per KB */
>         int max_usedpc_order = 1;
> 
>         for (i = 1; i <= max_pages; i++) {
>                 int zspage_size;
>                 int waste, usedpc;
> 
>                 zspage_size = i * PAGE_SIZE;
>                 waste = zspage_size % class_size;
>                 usedpc = (zspage_size - waste) * 100 / zspage_size;
> 
>                 if (usedpc > max_usedpc) {
>                         max_usedpc = usedpc;
>                         max_usedpc_order = i;
>                 }
>         }
> 
>         return max_usedpc_order;
> }
> 
> static int get_pages_per_zspage(int class_size)
> {
>         /* normal class first */
>         int pages = __get_pages_per_zspage(class_size,
>                         ZS_MAX_PAGES_PER_ZSPAGE);
> 
>         /* test if the class is ->huge and try to turn it into a normal one */
>         if (pages == 1 &&
>                         get_maxobj_per_zspage(class_size, pages) == 1) {
>                 pages = __get_pages_per_zspage(class_size,
>                                 ZS_MAX_PAGES_PER_HUGE_ZSPAGE);
>         }
> 
>         return pages;
> }
> 

That sounds like a plan but at a first glance, my worry is we might need
some special handling related to objs_per_zspage and pages_per_zspage
because currently, we have assumed all of zspages in a class has same
number of subpages so it might make it ugly.
Hmm, at least, I need to check code how it makes ugly.
If you think it's not trouble, please send a patch.

As well, please write down why order-4 for MAX_ZSPAGES is best
if you resend it as formal patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
