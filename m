Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9AB6B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 20:50:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so6517186pab.14
        for <linux-mm@kvack.org>; Mon, 19 May 2014 17:50:18 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ai10si21762652pad.94.2014.05.19.17.50.16
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 17:50:17 -0700 (PDT)
Message-ID: <537AA6C7.1040506@lge.com>
Date: Tue, 20 May 2014 09:50:15 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to
 non-zero value
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com> <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE> <xa1td2f91qw5.fsf@mina86.com>
In-Reply-To: <xa1td2f91qw5.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com



2014-05-20 i??i ? 4:59, Michal Nazarewicz i?' e,?:
> On Sun, May 18 2014, Joonsoo Kim wrote:
>> I think that this problem is originated from atomic_pool_init().
>> If configured coherent_pool size is larger than default cma size,
>> it can be failed even if this patch is applied.

The coherent_pool size (atomic_pool.size) should be restricted smaller than cma size.

This is another issue, however I think the default atomic pool size is too small.
Only one port of USB host needs at most 256Kbytes coherent memory (according to the USB host spec).
If a platform has several ports, it needs more than 1MB.
Therefore the default atomic pool size should be at least 1MB.

>>
>> How about below patch?
>> It uses fallback allocation if CMA is failed.
>
> Yes, I thought about it, but __dma_alloc uses similar code:
>
> 	else if (!IS_ENABLED(CONFIG_DMA_CMA))
> 		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
> 	else
> 		addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
>
> so it probably needs to be changed as well.

If CMA option is not selected, __alloc_from_contiguous would not be called.
We don't need to the fallback allocation.

And if CMA option is selected and initialized correctly,
the cma allocation can fail in case of no-CMA-memory situation.
I thinks in that case we don't need to the fallback allocation also,
because it is normal case.

Therefore I think the restriction of CMA size option and make CMA work can cover every cases.

I think below patch is also good choice.
If both of you, Michal and Joonsoo, do not agree with me, please inform me.
I will make a patch including option restriction and fallback allocation.

>
>> -----------------8<---------------------
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 6b00be1..2909ab9 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>>          unsigned long *bitmap;
>>          struct page *page;
>>          struct page **pages;
>> -       void *ptr;
>> +       void *ptr = NULL;
>>          int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
>>
>>          bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>> @@ -393,7 +393,7 @@ static int __init atomic_pool_init(void)
>>          if (IS_ENABLED(CONFIG_DMA_CMA))
>>                  ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
>>                                                atomic_pool_init);
>> -       else
>> +       if (!ptr)
>>                  ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
>>                                             atomic_pool_init);
>>          if (ptr) {
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
