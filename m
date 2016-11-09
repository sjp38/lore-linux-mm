Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 183496B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 04:27:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id l66so92150079pfl.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 01:27:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i8si41208972pgp.114.2016.11.09.01.27.33
        for <linux-mm@kvack.org>;
        Wed, 09 Nov 2016 01:27:33 -0800 (PST)
Date: Wed, 9 Nov 2016 09:27:26 +0000
From: Brian Starkey <brian.starkey@arm.com>
Subject: Re: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
Message-ID: <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
References: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jaewon,

On Wed, Nov 09, 2016 at 06:10:09PM +0900, Jaewon Kim wrote:
>Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
>added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
>DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
>ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
>MEMREMAP_WC compared to MEMREMAP_WB.
>
>Test results on AArch64 by allocating 4MB with putting trace_printk right
>before and after memset.
>	MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
>	MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms
>

This doesn't look like a good idea to me. The point of coherent memory
is to have it non-cached, however WB will make writes hit the cache.

Writing to the cache is of course faster than writing to RAM, but
that's not what we want to do here.

-Brian

>Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>---
> drivers/base/dma-coherent.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>index 640a7e6..0512a1d 100644
>--- a/drivers/base/dma-coherent.c
>+++ b/drivers/base/dma-coherent.c
>@@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
> 		goto out;
>
> 	if (flags & DMA_MEMORY_MAP)
>-		mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>+		mem_base = memremap(phys_addr, size, MEMREMAP_WB);
> 	else
> 		mem_base = ioremap(phys_addr, size);
> 	if (!mem_base)
>-- 
>1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
