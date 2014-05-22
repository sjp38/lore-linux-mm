Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC086B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 21:02:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so1924916pad.18
        for <linux-mm@kvack.org>; Wed, 21 May 2014 18:02:55 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ah3si31327124pad.52.2014.05.21.18.02.54
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 18:02:55 -0700 (PDT)
Message-ID: <537D4CBB.80305@lge.com>
Date: Thu, 22 May 2014 10:02:51 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE> <xa1t1tvo1fas.fsf@mina86.com> <537C5EA3.20709@lge.com> <xa1td2f699j4.fsf@mina86.com>
In-Reply-To: <xa1td2f699j4.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

I appreciate your comments.
The previous patch was ugly. But now it's beautiful! Just 3 lines!

I'm not familiar with kernel patch process.
Can I have your name at Signed-off-by: line?
What tag do I have to write your name in?


--------------------------------- 8< ----------------------------------------------
 From 135c986cfaa5a7291519308b3d47e58bf9f5af25 Mon Sep 17 00:00:00 2001
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
  arch/arm/mm/dma-mapping.c |    7 ++++---
  1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 18e98df..9173a13 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
         if (!pages)
                 goto no_pages;

-       if (IS_ENABLED(CONFIG_DMA_CMA))
+       if (dev_get_cma_area(NULL))
                 ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
                                               atomic_pool_init);
         else
                 ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
                                            atomic_pool_init);
+
         if (ptr) {
                 int i;

@@ -701,7 +702,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
                 addr = __alloc_simple_buffer(dev, size, gfp, &page);
         else if (!(gfp & __GFP_WAIT))
                 addr = __alloc_from_pool(size, &page);
-       else if (!IS_ENABLED(CONFIG_DMA_CMA))
+       else if (!dev_get_cma_area(dev))
                 addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
         else
                 addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
@@ -790,7 +791,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
                 __dma_free_buffer(page, size);
         } else if (__free_from_pool(cpu_addr, size)) {
                 return;
-       } else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
+       } else if (!dev_get_cma_area(dev)) {
                 __dma_free_remap(cpu_addr, size);
                 __dma_free_buffer(page, size);
         } else {
--
1.7.9.5


2014-05-22 i??i ? 5:11, Michal Nazarewicz i?' e,?:
> On Wed, May 21 2014, Gioh Kim <gioh.kim@lge.com> wrote:
>> Date: Tue, 20 May 2014 14:16:20 +0900
>> Subject: [PATCH] arm: dma-mapping: add checking cma area initialized
>>
>> If CMA is turned on and CMA size is set to zero, kernel should
>> behave as if CMA was not enabled at compile time.
>> Every dma allocation should check existence of cma area
>> before requesting memory.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Some minor comments.  Also, I'd love for someone more experienced with
> ARM to take a look at this as well.
>
>> ---
>>    arch/arm/mm/dma-mapping.c |   12 ++++++++----
>>    1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
>> index 18e98df..61f7b93 100644
>> --- a/arch/arm/mm/dma-mapping.c
>> +++ b/arch/arm/mm/dma-mapping.c
>> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>>           unsigned long *bitmap;
>>           struct page *page;
>>           struct page **pages;
>> -       void *ptr;
>> +       void *ptr = NULL;
>
> This is unnecessary any more.
>
>>           int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
>>
>>           bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>> @@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
>>           if (!pages)
>>                   goto no_pages;
>>
>> -       if (IS_ENABLED(CONFIG_DMA_CMA))
>> +       if (IS_ENABLED(CONFIG_DMA_CMA) && dma_contiguous_default_area)
>
> +	if (dev_get_cma_area(NULL))
>
> dev_get_cma_area returns NULL if !IS_ENABLED(CONFIG_DMA_CMA) so there's
> no need to check it explicitly.  And with NULL argument,
> deg_get_cma_area returns the default area.
>
>>                   ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
>>                                                 atomic_pool_init);
>>           else
>>                   ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
>>                                              atomic_pool_init);
>> +
>>           if (ptr) {
>>                   int i;
>>
>> @@ -669,6 +670,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>>           u64 mask = get_coherent_dma_mask(dev);
>>           struct page *page = NULL;
>>           void *addr;
>> +       struct cma *cma = dev_get_cma_area(dev);
>>
>>    #ifdef CONFIG_DMA_API_DEBUG
>>           u64 limit = (mask + 1) & ~mask;
>> @@ -701,7 +703,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>>                   addr = __alloc_simple_buffer(dev, size, gfp, &page);
>>           else if (!(gfp & __GFP_WAIT))
>>                   addr = __alloc_from_pool(size, &page);
>> -       else if (!IS_ENABLED(CONFIG_DMA_CMA))
>> +       else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma)
>
> Like above, just do:
>
> +	else if (!dev_get_cma_area(dev))
>
> This will also allow to drop the a??cmaa?? variable above.
>
>>                   addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
>>           else
>>                   addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
>> @@ -780,6 +782,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
>>                              bool is_coherent)
>>    {
>>           struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
>> +       struct cma *cma = dev_get_cma_area(dev);
>>
>>           if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
>>                   return;
>> @@ -790,7 +793,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
>>                   __dma_free_buffer(page, size);
>>           } else if (__free_from_pool(cpu_addr, size)) {
>>                   return;
>> -       } else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
>> +       } else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma) {
>
> Ditto.
>
>>                   __dma_free_remap(cpu_addr, size);
>>                   __dma_free_buffer(page, size);
>>           } else {
>> @@ -798,6 +801,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
>>                    * Non-atomic allocations cannot be freed with IRQs disabled
>>                    */
>>                   WARN_ON(irqs_disabled());
>> +
>
> Unrelated change.
>
>>                   __free_from_contiguous(dev, page, cpu_addr, size);
>>           }
>>    }
>> --
>> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
