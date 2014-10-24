Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 936956B0081
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 22:02:50 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id z6so1896276yhz.30
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:02:50 -0700 (PDT)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com. [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id v188si1240596ykb.86.2014.10.23.19.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 19:02:49 -0700 (PDT)
Received: by mail-yh0-f54.google.com with SMTP id 29so2052905yhl.27
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:02:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1463193.4qGZjcvNod@avalon>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<xa1tmw8mlobz.fsf@mina86.com>
	<1463193.4qGZjcvNod@avalon>
Date: Fri, 24 Oct 2014 10:02:49 +0800
Message-ID: <CAL1ERfPiv6KG5Lim6F0w72z=j47D1KCWhukLc5T6jJPOHTP_mQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't
 be activated
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Oct 24, 2014 at 7:42 AM, Laurent Pinchart
<laurent.pinchart@ideasonboard.com> wrote:
> Hi Michal,
>
> On Thursday 23 October 2014 18:53:36 Michal Nazarewicz wrote:
>> On Thu, Oct 23 2014, Laurent Pinchart wrote:
>> > If activation of the CMA area fails its mutex won't be initialized,
>> > leading to an oops at allocation time when trying to lock the mutex. Fix
>> > this by failing allocation if the area hasn't been successfully actived,
>> > and detect that condition by moving the CMA bitmap allocation after page
>> > block reservation completion.
>> >
>> > Signed-off-by: Laurent Pinchart
>> > <laurent.pinchart+renesas@ideasonboard.com>
>>
>> Cc: <stable@vger.kernel.org>  # v3.17
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>

This patch is good, but how about add a active field in cma struct?
use cma->active to check whether cma is actived successfully.
I think it will make code more clear and readable.
Just my little opinion.


>> As a matter of fact, this is present in kernels earlier than 3.17 but in
>> the 3.17 the code has been moved from drivers/base/dma-contiguous.c to
>> mm/cma.c so this might require separate stable patch.  I can track this
>> and prepare a patch if you want.
>
> That could be done, but I'm not sure if it's really worth it. The bug only
> occurs when the CMA zone activation fails. I've ran into that case due to a
> bug introduced in v3.18-rc1, but this shouldn't be the case for older kernel
> versions.
>
> If you think the fix should be backported to stable kernels older than v3.17
> please feel free to cook up a patch.
>
>> > ---
>> >
>> >  mm/cma.c | 17 ++++++-----------
>> >  1 file changed, 6 insertions(+), 11 deletions(-)
>> >
>> > diff --git a/mm/cma.c b/mm/cma.c
>> > index 963bc4a..16c6650 100644
>> > --- a/mm/cma.c
>> > +++ b/mm/cma.c
>> > @@ -93,11 +93,6 @@ static int __init cma_activate_area(struct cma *cma)
>> >     unsigned i = cma->count >> pageblock_order;
>> >     struct zone *zone;
>> >
>> > -   cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>> > -
>> > -   if (!cma->bitmap)
>> > -           return -ENOMEM;
>> > -
>> >     WARN_ON_ONCE(!pfn_valid(pfn));
>> >     zone = page_zone(pfn_to_page(pfn));
>> >
>> > @@ -114,17 +109,17 @@ static int __init cma_activate_area(struct cma *cma)
>> >                      * to be in the same zone.
>> >                      */
>> >                     if (page_zone(pfn_to_page(pfn)) != zone)
>> > -                           goto err;
>> > +                           return -EINVAL;
>> >             }
>> >             init_cma_reserved_pageblock(pfn_to_page(base_pfn));
>> >     } while (--i);
>> >
>> > +   cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>> > +   if (!cma->bitmap)
>> > +           return -ENOMEM;
>> > +
>> >     mutex_init(&cma->lock);
>> >     return 0;
>> > -
>> > -err:
>> > -   kfree(cma->bitmap);
>> > -   return -EINVAL;
>> >  }
>> >
>> >  static int __init cma_init_reserved_areas(void)
>> > @@ -313,7 +308,7 @@ struct page *cma_alloc(struct cma *cma, int count,
>> > unsigned int align)
>> >     struct page *page = NULL;
>> >     int ret;
>> >
>> > -   if (!cma || !cma->count)
>> > +   if (!cma || !cma->count || !cma->bitmap)
>> >             return NULL;
>> >
>> >     pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
>
> --
> Regards,
>
> Laurent Pinchart
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
