Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B52466B0309
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:09:15 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so116607035qkd.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:09:15 -0800 (PST)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id v85si19938798qka.130.2016.11.15.16.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:09:14 -0800 (PST)
Received: by mail-qk0-f178.google.com with SMTP id n204so156024461qke.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:09:14 -0800 (PST)
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade>
 <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
 <20161103155106.GF25852@remoulade>
 <20161114181937.GG3096@e104818-lin.cambridge.arm.com>
 <06569a6b-3846-5e18-28c1-7c16a9697663@redhat.com>
 <20161115183508.GJ3096@e104818-lin.cambridge.arm.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <95d1f7bb-d451-3b0a-1a32-957a24023a49@redhat.com>
Date: Tue, 15 Nov 2016 16:09:07 -0800
MIME-Version: 1.0
In-Reply-To: <20161115183508.GJ3096@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 11/15/2016 10:35 AM, Catalin Marinas wrote:
> On Mon, Nov 14, 2016 at 10:41:29AM -0800, Laura Abbott wrote:
>> On 11/14/2016 10:19 AM, Catalin Marinas wrote:
>>> On Thu, Nov 03, 2016 at 03:51:07PM +0000, Mark Rutland wrote:
>>>> On Wed, Nov 02, 2016 at 05:56:42PM -0600, Laura Abbott wrote:
>>>>> On 11/02/2016 04:52 PM, Mark Rutland wrote:
>>>>>> On Wed, Nov 02, 2016 at 03:00:53PM -0600, Laura Abbott wrote:
>>>>>>>
>>>>>>> __pa_symbol is technically the marco that should be used for kernel
>>>>>>> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.
>>>>>>
>>>>>> Nit: s/marco/macro/
>>>>>>
>>>>>> I see there are some other uses of __pa() that look like they could/should be
>>>>>> __pa_symbol(), e.g. in mark_rodata_ro().
>>>>>>
>>>>>> I guess strictly speaking those need to be updated to? Or is there a reason
>>>>>> that we should not?
>>>>>
>>>>> If the concept of __pa_symbol is okay then yes I think all uses of __pa
>>>>> should eventually be converted for consistency and debugging.
>>>>
>>>> I have no strong feelings either way about __pa_symbol(); I'm not clear on what
>>>> the purpose of __pa_symbol() is specifically, but I'm happy even if it's just
>>>> for consistency with other architectures.
>>>
>>> At a quick grep, it seems to only be used by mips and x86 and a single
>>> place in mm/memblock.c.
>>>
>>> Since we haven't seen any issues on arm/arm64 without this macro, can we
>>> not just continue to use __pa()?
>>
>> Technically yes but if it's introduced it may be confusing why it's being
>> used some places but not others.
> 
> As it currently stands, your patches introduce the first and only use of
> __pa_symbol to arch/arm64. But I don't see the point, unless we replace
> all of the other uses.
>  
>> Maybe the bounds in the debug virtual check should just be adjusted so
>> we don't need __pa_symbol along with a nice fat comment explaining
>> why. 
> 
> I'm fine with __pa_symbol use entirely from under arch/arm64. But if you
> want to use __pa_symbol, I tried to change most (all?) places where
> necessary, together with making virt_to_phys() only deal with the kernel
> linear mapping. Not sure it looks cleaner, especially the
> __va(__pa_symbol()) cases (we could replace the latter with another
> macro and proper comment):
> 

I agree everything should be converted over, I was considering doing
that in a separate patch but this covers everything nicely. Are you
okay with me folding this in? (Few comments below)

> -------------8<--------------------------------------
> diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
> index a79b969c26fc..fa6c44ebb51f 100644
> --- a/arch/arm64/include/asm/kvm_mmu.h
> +++ b/arch/arm64/include/asm/kvm_mmu.h
> @@ -47,7 +47,7 @@
>   * If the page is in the bottom half, we have to use the top half. If
>   * the page is in the top half, we have to use the bottom half:
>   *
> - * T = __virt_to_phys(__hyp_idmap_text_start)
> + * T = __pa_symbol(__hyp_idmap_text_start)
>   * if (T & BIT(VA_BITS - 1))
>   *	HYP_VA_MIN = 0  //idmap in upper half
>   * else
> @@ -271,7 +271,7 @@ static inline void __kvm_flush_dcache_pud(pud_t pud)
>  	kvm_flush_dcache_to_poc(page_address(page), PUD_SIZE);
>  }
>  
> -#define kvm_virt_to_phys(x)		__virt_to_phys((unsigned long)(x))
> +#define kvm_virt_to_phys(x)		__pa_symbol((unsigned long)(x))
>  
>  void kvm_set_way_flush(struct kvm_vcpu *vcpu);
>  void kvm_toggle_cache(struct kvm_vcpu *vcpu, bool was_enabled);
> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> index eac3dbb7e313..e02f45e5ee1b 100644
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -169,15 +169,22 @@ extern u64			kimage_voffset;
>   */
>  #define __virt_to_phys_nodebug(x) ({					\
>  	phys_addr_t __x = (phys_addr_t)(x);				\
> -	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
> -				 (__x - kimage_voffset); })
> +	VM_BUG_ON(!(__x & BIT(VA_BITS - 1)));				\
> +	((__x & ~PAGE_OFFSET) + PHYS_OFFSET);				\
> +})

I do think this is easier to understand vs the ternary operator.
I'll add a comment detailing the use of __pa vs __pa_symbol somewhere
as well.

> +
> +#define __pa_symbol_nodebug(x) ({					\
> +	phys_addr_t __x = (phys_addr_t)(x);				\
> +	VM_BUG_ON(__x & BIT(VA_BITS - 1));				\
> +	(__x - kimage_voffset);						\
> +})
>  
>  #ifdef CONFIG_DEBUG_VIRTUAL
>  extern unsigned long __virt_to_phys(unsigned long x);
>  extern unsigned long __phys_addr_symbol(unsigned long x);
>  #else
>  #define __virt_to_phys(x)	__virt_to_phys_nodebug(x)
> -#define __phys_addr_symbol	__pa
> +#define __phys_addr_symbol(x)	__pa_symbol_nodebug(x)
>  #endif
>  
>  #define __phys_to_virt(x)	((unsigned long)((x) - PHYS_OFFSET) | PAGE_OFFSET)
> @@ -210,7 +217,7 @@ static inline void *phys_to_virt(phys_addr_t x)
>   * Drivers should NOT use these either.
>   */
>  #define __pa(x)			__virt_to_phys((unsigned long)(x))
> -#define __pa_symbol(x)  __phys_addr_symbol(RELOC_HIDE((unsigned long)(x), 0))
> +#define __pa_symbol(x)		__phys_addr_symbol(RELOC_HIDE((unsigned long)(x), 0))
>  #define __pa_nodebug(x)		__virt_to_phys_nodebug((unsigned long)(x))
>  #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
>  #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
> diff --git a/arch/arm64/include/asm/mmu_context.h b/arch/arm64/include/asm/mmu_context.h
> index a50185375f09..6cf3763c6e11 100644
> --- a/arch/arm64/include/asm/mmu_context.h
> +++ b/arch/arm64/include/asm/mmu_context.h
> @@ -44,7 +44,7 @@ static inline void contextidr_thread_switch(struct task_struct *next)
>   */
>  static inline void cpu_set_reserved_ttbr0(void)
>  {
> -	unsigned long ttbr = virt_to_phys(empty_zero_page);
> +	unsigned long ttbr = __pa_symbol(empty_zero_page);
>  
>  	write_sysreg(ttbr, ttbr0_el1);
>  	isb();
> @@ -113,7 +113,7 @@ static inline void cpu_install_idmap(void)
>  	local_flush_tlb_all();
>  	cpu_set_idmap_tcr_t0sz();
>  
> -	cpu_switch_mm(idmap_pg_dir, &init_mm);
> +	cpu_switch_mm(__va(__pa_symbol(idmap_pg_dir)), &init_mm);

Yes, the __va(__pa_symbol(..)) idiom needs to be macroized and commented...

>  }
>  
>  /*
> @@ -128,7 +128,7 @@ static inline void cpu_replace_ttbr1(pgd_t *pgd)
>  
>  	phys_addr_t pgd_phys = virt_to_phys(pgd);
>  
> -	replace_phys = (void *)virt_to_phys(idmap_cpu_replace_ttbr1);
> +	replace_phys = (void *)__pa_symbol(idmap_cpu_replace_ttbr1);
>  
>  	cpu_install_idmap();
>  	replace_phys(pgd_phys);
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index ffbb9a520563..c2041a39a3e3 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -52,7 +52,7 @@ extern void __pgd_error(const char *file, int line, unsigned long val);
>   * for zero-mapped memory areas etc..
>   */
>  extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
> -#define ZERO_PAGE(vaddr)	pfn_to_page(PHYS_PFN(__pa(empty_zero_page)))
> +#define ZERO_PAGE(vaddr)	pfn_to_page(PHYS_PFN(__pa_symbol(empty_zero_page)))
>  
>  #define pte_ERROR(pte)		__pte_error(__FILE__, __LINE__, pte_val(pte))
>  
> diff --git a/arch/arm64/kernel/acpi_parking_protocol.c b/arch/arm64/kernel/acpi_parking_protocol.c
> index a32b4011d711..df58310660c6 100644
> --- a/arch/arm64/kernel/acpi_parking_protocol.c
> +++ b/arch/arm64/kernel/acpi_parking_protocol.c
> @@ -109,7 +109,7 @@ static int acpi_parking_protocol_cpu_boot(unsigned int cpu)
>  	 * that read this address need to convert this address to the
>  	 * Boot-Loader's endianness before jumping.
>  	 */
> -	writeq_relaxed(__pa(secondary_entry), &mailbox->entry_point);
> +	writeq_relaxed(__pa_symbol(secondary_entry), &mailbox->entry_point);
>  	writel_relaxed(cpu_entry->gic_cpu_id, &mailbox->cpu_id);
>  
>  	arch_send_wakeup_ipi_mask(cpumask_of(cpu));
> diff --git a/arch/arm64/kernel/cpufeature.c b/arch/arm64/kernel/cpufeature.c
> index c02504ea304b..6ccadf255fba 100644
> --- a/arch/arm64/kernel/cpufeature.c
> +++ b/arch/arm64/kernel/cpufeature.c
> @@ -736,7 +736,7 @@ static bool runs_at_el2(const struct arm64_cpu_capabilities *entry, int __unused
>  static bool hyp_offset_low(const struct arm64_cpu_capabilities *entry,
>  			   int __unused)
>  {
> -	phys_addr_t idmap_addr = virt_to_phys(__hyp_idmap_text_start);
> +	phys_addr_t idmap_addr = __pa_symbol(__hyp_idmap_text_start);
>  
>  	/*
>  	 * Activate the lower HYP offset only if:
> diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> index d55a7b09959b..81c03c74e5fe 100644
> --- a/arch/arm64/kernel/hibernate.c
> +++ b/arch/arm64/kernel/hibernate.c
> @@ -51,7 +51,7 @@
>  extern int in_suspend;
>  
>  /* Find a symbols alias in the linear map */
> -#define LMADDR(x)	phys_to_virt(virt_to_phys(x))
> +#define LMADDR(x)	__va(__pa_symbol(x))

...Perhaps just borrowing this macro?

>  
>  /* Do we need to reset el2? */
>  #define el2_reset_needed() (is_hyp_mode_available() && !is_kernel_in_hyp_mode())
> @@ -125,12 +125,12 @@ int arch_hibernation_header_save(void *addr, unsigned int max_size)
>  		return -EOVERFLOW;
>  
>  	arch_hdr_invariants(&hdr->invariants);
> -	hdr->ttbr1_el1		= virt_to_phys(swapper_pg_dir);
> +	hdr->ttbr1_el1		= __pa_symbol(swapper_pg_dir);
>  	hdr->reenter_kernel	= _cpu_resume;
>  
>  	/* We can't use __hyp_get_vectors() because kvm may still be loaded */
>  	if (el2_reset_needed())
> -		hdr->__hyp_stub_vectors = virt_to_phys(__hyp_stub_vectors);
> +		hdr->__hyp_stub_vectors = __pa_symbol(__hyp_stub_vectors);
>  	else
>  		hdr->__hyp_stub_vectors = 0;
>  
> diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> index 6f2ac4fc66ca..af8967a0343b 100644
> --- a/arch/arm64/kernel/insn.c
> +++ b/arch/arm64/kernel/insn.c
> @@ -97,7 +97,7 @@ static void __kprobes *patch_map(void *addr, int fixmap)
>  	if (module && IS_ENABLED(CONFIG_DEBUG_SET_MODULE_RONX))
>  		page = vmalloc_to_page(addr);
>  	else if (!module)
> -		page = pfn_to_page(PHYS_PFN(__pa(addr)));
> +		page = pfn_to_page(PHYS_PFN(__pa_symbol(addr)));
>  	else
>  		return addr;
>  
> diff --git a/arch/arm64/kernel/psci.c b/arch/arm64/kernel/psci.c
> index 42816bebb1e0..f0f2abb72cf9 100644
> --- a/arch/arm64/kernel/psci.c
> +++ b/arch/arm64/kernel/psci.c
> @@ -45,7 +45,7 @@ static int __init cpu_psci_cpu_prepare(unsigned int cpu)
>  
>  static int cpu_psci_cpu_boot(unsigned int cpu)
>  {
> -	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa(secondary_entry));
> +	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa_symbol(secondary_entry));
>  	if (err)
>  		pr_err("failed to boot CPU%d (%d)\n", cpu, err);
>  
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index f534f492a268..e2dbc02f4792 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -199,10 +199,10 @@ static void __init request_standard_resources(void)
>  	struct memblock_region *region;
>  	struct resource *res;
>  
> -	kernel_code.start   = virt_to_phys(_text);
> -	kernel_code.end     = virt_to_phys(__init_begin - 1);
> -	kernel_data.start   = virt_to_phys(_sdata);
> -	kernel_data.end     = virt_to_phys(_end - 1);
> +	kernel_code.start   = __pa_symbol(_text);
> +	kernel_code.end     = __pa_symbol(__init_begin - 1);
> +	kernel_data.start   = __pa_symbol(_sdata);
> +	kernel_data.end     = __pa_symbol(_end - 1);
>  
>  	for_each_memblock(memory, region) {
>  		res = alloc_bootmem_low(sizeof(*res));
> diff --git a/arch/arm64/kernel/smp_spin_table.c b/arch/arm64/kernel/smp_spin_table.c
> index 9a00eee9acc8..25fcccaf79b8 100644
> --- a/arch/arm64/kernel/smp_spin_table.c
> +++ b/arch/arm64/kernel/smp_spin_table.c
> @@ -98,7 +98,7 @@ static int smp_spin_table_cpu_prepare(unsigned int cpu)
>  	 * boot-loader's endianess before jumping. This is mandated by
>  	 * the boot protocol.
>  	 */
> -	writeq_relaxed(__pa(secondary_holding_pen), release_addr);
> +	writeq_relaxed(__pa_symbol(secondary_holding_pen), release_addr);
>  	__flush_dcache_area((__force void *)release_addr,
>  			    sizeof(*release_addr));
>  
> diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
> index a2c2478e7d78..791e87a99148 100644
> --- a/arch/arm64/kernel/vdso.c
> +++ b/arch/arm64/kernel/vdso.c
> @@ -140,11 +140,11 @@ static int __init vdso_init(void)
>  		return -ENOMEM;
>  
>  	/* Grab the vDSO data page. */
> -	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa(vdso_data)));
> +	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa_symbol(vdso_data)));
>  
>  	/* Grab the vDSO code pages. */
>  	for (i = 0; i < vdso_pages; i++)
> -		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
> +		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa_symbol(&vdso_start)) + i);
>  
>  	vdso_spec[0].pages = &vdso_pagelist[0];
>  	vdso_spec[1].pages = &vdso_pagelist[1];
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 3236eb062444..14f426fea61b 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -225,7 +225,7 @@ void __init arm64_memblock_init(void)
>  	 */
>  	if (memory_limit != (phys_addr_t)ULLONG_MAX) {
>  		memblock_mem_limit_remove_map(memory_limit);
> -		memblock_add(__pa(_text), (u64)(_end - _text));
> +		memblock_add(__pa_symbol(_text), (u64)(_end - _text));
>  	}
>  
>  	if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
> @@ -278,7 +278,7 @@ void __init arm64_memblock_init(void)
>  	 * Register the kernel text, kernel data, initrd, and initial
>  	 * pagetables with memblock.
>  	 */
> -	memblock_reserve(__pa(_text), _end - _text);
> +	memblock_reserve(__pa_symbol(_text), _end - _text);
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start) {
>  		memblock_reserve(initrd_start, initrd_end - initrd_start);
> @@ -483,7 +483,8 @@ void __init mem_init(void)
>  
>  void free_initmem(void)
>  {
> -	free_reserved_area(__va(__pa(__init_begin)), __va(__pa(__init_end)),
> +	free_reserved_area(__va(__pa_symbol(__init_begin)),
> +			   __va(__pa_symbol(__init_end)),
>  			   0, "unused kernel");
>  	/*
>  	 * Unmap the __init region but leave the VM area in place. This
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 17243e43184e..f7c0a47a8ebd 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -359,8 +359,8 @@ static void create_mapping_late(phys_addr_t phys, unsigned long virt,
>  
>  static void __init __map_memblock(pgd_t *pgd, phys_addr_t start, phys_addr_t end)
>  {
> -	unsigned long kernel_start = __pa(_text);
> -	unsigned long kernel_end = __pa(__init_begin);
> +	unsigned long kernel_start = __pa_symbol(_text);
> +	unsigned long kernel_end = __pa_symbol(__init_begin);
>  
>  	/*
>  	 * Take care not to create a writable alias for the
> @@ -427,14 +427,14 @@ void mark_rodata_ro(void)
>  	unsigned long section_size;
>  
>  	section_size = (unsigned long)_etext - (unsigned long)_text;
> -	create_mapping_late(__pa(_text), (unsigned long)_text,
> +	create_mapping_late(__pa_symbol(_text), (unsigned long)_text,
>  			    section_size, PAGE_KERNEL_ROX);
>  	/*
>  	 * mark .rodata as read only. Use __init_begin rather than __end_rodata
>  	 * to cover NOTES and EXCEPTION_TABLE.
>  	 */
>  	section_size = (unsigned long)__init_begin - (unsigned long)__start_rodata;
> -	create_mapping_late(__pa(__start_rodata), (unsigned long)__start_rodata,
> +	create_mapping_late(__pa_symbol(__start_rodata), (unsigned long)__start_rodata,
>  			    section_size, PAGE_KERNEL_RO);
>  
>  	/* flush the TLBs after updating live kernel mappings */
> @@ -446,7 +446,7 @@ void mark_rodata_ro(void)
>  static void __init map_kernel_segment(pgd_t *pgd, void *va_start, void *va_end,
>  				      pgprot_t prot, struct vm_struct *vma)
>  {
> -	phys_addr_t pa_start = __pa(va_start);
> +	phys_addr_t pa_start = __pa_symbol(va_start);
>  	unsigned long size = va_end - va_start;
>  
>  	BUG_ON(!PAGE_ALIGNED(pa_start));
> @@ -494,7 +494,7 @@ static void __init map_kernel(pgd_t *pgd)
>  		 */
>  		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
>  		set_pud(pud_set_fixmap_offset(pgd, FIXADDR_START),
> -			__pud(__pa(bm_pmd) | PUD_TYPE_TABLE));
> +			__pud(__pa_symbol(bm_pmd) | PUD_TYPE_TABLE));
>  		pud_clear_fixmap();
>  	} else {
>  		BUG();
> @@ -525,7 +525,7 @@ void __init paging_init(void)
>  	 */
>  	cpu_replace_ttbr1(__va(pgd_phys));
>  	memcpy(swapper_pg_dir, pgd, PAGE_SIZE);
> -	cpu_replace_ttbr1(swapper_pg_dir);
> +	cpu_replace_ttbr1(__va(__pa_symbol(swapper_pg_dir)));
>  
>  	pgd_clear_fixmap();
>  	memblock_free(pgd_phys, PAGE_SIZE);
> @@ -534,7 +534,7 @@ void __init paging_init(void)
>  	 * We only reuse the PGD from the swapper_pg_dir, not the pud + pmd
>  	 * allocated with it.
>  	 */
> -	memblock_free(__pa(swapper_pg_dir) + PAGE_SIZE,
> +	memblock_free(__pa_symbol(swapper_pg_dir) + PAGE_SIZE,
>  		      SWAPPER_DIR_SIZE - PAGE_SIZE);
>  }
>  
> @@ -654,7 +654,7 @@ void __init early_fixmap_init(void)
>  
>  	pgd = pgd_offset_k(addr);
>  	if (CONFIG_PGTABLE_LEVELS > 3 &&
> -	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa(bm_pud))) {
> +	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa_symbol(bm_pud))) {
>  		/*
>  		 * We only end up here if the kernel mapping and the fixmap
>  		 * share the top level pgd entry, which should only happen on
> @@ -663,12 +663,12 @@ void __init early_fixmap_init(void)
>  		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
>  		pud = pud_offset_kimg(pgd, addr);
>  	} else {
> -		pgd_populate(&init_mm, pgd, bm_pud);
> +		pgd_populate(&init_mm, pgd, __va(__pa_symbol(bm_pud)));
>  		pud = fixmap_pud(addr);
>  	}
> -	pud_populate(&init_mm, pud, bm_pmd);
> +	pud_populate(&init_mm, pud, __va(__pa_symbol(bm_pmd)));
>  	pmd = fixmap_pmd(addr);
> -	pmd_populate_kernel(&init_mm, pmd, bm_pte);
> +	pmd_populate_kernel(&init_mm, pmd, __va(__pa_symbol(bm_pte)));
>  
>  	/*
>  	 * The boot-ioremap range spans multiple pmds, for which
> diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
> index 874c78201a2b..98dae943e496 100644
> --- a/arch/arm64/mm/physaddr.c
> +++ b/arch/arm64/mm/physaddr.c
> @@ -14,8 +14,8 @@ unsigned long __virt_to_phys(unsigned long x)
>  		 */
>  		return (__x & ~PAGE_OFFSET) + PHYS_OFFSET;
>  	} else {
> -		VIRTUAL_BUG_ON(x < kimage_vaddr || x >= (unsigned long)_end);
> -		return (__x - kimage_voffset);
> +		WARN_ON(1);

Was the deletion of the BUG_ON here intentional? VIRTUAL_BUG_ON
is the check enabled by CONFIG_DEBUG_VIRTUAL vs just CONFIG_DEBUG_VM.
I intentionally kept CONFIG_DEBUG_VIRTUAL separate since the checks
are expensive.

> +		return __phys_addr_symbol(x);
>  	}
>  }
>  EXPORT_SYMBOL(__virt_to_phys);
> diff --git a/drivers/firmware/psci.c b/drivers/firmware/psci.c
> index 8263429e21b8..9defbe243c2f 100644
> --- a/drivers/firmware/psci.c
> +++ b/drivers/firmware/psci.c
> @@ -383,7 +383,7 @@ static int psci_suspend_finisher(unsigned long index)
>  	u32 *state = __this_cpu_read(psci_power_state);
>  
>  	return psci_ops.cpu_suspend(state[index - 1],
> -				    virt_to_phys(cpu_resume));
> +				    __pa_symbol(cpu_resume));
>  }
>  
>  int psci_cpu_suspend_enter(unsigned long index)
> 

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
