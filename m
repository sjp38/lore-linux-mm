Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 453E16B003D
	for <linux-mm@kvack.org>; Fri, 16 May 2014 04:02:39 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so2295328pbc.0
        for <linux-mm@kvack.org>; Fri, 16 May 2014 01:02:38 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id st6si8071728pab.46.2014.05.16.01.02.35
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 01:02:38 -0700 (PDT)
Message-ID: <5375C619.8010501@lge.com>
Date: Fri, 16 May 2014 17:02:33 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to non-zero
 value
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE>
In-Reply-To: <20140515015301.GA10116@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

Hi,

I've been trying to apply CMA into my platform.
USB host driver generated kernel panic like below when USB mouse is connected,
because I turned on CMA and set the CMA_SIZE_MBYTES value into zero by mistake.

I think the panic is cuased by atomic_pool in arch/arm/mm/dma-mapping.c.
Zero CMA_SIZE_MBYTES value skips CMA initialization and then atomic_pool is not initialized also
because __alloc_from_contiguous is failed in atomic_pool_init().

If CMA_SIZE_MBYTES_MAX is allowed to be zero, there should be defense code to check
CMA is initlaized correctly. And atomic_pool initialization should be done by __alloc_remap_buffer
instead of __alloc_from_contiguous if __alloc_from_contiguous is failed.

IMPO, it is more simple and powerful to restrict CMA_SIZE_MBYTES_MAX configuration to be larger than zero.


[    1.474523] ------------[ cut here ]------------
[    1.479150] WARNING: at arch/arm/mm/dma-mapping.c:496 __dma_alloc.isra.19+0x1b8/0x1e0()
[    1.487160] coherent pool not initialised!
[    1.491249] Modules linked in:
[    1.494317] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.10.19+ #55
[    1.500521] [<80013e20>] (unwind_backtrace+0x0/0xf8) from [<80011c60>] (show_stack+0x10/0x14)
[    1.509064] [<80011c60>] (show_stack+0x10/0x14) from [<8001eedc>] (warn_slowpath_common+0x4c/0x6c)
[    1.518038] [<8001eedc>] (warn_slowpath_common+0x4c/0x6c) from [<8001ef90>] (warn_slowpath_fmt+0x30/0x40)
[    1.527616] [<8001ef90>] (warn_slowpath_fmt+0x30/0x40) from [<80017c28>] (__dma_alloc.isra.19+0x1b8/0x1e0)
[    1.537282] [<80017c28>] (__dma_alloc.isra.19+0x1b8/0x1e0) from [<80017d7c>] (arm_dma_alloc+0x90/0x98)
[    1.546608] [<80017d7c>] (arm_dma_alloc+0x90/0x98) from [<8034a860>] (ohci_init+0x1b0/0x278)
[    1.555062] [<8034a860>] (ohci_init+0x1b0/0x278) from [<80332b0c>] (usb_add_hcd+0x184/0x5b8)
[    1.563500] [<80332b0c>] (usb_add_hcd+0x184/0x5b8) from [<8034b5e0>] (ohci_platform_probe+0xd0/0x174)
[    1.572729] [<8034b5e0>] (ohci_platform_probe+0xd0/0x174) from [<802f196c>] (platform_drv_probe+0x14/0x18)
[    1.582401] [<802f196c>] (platform_drv_probe+0x14/0x18) from [<802f0714>] (driver_probe_device+0x6c/0x1f8)
[    1.592064] [<802f0714>] (driver_probe_device+0x6c/0x1f8) from [<802f092c>] (__driver_attach+0x8c/0x90)
[    1.601465] [<802f092c>] (__driver_attach+0x8c/0x90) from [<802eeec8>] (bus_for_each_dev+0x54/0x88)
[    1.610518] [<802eeec8>] (bus_for_each_dev+0x54/0x88) from [<802efef0>] (bus_add_driver+0xd8/0x230)
[    1.619572] [<802efef0>] (bus_add_driver+0xd8/0x230) from [<802f0de4>] (driver_register+0x78/0x14c)
[    1.628632] [<802f0de4>] (driver_register+0x78/0x14c) from [<806ff018>] (ohci_hcd_mod_init+0x34/0x64)
[    1.637859] [<806ff018>] (ohci_hcd_mod_init+0x34/0x64) from [<8000879c>] (do_one_initcall+0xec/0x14c)
[    1.647088] [<8000879c>] (do_one_initcall+0xec/0x14c) from [<806dab30>] (kernel_init_freeable+0x150/0x220)
[    1.656754] [<806dab30>] (kernel_init_freeable+0x150/0x220) from [<80509f54>] (kernel_init+0x8/0xf8)
[    1.665895] [<80509f54>] (kernel_init+0x8/0xf8) from [<8000e398>] (ret_from_fork+0x14/0x3c)
[    1.674264] ---[ end trace 6f1857db5ef45cb9 ]---
[    1.678880] ohci-platform ohci-platform.0: can't setup
[    1.684027] ohci-platform ohci-platform.0: USB bus 1 deregistered
[    1.690362] ohci-platform: probe of ohci-platform.0 failed with error -12
[    1.697188] ohci-platform ohci-platform.1: Generic Platform OHCI Controller
[    1.704365] ohci-platform ohci-platform.1: new USB bus registered, assigned bus number 1
[    1.712457] ------------[ cut here ]------------
[    1.717096] WARNING: at arch/arm/mm/dma-mapping.c:496 __dma_alloc.isra.19+0x1b8/0x1e0()
[    1.725105] coherent pool not initialised!
[    1.729194] Modules linked in:
[    1.732247] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G        W    3.10.19+ #55
[    1.739404] [<80013e20>] (unwind_backtrace+0x0/0xf8) from [<80011c60>] (show_stack+0x10/0x14)
[    1.747949] [<80011c60>] (show_stack+0x10/0x14) from [<8001eedc>] (warn_slowpath_common+0x4c/0x6c)
[    1.756923] [<8001eedc>] (warn_slowpath_common+0x4c/0x6c) from [<8001ef90>] (warn_slowpath_fmt+0x30/0x40)
[    1.766502] [<8001ef90>] (warn_slowpath_fmt+0x30/0x40) from [<80017c28>] (__dma_alloc.isra.19+0x1b8/0x1e0)
[    1.776168] [<80017c28>] (__dma_alloc.isra.19+0x1b8/0x1e0) from [<80017d7c>] (arm_dma_alloc+0x90/0x98)
[    1.785484] [<80017d7c>] (arm_dma_alloc+0x90/0x98) from [<8034a860>] (ohci_init+0x1b0/0x278)
[    1.793933] [<8034a860>] (ohci_init+0x1b0/0x278) from [<80332b0c>] (usb_add_hcd+0x184/0x5b8)
[    1.802370] [<80332b0c>] (usb_add_hcd+0x184/0x5b8) from [<8034b5e0>] (ohci_platform_probe+0xd0/0x174)
[    1.811597] [<8034b5e0>] (ohci_platform_probe+0xd0/0x174) from [<802f196c>] (platform_drv_probe+0x14/0x18)
[    1.821263] [<802f196c>] (platform_drv_probe+0x14/0x18) from [<802f0714>] (driver_probe_device+0x6c/0x1f8)
[    1.830926] [<802f0714>] (driver_probe_device+0x6c/0x1f8) from [<802f092c>] (__driver_attach+0x8c/0x90)
[    1.840326] [<802f092c>] (__driver_attach+0x8c/0x90) from [<802eeec8>] (bus_for_each_dev+0x54/0x88)
[    1.849379] [<802eeec8>] (bus_for_each_dev+0x54/0x88) from [<802efef0>] (bus_add_driver+0xd8/0x230)
[    1.858432] [<802efef0>] (bus_add_driver+0xd8/0x230) from [<802f0de4>] (driver_register+0x78/0x14c)
[    1.867488] [<802f0de4>] (driver_register+0x78/0x14c) from [<806ff018>] (ohci_hcd_mod_init+0x34/0x64)
[    1.876714] [<806ff018>] (ohci_hcd_mod_init+0x34/0x64) from [<8000879c>] (do_one_initcall+0xec/0x14c)
[    1.885940] [<8000879c>] (do_one_initcall+0xec/0x14c) from [<806dab30>] (kernel_init_freeable+0x150/0x220)
[    1.895601] [<806dab30>] (kernel_init_freeable+0x150/0x220) from [<80509f54>] (kernel_init+0x8/0xf8)
[    1.904741] [<80509f54>] (kernel_init+0x8/0xf8) from [<8000e398>] (ret_from_fork+0x14/0x3c)
[    1.913085] ---[ end trace 6f1857db5ef45cba ]---


I'm adding my patch to restrict CMA_SIZE_MBYTES.
This patch is based on 3.15.0-rc5

-------------------------------- 8< --------------------------------------
 From 9f8e6d3c1f4bdeeeb7af3df7898b773a612c62e8 Mon Sep 17 00:00:00 2001
From: Gioh Kim <gioh.kim@lge.com>
Date: Fri, 16 May 2014 16:15:43 +0900
Subject: [PATCH] drivers/base/Kconfig: restrict CMA size to non-zero value

The size of CMA area must be larger than zero.
If the size is zero, CMA canno be initialized.

Signed-off-by: Gioh Kim <gioh.kim@lge.c>
---
  drivers/base/Kconfig |    7 ++++++-
  1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 4b7b452..19b3578 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -222,13 +222,18 @@ config DMA_CMA
  if  DMA_CMA
  comment "Default contiguous memory area size:"

+config CMA_SIZE_MBYTES_MAX
+       int
+       default 1024
+
  config CMA_SIZE_MBYTES
         int "Size in Mega Bytes"
         depends on !CMA_SIZE_SEL_PERCENTAGE
+       range 1 CMA_SIZE_MBYTES_MAX
         default 16
         help
           Defines the size (in MiB) of the default memory area for Contiguous
-         Memory Allocator.
+         Memory Allocator. This value must be larger than zero.

  config CMA_SIZE_PERCENTAGE
         int "Percentage of total memory"
--
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
