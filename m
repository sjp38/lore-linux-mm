Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6E02E6B0038
	for <linux-mm@kvack.org>; Tue, 20 May 2014 07:38:17 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so245402pde.14
        for <linux-mm@kvack.org>; Tue, 20 May 2014 04:38:17 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id io2si1395713pbc.125.2014.05.20.04.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 20 May 2014 04:38:16 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8; format=flowed
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N5V006KHEZEJTA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 20 May 2014 12:38:02 +0100 (BST)
Content-transfer-encoding: 8BIT
Message-id: <537B3EA5.2040302@samsung.com>
Date: Tue, 20 May 2014 13:38:13 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to
 non-zero value
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE>
 <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com>
 <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE>
 <xa1td2f91qw5.fsf@mina86.com> <537AA6C7.1040506@lge.com>
In-reply-to: <537AA6C7.1040506@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

Hello,

On 2014-05-20 02:50, Gioh Kim wrote:
>
>
> 2014-05-20 i??i ? 4:59, Michal Nazarewicz i?' e,?:
>> On Sun, May 18 2014, Joonsoo Kim wrote:
>>> I think that this problem is originated from atomic_pool_init().
>>> If configured coherent_pool size is larger than default cma size,
>>> it can be failed even if this patch is applied.
>
> The coherent_pool size (atomic_pool.size) should be restricted smaller 
> than cma size.
>
> This is another issue, however I think the default atomic pool size is 
> too small.
> Only one port of USB host needs at most 256Kbytes coherent memory 
> (according to the USB host spec).

This pool is used only for allocation done in atomic context (allocations
done with GFP_ATOMIC flag), otherwise the standard allocation path is used.
Are you sure that each usb host port really needs so much memory allocated
in atomic context?

> If a platform has several ports, it needs more than 1MB.
> Therefore the default atomic pool size should be at least 1MB.
>
>>>
>>> How about below patch?
>>> It uses fallback allocation if CMA is failed.
>>
>> Yes, I thought about it, but __dma_alloc uses similar code:
>>
>>     else if (!IS_ENABLED(CONFIG_DMA_CMA))
>>         addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, 
>> caller);
>>     else
>>         addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
>>
>> so it probably needs to be changed as well.
>
> If CMA option is not selected, __alloc_from_contiguous would not be 
> called.
> We don't need to the fallback allocation.
>
> And if CMA option is selected and initialized correctly,
> the cma allocation can fail in case of no-CMA-memory situation.
> I thinks in that case we don't need to the fallback allocation also,
> because it is normal case.
>
> Therefore I think the restriction of CMA size option and make CMA work 
> can cover every cases.
>
> I think below patch is also good choice.
> If both of you, Michal and Joonsoo, do not agree with me, please 
> inform me.
> I will make a patch including option restriction and fallback allocation.

I'm not sure if we need a fallback for failed CMA allocation. The only 
issue that
have been mentioned here and needs to be resolved is support for 
disabling cma by
kernel command line. Right now it will fails completely.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
