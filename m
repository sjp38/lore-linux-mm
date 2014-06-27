Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 84A8E6B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 05:21:16 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so4324921pab.8
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 02:21:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id tk10si13240025pab.212.2014.06.27.02.21.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jun 2014 02:21:15 -0700 (PDT)
Message-ID: <53AD3788.4090101@codeaurora.org>
Date: Fri, 27 Jun 2014 02:21:12 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/2] arm: Get rid of meminfo
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org> <1396544698-15596-3-git-send-email-lauraa@codeaurora.org> <20140623091754.GD14781@pengutronix.de> <53A8927B.3020409@codeaurora.org> <20140624084936.GJ14781@pengutronix.de>
In-Reply-To: <20140624084936.GJ14781@pengutronix.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, Russell King <linux@arm.linux.org.uk>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Lunn <andrew@lunn.ch>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Daniel Walker <dwalker@fifo99.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, David Brown <davidb@codeaurora.org>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Jason Cooper <jason@lakedaemon.net>, linux-arm-msm@vger.kernel.org, Haojian Zhuang <haojian.zhuang@gmail.com>, Leif Lindholm <leif.lindholm@linaro.org>, Ben Dooks <ben-linux@fluff.org>, linux-arm-kernel@lists.infradead.org, Courtney Cavin <courtney.cavin@sonymobile.com>, Eric Miao <eric.y.miao@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, kernel@pengutronix.de, Andrew Morton <akpm@linux-foundation.org>

On 6/24/2014 1:49 AM, Uwe Kleine-Konig wrote:
> Hi Laura,
> 
> On Mon, Jun 23, 2014 at 01:47:55PM -0700, Laura Abbott wrote:
>> Thanks for the report.
> Thanks for your reply to address it :-)
> Are you already aware of the mail with Message-Id:
> CAGa+x85H510fNGTXJHGYfQybRa2FGgg2NyCgJ8rmjJ6TE7GNbA@mail.gmail.com ?
> Seems to be another fall-out but I think you were not on Cc.
> 
>> On 6/23/2014 2:17 AM, Uwe Kleine-Konig wrote:
>>> This patch is in 3.16-rc1 as 1c2f87c22566cd057bc8cde10c37ae9da1a1bb76
>>> now.
>>>
>>> Unfortunately it makes my efm32 machine unbootable.
>>>
>>> With earlyprintk enabled I get the following output:
>>>
>>> [    0.000000] Booting Linux on physical CPU 0x0
>>> [    0.000000] Linux version 3.15.0-rc1-00028-g1c2f87c22566-dirty (ukleinek@perseus) (gcc version 4.7.2 (OSELAS.Toolchain-2012.12.1) ) #280 PREEMPT Mon Jun 23 11:05:34 CEST 2014
>>> [    0.000000] CPU: ARMv7-M [412fc231] revision 1 (ARMv7M), cr=00000000
>>> [    0.000000] CPU: unknown data cache, unknown instruction cache
>>> [    0.000000] Machine model: Energy Micro Giant Gecko Development Kit
>>> [    0.000000] debug: ignoring loglevel setting.
>>> [    0.000000] bootconsole [earlycon0] enabled
>>> [    0.000000] On node 0 totalpages: 1024
>>> [    0.000000] free_area_init_node: node 0, pgdat 880208f4, node_mem_map 00000000
>>> [    0.000000]   Normal zone: 3840 pages exceeds freesize 1024
>>
>> This looks off. The number of pages for the memmap exceeds the available free
>> size. Working backwards, I think the wrong bounds are being calculated in
>> find_limits in arch/arm/mm/init.c . max_low is now calculated via the current
>> limit but nommu never sets a limit unlike the mmu case. Can you try the
>> following patch and see if it fixes the issue? If this doesn't work, can
>> you share working bootup logs so I can do a bit more compare and contrast?
>>
>> Thanks,
>> Laura
>>
>> ---8<----
>> From 9b19241d577caf91928e26e55413047d1be90feb Mon Sep 17 00:00:00 2001
>> From: Laura Abbott <lauraa@codeaurora.org>
>> Date: Mon, 23 Jun 2014 13:26:56 -0700
>> Subject: [PATCH] arm: Set memblock limit for nommu
>>
>> Commit 1c2f87c (ARM: 8025/1: Get rid of meminfo) changed find_limits
>> to use memblock_get_current_limit for calculating the max_low pfn.
>> nommu targets never actually set a limit on memblock though which
>> means memblock_get_current_limit will just return the default
>> value. Set the memblock_limit to be the end of DDR to make sure
> s/DDR/RAM/ ?
> 
>> bounds are calculated correctly.
> This patch makes my machine boot. Full boot log appended below.
> (Side note: I place my dtb in the SRAM at 0x10000000 but don't add this to
> the available memory because it's only 128 KiB in size and so too small
> to be worth to track. Not sure this is allowed?!)
> 
> Thanks
> Uwe
> 
 
I put this in the patch tracker as 8086/1

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
