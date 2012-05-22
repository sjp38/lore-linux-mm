Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 87E786B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 08:50:35 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=utf-8
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4F00DPMCYUBK60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 22 May 2012 13:49:42 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4F00LHCD06IA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 22 May 2012 13:50:31 +0100 (BST)
Date: Tue, 22 May 2012 14:50:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv2 4/4] ARM: dma-mapping: remove custom consistent dma region
In-reply-to: <4FBB4142.2070709@kernel.org>
Message-id: <000001cd3819$722aae30$56800a90$%szyprowski@samsung.com>
Content-language: pl
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-5-git-send-email-m.szyprowski@samsung.com>
 <4FBB4142.2070709@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

Hello,

On Tuesday, May 22, 2012 9:33 AM Minchan Kim wrote:

> On 05/17/2012 07:54 PM, Marek Szyprowski wrote:
> 
> > This patch changes dma-mapping subsystem to use generic vmalloc areas
> > for all consistent dma allocations. This increases the total size limit
> > of the consistent allocations and removes platform hacks and a lot of
> > duplicated code.
> >
> 
> I like this patch very much!

Thanks!

> There are just small nitpicks below.
> 
> > Atomic allocations are served from special pool preallocated on boot,
> > becasue vmalloc areas cannot be reliably created in atomic context.
> 
> 
> typo because
> 
> >
> 
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > ---
> >  Documentation/kernel-parameters.txt |    4 +
> >  arch/arm/include/asm/dma-mapping.h  |    2 +-
> >  arch/arm/mm/dma-mapping.c           |  360 ++++++++++++++++-------------------
> >  3 files changed, 171 insertions(+), 195 deletions(-)
> >
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index c1601e5..ba58f50 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -515,6 +515,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
> >  			a hypervisor.
> >  			Default: yes
> >
> > +	coherent_pool=nn[KMG]	[ARM,KNL]
> > +			Sets the size of memory pool for coherent, atomic dma
> > +			allocations.
> > +
> >  	code_bytes	[X86] How many bytes of object code to print
> >  			in an oops report.
> >  			Range: 0 - 8192
> > diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
> > index cb3b7c9..92b0afb 100644
> > --- a/arch/arm/include/asm/dma-mapping.h
> > +++ b/arch/arm/include/asm/dma-mapping.h
> > @@ -210,7 +210,7 @@ int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
> >   * DMA region above it's default value of 2MB. It must be called before the
> >   * memory allocator is initialised, i.e. before any core_initcall.
> >   */
> > -extern void __init init_consistent_dma_size(unsigned long size);
> > +static inline void init_consistent_dma_size(unsigned long size) { }
> >
> >
> >  #ifdef CONFIG_DMABOUNCE
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index db23ae4..3be4de2 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -19,6 +19,8 @@
> >  #include <linux/dma-mapping.h>
> >  #include <linux/highmem.h>
> >  #include <linux/slab.h>
> > +#include <linux/io.h>
> > +#include <linux/vmalloc.h>
> >
> >  #include <asm/memory.h>
> >  #include <asm/highmem.h>
> > @@ -119,210 +121,178 @@ static void __dma_free_buffer(struct page *page, size_t size)
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
> > -unsigned long consistent_base = CONSISTENT_END - DEFAULT_CONSISTENT_DMA_SIZE;
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
> > -			printk(KERN_ERR "%s: no pud tables\n", __func__);
> > -			ret = -ENOMEM;
> > -			break;
> > -		}
> > -
> > -		pmd = pmd_alloc(&init_mm, pud, base);
> > -		if (!pmd) {
> > -			printk(KERN_ERR "%s: no pmd tables\n", __func__);
> > -			ret = -ENOMEM;
> > -			break;
> > -		}
> > -		WARN_ON(!pmd_none(*pmd));
> > -
> > -		pte = pte_alloc_kernel(pmd, base);
> > -		if (!pte) {
> > -			printk(KERN_ERR "%s: no pte tables\n", __func__);
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
> > -
> > -core_initcall(consistent_init);
> > -
> >  static void *
> >  __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
> >  	const void *caller)
> >  {
> > -	struct arm_vmregion *c;
> > -	size_t align;
> > -	int bit;
> > +	struct vm_struct *area;
> > +	unsigned long addr;
> >
> > -	if (!consistent_pte) {
> > -		printk(KERN_ERR "%s: not initialised\n", __func__);
> > +	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
> 
> Out of curiosity.
> Do we always map dma area into user's address space?

Nope, but there is always such possibility that the driver calls dma_mmap_*() and 
lets user space to access the memory allocated for dma.
 
> > +	if (!area)
> > +		return NULL;
> > +	addr = (unsigned long)area->addr;
> > +	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
> > +
> > +	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
> > +		vunmap((void *)addr);
> 
> > +		return NULL;
> 
> > +	}
> > +	return (void *)addr;
> > +}
> > +
> > +static void __dma_free_remap(void *cpu_addr, size_t size)
> > +{
> > +	struct vm_struct *area;
> > +
> > +	read_lock(&vmlist_lock);
> 
> 
> Why do we need vmlist_lock?

In fact, this one is not really needed here. I've copied it from arch/arm/mm/ioremap.c and then replaced 
search loop with find_vm_area(). Now I see that find_vm_area() uses internal locks in find_vmap_area(), 
so the global vmlist_lock is not needed here.

> > +	area = find_vm_area(cpu_addr);
> 
> 
> find_vm_area only checks vmalloced regions so we need more check.
> 
> if (!area || !(area->flags & VM_DMA))
> 
> > +	if (!area) {
> > +		pr_err("%s: trying to free invalid coherent area: %p\n",
> > +		       __func__, cpu_addr);
> > +		dump_stack();
> > +		read_unlock(&vmlist_lock);
> > +		return;
> > +	}
> > +	unmap_kernel_range((unsigned long)cpu_addr, size);
> > +	read_unlock(&vmlist_lock);
> > +	vunmap(cpu_addr);
> > +}
> > +
> > +struct dma_pool {
> > +	size_t size;
> > +	spinlock_t lock;
> > +	unsigned long *bitmap;
> > +	unsigned long count;
> 
> 
> Nitpick. What does count mean?
> nr_pages?

Right, I will rename it to nr_pages as it is much better name.

> > +	void *vaddr;
> > +	struct page *page;
> > +};
> > +
> > +static struct dma_pool atomic_pool = {
> > +	.size = SZ_256K,
> > +};
> 
> 
> AFAIUC, we could set it to 2M but you are reducing it to 256K.
> What's the justification for that default value?

I want to reduce memory waste. This atomic_pool is very rarely used (non-atomic allocations don't use 
this pool, kernel mappings are created on fly for them). The original consistent dma size on ARM was 
set to 2MiB, but it covered both atomic and non-atomic allocations. Some time ago (in the context of 
CMA/Contiguous Memory Allocator in Cambourne during Linaro MM meeting) we have discussed the idea of
pool for the atomic allocations and the conclusion was that the 1/8 of the original consistent dma 
size is probably more than enough. This value can be adjusted later if really needed or set with 
kernel boot parameter for some rare systems that needs more.

> > +
> > +static int __init early_coherent_pool(char *p)
> > +{
> > +	atomic_pool.size = memparse(p, &p);
> > +	return 0;
> > +}
> > +early_param("coherent_pool", early_coherent_pool);
> > +
> > +/*
> > + * Initialise the coherent pool for atomic allocations.
> > + */
> > +static int __init atomic_pool_init(void)
> > +{
> > +	struct dma_pool *pool = &atomic_pool;
> > +	pgprot_t prot = pgprot_dmacoherent(pgprot_kernel);
> > +	unsigned long count = pool->size >> PAGE_SHIFT;
> > +	gfp_t gfp = GFP_KERNEL | GFP_DMA;
> > +	unsigned long *bitmap;
> > +	struct page *page;
> > +	void *ptr;
> > +	int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> > +
> > +	bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	if (!bitmap)
> > +		goto no_bitmap;
> > +
> > +	page = __dma_alloc_buffer(NULL, pool->size, gfp);
> > +	if (!page)
> > +		goto no_page;
> > +
> > +	ptr = __dma_alloc_remap(page, pool->size, gfp, prot, NULL);
> > +	if (ptr) {
> > +		spin_lock_init(&pool->lock);
> > +		pool->vaddr = ptr;
> > +		pool->page = page;
> > +		pool->bitmap = bitmap;
> > +		pool->count = count;
> > +		pr_info("DMA: preallocated %u KiB pool for atomic coherent allocations\n",
> > +		       (unsigned)pool->size / 1024);
> > +		return 0;
> > +	}
> > +
> > +	__dma_free_buffer(page, pool->size);
> > +no_page:
> > +	kfree(bitmap);
> > +no_bitmap:
> > +	pr_err("DMA: failed to allocate %u KiB pool for atomic coherent allocation\n",
> > +	       (unsigned)pool->size / 1024);
> > +	return -ENOMEM;
> > +}
> > +core_initcall(atomic_pool_init);
> > +
> > +static void *__alloc_from_pool(size_t size, struct page **ret_page)
> > +{
> > +	struct dma_pool *pool = &atomic_pool;
> > +	unsigned int count = size >> PAGE_SHIFT;
> > +	unsigned int pageno;
> > +	unsigned long flags;
> > +	void *ptr = NULL;
> > +	size_t align;
> > +
> > +	if (!pool->vaddr) {
> > +		pr_err("%s: coherent pool not initialised!\n", __func__);
> >  		dump_stack();
> >  		return NULL;
> >  	}
> >
> >  	/*
> > -	 * Align the virtual region allocation - maximum alignment is
> > -	 * a section size, minimum is a page size.  This helps reduce
> > -	 * fragmentation of the DMA space, and also prevents allocations
> > -	 * smaller than a section from crossing a section boundary.
> > +	 * Align the region allocation - allocations from pool are rather
> > +	 * small, so align them to their order in pages, minimum is a page
> > +	 * size. This helps reduce fragmentation of the DMA space.
> >  	 */
> > -	bit = fls(size - 1);
> > -	if (bit > SECTION_SHIFT)
> > -		bit = SECTION_SHIFT;
> > -	align = 1 << bit;
> > +	align = PAGE_SIZE << get_order(size);
> >
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
> > -		c->vm_pages = page;
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
> > +	spin_lock_irqsave(&pool->lock, flags);
> > +	pageno = bitmap_find_next_zero_area(pool->bitmap, pool->count,
> > +					    0, count, (1 << align) - 1);
> > +	if (pageno < pool->count) {
> > +		bitmap_set(pool->bitmap, pageno, count);
> > +		ptr = pool->vaddr + PAGE_SIZE * pageno;
> > +		*ret_page = pool->page + pageno;
> >  	}
> > -	return NULL;
> > +	spin_unlock_irqrestore(&pool->lock, flags);
> > +
> > +	return ptr;
> >  }
> >
> > -static void __dma_free_remap(void *cpu_addr, size_t size)
> > +static int __free_from_pool(void *start, size_t size)
> >  {
> > -	struct arm_vmregion *c;
> > -	unsigned long addr;
> > -	pte_t *ptep;
> > -	int idx;
> > -	u32 off;
> > +	struct dma_pool *pool = &atomic_pool;
> > +	unsigned long pageno, count;
> > +	unsigned long flags;
> >
> > -	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
> > -	if (!c) {
> > -		printk(KERN_ERR "%s: trying to free invalid coherent area: %p\n",
> > -		       __func__, cpu_addr);
> > +	if (start < pool->vaddr || start > pool->vaddr + pool->size)
> > +		return 0;
> > +
> > +	if (start + size > pool->vaddr + pool->size) {
> > +		pr_err("%s: freeing wrong coherent size from pool\n", __func__);
> >  		dump_stack();
> > -		return;
> > +		return 0;
> >  	}
> >
> > -	if ((c->vm_end - c->vm_start) != size) {
> > -		printk(KERN_ERR "%s: freeing wrong coherent size (%ld != %d)\n",
> > -		       __func__, c->vm_end - c->vm_start, size);
> > -		dump_stack();
> > -		size = c->vm_end - c->vm_start;
> > -	}
> > +	pageno = (start - pool->vaddr) >> PAGE_SHIFT;
> > +	count = size >> PAGE_SHIFT;
> >
> > -	idx = CONSISTENT_PTE_INDEX(c->vm_start);
> > -	off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
> > -	ptep = consistent_pte[idx] + off;
> > -	addr = c->vm_start;
> > -	do {
> > -		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
> > +	spin_lock_irqsave(&pool->lock, flags);
> > +	bitmap_clear(pool->bitmap, pageno, count);
> > +	spin_unlock_irqrestore(&pool->lock, flags);
> >
> > -		ptep++;
> > -		addr += PAGE_SIZE;
> > -		off++;
> > -		if (off >= PTRS_PER_PTE) {
> > -			off = 0;
> > -			ptep = consistent_pte[++idx];
> > -		}
> > -
> > -		if (pte_none(pte) || !pte_present(pte))
> > -			printk(KERN_CRIT "%s: bad page in kernel page table\n",
> > -			       __func__);
> > -	} while (size -= PAGE_SIZE);
> > -
> > -	flush_tlb_kernel_range(c->vm_start, c->vm_end);
> > -
> > -	arm_vmregion_free(&consistent_head, c);
> > +	return 1;
> >  }
> >
> >  #else	/* !CONFIG_MMU */
> >
> >  #define __dma_alloc_remap(page, size, gfp, prot, c)	page_address(page)
> >  #define __dma_free_remap(addr, size)			do { } while (0)
> > +#define __alloc_from_pool(size, ret_page)		NULL
> > +#define __free_from_pool(addr, size)			0
> >
> >  #endif	/* CONFIG_MMU */
> >
> > @@ -345,6 +315,16 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t
> gfp,
> >  	*handle = ~0;
> >  	size = PAGE_ALIGN(size);
> >
> > +	/*
> > +	 * Atomic allocations need special handling
> > +	 */
> > +	if (gfp & GFP_ATOMIC && !arch_is_coherent()) {
> > +		addr = __alloc_from_pool(size, &page);
> > +		if (addr)
> > +			*handle = pfn_to_dma(dev, page_to_pfn(page));
> > +		return addr;
> > +	}
> > +
> >  	page = __dma_alloc_buffer(dev, size, gfp);
> >  	if (!page)
> >  		return NULL;
> > @@ -398,24 +378,16 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
> >  {
> >  	int ret = -ENXIO;
> >  #ifdef CONFIG_MMU
> > -	unsigned long user_size, kern_size;
> > -	struct arm_vmregion *c;
> > +	unsigned long user_count = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
> > +	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > +	unsigned long pfn = dma_to_pfn(dev, dma_addr);
> > +	unsigned long off = vma->vm_pgoff;
> >
> > -	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
> > -
> > -	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
> > -	if (c) {
> > -		unsigned long off = vma->vm_pgoff;
> > -
> > -		kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
> > -
> > -		if (off < kern_size &&
> > -		    user_size <= (kern_size - off)) {
> > -			ret = remap_pfn_range(vma, vma->vm_start,
> > -					      page_to_pfn(c->vm_pages) + off,
> > -					      user_size << PAGE_SHIFT,
> > -					      vma->vm_page_prot);
> > -		}
> > +	if (off < count && user_count <= (count - off)) {
> > +		ret = remap_pfn_range(vma, vma->vm_start,
> > +				      pfn + off,
> > +				      user_count << PAGE_SHIFT,
> > +				      vma->vm_page_prot);
> >  	}
> >  #endif	/* CONFIG_MMU */
> >
> > @@ -444,13 +416,16 @@ EXPORT_SYMBOL(dma_mmap_writecombine);
> >   */
> >  void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
> >  {
> > -	WARN_ON(irqs_disabled());
> > -
> >  	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
> >  		return;
> >
> >  	size = PAGE_ALIGN(size);
> >
> > +	if (__free_from_pool(cpu_addr, size))
> > +			return;
> > +
> > +	WARN_ON(irqs_disabled());
> > +
> >  	if (!arch_is_coherent())
> >  		__dma_free_remap(cpu_addr, size);
> >
> > @@ -726,9 +701,6 @@ EXPORT_SYMBOL(dma_set_mask);
> >
> >  static int __init dma_debug_do_init(void)
> >  {
> > -#ifdef CONFIG_MMU
> > -	arm_vmregion_create_proc("dma-mappings", &consistent_head);
> > -#endif
> >  	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
> >  	return 0;
> >  }
 
Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
