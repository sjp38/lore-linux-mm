Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4676B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 08:28:54 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so51025763pac.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 05:28:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id pz14si2679656pab.169.2015.04.01.05.28.52
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 05:28:52 -0700 (PDT)
Date: Wed, 1 Apr 2015 13:28:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] arm64: add KASan support
Message-ID: <20150401122843.GA28616@e104818-lin.cambridge.arm.com>
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
 <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Andrey,

On Tue, Mar 24, 2015 at 05:49:04PM +0300, Andrey Ryabinin wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 4085df1..10bbd71 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -41,6 +41,7 @@ config ARM64
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
> +	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
> @@ -116,6 +117,12 @@ config GENERIC_CSUM
>  config GENERIC_CALIBRATE_DELAY
>  	def_bool y
>  
> +config KASAN_SHADOW_OFFSET
> +	hex
> +	default 0xdfff200000000000 if ARM64_VA_BITS_48
> +	default 0xdffffc8000000000 if ARM64_VA_BITS_42
> +	default 0xdfffff9000000000 if ARM64_VA_BITS_39

Can we compute these at build time in some C header? Or they need to be
passed to gcc when compiling the kernel so that it generates the right
instrumentation?

I'm not familiar with KASan but is the offset address supposed to be
accessible? The addresses encoded above would always generate a fault
(level 0 / address size fault).

> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index bd5db28..f5ce010 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -40,7 +40,7 @@
>   *	fixed mappings and modules
>   */
>  #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
> -#define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
> +#define VMALLOC_START		((UL(0xffffffffffffffff) << VA_BITS) + (UL(1) << (VA_BITS - 3)))

I assume that's where you want to make room for KASan? Some comments and
macros would be useful for why this is needed and how it is calculated.
It also needs to be disabled when KASan is not enabled.

> diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
> index 51c9811..1a99e95 100644
> --- a/arch/arm64/kernel/head.S
> +++ b/arch/arm64/kernel/head.S
> @@ -482,6 +482,9 @@ __mmap_switched:
>  	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
>  	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
>  	mov	x29, #0
> +#ifdef CONFIG_KASAN
> +	b kasan_early_init
> +#endif

Nitpick: tab between b and kasan_early_init.

> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> new file mode 100644
> index 0000000..df537da
> --- /dev/null
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -0,0 +1,211 @@
> +#include <linux/kasan.h>
> +#include <linux/kernel.h>
> +#include <linux/memblock.h>
> +#include <linux/start_kernel.h>
> +
> +#include <asm/page.h>
> +#include <asm/pgtable.h>
> +#include <asm/tlbflush.h>
> +
> +static char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;

Can we not use the system's zero_page or it's not initialised yet?

> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 2
> +static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> +#endif
> +static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> +
> +static void __init init_kasan_page_tables(void)
> +{
> +	int i;
> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +	for (i = 0; i < PTRS_PER_PUD; i++)
> +		set_pud(&kasan_zero_pud[i], __pud(__pa(kasan_zero_pmd)
> +							| PAGE_KERNEL));
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 2
> +	for (i = 0; i < PTRS_PER_PMD; i++)
> +		set_pmd(&kasan_zero_pmd[i], __pmd(__pa(kasan_zero_pte)
> +							| PAGE_KERNEL));
> +#endif

These don't look right. You are setting page attributes on table
entries. You should use the standard pmd_populate etc. macros here, see
early_fixmap_init() as an example.

> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		set_pte(&kasan_zero_pte[i], __pte(__pa(kasan_zero_page)
> +							| PAGE_KERNEL));

PAGE_KERNEL is pgprot_t, so you mix the types here. Just do something
like:

	set_pte(..., pfn_pte(zero_pfn, PAGE_KERNEL_RO));

(shouldn't it be read-only?)

> +void __init kasan_map_early_shadow(pgd_t *pgdp)
> +{
> +	int i;
> +	unsigned long start = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	pgd_t pgd;
> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +	pgd = __pgd(__pa(kasan_zero_pud) | PAGE_KERNEL);
> +#elif CONFIG_PGTABLE_LEVELS > 2
> +	pgd = __pgd(__pa(kasan_zero_pmd) | PAGE_KERNEL);
> +#else
> +	pgd = __pgd(__pa(kasan_zero_pte) | PAGE_KERNEL);
> +#endif
> +
> +	for (i = pgd_index(start); start < end; i++) {
> +		set_pgd(&pgdp[i], pgd);
> +		start += PGDIR_SIZE;
> +	}
> +}

Same problem as above with PAGE_KERNEL. You should just use
pgd_populate().

> +
> +void __init kasan_early_init(void)
> +{
> +	init_kasan_page_tables();
> +	kasan_map_early_shadow(swapper_pg_dir);
> +	kasan_map_early_shadow(idmap_pg_dir);
> +	flush_tlb_all();
> +	start_kernel();
> +}

Why do you need to map the kasan page tables into the idmap?

> +
> +static void __init clear_pgds(unsigned long start,
> +			unsigned long end)
> +{
> +	for (; start && start < end; start += PGDIR_SIZE)
> +		set_pgd(pgd_offset_k(start), __pgd(0));
> +}

We have dedicated pgd_clear() macro.

> +
> +static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> +				unsigned long end)
> +{
> +	pte_t *pte = pte_offset_kernel(pmd, addr);
> +
> +	while (addr + PAGE_SIZE <= end) {
> +		set_pte(pte, __pte(__pa(kasan_zero_page)
> +					| PAGE_KERNEL_RO));

See above for a pfn_pte() usage.

> +		addr += PAGE_SIZE;
> +		pte = pte_offset_kernel(pmd, addr);
> +	}
> +	return 0;
> +}
> +
> +static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
> +				unsigned long end)
> +{
> +	int ret = 0;
> +	pmd_t *pmd = pmd_offset(pud, addr);
> +
> +	while (IS_ALIGNED(addr, PMD_SIZE) && addr + PMD_SIZE <= end) {
> +		set_pmd(pmd, __pmd(__pa(kasan_zero_pte)
> +					| PAGE_KERNEL_RO));
> +		addr += PMD_SIZE;
> +		pmd++;
> +	}
> +
> +	if (addr < end) {
> +		if (pmd_none(*pmd)) {
> +			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
> +			if (!p)
> +				return -ENOMEM;
> +			set_pmd(pmd, __pmd(__pa(p) | PAGE_KERNEL));
> +		}
> +		ret = zero_pte_populate(pmd, addr, end);
> +	}
> +	return ret;
> +}
> +
> +static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
> +				unsigned long end)
> +{
> +	int ret = 0;
> +	pud_t *pud = pud_offset(pgd, addr);
> +
> +#if CONFIG_PGTABLE_LEVELS > 2
> +	while (IS_ALIGNED(addr, PUD_SIZE) && addr + PUD_SIZE <= end) {
> +		set_pud(pud, __pud(__pa(kasan_zero_pmd)
> +					| PAGE_KERNEL_RO));
> +		addr += PUD_SIZE;
> +		pud++;
> +	}
> +#endif
> +
> +	if (addr < end) {
> +		if (pud_none(*pud)) {
> +			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
> +			if (!p)
> +				return -ENOMEM;
> +			set_pud(pud, __pud(__pa(p) | PAGE_KERNEL));
> +		}
> +		ret = zero_pmd_populate(pud, addr, end);
> +	}
> +	return ret;
> +}
> +
> +static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
> +{
> +	int ret = 0;
> +	pgd_t *pgd = pgd_offset_k(addr);
> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +	 while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
> +		set_pgd(pgd, __pgd(__pa(kasan_zero_pud)
> +					| PAGE_KERNEL_RO));
> +		addr += PGDIR_SIZE;
> +		pgd++;
> +	}
> +#endif

All these PAGE_KERNEL_RO on table entries are wrong. Please use the
standard pgd/pud/pmd_populate macros.

As for the while loops above, we have a standard way to avoid the
#ifdef's by using pgd_addr_end() etc. See __create_mapping() as an
example, there are a few others throughout the kernel.

> +
> +	 if (addr < end) {
> +		 if (pgd_none(*pgd)) {
> +			 void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
> +			 if (!p)
> +				 return -ENOMEM;
> +			 set_pgd(pgd, __pgd(__pa(p) | PAGE_KERNEL));

I'm just commenting here but it applies to the previous functions. You
may be able to use functions like vmmemap_pgd_populate() which look very
similar (and they also use pgd_populate instead of the set_pgd).

> +static void cpu_set_ttbr1(unsigned long ttbr1)
> +{
> +	asm(
> +	"	msr	ttbr1_el1, %0\n"
> +	"	isb"
> +	:
> +	: "r" (ttbr1));
> +}
> +
> +void __init kasan_init(void)
> +{
> +	struct memblock_region *reg;
> +
> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
> +	cpu_set_ttbr1(__pa(tmp_page_table));

Why is this needed? The code lacks comments in several places but here I
couldn't figure out what the point is.

> +
> +	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
> +
> +	populate_zero_shadow(KASAN_SHADOW_START,
> +			(unsigned long)kasan_mem_to_shadow((void *)MODULES_VADDR));
> +
> +	for_each_memblock(memory, reg) {
> +		void *start = (void *)__phys_to_virt(reg->base);
> +		void *end = (void *)__phys_to_virt(reg->base + reg->size);
> +
> +		if (start >= end)
> +			break;
> +
> +		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
> +				(unsigned long)kasan_mem_to_shadow(end),
> +				pfn_to_nid(virt_to_pfn(start)));
> +	}
> +
> +	memset(kasan_zero_page, 0, PAGE_SIZE);
> +	cpu_set_ttbr1(__pa(swapper_pg_dir));
> +	init_task.kasan_depth = 0;
> +}

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
