Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 189786B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:11:14 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so26070358pdj.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:11:13 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id sg9si15419028pac.108.2015.07.10.10.11.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 10:11:12 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRA00BP87QJVU50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jul 2015 18:11:07 +0100 (BST)
Message-id: <559FFCA7.4060008@samsung.com>
Date: Fri, 10 Jul 2015 20:11:03 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
In-reply-to: <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

>>  	select HAVE_ARCH_KGDB
>>  	select HAVE_ARCH_SECCOMP_FILTER
>>  	select HAVE_ARCH_TRACEHOOK
>> @@ -119,6 +120,12 @@ config GENERIC_CSUM
>>  config GENERIC_CALIBRATE_DELAY
>>  	def_bool y
>>  
>> +config KASAN_SHADOW_OFFSET
>> +	hex
>> +	default 0xdfff200000000000 if ARM64_VA_BITS_48
>> +	default 0xdffffc8000000000 if ARM64_VA_BITS_42
>> +	default 0xdfffff9000000000 if ARM64_VA_BITS_39
>> +
> 
> How were these numbers generated? I can probably guess but we need a
> comment in this file and a BUILD_BUG elsewhere (kasan_init.c) if we
> change the memory map and they no longer match.
> 

Ok, will do.

Probably the simplest way to get this number is:
	KASAN_SHADOW_END - (1ULL << (64 - 3))

64 is number of bits in pointer, 3 is KASAN_SHADOW_SCALE_SHIFT,
so [KASAN_SHADOW_OFFSET, KASAN_SHADOW_END] covers [0, -1ULL] addresses.


>> diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
>> new file mode 100644
>> index 0000000..65ac50d
>> --- /dev/null
>> +++ b/arch/arm64/include/asm/kasan.h
>> @@ -0,0 +1,24 @@
>> +#ifndef __ASM_KASAN_H
>> +#define __ASM_KASAN_H
>> +
>> +#ifndef __ASSEMBLY__
>> +
>> +#ifdef CONFIG_KASAN
>> +
>> +#include <asm/memory.h>
>> +
>> +/*
>> + * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
>> + * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
>> + */
>> +#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
>> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))
> 
> Can you define a VA_START in asm/memory.h so that we avoid this long
> list of f's here and in pgtable.h?
> 

Sure, will do.

> Another BUILD_BUG we need is to ensure that KASAN_SHADOW_START/END
> covers an exact number of pgd entries, otherwise the logic in
> kasan_init.c can go wrong (it seems to be the case in all VA_BITS
> configurations but just in case we forget about this requirement in the
> future).
> 
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index bd5db28..8700f66 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -40,7 +40,14 @@
>>   *	fixed mappings and modules
>>   */
>>  #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
>> +
>> +#ifndef CONFIG_KASAN
>>  #define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
> 
> And here we could just use VA_START.
> 
>> +#else
>> +#include <asm/kasan.h>
>> +#define VMALLOC_START		KASAN_SHADOW_END
>> +#endif
> 
> We could add a SZ_64K guard page here (just in case, the KASan shadow
> probably never reaches KASAN_SHADOW_END).
> 

Ok.

>> diff --git a/arch/arm64/include/asm/string.h b/arch/arm64/include/asm/string.h
>> index 64d2d48..bff522c 100644
>> --- a/arch/arm64/include/asm/string.h
>> +++ b/arch/arm64/include/asm/string.h
>> @@ -36,17 +36,33 @@ extern __kernel_size_t strnlen(const char *, __kernel_size_t);
>>  
>>  #define __HAVE_ARCH_MEMCPY
>>  extern void *memcpy(void *, const void *, __kernel_size_t);
>> +extern void *__memcpy(void *, const void *, __kernel_size_t);
>>  
>>  #define __HAVE_ARCH_MEMMOVE
>>  extern void *memmove(void *, const void *, __kernel_size_t);
>> +extern void *__memmove(void *, const void *, __kernel_size_t);
>>  
>>  #define __HAVE_ARCH_MEMCHR
>>  extern void *memchr(const void *, int, __kernel_size_t);
>>  
>>  #define __HAVE_ARCH_MEMSET
>>  extern void *memset(void *, int, __kernel_size_t);
>> +extern void *__memset(void *, int, __kernel_size_t);
>>  
>>  #define __HAVE_ARCH_MEMCMP
>>  extern int memcmp(const void *, const void *, size_t);
>>  
>> +
>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>> +
>> +/*
>> + * For files that not instrumented (e.g. mm/slub.c) we
> 
> Missing an "are".
> 
>> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
>> index dcd06d1..cfe5ea5 100644
>> --- a/arch/arm64/include/asm/thread_info.h
>> +++ b/arch/arm64/include/asm/thread_info.h
>> @@ -24,10 +24,18 @@
>>  #include <linux/compiler.h>
>>  
>>  #ifndef CONFIG_ARM64_64K_PAGES
>> +#ifndef CONFIG_KASAN
>>  #define THREAD_SIZE_ORDER	2
>> +#else
>> +#define THREAD_SIZE_ORDER	3
>> +#endif
>>  #endif
>>  
>> +#ifndef CONFIG_KASAN
>>  #define THREAD_SIZE		16384
>> +#else
>> +#define THREAD_SIZE		32768
>> +#endif
>>  #define THREAD_START_SP		(THREAD_SIZE - 16)
> 
> Have you actually seen it failing with the 16KB THREAD_SIZE? You may run
> into other problems with 8 4KB pages per stack.
> 

Actually no, so I guess that we could try with 16K.

I've seen it failing on ARM32 with 8K stack (we use some old version of kasan for our ARM kernels),
but that's a different story


>>  #ifndef __ASSEMBLY__
>> diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
>> index 19f915e..650b1e8 100644
>> --- a/arch/arm64/kernel/head.S
>> +++ b/arch/arm64/kernel/head.S
>> @@ -486,6 +486,9 @@ __mmap_switched:
>>  	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
>>  	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
>>  	mov	x29, #0
>> +#ifdef CONFIG_KASAN
>> +	b	kasan_early_init
>> +#endif
>>  	b	start_kernel
>>  ENDPROC(__mmap_switched)
> 
> I think we still have swapper_pg_dir in x26 at this point, could you
> instead do:
> 
> 	mov	x0, x26
> 	bl	kasan_map_early_shadow
> 
> Actually, I don't think kasan_map_early_shadow() even needs this
> argument, it uses pgd_offset_k() anyway.
> 

Indeed, just "bl	kasan_map_early_shadow" would be enough.


>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> new file mode 100644
>> index 0000000..35dbd84
>> --- /dev/null
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -0,0 +1,143 @@
>> +#include <linux/kasan.h>
>> +#include <linux/kernel.h>
>> +#include <linux/memblock.h>
>> +#include <linux/start_kernel.h>
>> +
>> +#include <asm/page.h>
>> +#include <asm/pgalloc.h>
>> +#include <asm/pgtable.h>
>> +#include <asm/tlbflush.h>
>> +
>> +unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
> 
> So that's needed because the shadow memory is mapped before paging_init
> is called and we don't have the zero page set up yet. Please add a
> comment.
> 

Actually this page has two purposes, so naming is bad here.
There was a debate (in kasan for x86_64 thread) about its name, but nobody
come up wit a good name.

So I'll add following comment:

/*
 * This page serves two purposes:
 *   - It used as early shadow memory. The entire shadow region populated with this
 *      page, before we will be able to setup normal shadow memory.
 *   - Latter it reused it as zero shadow to cover large ranges of memory
 *      that allowed to access, but not handled by kasan (vmalloc/vmemmap ...).
 */


>> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
> 
> This doesn't need a full PAGE_SIZE alignment, just PGD_SIZE. You could
> also rename to tmp_pg_dir for consistency with swapper and idmap.
> 

Ok.

>> +
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> +#endif
>> +#if CONFIG_PGTABLE_LEVELS > 2
>> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> +#endif
>> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>> +
>> +static void __init kasan_early_pmd_populate(unsigned long start,
>> +					unsigned long end, pud_t *pud)
>> +{
>> +	unsigned long addr;
>> +	unsigned long next;
>> +	pmd_t *pmd;
>> +
>> +	pmd = pmd_offset(pud, start);
>> +	for (addr = start; addr < end; addr = next, pmd++) {
>> +		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
>> +		next = pmd_addr_end(addr, end);
>> +	}
>> +}
>> +
>> +static void __init kasan_early_pud_populate(unsigned long start,
>> +					unsigned long end, pgd_t *pgd)
>> +{
>> +	unsigned long addr;
>> +	unsigned long next;
>> +	pud_t *pud;
>> +
>> +	pud = pud_offset(pgd, start);
>> +	for (addr = start; addr < end; addr = next, pud++) {
>> +		pud_populate(&init_mm, pud, kasan_zero_pmd);
>> +		next = pud_addr_end(addr, end);
>> +		kasan_early_pmd_populate(addr, next, pud);
>> +	}
>> +}
>> +
>> +static void __init kasan_map_early_shadow(pgd_t *pgdp)
>> +{
>> +	int i;
>> +	unsigned long start = KASAN_SHADOW_START;
>> +	unsigned long end = KASAN_SHADOW_END;
>> +	unsigned long addr;
>> +	unsigned long next;
>> +	pgd_t *pgd;
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>> +		set_pte(&kasan_zero_pte[i], pfn_pte(
>> +				virt_to_pfn(kasan_zero_page), PAGE_KERNEL));
> 
> Does this need to be writable? If yes, is there anything writing
> non-zero values to it?
> 

Yes. Before kasan_init() this needs to be writable for stack instrumentation.
In function's prologue GCC generates some code that writes to shadow marking
redzones around stack variables.

So the page will contain some garbage, however it doesn't matter for early
stage of boot. Kasan will ignore any bad shadow value before kasan_init().

>> +
>> +	pgd = pgd_offset_k(start);
>> +	for (addr = start; addr < end; addr = next, pgd++) {
>> +		pgd_populate(&init_mm, pgd, kasan_zero_pud);
>> +		next = pgd_addr_end(addr, end);
>> +		kasan_early_pud_populate(addr, next, pgd);
>> +	}
> 
> I prefer to use "do ... while" constructs similar to __create_mapping()
> (or zero_{pgd,pud,pmd}_populate as you are more familiar with them).
> 
> But what I don't get here is that you repopulate the pud page for every
> pgd (and so on for pmd). You don't need this recursive call all the way
> to kasan_early_pmd_populate() but just sequential:
> 

This repopulation needed for 3,2 level page tables configurations.

E.g. for 3-level page tables we need to call pud_populate(&init_mm, pud, kasan_zero_pmd)
for each pud in [KASAN_SHADOW_START, KASAN_SHADOW_END] range, this causes repopopulation for 4-level
page tables, since we need to pud_populate() only [KASAN_SHADOW_START, KASAN_SHADOW_START + PGDIR_SIZE] range.

> 	kasan_early_pte_populate();
> 	kasan_early_pmd_populate(..., pte);
> 	kasan_early_pud_populate(..., pmd);
> 	kasan_early_pgd_populate(..., pud);
> 
> (or in reverse order)
> 

Unless, I'm missing something, this will either work only with 4-level page tables.
We could do this without repopulation by using CONFIG_PGTABLE_LEVELS ifdefs.



> That's because you don't have enough pte/pmd/pud pages to cover the
> range (i.e. you need 512 pte pages for a pmd page) but you just reuse
> the same table page to make all of them pointing to kasan_zero_page.
> 
>> +void __init kasan_early_init(void)
>> +{
>> +	kasan_map_early_shadow(swapper_pg_dir);
>> +	start_kernel();
>> +}
>> +
>> +static void __init clear_pgds(unsigned long start,
>> +			unsigned long end)
>> +{
>> +	/*
>> +	 * Remove references to kasan page tables from
>> +	 * swapper_pg_dir. pgd_clear() can't be used
>> +	 * here because it's nop on 2,3-level pagetable setups
>> +	 */
>> +	for (; start && start < end; start += PGDIR_SIZE)
>> +		set_pgd(pgd_offset_k(start), __pgd(0));
>> +}
>> +
>> +static void __init cpu_set_ttbr1(unsigned long ttbr1)
>> +{
>> +	asm(
>> +	"	msr	ttbr1_el1, %0\n"
>> +	"	isb"
>> +	:
>> +	: "r" (ttbr1));
>> +}
>> +
>> +void __init kasan_init(void)
>> +{
>> +	struct memblock_region *reg;
>> +
>> +	/*
>> +	 * We are going to perform proper setup of shadow memory.
>> +	 * At first we should unmap early shadow (clear_pgds() call bellow).
>> +	 * However, instrumented code couldn't execute without shadow memory.
>> +	 * tmp_page_table used to keep early shadow mapped until full shadow
>> +	 * setup will be finished.
>> +	 */
>> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
>> +	cpu_set_ttbr1(__pa(tmp_page_table));
>> +	flush_tlb_all();
>> +
>> +	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
>> +
>> +	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
>> +			kasan_mem_to_shadow((void *)MODULES_VADDR));
>> +
>> +	for_each_memblock(memory, reg) {
>> +		void *start = (void *)__phys_to_virt(reg->base);
>> +		void *end = (void *)__phys_to_virt(reg->base + reg->size);
>> +
>> +		if (start >= end)
>> +			break;
>> +
>> +		/*
>> +		 * end + 1 here is intentional. We check several shadow bytes in
>> +		 * advance to slightly speed up fastpath. In some rare cases
>> +		 * we could cross boundary of mapped shadow, so we just map
>> +		 * some more here.
>> +		 */
>> +		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
>> +				(unsigned long)kasan_mem_to_shadow(end) + 1,
>> +				pfn_to_nid(virt_to_pfn(start)));
> 
> Is the only reason for sparsemem vmemmap dependency to reuse this
> function? Maybe at some point you could factor this out and not require
> SPARSEMEM_VMEMMAP to be enabled.
> 

Yes, this is the only reason and I'll get rid of this dependency some day.

> About the "end + 1", what you actually get is an additional full section
> (PMD_SIZE) with the 4KB page configuration. Since the shadow is 1/8 of
> the VA space, do we need a check for memblocks within 8 * 2MB of each
> other?
> 

Overlaps should be ok. vmemmap_populate will handle it.

>> +	}
>> +
>> +	memset(kasan_zero_page, 0, PAGE_SIZE);
> 
> Has anyone written to this page? Actually, what's its use after we
> enabled the proper KASan shadow mappings?
> 

As said before, in function's prologue GCC generates code that writes to shadow
so it writes to this page.

After kasan_init() this page used as shadow and covers large portions of memory
which are not handled by kasan (vmalloc/vmemmap). We just assume that any access
to this memory region is good.

>> +	cpu_set_ttbr1(__pa(swapper_pg_dir));
>> +	flush_tlb_all();
>> +
>> +	/* At this point kasan is fully initialized. Enable error messages */
>> +	init_task.kasan_depth = 0;
>> +}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
