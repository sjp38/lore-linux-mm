Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 301966B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 12:04:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q126so24236466pgq.7
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:04:36 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id y73si974390pfb.364.2017.11.15.09.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 09:04:33 -0800 (PST)
MIME-version: 1.0
Content-transfer-encoding: 8BIT
Content-type: text/plain; charset="utf-8"
Subject: Re: [RFC PATCH] drivers: base: dma-coherent: find free region
 without alignment
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <5A0C7391.3090801@samsung.com>
Date: Thu, 16 Nov 2017 02:04:17 +0900
In-reply-to: <94f35456-b661-908a-bdc0-ddd74cbaf9ec@samsung.com>
References: <CGME20171114084234epcas2p44ac00494b49aa798f709c5bbdf92127a@epcas2p4.samsung.com>
	<20171114084229.13512-1-jaewon31.kim@samsung.com>
	<94f35456-b661-908a-bdc0-ddd74cbaf9ec@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, hch@lst.de, robin.murphy@arm.com, gregkh@linuxfoundation.org, iommu@lists.linux-foundation.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello Marek

On 2017e?? 11i?? 14i? 1/4  20:07, Marek Szyprowski wrote:
> Hi Jaewon,
>
> On 2017-11-14 09:42, Jaewon Kim wrote:
>> dma-coherent uses bitmap API which internally consider align based on the
>> requested size. Depending on some usage pattern, using align, I think, may
>> be good for fast search and anti-fragmentation. But with the align, an
>> allocation may be failed.
>>
>> This is a example, total size is 30MB, only few memory at front is being
>> used, and 9MB is being requsted. Then 9MB will be aligned to 16MB. The
>> first try on offset 0MB will be failed because of others already using. The
>> second try on offset 16MB will be failed because of ouf of bound.
>>
>> So if the align is not necessary on dma-coherent, this patch removes the
>> align policy to allow allocation without increasing the total size.
>
> You are right that keeping strict alignment is waste of memory for large
> allocations. However for the smaller ones, typically under 1MiB, it helps
> to reduce memory fragmentation. The alignment of the allocated buffers is
> de-facto guaranteed by the memory management framework in Linux kernel
> and there are drivers that depends on this feature.
>
> Maybe it would make sense to keep alignment for buffers smaller than some
> predefined value (like 1MiB), something similar to config
> ARM_DMA_IOMMU_ALIGNMENT in arch/arm/Kconfig. Otherwise I would expect that
> some drivers will be broken by this patch.
Thank you for your comment.

I looked ARM_DMA_IOMMU_ALIGNMENT in ARM, it looks similar but it is using
bitmap_find_next_zero_area rather than bitmap_find_free_region. bitmap_find_next_zero_area
apply aligning only onto offset but not onto size. So I think ARM_DMA_IOMMU_ALIGNMENT way
is not perfect on this dma-coherent APIs which tries to align even on size.

Let me say another way where each reserved_mem from device tree can decide if it wants aligning.
This could be implemented like below. I need to change other dma-coherent APIs though.
I will wait for your comment on this.

--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -17,6 +17,7 @@ struct dma_coherent_mem {
        unsigned long   *bitmap;
        spinlock_t      spinlock;
        bool            use_dev_dma_pfn_offset;
+       bool            no_align;
 };
 
 static struct dma_coherent_mem *dma_coherent_default_memory __ro_after_init;
@@ -162,7 +163,6 @@ EXPORT_SYMBOL(dma_mark_declared_memory_occupied);
 static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
                ssize_t size, dma_addr_t *dma_handle)
 {
-       int order = get_order(size);
        unsigned long flags;
        int pageno;
        void *ret;
@@ -172,9 +172,21 @@ static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
        if (unlikely(size > (mem->size << PAGE_SHIFT)))
                goto err;
 
-       pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
-       if (unlikely(pageno < 0))
-               goto err;
+       if (mem->no_align) {
+               int nr_page = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+               pageno = bitmap_find_next_zero_area(mem->bitmap, mem->size, 0,
+                                                   nr_page, 0);
+               if (unlikely(pageno >= mem->size))
+                       goto err;
+               bitmap_set(mem->bitmap, pageno, nr_page);
+       } else {
+               int order = get_order(size);
+
+               pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
+               if (unlikely(pageno < 0))
+                       goto err;
+       }
 
        /*
         * Memory was found in the coherent area.
@@ -346,6 +358,7 @@ static struct reserved_mem *dma_reserved_default_memory __initdata;
 static int rmem_dma_device_init(struct reserved_mem *rmem, struct device *dev)
 {
        struct dma_coherent_mem *mem = rmem->priv;
+       unsigned long node = rmem->fdt_node;
        int ret;
 
        if (!mem) {
@@ -360,6 +373,8 @@ static int rmem_dma_device_init(struct reserved_mem *rmem, struct device *dev)
        }
        mem->use_dev_dma_pfn_offset = true;
        rmem->priv = mem;
+       if (of_get_flat_dt_prop(node, "no-align", NULL))
+               mem->no_align = true;
        dma_assign_coherent_memory(dev, mem);
        return 0;
 }


>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>   drivers/base/dma-coherent.c | 8 +++++---
>>   1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>> index 744f64f43454..b86a96d0cd07 100644
>> --- a/drivers/base/dma-coherent.c
>> +++ b/drivers/base/dma-coherent.c
>> @@ -162,7 +162,7 @@ EXPORT_SYMBOL(dma_mark_declared_memory_occupied);
>>   static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
>>           ssize_t size, dma_addr_t *dma_handle)
>>   {
>> -    int order = get_order(size);
>> +    int nr_page = PAGE_ALIGN(size) >> PAGE_SHIFT;
>>       unsigned long flags;
>>       int pageno;
>>       void *ret;
>> @@ -172,9 +172,11 @@ static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
>>       if (unlikely(size > (mem->size << PAGE_SHIFT)))
>>           goto err;
>>   -    pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
>> -    if (unlikely(pageno < 0))
>> +    pageno = bitmap_find_next_zero_area(mem->bitmap, mem->size, 0,
>> +                        nr_page, 0);
>> +    if (unlikely(pageno >= mem->size)) {
>>           goto err;
>> +    bitmap_set(mem->bitmap, pageno, nr_page);
>>         /*
>>        * Memory was found in the coherent area.
>
> Best regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
