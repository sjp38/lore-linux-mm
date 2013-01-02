Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E575F6B006C
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 20:55:29 -0500 (EST)
Received: by mail-oa0-f42.google.com with SMTP id j1so12680380oag.15
        for <linux-mm@kvack.org>; Tue, 01 Jan 2013 17:55:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50E238CF.1050708@gmail.com>
References: <1356656433-2278-1-git-send-email-daeinki@gmail.com>
	<50E238CF.1050708@gmail.com>
Date: Wed, 2 Jan 2013 10:55:28 +0900
Message-ID: <CAAQKjZOFKDBWMGKrCLOkQstvPOVgZmudQUT99jBBfxLqs3_ojQ@mail.gmail.com>
Subject: Re: [RFC] ARM: DMA-Mapping: add a new attribute to clear buffer
From: Inki Dae <inki.dae@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Subash Patel <subashrp@gmail.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com

2013/1/1 Subash Patel <subashrp@gmail.com>:
>
>
> On Thursday 27 December 2012 05:00 PM, daeinki@gmail.com wrote:
>>
>> From: Inki Dae <inki.dae@samsung.com>
>>
>> This patch adds a new attribute, DMA_ATTR_SKIP_BUFFER_CLEAR
>> to skip buffer clearing. The buffer clearing also flushes CPU cache
>> so this operation has performance deterioration a little bit.
>>
>> With this patch, allocated buffer region is cleared as default.
>> So if you want to skip the buffer clearing, just set this attribute.
>>
>> But this flag should be used carefully because this use might get
>> access to some vulnerable content such as security data. So with this
>> patch, we make sure that all pages will be somehow cleared before
>> exposing to userspace.
>>
>> For example, let's say that the security data had been stored
>> in some memory and freed without clearing it.
>> And then malicious process allocated the region though some buffer
>> allocator such as gem and ion without clearing it, and requested blit
>> operation with cleared another buffer though gpu or other drivers.
>> At this time, the malicious process could access the security data.
>
>
> Isnt it always good to use such security related buffers through TZ rather
> than trying to guard them in the non-secure zone?
>

This is for normal world. We should consider security issue to normal
world and also all cases as possible.

>
>>
>> Signed-off-by: Inki Dae <inki.dae@samsung.com>
>> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>> ---
>>   arch/arm/mm/dma-mapping.c |    6 ++++--
>>   include/linux/dma-attrs.h |    1 +
>>   2 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 6b2fb87..fbe9dff 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -1058,7 +1058,8 @@ static struct page **__iommu_alloc_buffer(struct
>> device *dev, size_t size,
>>                 if (!page)
>>                         goto error;
>>
>> -               __dma_clear_buffer(page, size);
>> +               if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
>> +                       __dma_clear_buffer(page, size);
>>
>>                 for (i = 0; i < count; i++)
>>                         pages[i] = page + i;
>> @@ -1082,7 +1083,8 @@ static struct page **__iommu_alloc_buffer(struct
>> device *dev, size_t size,
>>                                 pages[i + j] = pages[i] + j;
>>                 }
>>
>> -               __dma_clear_buffer(pages[i], PAGE_SIZE << order);
>> +               if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
>> +                       __dma_clear_buffer(pages[i], PAGE_SIZE << order);
>>                 i += 1 << order;
>>                 count -= 1 << order;
>>         }
>> diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
>> index c8e1831..2592c05 100644
>> --- a/include/linux/dma-attrs.h
>> +++ b/include/linux/dma-attrs.h
>> @@ -18,6 +18,7 @@ enum dma_attr {
>>         DMA_ATTR_NO_KERNEL_MAPPING,
>>         DMA_ATTR_SKIP_CPU_SYNC,
>>         DMA_ATTR_FORCE_CONTIGUOUS,
>> +       DMA_ATTR_SKIP_BUFFER_CLEAR,
>>         DMA_ATTR_MAX,
>
>
> How is this new macro different from SKIP_CPU_SYNC?
>

The purpose of this patch is to skip buffer clearing, not to skip
cache opeation.

>>   };
>>
>>
>
> Regards,
> Subash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
