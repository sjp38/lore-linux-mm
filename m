Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8FF76B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 06:05:48 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id o6so11739790oag.24
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 03:05:48 -0700 (PDT)
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
        by mx.google.com with ESMTPS id k5si2805645oed.63.2014.08.26.03.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 03:05:47 -0700 (PDT)
Received: by mail-ob0-f173.google.com with SMTP id vb8so11605081obc.32
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 03:05:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1407800431-21566-4-git-send-email-lauraa@codeaurora.org>
References: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>
	<1407800431-21566-4-git-send-email-lauraa@codeaurora.org>
Date: Tue, 26 Aug 2014 11:05:47 +0100
Message-ID: <CAAG0J99=wrz4+c49HeDvL0W9rDZKk2HNLdVtHv4ZJxU4-OjewA@mail.gmail.com>
Subject: Re: [PATCHv7 3/5] common: dma-mapping: Introduce common remapping functions
From: James Hogan <james.hogan@imgtec.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, ARM Kernel List <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-next@vger.kernel.org

On 12 August 2014 00:40, Laura Abbott <lauraa@codeaurora.org> wrote:
>
> For architectures without coherent DMA, memory for DMA may
> need to be remapped with coherent attributes. Factor out
> the the remapping code from arm and put it in a
> common location to reduce code duplication.
>
> As part of this, the arm APIs are now migrated away from
> ioremap_page_range to the common APIs which use map_vm_area for remapping=
.
> This should be an equivalent change and using map_vm_area is more
> correct as ioremap_page_range is intended to bring in io addresses
> into the cpu space and not regular kernel managed memory.
>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

This commit in linux-next () breaks the build for metag:

drivers/base/dma-mapping.c: In function =E2=80=98dma_common_contiguous_rema=
p=E2=80=99:
drivers/base/dma-mapping.c:294: error: implicit declaration of
function =E2=80=98dma_common_pages_remap=E2=80=99
drivers/base/dma-mapping.c:294: warning: assignment makes pointer from
integer without a cast
drivers/base/dma-mapping.c: At top level:
drivers/base/dma-mapping.c:308: error: conflicting types for
=E2=80=98dma_common_pages_remap=E2=80=99
drivers/base/dma-mapping.c:294: error: previous implicit declaration
of =E2=80=98dma_common_pages_remap=E2=80=99 was here

Looks like metag isn't alone either:

$ git grep -L dma-mapping-common arch/*/include/asm/dma-mapping.h
arch/arc/include/asm/dma-mapping.h
arch/avr32/include/asm/dma-mapping.h
arch/blackfin/include/asm/dma-mapping.h
arch/c6x/include/asm/dma-mapping.h
arch/cris/include/asm/dma-mapping.h
arch/frv/include/asm/dma-mapping.h
arch/m68k/include/asm/dma-mapping.h
arch/metag/include/asm/dma-mapping.h
arch/mn10300/include/asm/dma-mapping.h
arch/parisc/include/asm/dma-mapping.h
arch/xtensa/include/asm/dma-mapping.h

I've checked a couple of these arches (blackfin, xtensa) which don't
include dma-mapping-common.h and their builds seem to be broken too.

Cheers
James

> ---
>  arch/arm/mm/dma-mapping.c                | 57 +++++---------------------
>  drivers/base/dma-mapping.c               | 68 ++++++++++++++++++++++++++=
++++++
>  include/asm-generic/dma-mapping-common.h |  9 +++++
>  3 files changed, 86 insertions(+), 48 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 4c88935..f5190ac 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -297,37 +297,19 @@ static void *
>  __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t pr=
ot,
>         const void *caller)
>  {
> -       struct vm_struct *area;
> -       unsigned long addr;
> -
>         /*
>          * DMA allocation can be mapped to user space, so lets
>          * set VM_USERMAP flags too.
>          */
> -       area =3D get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USER=
MAP,
> -                                 caller);
> -       if (!area)
> -               return NULL;
> -       addr =3D (unsigned long)area->addr;
> -       area->phys_addr =3D __pfn_to_phys(page_to_pfn(page));
> -
> -       if (ioremap_page_range(addr, addr + size, area->phys_addr, prot))=
 {
> -               vunmap((void *)addr);
> -               return NULL;
> -       }
> -       return (void *)addr;
> +       return dma_common_contiguous_remap(page, size,
> +                       VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> +                       prot, caller);
>  }
>
>  static void __dma_free_remap(void *cpu_addr, size_t size)
>  {
> -       unsigned int flags =3D VM_ARM_DMA_CONSISTENT | VM_USERMAP;
> -       struct vm_struct *area =3D find_vm_area(cpu_addr);
> -       if (!area || (area->flags & flags) !=3D flags) {
> -               WARN(1, "trying to free invalid coherent area: %p\n", cpu=
_addr);
> -               return;
> -       }
> -       unmap_kernel_range((unsigned long)cpu_addr, size);
> -       vunmap(cpu_addr);
> +       dma_common_free_remap(cpu_addr, size,
> +                       VM_ARM_DMA_CONSISTENT | VM_USERMAP);
>  }
>
>  #define DEFAULT_DMA_COHERENT_POOL_SIZE SZ_256K
> @@ -1261,29 +1243,8 @@ static void *
>  __iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_=
t prot,
>                     const void *caller)
>  {
> -       unsigned int i, nr_pages =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
> -       struct vm_struct *area;
> -       unsigned long p;
> -
> -       area =3D get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USER=
MAP,
> -                                 caller);
> -       if (!area)
> -               return NULL;
> -
> -       area->pages =3D pages;
> -       area->nr_pages =3D nr_pages;
> -       p =3D (unsigned long)area->addr;
> -
> -       for (i =3D 0; i < nr_pages; i++) {
> -               phys_addr_t phys =3D __pfn_to_phys(page_to_pfn(pages[i]))=
;
> -               if (ioremap_page_range(p, p + PAGE_SIZE, phys, prot))
> -                       goto err;
> -               p +=3D PAGE_SIZE;
> -       }
> -       return area->addr;
> -err:
> -       unmap_kernel_range((unsigned long)area->addr, size);
> -       vunmap(area->addr);
> +       return dma_common_pages_remap(pages, size,
> +                       VM_ARM_DMA_CONSISTENT | VM_USERMAP, prot, caller)=
;
>         return NULL;
>  }
>
> @@ -1491,8 +1452,8 @@ void arm_iommu_free_attrs(struct device *dev, size_=
t size, void *cpu_addr,
>         }
>
>         if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs)) {
> -               unmap_kernel_range((unsigned long)cpu_addr, size);
> -               vunmap(cpu_addr);
> +               dma_common_free_remap(cpu_addr, size,
> +                       VM_ARM_DMA_CONSISTENT | VM_USERMAP);
>         }
>
>         __iommu_remove_mapping(dev, handle, size);
> diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
> index 6cd08e1..1bc46df 100644
> --- a/drivers/base/dma-mapping.c
> +++ b/drivers/base/dma-mapping.c
> @@ -10,6 +10,8 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/export.h>
>  #include <linux/gfp.h>
> +#include <linux/slab.h>
> +#include <linux/vmalloc.h>
>  #include <asm-generic/dma-coherent.h>
>
>  /*
> @@ -267,3 +269,69 @@ int dma_common_mmap(struct device *dev, struct vm_ar=
ea_struct *vma,
>         return ret;
>  }
>  EXPORT_SYMBOL(dma_common_mmap);
> +
> +/*
> + * remaps an allocated contiguous region into another vm_area.
> + * Cannot be used in non-sleeping contexts
> + */
> +
> +void *dma_common_contiguous_remap(struct page *page, size_t size,
> +                       unsigned long vm_flags,
> +                       pgprot_t prot, const void *caller)
> +{
> +       int i;
> +       struct page **pages;
> +       void *ptr;
> +       unsigned long pfn;
> +
> +       pages =3D kmalloc(sizeof(struct page *) << get_order(size), GFP_K=
ERNEL);
> +       if (!pages)
> +               return NULL;
> +
> +       for (i =3D 0, pfn =3D page_to_pfn(page); i < (size >> PAGE_SHIFT)=
; i++)
> +               pages[i] =3D pfn_to_page(pfn + i);
> +
> +       ptr =3D dma_common_pages_remap(pages, size, vm_flags, prot, calle=
r);
> +
> +       kfree(pages);
> +
> +       return ptr;
> +}
> +
> +/*
> + * remaps an array of PAGE_SIZE pages into another vm_area
> + * Cannot be used in non-sleeping contexts
> + */
> +void *dma_common_pages_remap(struct page **pages, size_t size,
> +                       unsigned long vm_flags, pgprot_t prot,
> +                       const void *caller)
> +{
> +       struct vm_struct *area;
> +
> +       area =3D get_vm_area_caller(size, vm_flags, caller);
> +       if (!area)
> +               return NULL;
> +
> +       if (map_vm_area(area, prot, pages)) {
> +               vunmap(area->addr);
> +               return NULL;
> +       }
> +
> +       return area->addr;
> +}
> +
> +/*
> + * unmaps a range previously mapped by dma_common_*_remap
> + */
> +void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm=
_flags)
> +{
> +       struct vm_struct *area =3D find_vm_area(cpu_addr);
> +
> +       if (!area || (area->flags & vm_flags) !=3D vm_flags) {
> +               WARN(1, "trying to free invalid coherent area: %p\n", cpu=
_addr);
> +               return;
> +       }
> +
> +       unmap_kernel_range((unsigned long)cpu_addr, size);
> +       vunmap(cpu_addr);
> +}
> diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-gener=
ic/dma-mapping-common.h
> index de8bf89..a9fd248 100644
> --- a/include/asm-generic/dma-mapping-common.h
> +++ b/include/asm-generic/dma-mapping-common.h
> @@ -179,6 +179,15 @@ dma_sync_sg_for_device(struct device *dev, struct sc=
atterlist *sg,
>  extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vm=
a,
>                            void *cpu_addr, dma_addr_t dma_addr, size_t si=
ze);
>
> +void *dma_common_contiguous_remap(struct page *page, size_t size,
> +                       unsigned long vm_flags,
> +                       pgprot_t prot, const void *caller);
> +
> +void *dma_common_pages_remap(struct page **pages, size_t size,
> +                       unsigned long vm_flags, pgprot_t prot,
> +                       const void *caller);
> +void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm=
_flags);
> +
>  /**
>   * dma_mmap_attrs - map a coherent DMA allocation into user space
>   * @dev: valid struct device pointer, or NULL for ISA and EISA-like devi=
ces
> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum=
,
> hosted by The Linux Foundation
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
