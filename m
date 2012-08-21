Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 86A6F6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 07:22:41 -0400 (EDT)
Date: Tue, 21 Aug 2012 14:22:35 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [PATCHv6 2/2] ARM: dma-mapping: remove custom consistent dma
 region
Message-ID: <20120821142235.97984abc9ad98d01015a3338@nvidia.com>
In-Reply-To: <1343636899-19508-3-git-send-email-m.szyprowski@samsung.com>
References: <1343636899-19508-1-git-send-email-m.szyprowski@samsung.com>
	<1343636899-19508-3-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Subash Patel <subashrp@gmail.com>, Minchan Kim <minchan@kernel.org>

Hi,

On Mon, 30 Jul 2012 10:28:19 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> This patch changes dma-mapping subsystem to use generic vmalloc areas
> for all consistent dma allocations. This increases the total size limit
> of the consistent allocations and removes platform hacks and a lot of
> duplicated code.
> 
> Atomic allocations are served from special pool preallocated on boot,
> because vmalloc areas cannot be reliably created in atomic context.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  Documentation/kernel-parameters.txt |    2 +-
>  arch/arm/include/asm/dma-mapping.h  |    2 +-
>  arch/arm/mm/dma-mapping.c           |  486 ++++++++++++-----------------------
>  arch/arm/mm/mm.h                    |    3 +
>  include/linux/vmalloc.h             |    1 +
>  mm/vmalloc.c                        |   10 +-
>  6 files changed, 181 insertions(+), 323 deletions(-)
> 
...
> @@ -1117,61 +984,32 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
>   * Create a CPU mapping for a specified pages
>   */
>  static void *
> -__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot)
> +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot,
> +                   const void *caller)
>  {
> -       struct arm_vmregion *c;
> -       size_t align;
> -       size_t count = size >> PAGE_SHIFT;
> -       int bit;
> +       unsigned int i, nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> +       struct vm_struct *area;
> +       unsigned long p;
> 
> -       if (!consistent_pte[0]) {
> -               pr_err("%s: not initialised\n", __func__);
> -               dump_stack();
> +       area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> +                                 caller);
> +       if (!area)

This patch replaced the custom "consistent_pte" with
get_vm_area_caller()", which breaks the compatibility with the
existing driver. This causes the following kernel oops(*1). That
driver has called dma_pool_alloc() to allocate memory from the
interrupt context, and it hits BUG_ON(in_interrpt()) in
"get_vm_area_caller()"(*2). Regardless of the badness of allocation
from interrupt handler in the driver, I have the following question.

The following "__get_vm_area_node()" can take gfp_mask, it means that
this function is expected to be called from atomic context, but why
it's _NOT_ allowed _ONLY_ from interrupt context?

According to the following definitions, "in_interrupt()" is in "in_atomic()".

#define in_interrupt()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK))
#define in_atomic()	((preempt_count() & ~PREEMPT_ACTIVE) != 0)

Does anyone know why BUG_ON(in_interrupt()) is set in __get_vm_area_node(*3)?

*2:
  static struct vm_struct *__get_vm_area_node(unsigned long size,
                  unsigned long align, unsigned long flags, unsigned long start,
                  unsigned long end, int node, gfp_t gfp_mask, const void *caller)
  {
          struct vmap_area *va;
          struct vm_struct *area;

          BUG_ON(in_interrupt());
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^*3:
*1:
[    8.321343] ------------[ cut here ]------------
[    8.325971] kernel BUG at /home/hdoyu/mydroid-k340-cardhu/kernel/mm/vmalloc.c:1322!
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
