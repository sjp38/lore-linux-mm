Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 931CA6B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 20:24:53 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so804238pdj.6
        for <linux-mm@kvack.org>; Tue, 20 May 2014 17:24:53 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id yg6si26781948pab.98.2014.05.20.17.24.51
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 17:24:52 -0700 (PDT)
Message-ID: <537BF252.6030905@lge.com>
Date: Wed, 21 May 2014 09:24:50 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE> <xa1t1tvo1fas.fsf@mina86.com>
In-Reply-To: <xa1t1tvo1fas.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>



2014-05-21 i??i ? 3:22, Michal Nazarewicz i?' e,?:
> On Mon, May 19 2014, Joonsoo Kim wrote:
>> On Tue, May 20, 2014 at 02:57:47PM +0900, Gioh Kim wrote:
>>>
>>> Thanks for your advise, Michal Nazarewicz.
>>>
>>> Having discuss with Joonsoo, I'm adding fallback allocation after __alloc_from_contiguous().
>>> The fallback allocation works if CMA kernel options is turned on but CMA size is zero.
>>
>> Hello, Gioh.
>>
>> I also mentioned the case where devices have their specific cma_area.
>> It means that this device needs memory with some contraint.
>> Although I'm not familiar with DMA infrastructure, I think that
>> we should handle this case.
>>
>> How about below patch?
>>
>> ------------>8----------------
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 6b00be1..4023434 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>>   	unsigned long *bitmap;
>>   	struct page *page;
>>   	struct page **pages;
>> -	void *ptr;
>> +	void *ptr = NULL;
>>   	int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
>>
>>   	bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>> @@ -393,7 +393,8 @@ static int __init atomic_pool_init(void)
>>   	if (IS_ENABLED(CONFIG_DMA_CMA))
>>   		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
>>   					      atomic_pool_init);
>> -	else
>> +
>> +	if (!ptr)
>>   		ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
>>   					   atomic_pool_init);
>>   	if (ptr) {
>> @@ -701,10 +702,22 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>>   		addr = __alloc_simple_buffer(dev, size, gfp, &page);
>>   	else if (!(gfp & __GFP_WAIT))
>>   		addr = __alloc_from_pool(size, &page);
>> -	else if (!IS_ENABLED(CONFIG_DMA_CMA))
>> -		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
>> -	else
>> -		addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
>> +	else {
>> +		if (IS_ENABLED(CONFIG_DMA_CMA)) {
>> +			addr = __alloc_from_contiguous(dev, size, prot,
>> +							&page, caller);
>> +			/*
>> +			 * Device specific cma_area means that
>> +			 * this device needs memory with some contraint.
>> +			 * So, we can't fall through general remap allocation.
>> +			 */
>> +			if (!addr && dev && dev->cma_area)
>> +				return NULL;
>> +		}
>> +
>> +		addr = __alloc_remap_buffer(dev, size, gfp, prot,
>> +							&page, caller);
>> +	}
>
> __arm_dma_free will have to be changed to handle the fallback as well.
> But perhaps Marek is right and there should be no fallback for regular
> allocations?  Than again, non-CMA allocation should be performed at
> least in the case of cma=0.


I think in the cases of cma=0, CONFIG_CMA_SIZE_SEL_MBYTES=0 and CONFIG_CMA_SIZE_SEL_PERCENTAGE=0
kernel should be act as like CMA is not turned on.
non-CMA allocation should be performed in the cases.


I will send a patch soon with __arm_dma_free changes.


>
>>
>>   	if (addr)
>>   		*handle = pfn_to_dma(dev, page_to_pfn(page));
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
