Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0A76F6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 07:42:35 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M6J00LSR76C0BM0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 02 Jul 2012 20:42:33 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M6J00HTS76G6N50@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 02 Jul 2012 20:42:33 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1340614047-5824-1-git-send-email-m.szyprowski@samsung.com>
 <1340614047-5824-3-git-send-email-m.szyprowski@samsung.com>
 <4FEA67D8.1080500@kernel.org>
In-reply-to: <4FEA67D8.1080500@kernel.org>
Subject: RE: [PATCHv4 2/2] ARM: dma-mapping: remove custom consistent dma region
Date: Mon, 02 Jul 2012 13:42:15 +0200
Message-id: <028e01cd5847$bea3f1b0$3bebd510$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

Hello,

On Wednesday, June 27, 2012 3:55 AM Minchan Kim wrote:

> On 06/25/2012 05:47 PM, Marek Szyprowski wrote:
> 
> > This patch changes dma-mapping subsystem to use generic vmalloc areas
> > for all consistent dma allocations. This increases the total size limit
> > of the consistent allocations and removes platform hacks and a lot of
> > duplicated code.
> >
> > Atomic allocations are served from special pool preallocated on boot,
> > becasue vmalloc areas cannot be reliably created in atomic context.
> 
> 
> s/becasue/because
> 
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> 
> I like this patch very much but notice one more again.
> Here is goes, again.
> https://lkml.org/lkml/2012/6/13/628
> It's another hack for avoding vmalloc atomic.
> There are several grumblers ago and everybody made own mempool so code
> began to bloat and it would be error-prone. :(
> I think it's TODO for mm folks to decide.

I've read the discussion. This case is very similar we also might need to be called
from atomic context.  I hope that this issue will be resolved by mm developers
one day, so my pool based workaround can be removed.

> Anyway, there are some trivial comment below.

Thanks, I will send an updated version soon.

> 
> > ---
> >  Documentation/kernel-parameters.txt |    2 +-
> >  arch/arm/include/asm/dma-mapping.h  |    2 +-
> >  arch/arm/mm/dma-mapping.c           |  505 +++++++++++++----------------------
> >  arch/arm/mm/mm.h                    |    3 +
> >  include/linux/vmalloc.h             |    1 +
> >  mm/vmalloc.c                        |   10 +-
> >  6 files changed, 194 insertions(+), 329 deletions(-)
> >
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index a92c5eb..da07f6c 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -526,7 +526,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
> >
> >  	coherent_pool=nn[KMG]	[ARM,KNL]
> >  			Sets the size of memory pool for coherent, atomic dma
> > -			allocations if Contiguous Memory Allocator (CMA) is used.
> > +			allocations.
> 
> 
> What's the default? 256K?
> If we specify, couldn't it help?

Good idea.

> 
> >
> >  	code_bytes	[X86] How many bytes of object code to print
> >  			in an oops report.
> > diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
> > index bbef15d..80777d87 100644
> > --- a/arch/arm/include/asm/dma-mapping.h
> > +++ b/arch/arm/include/asm/dma-mapping.h
> > @@ -226,7 +226,7 @@ static inline int dma_mmap_writecombine(struct device *dev, struct
> vm_area_struc
> >   * DMA region above it's default value of 2MB. It must be called before the
> >   * memory allocator is initialised, i.e. before any core_initcall.
> >   */
> > -extern void __init init_consistent_dma_size(unsigned long size);
> > +static inline void init_consistent_dma_size(unsigned long size) { }
> >
> >  /*
> >   * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index d766e42..c1f2294 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -22,6 +22,7 @@
> >  #include <linux/memblock.h>
> >  #include <linux/slab.h>
> >  #include <linux/iommu.h>
> > +#include <linux/io.h>
> >  #include <linux/vmalloc.h>
> >
> >  #include <asm/memory.h>
> > @@ -217,115 +218,67 @@ static void __dma_free_buffer(struct page *page, size_t size)
> >  }
> >
> >  #ifdef CONFIG_MMU
> > -
> > -#define CONSISTENT_OFFSET(x)	(((unsigned long)(x) - consistent_base) >> PAGE_SHIFT)
> > -#define CONSISTENT_PTE_INDEX(x) (((unsigned long)(x) - consistent_base) >> PMD_SHIFT)
> > -
> > -/*
> > - * These are the page tables (2MB each) covering uncached, DMA consistent allocations
> > - */
> > -static pte_t **consistent_pte;
> > -
> > -#define DEFAULT_CONSISTENT_DMA_SIZE SZ_2M
> > -
> > -static unsigned long consistent_base = CONSISTENT_END - DEFAULT_CONSISTENT_DMA_SIZE;
> > -
> > -void __init init_consistent_dma_size(unsigned long size)
> > -{
> > -	unsigned long base = CONSISTENT_END - ALIGN(size, SZ_2M);
> > -
> > -	BUG_ON(consistent_pte); /* Check we're called before DMA region init */
> > -	BUG_ON(base < VMALLOC_END);
> > -
> > -	/* Grow region to accommodate specified size  */
> > -	if (base < consistent_base)
> > -		consistent_base = base;
> > -}
> > -
> > -#include "vmregion.h"
> > -
> > -static struct arm_vmregion_head consistent_head = {
> > -	.vm_lock	= __SPIN_LOCK_UNLOCKED(&consistent_head.vm_lock),
> > -	.vm_list	= LIST_HEAD_INIT(consistent_head.vm_list),
> > -	.vm_end		= CONSISTENT_END,
> > -};
> > -
> >  #ifdef CONFIG_HUGETLB_PAGE
> >  #error ARM Coherent DMA allocator does not (yet) support huge TLB
> >  #endif
> >
> > -/*
> > - * Initialise the consistent memory allocation.
> > - */
> > -static int __init consistent_init(void)
> > -{
> > -	int ret = 0;
> > -	pgd_t *pgd;
> > -	pud_t *pud;
> > -	pmd_t *pmd;
> > -	pte_t *pte;
> > -	int i = 0;
> > -	unsigned long base = consistent_base;
> > -	unsigned long num_ptes = (CONSISTENT_END - base) >> PMD_SHIFT;
> > -
> > -	if (IS_ENABLED(CONFIG_CMA) && !IS_ENABLED(CONFIG_ARM_DMA_USE_IOMMU))
> > -		return 0;
> > -
> > -	consistent_pte = kmalloc(num_ptes * sizeof(pte_t), GFP_KERNEL);
> > -	if (!consistent_pte) {
> > -		pr_err("%s: no memory\n", __func__);
> > -		return -ENOMEM;
> > -	}
> > -
> > -	pr_debug("DMA memory: 0x%08lx - 0x%08lx:\n", base, CONSISTENT_END);
> > -	consistent_head.vm_start = base;
> > -
> > -	do {
> > -		pgd = pgd_offset(&init_mm, base);
> > -
> > -		pud = pud_alloc(&init_mm, pgd, base);
> > -		if (!pud) {
> > -			pr_err("%s: no pud tables\n", __func__);
> > -			ret = -ENOMEM;
> > -			break;
> > -		}
> > -
> > -		pmd = pmd_alloc(&init_mm, pud, base);
> > -		if (!pmd) {
> > -			pr_err("%s: no pmd tables\n", __func__);
> > -			ret = -ENOMEM;
> > -			break;
> > -		}
> > -		WARN_ON(!pmd_none(*pmd));
> > -
> > -		pte = pte_alloc_kernel(pmd, base);
> > -		if (!pte) {
> > -			pr_err("%s: no pte tables\n", __func__);
> > -			ret = -ENOMEM;
> > -			break;
> > -		}
> > -
> > -		consistent_pte[i++] = pte;
> > -		base += PMD_SIZE;
> > -	} while (base < CONSISTENT_END);
> > -
> > -	return ret;
> > -}
> > -core_initcall(consistent_init);
> > -
> >  static void *__alloc_from_contiguous(struct device *dev, size_t size,
> >  				     pgprot_t prot, struct page **ret_page);
> >
> > -static struct arm_vmregion_head coherent_head = {
> > -	.vm_lock	= __SPIN_LOCK_UNLOCKED(&coherent_head.vm_lock),
> > -	.vm_list	= LIST_HEAD_INIT(coherent_head.vm_list),
> > +static void *__alloc_remap_buffer(struct device *dev, size_t size, gfp_t gfp,
> > +				 pgprot_t prot, struct page **ret_page,
> > +				 const void *caller);
> > +
> > +static void *
> > +__dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
> > +	const void *caller)
> > +{
> > +	struct vm_struct *area;
> > +	unsigned long addr;
> > +
> > +	area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
> > +				  caller);
> 
> 
> Please write down why we always need VM_USERMAP.
> If we always need it in ARM, why don't you define following as?
> #define VM_ARM_DMA_CONSISTENT (0x20000000 | VM_USERAMP)?
> Although it's trivial, it could be more understandable that everybody
> can think of it that "ARM DMA allocation could be mapped by user space, everytime"

The fact that DMA allocation can be mapped to userspace is not specific to ARM, so I
will keep using (VM_ARM_DMA_CONSISTENT | VM_USERMAP) and add a comment about it.

> > +	if (!area)
> > +		return NULL;
> > +	addr = (unsigned long)area->addr;
> > +	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
> > +
> > +	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
> > +		vunmap((void *)addr);
> > +		return NULL;
> > +	}
> > +	return (void *)addr;
> > +}
> > +
> > +static void __dma_free_remap(void *cpu_addr, size_t size)
> > +{
> > +	struct vm_struct *area = find_vm_area(cpu_addr);
> > +	if (!area || !(area->flags & VM_ARM_DMA_CONSISTENT)) {
> 
> 
> Above definery could enhance this check, too.
> 
> > +		pr_err("%s: trying to free invalid coherent area: %p\n",
> > +		       __func__, cpu_addr);
> > +		dump_stack();
> > +		return;
> > +	}
> > +	unmap_kernel_range((unsigned long)cpu_addr, size);
> > +	vunmap(cpu_addr);
> > +}
> > +
> > +struct dma_pool {
> > +	size_t size;
> > +	spinlock_t lock;
> > +	unsigned long *bitmap;
> > +	unsigned long nr_pages;
> > +	void *vaddr;
> > +	struct page *page;
> >  };
> >
> > -static size_t coherent_pool_size = DEFAULT_CONSISTENT_DMA_SIZE / 8;
> > +static struct dma_pool atomic_pool = {
> > +	.size = SZ_256K,
> > +};
> >
> >  static int __init early_coherent_pool(char *p)
> >  {
> > -	coherent_pool_size = memparse(p, &p);
> > +	atomic_pool.size = memparse(p, &p);
> >  	return 0;
> >  }
> >  early_param("coherent_pool", early_coherent_pool);
> > @@ -333,32 +286,45 @@ early_param("coherent_pool", early_coherent_pool);
> >  /*
> >   * Initialise the coherent pool for atomic allocations.
> >   */
> > -static int __init coherent_init(void)
> > +static int __init atomic_pool_init(void)
> >  {
> > +	struct dma_pool *pool = &atomic_pool;
> >  	pgprot_t prot = pgprot_dmacoherent(pgprot_kernel);
> > -	size_t size = coherent_pool_size;
> > +	unsigned long nr_pages = pool->size >> PAGE_SHIFT;
> > +	unsigned long *bitmap;
> >  	struct page *page;
> >  	void *ptr;
> > +	int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
> >
> > -	if (!IS_ENABLED(CONFIG_CMA))
> > -		return 0;
> > +	bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	if (!bitmap)
> > +		goto no_bitmap;
> >
> > -	ptr = __alloc_from_contiguous(NULL, size, prot, &page);
> > +	if (IS_ENABLED(CONFIG_CMA))
> > +		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page);
> > +	else
> > +		ptr = __alloc_remap_buffer(NULL, pool->size, GFP_KERNEL, prot,
> > +					   &page, NULL);
> >  	if (ptr) {
> > -		coherent_head.vm_start = (unsigned long) ptr;
> > -		coherent_head.vm_end = (unsigned long) ptr + size;
> > -		printk(KERN_INFO "DMA: preallocated %u KiB pool for atomic coherent allocations\n",
> > -		       (unsigned)size / 1024);
> > +		spin_lock_init(&pool->lock);
> > +		pool->vaddr = ptr;
> > +		pool->page = page;
> > +		pool->bitmap = bitmap;
> > +		pool->nr_pages = nr_pages;
> > +		pr_info("DMA: preallocated %u KiB pool for atomic coherent allocations\n",
> > +		       (unsigned)pool->size / 1024);
> >  		return 0;
> >  	}
> > -	printk(KERN_ERR "DMA: failed to allocate %u KiB pool for atomic coherent allocation\n",
> > -	       (unsigned)size / 1024);
> > +	kfree(bitmap);
> > +no_bitmap:
> > +	pr_err("DMA: failed to allocate %u KiB pool for atomic coherent allocation\n",
> > +	       (unsigned)pool->size / 1024);
> >  	return -ENOMEM;
> >  }
> >  /*
> >   * CMA is activated by core_initcall, so we must be called after it.
> >   */
> > -postcore_initcall(coherent_init);
> > +postcore_initcall(atomic_pool_init);
> >
> >  struct dma_contig_early_reserve {
> >  	phys_addr_t base;
> > @@ -406,112 +372,6 @@ void __init dma_contiguous_remap(void)
> >  	}
> >  }
> >
> > -static void *
> > -__dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
> > -	const void *caller)
> > -{
> > -	struct arm_vmregion *c;
> > -	size_t align;
> > -	int bit;
> > -
> > -	if (!consistent_pte) {
> > -		pr_err("%s: not initialised\n", __func__);
> > -		dump_stack();
> > -		return NULL;
> > -	}
> > -
> > -	/*
> > -	 * Align the virtual region allocation - maximum alignment is
> > -	 * a section size, minimum is a page size.  This helps reduce
> > -	 * fragmentation of the DMA space, and also prevents allocations
> > -	 * smaller than a section from crossing a section boundary.
> > -	 */
> > -	bit = fls(size - 1);
> > -	if (bit > SECTION_SHIFT)
> > -		bit = SECTION_SHIFT;
> > -	align = 1 << bit;
> > -
> > -	/*
> > -	 * Allocate a virtual address in the consistent mapping region.
> > -	 */
> > -	c = arm_vmregion_alloc(&consistent_head, align, size,
> > -			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM), caller);
> > -	if (c) {
> > -		pte_t *pte;
> > -		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
> > -		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
> > -
> > -		pte = consistent_pte[idx] + off;
> > -		c->priv = page;
> > -
> > -		do {
> > -			BUG_ON(!pte_none(*pte));
> > -
> > -			set_pte_ext(pte, mk_pte(page, prot), 0);
> > -			page++;
> > -			pte++;
> > -			off++;
> > -			if (off >= PTRS_PER_PTE) {
> > -				off = 0;
> > -				pte = consistent_pte[++idx];
> > -			}
> > -		} while (size -= PAGE_SIZE);
> > -
> > -		dsb();
> > -
> > -		return (void *)c->vm_start;
> > -	}
> > -	return NULL;
> > -}
> > -
> > -static void __dma_free_remap(void *cpu_addr, size_t size)
> > -{
> > -	struct arm_vmregion *c;
> > -	unsigned long addr;
> > -	pte_t *ptep;
> > -	int idx;
> > -	u32 off;
> > -
> > -	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
> > -	if (!c) {
> > -		pr_err("%s: trying to free invalid coherent area: %p\n",
> > -		       __func__, cpu_addr);
> > -		dump_stack();
> > -		return;
> > -	}
> > -
> > -	if ((c->vm_end - c->vm_start) != size) {
> > -		pr_err("%s: freeing wrong coherent size (%ld != %d)\n",
> > -		       __func__, c->vm_end - c->vm_start, size);
> > -		dump_stack();
> > -		size = c->vm_end - c->vm_start;
> > -	}
> > -
> > -	idx = CONSISTENT_PTE_INDEX(c->vm_start);
> > -	off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
> > -	ptep = consistent_pte[idx] + off;
> > -	addr = c->vm_start;
> > -	do {
> > -		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
> > -
> > -		ptep++;
> > -		addr += PAGE_SIZE;
> > -		off++;
> > -		if (off >= PTRS_PER_PTE) {
> > -			off = 0;
> > -			ptep = consistent_pte[++idx];
> > -		}
> > -
> > -		if (pte_none(pte) || !pte_present(pte))
> > -			pr_crit("%s: bad page in kernel page table\n",
> > -				__func__);
> > -	} while (size -= PAGE_SIZE);
> > -
> > -	flush_tlb_kernel_range(c->vm_start, c->vm_end);
> > -
> > -	arm_vmregion_free(&consistent_head, c);
> > -}
> > -
> >  static int __dma_update_pte(pte_t *pte, pgtable_t token, unsigned long addr,
> >  			    void *data)
> >  {
> > @@ -552,15 +412,17 @@ static void *__alloc_remap_buffer(struct device *dev, size_t size,
> gfp_t gfp,
> >  	return ptr;
> >  }
> >
> > -static void *__alloc_from_pool(struct device *dev, size_t size,
> > -			       struct page **ret_page, const void *caller)
> > +static void *__alloc_from_pool(size_t size, struct page **ret_page)
> >  {
> > -	struct arm_vmregion *c;
> > +	struct dma_pool *pool = &atomic_pool;
> > +	unsigned int count = size >> PAGE_SHIFT;
> 
> 
> Just out of curiosity.
> Do we make sure size is always aligned to PAGE_SIZE?
> If so, please write down

Ok, thanks for spotting it.

> 
> > +	unsigned int pageno;
> > +	unsigned long flags;
> > +	void *ptr = NULL;
> >  	size_t align;
> >
> > -	if (!coherent_head.vm_start) {
> > -		printk(KERN_ERR "%s: coherent pool not initialised!\n",
> > -		       __func__);
> > +	if (!pool->vaddr) {
> > +		pr_err("%s: coherent pool not initialised!\n", __func__);
> >  		dump_stack();
> 
> Why doesn't you use WARN?

Ok, I will use WARN here.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
