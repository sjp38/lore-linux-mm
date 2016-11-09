Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E18FD6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 05:23:40 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id kr7so2305204pab.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 02:23:40 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m10si201945paw.24.2016.11.09.02.23.40
        for <linux-mm@kvack.org>;
        Wed, 09 Nov 2016 02:23:40 -0800 (PST)
Date: Wed, 9 Nov 2016 10:23:36 +0000
From: Brian Starkey <brian.starkey@arm.com>
Subject: Re: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
Message-ID: <20161109102336.GB6009@e106950-lin.cambridge.arm.com>
References: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
 <CGME20161109092808epcas3p3e44ec4c60646f29c765d4cdac27f151c@epcas3p3.samsung.com>
 <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
 <5822F0AE.30101@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5822F0AE.30101@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Wed, Nov 09, 2016 at 06:47:26PM +0900, Jaewon Kim wrote:
>
>
>On 2016e?? 11i?? 09i? 1/4  18:27, Brian Starkey wrote:
>> Hi Jaewon,
>>
>> On Wed, Nov 09, 2016 at 06:10:09PM +0900, Jaewon Kim wrote:
>>> Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
>>> added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
>>> DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
>>> ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
>>> MEMREMAP_WC compared to MEMREMAP_WB.
>>>
>>> Test results on AArch64 by allocating 4MB with putting trace_printk right
>>> before and after memset.
>>>     MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
>>>     MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms
>>>
>>
>> This doesn't look like a good idea to me. The point of coherent memory
>> is to have it non-cached, however WB will make writes hit the cache.
>>
>> Writing to the cache is of course faster than writing to RAM, but
>> that's not what we want to do here.
>>
>> -Brian
>>
>Hi Brian
>
>Thank you for your comment.
>If allocated memory will be used by TZ side, however, I think cacheable
>also can be used to be fast on memset in dma_alloc_from_coherent.

Are you trying to share the buffer between the secure and non-secure
worlds on the CPU? In that case, I don't think caching really helps
you. I'm not a TZ expert, but I believe the two worlds can never
share cached data.

If you want the secure world to see the non-secure world's data, as
far as I know you will need to clean the cache in the non-secure world
to make sure the secure world can see it (and vice-versa). I'd expect
this to remove most of the speed advantage of using WB in the first
place, except for some possible speedup from more efficient bursting.

If you're sharing the buffer with other DMA masters, regardless of
secure/non-secure you're not going to want WB mappings.

>How do you think to add another flag to distinguish this case?

You could look into the streaming DMA API. It will depend on the exact
implementation, but at some point you're still going to have to pay
the penalty of syncing the CPU and device.

-Brian

>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>>> ---
>>> drivers/base/dma-coherent.c | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>>> index 640a7e6..0512a1d 100644
>>> --- a/drivers/base/dma-coherent.c
>>> +++ b/drivers/base/dma-coherent.c
>>> @@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
>>>         goto out;
>>>
>>>     if (flags & DMA_MEMORY_MAP)
>>> -        mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>>> +        mem_base = memremap(phys_addr, size, MEMREMAP_WB);
>>>     else
>>>         mem_base = ioremap(phys_addr, size);
>>>     if (!mem_base)
>>> --
>>> 1.9.1
>>>
>>
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
