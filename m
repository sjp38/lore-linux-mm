Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E70266B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 06:42:13 -0400 (EDT)
Received: by wibhn6 with SMTP id hn6so2321661wib.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 03:42:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAH9JG2UzYYSk+O-Fc1ViouaMh6=jj-v2xzfk2qhsx_MKhdsY9Q@mail.gmail.com>
References: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
	<1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
	<CALYq+qT0VeXH+1Zu_hWC4EzBPFTb2isxn6U6gH5JQgLU6FC4FA@mail.gmail.com>
	<CAH9JG2UzYYSk+O-Fc1ViouaMh6=jj-v2xzfk2qhsx_MKhdsY9Q@mail.gmail.com>
Date: Mon, 23 Apr 2012 19:42:11 +0900
Message-ID: <CALYq+qSHQvjEAQU8z+Nw9BzJg1CQ7EKKJqBs6R59JSRGaF1ihA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv9 10/10] ARM: dma-mapping: add support for
 IOMMU mapper
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=f46d043bd7e86bd84104be564a32
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>, Joerg Roedel <joro@8bytes.org>

--f46d043bd7e86bd84104be564a32
Content-Type: text/plain; charset=ISO-8859-1

Hi,

I see a bottle-neck with the current dma-mapping framework.
Issue seems to be with the Virtual memory allocation for access in kernel
address space.

1. In "arch/arm/mm/dma-mapping.c" there is a initialization call to
"consistent_init". It reserves size 32MB of Kernel Address space.
2. "consistent_init" allocates memory for kernel page directory and page
tables.

3. "__iommu_alloc_remap" function allocates virtual memory region in kernel
address space reserved in step 1.

4. "__iommu_alloc_remap" function then maps the allocated pages to the
address space reserved in step 3.

Since the virtual memory area allocated for mapping these pages in kernel
address space is only 32MB,

eventually the calls for allocation and mapping new pages into kernel
address space are going to fail once 32 MB is exhausted.

e.g., For Exynos 5 platform Each framebuffer for 1280x800 resolution
consumes around 4MB.

We have a scenario where X11 DRI driver would allocate Non-contig pages for
all "Pixmaps" through "exynos_drm_gem_create" function which will follow
the path given above in steps 1 - 4.

Now the problem is the size limitation of 32MB. We may want to allocate
more than 8 such buffers when X11 DRI driver is integrated.

Possible solutions:

1. Why do we need to create a kernel virtual address space? Are we going to
access these pages in kernel using this address?

If we are not going to access anything in kernel then why do we need to map
these pages in kernel address space?. If we can avoid this then the problem
can be solved.

OR

2 Is it used for only book-keeping to retrieve "struct pages" later on for
passing/mapping to different devices?

If yes, then we have to find another way.

For "dmabuf" framework one solution could be to add a new member variable
"pages" in the exporting driver's local object and use that for
passing/mapping to different devices.

Moreover, even if we increase to say 64 MB that would not be enough for our
use, we never know how many graphic applications would be spawned by the
user.
Let me know your opinion on this.

Regards,
Abhinav

On Fri, Apr 20, 2012 at 10:51 AM, Kyungmin Park
<kyungmin.park@samsung.com>wrote:

> On 4/20/12, Abhinav Kochhar <kochhar.abhinav@gmail.com> wrote:
> > Hi Marek,
> >
> > dma_addr_t dma_addr is an unused argument passed to the function
> > arm_iommu_mmap_attrs
>
> Even though it's not used at here. it's mmap function field at dma_map_ops.
> To match the type, it's required.
>
> struct dma_map_ops iommu_ops = {
>       .alloc          = arm_iommu_alloc_attrs,
>       .free           = arm_iommu_free_attrs,
>       .mmap           = arm_iommu_mmap_attrs,
>
> Thank you,
> Kyungmin Park
> >
> > +static int arm_iommu_mmap_attrs(struct device *dev, struct
> vm_area_struct
> > *vma,
> > +                   void *cpu_addr, dma_addr_t dma_addr, size_t size,
> > +                   struct dma_attrs *attrs)
> > +{
> > +       struct arm_vmregion *c;
> > +
> > +       vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> > +       c = arm_vmregion_find(&consistent_
> > head, (unsigned long)cpu_addr);
> > +
> > +       if (c) {
> > +               struct page **pages = c->priv;
> > +
> > +               unsigned long uaddr = vma->vm_start;
> > +               unsigned long usize = vma->vm_end - vma->vm_start;
> > +               int i = 0;
> > +
> > +               do {
> > +                       int ret;
> > +
> > +                       ret = vm_insert_page(vma, uaddr, pages[i++]);
> > +                       if (ret) {
> > +                               pr_err("Remapping memory, error: %d\n",
> > ret);
> > +                               return ret;
> > +                       }
> > +
> > +                       uaddr += PAGE_SIZE;
> > +                       usize -= PAGE_SIZE;
> > +               } while (usize > 0);
> > +       }
> > +       return 0;
> > +}
> >
> >
> > On Wed, Apr 18, 2012 at 10:44 PM, Marek Szyprowski <
> m.szyprowski@samsung.com
> >> wrote:
> >
> >> This patch add a complete implementation of DMA-mapping API for
> >> devices which have IOMMU support.
> >>
> >> This implementation tries to optimize dma address space usage by
> remapping
> >> all possible physical memory chunks into a single dma address space
> chunk.
> >>
> >> DMA address space is managed on top of the bitmap stored in the
> >> dma_iommu_mapping structure stored in device->archdata. Platform setup
> >> code has to initialize parameters of the dma address space (base
> address,
> >> size, allocation precision order) with arm_iommu_create_mapping()
> >> function.
> >> To reduce the size of the bitmap, all allocations are aligned to the
> >> specified order of base 4 KiB pages.
> >>
> >> dma_alloc_* functions allocate physical memory in chunks, each with
> >> alloc_pages() function to avoid failing if the physical memory gets
> >> fragmented. In worst case the allocated buffer is composed of 4 KiB page
> >> chunks.
> >>
> >> dma_map_sg() function minimizes the total number of dma address space
> >> chunks by merging of physical memory chunks into one larger dma address
> >> space chunk. If requested chunk (scatter list entry) boundaries
> >> match physical page boundaries, most calls to dma_map_sg() requests will
> >> result in creating only one chunk in dma address space.
> >>
> >> dma_map_page() simply creates a mapping for the given page(s) in the dma
> >> address space.
> >>
> >> All dma functions also perform required cache operation like their
> >> counterparts from the arm linear physical memory mapping version.
> >>
> >> This patch contains code and fixes kindly provided by:
> >> - Krishna Reddy <vdumpa@nvidia.com>,
> >> - Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
> >> - Hiroshi DOYU <hdoyu@nvidia.com>
> >>
> >> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> >> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> >> Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
> >> ---
> >>  arch/arm/Kconfig                 |    8 +
> >>  arch/arm/include/asm/device.h    |    3 +
> >>  arch/arm/include/asm/dma-iommu.h |   34 ++
> >>  arch/arm/mm/dma-mapping.c        |  727
> >> +++++++++++++++++++++++++++++++++++++-
> >>  arch/arm/mm/vmregion.h           |    2 +-
> >>  5 files changed, 759 insertions(+), 15 deletions(-)
> >>  create mode 100644 arch/arm/include/asm/dma-iommu.h
> >>
> >> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> >> index 0fd27d4..874e519 100644
> >> --- a/arch/arm/Kconfig
> >> +++ b/arch/arm/Kconfig
> >> @@ -46,6 +46,14 @@ config ARM
> >>  config ARM_HAS_SG_CHAIN
> >>        bool
> >>
> >> +config NEED_SG_DMA_LENGTH
> >> +       bool
> >> +
> >> +config ARM_DMA_USE_IOMMU
> >> +       select NEED_SG_DMA_LENGTH
> >> +       select ARM_HAS_SG_CHAIN
> >> +       bool
> >> +
> >>  config HAVE_PWM
> >>        bool
> >>
> >> diff --git a/arch/arm/include/asm/device.h
> b/arch/arm/include/asm/device.h
> >> index 6e2cb0e..b69c0d3 100644
> >> --- a/arch/arm/include/asm/device.h
> >> +++ b/arch/arm/include/asm/device.h
> >> @@ -14,6 +14,9 @@ struct dev_archdata {
> >>  #ifdef CONFIG_IOMMU_API
> >>        void *iommu; /* private IOMMU data */
> >>  #endif
> >> +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> >> +       struct dma_iommu_mapping        *mapping;
> >> +#endif
> >>  };
> >>
> >>  struct omap_device;
> >> diff --git a/arch/arm/include/asm/dma-iommu.h
> >> b/arch/arm/include/asm/dma-iommu.h
> >> new file mode 100644
> >> index 0000000..799b094
> >> --- /dev/null
> >> +++ b/arch/arm/include/asm/dma-iommu.h
> >> @@ -0,0 +1,34 @@
> >> +#ifndef ASMARM_DMA_IOMMU_H
> >> +#define ASMARM_DMA_IOMMU_H
> >> +
> >> +#ifdef __KERNEL__
> >> +
> >> +#include <linux/mm_types.h>
> >> +#include <linux/scatterlist.h>
> >> +#include <linux/dma-debug.h>
> >> +#include <linux/kmemcheck.h>
> >> +
> >> +struct dma_iommu_mapping {
> >> +       /* iommu specific data */
> >> +       struct iommu_domain     *domain;
> >> +
> >> +       void                    *bitmap;
> >> +       size_t                  bits;
> >> +       unsigned int            order;
> >> +       dma_addr_t              base;
> >> +
> >> +       spinlock_t              lock;
> >> +       struct kref             kref;
> >> +};
> >> +
> >> +struct dma_iommu_mapping *
> >> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t
> >> size,
> >> +                        int order);
> >> +
> >> +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
> >> +
> >> +int arm_iommu_attach_device(struct device *dev,
> >> +                                       struct dma_iommu_mapping
> >> *mapping);
> >> +
> >> +#endif /* __KERNEL__ */
> >> +#endif
> >> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> >> index d4aad65..2d11aa0 100644
> >> --- a/arch/arm/mm/dma-mapping.c
> >> +++ b/arch/arm/mm/dma-mapping.c
> >> @@ -19,6 +19,8 @@
> >>  #include <linux/dma-mapping.h>
> >>  #include <linux/highmem.h>
> >>  #include <linux/slab.h>
> >> +#include <linux/iommu.h>
> >> +#include <linux/vmalloc.h>
> >>
> >>  #include <asm/memory.h>
> >>  #include <asm/highmem.h>
> >> @@ -26,6 +28,7 @@
> >>  #include <asm/tlbflush.h>
> >>  #include <asm/sizes.h>
> >>  #include <asm/mach/arch.h>
> >> +#include <asm/dma-iommu.h>
> >>
> >>  #include "mm.h"
> >>
> >> @@ -155,6 +158,21 @@ static u64 get_coherent_dma_mask(struct device
> *dev)
> >>        return mask;
> >>  }
> >>
> >> +static void __dma_clear_buffer(struct page *page, size_t size)
> >> +{
> >> +       void *ptr;
> >> +       /*
> >> +        * Ensure that the allocated pages are zeroed, and that any data
> >> +        * lurking in the kernel direct-mapped region is invalidated.
> >> +        */
> >> +       ptr = page_address(page);
> >> +       if (ptr) {
> >> +               memset(ptr, 0, size);
> >> +               dmac_flush_range(ptr, ptr + size);
> >> +               outer_flush_range(__pa(ptr), __pa(ptr) + size);
> >> +       }
> >> +}
> >> +
> >>  /*
> >>  * Allocate a DMA buffer for 'dev' of size 'size' using the
> >>  * specified gfp mask.  Note that 'size' must be page aligned.
> >> @@ -163,7 +181,6 @@ static struct page *__dma_alloc_buffer(struct device
> >> *dev, size_t size, gfp_t gf
> >>  {
> >>        unsigned long order = get_order(size);
> >>        struct page *page, *p, *e;
> >> -       void *ptr;
> >>        u64 mask = get_coherent_dma_mask(dev);
> >>
> >>  #ifdef CONFIG_DMA_API_DEBUG
> >> @@ -192,14 +209,7 @@ static struct page *__dma_alloc_buffer(struct
> device
> >> *dev, size_t size, gfp_t gf
> >>        for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p
> <
> >> e; p++)
> >>                __free_page(p);
> >>
> >> -       /*
> >> -        * Ensure that the allocated pages are zeroed, and that any data
> >> -        * lurking in the kernel direct-mapped region is invalidated.
> >> -        */
> >> -       ptr = page_address(page);
> >> -       memset(ptr, 0, size);
> >> -       dmac_flush_range(ptr, ptr + size);
> >> -       outer_flush_range(__pa(ptr), __pa(ptr) + size);
> >> +       __dma_clear_buffer(page, size);
> >>
> >>        return page;
> >>  }
> >> @@ -348,7 +358,7 @@ __dma_alloc_remap(struct page *page, size_t size,
> >> gfp_t gfp, pgprot_t prot,
> >>                u32 off = CONSISTENT_OFFSET(c->vm_start) &
> >> (PTRS_PER_PTE-1);
> >>
> >>                pte = consistent_pte[idx] + off;
> >> -               c->vm_pages = page;
> >> +               c->priv = page;
> >>
> >>                do {
> >>                        BUG_ON(!pte_none(*pte));
> >> @@ -461,6 +471,14 @@ __dma_alloc(struct device *dev, size_t size,
> >> dma_addr_t *handle, gfp_t gfp,
> >>        return addr;
> >>  }
> >>
> >> +static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs,
> pgprot_t
> >> prot)
> >> +{
> >> +       prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
> >> +                           pgprot_writecombine(prot) :
> >> +                           pgprot_dmacoherent(prot);
> >> +       return prot;
> >> +}
> >> +
> >>  /*
> >>  * Allocate DMA-coherent memory space and return both the kernel
> remapped
> >>  * virtual and bus address for that space.
> >> @@ -468,9 +486,7 @@ __dma_alloc(struct device *dev, size_t size,
> >> dma_addr_t *handle, gfp_t gfp,
> >>  void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t
> *handle,
> >>                    gfp_t gfp, struct dma_attrs *attrs)
> >>  {
> >> -       pgprot_t prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
> >> -                       pgprot_writecombine(pgprot_kernel) :
> >> -                       pgprot_dmacoherent(pgprot_kernel);
> >> +       pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
> >>        void *memory;
> >>
> >>        if (dma_alloc_from_coherent(dev, size, handle, &memory))
> >> @@ -497,16 +513,20 @@ int arm_dma_mmap(struct device *dev, struct
> >> vm_area_struct *vma,
> >>                            pgprot_writecombine(vma->vm_page_prot) :
> >>                            pgprot_dmacoherent(vma->vm_page_prot);
> >>
> >> +       if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
> >> +               return ret;
> >> +
> >>        c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
> >>        if (c) {
> >>                unsigned long off = vma->vm_pgoff;
> >> +               struct page *pages = c->priv;
> >>
> >>                kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
> >>
> >>                if (off < kern_size &&
> >>                    user_size <= (kern_size - off)) {
> >>                        ret = remap_pfn_range(vma, vma->vm_start,
> >> -                                             page_to_pfn(c->vm_pages) +
> >> off,
> >> +                                             page_to_pfn(pages) + off,
> >>                                              user_size << PAGE_SHIFT,
> >>                                              vma->vm_page_prot);
> >>                }
> >> @@ -645,6 +665,9 @@ int arm_dma_map_sg(struct device *dev, struct
> >> scatterlist *sg, int nents,
> >>        int i, j;
> >>
> >>        for_each_sg(sg, s, nents, i) {
> >> +#ifdef CONFIG_NEED_SG_DMA_LENGTH
> >> +               s->dma_length = s->length;
> >> +#endif
> >>                s->dma_address = ops->map_page(dev, sg_page(s),
> s->offset,
> >>                                                s->length, dir, attrs);
> >>                if (dma_mapping_error(dev, s->dma_address))
> >> @@ -753,3 +776,679 @@ static int __init dma_debug_do_init(void)
> >>        return 0;
> >>  }
> >>  fs_initcall(dma_debug_do_init);
> >> +
> >> +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> >> +
> >> +/* IOMMU */
> >> +
> >> +static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping
> *mapping,
> >> +                                     size_t size)
> >> +{
> >> +       unsigned int order = get_order(size);
> >> +       unsigned int align = 0;
> >> +       unsigned int count, start;
> >> +       unsigned long flags;
> >> +
> >> +       count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
> >> +                (1 << mapping->order) - 1) >> mapping->order;
> >> +
> >> +       if (order > mapping->order)
> >> +               align = (1 << (order - mapping->order)) - 1;
> >> +
> >> +       spin_lock_irqsave(&mapping->lock, flags);
> >> +       start = bitmap_find_next_zero_area(mapping->bitmap,
> mapping->bits,
> >> 0,
> >> +                                          count, align);
> >> +       if (start > mapping->bits) {
> >> +               spin_unlock_irqrestore(&mapping->lock, flags);
> >> +               return DMA_ERROR_CODE;
> >> +       }
> >> +
> >> +       bitmap_set(mapping->bitmap, start, count);
> >> +       spin_unlock_irqrestore(&mapping->lock, flags);
> >> +
> >> +       return mapping->base + (start << (mapping->order + PAGE_SHIFT));
> >> +}
> >> +
> >> +static inline void __free_iova(struct dma_iommu_mapping *mapping,
> >> +                              dma_addr_t addr, size_t size)
> >> +{
> >> +       unsigned int start = (addr - mapping->base) >>
> >> +                            (mapping->order + PAGE_SHIFT);
> >> +       unsigned int count = ((size >> PAGE_SHIFT) +
> >> +                             (1 << mapping->order) - 1) >>
> >> mapping->order;
> >> +       unsigned long flags;
> >> +
> >> +       spin_lock_irqsave(&mapping->lock, flags);
> >> +       bitmap_clear(mapping->bitmap, start, count);
> >> +       spin_unlock_irqrestore(&mapping->lock, flags);
> >> +}
> >> +
> >> +static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> >> size, gfp_t gfp)
> >> +{
> >> +       struct page **pages;
> >> +       int count = size >> PAGE_SHIFT;
> >> +       int array_size = count * sizeof(struct page *);
> >> +       int i = 0;
> >> +
> >> +       if (array_size <= PAGE_SIZE)
> >> +               pages = kzalloc(array_size, gfp);
> >> +       else
> >> +               pages = vzalloc(array_size);
> >> +       if (!pages)
> >> +               return NULL;
> >> +
> >> +       while (count) {
> >> +               int j, order = __ffs(count);
> >> +
> >> +               pages[i] = alloc_pages(gfp | __GFP_NOWARN, order);
> >> +               while (!pages[i] && order)
> >> +                       pages[i] = alloc_pages(gfp | __GFP_NOWARN,
> >> --order);
> >> +               if (!pages[i])
> >> +                       goto error;
> >> +
> >> +               if (order)
> >> +                       split_page(pages[i], order);
> >> +               j = 1 << order;
> >> +               while (--j)
> >> +                       pages[i + j] = pages[i] + j;
> >> +
> >> +               __dma_clear_buffer(pages[i], PAGE_SIZE << order);
> >> +               i += 1 << order;
> >> +               count -= 1 << order;
> >> +       }
> >> +
> >> +       return pages;
> >> +error:
> >> +       while (--i)
> >> +               if (pages[i])
> >> +                       __free_pages(pages[i], 0);
> >> +       if (array_size < PAGE_SIZE)
> >> +               kfree(pages);
> >> +       else
> >> +               vfree(pages);
> >> +       return NULL;
> >> +}
> >> +
> >> +static int __iommu_free_buffer(struct device *dev, struct page **pages,
> >> size_t size)
> >> +{
> >> +       int count = size >> PAGE_SHIFT;
> >> +       int array_size = count * sizeof(struct page *);
> >> +       int i;
> >> +       for (i = 0; i < count; i++)
> >> +               if (pages[i])
> >> +                       __free_pages(pages[i], 0);
> >> +       if (array_size < PAGE_SIZE)
> >> +               kfree(pages);
> >> +       else
> >> +               vfree(pages);
> >> +       return 0;
> >> +}
> >> +
> >> +/*
> >> + * Create a CPU mapping for a specified pages
> >> + */
> >> +static void *
> >> +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp,
> pgprot_t
> >> prot)
> >> +{
> >> +       struct arm_vmregion *c;
> >> +       size_t align;
> >> +       size_t count = size >> PAGE_SHIFT;
> >> +       int bit;
> >> +
> >> +       if (!consistent_pte[0]) {
> >> +               pr_err("%s: not initialised\n", __func__);
> >> +               dump_stack();
> >> +               return NULL;
> >> +       }
> >> +
> >> +       /*
> >> +        * Align the virtual region allocation - maximum alignment is
> >> +        * a section size, minimum is a page size.  This helps reduce
> >> +        * fragmentation of the DMA space, and also prevents allocations
> >> +        * smaller than a section from crossing a section boundary.
> >> +        */
> >> +       bit = fls(size - 1);
> >> +       if (bit > SECTION_SHIFT)
> >> +               bit = SECTION_SHIFT;
> >> +       align = 1 << bit;
> >> +
> >> +       /*
> >> +        * Allocate a virtual address in the consistent mapping region.
> >> +        */
> >> +       c = arm_vmregion_alloc(&consistent_head, align, size,
> >> +                           gfp & ~(__GFP_DMA | __GFP_HIGHMEM), NULL);
> >> +       if (c) {
> >> +               pte_t *pte;
> >> +               int idx = CONSISTENT_PTE_INDEX(c->vm_start);
> >> +               int i = 0;
> >> +               u32 off = CONSISTENT_OFFSET(c->vm_start) &
> >> (PTRS_PER_PTE-1);
> >> +
> >> +               pte = consistent_pte[idx] + off;
> >> +               c->priv = pages;
> >> +
> >> +               do {
> >> +                       BUG_ON(!pte_none(*pte));
> >> +
> >> +                       set_pte_ext(pte, mk_pte(pages[i], prot), 0);
> >> +                       pte++;
> >> +                       off++;
> >> +                       i++;
> >> +                       if (off >= PTRS_PER_PTE) {
> >> +                               off = 0;
> >> +                               pte = consistent_pte[++idx];
> >> +                       }
> >> +               } while (i < count);
> >> +
> >> +               dsb();
> >> +
> >> +               return (void *)c->vm_start;
> >> +       }
> >> +       return NULL;
> >> +}
> >> +
> >> +/*
> >> + * Create a mapping in device IO address space for specified pages
> >> + */
> >> +static dma_addr_t
> >> +__iommu_create_mapping(struct device *dev, struct page **pages, size_t
> >> size)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> >> +       dma_addr_t dma_addr, iova;
> >> +       int i, ret = DMA_ERROR_CODE;
> >> +
> >> +       dma_addr = __alloc_iova(mapping, size);
> >> +       if (dma_addr == DMA_ERROR_CODE)
> >> +               return dma_addr;
> >> +
> >> +       iova = dma_addr;
> >> +       for (i = 0; i < count; ) {
> >> +               unsigned int next_pfn = page_to_pfn(pages[i]) + 1;
> >> +               phys_addr_t phys = page_to_phys(pages[i]);
> >> +               unsigned int len, j;
> >> +
> >> +               for (j = i + 1; j < count; j++, next_pfn++)
> >> +                       if (page_to_pfn(pages[j]) != next_pfn)
> >> +                               break;
> >> +
> >> +               len = (j - i) << PAGE_SHIFT;
> >> +               ret = iommu_map(mapping->domain, iova, phys, len, 0);
> >> +               if (ret < 0)
> >> +                       goto fail;
> >> +               iova += len;
> >> +               i = j;
> >> +       }
> >> +       return dma_addr;
> >> +fail:
> >> +       iommu_unmap(mapping->domain, dma_addr, iova-dma_addr);
> >> +       __free_iova(mapping, dma_addr, size);
> >> +       return DMA_ERROR_CODE;
> >> +}
> >> +
> >> +static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova,
> >> size_t size)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +
> >> +       /*
> >> +        * add optional in-page offset from iova to size and align
> >> +        * result to page size
> >> +        */
> >> +       size = PAGE_ALIGN((iova & ~PAGE_MASK) + size);
> >> +       iova &= PAGE_MASK;
> >> +
> >> +       iommu_unmap(mapping->domain, iova, size);
> >> +       __free_iova(mapping, iova, size);
> >> +       return 0;
> >> +}
> >> +
> >> +static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
> >> +           dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
> >> +{
> >> +       pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
> >> +       struct page **pages;
> >> +       void *addr = NULL;
> >> +
> >> +       *handle = DMA_ERROR_CODE;
> >> +       size = PAGE_ALIGN(size);
> >> +
> >> +       pages = __iommu_alloc_buffer(dev, size, gfp);
> >> +       if (!pages)
> >> +               return NULL;
> >> +
> >> +       *handle = __iommu_create_mapping(dev, pages, size);
> >> +       if (*handle == DMA_ERROR_CODE)
> >> +               goto err_buffer;
> >> +
> >> +       addr = __iommu_alloc_remap(pages, size, gfp, prot);
> >> +       if (!addr)
> >> +               goto err_mapping;
> >> +
> >> +       return addr;
> >> +
> >> +err_mapping:
> >> +       __iommu_remove_mapping(dev, *handle, size);
> >> +err_buffer:
> >> +       __iommu_free_buffer(dev, pages, size);
> >> +       return NULL;
> >> +}
> >> +
> >> +static int arm_iommu_mmap_attrs(struct device *dev, struct
> vm_area_struct
> >> *vma,
> >> +                   void *cpu_addr, dma_addr_t dma_addr, size_t size,
> >> +                   struct dma_attrs *attrs)
> >> +{
> >> +       struct arm_vmregion *c;
> >> +
> >> +       vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> >> +       c = arm_vmregion_find(&consistent_head, (unsigned
> long)cpu_addr);
> >> +
> >> +       if (c) {
> >> +               struct page **pages = c->priv;
> >> +
> >> +               unsigned long uaddr = vma->vm_start;
> >> +               unsigned long usize = vma->vm_end - vma->vm_start;
> >> +               int i = 0;
> >> +
> >> +               do {
> >> +                       int ret;
> >> +
> >> +                       ret = vm_insert_page(vma, uaddr, pages[i++]);
> >> +                       if (ret) {
> >> +                               pr_err("Remapping memory, error: %d\n",
> >> ret);
> >> +                               return ret;
> >> +                       }
> >> +
> >> +                       uaddr += PAGE_SIZE;
> >> +                       usize -= PAGE_SIZE;
> >> +               } while (usize > 0);
> >> +       }
> >> +       return 0;
> >> +}
> >> +
> >> +/*
> >> + * free a page as defined by the above mapping.
> >> + * Must not be called with IRQs disabled.
> >> + */
> >> +void arm_iommu_free_attrs(struct device *dev, size_t size, void
> >> *cpu_addr,
> >> +                         dma_addr_t handle, struct dma_attrs *attrs)
> >> +{
> >> +       struct arm_vmregion *c;
> >> +       size = PAGE_ALIGN(size);
> >> +
> >> +       c = arm_vmregion_find(&consistent_head, (unsigned
> long)cpu_addr);
> >> +       if (c) {
> >> +               struct page **pages = c->priv;
> >> +               __dma_free_remap(cpu_addr, size);
> >> +               __iommu_remove_mapping(dev, handle, size);
> >> +               __iommu_free_buffer(dev, pages, size);
> >> +       }
> >> +}
> >> +
> >> +/*
> >> + * Map a part of the scatter-gather list into contiguous io address
> space
> >> + */
> >> +static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> >> +                         size_t size, dma_addr_t *handle,
> >> +                         enum dma_data_direction dir)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       dma_addr_t iova, iova_base;
> >> +       int ret = 0;
> >> +       unsigned int count;
> >> +       struct scatterlist *s;
> >> +
> >> +       size = PAGE_ALIGN(size);
> >> +       *handle = DMA_ERROR_CODE;
> >> +
> >> +       iova_base = iova = __alloc_iova(mapping, size);
> >> +       if (iova == DMA_ERROR_CODE)
> >> +               return -ENOMEM;
> >> +
> >> +       for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s =
> >> sg_next(s)) {
> >> +               phys_addr_t phys = page_to_phys(sg_page(s));
> >> +               unsigned int len = PAGE_ALIGN(s->offset + s->length);
> >> +
> >> +               if (!arch_is_coherent())
> >> +                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
> >> s->length, dir);
> >> +
> >> +               ret = iommu_map(mapping->domain, iova, phys, len, 0);
> >> +               if (ret < 0)
> >> +                       goto fail;
> >> +               count += len >> PAGE_SHIFT;
> >> +               iova += len;
> >> +       }
> >> +       *handle = iova_base;
> >> +
> >> +       return 0;
> >> +fail:
> >> +       iommu_unmap(mapping->domain, iova_base, count * PAGE_SIZE);
> >> +       __free_iova(mapping, iova_base, size);
> >> +       return ret;
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_map_sg - map a set of SG buffers for streaming mode DMA
> >> + * @dev: valid struct device pointer
> >> + * @sg: list of buffers
> >> + * @nents: number of buffers to map
> >> + * @dir: DMA transfer direction
> >> + *
> >> + * Map a set of buffers described by scatterlist in streaming mode for
> >> DMA.
> >> + * The scatter gather list elements are merged together (if possible)
> and
> >> + * tagged with the appropriate dma address and length. They are
> obtained
> >> via
> >> + * sg_dma_{address,length}.
> >> + */
> >> +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int
> >> nents,
> >> +                    enum dma_data_direction dir, struct dma_attrs
> *attrs)
> >> +{
> >> +       struct scatterlist *s = sg, *dma = sg, *start = sg;
> >> +       int i, count = 0;
> >> +       unsigned int offset = s->offset;
> >> +       unsigned int size = s->offset + s->length;
> >> +       unsigned int max = dma_get_max_seg_size(dev);
> >> +
> >> +       for (i = 1; i < nents; i++) {
> >> +               s = sg_next(s);
> >> +
> >> +               s->dma_address = DMA_ERROR_CODE;
> >> +               s->dma_length = 0;
> >> +
> >> +               if (s->offset || (size & ~PAGE_MASK) || size +
> s->length >
> >> max) {
> >> +                       if (__map_sg_chunk(dev, start, size,
> >> &dma->dma_address,
> >> +                           dir) < 0)
> >> +                               goto bad_mapping;
> >> +
> >> +                       dma->dma_address += offset;
> >> +                       dma->dma_length = size - offset;
> >> +
> >> +                       size = offset = s->offset;
> >> +                       start = s;
> >> +                       dma = sg_next(dma);
> >> +                       count += 1;
> >> +               }
> >> +               size += s->length;
> >> +       }
> >> +       if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) <
> 0)
> >> +               goto bad_mapping;
> >> +
> >> +       dma->dma_address += offset;
> >> +       dma->dma_length = size - offset;
> >> +
> >> +       return count+1;
> >> +
> >> +bad_mapping:
> >> +       for_each_sg(sg, s, count, i)
> >> +               __iommu_remove_mapping(dev, sg_dma_address(s),
> >> sg_dma_len(s));
> >> +       return 0;
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
> >> + * @dev: valid struct device pointer
> >> + * @sg: list of buffers
> >> + * @nents: number of buffers to unmap (same as was passed to
> dma_map_sg)
> >> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> >> + *
> >> + * Unmap a set of streaming mode DMA translations.  Again, CPU access
> >> + * rules concerning calls here are the same as for dma_unmap_single().
> >> + */
> >> +void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *sg, int
> >> nents,
> >> +                       enum dma_data_direction dir, struct dma_attrs
> >> *attrs)
> >> +{
> >> +       struct scatterlist *s;
> >> +       int i;
> >> +
> >> +       for_each_sg(sg, s, nents, i) {
> >> +               if (sg_dma_len(s))
> >> +                       __iommu_remove_mapping(dev, sg_dma_address(s),
> >> +                                              sg_dma_len(s));
> >> +               if (!arch_is_coherent())
> >> +                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
> >> +                                             s->length, dir);
> >> +       }
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_sync_sg_for_cpu
> >> + * @dev: valid struct device pointer
> >> + * @sg: list of buffers
> >> + * @nents: number of buffers to map (returned from dma_map_sg)
> >> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> >> + */
> >> +void arm_iommu_sync_sg_for_cpu(struct device *dev, struct scatterlist
> >> *sg,
> >> +                       int nents, enum dma_data_direction dir)
> >> +{
> >> +       struct scatterlist *s;
> >> +       int i;
> >> +
> >> +       for_each_sg(sg, s, nents, i)
> >> +               if (!arch_is_coherent())
> >> +                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
> >> s->length, dir);
> >> +
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_sync_sg_for_device
> >> + * @dev: valid struct device pointer
> >> + * @sg: list of buffers
> >> + * @nents: number of buffers to map (returned from dma_map_sg)
> >> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> >> + */
> >> +void arm_iommu_sync_sg_for_device(struct device *dev, struct
> scatterlist
> >> *sg,
> >> +                       int nents, enum dma_data_direction dir)
> >> +{
> >> +       struct scatterlist *s;
> >> +       int i;
> >> +
> >> +       for_each_sg(sg, s, nents, i)
> >> +               if (!arch_is_coherent())
> >> +                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
> >> s->length, dir);
> >> +}
> >> +
> >> +
> >> +/**
> >> + * arm_iommu_map_page
> >> + * @dev: valid struct device pointer
> >> + * @page: page that buffer resides in
> >> + * @offset: offset into page for start of buffer
> >> + * @size: size of buffer to map
> >> + * @dir: DMA transfer direction
> >> + *
> >> + * IOMMU aware version of arm_dma_map_page()
> >> + */
> >> +static dma_addr_t arm_iommu_map_page(struct device *dev, struct page
> >> *page,
> >> +            unsigned long offset, size_t size, enum dma_data_direction
> >> dir,
> >> +            struct dma_attrs *attrs)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       dma_addr_t dma_addr;
> >> +       int ret, len = PAGE_ALIGN(size + offset);
> >> +
> >> +       if (!arch_is_coherent())
> >> +               __dma_page_cpu_to_dev(page, offset, size, dir);
> >> +
> >> +       dma_addr = __alloc_iova(mapping, len);
> >> +       if (dma_addr == DMA_ERROR_CODE)
> >> +               return dma_addr;
> >> +
> >> +       ret = iommu_map(mapping->domain, dma_addr, page_to_phys(page),
> >> len, 0);
> >> +       if (ret < 0)
> >> +               goto fail;
> >> +
> >> +       return dma_addr + offset;
> >> +fail:
> >> +       __free_iova(mapping, dma_addr, len);
> >> +       return DMA_ERROR_CODE;
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_unmap_page
> >> + * @dev: valid struct device pointer
> >> + * @handle: DMA address of buffer
> >> + * @size: size of buffer (same as passed to dma_map_page)
> >> + * @dir: DMA transfer direction (same as passed to dma_map_page)
> >> + *
> >> + * IOMMU aware version of arm_dma_unmap_page()
> >> + */
> >> +static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
> >> +               size_t size, enum dma_data_direction dir,
> >> +               struct dma_attrs *attrs)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       dma_addr_t iova = handle & PAGE_MASK;
> >> +       struct page *page =
> >> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> >> +       int offset = handle & ~PAGE_MASK;
> >> +       int len = PAGE_ALIGN(size + offset);
> >> +
> >> +       if (!iova)
> >> +               return;
> >> +
> >> +       if (!arch_is_coherent())
> >> +               __dma_page_dev_to_cpu(page, offset, size, dir);
> >> +
> >> +       iommu_unmap(mapping->domain, iova, len);
> >> +       __free_iova(mapping, iova, len);
> >> +}
> >> +
> >> +static void arm_iommu_sync_single_for_cpu(struct device *dev,
> >> +               dma_addr_t handle, size_t size, enum dma_data_direction
> >> dir)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       dma_addr_t iova = handle & PAGE_MASK;
> >> +       struct page *page =
> >> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> >> +       unsigned int offset = handle & ~PAGE_MASK;
> >> +
> >> +       if (!iova)
> >> +               return;
> >> +
> >> +       if (!arch_is_coherent())
> >> +               __dma_page_dev_to_cpu(page, offset, size, dir);
> >> +}
> >> +
> >> +static void arm_iommu_sync_single_for_device(struct device *dev,
> >> +               dma_addr_t handle, size_t size, enum dma_data_direction
> >> dir)
> >> +{
> >> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> >> +       dma_addr_t iova = handle & PAGE_MASK;
> >> +       struct page *page =
> >> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> >> +       unsigned int offset = handle & ~PAGE_MASK;
> >> +
> >> +       if (!iova)
> >> +               return;
> >> +
> >> +       __dma_page_cpu_to_dev(page, offset, size, dir);
> >> +}
> >> +
> >> +struct dma_map_ops iommu_ops = {
> >> +       .alloc          = arm_iommu_alloc_attrs,
> >> +       .free           = arm_iommu_free_attrs,
> >> +       .mmap           = arm_iommu_mmap_attrs,
> >> +
> >> +       .map_page               = arm_iommu_map_page,
> >> +       .unmap_page             = arm_iommu_unmap_page,
> >> +       .sync_single_for_cpu    = arm_iommu_sync_single_for_cpu,
> >> +       .sync_single_for_device = arm_iommu_sync_single_for_device,
> >> +
> >> +       .map_sg                 = arm_iommu_map_sg,
> >> +       .unmap_sg               = arm_iommu_unmap_sg,
> >> +       .sync_sg_for_cpu        = arm_iommu_sync_sg_for_cpu,
> >> +       .sync_sg_for_device     = arm_iommu_sync_sg_for_device,
> >> +};
> >> +
> >> +/**
> >> + * arm_iommu_create_mapping
> >> + * @bus: pointer to the bus holding the client device (for IOMMU calls)
> >> + * @base: start address of the valid IO address space
> >> + * @size: size of the valid IO address space
> >> + * @order: accuracy of the IO addresses allocations
> >> + *
> >> + * Creates a mapping structure which holds information about
> used/unused
> >> + * IO address ranges, which is required to perform memory allocation
> and
> >> + * mapping with IOMMU aware functions.
> >> + *
> >> + * The client device need to be attached to the mapping with
> >> + * arm_iommu_attach_device function.
> >> + */
> >> +struct dma_iommu_mapping *
> >> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t
> >> size,
> >> +                        int order)
> >> +{
> >> +       unsigned int count = size >> (PAGE_SHIFT + order);
> >> +       unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> >> +       struct dma_iommu_mapping *mapping;
> >> +       int err = -ENOMEM;
> >> +
> >> +       if (!count)
> >> +               return ERR_PTR(-EINVAL);
> >> +
> >> +       mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
> >> +       if (!mapping)
> >> +               goto err;
> >> +
> >> +       mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> >> +       if (!mapping->bitmap)
> >> +               goto err2;
> >> +
> >> +       mapping->base = base;
> >> +       mapping->bits = BITS_PER_BYTE * bitmap_size;
> >> +       mapping->order = order;
> >> +       spin_lock_init(&mapping->lock);
> >> +
> >> +       mapping->domain = iommu_domain_alloc(bus);
> >> +       if (!mapping->domain)
> >> +               goto err3;
> >> +
> >> +       kref_init(&mapping->kref);
> >> +       return mapping;
> >> +err3:
> >> +       kfree(mapping->bitmap);
> >> +err2:
> >> +       kfree(mapping);
> >> +err:
> >> +       return ERR_PTR(err);
> >> +}
> >> +
> >> +static void release_iommu_mapping(struct kref *kref)
> >> +{
> >> +       struct dma_iommu_mapping *mapping =
> >> +               container_of(kref, struct dma_iommu_mapping, kref);
> >> +
> >> +       iommu_domain_free(mapping->domain);
> >> +       kfree(mapping->bitmap);
> >> +       kfree(mapping);
> >> +}
> >> +
> >> +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
> >> +{
> >> +       if (mapping)
> >> +               kref_put(&mapping->kref, release_iommu_mapping);
> >> +}
> >> +
> >> +/**
> >> + * arm_iommu_attach_device
> >> + * @dev: valid struct device pointer
> >> + * @mapping: io address space mapping structure (returned from
> >> + *     arm_iommu_create_mapping)
> >> + *
> >> + * Attaches specified io address space mapping to the provided device,
> >> + * this replaces the dma operations (dma_map_ops pointer) with the
> >> + * IOMMU aware version. More than one client might be attached to
> >> + * the same io address space mapping.
> >> + */
> >> +int arm_iommu_attach_device(struct device *dev,
> >> +                           struct dma_iommu_mapping *mapping)
> >> +{
> >> +       int err;
> >> +
> >> +       err = iommu_attach_device(mapping->domain, dev);
> >> +       if (err)
> >> +               return err;
> >> +
> >> +       kref_get(&mapping->kref);
> >> +       dev->archdata.mapping = mapping;
> >> +       set_dma_ops(dev, &iommu_ops);
> >> +
> >> +       pr_info("Attached IOMMU controller to %s device.\n",
> >> dev_name(dev));
> >> +       return 0;
> >> +}
> >> +
> >> +#endif
> >> diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h
> >> index 162be66..bf312c3 100644
> >> --- a/arch/arm/mm/vmregion.h
> >> +++ b/arch/arm/mm/vmregion.h
> >> @@ -17,7 +17,7 @@ struct arm_vmregion {
> >>        struct list_head        vm_list;
> >>        unsigned long           vm_start;
> >>        unsigned long           vm_end;
> >> -       struct page             *vm_pages;
> >> +       void                    *priv;
> >>        int                     vm_active;
> >>        const void              *caller;
> >>  };
> >> --
> >> 1.7.1.569.g6f426
> >>
> >>
> >> _______________________________________________
> >> Linaro-mm-sig mailing list
> >> Linaro-mm-sig@lists.linaro.org
> >> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig
> >>
> >
>

--f46d043bd7e86bd84104be564a32
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>Hi,<br></p><p>I see a bottle-neck with the current dma-mapping=20
framework.<br>Issue seems to be with the Virtual memory allocation for acce=
ss in=20
kernel address space.</p>
<p>1. In &quot;arch/arm/mm/dma-mapping.c&quot; there is a initialization ca=
ll to=20
&quot;consistent_init&quot;. It reserves size 32MB of Kernel Address space.=
 <br>2.=20
&quot;consistent_init&quot; allocates memory for kernel page directory and =
page=20
tables.</p>
<p>3. &quot;__iommu_alloc_remap&quot; function allocates virtual memory reg=
ion in kernel=20
address space reserved in step 1.</p>
<p>4. &quot;__iommu_alloc_remap&quot; function then maps the allocated page=
s to the=20
address space reserved in step 3.</p>
<p>Since the virtual memory area allocated for mapping these pages in kerne=
l=20
address space is only 32MB, </p>
<p>eventually the calls for allocation and mapping new pages into kernel ad=
dress=20
space are going to fail once 32 MB is exhausted.</p>
<p>e.g., For Exynos 5 platform Each framebuffer for 1280x800 resolution con=
sumes around 4MB.</p>
<p>We have a scenario where X11 DRI driver would allocate Non-contig pages =
for all &quot;Pixmaps&quot; through &quot;exynos_drm_gem_create&quot; funct=
ion which will follow the path given above in steps 1 -=20
4.</p>
<p>Now the problem is the size limitation of 32MB. We may want to allocate =
more=20
than 8 such buffers when X11 DRI driver is integrated.</p>
<p></p>Possible solutions:
<p>1. Why do we need to create a kernel virtual address space? Are we going=
 to=20
access these pages in kernel using this address? </p>
<p>If we are not going to access anything in kernel then why do we need to =
map=20
these pages in kernel address space?. If we can avoid this then the problem=
 can=20
be solved.</p>
<p>OR</p>
<p>2 Is it used for only book-keeping to retrieve &quot;struct pages&quot; =
later on for=20
passing/mapping to different devices?</p>
<p>If yes, then we have to find another way. <br></p><p>For &quot;dmabuf&qu=
ot; framework one solution could be to add a new member=20
variable &quot;pages&quot; in the exporting driver&#39;s local object and u=
se that=20
for passing/mapping to different devices.</p><p>Moreover, even if we increa=
se to say 64 MB that would not be enough for our use,=20
we never know how many graphic applications would be spawned by the user.</=
p>Let me know your opinion on this.<br><br>Regards,<br>Abhinav<br><br><div =
class=3D"gmail_quote">On Fri, Apr 20, 2012 at 10:51 AM, Kyungmin Park <span=
 dir=3D"ltr">&lt;<a href=3D"mailto:kyungmin.park@samsung.com">kyungmin.park=
@samsung.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On 4/20/12, Abhinav Kochha=
r &lt;<a href=3D"mailto:kochhar.abhinav@gmail.com">kochhar.abhinav@gmail.co=
m</a>&gt; wrote:<br>

&gt; Hi Marek,<br>
&gt;<br>
&gt; dma_addr_t dma_addr is an unused argument passed to the function<br>
&gt; arm_iommu_mmap_attrs<br>
<br>
</div>Even though it&#39;s not used at here. it&#39;s mmap function field a=
t dma_map_ops.<br>
To match the type, it&#39;s required.<br>
<br>
struct dma_map_ops iommu_ops =3D {<br>
 =A0 =A0 =A0 .alloc =A0 =A0 =A0 =A0 =A0=3D arm_iommu_alloc_attrs,<br>
 =A0 =A0 =A0 .free =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_free_attrs,<br>
 =A0 =A0 =A0 .mmap =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_mmap_attrs,<br>
<br>
Thank you,<br>
Kyungmin Park<br>
<div class=3D"HOEnZb"><div class=3D"h5">&gt;<br>
&gt; +static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_st=
ruct<br>
&gt; *vma,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *cpu_addr, dma_addr_t dma_a=
ddr, size_t size,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 struct arm_vmregion *c;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 vma-&gt;vm_page_prot =3D __get_dma_pgprot(attrs, vma-&gt=
;vm_page_prot);<br>
&gt; + =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_<br>
&gt; head, (unsigned long)cpu_addr);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 if (c) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long uaddr =3D vma-&gt;vm_start=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long usize =3D vma-&gt;vm_end -=
 vma-&gt;vm_start;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vm_insert_page(v=
ma, uaddr, pages[i++]);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&=
quot;Remapping memory, error: %d\n&quot;,<br>
&gt; ret);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return r=
et;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uaddr +=3D PAGE_SIZE;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usize -=3D PAGE_SIZE;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (usize &gt; 0);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 return 0;<br>
&gt; +}<br>
&gt;<br>
&gt;<br>
&gt; On Wed, Apr 18, 2012 at 10:44 PM, Marek Szyprowski &lt;<a href=3D"mail=
to:m.szyprowski@samsung.com">m.szyprowski@samsung.com</a><br>
&gt;&gt; wrote:<br>
&gt;<br>
&gt;&gt; This patch add a complete implementation of DMA-mapping API for<br=
>
&gt;&gt; devices which have IOMMU support.<br>
&gt;&gt;<br>
&gt;&gt; This implementation tries to optimize dma address space usage by r=
emapping<br>
&gt;&gt; all possible physical memory chunks into a single dma address spac=
e chunk.<br>
&gt;&gt;<br>
&gt;&gt; DMA address space is managed on top of the bitmap stored in the<br=
>
&gt;&gt; dma_iommu_mapping structure stored in device-&gt;archdata. Platfor=
m setup<br>
&gt;&gt; code has to initialize parameters of the dma address space (base a=
ddress,<br>
&gt;&gt; size, allocation precision order) with arm_iommu_create_mapping()<=
br>
&gt;&gt; function.<br>
&gt;&gt; To reduce the size of the bitmap, all allocations are aligned to t=
he<br>
&gt;&gt; specified order of base 4 KiB pages.<br>
&gt;&gt;<br>
&gt;&gt; dma_alloc_* functions allocate physical memory in chunks, each wit=
h<br>
&gt;&gt; alloc_pages() function to avoid failing if the physical memory get=
s<br>
&gt;&gt; fragmented. In worst case the allocated buffer is composed of 4 Ki=
B page<br>
&gt;&gt; chunks.<br>
&gt;&gt;<br>
&gt;&gt; dma_map_sg() function minimizes the total number of dma address sp=
ace<br>
&gt;&gt; chunks by merging of physical memory chunks into one larger dma ad=
dress<br>
&gt;&gt; space chunk. If requested chunk (scatter list entry) boundaries<br=
>
&gt;&gt; match physical page boundaries, most calls to dma_map_sg() request=
s will<br>
&gt;&gt; result in creating only one chunk in dma address space.<br>
&gt;&gt;<br>
&gt;&gt; dma_map_page() simply creates a mapping for the given page(s) in t=
he dma<br>
&gt;&gt; address space.<br>
&gt;&gt;<br>
&gt;&gt; All dma functions also perform required cache operation like their=
<br>
&gt;&gt; counterparts from the arm linear physical memory mapping version.<=
br>
&gt;&gt;<br>
&gt;&gt; This patch contains code and fixes kindly provided by:<br>
&gt;&gt; - Krishna Reddy &lt;<a href=3D"mailto:vdumpa@nvidia.com">vdumpa@nv=
idia.com</a>&gt;,<br>
&gt;&gt; - Andrzej Pietrasiewicz &lt;<a href=3D"mailto:andrzej.p@samsung.co=
m">andrzej.p@samsung.com</a>&gt;,<br>
&gt;&gt; - Hiroshi DOYU &lt;<a href=3D"mailto:hdoyu@nvidia.com">hdoyu@nvidi=
a.com</a>&gt;<br>
&gt;&gt;<br>
&gt;&gt; Signed-off-by: Marek Szyprowski &lt;<a href=3D"mailto:m.szyprowski=
@samsung.com">m.szyprowski@samsung.com</a>&gt;<br>
&gt;&gt; Acked-by: Kyungmin Park &lt;<a href=3D"mailto:kyungmin.park@samsun=
g.com">kyungmin.park@samsung.com</a>&gt;<br>
&gt;&gt; Reviewed-by: Konrad Rzeszutek Wilk &lt;<a href=3D"mailto:konrad.wi=
lk@oracle.com">konrad.wilk@oracle.com</a>&gt;<br>
&gt;&gt; Tested-By: Subash Patel &lt;<a href=3D"mailto:subash.ramaswamy@lin=
aro.org">subash.ramaswamy@linaro.org</a>&gt;<br>
&gt;&gt; ---<br>
&gt;&gt; =A0arch/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +<b=
r>
&gt;&gt; =A0arch/arm/include/asm/device.h =A0 =A0| =A0 =A03 +<br>
&gt;&gt; =A0arch/arm/include/asm/dma-iommu.h | =A0 34 ++<br>
&gt;&gt; =A0arch/arm/mm/dma-mapping.c =A0 =A0 =A0 =A0| =A0727<br>
&gt;&gt; +++++++++++++++++++++++++++++++++++++-<br>
&gt;&gt; =A0arch/arm/mm/vmregion.h =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
&gt;&gt; =A05 files changed, 759 insertions(+), 15 deletions(-)<br>
&gt;&gt; =A0create mode 100644 arch/arm/include/asm/dma-iommu.h<br>
&gt;&gt;<br>
&gt;&gt; diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig<br>
&gt;&gt; index 0fd27d4..874e519 100644<br>
&gt;&gt; --- a/arch/arm/Kconfig<br>
&gt;&gt; +++ b/arch/arm/Kconfig<br>
&gt;&gt; @@ -46,6 +46,14 @@ config ARM<br>
&gt;&gt; =A0config ARM_HAS_SG_CHAIN<br>
&gt;&gt; =A0 =A0 =A0 =A0bool<br>
&gt;&gt;<br>
&gt;&gt; +config NEED_SG_DMA_LENGTH<br>
&gt;&gt; + =A0 =A0 =A0 bool<br>
&gt;&gt; +<br>
&gt;&gt; +config ARM_DMA_USE_IOMMU<br>
&gt;&gt; + =A0 =A0 =A0 select NEED_SG_DMA_LENGTH<br>
&gt;&gt; + =A0 =A0 =A0 select ARM_HAS_SG_CHAIN<br>
&gt;&gt; + =A0 =A0 =A0 bool<br>
&gt;&gt; +<br>
&gt;&gt; =A0config HAVE_PWM<br>
&gt;&gt; =A0 =A0 =A0 =A0bool<br>
&gt;&gt;<br>
&gt;&gt; diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/=
device.h<br>
&gt;&gt; index 6e2cb0e..b69c0d3 100644<br>
&gt;&gt; --- a/arch/arm/include/asm/device.h<br>
&gt;&gt; +++ b/arch/arm/include/asm/device.h<br>
&gt;&gt; @@ -14,6 +14,9 @@ struct dev_archdata {<br>
&gt;&gt; =A0#ifdef CONFIG_IOMMU_API<br>
&gt;&gt; =A0 =A0 =A0 =A0void *iommu; /* private IOMMU data */<br>
&gt;&gt; =A0#endif<br>
&gt;&gt; +#ifdef CONFIG_ARM_DMA_USE_IOMMU<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping =A0 =A0 =A0 =A0*mapping;<br=
>
&gt;&gt; +#endif<br>
&gt;&gt; =A0};<br>
&gt;&gt;<br>
&gt;&gt; =A0struct omap_device;<br>
&gt;&gt; diff --git a/arch/arm/include/asm/dma-iommu.h<br>
&gt;&gt; b/arch/arm/include/asm/dma-iommu.h<br>
&gt;&gt; new file mode 100644<br>
&gt;&gt; index 0000000..799b094<br>
&gt;&gt; --- /dev/null<br>
&gt;&gt; +++ b/arch/arm/include/asm/dma-iommu.h<br>
&gt;&gt; @@ -0,0 +1,34 @@<br>
&gt;&gt; +#ifndef ASMARM_DMA_IOMMU_H<br>
&gt;&gt; +#define ASMARM_DMA_IOMMU_H<br>
&gt;&gt; +<br>
&gt;&gt; +#ifdef __KERNEL__<br>
&gt;&gt; +<br>
&gt;&gt; +#include &lt;linux/mm_types.h&gt;<br>
&gt;&gt; +#include &lt;linux/scatterlist.h&gt;<br>
&gt;&gt; +#include &lt;linux/dma-debug.h&gt;<br>
&gt;&gt; +#include &lt;linux/kmemcheck.h&gt;<br>
&gt;&gt; +<br>
&gt;&gt; +struct dma_iommu_mapping {<br>
&gt;&gt; + =A0 =A0 =A0 /* iommu specific data */<br>
&gt;&gt; + =A0 =A0 =A0 struct iommu_domain =A0 =A0 *domain;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*bitmap;=
<br>
&gt;&gt; + =A0 =A0 =A0 size_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bits;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0order;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t =A0 =A0 =A0 =A0 =A0 =A0 =A0base;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock;<br>
&gt;&gt; + =A0 =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 kref;<br>
&gt;&gt; +};<br>
&gt;&gt; +<br>
&gt;&gt; +struct dma_iommu_mapping *<br>
&gt;&gt; +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, s=
ize_t<br>
&gt;&gt; size,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order);<br>
&gt;&gt; +<br>
&gt;&gt; +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)=
;<br>
&gt;&gt; +<br>
&gt;&gt; +int arm_iommu_attach_device(struct device *dev,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct dma_iommu_mapping<br>
&gt;&gt; *mapping);<br>
&gt;&gt; +<br>
&gt;&gt; +#endif /* __KERNEL__ */<br>
&gt;&gt; +#endif<br>
&gt;&gt; diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c=
<br>
&gt;&gt; index d4aad65..2d11aa0 100644<br>
&gt;&gt; --- a/arch/arm/mm/dma-mapping.c<br>
&gt;&gt; +++ b/arch/arm/mm/dma-mapping.c<br>
&gt;&gt; @@ -19,6 +19,8 @@<br>
&gt;&gt; =A0#include &lt;linux/dma-mapping.h&gt;<br>
&gt;&gt; =A0#include &lt;linux/highmem.h&gt;<br>
&gt;&gt; =A0#include &lt;linux/slab.h&gt;<br>
&gt;&gt; +#include &lt;linux/iommu.h&gt;<br>
&gt;&gt; +#include &lt;linux/vmalloc.h&gt;<br>
&gt;&gt;<br>
&gt;&gt; =A0#include &lt;asm/memory.h&gt;<br>
&gt;&gt; =A0#include &lt;asm/highmem.h&gt;<br>
&gt;&gt; @@ -26,6 +28,7 @@<br>
&gt;&gt; =A0#include &lt;asm/tlbflush.h&gt;<br>
&gt;&gt; =A0#include &lt;asm/sizes.h&gt;<br>
&gt;&gt; =A0#include &lt;asm/mach/arch.h&gt;<br>
&gt;&gt; +#include &lt;asm/dma-iommu.h&gt;<br>
&gt;&gt;<br>
&gt;&gt; =A0#include &quot;mm.h&quot;<br>
&gt;&gt;<br>
&gt;&gt; @@ -155,6 +158,21 @@ static u64 get_coherent_dma_mask(struct devic=
e *dev)<br>
&gt;&gt; =A0 =A0 =A0 =A0return mask;<br>
&gt;&gt; =A0}<br>
&gt;&gt;<br>
&gt;&gt; +static void __dma_clear_buffer(struct page *page, size_t size)<br=
>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 void *ptr;<br>
&gt;&gt; + =A0 =A0 =A0 /*<br>
&gt;&gt; + =A0 =A0 =A0 =A0* Ensure that the allocated pages are zeroed, and=
 that any data<br>
&gt;&gt; + =A0 =A0 =A0 =A0* lurking in the kernel direct-mapped region is i=
nvalidated.<br>
&gt;&gt; + =A0 =A0 =A0 =A0*/<br>
&gt;&gt; + =A0 =A0 =A0 ptr =3D page_address(page);<br>
&gt;&gt; + =A0 =A0 =A0 if (ptr) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(ptr, 0, size);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dmac_flush_range(ptr, ptr + size);<b=
r>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 outer_flush_range(__pa(ptr), __pa(pt=
r) + size);<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; =A0/*<br>
&gt;&gt; =A0* Allocate a DMA buffer for &#39;dev&#39; of size &#39;size&#39=
; using the<br>
&gt;&gt; =A0* specified gfp mask. =A0Note that &#39;size&#39; must be page =
aligned.<br>
&gt;&gt; @@ -163,7 +181,6 @@ static struct page *__dma_alloc_buffer(struct =
device<br>
&gt;&gt; *dev, size_t size, gfp_t gf<br>
&gt;&gt; =A0{<br>
&gt;&gt; =A0 =A0 =A0 =A0unsigned long order =3D get_order(size);<br>
&gt;&gt; =A0 =A0 =A0 =A0struct page *page, *p, *e;<br>
&gt;&gt; - =A0 =A0 =A0 void *ptr;<br>
&gt;&gt; =A0 =A0 =A0 =A0u64 mask =3D get_coherent_dma_mask(dev);<br>
&gt;&gt;<br>
&gt;&gt; =A0#ifdef CONFIG_DMA_API_DEBUG<br>
&gt;&gt; @@ -192,14 +209,7 @@ static struct page *__dma_alloc_buffer(struct=
 device<br>
&gt;&gt; *dev, size_t size, gfp_t gf<br>
&gt;&gt; =A0 =A0 =A0 =A0for (p =3D page + (size &gt;&gt; PAGE_SHIFT), e =3D=
 page + (1 &lt;&lt; order); p &lt;<br>
&gt;&gt; e; p++)<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__free_page(p);<br>
&gt;&gt;<br>
&gt;&gt; - =A0 =A0 =A0 /*<br>
&gt;&gt; - =A0 =A0 =A0 =A0* Ensure that the allocated pages are zeroed, and=
 that any data<br>
&gt;&gt; - =A0 =A0 =A0 =A0* lurking in the kernel direct-mapped region is i=
nvalidated.<br>
&gt;&gt; - =A0 =A0 =A0 =A0*/<br>
&gt;&gt; - =A0 =A0 =A0 ptr =3D page_address(page);<br>
&gt;&gt; - =A0 =A0 =A0 memset(ptr, 0, size);<br>
&gt;&gt; - =A0 =A0 =A0 dmac_flush_range(ptr, ptr + size);<br>
&gt;&gt; - =A0 =A0 =A0 outer_flush_range(__pa(ptr), __pa(ptr) + size);<br>
&gt;&gt; + =A0 =A0 =A0 __dma_clear_buffer(page, size);<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0return page;<br>
&gt;&gt; =A0}<br>
&gt;&gt; @@ -348,7 +358,7 @@ __dma_alloc_remap(struct page *page, size_t si=
ze,<br>
&gt;&gt; gfp_t gfp, pgprot_t prot,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 off =3D CONSISTENT_OFFSET(c-&gt=
;vm_start) &amp;<br>
&gt;&gt; (PTRS_PER_PTE-1);<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pte =3D consistent_pte[idx] + off;<=
br>
&gt;&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;vm_pages =3D page;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;priv =3D page;<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!pte_none(*p=
te));<br>
&gt;&gt; @@ -461,6 +471,14 @@ __dma_alloc(struct device *dev, size_t size,<=
br>
&gt;&gt; dma_addr_t *handle, gfp_t gfp,<br>
&gt;&gt; =A0 =A0 =A0 =A0return addr;<br>
&gt;&gt; =A0}<br>
&gt;&gt;<br>
&gt;&gt; +static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, =
pgprot_t<br>
&gt;&gt; prot)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 prot =3D dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs)=
 ?<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_write=
combine(prot) :<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_dmaco=
herent(prot);<br>
&gt;&gt; + =A0 =A0 =A0 return prot;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; =A0/*<br>
&gt;&gt; =A0* Allocate DMA-coherent memory space and return both the kernel=
 remapped<br>
&gt;&gt; =A0* virtual and bus address for that space.<br>
&gt;&gt; @@ -468,9 +486,7 @@ __dma_alloc(struct device *dev, size_t size,<b=
r>
&gt;&gt; dma_addr_t *handle, gfp_t gfp,<br>
&gt;&gt; =A0void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t=
 *handle,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp, struct dma_attrs=
 *attrs)<br>
&gt;&gt; =A0{<br>
&gt;&gt; - =A0 =A0 =A0 pgprot_t prot =3D dma_get_attr(DMA_ATTR_WRITE_COMBIN=
E, attrs) ?<br>
&gt;&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_writecombine(=
pgprot_kernel) :<br>
&gt;&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_dmacoherent(p=
gprot_kernel);<br>
&gt;&gt; + =A0 =A0 =A0 pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_ker=
nel);<br>
&gt;&gt; =A0 =A0 =A0 =A0void *memory;<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0if (dma_alloc_from_coherent(dev, size, handle, &amp=
;memory))<br>
&gt;&gt; @@ -497,16 +513,20 @@ int arm_dma_mmap(struct device *dev, struct<=
br>
&gt;&gt; vm_area_struct *vma,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgprot_writ=
ecombine(vma-&gt;vm_page_prot) :<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgprot_dmac=
oherent(vma-&gt;vm_page_prot);<br>
&gt;&gt;<br>
&gt;&gt; + =A0 =A0 =A0 if (dma_mmap_from_coherent(dev, vma, cpu_addr, size,=
 &amp;ret))<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt;&gt; +<br>
&gt;&gt; =A0 =A0 =A0 =A0c =3D arm_vmregion_find(&amp;consistent_head, (unsi=
gned long)cpu_addr);<br>
&gt;&gt; =A0 =A0 =A0 =A0if (c) {<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long off =3D vma-&gt;vm_pg=
off;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *pages =3D c-&gt;priv;<b=
r>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kern_size =3D (c-&gt;vm_end - c-&gt=
;vm_start) &gt;&gt; PAGE_SHIFT;<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (off &lt; kern_size &amp;&amp;<b=
r>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0user_size &lt;=3D (kern_siz=
e - off)) {<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D remap_pfn_r=
ange(vma, vma-&gt;vm_start,<br>
&gt;&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 page_to_pfn(c-&gt;vm_pages) +<br>
&gt;&gt; off,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 page_to_pfn(pages) + off,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0user_size &lt;&lt; PAGE_SHIFT,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0vma-&gt;vm_page_prot);<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt;&gt; @@ -645,6 +665,9 @@ int arm_dma_map_sg(struct device *dev, struct<=
br>
&gt;&gt; scatterlist *sg, int nents,<br>
&gt;&gt; =A0 =A0 =A0 =A0int i, j;<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0for_each_sg(sg, s, nents, i) {<br>
&gt;&gt; +#ifdef CONFIG_NEED_SG_DMA_LENGTH<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_length =3D s-&gt;length;<b=
r>
&gt;&gt; +#endif<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s-&gt;dma_address =3D ops-&gt;map_p=
age(dev, sg_page(s), s-&gt;offset,<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s-&gt;length, dir, attrs);<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (dma_mapping_error(dev, s-&gt;dm=
a_address))<br>
&gt;&gt; @@ -753,3 +776,679 @@ static int __init dma_debug_do_init(void)<br=
>
&gt;&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt;&gt; =A0}<br>
&gt;&gt; =A0fs_initcall(dma_debug_do_init);<br>
&gt;&gt; +<br>
&gt;&gt; +#ifdef CONFIG_ARM_DMA_USE_IOMMU<br>
&gt;&gt; +<br>
&gt;&gt; +/* IOMMU */<br>
&gt;&gt; +<br>
&gt;&gt; +static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *m=
apping,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 size_t size)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int order =3D get_order(size);<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int align =3D 0;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int count, start;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned long flags;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 count =3D ((PAGE_ALIGN(size) &gt;&gt; PAGE_SHIFT) +<=
br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 &lt;&lt; mapping-&gt;order) - =
1) &gt;&gt; mapping-&gt;order;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (order &gt; mapping-&gt;order)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 align =3D (1 &lt;&lt; (order - mappi=
ng-&gt;order)) - 1;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 spin_lock_irqsave(&amp;mapping-&gt;lock, flags);<br>
&gt;&gt; + =A0 =A0 =A0 start =3D bitmap_find_next_zero_area(mapping-&gt;bit=
map, mapping-&gt;bits,<br>
&gt;&gt; 0,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0count, align);<br>
&gt;&gt; + =A0 =A0 =A0 if (start &gt; mapping-&gt;bits) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-=
&gt;lock, flags);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 bitmap_set(mapping-&gt;bitmap, start, count);<br>
&gt;&gt; + =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-&gt;lock, flags)=
;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return mapping-&gt;base + (start &lt;&lt; (mapping-&=
gt;order + PAGE_SHIFT));<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static inline void __free_iova(struct dma_iommu_mapping *mapping,=
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_a=
ddr_t addr, size_t size)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int start =3D (addr - mapping-&gt;base) &gt=
;&gt;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(mapping-=
&gt;order + PAGE_SHIFT);<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int count =3D ((size &gt;&gt; PAGE_SHIFT) +=
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 &lt;&=
lt; mapping-&gt;order) - 1) &gt;&gt;<br>
&gt;&gt; mapping-&gt;order;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned long flags;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 spin_lock_irqsave(&amp;mapping-&gt;lock, flags);<br>
&gt;&gt; + =A0 =A0 =A0 bitmap_clear(mapping-&gt;bitmap, start, count);<br>
&gt;&gt; + =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-&gt;lock, flags)=
;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static struct page **__iommu_alloc_buffer(struct device *dev, siz=
e_t<br>
&gt;&gt; size, gfp_t gfp)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct page **pages;<br>
&gt;&gt; + =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>
&gt;&gt; + =A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br=
>
&gt;&gt; + =A0 =A0 =A0 int i =3D 0;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (array_size &lt;=3D PAGE_SIZE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D kzalloc(array_size, gfp);<=
br>
&gt;&gt; + =A0 =A0 =A0 else<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D vzalloc(array_size);<br>
&gt;&gt; + =A0 =A0 =A0 if (!pages)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 while (count) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int j, order =3D __ffs(count);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D alloc_pages(gfp | __GFP=
_NOWARN, order);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (!pages[i] &amp;&amp; order)<b=
r>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D alloc_p=
ages(gfp | __GFP_NOWARN,<br>
&gt;&gt; --order);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pages[i])<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 split_page(pages[i],=
 order);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 j =3D 1 &lt;&lt; order;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (--j)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i + j] =3D pag=
es[i] + j;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_clear_buffer(pages[i], PAGE_SI=
ZE &lt;&lt; order);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i +=3D 1 &lt;&lt; order;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count -=3D 1 &lt;&lt; order;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return pages;<br>
&gt;&gt; +error:<br>
&gt;&gt; + =A0 =A0 =A0 while (--i)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages[i])<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages(pages[i=
], 0);<br>
&gt;&gt; + =A0 =A0 =A0 if (array_size &lt; PAGE_SIZE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pages);<br>
&gt;&gt; + =A0 =A0 =A0 else<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(pages);<br>
&gt;&gt; + =A0 =A0 =A0 return NULL;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static int __iommu_free_buffer(struct device *dev, struct page **=
pages,<br>
&gt;&gt; size_t size)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>
&gt;&gt; + =A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br=
>
&gt;&gt; + =A0 =A0 =A0 int i;<br>
&gt;&gt; + =A0 =A0 =A0 for (i =3D 0; i &lt; count; i++)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages[i])<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages(pages[i=
], 0);<br>
&gt;&gt; + =A0 =A0 =A0 if (array_size &lt; PAGE_SIZE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pages);<br>
&gt;&gt; + =A0 =A0 =A0 else<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(pages);<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * Create a CPU mapping for a specified pages<br>
&gt;&gt; + */<br>
&gt;&gt; +static void *<br>
&gt;&gt; +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, =
pgprot_t<br>
&gt;&gt; prot)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct arm_vmregion *c;<br>
&gt;&gt; + =A0 =A0 =A0 size_t align;<br>
&gt;&gt; + =A0 =A0 =A0 size_t count =3D size &gt;&gt; PAGE_SHIFT;<br>
&gt;&gt; + =A0 =A0 =A0 int bit;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!consistent_pte[0]) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&quot;%s: not initialised\n&q=
uot;, __func__);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_stack();<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 /*<br>
&gt;&gt; + =A0 =A0 =A0 =A0* Align the virtual region allocation - maximum a=
lignment is<br>
&gt;&gt; + =A0 =A0 =A0 =A0* a section size, minimum is a page size. =A0This=
 helps reduce<br>
&gt;&gt; + =A0 =A0 =A0 =A0* fragmentation of the DMA space, and also preven=
ts allocations<br>
&gt;&gt; + =A0 =A0 =A0 =A0* smaller than a section from crossing a section =
boundary.<br>
&gt;&gt; + =A0 =A0 =A0 =A0*/<br>
&gt;&gt; + =A0 =A0 =A0 bit =3D fls(size - 1);<br>
&gt;&gt; + =A0 =A0 =A0 if (bit &gt; SECTION_SHIFT)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bit =3D SECTION_SHIFT;<br>
&gt;&gt; + =A0 =A0 =A0 align =3D 1 &lt;&lt; bit;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 /*<br>
&gt;&gt; + =A0 =A0 =A0 =A0* Allocate a virtual address in the consistent ma=
pping region.<br>
&gt;&gt; + =A0 =A0 =A0 =A0*/<br>
&gt;&gt; + =A0 =A0 =A0 c =3D arm_vmregion_alloc(&amp;consistent_head, align=
, size,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp &amp; ~(=
__GFP_DMA | __GFP_HIGHMEM), NULL);<br>
&gt;&gt; + =A0 =A0 =A0 if (c) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte_t *pte;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int idx =3D CONSISTENT_PTE_INDEX(c-&=
gt;vm_start);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 off =3D CONSISTENT_OFFSET(c-&gt;=
vm_start) &amp;<br>
&gt;&gt; (PTRS_PER_PTE-1);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte =3D consistent_pte[idx] + off;<b=
r>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;priv =3D pages;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!pte_none(*pt=
e));<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pte_ext(pte, mk_=
pte(pages[i], prot), 0);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte++;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 off++;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i++;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (off &gt;=3D PTRS=
_PER_PTE) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =
=3D 0;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte =
=3D consistent_pte[++idx];<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (i &lt; count);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dsb();<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (void *)c-&gt;vm_start;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 return NULL;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * Create a mapping in device IO address space for specified page=
s<br>
&gt;&gt; + */<br>
&gt;&gt; +static dma_addr_t<br>
&gt;&gt; +__iommu_create_mapping(struct device *dev, struct page **pages, s=
ize_t<br>
&gt;&gt; size)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int count =3D PAGE_ALIGN(size) &gt;&gt; PAG=
E_SHIFT;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t dma_addr, iova;<br>
&gt;&gt; + =A0 =A0 =A0 int i, ret =3D DMA_ERROR_CODE;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr =3D __alloc_iova(mapping, size);<br>
&gt;&gt; + =A0 =A0 =A0 if (dma_addr =3D=3D DMA_ERROR_CODE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dma_addr;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 iova =3D dma_addr;<br>
&gt;&gt; + =A0 =A0 =A0 for (i =3D 0; i &lt; count; ) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int next_pfn =3D page_to_pf=
n(pages[i]) + 1;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t phys =3D page_to_phys(pa=
ges[i]);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int len, j;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D i + 1; j &lt; count; j++,=
 next_pfn++)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_to_pfn(page=
s[j]) !=3D next_pfn)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 brea=
k;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D (j - i) &lt;&lt; PAGE_SHIFT;=
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain=
, iova, phys, len, 0);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iova +=3D len;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D j;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 return dma_addr;<br>
&gt;&gt; +fail:<br>
&gt;&gt; + =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, dma_addr, iova-dma_a=
ddr);<br>
&gt;&gt; + =A0 =A0 =A0 __free_iova(mapping, dma_addr, size);<br>
&gt;&gt; + =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static int __iommu_remove_mapping(struct device *dev, dma_addr_t =
iova,<br>
&gt;&gt; size_t size)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 /*<br>
&gt;&gt; + =A0 =A0 =A0 =A0* add optional in-page offset from iova to size a=
nd align<br>
&gt;&gt; + =A0 =A0 =A0 =A0* result to page size<br>
&gt;&gt; + =A0 =A0 =A0 =A0*/<br>
&gt;&gt; + =A0 =A0 =A0 size =3D PAGE_ALIGN((iova &amp; ~PAGE_MASK) + size);=
<br>
&gt;&gt; + =A0 =A0 =A0 iova &amp;=3D PAGE_MASK;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova, size);<br>
&gt;&gt; + =A0 =A0 =A0 __free_iova(mapping, iova, size);<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static void *arm_iommu_alloc_attrs(struct device *dev, size_t siz=
e,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 dma_addr_t *handle, gfp_t gfp, struct dma_at=
trs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_ker=
nel);<br>
&gt;&gt; + =A0 =A0 =A0 struct page **pages;<br>
&gt;&gt; + =A0 =A0 =A0 void *addr =3D NULL;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 *handle =3D DMA_ERROR_CODE;<br>
&gt;&gt; + =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 pages =3D __iommu_alloc_buffer(dev, size, gfp);<br>
&gt;&gt; + =A0 =A0 =A0 if (!pages)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 *handle =3D __iommu_create_mapping(dev, pages, size)=
;<br>
&gt;&gt; + =A0 =A0 =A0 if (*handle =3D=3D DMA_ERROR_CODE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_buffer;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 addr =3D __iommu_alloc_remap(pages, size, gfp, prot)=
;<br>
&gt;&gt; + =A0 =A0 =A0 if (!addr)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_mapping;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return addr;<br>
&gt;&gt; +<br>
&gt;&gt; +err_mapping:<br>
&gt;&gt; + =A0 =A0 =A0 __iommu_remove_mapping(dev, *handle, size);<br>
&gt;&gt; +err_buffer:<br>
&gt;&gt; + =A0 =A0 =A0 __iommu_free_buffer(dev, pages, size);<br>
&gt;&gt; + =A0 =A0 =A0 return NULL;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static int arm_iommu_mmap_attrs(struct device *dev, struct vm_are=
a_struct<br>
&gt;&gt; *vma,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *cpu_addr, dma_addr_t d=
ma_addr, size_t size,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct arm_vmregion *c;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 vma-&gt;vm_page_prot =3D __get_dma_pgprot(attrs, vma=
-&gt;vm_page_prot);<br>
&gt;&gt; + =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_head, (unsig=
ned long)cpu_addr);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (c) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<=
br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long uaddr =3D vma-&gt;vm_s=
tart;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long usize =3D vma-&gt;vm_e=
nd - vma-&gt;vm_start;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vm_insert_pa=
ge(vma, uaddr, pages[i++]);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_e=
rr(&quot;Remapping memory, error: %d\n&quot;,<br>
&gt;&gt; ret);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retu=
rn ret;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uaddr +=3D PAGE_SIZE=
;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usize -=3D PAGE_SIZE=
;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (usize &gt; 0);<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * free a page as defined by the above mapping.<br>
&gt;&gt; + * Must not be called with IRQs disabled.<br>
&gt;&gt; + */<br>
&gt;&gt; +void arm_iommu_free_attrs(struct device *dev, size_t size, void<b=
r>
&gt;&gt; *cpu_addr,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handl=
e, struct dma_attrs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct arm_vmregion *c;<br>
&gt;&gt; + =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_head, (unsig=
ned long)cpu_addr);<br>
&gt;&gt; + =A0 =A0 =A0 if (c) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<=
br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_free_remap(cpu_addr, size);<br=
>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, handle, =
size);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_free_buffer(dev, pages, size=
);<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * Map a part of the scatter-gather list into contiguous io addre=
ss space<br>
&gt;&gt; + */<br>
&gt;&gt; +static int __map_sg_chunk(struct device *dev, struct scatterlist =
*sg,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, dma=
_addr_t *handle,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum dma_data_di=
rection dir)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t iova, iova_base;<br>
&gt;&gt; + =A0 =A0 =A0 int ret =3D 0;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int count;<br>
&gt;&gt; + =A0 =A0 =A0 struct scatterlist *s;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
&gt;&gt; + =A0 =A0 =A0 *handle =3D DMA_ERROR_CODE;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 iova_base =3D iova =3D __alloc_iova(mapping, size);<=
br>
&gt;&gt; + =A0 =A0 =A0 if (iova =3D=3D DMA_ERROR_CODE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 for (count =3D 0, s =3D sg; count &lt; (size &gt;&gt=
; PAGE_SHIFT); s =3D<br>
&gt;&gt; sg_next(s)) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t phys =3D page_to_phys(sg=
_page(s));<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int len =3D PAGE_ALIGN(s-&g=
t;offset + s-&gt;length);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_de=
v(sg_page(s), s-&gt;offset,<br>
&gt;&gt; s-&gt;length, dir);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain=
, iova, phys, len, 0);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D len &gt;&gt; PAGE_SHIFT;<=
br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iova +=3D len;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 *handle =3D iova_base;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +fail:<br>
&gt;&gt; + =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova_base, count * P=
AGE_SIZE);<br>
&gt;&gt; + =A0 =A0 =A0 __free_iova(mapping, iova_base, size);<br>
&gt;&gt; + =A0 =A0 =A0 return ret;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_map_sg - map a set of SG buffers for streaming mode =
DMA<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @sg: list of buffers<br>
&gt;&gt; + * @nents: number of buffers to map<br>
&gt;&gt; + * @dir: DMA transfer direction<br>
&gt;&gt; + *<br>
&gt;&gt; + * Map a set of buffers described by scatterlist in streaming mod=
e for<br>
&gt;&gt; DMA.<br>
&gt;&gt; + * The scatter gather list elements are merged together (if possi=
ble) and<br>
&gt;&gt; + * tagged with the appropriate dma address and length. They are o=
btained<br>
&gt;&gt; via<br>
&gt;&gt; + * sg_dma_{address,length}.<br>
&gt;&gt; + */<br>
&gt;&gt; +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, =
int<br>
&gt;&gt; nents,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction d=
ir, struct dma_attrs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct scatterlist *s =3D sg, *dma =3D sg, *start =
=3D sg;<br>
&gt;&gt; + =A0 =A0 =A0 int i, count =3D 0;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int offset =3D s-&gt;offset;<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int size =3D s-&gt;offset + s-&gt;length;<b=
r>
&gt;&gt; + =A0 =A0 =A0 unsigned int max =3D dma_get_max_seg_size(dev);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 for (i =3D 1; i &lt; nents; i++) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D sg_next(s);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_address =3D DMA_ERROR_CODE=
;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_length =3D 0;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s-&gt;offset || (size &amp; ~PAG=
E_MASK) || size + s-&gt;length &gt;<br>
&gt;&gt; max) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__map_sg_chunk(d=
ev, start, size,<br>
&gt;&gt; &amp;dma-&gt;dma_address,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir) &lt; 0)=
<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto=
 bad_mapping;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma-&gt;dma_address =
+=3D offset;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma-&gt;dma_length =
=3D size - offset;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D offset =3D =
s-&gt;offset;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D s;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma =3D sg_next(dma)=
;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D 1;<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D s-&gt;length;<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; + =A0 =A0 =A0 if (__map_sg_chunk(dev, start, size, &amp;dma-&gt;dm=
a_address, dir) &lt; 0)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_mapping;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 dma-&gt;dma_address +=3D offset;<br>
&gt;&gt; + =A0 =A0 =A0 dma-&gt;dma_length =3D size - offset;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return count+1;<br>
&gt;&gt; +<br>
&gt;&gt; +bad_mapping:<br>
&gt;&gt; + =A0 =A0 =A0 for_each_sg(sg, s, count, i)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, sg_dma_a=
ddress(s),<br>
&gt;&gt; sg_dma_len(s));<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_unmap_sg - unmap a set of SG buffers mapped by dma_m=
ap_sg<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @sg: list of buffers<br>
&gt;&gt; + * @nents: number of buffers to unmap (same as was passed to dma_=
map_sg)<br>
&gt;&gt; + * @dir: DMA transfer direction (same as was passed to dma_map_sg=
)<br>
&gt;&gt; + *<br>
&gt;&gt; + * Unmap a set of streaming mode DMA translations. =A0Again, CPU =
access<br>
&gt;&gt; + * rules concerning calls here are the same as for dma_unmap_sing=
le().<br>
&gt;&gt; + */<br>
&gt;&gt; +void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *s=
g, int<br>
&gt;&gt; nents,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum dma_data_direct=
ion dir, struct dma_attrs<br>
&gt;&gt; *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct scatterlist *s;<br>
&gt;&gt; + =A0 =A0 =A0 int i;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 for_each_sg(sg, s, nents, i) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sg_dma_len(s))<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mappi=
ng(dev, sg_dma_address(s),<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0sg_dma_len(s));<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cp=
u(sg_page(s), s-&gt;offset,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 s-&gt;length, dir);<br>
&gt;&gt; + =A0 =A0 =A0 }<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_sync_sg_for_cpu<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @sg: list of buffers<br>
&gt;&gt; + * @nents: number of buffers to map (returned from dma_map_sg)<br=
>
&gt;&gt; + * @dir: DMA transfer direction (same as was passed to dma_map_sg=
)<br>
&gt;&gt; + */<br>
&gt;&gt; +void arm_iommu_sync_sg_for_cpu(struct device *dev, struct scatter=
list<br>
&gt;&gt; *sg,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nents, enum dma_=
data_direction dir)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct scatterlist *s;<br>
&gt;&gt; + =A0 =A0 =A0 int i;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 for_each_sg(sg, s, nents, i)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cp=
u(sg_page(s), s-&gt;offset,<br>
&gt;&gt; s-&gt;length, dir);<br>
&gt;&gt; +<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_sync_sg_for_device<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @sg: list of buffers<br>
&gt;&gt; + * @nents: number of buffers to map (returned from dma_map_sg)<br=
>
&gt;&gt; + * @dir: DMA transfer direction (same as was passed to dma_map_sg=
)<br>
&gt;&gt; + */<br>
&gt;&gt; +void arm_iommu_sync_sg_for_device(struct device *dev, struct scat=
terlist<br>
&gt;&gt; *sg,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nents, enum dma_=
data_direction dir)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct scatterlist *s;<br>
&gt;&gt; + =A0 =A0 =A0 int i;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 for_each_sg(sg, s, nents, i)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_de=
v(sg_page(s), s-&gt;offset,<br>
&gt;&gt; s-&gt;length, dir);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_map_page<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @page: page that buffer resides in<br>
&gt;&gt; + * @offset: offset into page for start of buffer<br>
&gt;&gt; + * @size: size of buffer to map<br>
&gt;&gt; + * @dir: DMA transfer direction<br>
&gt;&gt; + *<br>
&gt;&gt; + * IOMMU aware version of arm_dma_map_page()<br>
&gt;&gt; + */<br>
&gt;&gt; +static dma_addr_t arm_iommu_map_page(struct device *dev, struct p=
age<br>
&gt;&gt; *page,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0unsigned long offset, size_t size, enum d=
ma_data_direction<br>
&gt;&gt; dir,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0struct dma_attrs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t dma_addr;<br>
&gt;&gt; + =A0 =A0 =A0 int ret, len =3D PAGE_ALIGN(size + offset);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_dev(page, offset, =
size, dir);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr =3D __alloc_iova(mapping, len);<br>
&gt;&gt; + =A0 =A0 =A0 if (dma_addr =3D=3D DMA_ERROR_CODE)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dma_addr;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain, dma_addr, page=
_to_phys(page),<br>
&gt;&gt; len, 0);<br>
&gt;&gt; + =A0 =A0 =A0 if (ret &lt; 0)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 return dma_addr + offset;<br>
&gt;&gt; +fail:<br>
&gt;&gt; + =A0 =A0 =A0 __free_iova(mapping, dma_addr, len);<br>
&gt;&gt; + =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_unmap_page<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @handle: DMA address of buffer<br>
&gt;&gt; + * @size: size of buffer (same as passed to dma_map_page)<br>
&gt;&gt; + * @dir: DMA transfer direction (same as passed to dma_map_page)<=
br>
&gt;&gt; + *<br>
&gt;&gt; + * IOMMU aware version of arm_dma_unmap_page()<br>
&gt;&gt; + */<br>
&gt;&gt; +static void arm_iommu_unmap_page(struct device *dev, dma_addr_t h=
andle,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, enum dma_data_direction=
 dir,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
&gt;&gt; + =A0 =A0 =A0 struct page *page =3D<br>
&gt;&gt; phys_to_page(iommu_iova_to_phys(mapping-&gt;domain, iova));<br>
&gt;&gt; + =A0 =A0 =A0 int offset =3D handle &amp; ~PAGE_MASK;<br>
&gt;&gt; + =A0 =A0 =A0 int len =3D PAGE_ALIGN(size + offset);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!iova)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(page, offset, =
size, dir);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova, len);<br>
&gt;&gt; + =A0 =A0 =A0 __free_iova(mapping, iova, len);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static void arm_iommu_sync_single_for_cpu(struct device *dev,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, size_t size, enum=
 dma_data_direction<br>
&gt;&gt; dir)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
&gt;&gt; + =A0 =A0 =A0 struct page *page =3D<br>
&gt;&gt; phys_to_page(iommu_iova_to_phys(mapping-&gt;domain, iova));<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int offset =3D handle &amp; ~PAGE_MASK;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!iova)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!arch_is_coherent())<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(page, offset, =
size, dir);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static void arm_iommu_sync_single_for_device(struct device *dev,<=
br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, size_t size, enum=
 dma_data_direction<br>
&gt;&gt; dir)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archda=
ta.mapping;<br>
&gt;&gt; + =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
&gt;&gt; + =A0 =A0 =A0 struct page *page =3D<br>
&gt;&gt; phys_to_page(iommu_iova_to_phys(mapping-&gt;domain, iova));<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int offset =3D handle &amp; ~PAGE_MASK;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!iova)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 __dma_page_cpu_to_dev(page, offset, size, dir);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +struct dma_map_ops iommu_ops =3D {<br>
&gt;&gt; + =A0 =A0 =A0 .alloc =A0 =A0 =A0 =A0 =A0=3D arm_iommu_alloc_attrs,=
<br>
&gt;&gt; + =A0 =A0 =A0 .free =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_free_attrs,<=
br>
&gt;&gt; + =A0 =A0 =A0 .mmap =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_mmap_attrs,<=
br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 .map_page =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_=
map_page,<br>
&gt;&gt; + =A0 =A0 =A0 .unmap_page =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_un=
map_page,<br>
&gt;&gt; + =A0 =A0 =A0 .sync_single_for_cpu =A0 =A0=3D arm_iommu_sync_singl=
e_for_cpu,<br>
&gt;&gt; + =A0 =A0 =A0 .sync_single_for_device =3D arm_iommu_sync_single_fo=
r_device,<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 .map_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iomm=
u_map_sg,<br>
&gt;&gt; + =A0 =A0 =A0 .unmap_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_=
unmap_sg,<br>
&gt;&gt; + =A0 =A0 =A0 .sync_sg_for_cpu =A0 =A0 =A0 =A0=3D arm_iommu_sync_s=
g_for_cpu,<br>
&gt;&gt; + =A0 =A0 =A0 .sync_sg_for_device =A0 =A0 =3D arm_iommu_sync_sg_fo=
r_device,<br>
&gt;&gt; +};<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_create_mapping<br>
&gt;&gt; + * @bus: pointer to the bus holding the client device (for IOMMU =
calls)<br>
&gt;&gt; + * @base: start address of the valid IO address space<br>
&gt;&gt; + * @size: size of the valid IO address space<br>
&gt;&gt; + * @order: accuracy of the IO addresses allocations<br>
&gt;&gt; + *<br>
&gt;&gt; + * Creates a mapping structure which holds information about used=
/unused<br>
&gt;&gt; + * IO address ranges, which is required to perform memory allocat=
ion and<br>
&gt;&gt; + * mapping with IOMMU aware functions.<br>
&gt;&gt; + *<br>
&gt;&gt; + * The client device need to be attached to the mapping with<br>
&gt;&gt; + * arm_iommu_attach_device function.<br>
&gt;&gt; + */<br>
&gt;&gt; +struct dma_iommu_mapping *<br>
&gt;&gt; +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, s=
ize_t<br>
&gt;&gt; size,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int count =3D size &gt;&gt; (PAGE_SHIFT + o=
rder);<br>
&gt;&gt; + =A0 =A0 =A0 unsigned int bitmap_size =3D BITS_TO_LONGS(count) * =
sizeof(long);<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping;<br>
&gt;&gt; + =A0 =A0 =A0 int err =3D -ENOMEM;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 if (!count)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 mapping =3D kzalloc(sizeof(struct dma_iommu_mapping)=
, GFP_KERNEL);<br>
&gt;&gt; + =A0 =A0 =A0 if (!mapping)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 mapping-&gt;bitmap =3D kzalloc(bitmap_size, GFP_KERN=
EL);<br>
&gt;&gt; + =A0 =A0 =A0 if (!mapping-&gt;bitmap)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err2;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 mapping-&gt;base =3D base;<br>
&gt;&gt; + =A0 =A0 =A0 mapping-&gt;bits =3D BITS_PER_BYTE * bitmap_size;<br=
>
&gt;&gt; + =A0 =A0 =A0 mapping-&gt;order =3D order;<br>
&gt;&gt; + =A0 =A0 =A0 spin_lock_init(&amp;mapping-&gt;lock);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 mapping-&gt;domain =3D iommu_domain_alloc(bus);<br>
&gt;&gt; + =A0 =A0 =A0 if (!mapping-&gt;domain)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err3;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 kref_init(&amp;mapping-&gt;kref);<br>
&gt;&gt; + =A0 =A0 =A0 return mapping;<br>
&gt;&gt; +err3:<br>
&gt;&gt; + =A0 =A0 =A0 kfree(mapping-&gt;bitmap);<br>
&gt;&gt; +err2:<br>
&gt;&gt; + =A0 =A0 =A0 kfree(mapping);<br>
&gt;&gt; +err:<br>
&gt;&gt; + =A0 =A0 =A0 return ERR_PTR(err);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +static void release_iommu_mapping(struct kref *kref)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(kref, struct dma_iommu_=
mapping, kref);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 iommu_domain_free(mapping-&gt;domain);<br>
&gt;&gt; + =A0 =A0 =A0 kfree(mapping-&gt;bitmap);<br>
&gt;&gt; + =A0 =A0 =A0 kfree(mapping);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)=
<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 if (mapping)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_put(&amp;mapping-&gt;kref, rele=
ase_iommu_mapping);<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +/**<br>
&gt;&gt; + * arm_iommu_attach_device<br>
&gt;&gt; + * @dev: valid struct device pointer<br>
&gt;&gt; + * @mapping: io address space mapping structure (returned from<br=
>
&gt;&gt; + * =A0 =A0 arm_iommu_create_mapping)<br>
&gt;&gt; + *<br>
&gt;&gt; + * Attaches specified io address space mapping to the provided de=
vice,<br>
&gt;&gt; + * this replaces the dma operations (dma_map_ops pointer) with th=
e<br>
&gt;&gt; + * IOMMU aware version. More than one client might be attached to=
<br>
&gt;&gt; + * the same io address space mapping.<br>
&gt;&gt; + */<br>
&gt;&gt; +int arm_iommu_attach_device(struct device *dev,<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_i=
ommu_mapping *mapping)<br>
&gt;&gt; +{<br>
&gt;&gt; + =A0 =A0 =A0 int err;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 err =3D iommu_attach_device(mapping-&gt;domain, dev)=
;<br>
&gt;&gt; + =A0 =A0 =A0 if (err)<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 kref_get(&amp;mapping-&gt;kref);<br>
&gt;&gt; + =A0 =A0 =A0 dev-&gt;archdata.mapping =3D mapping;<br>
&gt;&gt; + =A0 =A0 =A0 set_dma_ops(dev, &amp;iommu_ops);<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0 pr_info(&quot;Attached IOMMU controller to %s device=
.\n&quot;,<br>
&gt;&gt; dev_name(dev));<br>
&gt;&gt; + =A0 =A0 =A0 return 0;<br>
&gt;&gt; +}<br>
&gt;&gt; +<br>
&gt;&gt; +#endif<br>
&gt;&gt; diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h<br>
&gt;&gt; index 162be66..bf312c3 100644<br>
&gt;&gt; --- a/arch/arm/mm/vmregion.h<br>
&gt;&gt; +++ b/arch/arm/mm/vmregion.h<br>
&gt;&gt; @@ -17,7 +17,7 @@ struct arm_vmregion {<br>
&gt;&gt; =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0vm_list;<br>
&gt;&gt; =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 vm_start;<br>
&gt;&gt; =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 vm_end;<br>
&gt;&gt; - =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *vm_pages;<br>
&gt;&gt; + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*priv;<b=
r>
&gt;&gt; =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm_acti=
ve;<br>
&gt;&gt; =A0 =A0 =A0 =A0const void =A0 =A0 =A0 =A0 =A0 =A0 =A0*caller;<br>
&gt;&gt; =A0};<br>
&gt;&gt; --<br>
&gt;&gt; 1.7.1.569.g6f426<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; _______________________________________________<br>
&gt;&gt; Linaro-mm-sig mailing list<br>
&gt;&gt; <a href=3D"mailto:Linaro-mm-sig@lists.linaro.org">Linaro-mm-sig@li=
sts.linaro.org</a><br>
&gt;&gt; <a href=3D"http://lists.linaro.org/mailman/listinfo/linaro-mm-sig"=
 target=3D"_blank">http://lists.linaro.org/mailman/listinfo/linaro-mm-sig</=
a><br>
&gt;&gt;<br>
&gt;<br>
</div></div></blockquote></div><br>

--f46d043bd7e86bd84104be564a32--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
