Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E8B4F6B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 20:15:13 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so790491pdj.26
        for <linux-mm@kvack.org>; Tue, 20 May 2014 17:15:13 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fy1si3884725pbb.65.2014.05.20.17.15.11
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 17:15:13 -0700 (PDT)
Message-ID: <537BF00E.3030409@lge.com>
Date: Wed, 21 May 2014 09:15:10 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to
 non-zero value
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com> <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE> <xa1td2f91qw5.fsf@mina86.com> <537AA6C7.1040506@lge.com> <537B3EA5.2040302@samsung.com>
In-Reply-To: <537B3EA5.2040302@samsung.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com



2014-05-20 i??i?? 8:38, Marek Szyprowski i?' e,?:
> Hello,
>
> On 2014-05-20 02:50, Gioh Kim wrote:
>>
>>
>> 2014-05-20 i??i ? 4:59, Michal Nazarewicz i?' e,?:
>>> On Sun, May 18 2014, Joonsoo Kim wrote:
>>>> I think that this problem is originated from atomic_pool_init().
>>>> If configured coherent_pool size is larger than default cma size,
>>>> it can be failed even if this patch is applied.
>>
>> The coherent_pool size (atomic_pool.size) should be restricted smaller than cma size.
>>
>> This is another issue, however I think the default atomic pool size is too small.
>> Only one port of USB host needs at most 256Kbytes coherent memory (according to the USB host spec).
>
> This pool is used only for allocation done in atomic context (allocations
> done with GFP_ATOMIC flag), otherwise the standard allocation path is used.
> Are you sure that each usb host port really needs so much memory allocated
> in atomic context?

I don't know why but drivers/usb/host/ohci-hcd.c:ohci_init() calls dma_alloc_coherent with zero gfp.
Therefore it occurs panic if CMA is turned on and CONFIG_CMA_SIZE_MBYTES is zero.
A pointer pool->vaddr is NULL in __alloc_from_pool.

Below is my kernel message.
[ 24.339858] -----------[ cut here ]-----------
[ 24.344535] WARNING: at arch/arm/mm/dma-mapping.c:492 __dma_alloc.isra.19+0x25c/0x2a4()
[ 24.352554] coherent pool not initialised!
[ 24.356644] Modules linked in:
[ 24.359701] CPU: 1 PID: 711 Comm: sh Not tainted 3.10.19+ #42
[ 24.365488] [<800140e0>] (unwind_backtrace+0x0/0xf8) from [<80011f20>] (show_stack+0x10/0x14)
[ 24.374045] [<80011f20>] (show_stack+0x10/0x14) from [<8001f21c>] (warn_slowpath_common+0x4c/0x6c)
[ 24.383022] [<8001f21c>] (warn_slowpath_common+0x4c/0x6c) from [<8001f2d0>] (warn_slowpath_fmt+0x30/0x40)
[ 24.392602] [<8001f2d0>] (warn_slowpath_fmt+0x30/0x40) from [<80017f5c>] (__dma_alloc.isra.19+0x25c/0x2a4)
[ 24.402270] [<80017f5c>] (__dma_alloc.isra.19+0x25c/0x2a4) from [<800180d0>] (arm_dma_alloc+0x90/0x98)
[ 24.411580] [<800180d0>] (arm_dma_alloc+0x90/0x98) from [<8034ab54>] (ohci_init+0x1b0/0x278)
[ 24.420035] [<8034ab54>] (ohci_init+0x1b0/0x278) from [<80332e00>] (usb_add_hcd+0x184/0x5b8)
[ 24.428484] [<80332e00>] (usb_add_hcd+0x184/0x5b8) from [<8034b8d4>] (ohci_platform_probe+0xd0/0x174)
[ 24.437713] [<8034b8d4>] (ohci_platform_probe+0xd0/0x174) from [<802f1cac>] (platform_drv_probe+0x14/0x18)
[ 24.447385] [<802f1cac>] (platform_drv_probe+0x14/0x18) from [<802f0a54>] (driver_probe_device+0x6c/0x1f8)
[ 24.457049] [<802f0a54>] (driver_probe_device+0x6c/0x1f8) from [<802ef16c>] (bus_for_each_drv+0x44/0x8c)
[ 24.466537] [<802ef16c>] (bus_for_each_drv+0x44/0x8c) from [<802f09bc>] (device_attach+0x74/0x80)
[ 24.475416] [<802f09bc>] (device_attach+0x74/0x80) from [<802f0050>] (bus_probe_device+0x84/0xa8)
[ 24.484295] [<802f0050>] (bus_probe_device+0x84/0xa8) from [<802ee89c>] (device_add+0x4c0/0x58c)
[ 24.493088] [<802ee89c>] (device_add+0x4c0/0x58c) from [<802f21b8>] (platform_device_add+0xac/0x214)
[ 24.502227] [<802f21b8>] (platform_device_add+0xac/0x214) from [<8001bf3c>] (lg115x_init_usb+0xbc/0xe4)
[ 24.511618] [<8001bf3c>] (lg115x_init_usb+0xbc/0xe4) from [<80008734>] (do_user_initcalls+0x98/0x128)
[ 24.520843] [<80008734>] (do_user_initcalls+0x98/0x128) from [<80008870>] (proc_write_usercalls+0xac/0xd0)
[ 24.530512] [<80008870>] (proc_write_usercalls+0xac/0xd0) from [<80138f48>] (proc_reg_write+0x58/0x80)
[ 24.539830] [<80138f48>] (proc_reg_write+0x58/0x80) from [<800f0084>] (vfs_write+0xb0/0x1bc)
[ 24.548275] [<800f0084>] (vfs_write+0xb0/0x1bc) from [<800f04d0>] (SyS_write+0x3c/0x70)
[ 24.556287] [<800f04d0>] (SyS_write+0x3c/0x70) from [<8000e5c0>] (ret_fast_syscall+0x0/0x30)
[ 24.564726] --[ end trace c092568e2a263d21 ]--
[ 24.569345] ohci-platform ohci-platform.0: can't setup
[ 24.574498] ohci-platform ohci-platform.0: USB bus 1 deregistered
[ 24.582241] ohci-platform: probe of ohci-platform.0 failed with error -12
[ 24.590496] ohci-platform ohci-platform.1: Generic Platform OHCI Controller
[ 24.598984] ohci-platform ohci-platform.1: new USB bus registered, assigned bus number 1

>
>> If a platform has several ports, it needs more than 1MB.
>> Therefore the default atomic pool size should be at least 1MB.
>>
>>>>
>>>> How about below patch?
>>>> It uses fallback allocation if CMA is failed.
>>>
>>> Yes, I thought about it, but __dma_alloc uses similar code:
>>>
>>>     else if (!IS_ENABLED(CONFIG_DMA_CMA))
>>>         addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
>>>     else
>>>         addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
>>>
>>> so it probably needs to be changed as well.
>>
>> If CMA option is not selected, __alloc_from_contiguous would not be called.
>> We don't need to the fallback allocation.
>>
>> And if CMA option is selected and initialized correctly,
>> the cma allocation can fail in case of no-CMA-memory situation.
>> I thinks in that case we don't need to the fallback allocation also,
>> because it is normal case.
>>
>> Therefore I think the restriction of CMA size option and make CMA work can cover every cases.
>>
>> I think below patch is also good choice.
>> If both of you, Michal and Joonsoo, do not agree with me, please inform me.
>> I will make a patch including option restriction and fallback allocation.
>
> I'm not sure if we need a fallback for failed CMA allocation. The only issue that
> have been mentioned here and needs to be resolved is support for disabling cma by
> kernel command line. Right now it will fails completely.

cma=0 in the kernel command line and CONFIG_CMA_SIZE_MBYTES 0 are set selected_size as zero in dma_contiguous_reserve.
And dma_contiguous_reserve_area cannot be called and atomic_pool is not initialized.

After that dma_alloc_coherent try to allocate via atomic_pool (__alloc_from_pool) or CMA (__alloc_from_contiguous).
Allocation via atomic_pool fails becauseof atomic_pool->vaddr is NULL.
And CMA allocation shouldn't be called because cma=0 or setting CONFIG_CMA_SIZE_MBYTES 0 is the same with disabling CMA.
If cma=0 or CONFIG_CMA_SIZE_MBYTES is 0, __alloc_remap_buffer should be called instead of __alloc_from_contiguous even-if CMA is turned on.

I'm poor at English so I describe the problem in seudo code:

if (CMA is turned on) and ((cma=0 in command line) or (CONFIG_CMA_SIZE_MBYTES=0))
         try to allocate from CMA but CMA is not initialized



>
> Best regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
