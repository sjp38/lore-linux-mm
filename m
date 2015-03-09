Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id C19CE6B0081
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 17:34:03 -0400 (EDT)
Received: by wevk48 with SMTP id k48so31971992wev.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 14:34:03 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id j4si986900wix.56.2015.03.09.14.34.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 14:34:02 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ARM: OMPA4+: is it expected dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64)); to fail?
Date: Mon, 09 Mar 2015 22:33:45 +0100
Message-ID: <2886917.pqK9QloHOD@wuerfel>
In-Reply-To: <54F8A68B.3080709@linaro.org>
References: <54F8A68B.3080709@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux@arm.linux.org.uk, Tejun Heo <tj@kernel.org>, Tony Lindgren <tony@atomide.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Thursday 05 March 2015 20:55:07 Grygorii.Strashko@linaro.org wrote:
> Hi All,
> 
> Now I can see very interesting behavior related to dma_coerce_mask_and_coherent()
> and friends which I'd like to explain and clarify.
> 
> Below is set of questions I have (why - I explained below):
> - Is expected dma_coerce_mask_and_coherent(DMA_BIT_MASK(64)) and friends to fail on 32 bits HW?

No. dma_coerce_mask_and_coherent() is meant to ignore the actual mask. It's
usually considered a bug to use this function for that reason.

> - What is expected value for max_pfn: max_phys_pfn or max_phys_pfn + 1?
> 
> - What is expected value for struct memblock_region->size: mem_range_size or mem_range_size - 1?
> 
> - What is expected value to be returned by memblock_end_of_DRAM():
>   @base + @size(max_phys_addr + 1) or @base + @size - 1(max_phys_addr)?
> 
> 
> I'm working with BeaglBoard-X15 (AM572x/DRA7xx) board and have following code in OMAP ASOC driver
> which is failed SOMETIMES during the boot with error -EIO.
> === to omap-pcm.c:
> omap_pcm_new() {
> ...
> 	ret = dma_coerce_mask_and_coherent(card->dev, DMA_BIT_MASK(64));
> ^^ failed sometimes
> 	if (ret)
> 		return ret;
> }

The code should be fixed to use dma_set_mask_and_coherent(), which is expected to
fail if the bus is incapable of addressing all RAM within the mask.

> I'd be very appreciated for any comments/clarification on questions I've listed at the
> beginning of my e-mail - there are no patches from my side as I'd like to understand 
> expected behavior of the kernel first (especially taking into account that any
> memblock changes might affect on at least half of arches). 

Is the device you have actually 64-bit capable?

Is the bus it is connected to 64-bit wide?

Does the dma-ranges property of the parent bus reflect the correct address width?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
