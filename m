Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3696B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 04:47:24 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id fp5so41471175pac.6
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 01:47:24 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hb8si19184020pac.52.2016.11.09.01.47.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 01:47:23 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OGD00J6PCIX8RE0@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 09 Nov 2016 18:47:21 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
References: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
 <CGME20161109092808epcas3p3e44ec4c60646f29c765d4cdac27f151c@epcas3p3.samsung.com>
 <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <5822F0AE.30101@samsung.com>
Date: Wed, 09 Nov 2016 18:47:26 +0900
In-reply-to: <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Starkey <brian.starkey@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016e?? 11i?? 09i? 1/4  18:27, Brian Starkey wrote:
> Hi Jaewon,
>
> On Wed, Nov 09, 2016 at 06:10:09PM +0900, Jaewon Kim wrote:
>> Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
>> added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
>> DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
>> ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
>> MEMREMAP_WC compared to MEMREMAP_WB.
>>
>> Test results on AArch64 by allocating 4MB with putting trace_printk right
>> before and after memset.
>>     MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
>>     MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms
>>
>
> This doesn't look like a good idea to me. The point of coherent memory
> is to have it non-cached, however WB will make writes hit the cache.
>
> Writing to the cache is of course faster than writing to RAM, but
> that's not what we want to do here.
>
> -Brian
>
Hi Brian

Thank you for your comment.
If allocated memory will be used by TZ side, however, I think cacheable
also can be used to be fast on memset in dma_alloc_from_coherent.
How do you think to add another flag to distinguish this case?
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>> drivers/base/dma-coherent.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>> index 640a7e6..0512a1d 100644
>> --- a/drivers/base/dma-coherent.c
>> +++ b/drivers/base/dma-coherent.c
>> @@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
>>         goto out;
>>
>>     if (flags & DMA_MEMORY_MAP)
>> -        mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>> +        mem_base = memremap(phys_addr, size, MEMREMAP_WB);
>>     else
>>         mem_base = ioremap(phys_addr, size);
>>     if (!mem_base)
>> -- 
>> 1.9.1
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
