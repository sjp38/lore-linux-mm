Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCEB6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:10:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so3389965wmu.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:10:16 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id p18si7009750wrh.310.2017.10.19.04.10.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 04:10:14 -0700 (PDT)
Date: Thu, 19 Oct 2017 12:09:22 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171019110921.GS20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011082227.20546-2-liuwenliang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 04:22:17PM +0800, Abbott Liu wrote:
> diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> index b2902a5..10cee6a 100644
> --- a/arch/arm/include/asm/pgalloc.h
> +++ b/arch/arm/include/asm/pgalloc.h
> @@ -50,8 +50,11 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
>   */
>  #define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
>  #define pmd_free(mm, pmd)		do { } while (0)
> +#ifndef CONFIG_KASAN
>  #define pud_populate(mm,pmd,pte)	BUG()
> -
> +#else
> +#define pud_populate(mm,pmd,pte)	do { } while (0)
> +#endif

Please explain this change - we don't have a "pud" as far as the rest of
the Linux MM layer is concerned, so why do we need it for kasan?

I suspect it comes from the way we wrap up the page tables - where ARM
does it one way (because it has to) vs the subsequently merged method
which is completely upside down to what ARMs doing, and therefore is
totally incompatible and impossible to fit in with our way.

> diff --git a/arch/arm/include/asm/proc-fns.h b/arch/arm/include/asm/proc-fns.h
> index f2e1af4..6e26714 100644
> --- a/arch/arm/include/asm/proc-fns.h
> +++ b/arch/arm/include/asm/proc-fns.h
> @@ -131,6 +131,15 @@ extern void cpu_resume(void);
>  		pg &= ~(PTRS_PER_PGD*sizeof(pgd_t)-1);	\
>  		(pgd_t *)phys_to_virt(pg);		\
>  	})
> +
> +#define cpu_set_ttbr0(val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcrr	p15, 0, %Q0, %R0, c2"		\
> +			: : "r" (ttbr));	\
> +	} while (0)
> +
> +
>  #else
>  #define cpu_get_pgd()	\
>  	({						\
> @@ -140,6 +149,30 @@ extern void cpu_resume(void);
>  		pg &= ~0x3fff;				\
>  		(pgd_t *)phys_to_virt(pg);		\
>  	})
> +
> +#define cpu_set_ttbr(nr, val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
> +			: : "r" (ttbr));			\
> +	} while (0)
> +
> +#define cpu_get_ttbr(nr)					\
> +	({							\
> +		unsigned long ttbr;				\
> +		__asm__("mrc	p15, 0, %0, c2, c0, 0"		\
> +			: "=r" (ttbr));				\
> +		ttbr;						\
> +	})
> +
> +#define cpu_set_ttbr0(val)					\
> +	do {							\
> +		u64 ttbr = val;					\
> +		__asm__("mcr	p15, 0, %0, c2, c0, 0"		\
> +			: : "r" (ttbr));			\
> +	} while (0)
> +
> +
>  #endif
>  
>  #else	/*!CONFIG_MMU */
> diff --git a/arch/arm/include/asm/thread_info.h b/arch/arm/include/asm/thread_info.h
> index 1d468b5..52c4858 100644
> --- a/arch/arm/include/asm/thread_info.h
> +++ b/arch/arm/include/asm/thread_info.h
> @@ -16,7 +16,11 @@
>  #include <asm/fpstate.h>
>  #include <asm/page.h>
>  
> +#ifdef CONFIG_KASAN
> +#define THREAD_SIZE_ORDER       2
> +#else
>  #define THREAD_SIZE_ORDER	1
> +#endif
>  #define THREAD_SIZE		(PAGE_SIZE << THREAD_SIZE_ORDER)
>  #define THREAD_START_SP		(THREAD_SIZE - 8)
>  
> diff --git a/arch/arm/kernel/head-common.S b/arch/arm/kernel/head-common.S
> index 8733012..c17f4a2 100644
> --- a/arch/arm/kernel/head-common.S
> +++ b/arch/arm/kernel/head-common.S
> @@ -101,7 +101,11 @@ __mmap_switched:
>  	str	r2, [r6]			@ Save atags pointer
>  	cmp	r7, #0
>  	strne	r0, [r7]			@ Save control register values
> +#ifdef CONFIG_KASAN
> +	b	kasan_early_init
> +#else
>  	b	start_kernel
> +#endif
>  ENDPROC(__mmap_switched)
>  
>  	.align	2
> diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
> index 8e9a3e4..985d9a3 100644
> --- a/arch/arm/kernel/setup.c
> +++ b/arch/arm/kernel/setup.c
> @@ -62,6 +62,7 @@
>  #include <asm/unwind.h>
>  #include <asm/memblock.h>
>  #include <asm/virt.h>
> +#include <asm/kasan.h>
>  
>  #include "atags.h"
>  
> @@ -1108,6 +1109,7 @@ void __init setup_arch(char **cmdline_p)
>  	early_ioremap_reset();
>  
>  	paging_init(mdesc);
> +	kasan_init();
>  	request_standard_resources(mdesc);
>  
>  	if (mdesc->restart)
> diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
> index 950d19b..498c316 100644
> --- a/arch/arm/mm/Makefile
> +++ b/arch/arm/mm/Makefile
> @@ -106,4 +106,9 @@ obj-$(CONFIG_CACHE_L2X0)	+= cache-l2x0.o l2c-l2x0-resume.o
>  obj-$(CONFIG_CACHE_L2X0_PMU)	+= cache-l2x0-pmu.o
>  obj-$(CONFIG_CACHE_XSC3L2)	+= cache-xsc3l2.o
>  obj-$(CONFIG_CACHE_TAUROS2)	+= cache-tauros2.o
> +
> +KASAN_SANITIZE_kasan_init.o    := n
> +obj-$(CONFIG_KASAN)            += kasan_init.o

Why is this placed in the middle of the cache object listing?

> +
> +
>  obj-$(CONFIG_CACHE_UNIPHIER)	+= cache-uniphier.o
> diff --git a/arch/arm/mm/kasan_init.c b/arch/arm/mm/kasan_init.c
> new file mode 100644
> index 0000000..2bf0782
> --- /dev/null
> +++ b/arch/arm/mm/kasan_init.c
> @@ -0,0 +1,257 @@
> +#include <linux/bootmem.h>
> +#include <linux/kasan.h>
> +#include <linux/kernel.h>
> +#include <linux/memblock.h>
> +#include <linux/start_kernel.h>
> +
> +#include <asm/cputype.h>
> +#include <asm/highmem.h>
> +#include <asm/mach/map.h>
> +#include <asm/memory.h>
> +#include <asm/page.h>
> +#include <asm/pgalloc.h>
> +#include <asm/pgtable.h>
> +#include <asm/procinfo.h>
> +#include <asm/proc-fns.h>
> +#include <asm/tlbflush.h>
> +#include <asm/cp15.h>
> +#include <linux/sched/task.h>
> +
> +#include "mm.h"
> +
> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(1ULL << 14);
> +
> +pmd_t tmp_pmd_table[PTRS_PER_PMD] __page_aligned_bss;
> +
> +static __init void *kasan_alloc_block(size_t size, int node)
> +{
> +	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
> +					BOOTMEM_ALLOC_ACCESSIBLE, node);
> +}
> +
> +static void __init kasan_early_pmd_populate(unsigned long start, unsigned long end, pud_t *pud)
> +{
> +	unsigned long addr;
> +	unsigned long next;
> +	pmd_t *pmd;
> +
> +	pmd = pmd_offset(pud, start);
> +	for (addr = start; addr < end;) {
> +		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +		next = pmd_addr_end(addr, end);
> +		addr = next;
> +		flush_pmd_entry(pmd);
> +		pmd++;
> +	}
> +}
> +
> +static void __init kasan_early_pud_populate(unsigned long start, unsigned long end, pgd_t *pgd)
> +{
> +	unsigned long addr;
> +	unsigned long next;
> +	pud_t *pud;
> +
> +	pud = pud_offset(pgd, start);
> +	for (addr = start; addr < end;) {
> +		next = pud_addr_end(addr, end);
> +		kasan_early_pmd_populate(addr, next, pud);
> +		addr = next;
> +		pud++;
> +	}
> +}
> +
> +void __init kasan_map_early_shadow(pgd_t *pgdp)
> +{
> +	int i;
> +	unsigned long start = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long addr;
> +	unsigned long next;
> +	pgd_t *pgd;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		set_pte_at(&init_mm, KASAN_SHADOW_START + i*PAGE_SIZE,
> +			&kasan_zero_pte[i], pfn_pte(
> +				virt_to_pfn(kasan_zero_page),
> +				__pgprot(_L_PTE_DEFAULT | L_PTE_DIRTY | L_PTE_XN)));
> +
> +	pgd = pgd_offset_k(start);
> +	for (addr = start; addr < end;) {
> +		next = pgd_addr_end(addr, end);
> +		kasan_early_pud_populate(addr, next, pgd);
> +		addr = next;
> +		pgd++;
> +	}
> +}
> +
> +extern struct proc_info_list *lookup_processor_type(unsigned int);
> +
> +void __init kasan_early_init(void)
> +{
> +	struct proc_info_list *list;
> +
> +	/*
> +	 * locate processor in the list of supported processor
> +	 * types.  The linker builds this table for us from the
> +	 * entries in arch/arm/mm/proc-*.S
> +	 */
> +	list = lookup_processor_type(read_cpuid_id());
> +	if (list) {
> +#ifdef MULTI_CPU
> +		processor = *list->proc;
> +#endif
> +	}
> +
> +	BUILD_BUG_ON(KASAN_SHADOW_OFFSET != KASAN_SHADOW_END - (1UL << 29));
> +
> +
> +	kasan_map_early_shadow(swapper_pg_dir);
> +	start_kernel();
> +}
> +
> +static void __init clear_pgds(unsigned long start,
> +			unsigned long end)
> +{
> +	for (; start && start < end; start += PMD_SIZE)
> +		pmd_clear(pmd_off_k(start));
> +}
> +
> +pte_t * __meminit kasan_pte_populate(pmd_t *pmd, unsigned long addr, int node)
> +{
> +	pte_t *pte = pte_offset_kernel(pmd, addr);
> +	if (pte_none(*pte)) {
> +		pte_t entry;
> +		void *p = kasan_alloc_block(PAGE_SIZE, node);
> +		if (!p)
> +			return NULL;
> +		entry = pfn_pte(virt_to_pfn(p), __pgprot(_L_PTE_DEFAULT | L_PTE_DIRTY | L_PTE_XN));
> +		set_pte_at(&init_mm, addr, pte, entry);
> +	}
> +	return pte;
> +}
> +
> +pmd_t * __meminit kasan_pmd_populate(pud_t *pud, unsigned long addr, int node)
> +{
> +	pmd_t *pmd = pmd_offset(pud, addr);
> +	if (pmd_none(*pmd)) {
> +		void *p = kasan_alloc_block(PAGE_SIZE, node);
> +		if (!p)
> +			return NULL;
> +		pmd_populate_kernel(&init_mm, pmd, p);
> +	}
> +	return pmd;
> +}
> +
> +pud_t * __meminit kasan_pud_populate(pgd_t *pgd, unsigned long addr, int node)
> +{
> +	pud_t *pud = pud_offset(pgd, addr);
> +	if (pud_none(*pud)) {
> +		void *p = kasan_alloc_block(PAGE_SIZE, node);
> +		if (!p)
> +			return NULL;
> +		pr_err("populating pud addr %lx\n", addr);
> +		pud_populate(&init_mm, pud, p);
> +	}
> +	return pud;
> +}
> +
> +pgd_t * __meminit kasan_pgd_populate(unsigned long addr, int node)
> +{
> +	pgd_t *pgd = pgd_offset_k(addr);
> +	if (pgd_none(*pgd)) {
> +		void *p = kasan_alloc_block(PAGE_SIZE, node);
> +		if (!p)
> +			return NULL;
> +		pgd_populate(&init_mm, pgd, p);
> +	}
> +	return pgd;
> +}

This all looks wrong - you are aware that on non-LPAE platforms, there
is only a _two_ level page table - the top level page table is 16K in
size, and each _individual_ lower level page table is actually 1024
bytes, but we do some special handling in the kernel to combine two
together.  It looks to me that you allocate memory for each Linux-
abstracted page table level whether the hardware needs it or not.

Is there any reason why the pre-existing "create_mapping()" function
can't be used, and you've had to rewrite that code here?

> +
> +static int __init create_mapping(unsigned long start, unsigned long end, int node)
> +{
> +	unsigned long addr = start;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;

A blank line would help between the auto variables and the code of the
function.

> +	pr_info("populating shadow for %lx, %lx\n", start, end);

Blank line here too please.

> +	for (; addr < end; addr += PAGE_SIZE) {
> +		pgd = kasan_pgd_populate(addr, node);
> +		if (!pgd)
> +			return -ENOMEM;
> +
> +		pud = kasan_pud_populate(pgd, addr, node);
> +		if (!pud)
> +			return -ENOMEM;
> +
> +		pmd = kasan_pmd_populate(pud, addr, node);
> +		if (!pmd)
> +			return -ENOMEM;
> +
> +		pte = kasan_pte_populate(pmd, addr, node);
> +		if (!pte)
> +			return -ENOMEM;
> +	}
> +	return 0;
> +}
> +
> +
> +void __init kasan_init(void)
> +{
> +	struct memblock_region *reg;
> +	u64 orig_ttbr0;
> +
> +	orig_ttbr0 = cpu_get_ttbr(0);
> +
> +#ifdef CONFIG_ARM_LPAE
> +	memcpy(tmp_pmd_table, pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_START)), sizeof(tmp_pmd_table));
> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
> +	set_pgd(&tmp_page_table[pgd_index(KASAN_SHADOW_START)], __pgd(__pa(tmp_pmd_table) | PMD_TYPE_TABLE | L_PGD_SWAPPER));
> +	cpu_set_ttbr0(__pa(tmp_page_table));
> +#else
> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
> +	cpu_set_ttbr0(__pa(tmp_page_table));
> +#endif
> +	flush_cache_all();
> +	local_flush_bp_all();
> +	local_flush_tlb_all();

What are you trying to achieve with all this complexity?  Some comments
might be useful, especially for those of us who don't know the internals
of kasan.

> +
> +	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
> +
> +	kasan_populate_zero_shadow(
> +		kasan_mem_to_shadow((void *)KASAN_SHADOW_START),
> +		kasan_mem_to_shadow((void *)KASAN_SHADOW_END));
> +
> +	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)VMALLOC_START),
> +				kasan_mem_to_shadow((void *)-1UL) + 1);
> +
> +	for_each_memblock(memory, reg) {
> +		void *start = __va(reg->base);
> +		void *end = __va(reg->base + reg->size);

Isn't this going to complain if the translation macro debugging is enabled?

> +
> +		if (reg->base + reg->size > arm_lowmem_limit)
> +			end = __va(arm_lowmem_limit);
> +		if (start >= end)
> +			break;
> +
> +		create_mapping((unsigned long)kasan_mem_to_shadow(start),
> +			(unsigned long)kasan_mem_to_shadow(end),
> +			NUMA_NO_NODE);
> +	}
> +
> +	/*1.the module's global variable is in MODULES_VADDR ~ MODULES_END,so we need mapping.
> +	  *2.PKMAP_BASE ~ PKMAP_BASE+PMD_SIZE's shadow and MODULES_VADDR ~ MODULES_END's shadow
> +	  *  is in the same PMD_SIZE, so we cant use kasan_populate_zero_shadow.
> +	  *
> +	  **/
> +	create_mapping((unsigned long)kasan_mem_to_shadow((void *)MODULES_VADDR),
> +		(unsigned long)kasan_mem_to_shadow((void *)(PKMAP_BASE+PMD_SIZE)),
> +		NUMA_NO_NODE);
> +	cpu_set_ttbr0(orig_ttbr0);
> +	flush_cache_all();
> +	local_flush_bp_all();
> +	local_flush_tlb_all();
> +	memset(kasan_zero_page, 0, PAGE_SIZE);
> +	pr_info("Kernel address sanitizer initialized\n");
> +	init_task.kasan_depth = 0;
> +}
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 6f319fb..12749da 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -358,7 +358,7 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>  	if (redzone_adjust > 0)
>  		*size += redzone_adjust;
>  
> -	*size = min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
> +	*size = min((size_t)KMALLOC_MAX_SIZE, max(*size, cache->object_size +
>  					optimal_redzone(cache->object_size)));
>  
>  	/*
> -- 
> 2.9.0
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
