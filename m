Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3C4116B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 21:44:09 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so7756370wgb.26
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 18:44:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
References: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
	<1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
Date: Fri, 20 Apr 2012 10:44:05 +0900
Message-ID: <CALYq+qT0VeXH+1Zu_hWC4EzBPFTb2isxn6U6gH5JQgLU6FC4FA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv9 10/10] ARM: dma-mapping: add support for
 IOMMU mapper
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=0016e6d58a1a74164f04be126cd0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>, Joerg Roedel <joro@8bytes.org>

--0016e6d58a1a74164f04be126cd0
Content-Type: text/plain; charset=ISO-8859-1

Hi Marek,

dma_addr_t dma_addr is an unused argument passed to the function
arm_iommu_mmap_attrs

+static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct
*vma,
+                   void *cpu_addr, dma_addr_t dma_addr, size_t size,
+                   struct dma_attrs *attrs)
+{
+       struct arm_vmregion *c;
+
+       vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
+       c = arm_vmregion_find(&consistent_
head, (unsigned long)cpu_addr);
+
+       if (c) {
+               struct page **pages = c->priv;
+
+               unsigned long uaddr = vma->vm_start;
+               unsigned long usize = vma->vm_end - vma->vm_start;
+               int i = 0;
+
+               do {
+                       int ret;
+
+                       ret = vm_insert_page(vma, uaddr, pages[i++]);
+                       if (ret) {
+                               pr_err("Remapping memory, error: %d\n",
ret);
+                               return ret;
+                       }
+
+                       uaddr += PAGE_SIZE;
+                       usize -= PAGE_SIZE;
+               } while (usize > 0);
+       }
+       return 0;
+}


On Wed, Apr 18, 2012 at 10:44 PM, Marek Szyprowski <m.szyprowski@samsung.com
> wrote:

> This patch add a complete implementation of DMA-mapping API for
> devices which have IOMMU support.
>
> This implementation tries to optimize dma address space usage by remapping
> all possible physical memory chunks into a single dma address space chunk.
>
> DMA address space is managed on top of the bitmap stored in the
> dma_iommu_mapping structure stored in device->archdata. Platform setup
> code has to initialize parameters of the dma address space (base address,
> size, allocation precision order) with arm_iommu_create_mapping() function.
> To reduce the size of the bitmap, all allocations are aligned to the
> specified order of base 4 KiB pages.
>
> dma_alloc_* functions allocate physical memory in chunks, each with
> alloc_pages() function to avoid failing if the physical memory gets
> fragmented. In worst case the allocated buffer is composed of 4 KiB page
> chunks.
>
> dma_map_sg() function minimizes the total number of dma address space
> chunks by merging of physical memory chunks into one larger dma address
> space chunk. If requested chunk (scatter list entry) boundaries
> match physical page boundaries, most calls to dma_map_sg() requests will
> result in creating only one chunk in dma address space.
>
> dma_map_page() simply creates a mapping for the given page(s) in the dma
> address space.
>
> All dma functions also perform required cache operation like their
> counterparts from the arm linear physical memory mapping version.
>
> This patch contains code and fixes kindly provided by:
> - Krishna Reddy <vdumpa@nvidia.com>,
> - Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
> - Hiroshi DOYU <hdoyu@nvidia.com>
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
> ---
>  arch/arm/Kconfig                 |    8 +
>  arch/arm/include/asm/device.h    |    3 +
>  arch/arm/include/asm/dma-iommu.h |   34 ++
>  arch/arm/mm/dma-mapping.c        |  727
> +++++++++++++++++++++++++++++++++++++-
>  arch/arm/mm/vmregion.h           |    2 +-
>  5 files changed, 759 insertions(+), 15 deletions(-)
>  create mode 100644 arch/arm/include/asm/dma-iommu.h
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 0fd27d4..874e519 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -46,6 +46,14 @@ config ARM
>  config ARM_HAS_SG_CHAIN
>        bool
>
> +config NEED_SG_DMA_LENGTH
> +       bool
> +
> +config ARM_DMA_USE_IOMMU
> +       select NEED_SG_DMA_LENGTH
> +       select ARM_HAS_SG_CHAIN
> +       bool
> +
>  config HAVE_PWM
>        bool
>
> diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
> index 6e2cb0e..b69c0d3 100644
> --- a/arch/arm/include/asm/device.h
> +++ b/arch/arm/include/asm/device.h
> @@ -14,6 +14,9 @@ struct dev_archdata {
>  #ifdef CONFIG_IOMMU_API
>        void *iommu; /* private IOMMU data */
>  #endif
> +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> +       struct dma_iommu_mapping        *mapping;
> +#endif
>  };
>
>  struct omap_device;
> diff --git a/arch/arm/include/asm/dma-iommu.h
> b/arch/arm/include/asm/dma-iommu.h
> new file mode 100644
> index 0000000..799b094
> --- /dev/null
> +++ b/arch/arm/include/asm/dma-iommu.h
> @@ -0,0 +1,34 @@
> +#ifndef ASMARM_DMA_IOMMU_H
> +#define ASMARM_DMA_IOMMU_H
> +
> +#ifdef __KERNEL__
> +
> +#include <linux/mm_types.h>
> +#include <linux/scatterlist.h>
> +#include <linux/dma-debug.h>
> +#include <linux/kmemcheck.h>
> +
> +struct dma_iommu_mapping {
> +       /* iommu specific data */
> +       struct iommu_domain     *domain;
> +
> +       void                    *bitmap;
> +       size_t                  bits;
> +       unsigned int            order;
> +       dma_addr_t              base;
> +
> +       spinlock_t              lock;
> +       struct kref             kref;
> +};
> +
> +struct dma_iommu_mapping *
> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t
> size,
> +                        int order);
> +
> +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
> +
> +int arm_iommu_attach_device(struct device *dev,
> +                                       struct dma_iommu_mapping *mapping);
> +
> +#endif /* __KERNEL__ */
> +#endif
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index d4aad65..2d11aa0 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -19,6 +19,8 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/highmem.h>
>  #include <linux/slab.h>
> +#include <linux/iommu.h>
> +#include <linux/vmalloc.h>
>
>  #include <asm/memory.h>
>  #include <asm/highmem.h>
> @@ -26,6 +28,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/sizes.h>
>  #include <asm/mach/arch.h>
> +#include <asm/dma-iommu.h>
>
>  #include "mm.h"
>
> @@ -155,6 +158,21 @@ static u64 get_coherent_dma_mask(struct device *dev)
>        return mask;
>  }
>
> +static void __dma_clear_buffer(struct page *page, size_t size)
> +{
> +       void *ptr;
> +       /*
> +        * Ensure that the allocated pages are zeroed, and that any data
> +        * lurking in the kernel direct-mapped region is invalidated.
> +        */
> +       ptr = page_address(page);
> +       if (ptr) {
> +               memset(ptr, 0, size);
> +               dmac_flush_range(ptr, ptr + size);
> +               outer_flush_range(__pa(ptr), __pa(ptr) + size);
> +       }
> +}
> +
>  /*
>  * Allocate a DMA buffer for 'dev' of size 'size' using the
>  * specified gfp mask.  Note that 'size' must be page aligned.
> @@ -163,7 +181,6 @@ static struct page *__dma_alloc_buffer(struct device
> *dev, size_t size, gfp_t gf
>  {
>        unsigned long order = get_order(size);
>        struct page *page, *p, *e;
> -       void *ptr;
>        u64 mask = get_coherent_dma_mask(dev);
>
>  #ifdef CONFIG_DMA_API_DEBUG
> @@ -192,14 +209,7 @@ static struct page *__dma_alloc_buffer(struct device
> *dev, size_t size, gfp_t gf
>        for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p <
> e; p++)
>                __free_page(p);
>
> -       /*
> -        * Ensure that the allocated pages are zeroed, and that any data
> -        * lurking in the kernel direct-mapped region is invalidated.
> -        */
> -       ptr = page_address(page);
> -       memset(ptr, 0, size);
> -       dmac_flush_range(ptr, ptr + size);
> -       outer_flush_range(__pa(ptr), __pa(ptr) + size);
> +       __dma_clear_buffer(page, size);
>
>        return page;
>  }
> @@ -348,7 +358,7 @@ __dma_alloc_remap(struct page *page, size_t size,
> gfp_t gfp, pgprot_t prot,
>                u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
>
>                pte = consistent_pte[idx] + off;
> -               c->vm_pages = page;
> +               c->priv = page;
>
>                do {
>                        BUG_ON(!pte_none(*pte));
> @@ -461,6 +471,14 @@ __dma_alloc(struct device *dev, size_t size,
> dma_addr_t *handle, gfp_t gfp,
>        return addr;
>  }
>
> +static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t
> prot)
> +{
> +       prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
> +                           pgprot_writecombine(prot) :
> +                           pgprot_dmacoherent(prot);
> +       return prot;
> +}
> +
>  /*
>  * Allocate DMA-coherent memory space and return both the kernel remapped
>  * virtual and bus address for that space.
> @@ -468,9 +486,7 @@ __dma_alloc(struct device *dev, size_t size,
> dma_addr_t *handle, gfp_t gfp,
>  void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>                    gfp_t gfp, struct dma_attrs *attrs)
>  {
> -       pgprot_t prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
> -                       pgprot_writecombine(pgprot_kernel) :
> -                       pgprot_dmacoherent(pgprot_kernel);
> +       pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
>        void *memory;
>
>        if (dma_alloc_from_coherent(dev, size, handle, &memory))
> @@ -497,16 +513,20 @@ int arm_dma_mmap(struct device *dev, struct
> vm_area_struct *vma,
>                            pgprot_writecombine(vma->vm_page_prot) :
>                            pgprot_dmacoherent(vma->vm_page_prot);
>
> +       if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
> +               return ret;
> +
>        c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
>        if (c) {
>                unsigned long off = vma->vm_pgoff;
> +               struct page *pages = c->priv;
>
>                kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
>
>                if (off < kern_size &&
>                    user_size <= (kern_size - off)) {
>                        ret = remap_pfn_range(vma, vma->vm_start,
> -                                             page_to_pfn(c->vm_pages) +
> off,
> +                                             page_to_pfn(pages) + off,
>                                              user_size << PAGE_SHIFT,
>                                              vma->vm_page_prot);
>                }
> @@ -645,6 +665,9 @@ int arm_dma_map_sg(struct device *dev, struct
> scatterlist *sg, int nents,
>        int i, j;
>
>        for_each_sg(sg, s, nents, i) {
> +#ifdef CONFIG_NEED_SG_DMA_LENGTH
> +               s->dma_length = s->length;
> +#endif
>                s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
>                                                s->length, dir, attrs);
>                if (dma_mapping_error(dev, s->dma_address))
> @@ -753,3 +776,679 @@ static int __init dma_debug_do_init(void)
>        return 0;
>  }
>  fs_initcall(dma_debug_do_init);
> +
> +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> +
> +/* IOMMU */
> +
> +static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
> +                                     size_t size)
> +{
> +       unsigned int order = get_order(size);
> +       unsigned int align = 0;
> +       unsigned int count, start;
> +       unsigned long flags;
> +
> +       count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
> +                (1 << mapping->order) - 1) >> mapping->order;
> +
> +       if (order > mapping->order)
> +               align = (1 << (order - mapping->order)) - 1;
> +
> +       spin_lock_irqsave(&mapping->lock, flags);
> +       start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits,
> 0,
> +                                          count, align);
> +       if (start > mapping->bits) {
> +               spin_unlock_irqrestore(&mapping->lock, flags);
> +               return DMA_ERROR_CODE;
> +       }
> +
> +       bitmap_set(mapping->bitmap, start, count);
> +       spin_unlock_irqrestore(&mapping->lock, flags);
> +
> +       return mapping->base + (start << (mapping->order + PAGE_SHIFT));
> +}
> +
> +static inline void __free_iova(struct dma_iommu_mapping *mapping,
> +                              dma_addr_t addr, size_t size)
> +{
> +       unsigned int start = (addr - mapping->base) >>
> +                            (mapping->order + PAGE_SHIFT);
> +       unsigned int count = ((size >> PAGE_SHIFT) +
> +                             (1 << mapping->order) - 1) >> mapping->order;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&mapping->lock, flags);
> +       bitmap_clear(mapping->bitmap, start, count);
> +       spin_unlock_irqrestore(&mapping->lock, flags);
> +}
> +
> +static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> size, gfp_t gfp)
> +{
> +       struct page **pages;
> +       int count = size >> PAGE_SHIFT;
> +       int array_size = count * sizeof(struct page *);
> +       int i = 0;
> +
> +       if (array_size <= PAGE_SIZE)
> +               pages = kzalloc(array_size, gfp);
> +       else
> +               pages = vzalloc(array_size);
> +       if (!pages)
> +               return NULL;
> +
> +       while (count) {
> +               int j, order = __ffs(count);
> +
> +               pages[i] = alloc_pages(gfp | __GFP_NOWARN, order);
> +               while (!pages[i] && order)
> +                       pages[i] = alloc_pages(gfp | __GFP_NOWARN,
> --order);
> +               if (!pages[i])
> +                       goto error;
> +
> +               if (order)
> +                       split_page(pages[i], order);
> +               j = 1 << order;
> +               while (--j)
> +                       pages[i + j] = pages[i] + j;
> +
> +               __dma_clear_buffer(pages[i], PAGE_SIZE << order);
> +               i += 1 << order;
> +               count -= 1 << order;
> +       }
> +
> +       return pages;
> +error:
> +       while (--i)
> +               if (pages[i])
> +                       __free_pages(pages[i], 0);
> +       if (array_size < PAGE_SIZE)
> +               kfree(pages);
> +       else
> +               vfree(pages);
> +       return NULL;
> +}
> +
> +static int __iommu_free_buffer(struct device *dev, struct page **pages,
> size_t size)
> +{
> +       int count = size >> PAGE_SHIFT;
> +       int array_size = count * sizeof(struct page *);
> +       int i;
> +       for (i = 0; i < count; i++)
> +               if (pages[i])
> +                       __free_pages(pages[i], 0);
> +       if (array_size < PAGE_SIZE)
> +               kfree(pages);
> +       else
> +               vfree(pages);
> +       return 0;
> +}
> +
> +/*
> + * Create a CPU mapping for a specified pages
> + */
> +static void *
> +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t
> prot)
> +{
> +       struct arm_vmregion *c;
> +       size_t align;
> +       size_t count = size >> PAGE_SHIFT;
> +       int bit;
> +
> +       if (!consistent_pte[0]) {
> +               pr_err("%s: not initialised\n", __func__);
> +               dump_stack();
> +               return NULL;
> +       }
> +
> +       /*
> +        * Align the virtual region allocation - maximum alignment is
> +        * a section size, minimum is a page size.  This helps reduce
> +        * fragmentation of the DMA space, and also prevents allocations
> +        * smaller than a section from crossing a section boundary.
> +        */
> +       bit = fls(size - 1);
> +       if (bit > SECTION_SHIFT)
> +               bit = SECTION_SHIFT;
> +       align = 1 << bit;
> +
> +       /*
> +        * Allocate a virtual address in the consistent mapping region.
> +        */
> +       c = arm_vmregion_alloc(&consistent_head, align, size,
> +                           gfp & ~(__GFP_DMA | __GFP_HIGHMEM), NULL);
> +       if (c) {
> +               pte_t *pte;
> +               int idx = CONSISTENT_PTE_INDEX(c->vm_start);
> +               int i = 0;
> +               u32 off = CONSISTENT_OFFSET(c->vm_start) &
> (PTRS_PER_PTE-1);
> +
> +               pte = consistent_pte[idx] + off;
> +               c->priv = pages;
> +
> +               do {
> +                       BUG_ON(!pte_none(*pte));
> +
> +                       set_pte_ext(pte, mk_pte(pages[i], prot), 0);
> +                       pte++;
> +                       off++;
> +                       i++;
> +                       if (off >= PTRS_PER_PTE) {
> +                               off = 0;
> +                               pte = consistent_pte[++idx];
> +                       }
> +               } while (i < count);
> +
> +               dsb();
> +
> +               return (void *)c->vm_start;
> +       }
> +       return NULL;
> +}
> +
> +/*
> + * Create a mapping in device IO address space for specified pages
> + */
> +static dma_addr_t
> +__iommu_create_mapping(struct device *dev, struct page **pages, size_t
> size)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> +       dma_addr_t dma_addr, iova;
> +       int i, ret = DMA_ERROR_CODE;
> +
> +       dma_addr = __alloc_iova(mapping, size);
> +       if (dma_addr == DMA_ERROR_CODE)
> +               return dma_addr;
> +
> +       iova = dma_addr;
> +       for (i = 0; i < count; ) {
> +               unsigned int next_pfn = page_to_pfn(pages[i]) + 1;
> +               phys_addr_t phys = page_to_phys(pages[i]);
> +               unsigned int len, j;
> +
> +               for (j = i + 1; j < count; j++, next_pfn++)
> +                       if (page_to_pfn(pages[j]) != next_pfn)
> +                               break;
> +
> +               len = (j - i) << PAGE_SHIFT;
> +               ret = iommu_map(mapping->domain, iova, phys, len, 0);
> +               if (ret < 0)
> +                       goto fail;
> +               iova += len;
> +               i = j;
> +       }
> +       return dma_addr;
> +fail:
> +       iommu_unmap(mapping->domain, dma_addr, iova-dma_addr);
> +       __free_iova(mapping, dma_addr, size);
> +       return DMA_ERROR_CODE;
> +}
> +
> +static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova,
> size_t size)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +
> +       /*
> +        * add optional in-page offset from iova to size and align
> +        * result to page size
> +        */
> +       size = PAGE_ALIGN((iova & ~PAGE_MASK) + size);
> +       iova &= PAGE_MASK;
> +
> +       iommu_unmap(mapping->domain, iova, size);
> +       __free_iova(mapping, iova, size);
> +       return 0;
> +}
> +
> +static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
> +           dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
> +{
> +       pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
> +       struct page **pages;
> +       void *addr = NULL;
> +
> +       *handle = DMA_ERROR_CODE;
> +       size = PAGE_ALIGN(size);
> +
> +       pages = __iommu_alloc_buffer(dev, size, gfp);
> +       if (!pages)
> +               return NULL;
> +
> +       *handle = __iommu_create_mapping(dev, pages, size);
> +       if (*handle == DMA_ERROR_CODE)
> +               goto err_buffer;
> +
> +       addr = __iommu_alloc_remap(pages, size, gfp, prot);
> +       if (!addr)
> +               goto err_mapping;
> +
> +       return addr;
> +
> +err_mapping:
> +       __iommu_remove_mapping(dev, *handle, size);
> +err_buffer:
> +       __iommu_free_buffer(dev, pages, size);
> +       return NULL;
> +}
> +
> +static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct
> *vma,
> +                   void *cpu_addr, dma_addr_t dma_addr, size_t size,
> +                   struct dma_attrs *attrs)
> +{
> +       struct arm_vmregion *c;
> +
> +       vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
> +       c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
> +
> +       if (c) {
> +               struct page **pages = c->priv;
> +
> +               unsigned long uaddr = vma->vm_start;
> +               unsigned long usize = vma->vm_end - vma->vm_start;
> +               int i = 0;
> +
> +               do {
> +                       int ret;
> +
> +                       ret = vm_insert_page(vma, uaddr, pages[i++]);
> +                       if (ret) {
> +                               pr_err("Remapping memory, error: %d\n",
> ret);
> +                               return ret;
> +                       }
> +
> +                       uaddr += PAGE_SIZE;
> +                       usize -= PAGE_SIZE;
> +               } while (usize > 0);
> +       }
> +       return 0;
> +}
> +
> +/*
> + * free a page as defined by the above mapping.
> + * Must not be called with IRQs disabled.
> + */
> +void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
> +                         dma_addr_t handle, struct dma_attrs *attrs)
> +{
> +       struct arm_vmregion *c;
> +       size = PAGE_ALIGN(size);
> +
> +       c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
> +       if (c) {
> +               struct page **pages = c->priv;
> +               __dma_free_remap(cpu_addr, size);
> +               __iommu_remove_mapping(dev, handle, size);
> +               __iommu_free_buffer(dev, pages, size);
> +       }
> +}
> +
> +/*
> + * Map a part of the scatter-gather list into contiguous io address space
> + */
> +static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
> +                         size_t size, dma_addr_t *handle,
> +                         enum dma_data_direction dir)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       dma_addr_t iova, iova_base;
> +       int ret = 0;
> +       unsigned int count;
> +       struct scatterlist *s;
> +
> +       size = PAGE_ALIGN(size);
> +       *handle = DMA_ERROR_CODE;
> +
> +       iova_base = iova = __alloc_iova(mapping, size);
> +       if (iova == DMA_ERROR_CODE)
> +               return -ENOMEM;
> +
> +       for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s =
> sg_next(s)) {
> +               phys_addr_t phys = page_to_phys(sg_page(s));
> +               unsigned int len = PAGE_ALIGN(s->offset + s->length);
> +
> +               if (!arch_is_coherent())
> +                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
> s->length, dir);
> +
> +               ret = iommu_map(mapping->domain, iova, phys, len, 0);
> +               if (ret < 0)
> +                       goto fail;
> +               count += len >> PAGE_SHIFT;
> +               iova += len;
> +       }
> +       *handle = iova_base;
> +
> +       return 0;
> +fail:
> +       iommu_unmap(mapping->domain, iova_base, count * PAGE_SIZE);
> +       __free_iova(mapping, iova_base, size);
> +       return ret;
> +}
> +
> +/**
> + * arm_iommu_map_sg - map a set of SG buffers for streaming mode DMA
> + * @dev: valid struct device pointer
> + * @sg: list of buffers
> + * @nents: number of buffers to map
> + * @dir: DMA transfer direction
> + *
> + * Map a set of buffers described by scatterlist in streaming mode for
> DMA.
> + * The scatter gather list elements are merged together (if possible) and
> + * tagged with the appropriate dma address and length. They are obtained
> via
> + * sg_dma_{address,length}.
> + */
> +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int
> nents,
> +                    enum dma_data_direction dir, struct dma_attrs *attrs)
> +{
> +       struct scatterlist *s = sg, *dma = sg, *start = sg;
> +       int i, count = 0;
> +       unsigned int offset = s->offset;
> +       unsigned int size = s->offset + s->length;
> +       unsigned int max = dma_get_max_seg_size(dev);
> +
> +       for (i = 1; i < nents; i++) {
> +               s = sg_next(s);
> +
> +               s->dma_address = DMA_ERROR_CODE;
> +               s->dma_length = 0;
> +
> +               if (s->offset || (size & ~PAGE_MASK) || size + s->length >
> max) {
> +                       if (__map_sg_chunk(dev, start, size,
> &dma->dma_address,
> +                           dir) < 0)
> +                               goto bad_mapping;
> +
> +                       dma->dma_address += offset;
> +                       dma->dma_length = size - offset;
> +
> +                       size = offset = s->offset;
> +                       start = s;
> +                       dma = sg_next(dma);
> +                       count += 1;
> +               }
> +               size += s->length;
> +       }
> +       if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) < 0)
> +               goto bad_mapping;
> +
> +       dma->dma_address += offset;
> +       dma->dma_length = size - offset;
> +
> +       return count+1;
> +
> +bad_mapping:
> +       for_each_sg(sg, s, count, i)
> +               __iommu_remove_mapping(dev, sg_dma_address(s),
> sg_dma_len(s));
> +       return 0;
> +}
> +
> +/**
> + * arm_iommu_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
> + * @dev: valid struct device pointer
> + * @sg: list of buffers
> + * @nents: number of buffers to unmap (same as was passed to dma_map_sg)
> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> + *
> + * Unmap a set of streaming mode DMA translations.  Again, CPU access
> + * rules concerning calls here are the same as for dma_unmap_single().
> + */
> +void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *sg, int
> nents,
> +                       enum dma_data_direction dir, struct dma_attrs
> *attrs)
> +{
> +       struct scatterlist *s;
> +       int i;
> +
> +       for_each_sg(sg, s, nents, i) {
> +               if (sg_dma_len(s))
> +                       __iommu_remove_mapping(dev, sg_dma_address(s),
> +                                              sg_dma_len(s));
> +               if (!arch_is_coherent())
> +                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
> +                                             s->length, dir);
> +       }
> +}
> +
> +/**
> + * arm_iommu_sync_sg_for_cpu
> + * @dev: valid struct device pointer
> + * @sg: list of buffers
> + * @nents: number of buffers to map (returned from dma_map_sg)
> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> + */
> +void arm_iommu_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
> +                       int nents, enum dma_data_direction dir)
> +{
> +       struct scatterlist *s;
> +       int i;
> +
> +       for_each_sg(sg, s, nents, i)
> +               if (!arch_is_coherent())
> +                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
> s->length, dir);
> +
> +}
> +
> +/**
> + * arm_iommu_sync_sg_for_device
> + * @dev: valid struct device pointer
> + * @sg: list of buffers
> + * @nents: number of buffers to map (returned from dma_map_sg)
> + * @dir: DMA transfer direction (same as was passed to dma_map_sg)
> + */
> +void arm_iommu_sync_sg_for_device(struct device *dev, struct scatterlist
> *sg,
> +                       int nents, enum dma_data_direction dir)
> +{
> +       struct scatterlist *s;
> +       int i;
> +
> +       for_each_sg(sg, s, nents, i)
> +               if (!arch_is_coherent())
> +                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
> s->length, dir);
> +}
> +
> +
> +/**
> + * arm_iommu_map_page
> + * @dev: valid struct device pointer
> + * @page: page that buffer resides in
> + * @offset: offset into page for start of buffer
> + * @size: size of buffer to map
> + * @dir: DMA transfer direction
> + *
> + * IOMMU aware version of arm_dma_map_page()
> + */
> +static dma_addr_t arm_iommu_map_page(struct device *dev, struct page
> *page,
> +            unsigned long offset, size_t size, enum dma_data_direction
> dir,
> +            struct dma_attrs *attrs)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       dma_addr_t dma_addr;
> +       int ret, len = PAGE_ALIGN(size + offset);
> +
> +       if (!arch_is_coherent())
> +               __dma_page_cpu_to_dev(page, offset, size, dir);
> +
> +       dma_addr = __alloc_iova(mapping, len);
> +       if (dma_addr == DMA_ERROR_CODE)
> +               return dma_addr;
> +
> +       ret = iommu_map(mapping->domain, dma_addr, page_to_phys(page),
> len, 0);
> +       if (ret < 0)
> +               goto fail;
> +
> +       return dma_addr + offset;
> +fail:
> +       __free_iova(mapping, dma_addr, len);
> +       return DMA_ERROR_CODE;
> +}
> +
> +/**
> + * arm_iommu_unmap_page
> + * @dev: valid struct device pointer
> + * @handle: DMA address of buffer
> + * @size: size of buffer (same as passed to dma_map_page)
> + * @dir: DMA transfer direction (same as passed to dma_map_page)
> + *
> + * IOMMU aware version of arm_dma_unmap_page()
> + */
> +static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
> +               size_t size, enum dma_data_direction dir,
> +               struct dma_attrs *attrs)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       dma_addr_t iova = handle & PAGE_MASK;
> +       struct page *page =
> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> +       int offset = handle & ~PAGE_MASK;
> +       int len = PAGE_ALIGN(size + offset);
> +
> +       if (!iova)
> +               return;
> +
> +       if (!arch_is_coherent())
> +               __dma_page_dev_to_cpu(page, offset, size, dir);
> +
> +       iommu_unmap(mapping->domain, iova, len);
> +       __free_iova(mapping, iova, len);
> +}
> +
> +static void arm_iommu_sync_single_for_cpu(struct device *dev,
> +               dma_addr_t handle, size_t size, enum dma_data_direction
> dir)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       dma_addr_t iova = handle & PAGE_MASK;
> +       struct page *page =
> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> +       unsigned int offset = handle & ~PAGE_MASK;
> +
> +       if (!iova)
> +               return;
> +
> +       if (!arch_is_coherent())
> +               __dma_page_dev_to_cpu(page, offset, size, dir);
> +}
> +
> +static void arm_iommu_sync_single_for_device(struct device *dev,
> +               dma_addr_t handle, size_t size, enum dma_data_direction
> dir)
> +{
> +       struct dma_iommu_mapping *mapping = dev->archdata.mapping;
> +       dma_addr_t iova = handle & PAGE_MASK;
> +       struct page *page =
> phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
> +       unsigned int offset = handle & ~PAGE_MASK;
> +
> +       if (!iova)
> +               return;
> +
> +       __dma_page_cpu_to_dev(page, offset, size, dir);
> +}
> +
> +struct dma_map_ops iommu_ops = {
> +       .alloc          = arm_iommu_alloc_attrs,
> +       .free           = arm_iommu_free_attrs,
> +       .mmap           = arm_iommu_mmap_attrs,
> +
> +       .map_page               = arm_iommu_map_page,
> +       .unmap_page             = arm_iommu_unmap_page,
> +       .sync_single_for_cpu    = arm_iommu_sync_single_for_cpu,
> +       .sync_single_for_device = arm_iommu_sync_single_for_device,
> +
> +       .map_sg                 = arm_iommu_map_sg,
> +       .unmap_sg               = arm_iommu_unmap_sg,
> +       .sync_sg_for_cpu        = arm_iommu_sync_sg_for_cpu,
> +       .sync_sg_for_device     = arm_iommu_sync_sg_for_device,
> +};
> +
> +/**
> + * arm_iommu_create_mapping
> + * @bus: pointer to the bus holding the client device (for IOMMU calls)
> + * @base: start address of the valid IO address space
> + * @size: size of the valid IO address space
> + * @order: accuracy of the IO addresses allocations
> + *
> + * Creates a mapping structure which holds information about used/unused
> + * IO address ranges, which is required to perform memory allocation and
> + * mapping with IOMMU aware functions.
> + *
> + * The client device need to be attached to the mapping with
> + * arm_iommu_attach_device function.
> + */
> +struct dma_iommu_mapping *
> +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t
> size,
> +                        int order)
> +{
> +       unsigned int count = size >> (PAGE_SHIFT + order);
> +       unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> +       struct dma_iommu_mapping *mapping;
> +       int err = -ENOMEM;
> +
> +       if (!count)
> +               return ERR_PTR(-EINVAL);
> +
> +       mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
> +       if (!mapping)
> +               goto err;
> +
> +       mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> +       if (!mapping->bitmap)
> +               goto err2;
> +
> +       mapping->base = base;
> +       mapping->bits = BITS_PER_BYTE * bitmap_size;
> +       mapping->order = order;
> +       spin_lock_init(&mapping->lock);
> +
> +       mapping->domain = iommu_domain_alloc(bus);
> +       if (!mapping->domain)
> +               goto err3;
> +
> +       kref_init(&mapping->kref);
> +       return mapping;
> +err3:
> +       kfree(mapping->bitmap);
> +err2:
> +       kfree(mapping);
> +err:
> +       return ERR_PTR(err);
> +}
> +
> +static void release_iommu_mapping(struct kref *kref)
> +{
> +       struct dma_iommu_mapping *mapping =
> +               container_of(kref, struct dma_iommu_mapping, kref);
> +
> +       iommu_domain_free(mapping->domain);
> +       kfree(mapping->bitmap);
> +       kfree(mapping);
> +}
> +
> +void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
> +{
> +       if (mapping)
> +               kref_put(&mapping->kref, release_iommu_mapping);
> +}
> +
> +/**
> + * arm_iommu_attach_device
> + * @dev: valid struct device pointer
> + * @mapping: io address space mapping structure (returned from
> + *     arm_iommu_create_mapping)
> + *
> + * Attaches specified io address space mapping to the provided device,
> + * this replaces the dma operations (dma_map_ops pointer) with the
> + * IOMMU aware version. More than one client might be attached to
> + * the same io address space mapping.
> + */
> +int arm_iommu_attach_device(struct device *dev,
> +                           struct dma_iommu_mapping *mapping)
> +{
> +       int err;
> +
> +       err = iommu_attach_device(mapping->domain, dev);
> +       if (err)
> +               return err;
> +
> +       kref_get(&mapping->kref);
> +       dev->archdata.mapping = mapping;
> +       set_dma_ops(dev, &iommu_ops);
> +
> +       pr_info("Attached IOMMU controller to %s device.\n",
> dev_name(dev));
> +       return 0;
> +}
> +
> +#endif
> diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h
> index 162be66..bf312c3 100644
> --- a/arch/arm/mm/vmregion.h
> +++ b/arch/arm/mm/vmregion.h
> @@ -17,7 +17,7 @@ struct arm_vmregion {
>        struct list_head        vm_list;
>        unsigned long           vm_start;
>        unsigned long           vm_end;
> -       struct page             *vm_pages;
> +       void                    *priv;
>        int                     vm_active;
>        const void              *caller;
>  };
> --
> 1.7.1.569.g6f426
>
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig
>

--0016e6d58a1a74164f04be126cd0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div>Hi Marek,<br></div><div><br>dma_addr_t dma_addr is an unused argument =
passed to the function <span class=3D"il">arm_iommu_mmap_attrs</span><br><b=
r>+static int <span class=3D"il">arm_iommu_mmap_attrs</span>(struct device =
*dev, struct vm_area_struct *vma,<br>

+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *cpu_addr, dma_addr_t dma_addr, =
size_t size,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct arm_vmregion *c;<br>
+<br>
+ =A0 =A0 =A0 vma-&gt;vm_page_prot =3D __get_dma_pgprot(attrs, vma-&gt;vm_p=
age_prot);<br>
+ =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_<div id=3D":50">head,=
 (unsigned long)cpu_addr);<br>
+<br>
+ =A0 =A0 =A0 if (c) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long uaddr =3D vma-&gt;vm_start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long usize =3D vma-&gt;vm_end - vma-=
&gt;vm_start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vm_insert_page(vma, u=
addr, pages[i++]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&quot;=
Remapping memory, error: %d\n&quot;, ret);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uaddr +=3D PAGE_SIZE;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usize -=3D PAGE_SIZE;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (usize &gt; 0);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return 0;<br>
+}</div><br><br></div><div class=3D"gmail_quote">On Wed, Apr 18, 2012 at 10=
:44 PM, Marek Szyprowski <span dir=3D"ltr">&lt;<a href=3D"mailto:m.szyprows=
ki@samsung.com" target=3D"_blank">m.szyprowski@samsung.com</a>&gt;</span> w=
rote:<br>

<blockquote style=3D"margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-=
color:rgb(204,204,204);border-left-width:1px;border-left-style:solid" class=
=3D"gmail_quote">This patch add a complete implementation of DMA-mapping AP=
I for<br>


devices which have IOMMU support.<br>
<br>
This implementation tries to optimize dma address space usage by remapping<=
br>
all possible physical memory chunks into a single dma address space chunk.<=
br>
<br>
DMA address space is managed on top of the bitmap stored in the<br>
dma_iommu_mapping structure stored in device-&gt;archdata. Platform setup<b=
r>
code has to initialize parameters of the dma address space (base address,<b=
r>
size, allocation precision order) with arm_iommu_create_mapping() function.=
<br>
To reduce the size of the bitmap, all allocations are aligned to the<br>
specified order of base 4 KiB pages.<br>
<br>
dma_alloc_* functions allocate physical memory in chunks, each with<br>
alloc_pages() function to avoid failing if the physical memory gets<br>
fragmented. In worst case the allocated buffer is composed of 4 KiB page<br=
>
chunks.<br>
<br>
dma_map_sg() function minimizes the total number of dma address space<br>
chunks by merging of physical memory chunks into one larger dma address<br>
space chunk. If requested chunk (scatter list entry) boundaries<br>
match physical page boundaries, most calls to dma_map_sg() requests will<br=
>
result in creating only one chunk in dma address space.<br>
<br>
dma_map_page() simply creates a mapping for the given page(s) in the dma<br=
>
address space.<br>
<br>
All dma functions also perform required cache operation like their<br>
counterparts from the arm linear physical memory mapping version.<br>
<br>
This patch contains code and fixes kindly provided by:<br>
- Krishna Reddy &lt;<a href=3D"mailto:vdumpa@nvidia.com" target=3D"_blank">=
vdumpa@nvidia.com</a>&gt;,<br>
- Andrzej Pietrasiewicz &lt;<a href=3D"mailto:andrzej.p@samsung.com" target=
=3D"_blank">andrzej.p@samsung.com</a>&gt;,<br>
- Hiroshi DOYU &lt;<a href=3D"mailto:hdoyu@nvidia.com" target=3D"_blank">hd=
oyu@nvidia.com</a>&gt;<br>
<br>
Signed-off-by: Marek Szyprowski &lt;<a href=3D"mailto:m.szyprowski@samsung.=
com" target=3D"_blank">m.szyprowski@samsung.com</a>&gt;<br>
Acked-by: Kyungmin Park &lt;<a href=3D"mailto:kyungmin.park@samsung.com" ta=
rget=3D"_blank">kyungmin.park@samsung.com</a>&gt;<br>
Reviewed-by: Konrad Rzeszutek Wilk &lt;<a href=3D"mailto:konrad.wilk@oracle=
.com" target=3D"_blank">konrad.wilk@oracle.com</a>&gt;<br>
Tested-By: Subash Patel &lt;<a href=3D"mailto:subash.ramaswamy@linaro.org" =
target=3D"_blank">subash.ramaswamy@linaro.org</a>&gt;<br>
---<br>
=A0arch/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +<br>
=A0arch/arm/include/asm/device.h =A0 =A0| =A0 =A03 +<br>
=A0arch/arm/include/asm/dma-iommu.h | =A0 34 ++<br>
=A0arch/arm/mm/dma-mapping.c =A0 =A0 =A0 =A0| =A0727 ++++++++++++++++++++++=
+++++++++++++++-<br>
=A0arch/arm/mm/vmregion.h =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
=A05 files changed, 759 insertions(+), 15 deletions(-)<br>
=A0create mode 100644 arch/arm/include/asm/dma-iommu.h<br>
<br>
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig<br>
index 0fd27d4..874e519 100644<br>
--- a/arch/arm/Kconfig<br>
+++ b/arch/arm/Kconfig<br>
@@ -46,6 +46,14 @@ config ARM<br>
=A0config ARM_HAS_SG_CHAIN<br>
 =A0 =A0 =A0 =A0bool<br>
<br>
+config NEED_SG_DMA_LENGTH<br>
+ =A0 =A0 =A0 bool<br>
+<br>
+config ARM_DMA_USE_IOMMU<br>
+ =A0 =A0 =A0 select NEED_SG_DMA_LENGTH<br>
+ =A0 =A0 =A0 select ARM_HAS_SG_CHAIN<br>
+ =A0 =A0 =A0 bool<br>
+<br>
=A0config HAVE_PWM<br>
 =A0 =A0 =A0 =A0bool<br>
<br>
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h<=
br>
index 6e2cb0e..b69c0d3 100644<br>
--- a/arch/arm/include/asm/device.h<br>
+++ b/arch/arm/include/asm/device.h<br>
@@ -14,6 +14,9 @@ struct dev_archdata {<br>
=A0#ifdef CONFIG_IOMMU_API<br>
 =A0 =A0 =A0 =A0void *iommu; /* private IOMMU data */<br>
=A0#endif<br>
+#ifdef CONFIG_ARM_DMA_USE_IOMMU<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping =A0 =A0 =A0 =A0*mapping;<br>
+#endif<br>
=A0};<br>
<br>
=A0struct omap_device;<br>
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-io=
mmu.h<br>
new file mode 100644<br>
index 0000000..799b094<br>
--- /dev/null<br>
+++ b/arch/arm/include/asm/dma-iommu.h<br>
@@ -0,0 +1,34 @@<br>
+#ifndef ASMARM_DMA_IOMMU_H<br>
+#define ASMARM_DMA_IOMMU_H<br>
+<br>
+#ifdef __KERNEL__<br>
+<br>
+#include &lt;linux/mm_types.h&gt;<br>
+#include &lt;linux/scatterlist.h&gt;<br>
+#include &lt;linux/dma-debug.h&gt;<br>
+#include &lt;linux/kmemcheck.h&gt;<br>
+<br>
+struct dma_iommu_mapping {<br>
+ =A0 =A0 =A0 /* iommu specific data */<br>
+ =A0 =A0 =A0 struct iommu_domain =A0 =A0 *domain;<br>
+<br>
+ =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*bitmap;<br>
+ =A0 =A0 =A0 size_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bits;<br>
+ =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0order;<br>
+ =A0 =A0 =A0 dma_addr_t =A0 =A0 =A0 =A0 =A0 =A0 =A0base;<br>
+<br>
+ =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock;<br>
+ =A0 =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 kref;<br>
+};<br>
+<br>
+struct dma_iommu_mapping *<br>
+arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t siz=
e,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order);<br>
+<br>
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);<br>
+<br>
+int arm_iommu_attach_device(struct device *dev,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct dma_iommu_mapping *mapping);<br>
+<br>
+#endif /* __KERNEL__ */<br>
+#endif<br>
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c<br>
index d4aad65..2d11aa0 100644<br>
--- a/arch/arm/mm/dma-mapping.c<br>
+++ b/arch/arm/mm/dma-mapping.c<br>
@@ -19,6 +19,8 @@<br>
=A0#include &lt;linux/dma-mapping.h&gt;<br>
=A0#include &lt;linux/highmem.h&gt;<br>
=A0#include &lt;linux/slab.h&gt;<br>
+#include &lt;linux/iommu.h&gt;<br>
+#include &lt;linux/vmalloc.h&gt;<br>
<br>
=A0#include &lt;asm/memory.h&gt;<br>
=A0#include &lt;asm/highmem.h&gt;<br>
@@ -26,6 +28,7 @@<br>
=A0#include &lt;asm/tlbflush.h&gt;<br>
=A0#include &lt;asm/sizes.h&gt;<br>
=A0#include &lt;asm/mach/arch.h&gt;<br>
+#include &lt;asm/dma-iommu.h&gt;<br>
<br>
=A0#include &quot;mm.h&quot;<br>
<br>
@@ -155,6 +158,21 @@ static u64 get_coherent_dma_mask(struct device *dev)<b=
r>
 =A0 =A0 =A0 =A0return mask;<br>
=A0}<br>
<br>
+static void __dma_clear_buffer(struct page *page, size_t size)<br>
+{<br>
+ =A0 =A0 =A0 void *ptr;<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Ensure that the allocated pages are zeroed, and that any=
 data<br>
+ =A0 =A0 =A0 =A0* lurking in the kernel direct-mapped region is invalidate=
d.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 ptr =3D page_address(page);<br>
+ =A0 =A0 =A0 if (ptr) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(ptr, 0, size);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dmac_flush_range(ptr, ptr + size);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 outer_flush_range(__pa(ptr), __pa(ptr) + size=
);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Allocate a DMA buffer for &#39;dev&#39; of size &#39;size&#39; using =
the<br>
 =A0* specified gfp mask. =A0Note that &#39;size&#39; must be page aligned.=
<br>
@@ -163,7 +181,6 @@ static struct page *__dma_alloc_buffer(struct device *d=
ev, size_t size, gfp_t gf<br>
=A0{<br>
 =A0 =A0 =A0 =A0unsigned long order =3D get_order(size);<br>
 =A0 =A0 =A0 =A0struct page *page, *p, *e;<br>
- =A0 =A0 =A0 void *ptr;<br>
 =A0 =A0 =A0 =A0u64 mask =3D get_coherent_dma_mask(dev);<br>
<br>
=A0#ifdef CONFIG_DMA_API_DEBUG<br>
@@ -192,14 +209,7 @@ static struct page *__dma_alloc_buffer(struct device *=
dev, size_t size, gfp_t gf<br>
 =A0 =A0 =A0 =A0for (p =3D page + (size &gt;&gt; PAGE_SHIFT), e =3D page + =
(1 &lt;&lt; order); p &lt; e; p++)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__free_page(p);<br>
<br>
- =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0* Ensure that the allocated pages are zeroed, and that any=
 data<br>
- =A0 =A0 =A0 =A0* lurking in the kernel direct-mapped region is invalidate=
d.<br>
- =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 ptr =3D page_address(page);<br>
- =A0 =A0 =A0 memset(ptr, 0, size);<br>
- =A0 =A0 =A0 dmac_flush_range(ptr, ptr + size);<br>
- =A0 =A0 =A0 outer_flush_range(__pa(ptr), __pa(ptr) + size);<br>
+ =A0 =A0 =A0 __dma_clear_buffer(page, size);<br>
<br>
 =A0 =A0 =A0 =A0return page;<br>
=A0}<br>
@@ -348,7 +358,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t=
 gfp, pgprot_t prot,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 off =3D CONSISTENT_OFFSET(c-&gt;vm_star=
t) &amp; (PTRS_PER_PTE-1);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pte =3D consistent_pte[idx] + off;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;vm_pages =3D page;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;priv =3D page;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!pte_none(*pte));<br=
>
@@ -461,6 +471,14 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_=
t *handle, gfp_t gfp,<br>
 =A0 =A0 =A0 =A0return addr;<br>
=A0}<br>
<br>
+static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t =
prot)<br>
+{<br>
+ =A0 =A0 =A0 prot =3D dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_writecombine(p=
rot) :<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_dmacoherent(pr=
ot);<br>
+ =A0 =A0 =A0 return prot;<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Allocate DMA-coherent memory space and return both the kernel remappe=
d<br>
 =A0* virtual and bus address for that space.<br>
@@ -468,9 +486,7 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t=
 *handle, gfp_t gfp,<br>
=A0void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,=
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp, struct dma_attrs *attrs)=
<br>
=A0{<br>
- =A0 =A0 =A0 pgprot_t prot =3D dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs)=
 ?<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_writecombine(pgprot_ke=
rnel) :<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgprot_dmacoherent(pgprot_ker=
nel);<br>
+ =A0 =A0 =A0 pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_kernel);<br>
 =A0 =A0 =A0 =A0void *memory;<br>
<br>
 =A0 =A0 =A0 =A0if (dma_alloc_from_coherent(dev, size, handle, &amp;memory)=
)<br>
@@ -497,16 +513,20 @@ int arm_dma_mmap(struct device *dev, struct vm_area_s=
truct *vma,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgprot_writecombine=
(vma-&gt;vm_page_prot) :<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgprot_dmacoherent(=
vma-&gt;vm_page_prot);<br>
<br>
+ =A0 =A0 =A0 if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &amp;ret=
))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
+<br>
 =A0 =A0 =A0 =A0c =3D arm_vmregion_find(&amp;consistent_head, (unsigned lon=
g)cpu_addr);<br>
 =A0 =A0 =A0 =A0if (c) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long off =3D vma-&gt;vm_pgoff;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *pages =3D c-&gt;priv;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kern_size =3D (c-&gt;vm_end - c-&gt;vm_star=
t) &gt;&gt; PAGE_SHIFT;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (off &lt; kern_size &amp;&amp;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0user_size &lt;=3D (kern_size - off)=
) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D remap_pfn_range(vma=
, vma-&gt;vm_start,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 page_to_pfn(c-&gt;vm_pages) + off,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 page_to_pfn(pages) + off,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0user_size &lt;&lt; PAGE_SHIFT,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0vma-&gt;vm_page_prot);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
@@ -645,6 +665,9 @@ int arm_dma_map_sg(struct device *dev, struct scatterli=
st *sg, int nents,<br>
 =A0 =A0 =A0 =A0int i, j;<br>
<br>
 =A0 =A0 =A0 =A0for_each_sg(sg, s, nents, i) {<br>
+#ifdef CONFIG_NEED_SG_DMA_LENGTH<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_length =3D s-&gt;length;<br>
+#endif<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s-&gt;dma_address =3D ops-&gt;map_page(dev,=
 sg_page(s), s-&gt;offset,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0s-&gt;length, dir, attrs);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (dma_mapping_error(dev, s-&gt;dma_addres=
s))<br>
@@ -753,3 +776,679 @@ static int __init dma_debug_do_init(void)<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
=A0fs_initcall(dma_debug_do_init);<br>
+<br>
+#ifdef CONFIG_ARM_DMA_USE_IOMMU<br>
+<br>
+/* IOMMU */<br>
+<br>
+static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s=
ize_t size)<br>
+{<br>
+ =A0 =A0 =A0 unsigned int order =3D get_order(size);<br>
+ =A0 =A0 =A0 unsigned int align =3D 0;<br>
+ =A0 =A0 =A0 unsigned int count, start;<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 count =3D ((PAGE_ALIGN(size) &gt;&gt; PAGE_SHIFT) +<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 &lt;&lt; mapping-&gt;order) - 1) &gt;&g=
t; mapping-&gt;order;<br>
+<br>
+ =A0 =A0 =A0 if (order &gt; mapping-&gt;order)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 align =3D (1 &lt;&lt; (order - mapping-&gt;or=
der)) - 1;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;mapping-&gt;lock, flags);<br>
+ =A0 =A0 =A0 start =3D bitmap_find_next_zero_area(mapping-&gt;bitmap, mapp=
ing-&gt;bits, 0,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0count, align);<br>
+ =A0 =A0 =A0 if (start &gt; mapping-&gt;bits) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-&gt;lock,=
 flags);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 bitmap_set(mapping-&gt;bitmap, start, count);<br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-&gt;lock, flags);<br>
+<br>
+ =A0 =A0 =A0 return mapping-&gt;base + (start &lt;&lt; (mapping-&gt;order =
+ PAGE_SHIFT));<br>
+}<br>
+<br>
+static inline void __free_iova(struct dma_iommu_mapping *mapping,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_addr_t add=
r, size_t size)<br>
+{<br>
+ =A0 =A0 =A0 unsigned int start =3D (addr - mapping-&gt;base) &gt;&gt;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(mapping-&gt;order=
 + PAGE_SHIFT);<br>
+ =A0 =A0 =A0 unsigned int count =3D ((size &gt;&gt; PAGE_SHIFT) +<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 &lt;&lt; mappi=
ng-&gt;order) - 1) &gt;&gt; mapping-&gt;order;<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;mapping-&gt;lock, flags);<br>
+ =A0 =A0 =A0 bitmap_clear(mapping-&gt;bitmap, start, count);<br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;mapping-&gt;lock, flags);<br>
+}<br>
+<br>
+static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,=
 gfp_t gfp)<br>
+{<br>
+ =A0 =A0 =A0 struct page **pages;<br>
+ =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br>
+ =A0 =A0 =A0 int i =3D 0;<br>
+<br>
+ =A0 =A0 =A0 if (array_size &lt;=3D PAGE_SIZE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D kzalloc(array_size, gfp);<br>
+ =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D vzalloc(array_size);<br>
+ =A0 =A0 =A0 if (!pages)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
+<br>
+ =A0 =A0 =A0 while (count) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int j, order =3D __ffs(count);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D alloc_pages(gfp | __GFP_NOWARN, =
order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (!pages[i] &amp;&amp; order)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D alloc_pages(gfp =
| __GFP_NOWARN, --order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pages[i])<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 split_page(pages[i], order);<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 j =3D 1 &lt;&lt; order;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (--j)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i + j] =3D pages[i] + j=
;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_clear_buffer(pages[i], PAGE_SIZE &lt;&l=
t; order);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 i +=3D 1 &lt;&lt; order;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 count -=3D 1 &lt;&lt; order;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 return pages;<br>
+error:<br>
+ =A0 =A0 =A0 while (--i)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages[i])<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages(pages[i], 0);<br=
>
+ =A0 =A0 =A0 if (array_size &lt; PAGE_SIZE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pages);<br>
+ =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(pages);<br>
+ =A0 =A0 =A0 return NULL;<br>
+}<br>
+<br>
+static int __iommu_free_buffer(struct device *dev, struct page **pages, si=
ze_t size)<br>
+{<br>
+ =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br>
+ =A0 =A0 =A0 int i;<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; count; i++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages[i])<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages(pages[i], 0);<br=
>
+ =A0 =A0 =A0 if (array_size &lt; PAGE_SIZE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pages);<br>
+ =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(pages);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+/*<br>
+ * Create a CPU mapping for a specified pages<br>
+ */<br>
+static void *<br>
+__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t =
prot)<br>
+{<br>
+ =A0 =A0 =A0 struct arm_vmregion *c;<br>
+ =A0 =A0 =A0 size_t align;<br>
+ =A0 =A0 =A0 size_t count =3D size &gt;&gt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 int bit;<br>
+<br>
+ =A0 =A0 =A0 if (!consistent_pte[0]) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&quot;%s: not initialised\n&quot;, __f=
unc__);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_stack();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Align the virtual region allocation - maximum alignment =
is<br>
+ =A0 =A0 =A0 =A0* a section size, minimum is a page size. =A0This helps re=
duce<br>
+ =A0 =A0 =A0 =A0* fragmentation of the DMA space, and also prevents alloca=
tions<br>
+ =A0 =A0 =A0 =A0* smaller than a section from crossing a section boundary.=
<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 bit =3D fls(size - 1);<br>
+ =A0 =A0 =A0 if (bit &gt; SECTION_SHIFT)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 bit =3D SECTION_SHIFT;<br>
+ =A0 =A0 =A0 align =3D 1 &lt;&lt; bit;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Allocate a virtual address in the consistent mapping reg=
ion.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 c =3D arm_vmregion_alloc(&amp;consistent_head, align, size,<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp &amp; ~(__GFP_DMA=
 | __GFP_HIGHMEM), NULL);<br>
+ =A0 =A0 =A0 if (c) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte_t *pte;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int idx =3D CONSISTENT_PTE_INDEX(c-&gt;vm_sta=
rt);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 off =3D CONSISTENT_OFFSET(c-&gt;vm_start)=
 &amp; (PTRS_PER_PTE-1);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte =3D consistent_pte[idx] + off;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 c-&gt;priv =3D pages;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!pte_none(*pte));<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pte_ext(pte, mk_pte(pages=
[i], prot), 0);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte++;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 off++;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i++;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (off &gt;=3D PTRS_PER_PTE)=
 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =3D 0;<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte =3D consi=
stent_pte[++idx];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (i &lt; count);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dsb();<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (void *)c-&gt;vm_start;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return NULL;<br>
+}<br>
+<br>
+/*<br>
+ * Create a mapping in device IO address space for specified pages<br>
+ */<br>
+static dma_addr_t<br>
+__iommu_create_mapping(struct device *dev, struct page **pages, size_t siz=
e)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 unsigned int count =3D PAGE_ALIGN(size) &gt;&gt; PAGE_SHIFT;<=
br>
+ =A0 =A0 =A0 dma_addr_t dma_addr, iova;<br>
+ =A0 =A0 =A0 int i, ret =3D DMA_ERROR_CODE;<br>
+<br>
+ =A0 =A0 =A0 dma_addr =3D __alloc_iova(mapping, size);<br>
+ =A0 =A0 =A0 if (dma_addr =3D=3D DMA_ERROR_CODE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dma_addr;<br>
+<br>
+ =A0 =A0 =A0 iova =3D dma_addr;<br>
+ =A0 =A0 =A0 for (i =3D 0; i &lt; count; ) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int next_pfn =3D page_to_pfn(pages[i=
]) + 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t phys =3D page_to_phys(pages[i]);<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int len, j;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D i + 1; j &lt; count; j++, next_pfn=
++)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_to_pfn(pages[j]) !=
=3D next_pfn)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D (j - i) &lt;&lt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain, iova, p=
hys, len, 0);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 iova +=3D len;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D j;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return dma_addr;<br>
+fail:<br>
+ =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, dma_addr, iova-dma_addr);<br>
+ =A0 =A0 =A0 __free_iova(mapping, dma_addr, size);<br>
+ =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
+}<br>
+<br>
+static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, siz=
e_t size)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* add optional in-page offset from iova to size and align<=
br>
+ =A0 =A0 =A0 =A0* result to page size<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 size =3D PAGE_ALIGN((iova &amp; ~PAGE_MASK) + size);<br>
+ =A0 =A0 =A0 iova &amp;=3D PAGE_MASK;<br>
+<br>
+ =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova, size);<br>
+ =A0 =A0 =A0 __free_iova(mapping, iova, size);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,<br>
+ =A0 =A0 =A0 =A0 =A0 dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attr=
s)<br>
+{<br>
+ =A0 =A0 =A0 pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_kernel);<br>
+ =A0 =A0 =A0 struct page **pages;<br>
+ =A0 =A0 =A0 void *addr =3D NULL;<br>
+<br>
+ =A0 =A0 =A0 *handle =3D DMA_ERROR_CODE;<br>
+ =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
+<br>
+ =A0 =A0 =A0 pages =3D __iommu_alloc_buffer(dev, size, gfp);<br>
+ =A0 =A0 =A0 if (!pages)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
+<br>
+ =A0 =A0 =A0 *handle =3D __iommu_create_mapping(dev, pages, size);<br>
+ =A0 =A0 =A0 if (*handle =3D=3D DMA_ERROR_CODE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_buffer;<br>
+<br>
+ =A0 =A0 =A0 addr =3D __iommu_alloc_remap(pages, size, gfp, prot);<br>
+ =A0 =A0 =A0 if (!addr)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_mapping;<br>
+<br>
+ =A0 =A0 =A0 return addr;<br>
+<br>
+err_mapping:<br>
+ =A0 =A0 =A0 __iommu_remove_mapping(dev, *handle, size);<br>
+err_buffer:<br>
+ =A0 =A0 =A0 __iommu_free_buffer(dev, pages, size);<br>
+ =A0 =A0 =A0 return NULL;<br>
+}<br>
+<br>
+static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct =
*vma,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *cpu_addr, dma_addr_t dma_addr, =
size_t size,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct arm_vmregion *c;<br>
+<br>
+ =A0 =A0 =A0 vma-&gt;vm_page_prot =3D __get_dma_pgprot(attrs, vma-&gt;vm_p=
age_prot);<br>
+ =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_head, (unsigned long)=
cpu_addr);<br>
+<br>
+ =A0 =A0 =A0 if (c) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long uaddr =3D vma-&gt;vm_start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long usize =3D vma-&gt;vm_end - vma-=
&gt;vm_start;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i =3D 0;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vm_insert_page(vma, u=
addr, pages[i++]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&quot;=
Remapping memory, error: %d\n&quot;, ret);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uaddr +=3D PAGE_SIZE;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usize -=3D PAGE_SIZE;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (usize &gt; 0);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+/*<br>
+ * free a page as defined by the above mapping.<br>
+ * Must not be called with IRQs disabled.<br>
+ */<br>
+void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, struct=
 dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct arm_vmregion *c;<br>
+ =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
+<br>
+ =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_head, (unsigned long)=
cpu_addr);<br>
+ =A0 =A0 =A0 if (c) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_free_remap(cpu_addr, size);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, handle, size);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_free_buffer(dev, pages, size);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
+/*<br>
+ * Map a part of the scatter-gather list into contiguous io address space<=
br>
+ */<br>
+static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, dma_addr_t *=
handle,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum dma_data_direction d=
ir)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 dma_addr_t iova, iova_base;<br>
+ =A0 =A0 =A0 int ret =3D 0;<br>
+ =A0 =A0 =A0 unsigned int count;<br>
+ =A0 =A0 =A0 struct scatterlist *s;<br>
+<br>
+ =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br>
+ =A0 =A0 =A0 *handle =3D DMA_ERROR_CODE;<br>
+<br>
+ =A0 =A0 =A0 iova_base =3D iova =3D __alloc_iova(mapping, size);<br>
+ =A0 =A0 =A0 if (iova =3D=3D DMA_ERROR_CODE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
+<br>
+ =A0 =A0 =A0 for (count =3D 0, s =3D sg; count &lt; (size &gt;&gt; PAGE_SH=
IFT); s =3D sg_next(s)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t phys =3D page_to_phys(sg_page(s))=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int len =3D PAGE_ALIGN(s-&gt;offset =
+ s-&gt;length);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_dev(sg_page=
(s), s-&gt;offset, s-&gt;length, dir);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain, iova, p=
hys, len, 0);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D len &gt;&gt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 iova +=3D len;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 *handle =3D iova_base;<br>
+<br>
+ =A0 =A0 =A0 return 0;<br>
+fail:<br>
+ =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova_base, count * PAGE_SIZE)=
;<br>
+ =A0 =A0 =A0 __free_iova(mapping, iova_base, size);<br>
+ =A0 =A0 =A0 return ret;<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_map_sg - map a set of SG buffers for streaming mode DMA<br>
+ * @dev: valid struct device pointer<br>
+ * @sg: list of buffers<br>
+ * @nents: number of buffers to map<br>
+ * @dir: DMA transfer direction<br>
+ *<br>
+ * Map a set of buffers described by scatterlist in streaming mode for DMA=
.<br>
+ * The scatter gather list elements are merged together (if possible) and<=
br>
+ * tagged with the appropriate dma address and length. They are obtained v=
ia<br>
+ * sg_dma_{address,length}.<br>
+ */<br>
+int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents=
,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction dir, struc=
t dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct scatterlist *s =3D sg, *dma =3D sg, *start =3D sg;<br>
+ =A0 =A0 =A0 int i, count =3D 0;<br>
+ =A0 =A0 =A0 unsigned int offset =3D s-&gt;offset;<br>
+ =A0 =A0 =A0 unsigned int size =3D s-&gt;offset + s-&gt;length;<br>
+ =A0 =A0 =A0 unsigned int max =3D dma_get_max_seg_size(dev);<br>
+<br>
+ =A0 =A0 =A0 for (i =3D 1; i &lt; nents; i++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D sg_next(s);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_address =3D DMA_ERROR_CODE;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;dma_length =3D 0;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s-&gt;offset || (size &amp; ~PAGE_MASK) |=
| size + s-&gt;length &gt; max) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__map_sg_chunk(dev, start=
, size, &amp;dma-&gt;dma_address,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir) &lt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_mapp=
ing;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma-&gt;dma_address +=3D offs=
et;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma-&gt;dma_length =3D size -=
 offset;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D offset =3D s-&gt;off=
set;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D s;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma =3D sg_next(dma);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D s-&gt;length;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 if (__map_sg_chunk(dev, start, size, &amp;dma-&gt;dma_address=
, dir) &lt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_mapping;<br>
+<br>
+ =A0 =A0 =A0 dma-&gt;dma_address +=3D offset;<br>
+ =A0 =A0 =A0 dma-&gt;dma_length =3D size - offset;<br>
+<br>
+ =A0 =A0 =A0 return count+1;<br>
+<br>
+bad_mapping:<br>
+ =A0 =A0 =A0 for_each_sg(sg, s, count, i)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, sg_dma_address(s)=
, sg_dma_len(s));<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg<br>
+ * @dev: valid struct device pointer<br>
+ * @sg: list of buffers<br>
+ * @nents: number of buffers to unmap (same as was passed to dma_map_sg)<b=
r>
+ * @dir: DMA transfer direction (same as was passed to dma_map_sg)<br>
+ *<br>
+ * Unmap a set of streaming mode DMA translations. =A0Again, CPU access<br=
>
+ * rules concerning calls here are the same as for dma_unmap_single().<br>
+ */<br>
+void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *sg, int ne=
nts,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum dma_data_direction dir, =
struct dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct scatterlist *s;<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for_each_sg(sg, s, nents, i) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sg_dma_len(s))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, s=
g_dma_address(s),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0sg_dma_len(s));<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(sg_page=
(s), s-&gt;offset,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 s-&gt;length, dir);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_sync_sg_for_cpu<br>
+ * @dev: valid struct device pointer<br>
+ * @sg: list of buffers<br>
+ * @nents: number of buffers to map (returned from dma_map_sg)<br>
+ * @dir: DMA transfer direction (same as was passed to dma_map_sg)<br>
+ */<br>
+void arm_iommu_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nents, enum dma_data_dire=
ction dir)<br>
+{<br>
+ =A0 =A0 =A0 struct scatterlist *s;<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for_each_sg(sg, s, nents, i)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(sg_page=
(s), s-&gt;offset, s-&gt;length, dir);<br>
+<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_sync_sg_for_device<br>
+ * @dev: valid struct device pointer<br>
+ * @sg: list of buffers<br>
+ * @nents: number of buffers to map (returned from dma_map_sg)<br>
+ * @dir: DMA transfer direction (same as was passed to dma_map_sg)<br>
+ */<br>
+void arm_iommu_sync_sg_for_device(struct device *dev, struct scatterlist *=
sg,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nents, enum dma_data_dire=
ction dir)<br>
+{<br>
+ =A0 =A0 =A0 struct scatterlist *s;<br>
+ =A0 =A0 =A0 int i;<br>
+<br>
+ =A0 =A0 =A0 for_each_sg(sg, s, nents, i)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_dev(sg_page=
(s), s-&gt;offset, s-&gt;length, dir);<br>
+}<br>
+<br>
+<br>
+/**<br>
+ * arm_iommu_map_page<br>
+ * @dev: valid struct device pointer<br>
+ * @page: page that buffer resides in<br>
+ * @offset: offset into page for start of buffer<br>
+ * @size: size of buffer to map<br>
+ * @dir: DMA transfer direction<br>
+ *<br>
+ * IOMMU aware version of arm_dma_map_page()<br>
+ */<br>
+static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page=
,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0unsigned long offset, size_t size, enum dma_data_d=
irection dir,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0struct dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 dma_addr_t dma_addr;<br>
+ =A0 =A0 =A0 int ret, len =3D PAGE_ALIGN(size + offset);<br>
+<br>
+ =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_cpu_to_dev(page, offset, size, dir=
);<br>
+<br>
+ =A0 =A0 =A0 dma_addr =3D __alloc_iova(mapping, len);<br>
+ =A0 =A0 =A0 if (dma_addr =3D=3D DMA_ERROR_CODE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dma_addr;<br>
+<br>
+ =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain, dma_addr, page_to_phys(=
page), len, 0);<br>
+ =A0 =A0 =A0 if (ret &lt; 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
+<br>
+ =A0 =A0 =A0 return dma_addr + offset;<br>
+fail:<br>
+ =A0 =A0 =A0 __free_iova(mapping, dma_addr, len);<br>
+ =A0 =A0 =A0 return DMA_ERROR_CODE;<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_unmap_page<br>
+ * @dev: valid struct device pointer<br>
+ * @handle: DMA address of buffer<br>
+ * @size: size of buffer (same as passed to dma_map_page)<br>
+ * @dir: DMA transfer direction (same as passed to dma_map_page)<br>
+ *<br>
+ * IOMMU aware version of arm_dma_unmap_page()<br>
+ */<br>
+static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, enum dma_data_direction dir,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attrs *attrs)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
+ =A0 =A0 =A0 struct page *page =3D phys_to_page(iommu_iova_to_phys(mapping=
-&gt;domain, iova));<br>
+ =A0 =A0 =A0 int offset =3D handle &amp; ~PAGE_MASK;<br>
+ =A0 =A0 =A0 int len =3D PAGE_ALIGN(size + offset);<br>
+<br>
+ =A0 =A0 =A0 if (!iova)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+<br>
+ =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(page, offset, size, dir=
);<br>
+<br>
+ =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, iova, len);<br>
+ =A0 =A0 =A0 __free_iova(mapping, iova, len);<br>
+}<br>
+<br>
+static void arm_iommu_sync_single_for_cpu(struct device *dev,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, size_t size, enum dma_data=
_direction dir)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
+ =A0 =A0 =A0 struct page *page =3D phys_to_page(iommu_iova_to_phys(mapping=
-&gt;domain, iova));<br>
+ =A0 =A0 =A0 unsigned int offset =3D handle &amp; ~PAGE_MASK;<br>
+<br>
+ =A0 =A0 =A0 if (!iova)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+<br>
+ =A0 =A0 =A0 if (!arch_is_coherent())<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_page_dev_to_cpu(page, offset, size, dir=
);<br>
+}<br>
+<br>
+static void arm_iommu_sync_single_for_device(struct device *dev,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, size_t size, enum dma_data=
_direction dir)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev-&gt;archdata.mappin=
g;<br>
+ =A0 =A0 =A0 dma_addr_t iova =3D handle &amp; PAGE_MASK;<br>
+ =A0 =A0 =A0 struct page *page =3D phys_to_page(iommu_iova_to_phys(mapping=
-&gt;domain, iova));<br>
+ =A0 =A0 =A0 unsigned int offset =3D handle &amp; ~PAGE_MASK;<br>
+<br>
+ =A0 =A0 =A0 if (!iova)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+<br>
+ =A0 =A0 =A0 __dma_page_cpu_to_dev(page, offset, size, dir);<br>
+}<br>
+<br>
+struct dma_map_ops iommu_ops =3D {<br>
+ =A0 =A0 =A0 .alloc =A0 =A0 =A0 =A0 =A0=3D arm_iommu_alloc_attrs,<br>
+ =A0 =A0 =A0 .free =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_free_attrs,<br>
+ =A0 =A0 =A0 .mmap =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_mmap_attrs,<br>
+<br>
+ =A0 =A0 =A0 .map_page =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_map_page,=
<br>
+ =A0 =A0 =A0 .unmap_page =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_unmap_page,=
<br>
+ =A0 =A0 =A0 .sync_single_for_cpu =A0 =A0=3D arm_iommu_sync_single_for_cpu=
,<br>
+ =A0 =A0 =A0 .sync_single_for_device =3D arm_iommu_sync_single_for_device,=
<br>
+<br>
+ =A0 =A0 =A0 .map_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_map_sg,=
<br>
+ =A0 =A0 =A0 .unmap_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D arm_iommu_unmap_sg,=
<br>
+ =A0 =A0 =A0 .sync_sg_for_cpu =A0 =A0 =A0 =A0=3D arm_iommu_sync_sg_for_cpu=
,<br>
+ =A0 =A0 =A0 .sync_sg_for_device =A0 =A0 =3D arm_iommu_sync_sg_for_device,=
<br>
+};<br>
+<br>
+/**<br>
+ * arm_iommu_create_mapping<br>
+ * @bus: pointer to the bus holding the client device (for IOMMU calls)<br=
>
+ * @base: start address of the valid IO address space<br>
+ * @size: size of the valid IO address space<br>
+ * @order: accuracy of the IO addresses allocations<br>
+ *<br>
+ * Creates a mapping structure which holds information about used/unused<b=
r>
+ * IO address ranges, which is required to perform memory allocation and<b=
r>
+ * mapping with IOMMU aware functions.<br>
+ *<br>
+ * The client device need to be attached to the mapping with<br>
+ * arm_iommu_attach_device function.<br>
+ */<br>
+struct dma_iommu_mapping *<br>
+arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t siz=
e,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order)<br>
+{<br>
+ =A0 =A0 =A0 unsigned int count =3D size &gt;&gt; (PAGE_SHIFT + order);<br=
>
+ =A0 =A0 =A0 unsigned int bitmap_size =3D BITS_TO_LONGS(count) * sizeof(lo=
ng);<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping;<br>
+ =A0 =A0 =A0 int err =3D -ENOMEM;<br>
+<br>
+ =A0 =A0 =A0 if (!count)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);<br>
+<br>
+ =A0 =A0 =A0 mapping =3D kzalloc(sizeof(struct dma_iommu_mapping), GFP_KER=
NEL);<br>
+ =A0 =A0 =A0 if (!mapping)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;<br>
+<br>
+ =A0 =A0 =A0 mapping-&gt;bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);<br>
+ =A0 =A0 =A0 if (!mapping-&gt;bitmap)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err2;<br>
+<br>
+ =A0 =A0 =A0 mapping-&gt;base =3D base;<br>
+ =A0 =A0 =A0 mapping-&gt;bits =3D BITS_PER_BYTE * bitmap_size;<br>
+ =A0 =A0 =A0 mapping-&gt;order =3D order;<br>
+ =A0 =A0 =A0 spin_lock_init(&amp;mapping-&gt;lock);<br>
+<br>
+ =A0 =A0 =A0 mapping-&gt;domain =3D iommu_domain_alloc(bus);<br>
+ =A0 =A0 =A0 if (!mapping-&gt;domain)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err3;<br>
+<br>
+ =A0 =A0 =A0 kref_init(&amp;mapping-&gt;kref);<br>
+ =A0 =A0 =A0 return mapping;<br>
+err3:<br>
+ =A0 =A0 =A0 kfree(mapping-&gt;bitmap);<br>
+err2:<br>
+ =A0 =A0 =A0 kfree(mapping);<br>
+err:<br>
+ =A0 =A0 =A0 return ERR_PTR(err);<br>
+}<br>
+<br>
+static void release_iommu_mapping(struct kref *kref)<br>
+{<br>
+ =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(kref, struct dma_iommu_mapping, =
kref);<br>
+<br>
+ =A0 =A0 =A0 iommu_domain_free(mapping-&gt;domain);<br>
+ =A0 =A0 =A0 kfree(mapping-&gt;bitmap);<br>
+ =A0 =A0 =A0 kfree(mapping);<br>
+}<br>
+<br>
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)<br>
+{<br>
+ =A0 =A0 =A0 if (mapping)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_put(&amp;mapping-&gt;kref, release_iommu=
_mapping);<br>
+}<br>
+<br>
+/**<br>
+ * arm_iommu_attach_device<br>
+ * @dev: valid struct device pointer<br>
+ * @mapping: io address space mapping structure (returned from<br>
+ * =A0 =A0 arm_iommu_create_mapping)<br>
+ *<br>
+ * Attaches specified io address space mapping to the provided device,<br>
+ * this replaces the dma operations (dma_map_ops pointer) with the<br>
+ * IOMMU aware version. More than one client might be attached to<br>
+ * the same io address space mapping.<br>
+ */<br>
+int arm_iommu_attach_device(struct device *dev,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_iommu_mapp=
ing *mapping)<br>
+{<br>
+ =A0 =A0 =A0 int err;<br>
+<br>
+ =A0 =A0 =A0 err =3D iommu_attach_device(mapping-&gt;domain, dev);<br>
+ =A0 =A0 =A0 if (err)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;<br>
+<br>
+ =A0 =A0 =A0 kref_get(&amp;mapping-&gt;kref);<br>
+ =A0 =A0 =A0 dev-&gt;archdata.mapping =3D mapping;<br>
+ =A0 =A0 =A0 set_dma_ops(dev, &amp;iommu_ops);<br>
+<br>
+ =A0 =A0 =A0 pr_info(&quot;Attached IOMMU controller to %s device.\n&quot;=
, dev_name(dev));<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+#endif<br>
diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h<br>
index 162be66..bf312c3 100644<br>
--- a/arch/arm/mm/vmregion.h<br>
+++ b/arch/arm/mm/vmregion.h<br>
@@ -17,7 +17,7 @@ struct arm_vmregion {<br>
 =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0vm_list;<br>
 =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 vm_start;<br>
 =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 vm_end;<br>
- =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *vm_pages;<br>
+ =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*priv;<br>
 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm_active;<br>
 =A0 =A0 =A0 =A0const void =A0 =A0 =A0 =A0 =A0 =A0 =A0*caller;<br>
=A0};<br>
<span><font color=3D"#888888">--<br>
1.7.1.569.g6f426<br>
<br>
<br>
_______________________________________________<br>
Linaro-mm-sig mailing list<br>
<a href=3D"mailto:Linaro-mm-sig@lists.linaro.org" target=3D"_blank">Linaro-=
mm-sig@lists.linaro.org</a><br>
<a href=3D"http://lists.linaro.org/mailman/listinfo/linaro-mm-sig" target=
=3D"_blank">http://lists.linaro.org/mailman/listinfo/linaro-mm-sig</a><br>
</font></span></blockquote></div><br>

--0016e6d58a1a74164f04be126cd0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
