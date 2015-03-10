Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D1027900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 13:35:46 -0400 (EDT)
Received: by lbvp9 with SMTP id p9so3378288lbv.10
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 10:35:46 -0700 (PDT)
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com. [209.85.215.43])
        by mx.google.com with ESMTPS id wm3si716505lbb.146.2015.03.10.10.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 10:35:44 -0700 (PDT)
Received: by labge10 with SMTP id ge10so3352622lab.7
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 10:35:43 -0700 (PDT)
From: "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Message-ID: <54FF2B6D.1030005@linaro.org>
Date: Tue, 10 Mar 2015 19:35:41 +0200
MIME-Version: 1.0
Subject: Re: ARM: OMPA4+: is it expected dma_coerce_mask_and_coherent(dev,
 DMA_BIT_MASK(64)); to fail?
References: <54F8A68B.3080709@linaro.org> <2886917.pqK9QloHOD@wuerfel>
In-Reply-To: <2886917.pqK9QloHOD@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux@arm.linux.org.uk, Tejun Heo <tj@kernel.org>, Tony Lindgren <tony@atomide.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

Hi Arnd,

On 03/09/2015 11:33 PM, Arnd Bergmann wrote:
> On Thursday 05 March 2015 20:55:07 Grygorii.Strashko@linaro.org wrote:
>> Hi All,
>>
>> Now I can see very interesting behavior related to dma_coerce_mask_and_coherent()
>> and friends which I'd like to explain and clarify.
>>
>> Below is set of questions I have (why - I explained below):
>> - Is expected dma_coerce_mask_and_coherent(DMA_BIT_MASK(64)) and friends to fail on 32 bits HW?
> 
> No. dma_coerce_mask_and_coherent() is meant to ignore the actual mask. It's
> usually considered a bug to use this function for that reason.
> 
>> - What is expected value for max_pfn: max_phys_pfn or max_phys_pfn + 1?
>>
>> - What is expected value for struct memblock_region->size: mem_range_size or mem_range_size - 1?
>>
>> - What is expected value to be returned by memblock_end_of_DRAM():
>>    @base + @size(max_phys_addr + 1) or @base + @size - 1(max_phys_addr)?
>>
>>
>> I'm working with BeaglBoard-X15 (AM572x/DRA7xx) board and have following code in OMAP ASOC driver
>> which is failed SOMETIMES during the boot with error -EIO.
>> === to omap-pcm.c:
>> omap_pcm_new() {
>> ...
>> 	ret = dma_coerce_mask_and_coherent(card->dev, DMA_BIT_MASK(64));
>> ^^ failed sometimes
>> 	if (ret)
>> 		return ret;
>> }
> 
> The code should be fixed to use dma_set_mask_and_coherent(), which is expected to
> fail if the bus is incapable of addressing all RAM within the mask.
> 
>> I'd be very appreciated for any comments/clarification on questions I've listed at the
>> beginning of my e-mail - there are no patches from my side as I'd like to understand
>> expected behavior of the kernel first (especially taking into account that any
>> memblock changes might affect on at least half of arches).
> 
> Is the device you have actually 64-bit capable?
> 
> Is the bus it is connected to 64-bit wide?

As I mentioned before - The device was fixed by switching to use 32 bit mask
"The issue with omap-pcm was simply fixed by using DMA_BIT_MASK(32), ".

> 
> Does the dma-ranges property of the parent bus reflect the correct address width?

dma-ranges is not used and all devices are created with default mask DMA_BIT_MASK(32);


My goal was to clarify above questions (first of all), because on my HW I can see
different values of  max_pfn, max_mapnr and memblock configuration depending on 
CONFIG_ARM_LPAE=n|y and when RAM is defined as: start = 0x80000000 size = 0x80000000.
(and also between kernels 3.14 and LKML).

Looks like such RAM configuration is a corner case, which is not always handled as expected
(and how is it expected to be handled?).
For example:
before commit ARM: 8025/1: Get rid of meminfo
- registered RAM  start = 0x80000000 size = 0x80000000 will be adjusted by arm_add_memory()
and final RAM configuration will be start = 0x80000000 size = 0x7FFFF000
after this commit:
- code will try to register start = 0x80000000 size = 0x80000000, but memblock will
adjust it to start = 0x80000000 size = 0x7fffffff.



-- 
regards,
-grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
