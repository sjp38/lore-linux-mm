Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EABB26B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 09:44:41 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so35738894pab.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 06:44:41 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id a4si12084814pdm.207.2015.04.03.06.44.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 03 Apr 2015 06:44:40 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM800C6XH0WK340@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Apr 2015 14:48:32 +0100 (BST)
Message-id: <551E993E.5060801@samsung.com>
Date: Fri, 03 Apr 2015 16:44:30 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
 <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
 <20150401122843.GA28616@e104818-lin.cambridge.arm.com>
In-reply-to: <20150401122843.GA28616@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 04/01/2015 03:28 PM, Catalin Marinas wrote:
> Hi Andrey,
> 

Hi Catalin,

> On Tue, Mar 24, 2015 at 05:49:04PM +0300, Andrey Ryabinin wrote:
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 4085df1..10bbd71 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -41,6 +41,7 @@ config ARM64
>>  	select HAVE_ARCH_AUDITSYSCALL
>>  	select HAVE_ARCH_BITREVERSE
>>  	select HAVE_ARCH_JUMP_LABEL
>> +	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
>>  	select HAVE_ARCH_KGDB
>>  	select HAVE_ARCH_SECCOMP_FILTER
>>  	select HAVE_ARCH_TRACEHOOK
>> @@ -116,6 +117,12 @@ config GENERIC_CSUM
>>  config GENERIC_CALIBRATE_DELAY
>>  	def_bool y
>>  
>> +config KASAN_SHADOW_OFFSET
>> +	hex
>> +	default 0xdfff200000000000 if ARM64_VA_BITS_48
>> +	default 0xdffffc8000000000 if ARM64_VA_BITS_42
>> +	default 0xdfffff9000000000 if ARM64_VA_BITS_39
> 
> Can we compute these at build time in some C header? Or they need to be
> passed to gcc when compiling the kernel so that it generates the right
> instrumentation?
> 

Correct, this value passed to GCC.

> I'm not familiar with KASan but is the offset address supposed to be
> accessible? The addresses encoded above would always generate a fault
> (level 0 / address size fault).
> 

It's fine. KASAN_SHADOW_OFFSET address is shadow address that corresponds to 0 address.
So KASAN_SHADOW_OFFSET could be dereferenced only if we have NULL-ptr derefernce in kernel.

Shadow for kernel addresses starts from KASAN_SHADOW_START constant,
which is defined in arch/arm64/include/asm/kasan.h. But since I forgot to 'git add' that file
it's not present in this patch.

arch/arm64/include/asm/kasan.h:

/*
 * Compiler uses shadow offset assuming that addresses start
 * from 0. Kernel addresses don't start from 0, so shadow
 * for kernel really starts from 'compiler's shadow offset' +
 * ('kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT)
 */
#define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
					((UL(0xffffffffffffffff) << (VA_BITS)) >> 3))

#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (VA_BITS - 3)))


>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index bd5db28..f5ce010 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -40,7 +40,7 @@
>>   *	fixed mappings and modules
>>   */
>>  #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
>> -#define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
>> +#define VMALLOC_START		((UL(0xffffffffffffffff) << VA_BITS) + (UL(1) << (VA_BITS - 3)))
> 
> I assume that's where you want to make room for KASan? Some comments and
> macros would be useful for why this is needed and how it is calculated.
> It also needs to be disabled when KASan is not enabled.
> 

Ok.

>> diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
>> index 51c9811..1a99e95 100644
>> --- a/arch/arm64/kernel/head.S
>> +++ b/arch/arm64/kernel/head.S
>> @@ -482,6 +482,9 @@ __mmap_switched:
>>  	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
>>  	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
>>  	mov	x29, #0
>> +#ifdef CONFIG_KASAN
>> +	b kasan_early_init
>> +#endif
> 
> Nitpick: tab between b and kasan_early_init.
> 
>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> new file mode 100644
>> index 0000000..df537da
>> --- /dev/null
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -0,0 +1,211 @@
>> +#include <linux/kasan.h>
>> +#include <linux/kernel.h>
>> +#include <linux/memblock.h>
>> +#include <linux/start_kernel.h>
>> +
>> +#include <asm/page.h>
>> +#include <asm/pgtable.h>
>> +#include <asm/tlbflush.h>
>> +
>> +static char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
> 
> Can we not use the system's zero_page or it's not initialised yet?
> 

System's zero page allocated in paging_init() and that is too late.
But I could put system's zero page into bss and use it here if you ok with this.


>> +static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
>> +
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> +#endif
>> +#if CONFIG_PGTABLE_LEVELS > 2
>> +static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> +#endif
>> +static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>> +
>> +static void __init init_kasan_page_tables(void)
>> +{
>> +	int i;
>> +
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +	for (i = 0; i < PTRS_PER_PUD; i++)
>> +		set_pud(&kasan_zero_pud[i], __pud(__pa(kasan_zero_pmd)
>> +							| PAGE_KERNEL));
>> +#endif
>> +#if CONFIG_PGTABLE_LEVELS > 2
>> +	for (i = 0; i < PTRS_PER_PMD; i++)
>> +		set_pmd(&kasan_zero_pmd[i], __pmd(__pa(kasan_zero_pte)
>> +							| PAGE_KERNEL));
>> +#endif
> 
> These don't look right. You are setting page attributes on table
> entries. You should use the standard pmd_populate etc. macros here, see
> early_fixmap_init() as an example.
> 

Right. Will fix.

>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>> +		set_pte(&kasan_zero_pte[i], __pte(__pa(kasan_zero_page)
>> +							| PAGE_KERNEL));
> 
> PAGE_KERNEL is pgprot_t, so you mix the types here. Just do something
> like:
> 
> 	set_pte(..., pfn_pte(zero_pfn, PAGE_KERNEL_RO));
> 
> (shouldn't it be read-only?)
> 

It should be read-only, but only after kasan_init().
It should be writable earlier because stack instrumentation writes to shadow memory.
In function's prologue compiler writes to shadow to poison redzones around stack variables.


>> +void __init kasan_map_early_shadow(pgd_t *pgdp)
>> +{
>> +	int i;
>> +	unsigned long start = KASAN_SHADOW_START;
>> +	unsigned long end = KASAN_SHADOW_END;
>> +	pgd_t pgd;
>> +
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +	pgd = __pgd(__pa(kasan_zero_pud) | PAGE_KERNEL);
>> +#elif CONFIG_PGTABLE_LEVELS > 2
>> +	pgd = __pgd(__pa(kasan_zero_pmd) | PAGE_KERNEL);
>> +#else
>> +	pgd = __pgd(__pa(kasan_zero_pte) | PAGE_KERNEL);
>> +#endif
>> +
>> +	for (i = pgd_index(start); start < end; i++) {
>> +		set_pgd(&pgdp[i], pgd);
>> +		start += PGDIR_SIZE;
>> +	}
>> +}
> 
> Same problem as above with PAGE_KERNEL. You should just use
> pgd_populate().
> 

Ok

>> +
>> +void __init kasan_early_init(void)
>> +{
>> +	init_kasan_page_tables();
>> +	kasan_map_early_shadow(swapper_pg_dir);
>> +	kasan_map_early_shadow(idmap_pg_dir);
>> +	flush_tlb_all();
>> +	start_kernel();
>> +}
> 
> Why do you need to map the kasan page tables into the idmap?
> 

I don't need it. This is some left-over that should be removed.

>> +
>> +static void __init clear_pgds(unsigned long start,
>> +			unsigned long end)
>> +{
>> +	for (; start && start < end; start += PGDIR_SIZE)
>> +		set_pgd(pgd_offset_k(start), __pgd(0));
>> +}
> 
> We have dedicated pgd_clear() macro.
> 

I need to remove references to kasan_zero_p* tables from swapper_pg_dir so
pgd_clear() will not work here because it's noop on CONFIG_PGTABLE_LEVEL <= 3.


[...]

>> +static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
>> +{
>> +	int ret = 0;
>> +	pgd_t *pgd = pgd_offset_k(addr);
>> +
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +	 while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
>> +		set_pgd(pgd, __pgd(__pa(kasan_zero_pud)
>> +					| PAGE_KERNEL_RO));
>> +		addr += PGDIR_SIZE;
>> +		pgd++;
>> +	}
>> +#endif
> 
> All these PAGE_KERNEL_RO on table entries are wrong. Please use the
> standard pgd/pud/pmd_populate macros.
> 
> As for the while loops above, we have a standard way to avoid the
> #ifdef's by using pgd_addr_end() etc. See __create_mapping() as an
> example, there are a few others throughout the kernel.
> 

Ok.

[...]

>> +static void cpu_set_ttbr1(unsigned long ttbr1)
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
>> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
>> +	cpu_set_ttbr1(__pa(tmp_page_table));
> 
> Why is this needed? The code lacks comments in several places but here I
> couldn't figure out what the point is.
> 

To setup shadow memory properly we need to unmap early shadow first (clear_pgds() in next line).

But instrumented kernel cannot run with unmaped shadow so this temporary
page table with early shadow until setting up shadow in swapper_pg_dir
will be finished.
I'll add comment about this here.


>> +
>> +	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
>> +
>> +	populate_zero_shadow(KASAN_SHADOW_START,
>> +			(unsigned long)kasan_mem_to_shadow((void *)MODULES_VADDR));
>> +
>> +	for_each_memblock(memory, reg) {
>> +		void *start = (void *)__phys_to_virt(reg->base);
>> +		void *end = (void *)__phys_to_virt(reg->base + reg->size);
>> +
>> +		if (start >= end)
>> +			break;
>> +
>> +		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
>> +				(unsigned long)kasan_mem_to_shadow(end),
>> +				pfn_to_nid(virt_to_pfn(start)));
>> +	}
>> +
>> +	memset(kasan_zero_page, 0, PAGE_SIZE);
>> +	cpu_set_ttbr1(__pa(swapper_pg_dir));
>> +	init_task.kasan_depth = 0;
>> +}
> 

Thank you for detailed review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
