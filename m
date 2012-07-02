Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 750806B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 10:47:52 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M6J00EJ4FRNHXS0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 02 Jul 2012 23:47:50 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M6J000VLFRBM160@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 02 Jul 2012 23:47:50 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1340614047-5824-1-git-send-email-m.szyprowski@samsung.com>
 <1340614047-5824-3-git-send-email-m.szyprowski@samsung.com>
 <20120702140601.124e307e493bff4f05efb0b1@nvidia.com>
In-reply-to: <20120702140601.124e307e493bff4f05efb0b1@nvidia.com>
Subject: RE: [PATCHv4 2/2] ARM: dma-mapping: remove custom consistent dma region
Date: Mon, 02 Jul 2012 16:47:34 +0200
Message-id: <02f601cd5861$a1965b70$e4c31250$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Subash Patel' <subashrp@gmail.com>, 'Minchan Kim' <minchan@kernel.org>

Hello,

On Monday, July 02, 2012 1:06 PM Hiroshi Doyu wrote:

> On Mon, 25 Jun 2012 10:47:27 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > This patch changes dma-mapping subsystem to use generic vmalloc areas
> > for all consistent dma allocations. This increases the total size limit
> > of the consistent allocations and removes platform hacks and a lot of
> > duplicated code.
> >
> > Atomic allocations are served from special pool preallocated on boot,
> > becasue vmalloc areas cannot be reliably created in atomic context.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  Documentation/kernel-parameters.txt |    2 +-
> >  arch/arm/include/asm/dma-mapping.h  |    2 +-
> >  arch/arm/mm/dma-mapping.c           |  505 +++++++++++++----------------------
> >  arch/arm/mm/mm.h                    |    3 +
> >  include/linux/vmalloc.h             |    1 +
> >  mm/vmalloc.c                        |   10 +-
> >  6 files changed, 194 insertions(+), 329 deletions(-)
> >
> ......
> > -static int __init consistent_init(void)
> > -{
> > -       int ret = 0;
> > -       pgd_t *pgd;
> > -       pud_t *pud;
> > -       pmd_t *pmd;
> > -       pte_t *pte;
> > -       int i = 0;
> > -       unsigned long base = consistent_base;
> > -       unsigned long num_ptes = (CONSISTENT_END - base) >> PMD_SHIFT;
> > -
> > -       if (IS_ENABLED(CONFIG_CMA) && !IS_ENABLED(CONFIG_ARM_DMA_USE_IOMMU))
> > -               return 0;
> > -
> > -       consistent_pte = kmalloc(num_ptes * sizeof(pte_t), GFP_KERNEL);
> > -       if (!consistent_pte) {
> > -               pr_err("%s: no memory\n", __func__);
> > -               return -ENOMEM;
> > -       }
> > -
> > -       pr_debug("DMA memory: 0x%08lx - 0x%08lx:\n", base, CONSISTENT_END);
> > -       consistent_head.vm_start = base;
> > -
> > -       do {
> > -               pgd = pgd_offset(&init_mm, base);
> > -
> > -               pud = pud_alloc(&init_mm, pgd, base);
> > -               if (!pud) {
> > -                       pr_err("%s: no pud tables\n", __func__);
> > -                       ret = -ENOMEM;
> > -                       break;
> > -               }
> > -
> > -               pmd = pmd_alloc(&init_mm, pud, base);
> > -               if (!pmd) {
> > -                       pr_err("%s: no pmd tables\n", __func__);
> > -                       ret = -ENOMEM;
> > -                       break;
> > -               }
> > -               WARN_ON(!pmd_none(*pmd));
> > -
> > -               pte = pte_alloc_kernel(pmd, base);
> > -               if (!pte) {
> > -                       pr_err("%s: no pte tables\n", __func__);
> > -                       ret = -ENOMEM;
> > -                       break;
> > -               }
> > -
> > -               consistent_pte[i++] = pte;
> > -               base += PMD_SIZE;
> > -       } while (base < CONSISTENT_END);
> > -
> > -       return ret;
> > -}
> > -core_initcall(consistent_init);
> > -
> >  static void *__alloc_from_contiguous(struct device *dev, size_t size,
> >                                      pgprot_t prot, struct page **ret_page);
> >
> > -static struct arm_vmregion_head coherent_head = {
> > -       .vm_lock        = __SPIN_LOCK_UNLOCKED(&coherent_head.vm_lock),
> > -       .vm_list        = LIST_HEAD_INIT(coherent_head.vm_list),
> > +static void *__alloc_remap_buffer(struct device *dev, size_t size, gfp_t gfp,
> > +                                pgprot_t prot, struct page **ret_page,
> > +                                const void *caller);
> > +
> > +static void *
> > +__dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
> > +       const void *caller)
> > +{
> > +       struct vm_struct *area;
> > +       unsigned long addr;
> > +
> > +       area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> > +                                 caller);
> > +       if (!area)
> > +               return NULL;
> > +       addr = (unsigned long)area->addr;
> > +       area->phys_addr = __pfn_to_phys(page_to_pfn(page));
> > +
> > +       if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
> > +               vunmap((void *)addr);
> > +               return NULL;
> > +       }
> > +       return (void *)addr;
> > +}
> 
> The above "ioremap_page_range()" seems to be executed against normal
> pages(liner kernel mapping) with setting a new prot, because pages were
> passed from __dma_alloc_buffer(){..alloc_pages()...}. For me, this is
> creating another page mapping with different pgprot, and it can cause
> the pgprot inconsistency. This reminds me of the following old patch.
> 
>   [RFC PATCH] Avoid aliasing mappings in DMA coherent allocator
>   http://lists.infradead.org/pipermail/linux-arm-kernel/2012-June/106815.html

If I remember correctly that approach has been dropped because:
a) it consumed a fixed, quite large amount of RAM only for DMA mapping purposes
what was considered as a waste of resources
b) didn't work with some hardware configurations which had DMA zone less than 2MiB.

> I think that this is why ioremap() isn't allowed with RAM.
> 
>   __arm_ioremap_pfn_caller() doens't allow RAM remapping.
> 
>   193 void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
>   194         unsigned long offset, size_t size, unsigned int mtype, void *caller)
>   195 {
>   196         const struct mem_type *type;
>   197         int err;
>   ... .
>   240         /*
>   241          * Don't allow RAM to be mapped - this causes problems with ARMv6+
>   242          */
>   243         if (WARN_ON(pfn_valid(pfn)))
>   244                 return NULL;
>   ...
> 
> So my question is:
> 1, is the above ioremap_page_range() creating another page mapping
>    with a new pgprot, in addition to liner mapping?

Yes it does. My patch does exactly the same thing a the existing __dma_alloc_remap() 
by using a generic vmalloc helper functions.

> 2, If so, is it safe for pgprot inconsistency from different vaddrs?

It probably depends on the hardware. Right now, although specification says this is
a violation, no side effects has been observed and such solution is already used for
years.
 
> I hope that my questins are making sense.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
