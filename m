Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id B4C066B0254
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 11:48:10 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so166099879qkh.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 08:48:10 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w53si3443301qge.4.2015.07.08.08.48.09
        for <linux-mm@kvack.org>;
        Wed, 08 Jul 2015 08:48:09 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:48:04 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
Message-ID: <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 15, 2015 at 04:59:04PM +0300, Andrey Ryabinin wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 7796af4..4cc73cc 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -44,6 +44,7 @@ config ARM64
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
> +	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP

Just curious, why the dependency?

>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
> @@ -119,6 +120,12 @@ config GENERIC_CSUM
>  config GENERIC_CALIBRATE_DELAY
>  	def_bool y
>  
> +config KASAN_SHADOW_OFFSET
> +	hex
> +	default 0xdfff200000000000 if ARM64_VA_BITS_48
> +	default 0xdffffc8000000000 if ARM64_VA_BITS_42
> +	default 0xdfffff9000000000 if ARM64_VA_BITS_39
> +

How were these numbers generated? I can probably guess but we need a
comment in this file and a BUILD_BUG elsewhere (kasan_init.c) if we
change the memory map and they no longer match.

> diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
> new file mode 100644
> index 0000000..65ac50d
> --- /dev/null
> +++ b/arch/arm64/include/asm/kasan.h
> @@ -0,0 +1,24 @@
> +#ifndef __ASM_KASAN_H
> +#define __ASM_KASAN_H
> +
> +#ifndef __ASSEMBLY__
> +
> +#ifdef CONFIG_KASAN
> +
> +#include <asm/memory.h>
> +
> +/*
> + * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
> + * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
> + */
> +#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))

Can you define a VA_START in asm/memory.h so that we avoid this long
list of f's here and in pgtable.h?

Another BUILD_BUG we need is to ensure that KASAN_SHADOW_START/END
covers an exact number of pgd entries, otherwise the logic in
kasan_init.c can go wrong (it seems to be the case in all VA_BITS
configurations but just in case we forget about this requirement in the
future).

> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index bd5db28..8700f66 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -40,7 +40,14 @@
>   *	fixed mappings and modules
>   */
>  #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
> +
> +#ifndef CONFIG_KASAN
>  #define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)

And here we could just use VA_START.

> +#else
> +#include <asm/kasan.h>
> +#define VMALLOC_START		KASAN_SHADOW_END
> +#endif

We could add a SZ_64K guard page here (just in case, the KASan shadow
probably never reaches KASAN_SHADOW_END).

> diff --git a/arch/arm64/include/asm/string.h b/arch/arm64/include/asm/string.h
> index 64d2d48..bff522c 100644
> --- a/arch/arm64/include/asm/string.h
> +++ b/arch/arm64/include/asm/string.h
> @@ -36,17 +36,33 @@ extern __kernel_size_t strnlen(const char *, __kernel_size_t);
>  
>  #define __HAVE_ARCH_MEMCPY
>  extern void *memcpy(void *, const void *, __kernel_size_t);
> +extern void *__memcpy(void *, const void *, __kernel_size_t);
>  
>  #define __HAVE_ARCH_MEMMOVE
>  extern void *memmove(void *, const void *, __kernel_size_t);
> +extern void *__memmove(void *, const void *, __kernel_size_t);
>  
>  #define __HAVE_ARCH_MEMCHR
>  extern void *memchr(const void *, int, __kernel_size_t);
>  
>  #define __HAVE_ARCH_MEMSET
>  extern void *memset(void *, int, __kernel_size_t);
> +extern void *__memset(void *, int, __kernel_size_t);
>  
>  #define __HAVE_ARCH_MEMCMP
>  extern int memcmp(const void *, const void *, size_t);
>  
> +
> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
> +
> +/*
> + * For files that not instrumented (e.g. mm/slub.c) we

Missing an "are".

> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
> index dcd06d1..cfe5ea5 100644
> --- a/arch/arm64/include/asm/thread_info.h
> +++ b/arch/arm64/include/asm/thread_info.h
> @@ -24,10 +24,18 @@
>  #include <linux/compiler.h>
>  
>  #ifndef CONFIG_ARM64_64K_PAGES
> +#ifndef CONFIG_KASAN
>  #define THREAD_SIZE_ORDER	2
> +#else
> +#define THREAD_SIZE_ORDER	3
> +#endif
>  #endif
>  
> +#ifndef CONFIG_KASAN
>  #define THREAD_SIZE		16384
> +#else
> +#define THREAD_SIZE		32768
> +#endif
>  #define THREAD_START_SP		(THREAD_SIZE - 16)

Have you actually seen it failing with the 16KB THREAD_SIZE? You may run
into other problems with 8 4KB pages per stack.

>  #ifndef __ASSEMBLY__
> diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
> index 19f915e..650b1e8 100644
> --- a/arch/arm64/kernel/head.S
> +++ b/arch/arm64/kernel/head.S
> @@ -486,6 +486,9 @@ __mmap_switched:
>  	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
>  	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
>  	mov	x29, #0
> +#ifdef CONFIG_KASAN
> +	b	kasan_early_init
> +#endif
>  	b	start_kernel
>  ENDPROC(__mmap_switched)

I think we still have swapper_pg_dir in x26 at this point, could you
instead do:

	mov	x0, x26
	bl	kasan_map_early_shadow

Actually, I don't think kasan_map_early_shadow() even needs this
argument, it uses pgd_offset_k() anyway.

> diff --git a/arch/arm64/lib/memcpy.S b/arch/arm64/lib/memcpy.S
> index 8a9a96d..845e40a 100644
> --- a/arch/arm64/lib/memcpy.S
> +++ b/arch/arm64/lib/memcpy.S
> @@ -56,6 +56,8 @@ C_h	.req	x12
>  D_l	.req	x13
>  D_h	.req	x14
>  
> +.weak memcpy

Nitpick: as with other such asm declarations, use some indentation:

	.weak	memcpy

(similarly for the others)

> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
> index 773d37a..e17703c 100644
> --- a/arch/arm64/mm/Makefile
> +++ b/arch/arm64/mm/Makefile
> @@ -4,3 +4,6 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
>  				   context.o proc.o pageattr.o
>  obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
>  obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
> +
> +KASAN_SANITIZE_kasan_init.o	:= n
> +obj-$(CONFIG_KASAN)		+= kasan_init.o
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> new file mode 100644
> index 0000000..35dbd84
> --- /dev/null
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -0,0 +1,143 @@
> +#include <linux/kasan.h>
> +#include <linux/kernel.h>
> +#include <linux/memblock.h>
> +#include <linux/start_kernel.h>
> +
> +#include <asm/page.h>
> +#include <asm/pgalloc.h>
> +#include <asm/pgtable.h>
> +#include <asm/tlbflush.h>
> +
> +unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;

So that's needed because the shadow memory is mapped before paging_init
is called and we don't have the zero page set up yet. Please add a
comment.

> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);

This doesn't need a full PAGE_SIZE alignment, just PGD_SIZE. You could
also rename to tmp_pg_dir for consistency with swapper and idmap.

> +
> +#if CONFIG_PGTABLE_LEVELS > 3
> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 2
> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> +#endif
> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> +
> +static void __init kasan_early_pmd_populate(unsigned long start,
> +					unsigned long end, pud_t *pud)
> +{
> +	unsigned long addr;
> +	unsigned long next;
> +	pmd_t *pmd;
> +
> +	pmd = pmd_offset(pud, start);
> +	for (addr = start; addr < end; addr = next, pmd++) {
> +		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +		next = pmd_addr_end(addr, end);
> +	}
> +}
> +
> +static void __init kasan_early_pud_populate(unsigned long start,
> +					unsigned long end, pgd_t *pgd)
> +{
> +	unsigned long addr;
> +	unsigned long next;
> +	pud_t *pud;
> +
> +	pud = pud_offset(pgd, start);
> +	for (addr = start; addr < end; addr = next, pud++) {
> +		pud_populate(&init_mm, pud, kasan_zero_pmd);
> +		next = pud_addr_end(addr, end);
> +		kasan_early_pmd_populate(addr, next, pud);
> +	}
> +}
> +
> +static void __init kasan_map_early_shadow(pgd_t *pgdp)
> +{
> +	int i;
> +	unsigned long start = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long addr;
> +	unsigned long next;
> +	pgd_t *pgd;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		set_pte(&kasan_zero_pte[i], pfn_pte(
> +				virt_to_pfn(kasan_zero_page), PAGE_KERNEL));

Does this need to be writable? If yes, is there anything writing
non-zero values to it?

> +
> +	pgd = pgd_offset_k(start);
> +	for (addr = start; addr < end; addr = next, pgd++) {
> +		pgd_populate(&init_mm, pgd, kasan_zero_pud);
> +		next = pgd_addr_end(addr, end);
> +		kasan_early_pud_populate(addr, next, pgd);
> +	}

I prefer to use "do ... while" constructs similar to __create_mapping()
(or zero_{pgd,pud,pmd}_populate as you are more familiar with them).

But what I don't get here is that you repopulate the pud page for every
pgd (and so on for pmd). You don't need this recursive call all the way
to kasan_early_pmd_populate() but just sequential:

	kasan_early_pte_populate();
	kasan_early_pmd_populate(..., pte);
	kasan_early_pud_populate(..., pmd);
	kasan_early_pgd_populate(..., pud);

(or in reverse order)

That's because you don't have enough pte/pmd/pud pages to cover the
range (i.e. you need 512 pte pages for a pmd page) but you just reuse
the same table page to make all of them pointing to kasan_zero_page.

> +void __init kasan_early_init(void)
> +{
> +	kasan_map_early_shadow(swapper_pg_dir);
> +	start_kernel();
> +}
> +
> +static void __init clear_pgds(unsigned long start,
> +			unsigned long end)
> +{
> +	/*
> +	 * Remove references to kasan page tables from
> +	 * swapper_pg_dir. pgd_clear() can't be used
> +	 * here because it's nop on 2,3-level pagetable setups
> +	 */
> +	for (; start && start < end; start += PGDIR_SIZE)
> +		set_pgd(pgd_offset_k(start), __pgd(0));
> +}
> +
> +static void __init cpu_set_ttbr1(unsigned long ttbr1)
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
> +	/*
> +	 * We are going to perform proper setup of shadow memory.
> +	 * At first we should unmap early shadow (clear_pgds() call bellow).
> +	 * However, instrumented code couldn't execute without shadow memory.
> +	 * tmp_page_table used to keep early shadow mapped until full shadow
> +	 * setup will be finished.
> +	 */
> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
> +	cpu_set_ttbr1(__pa(tmp_page_table));
> +	flush_tlb_all();
> +
> +	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
> +
> +	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
> +			kasan_mem_to_shadow((void *)MODULES_VADDR));
> +
> +	for_each_memblock(memory, reg) {
> +		void *start = (void *)__phys_to_virt(reg->base);
> +		void *end = (void *)__phys_to_virt(reg->base + reg->size);
> +
> +		if (start >= end)
> +			break;
> +
> +		/*
> +		 * end + 1 here is intentional. We check several shadow bytes in
> +		 * advance to slightly speed up fastpath. In some rare cases
> +		 * we could cross boundary of mapped shadow, so we just map
> +		 * some more here.
> +		 */
> +		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
> +				(unsigned long)kasan_mem_to_shadow(end) + 1,
> +				pfn_to_nid(virt_to_pfn(start)));

Is the only reason for sparsemem vmemmap dependency to reuse this
function? Maybe at some point you could factor this out and not require
SPARSEMEM_VMEMMAP to be enabled.

About the "end + 1", what you actually get is an additional full section
(PMD_SIZE) with the 4KB page configuration. Since the shadow is 1/8 of
the VA space, do we need a check for memblocks within 8 * 2MB of each
other?

> +	}
> +
> +	memset(kasan_zero_page, 0, PAGE_SIZE);

Has anyone written to this page? Actually, what's its use after we
enabled the proper KASan shadow mappings?

> +	cpu_set_ttbr1(__pa(swapper_pg_dir));
> +	flush_tlb_all();
> +
> +	/* At this point kasan is fully initialized. Enable error messages */
> +	init_task.kasan_depth = 0;
> +}

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
