Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F39926B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:10:05 -0400 (EDT)
Date: Wed, 22 Aug 2012 13:09:59 +0300
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [PATCHv6 2/2] ARM: dma-mapping: remove custom consistent dma
 region
Message-ID: <20120822130959.183933b51c45c4245e44478d@nvidia.com>
In-Reply-To: <00c301cd7fad$cfc7f3f0$6f57dbd0$%szyprowski@samsung.com>
References: <1343636899-19508-1-git-send-email-m.szyprowski@samsung.com>
	<1343636899-19508-3-git-send-email-m.szyprowski@samsung.com>
	<20120821142235.97984abc9ad98d01015a3338@nvidia.com>
	<20120821.151521.702882672715065253.hdoyu@nvidia.com>
	<00c301cd7fad$cfc7f3f0$6f57dbd0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Hi Marek,

On Tue, 21 Aug 2012 17:01:08 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> > > > -__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot)
> > > > +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot,
> > > > +                   const void *caller)
> > > >  {
> > > > -       struct arm_vmregion *c;
> > > > -       size_t align;
> > > > -       size_t count = size >> PAGE_SHIFT;
> > > > -       int bit;
> > > > +       unsigned int i, nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > > > +       struct vm_struct *area;
> > > > +       unsigned long p;
> > > >
> > > > -       if (!consistent_pte[0]) {
> > > > -               pr_err("%s: not initialised\n", __func__);
> > > > -               dump_stack();
> > > > +       area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> > > > +                                 caller);
> > > > +       if (!area)
> > >
> > > This patch replaced the custom "consistent_pte" with
> > > get_vm_area_caller()", which breaks the compatibility with the
> > > existing driver. This causes the following kernel oops(*1). That
> > > driver has called dma_pool_alloc() to allocate memory from the
> > > interrupt context, and it hits BUG_ON(in_interrpt()) in
> > > "get_vm_area_caller()"(*2). Regardless of the badness of allocation
> > > from interrupt handler in the driver, I have the following question.
> > >
> > > The following "__get_vm_area_node()" can take gfp_mask, it means that
> > > this function is expected to be called from atomic context, but why
> > > it's _NOT_ allowed _ONLY_ from interrupt context?
> > >
> > > According to the following definitions, "in_interrupt()" is in "in_atomic()".
> > >
> > > #define in_interrupt()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK))
> > > #define in_atomic()	((preempt_count() & ~PREEMPT_ACTIVE) != 0)
> > >
> > > Does anyone know why BUG_ON(in_interrupt()) is set in __get_vm_area_node(*3)?
> > 
> > For arm_dma_alloc(), it allocates from the pool if GFP_ATOMIC, but for
> > arm_iommu_alloc_attrs() doesn't have pre-allocate pool at all, and it
> > always call "get_vm_area_caller()". That's why it hits BUG(). But
> > still I don't understand why it's not BUG_ON(in_atomic) as Russell
> > already pointed out(*1).
> > 
> > *1: http://article.gmane.org/gmane.linux.kernel.mm/76708
> 
> Ok, now I see the problem. I will try to find out a solution for your issue.

My explanation wasn't so good.

For a solution, I thought that, in order to allow IOMMU'able device
drivers to allocate memory from atomic context/ISR, there were the
following 2 solutions:

(1) To provide the pre-allocate area like arm_dma_alloc() does,
or
(2) __get_vm_area_node() can be called from ISR.

But (2) doesn't work because PGALLOC_GFP(GFP_KERNEL) is used to
allocate a page table. This is called from:

  arm_iommu_alloc_attrs() ->
    __iommu_alloc_remap() ->
      ioremap_page_range() ->
        .....              ->
          pte_alloc_one_kernel() ->
              pte = (pte_t *)__get_free_page(PGALLOC_GFP);

We always have to avoid changing a page table for atomic
allocation. So for me, the only remaining solution is
(1) pre-allocation. We can make use of the same atomic pool both for
DMA and IOMMU. I'll send the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
