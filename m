Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id D90736B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 04:07:03 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so1194267pbc.1
        for <linux-mm@kvack.org>; Wed, 21 May 2014 01:07:03 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id jz3si5181474pbc.89.2014.05.21.01.07.01
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 01:07:03 -0700 (PDT)
Message-ID: <537C5EA3.20709@lge.com>
Date: Wed, 21 May 2014 17:06:59 +0900
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
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>


I change the name of patch into "[PATCH] arm: dma-mapping: add checking cma area initialized",
because I remove fallback allocation and use dev_get_cma_area() to check cma area.
If no cma area exists it goes to __alloc_remap_buffer().

I think this is the same with the fallback allocation but a little simple.

I am sorry but I am not familiar kernel mailing style.
Do I have to send the new patch in new email? Or is it OK to copy the new patch here?

------------------------------ 8< -------------------------------------------
 From e50388f5904105cacea746cd6917c200704f0bf9 Mon Sep 17 00:00:00 2001
From: Gioh Kim <gioh.kim@lge.com>
Date: Tue, 20 May 2014 14:16:20 +0900
Subject: [PATCH] arm: dma-mapping: add checking cma area initialized

If CMA is turned on and CMA size is set to zero, kernel should
behave as if CMA was not enabled at compile time.
Every dma allocation should check existence of cma area
before requesting memory.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
  arch/arm/mm/dma-mapping.c |   12 ++++++++----
  1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 18e98df..61f7b93 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
         unsigned long *bitmap;
         struct page *page;
         struct page **pages;
-       void *ptr;
+       void *ptr = NULL;
         int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);

         bitmap = kzalloc(bitmap_size, GFP_KERNEL);
@@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
         if (!pages)
                 goto no_pages;

-       if (IS_ENABLED(CONFIG_DMA_CMA))
+       if (IS_ENABLED(CONFIG_DMA_CMA) && dma_contiguous_default_area)
                 ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
                                               atomic_pool_init);
         else
                 ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
                                            atomic_pool_init);
+
         if (ptr) {
                 int i;

@@ -669,6 +670,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
         u64 mask = get_coherent_dma_mask(dev);
         struct page *page = NULL;
         void *addr;
+       struct cma *cma = dev_get_cma_area(dev);

  #ifdef CONFIG_DMA_API_DEBUG
         u64 limit = (mask + 1) & ~mask;
@@ -701,7 +703,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
                 addr = __alloc_simple_buffer(dev, size, gfp, &page);
         else if (!(gfp & __GFP_WAIT))
                 addr = __alloc_from_pool(size, &page);
-       else if (!IS_ENABLED(CONFIG_DMA_CMA))
+       else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma)
                 addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
         else
                 addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
@@ -780,6 +782,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
                            bool is_coherent)
  {
         struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
+       struct cma *cma = dev_get_cma_area(dev);

         if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
                 return;
@@ -790,7 +793,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
                 __dma_free_buffer(page, size);
         } else if (__free_from_pool(cpu_addr, size)) {
                 return;
-       } else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
+       } else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma) {
                 __dma_free_remap(cpu_addr, size);
                 __dma_free_buffer(page, size);
         } else {
@@ -798,6 +801,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
                  * Non-atomic allocations cannot be freed with IRQs disabled
                  */
                 WARN_ON(irqs_disabled());
+
                 __free_from_contiguous(dev, page, cpu_addr, size);
         }
  }
--
1.7.9.5


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
