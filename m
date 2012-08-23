Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 18B5B6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 02:10:46 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v2 0/4] ARM: dma-mapping: IOMMU atomic allocation
Date: Thu, 23 Aug 2012 09:10:25 +0300
Message-ID: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Hi,

The commit e9da6e9 "ARM: dma-mapping: remove custom consistent dma
region" breaks the compatibility with existing drivers. This causes
the following kernel oops(*1). That driver has called dma_pool_alloc()
to allocate memory from the interrupt context, and it hits
BUG_ON(in_interrpt()) in "get_vm_area_caller()". This patch seris
fixes this problem with making use of the pre-allocate atomic memory
pool which DMA is using in the same way as DMA does now.

Any comment would be really appreciated.

v2:
Don't modify attrs(DMA_ATTR_NO_KERNEL_MAPPING) for atomic allocation. (Marek)
Skip vzalloc (KyongHo, Minchan)
v1:
http://lists.linaro.org/pipermail/linaro-mm-sig/2012-August/002398.html

*1:
[    8.321343] ------------[ cut here ]------------
[    8.325971] kernel BUG at kernel/mm/vmalloc.c:1322!
[    8.333615] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[    8.339436] Modules linked in:
[    8.342496] CPU: 0    Tainted: G        W     (3.4.6-00067-g5d485f7 #67)
[    8.349192] PC is at __get_vm_area_node.isra.29+0x164/0x16c
[    8.354758] LR is at get_vm_area_caller+0x4c/0x54
[    8.359454] pc : [<c011297c>]    lr : [<c011318c>]    psr: 20000193
[    8.359458] sp : c09edca0  ip : c09ec000  fp : ae278000
[    8.370922] r10: f0000000  r9 : c011aa54  r8 : c0a26cb8
[    8.376136] r7 : 00000001  r6 : 000000d0  r5 : 20000008  r4 : c09edca0
[    8.382651] r3 : 00010000  r2 : 20000008  r1 : 00000001  r0 : 00001000
[    8.389166] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    8.396549] Control: 10c5387d  Table: ad98c04a  DAC: 00000015
....
[    9.169162] dfa0: 412fc099 c09ec000 00000000 c000fdd8 c06df1e4 c0a1b080 00000000 00000000
[    9.177329] dfc0: c0a235cc 8000406a 00000000 c0986818 ffffffff ffffffff c0986404 00000000
[    9.185497] dfe0: 00000000 c09bb070 10c5387d c0a19c58 c09bb064 80008044 00000000 00000000
[    9.193673] [<c011297c>] (__get_vm_area_node.isra.29+0x164/0x16c) from [<c011318c>] (get_vm_area_caller+0x4c/0x54)
[    9.204022] [<c011318c>] (get_vm_area_caller+0x4c/0x54) from [<c001aed8>] (__iommu_alloc_remap.isra.14+0x2c/0xfc)
[    9.214276] [<c001aed8>] (__iommu_alloc_remap.isra.14+0x2c/0xfc) from [<c001b06c>] (arm_iommu_alloc_attrs+0xc4/0xf8)
[    9.224795] [<c001b06c>] (arm_iommu_alloc_attrs+0xc4/0xf8) from [<c011aa54>] (pool_alloc_page.constprop.5+0x6c/0xf8)
[    9.235309] [<c011aa54>] (pool_alloc_page.constprop.5+0x6c/0xf8) from [<c011ab60>] (dma_pool_alloc+0x80/0x170)
[    9.245304] [<c011ab60>] (dma_pool_alloc+0x80/0x170) from [<c03cbbcc>] (tegra_build_dtd+0x48/0x14c)
[    9.254344] [<c03cbbcc>] (tegra_build_dtd+0x48/0x14c) from [<c03cbd4c>] (tegra_req_to_dtd+0x7c/0xa8)
[    9.263467] [<c03cbd4c>] (tegra_req_to_dtd+0x7c/0xa8) from [<c03cc140>] (tegra_ep_queue+0x154/0x33c)
[    9.272592] [<c03cc140>] (tegra_ep_queue+0x154/0x33c) from [<c03dd5b4>] (composite_setup+0x364/0x6d4)
[    9.281804] [<c03dd5b4>] (composite_setup+0x364/0x6d4) from [<c03dd9dc>] (android_setup+0xb8/0x14c)
[    9.290843] [<c03dd9dc>] (android_setup+0xb8/0x14c) from [<c03cd144>] (setup_received_irq+0xbc/0x270)
[    9.300053] [<c03cd144>] (setup_received_irq+0xbc/0x270) from [<c03cda64>] (tegra_udc_irq+0x2ac/0x2c4)
[    9.309353] [<c03cda64>] (tegra_udc_irq+0x2ac/0x2c4) from [<c00b5708>] (handle_irq_event_percpu+0x78/0x2e0)
[    9.319087] [<c00b5708>] (handle_irq_event_percpu+0x78/0x2e0) from [<c00b59b4>] (handle_irq_event+0x44/0x64)
[    9.328907] [<c00b59b4>] (handle_irq_event+0x44/0x64) from [<c00b8688>] (handle_fasteoi_irq+0xc4/0x16c)
[    9.338294] [<c00b8688>] (handle_fasteoi_irq+0xc4/0x16c) from [<c00b4f14>] (generic_handle_irq+0x34/0x48)
[    9.347858] [<c00b4f14>] (generic_handle_irq+0x34/0x48) from [<c000f6f4>] (handle_IRQ+0x54/0xb4)
[    9.356637] [<c000f6f4>] (handle_IRQ+0x54/0xb4) from [<c00084b0>] (gic_handle_irq+0x2c/0x60)
[    9.365068] [<c00084b0>] (gic_handle_irq+0x2c/0x60) from [<c000e900>] (__irq_svc+0x40/0x70)
[    9.373405] Exception stack(0xc09edf10 to 0xc09edf58)
[    9.378447] df00:                                     00000000 000f4240 00000003 00000000
[    9.386615] df20: 00000000 e55bbc00 ef66f3ca 00000001 00000000 412fc099 c0abb9c8 00000000
[    9.394781] df40: 3b9ac9ff c09edf58 c027a9bc c0042880 20000113 ffffffff
[    9.401396] [<c000e900>] (__irq_svc+0x40/0x70) from [<c0042880>] (tegra_idle_enter_lp3+0x68/0x78)
[    9.410272] [<c0042880>] (tegra_idle_enter_lp3+0x68/0x78) from [<c04701d4>] (cpuidle_idle_call+0xdc/0x3a4)
[    9.419922] [<c04701d4>] (cpuidle_idle_call+0xdc/0x3a4) from [<c000fdd8>] (cpu_idle+0xd8/0x134)
[    9.428612] [<c000fdd8>] (cpu_idle+0xd8/0x134) from [<c0986818>] (start_kernel+0x27c/0x2cc)
[    9.436952] Code: e1a00004 e3a04000 eb002265 eaffffe0 (e7f001f2)
[    9.443038] ---[ end trace 1b75b31a2719ed24 ]---
[    9.447645] Kernel panic - not syncing: Fatal exception in interrupt

Hiroshi Doyu (4):
  ARM: dma-mapping: Refactor out to introduce __in_atomic_pool
  ARM: dma-mapping: Use kzalloc() with GFP_ATOMIC
  ARM: dma-mapping: Refactor out to introduce __alloc_fill_pages
  ARM: dma-mapping: IOMMU allocates pages from atomic_pool with
    GFP_ATOMIC

 arch/arm/mm/dma-mapping.c |  102 ++++++++++++++++++++++++++++++++++-----------
 1 files changed, 77 insertions(+), 25 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
