Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D977A6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 20:41:33 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so85035732pac.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 17:41:33 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id h4si2009796pgn.139.2016.11.09.17.41.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 17:41:32 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OGE02H6GKP7V3D0@mailout4.samsung.com> for linux-mm@kvack.org;
 Thu, 10 Nov 2016 10:41:31 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
References: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
 <CGME20161109092808epcas3p3e44ec4c60646f29c765d4cdac27f151c@epcas3p3.samsung.com>
 <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
 <5822F0AE.30101@samsung.com>
 <20161109102336.GB6009@e106950-lin.cambridge.arm.com>
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <5823D057.2050509@samsung.com>
Date: Thu, 10 Nov 2016 10:41:43 +0900
In-reply-to: <20161109102336.GB6009@e106950-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Starkey <brian.starkey@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@samsung.com

Hi

On 2016e?? 11i?? 09i? 1/4  19:23, Brian Starkey wrote:
> Hi,
>
> On Wed, Nov 09, 2016 at 06:47:26PM +0900, Jaewon Kim wrote:
>>
>>
>> On 2016e?? 11i?? 09i? 1/4  18:27, Brian Starkey wrote:
>>> Hi Jaewon,
>>>
>>> On Wed, Nov 09, 2016 at 06:10:09PM +0900, Jaewon Kim wrote:
>>>> Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
>>>> added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
>>>> DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
>>>> ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
>>>> MEMREMAP_WC compared to MEMREMAP_WB.
>>>>
>>>> Test results on AArch64 by allocating 4MB with putting trace_printk right
>>>> before and after memset.
>>>>     MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
>>>>     MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms
>>>>
>>>
>>> This doesn't look like a good idea to me. The point of coherent memory
>>> is to have it non-cached, however WB will make writes hit the cache.
>>>
>>> Writing to the cache is of course faster than writing to RAM, but
>>> that's not what we want to do here.
>>>
>>> -Brian
>>>
>> Hi Brian
>>
>> Thank you for your comment.
>> If allocated memory will be used by TZ side, however, I think cacheable
>> also can be used to be fast on memset in dma_alloc_from_coherent.
>
> Are you trying to share the buffer between the secure and non-secure
> worlds on the CPU? In that case, I don't think caching really helps
> you. I'm not a TZ expert, but I believe the two worlds can never
> share cached data.
I do not want memory sharing between the secure and non-secure worlds.
I just want faster allocation.

I am not a TZ expert, either. I also think they cannot share cached data.
As far as I know secure world can decide its cache policy with secure
world page table regardless of non-secure world.
> If you want the secure world to see the non-secure world's data, as
> far as I know you will need to clean the cache in the non-secure world
> to make sure the secure world can see it (and vice-versa). I'd expect
> this to remove most of the speed advantage of using WB in the first
> place, except for some possible speedup from more efficient bursting.
Yes I also think non-secure world need to clean the cache before secure world
access the memory region to avoid invalid data issue. But if other software
like Linux driver or hypervisor do the cache cleaning, or engineer confirm,
then we may be able to use MEMREMAP_WB or just skipping memset for faster
memory allocation in dma_alloc_from_coherent.
>
> If you're sharing the buffer with other DMA masters, regardless of
> secure/non-secure you're not going to want WB mappings.
>
If there is a scenario where another DMA master works on this memory,
an engineer, I think, need to consider cache clean if he/she uses WB.
>> How do you think to add another flag to distinguish this case?
>
> You could look into the streaming DMA API. It will depend on the exact
> implementation, but at some point you're still going to have to pay
> the penalty of syncing the CPU and device.
>
> -Brian
>
I cannot find DMA API and flag for WB. So I am considering additional flag
to meet my request. In my opinion the flag can be either WB or non-zeroing.

For case #1 - DMA_MEMORY_MAP_WB
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -32,7 +32,9 @@ static bool dma_init_coherent_memory(
        if (!size)
                goto out;
 
-       if (flags & DMA_MEMORY_MAP)
+       if (flags & DMA_MEMORY_MAP_WB)
+               mem_base = memremap(phys_addr, size, MEMREMAP_WB);
+       else if (flags & DMA_MEMORY_MAP)
                mem_base = memremap(phys_addr, size, MEMREMAP_WC);
        else
                mem_base = ioremap(phys_addr, size);

For case #2 - DMA_MEMORY_MAP_NOZEROING
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -190,6 +190,8 @@ int dma_alloc_from_coherent(struct device *dev, ssize_t size,
        *ret = mem->virt_base + (pageno << PAGE_SHIFT);
        dma_memory_map = (mem->flags & DMA_MEMORY_MAP);
        spin_unlock_irqrestore(&mem->spinlock, flags);
+       if (mem->flags & DMA_MEMORY_MAP_NOZEROING)
+               return 1;
        if (dma_memory_map)
                memset(*ret, 0, size);
        else

Can I get your comment?

Thank you
Jaewon Kim

>>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>>>> ---
>>>> drivers/base/dma-coherent.c | 2 +-
>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>>>> index 640a7e6..0512a1d 100644
>>>> --- a/drivers/base/dma-coherent.c
>>>> +++ b/drivers/base/dma-coherent.c
>>>> @@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
>>>>         goto out;
>>>>
>>>>     if (flags & DMA_MEMORY_MAP)
>>>> -        mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>>>> +        mem_base = memremap(phys_addr, size, MEMREMAP_WB);
>>>>     else
>>>>         mem_base = ioremap(phys_addr, size);
>>>>     if (!mem_base)
>>>> -- 
>>>> 1.9.1
>>>>
>>>
>>>
>>>
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
