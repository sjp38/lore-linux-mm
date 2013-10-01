Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id C645C6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:43:39 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so7664039pbc.39
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:43:39 -0700 (PDT)
Message-ID: <524B41FC.6090204@imgtec.com>
Date: Tue, 1 Oct 2013 14:43:24 -0700
From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH] MIPS HIGHMEM fixes for cache aliasing and non-DMA
 I/O.
References: <1380600825-28319-1-git-send-email-Steven.Hill@imgtec.com> <20131001172451.GB12616@linux-mips.org>
In-Reply-To: <20131001172451.GB12616@linux-mips.org>
Content-Type: multipart/alternative;
	boundary="------------060106000609060307010904"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: "Steven J. Hill" <Steven.Hill@imgtec.com>, linux-mips@linux-mips.org, linux-mm@kvack.org

--------------060106000609060307010904
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 10/01/2013 10:24 AM, Ralf Baechle wrote:
> On Mon, Sep 30, 2013 at 11:13:45PM -0500, Steven J. Hill wrote:
>
>> This patch fixes MIPS HIGHMEM for cache aliasing and non-DMA device
>> I/O. It does the following:
>>
>> 1.  Uses only colored page addresses while allocating by kmap*(),
>>      page address in HIGHMEM zone matches a kernel address by color.
>>      It allows easy re-allocation before flushing cache.
>>      It does it for kmap() and kmap_atomic().
>>
>> 2.  Fixes instruction cache flush by right color address via
>>      kmap_coherent() in case of I-cache aliasing.
>>
>> 3.  Flushes D-cache before page is provided for process as I-page.
>>      It is required for swapped-in pages in case of non-DMA I/O.
>>
>> 4.  Some optimization is done... more comes.
>>
>> Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
>> Signed-off-by: Steven J. Hill <Steven.Hill@imgtec.com>
>> (cherry picked from commit bf252e2d224256b3f34683bff141d6951b3cae6a)
>> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
>> index 17cc7ff..ed835b2 100644
>> --- a/arch/mips/Kconfig
>> +++ b/arch/mips/Kconfig
>> @@ -330,6 +330,7 @@ config MIPS_MALTA
>>   	select SYS_SUPPORTS_MULTITHREADING
>>   	select SYS_SUPPORTS_SMARTMIPS
>>   	select SYS_SUPPORTS_ZBOOT
>> +	select SYS_SUPPORTS_HIGHMEM
>>   	help
>>   	  This enables support for the MIPS Technologies Malta evaluation
>>   	  board.
>> @@ -2064,6 +2065,7 @@ config CPU_R4400_WORKAROUNDS
>>   config HIGHMEM
>>   	bool "High Memory Support"
>>   	depends on 32BIT && CPU_SUPPORTS_HIGHMEM && SYS_SUPPORTS_HIGHMEM
>> +	depends on ( !SMP || NR_CPUS = 1 || NR_CPUS = 2 || NR_CPUS = 3 || NR_CPUS = 4 || NR_CPUS = 5 || NR_CPUS = 6 || NR_CPUS = 7 || NR_CPUS = 8 )
> Why does highmem not work for more than 8 CPU?

Coloring requires much more kernel virtual address space, and 
kmap_atomic() uses space /per-cpu/.
So, some trade-off is needed because kmap_atomic space may hit a top of 
kmap() space.
NR_CPU == 8 is a good trade-off, at least for now.

We may redesign it later but that would require splitting the idle task 
PTE table on per-cpu basis or some another means to separate PTE tables.
Today each CPU kmap_atomic has a separate zone in kernel virtual address 
space. But this patch requires a multiplication by number of colours.


>> +#ifndef cpu_has_ic_aliases
>> +#define cpu_has_ic_aliases      (cpu_data[0].icache.flags & MIPS_CACHE_ALIASES)
>> +#endif
>>   #ifndef cpu_has_dc_aliases
>>   #define cpu_has_dc_aliases	(cpu_data[0].dcache.flags & MIPS_CACHE_ALIASES)
>>   #endif
>> diff --git a/arch/mips/include/asm/fixmap.h b/arch/mips/include/asm/fixmap.h
>> index dfaaf49..a690f05 100644
>> --- a/arch/mips/include/asm/fixmap.h
>> +++ b/arch/mips/include/asm/fixmap.h
>> @@ -46,7 +46,19 @@
>>    * fix-mapped?
>>    */
>>   enum fixed_addresses {
>> +
>> +/* must be <= 8, last_pkmap_nr_arr[] is initialized to 8 elements,
>> +   keep the total L1 size <= 512KB with 4 ways */
>> +#ifdef  CONFIG_PAGE_SIZE_64KB
>> +#define FIX_N_COLOURS 2
>> +#endif
>> +#ifdef  CONFIG_PAGE_SIZE_32KB
>> +#define FIX_N_COLOURS 4
>> +#endif
>> +#ifndef FIX_N_COLOURS
>>   #define FIX_N_COLOURS 8
>> +#endif
> Dark black magic alert?

It is the same space problem - just limit the possible number of colors 
if CPU has a big L1. There is a panic() call in cache probe which 
verifies an actual number of required colors and L1 sizes and it is 
based on FIX_N_COLOURS.

> Normally a anything bigger than 16K page size isn't suffering from aliases
> at all, so can be considered having just a single page colour.

Well, I don't believe HW engineers, so I would like to avoid that kind 
of conclusions :)
At least I have on my desk some cores with 64KB L1 and still cache aliasing.

>> +
>>   	FIX_CMAP_BEGIN,
>>   #ifdef CONFIG_MIPS_MT_SMTC
>>   	FIX_CMAP_END = FIX_CMAP_BEGIN + (FIX_N_COLOURS * NR_CPUS * 2),
>> @@ -56,7 +68,7 @@ enum fixed_addresses {
>>   #ifdef CONFIG_HIGHMEM
>>   	/* reserved pte's for temporary kernel mappings */
>>   	FIX_KMAP_BEGIN = FIX_CMAP_END + 1,
>> -	FIX_KMAP_END = FIX_KMAP_BEGIN+(KM_TYPE_NR*NR_CPUS)-1,
>> +	FIX_KMAP_END = FIX_KMAP_BEGIN+(8*NR_CPUS*FIX_N_COLOURS)-1,
> I don't understand why this would need to be extended for dealing with
> highmem cache aliases.  Please explain.

See above - kmap_atomic uses space per-cpu. I just replaced KM_TYPE_NR 
by maximum number 8 - it is a max stack level for kmap_atomic(). And 
multiplied by max number of colors.

I use max number 8 because I suspect it never goes above 3 (I tried hard 
but never seen above 2). Anywhere, using KM_TYPE_NR is overkill now 
because lock is done today not by KM_TYPE but simple stack (see 
kmap_atomic_idx() function). Probably, it has sense to change in 
kmap_atomic_idx()

   BUG_ON(idx > KM_TYPE_NR);

to

   BUG_ON(idx > 8);

and replace it with symbolic, but patch was done originally on 2.6.32.15 
and included a backported kmap_atomic_idx_push() and that verification 
was inadvertently changed.

>
>> +/*  8 colors pages are here *
>> +#ifdef  CONFIG_PAGE_SIZE_4KB
>> +#define LAST_PKMAP 4096
>> +#endif
>> +#ifdef  CONFIG_PAGE_SIZE_8KB
>> +#define LAST_PKMAP 2048
>> +#endif
>> +#ifdef  CONFIG_PAGE_SIZE_16KB
>> +#define LAST_PKMAP 1024
>> +#endif
>> +
>> +/* 32KB and 64KB pages should have 4 and 2 colors to keep space under control */
> Again I'm wondering why these large number of colors where you should need
> just one.
See above about 64KB aliasing cache. I hope for good future and 512KB 
L1... but it still may be aliasing.

>
> Is this related to the 74K / 1074K erratum workaround we've recently been
> mailing about?

No.

> diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
> index 341609c..d7acabb 100644
> --- a/arch/mips/mm/c-r4k.c
> +++ b/arch/mips/mm/c-r4k.c
> @@ -409,8 +409,11 @@ static inline void local_r4k_flush_cache_range(void * args)
>   		return;
>   
>   	r4k_blast_dcache();
> -	if (exec)
> +	if (exec) {
> +		if (!cpu_has_ic_fills_f_dc)
> +			wmb();
>   		r4k_blast_icache();
> +	}
> Why the wmb() here?  I think the implied barrier by the ERET before userland
> execution in that page can start I-cache refilling, should suffice?

Well, after flushing L1D cache the CACHE instruction should be completed 
before we invalidate the same L1I cacheline with CACHE.
The SYNC is needed and Arch Vol II (CACHE) explicitly states that:

"For implementations which implement multiple level of caches without 
the inclusion property, the use of a SYNC instruction after the CACHE 
instruction is still needed whenever writeback data has to be resident 
in the next level of memory hierarchy".

(The hazard barrier in ERET is needed too).

HW team swears me that hazard barrier is not enough because D and I 
caches are independent from CPU and some race condition may occur here 
and I-cache may be filled before D-cache flush is completed. Hazard 
barrier just destroys core pipelines but it doesn't revert an effect of 
I-fetch into L1I forced by core prediction mechanics before hazard barrier.

The newest cores from MIPS (I mean IMG :) with CM/CM2 don't need that 
because (from my records):

"CM/CM2 doesn't delay the second cache flush (I-cache HInval). However, 
after Hazard barrier the instruction fetch on the same address as 
D-cache HWBInv will be delayed until it is finished." - it is a 
coherency feature of CM/CM2 which can be absent on other cores and SYNC 
is needed between two CACHEs.

But this optimisation is not pushed yet to LMO.

>>   }
>>   
>>   static void r4k_flush_cache_range(struct vm_area_struct *vma,
>> @@ -474,6 +477,7 @@ static inline void local_r4k_flush_cache_page(void *args)
>>   	pmd_t *pmdp;
>>   	pte_t *ptep;
>>   	void *vaddr;
>> +	int dontflash = 0;
> I think you mean 'dontflush'.

Yes, thank you.

>
>>   		if (exec && !cpu_icache_snoops_remote_store)
>>   			r4k_blast_scache_page(addr);
>>   	}
>> @@ -522,8 +532,10 @@ static inline void local_r4k_flush_cache_page(void *args)
>>   
>>   			if (cpu_context(cpu, mm) != 0)
>>   				drop_mmu_context(mm, cpu);
>> +			dontflash = 1;
>>   		} else
>> -			r4k_blast_icache_page(addr);
>> +			if (map_coherent || !cpu_has_ic_aliases)
>> +				r4k_blast_icache_page(addr);
> So if we don't call r4k_blast_icache_page() here we assume the flush is
> done elsewhere?

Yes, it is right below:

>
>>   	}
>>   
>>   	if (vaddr) {
>> @@ -532,6 +544,13 @@ static inline void local_r4k_flush_cache_page(void *args)
>>   		else
>>   			kunmap_atomic(vaddr);
>>   	}
>> +
>> +	/*  in case of I-cache aliasing - blast it via coherent page */
>> +	if (exec && cpu_has_ic_aliases && (!dontflash) && !map_coherent) {
>                                            ^^^^^^^^^^^^
> Useless parenthesis.
>
>> +		vaddr = kmap_coherent(page, addr);
>> +		r4k_blast_icache_page((unsigned long)vaddr);
>> +		kunmap_coherent();
>> +	}
>>   }
>>   
>>   static void r4k_flush_cache_page(struct vm_area_struct *vma,
>> @@ -544,6 +563,8 @@ static void r4k_flush_cache_page(struct vm_area_struct *vma,
>>   	args.pfn = pfn;
>>   
>>   	r4k_on_each_cpu(local_r4k_flush_cache_page, &args);
>> +	if (cpu_has_dc_aliases)
>> +		ClearPageDcacheDirty(pfn_to_page(pfn));
>
> This also is just a performance tweak?  If so it should also go into a
> separate patch.

No, it should be done for correctness. It is related with arch dirty bit 
control which was fixed too. Unfortunately, it was done 2.5 years ago 
and was merged with HIGHMEM patch because it is /required/ for it. Sorry.

>
>> +			if (c->icache.waysize > PAGE_SIZE)
>> +				c->icache.flags |= MIPS_CACHE_ALIASES;
>> +		}
>> +		if (read_c0_config7() & MIPS_CONF7_AR) {
>>   			/* effectively physically indexed dcache,
>>   			   thus no virtual aliases. */
>>   			c->dcache.flags |= MIPS_CACHE_PINDEX;
>> @@ -1109,6 +1136,14 @@ static void probe_pcache(void)
>>   			c->dcache.flags |= MIPS_CACHE_ALIASES;
>>   	}
>>   
>> +#ifdef CONFIG_HIGHMEM
>> +	if (((c->dcache.flags & MIPS_CACHE_ALIASES) &&
>> +	     ((c->dcache.waysize / PAGE_SIZE) > FIX_N_COLOURS)) ||
>> +	     ((c->icache.flags & MIPS_CACHE_ALIASES) &&
>> +	     ((c->icache.waysize / PAGE_SIZE) > FIX_N_COLOURS)))
>> +		panic("PAGE_SIZE*WAYS too small for L1 size, too many colors");
>> +#endif
>> +
>>   	switch (current_cpu_type()) {
>>   	case CPU_20KC:
>>   		/*
>> @@ -1130,10 +1165,12 @@ static void probe_pcache(void)
>>   		c->icache.ways = 1;
>>   	}
>>   
>> -	printk("Primary instruction cache %ldkB, %s, %s, linesize %d bytes.\n",
>> -	       icache_size >> 10,
>> +	printk("Primary instruction cache %ldkB, %s, %s, %slinesize %d bytes.\n",
>> +	       icache_size >> 10, way_string[c->icache.ways],
>>   	       c->icache.flags & MIPS_CACHE_VTAG ? "VIVT" : "VIPT",
>> -	       way_string[c->icache.ways], c->icache.linesz);
>> +	       (c->icache.flags & MIPS_CACHE_ALIASES) ?
>> +			"I-cache aliases, " : "",
>> +	       c->icache.linesz);
>>   
>>   	printk("Primary data cache %ldkB, %s, %s, %s, linesize %d bytes\n",
>>   	       dcache_size >> 10, way_string[c->dcache.ways],
>> diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
>> index 15f813c..92598de 100644
>> --- a/arch/mips/mm/cache.c
>> +++ b/arch/mips/mm/cache.c
>> @@ -20,6 +20,7 @@
>>   #include <asm/processor.h>
>>   #include <asm/cpu.h>
>>   #include <asm/cpu-features.h>
>> +#include <linux/highmem.h>
>>   
>>   /* Cache operations. */
>>   void (*flush_cache_all)(void);
>> @@ -80,12 +81,9 @@ SYSCALL_DEFINE3(cacheflush, unsigned long, addr, unsigned long, bytes,
>>   
>>   void __flush_dcache_page(struct page *page)
>>   {
>> -	struct address_space *mapping = page_mapping(page);
>> -	unsigned long addr;
>> +	void *addr;
>>   
>> -	if (PageHighMem(page))
>> -		return;
> Quite obviously that was "not quite right".
>
>> -	if (mapping && !mapping_mapped(mapping)) {
>> +	if (page_mapping(page) && !page_mapped(page)) {
> This again is only a performance tweak?

No, it is again a correctness in arch dirty bit handling.

>
>>   }
>>   
>>   unsigned long _page_cachable_default;
>> diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
>> index da815d2..10fc041 100644
>> --- a/arch/mips/mm/highmem.c
>> +++ b/arch/mips/mm/highmem.c
>> @@ -9,6 +9,7 @@
>>   static pte_t *kmap_pte;
>>   
>>   unsigned long highstart_pfn, highend_pfn;
>> +unsigned int  last_pkmap_nr_arr[FIX_N_COLOURS] = { 0, 1, 2, 3, 4, 5, 6, 7 };
>>   
>>   void *kmap(struct page *page)
>>   {
>> @@ -53,8 +54,12 @@ void *kmap_atomic(struct page *page)
>>   		return page_address(page);
>>   
>>   	type = kmap_atomic_idx_push();
>> -	idx = type + KM_TYPE_NR*smp_processor_id();
>> -	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>> +
>> +	idx = (((unsigned long)lowmem_page_address(page)) >> PAGE_SHIFT) & (FIX_N_COLOURS - 1);
>> +	idx = (FIX_N_COLOURS - idx);
>> +	idx = idx + FIX_N_COLOURS * (smp_processor_id() + NR_CPUS * type);
>> +	vaddr = __fix_to_virt(FIX_KMAP_BEGIN - 1 + idx);    /* actually - FIX_CMAP_END */
>> +
>>   #ifdef CONFIG_DEBUG_HIGHMEM
>>   	BUG_ON(!pte_none(*(kmap_pte - idx)));
>>   #endif
>> @@ -75,12 +80,16 @@ void __kunmap_atomic(void *kvaddr)
>>   		return;
>>   	}
>>   
>> -	type = kmap_atomic_idx();
>>   #ifdef CONFIG_DEBUG_HIGHMEM
>>   	{
>> -		int idx = type + KM_TYPE_NR * smp_processor_id();
>> +		int idx;
>> +		type = kmap_atomic_idx();
>>   
>> -		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
>> +		idx = ((unsigned long)kvaddr >> PAGE_SHIFT) & (FIX_N_COLOURS - 1);
>> +		idx = (FIX_N_COLOURS - idx);
>> +		idx = idx + FIX_N_COLOURS * (smp_processor_id() + NR_CPUS * type);
>> +
>> +		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN -1 + idx));
>>   
>>   		/*
>>   		 * force other mappings to Oops if they'll try to access
>> @@ -95,26 +104,6 @@ void __kunmap_atomic(void *kvaddr)
>>   }
>>   EXPORT_SYMBOL(__kunmap_atomic);
>>   
>> -/*
>> - * This is the same as kmap_atomic() but can map memory that doesn't
>> - * have a struct page associated with it.
>> - */
>> -void *kmap_atomic_pfn(unsigned long pfn)
>> -{
>> -	unsigned long vaddr;
>> -	int idx, type;
>> -
>> -	pagefault_disable();
>> -
>> -	type = kmap_atomic_idx_push();
>> -	idx = type + KM_TYPE_NR*smp_processor_id();
>> -	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>> -	set_pte(kmap_pte-idx, pfn_pte(pfn, PAGE_KERNEL));
>> -	flush_tlb_one(vaddr);
>> -
>> -	return (void*) vaddr;
>> -}
>> -
>>   struct page *kmap_atomic_to_page(void *ptr)
>>   {
>>   	unsigned long idx, vaddr = (unsigned long)ptr;
>> @@ -124,7 +113,7 @@ struct page *kmap_atomic_to_page(void *ptr)
>>   		return virt_to_page(ptr);
>>   
>>   	idx = virt_to_fix(vaddr);
>> -	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
>> +	pte = kmap_pte - (idx - FIX_KMAP_BEGIN + 1);
>>   	return pte_page(*pte);
>>   }
>>   
>> @@ -133,6 +122,6 @@ void __init kmap_init(void)
>>   	unsigned long kmap_vstart;
>>   
>>   	/* cache the first kmap pte */
>> -	kmap_vstart = __fix_to_virt(FIX_KMAP_BEGIN);
>> +	kmap_vstart = __fix_to_virt(FIX_KMAP_BEGIN - 1); /* actually - FIX_CMAP_END */
>>   	kmap_pte = kmap_get_fixmap_pte(kmap_vstart);
>>   }
>> diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
>> index e205ef5..352367b 100644
>> --- a/arch/mips/mm/init.c
>> +++ b/arch/mips/mm/init.c
>> @@ -122,7 +122,7 @@ void *kmap_coherent(struct page *page, unsigned long addr)
>>   	pte_t pte;
>>   	int tlbidx;
>>   
>> -	BUG_ON(Page_dcache_dirty(page));
>> +	/* BUG_ON(Page_dcache_dirty(page)); - removed for I-cache flush */
>>   
>>   	inc_preempt_count();
>>   	idx = (addr >> PAGE_SHIFT) & (FIX_N_COLOURS - 1);
>> @@ -213,9 +213,15 @@ void copy_user_highpage(struct page *to, struct page *from,
>>   		copy_page(vto, vfrom);
>>   		kunmap_atomic(vfrom);
>>   	}
>> -	if ((!cpu_has_ic_fills_f_dc) ||
>> -	    pages_do_alias((unsigned long)vto, vaddr & PAGE_MASK))
>> +	if (cpu_has_dc_aliases)
>> +		SetPageDcacheDirty(to);
>> +	if (((vma->vm_flags & VM_EXEC) && !cpu_has_ic_fills_f_dc) ||
>> +	    cpu_has_vtag_dcache || (cpu_has_dc_aliases &&
>> +	     pages_do_alias((unsigned long)vto, vaddr & PAGE_MASK))) {
>>   		flush_data_cache_page((unsigned long)vto);
>> +		if (cpu_has_dc_aliases)
>> +			ClearPageDcacheDirty(to);
>> +	}
>>   	kunmap_atomic(vto);
>>   	/* Make sure this page is cleared on other CPU's too before using it */
>>   	smp_wmb();
>> @@ -235,8 +241,14 @@ void copy_to_user_page(struct vm_area_struct *vma,
>>   		if (cpu_has_dc_aliases)
>>   			SetPageDcacheDirty(page);
>>   	}
>> -	if ((vma->vm_flags & VM_EXEC) && !cpu_has_ic_fills_f_dc)
>> +	if (((vma->vm_flags & VM_EXEC) && !cpu_has_ic_fills_f_dc) ||
>> +	    (Page_dcache_dirty(page) &&
>> +	     pages_do_alias((unsigned long)dst & PAGE_MASK,
>> +			    vaddr & PAGE_MASK))) {
>>   		flush_cache_page(vma, vaddr, page_to_pfn(page));
>> +		if (cpu_has_dc_aliases)
>> +			ClearPageDcacheDirty(page);
>> +	}
>>   }
>>   
>>   void copy_from_user_page(struct vm_area_struct *vma,
>> @@ -248,11 +260,8 @@ void copy_from_user_page(struct vm_area_struct *vma,
>>   		void *vfrom = kmap_coherent(page, vaddr) + (vaddr & ~PAGE_MASK);
>>   		memcpy(dst, vfrom, len);
>>   		kunmap_coherent();
>> -	} else {
>> +	} else
>>   		memcpy(dst, src, len);
>> -		if (cpu_has_dc_aliases)
>> -			SetPageDcacheDirty(page);
>> -	}
>>   }
>>   EXPORT_SYMBOL_GPL(copy_from_user_page);
>>   
>> @@ -323,7 +332,7 @@ int page_is_ram(unsigned long pagenr)
>>   void __init paging_init(void)
>>   {
>>   	unsigned long max_zone_pfns[MAX_NR_ZONES];
>> -	unsigned long lastpfn __maybe_unused;
>> +	unsigned long lastpfn;
>>   
>>   	pagetable_init();
>>   
>> @@ -343,14 +352,6 @@ void __init paging_init(void)
>>   #ifdef CONFIG_HIGHMEM
>>   	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
>>   	lastpfn = highend_pfn;
>> -
>> -	if (cpu_has_dc_aliases && max_low_pfn != highend_pfn) {
>> -		printk(KERN_WARNING "This processor doesn't support highmem."
>> -		       " %ldk highmem ignored\n",
>> -		       (highend_pfn - max_low_pfn) << (PAGE_SHIFT - 10));
>> -		max_zone_pfns[ZONE_HIGHMEM] = max_low_pfn;
>> -		lastpfn = max_low_pfn;
>> -	}
>>   #endif
>>   
>>   	free_area_init_nodes(max_zone_pfns);
>> diff --git a/arch/mips/mm/sc-mips.c b/arch/mips/mm/sc-mips.c
>> index 08d05ae..a801f6b 100644
>> --- a/arch/mips/mm/sc-mips.c
>> +++ b/arch/mips/mm/sc-mips.c
>> @@ -24,6 +24,7 @@
>>    */
>>   static void mips_sc_wback_inv(unsigned long addr, unsigned long size)
>>   {
>> +	__sync();
> This again seems unrelated to the rest of the patch.  Please submit
> in a separate patch.

SYNC is required, see above a note on L1D/L1I cache flush with Arch Vol 
II statement.

>    Ralf

- Leonid.


--------------060106000609060307010904
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 10/01/2013 10:24 AM, Ralf Baechle
      wrote:<br>
    </div>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">On Mon, Sep 30, 2013 at 11:13:45PM -0500, Steven J. Hill wrote:

</pre>
      <blockquote type="cite">
        <pre wrap="">This patch fixes MIPS HIGHMEM for cache aliasing and non-DMA device
I/O. It does the following:

1.  Uses only colored page addresses while allocating by kmap*(),
    page address in HIGHMEM zone matches a kernel address by color.
    It allows easy re-allocation before flushing cache.
    It does it for kmap() and kmap_atomic().

2.  Fixes instruction cache flush by right color address via
    kmap_coherent() in case of I-cache aliasing.

3.  Flushes D-cache before page is provided for process as I-page.
    It is required for swapped-in pages in case of non-DMA I/O.

4.  Some optimization is done... more comes.

Signed-off-by: Leonid Yegoshin <a class="moz-txt-link-rfc2396E" href="mailto:Leonid.Yegoshin@imgtec.com">&lt;Leonid.Yegoshin@imgtec.com&gt;</a>
Signed-off-by: Steven J. Hill <a class="moz-txt-link-rfc2396E" href="mailto:Steven.Hill@imgtec.com">&lt;Steven.Hill@imgtec.com&gt;</a>
(cherry picked from commit bf252e2d224256b3f34683bff141d6951b3cae6a)
</pre>
      </blockquote>
    </blockquote>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <blockquote type="cite">
        <pre wrap="">diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 17cc7ff..ed835b2 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -330,6 +330,7 @@ config MIPS_MALTA
 	select SYS_SUPPORTS_MULTITHREADING
 	select SYS_SUPPORTS_SMARTMIPS
 	select SYS_SUPPORTS_ZBOOT
+	select SYS_SUPPORTS_HIGHMEM
 	help
 	  This enables support for the MIPS Technologies Malta evaluation
 	  board.
@@ -2064,6 +2065,7 @@ config CPU_R4400_WORKAROUNDS
 config HIGHMEM
 	bool "High Memory Support"
 	depends on 32BIT &amp;&amp; CPU_SUPPORTS_HIGHMEM &amp;&amp; SYS_SUPPORTS_HIGHMEM
+	depends on ( !SMP || NR_CPUS = 1 || NR_CPUS = 2 || NR_CPUS = 3 || NR_CPUS = 4 || NR_CPUS = 5 || NR_CPUS = 6 || NR_CPUS = 7 || NR_CPUS = 8 )
</pre>
      </blockquote>
      <pre wrap="">
Why does highmem not work for more than 8 CPU?
</pre>
    </blockquote>
    <br>
    Coloring requires much more kernel virtual address space, and
    kmap_atomic() uses space <i>per-cpu</i>.<br>
    So, some trade-off is needed because kmap_atomic space may hit a top
    of kmap() space.<br>
    NR_CPU == 8 is a good trade-off, at least for now.<br>
    <br>
    We may redesign it later but that would require splitting the idle
    task PTE table on per-cpu basis or some another means to separate
    PTE tables.<br>
    Today each CPU kmap_atomic has a separate zone in kernel virtual
    address space. But this patch requires a multiplication by number of
    colours.<br>
    <br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">
</pre>
      <blockquote type="cite">
        <pre wrap="">+#ifndef cpu_has_ic_aliases
+#define cpu_has_ic_aliases      (cpu_data[0].icache.flags &amp; MIPS_CACHE_ALIASES)
+#endif
 #ifndef cpu_has_dc_aliases
 #define cpu_has_dc_aliases	(cpu_data[0].dcache.flags &amp; MIPS_CACHE_ALIASES)
 #endif
diff --git a/arch/mips/include/asm/fixmap.h b/arch/mips/include/asm/fixmap.h
index dfaaf49..a690f05 100644
--- a/arch/mips/include/asm/fixmap.h
+++ b/arch/mips/include/asm/fixmap.h
@@ -46,7 +46,19 @@
  * fix-mapped?
  */
 enum fixed_addresses {
+
+/* must be &lt;= 8, last_pkmap_nr_arr[] is initialized to 8 elements,
+   keep the total L1 size &lt;= 512KB with 4 ways */
+#ifdef  CONFIG_PAGE_SIZE_64KB
+#define FIX_N_COLOURS 2
+#endif
+#ifdef  CONFIG_PAGE_SIZE_32KB
+#define FIX_N_COLOURS 4
+#endif
+#ifndef FIX_N_COLOURS
 #define FIX_N_COLOURS 8
+#endif
</pre>
      </blockquote>
      <pre wrap="">
Dark black magic alert?</pre>
    </blockquote>
    <br>
    It is the same space problem - just limit the possible number of
    colors if CPU has a big L1. There is a panic() call in cache probe
    which verifies an actual number of required colors and L1 sizes and
    it is based on FIX_N_COLOURS.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">
Normally a anything bigger than 16K page size isn't suffering from aliases
at all, so can be considered having just a single page colour.</pre>
    </blockquote>
    <br>
    Well, I don't believe HW engineers, so I would like to avoid that
    kind of conclusions :)<br>
    At least I have on my desk some cores with 64KB L1 and still cache
    aliasing.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <blockquote type="cite">
        <pre wrap="">+
 	FIX_CMAP_BEGIN,
 #ifdef CONFIG_MIPS_MT_SMTC
 	FIX_CMAP_END = FIX_CMAP_BEGIN + (FIX_N_COLOURS * NR_CPUS * 2),
@@ -56,7 +68,7 @@ enum fixed_addresses {
 #ifdef CONFIG_HIGHMEM
 	/* reserved pte's for temporary kernel mappings */
 	FIX_KMAP_BEGIN = FIX_CMAP_END + 1,
-	FIX_KMAP_END = FIX_KMAP_BEGIN+(KM_TYPE_NR*NR_CPUS)-1,
+	FIX_KMAP_END = FIX_KMAP_BEGIN+(8*NR_CPUS*FIX_N_COLOURS)-1,
</pre>
      </blockquote>
      <pre wrap="">
I don't understand why this would need to be extended for dealing with
highmem cache aliases.  Please explain.</pre>
    </blockquote>
    <br>
    See above - kmap_atomic uses space per-cpu. I just replaced
    KM_TYPE_NR by maximum number 8 - it is a max stack level for
    kmap_atomic(). And multiplied by max number of colors.<br>
    <br>
    I use max number 8 because I suspect it never goes above 3 (I tried
    hard but never seen above 2). Anywhere, using KM_TYPE_NR is overkill
    now because lock is done today not by KM_TYPE but simple stack (see
    kmap_atomic_idx() function). Probably, it has sense to change in
    kmap_atomic_idx()<br>
    <br>
    &nbsp; BUG_ON(idx &gt; KM_TYPE_NR); <br>
    <br>
    to<br>
    <br>
    &nbsp; BUG_ON(idx &gt; 8);<br>
    <br>
    and replace it with symbolic, but patch was done originally on
    2.6.32.15 and included a backported kmap_atomic_idx_push() and that
    verification was inadvertently changed.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <pre wrap="">+/*  8 colors pages are here *
+#ifdef  CONFIG_PAGE_SIZE_4KB
+#define LAST_PKMAP 4096
+#endif
+#ifdef  CONFIG_PAGE_SIZE_8KB
+#define LAST_PKMAP 2048
+#endif
+#ifdef  CONFIG_PAGE_SIZE_16KB
+#define LAST_PKMAP 1024
+#endif
+
+/* 32KB and 64KB pages should have 4 and 2 colors to keep space under control */
</pre>
      </blockquote>
      <pre wrap="">
Again I'm wondering why these large number of colors where you should need
just one.</pre>
    </blockquote>
    See above about 64KB aliasing cache. I hope for good future and
    512KB L1... but it still may be aliasing.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">

Is this related to the 74K / 1074K erratum workaround we've recently been
mailing about?</pre>
    </blockquote>
    <br>
    No.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">
diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index 341609c..d7acabb 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -409,8 +409,11 @@ static inline void local_r4k_flush_cache_range(void * args)
 		return;
 
 	r4k_blast_dcache();
-	if (exec)
+	if (exec) {
+		if (!cpu_has_ic_fills_f_dc)
+			wmb();
 		r4k_blast_icache();
+	}
</pre>
      <pre wrap="">
Why the wmb() here?  I think the implied barrier by the ERET before userland
execution in that page can start I-cache refilling, should suffice?</pre>
    </blockquote>
    <br>
    Well, after flushing L1D cache the CACHE instruction should be
    completed before we invalidate the same L1I cacheline with CACHE.<br>
    The SYNC is needed and Arch Vol II (CACHE) explicitly states that:<br>
    <br>
    "For implementations which implement multiple level of caches
    without the inclusion property, the use of a SYNC instruction after
    the CACHE instruction is still needed whenever writeback data has to
    be resident in the next level of memory hierarchy". <br>
    <br>
    (The hazard barrier in ERET is needed too).<br>
    <br>
    HW team swears me that hazard barrier is not enough because D and I
    caches are independent from CPU and some race condition may occur
    here and I-cache may be filled before D-cache flush is completed.
    Hazard barrier just destroys core pipelines but it doesn't revert an
    effect of I-fetch into L1I forced by core prediction mechanics
    before hazard barrier.<br>
    <br>
    The newest cores from MIPS (I mean IMG :) with CM/CM2 don't need
    that because (from my records):<br>
    <br>
    "CM/CM2 doesn't delay the second cache flush (I-cache HInval).
    However, after Hazard barrier the instruction fetch on the same
    address as D-cache HWBInv will be delayed until it is finished." -
    it is a coherency feature of CM/CM2 which can be absent on other
    cores and SYNC is needed between two CACHEs.<br>
    <br>
    But this optimisation is not pushed yet to LMO.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <blockquote type="cite">
        <pre wrap=""> }
 
 static void r4k_flush_cache_range(struct vm_area_struct *vma,
@@ -474,6 +477,7 @@ static inline void local_r4k_flush_cache_page(void *args)
 	pmd_t *pmdp;
 	pte_t *ptep;
 	void *vaddr;
+	int dontflash = 0;
</pre>
      </blockquote>
      <pre wrap="">
I think you mean 'dontflush'.</pre>
    </blockquote>
    <br>
    Yes, thank you.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite"><br>
      <blockquote type="cite">
        <pre wrap=""> 		if (exec &amp;&amp; !cpu_icache_snoops_remote_store)
 			r4k_blast_scache_page(addr);
 	}
@@ -522,8 +532,10 @@ static inline void local_r4k_flush_cache_page(void *args)
 
 			if (cpu_context(cpu, mm) != 0)
 				drop_mmu_context(mm, cpu);
+			dontflash = 1;
 		} else
-			r4k_blast_icache_page(addr);
+			if (map_coherent || !cpu_has_ic_aliases)
+				r4k_blast_icache_page(addr);
</pre>
      </blockquote>
      <pre wrap="">
So if we don't call r4k_blast_icache_page() here we assume the flush is
done elsewhere?</pre>
    </blockquote>
    <br>
    Yes, it is right below:<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <pre wrap=""> 	}
 
 	if (vaddr) {
@@ -532,6 +544,13 @@ static inline void local_r4k_flush_cache_page(void *args)
 		else
 			kunmap_atomic(vaddr);
 	}
+
+	/*  in case of I-cache aliasing - blast it via coherent page */
+	if (exec &amp;&amp; cpu_has_ic_aliases &amp;&amp; (!dontflash) &amp;&amp; !map_coherent) {
</pre>
      </blockquote>
      <pre wrap="">                                          ^^^^^^^^^^^^
Useless parenthesis.

</pre>
      <blockquote type="cite">
        <pre wrap="">+		vaddr = kmap_coherent(page, addr);
+		r4k_blast_icache_page((unsigned long)vaddr);
+		kunmap_coherent();
+	}
 }
 
 static void r4k_flush_cache_page(struct vm_area_struct *vma,
@@ -544,6 +563,8 @@ static void r4k_flush_cache_page(struct vm_area_struct *vma,
 	args.pfn = pfn;
 
 	r4k_on_each_cpu(local_r4k_flush_cache_page, &amp;args);
+	if (cpu_has_dc_aliases)
+		ClearPageDcacheDirty(pfn_to_page(pfn));
</pre>
      </blockquote>
      <pre wrap="">

This also is just a performance tweak?  If so it should also go into a
separate patch.</pre>
    </blockquote>
    <br>
    No, it should be done for correctness. It is related with arch dirty
    bit control which was fixed too. Unfortunately, it was done 2.5
    years ago and was merged with HIGHMEM patch because it is <i>required</i>
    for it. Sorry.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite"><br>
      <blockquote type="cite">
        <pre wrap="">+			if (c-&gt;icache.waysize &gt; PAGE_SIZE)
+				c-&gt;icache.flags |= MIPS_CACHE_ALIASES;
+		}
+		if (read_c0_config7() &amp; MIPS_CONF7_AR) {
 			/* effectively physically indexed dcache,
 			   thus no virtual aliases. */
 			c-&gt;dcache.flags |= MIPS_CACHE_PINDEX;
@@ -1109,6 +1136,14 @@ static void probe_pcache(void)
 			c-&gt;dcache.flags |= MIPS_CACHE_ALIASES;
 	}
 
+#ifdef CONFIG_HIGHMEM
+	if (((c-&gt;dcache.flags &amp; MIPS_CACHE_ALIASES) &amp;&amp;
+	     ((c-&gt;dcache.waysize / PAGE_SIZE) &gt; FIX_N_COLOURS)) ||
+	     ((c-&gt;icache.flags &amp; MIPS_CACHE_ALIASES) &amp;&amp;
+	     ((c-&gt;icache.waysize / PAGE_SIZE) &gt; FIX_N_COLOURS)))
+		panic("PAGE_SIZE*WAYS too small for L1 size, too many colors");
+#endif
+
 	switch (current_cpu_type()) {
 	case CPU_20KC:
 		/*
@@ -1130,10 +1165,12 @@ static void probe_pcache(void)
 		c-&gt;icache.ways = 1;
 	}
 
-	printk("Primary instruction cache %ldkB, %s, %s, linesize %d bytes.\n",
-	       icache_size &gt;&gt; 10,
+	printk("Primary instruction cache %ldkB, %s, %s, %slinesize %d bytes.\n",
+	       icache_size &gt;&gt; 10, way_string[c-&gt;icache.ways],
 	       c-&gt;icache.flags &amp; MIPS_CACHE_VTAG ? "VIVT" : "VIPT",
-	       way_string[c-&gt;icache.ways], c-&gt;icache.linesz);
+	       (c-&gt;icache.flags &amp; MIPS_CACHE_ALIASES) ?
+			"I-cache aliases, " : "",
+	       c-&gt;icache.linesz);
 
 	printk("Primary data cache %ldkB, %s, %s, %s, linesize %d bytes\n",
 	       dcache_size &gt;&gt; 10, way_string[c-&gt;dcache.ways],
diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
index 15f813c..92598de 100644
--- a/arch/mips/mm/cache.c
+++ b/arch/mips/mm/cache.c
@@ -20,6 +20,7 @@
 #include &lt;asm/processor.h&gt;
 #include &lt;asm/cpu.h&gt;
 #include &lt;asm/cpu-features.h&gt;
+#include &lt;linux/highmem.h&gt;
 
 /* Cache operations. */
 void (*flush_cache_all)(void);
@@ -80,12 +81,9 @@ SYSCALL_DEFINE3(cacheflush, unsigned long, addr, unsigned long, bytes,
 
 void __flush_dcache_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
-	unsigned long addr;
+	void *addr;
 
-	if (PageHighMem(page))
-		return;
</pre>
      </blockquote>
      <pre wrap="">
Quite obviously that was "not quite right".

</pre>
      <blockquote type="cite">
        <pre wrap="">-	if (mapping &amp;&amp; !mapping_mapped(mapping)) {
+	if (page_mapping(page) &amp;&amp; !page_mapped(page)) {
</pre>
      </blockquote>
      <pre wrap="">
This again is only a performance tweak?</pre>
    </blockquote>
    <br>
    No, it is again a correctness in arch dirty bit handling.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite"><br>
      <blockquote type="cite">
        <pre wrap=""> }
 
 unsigned long _page_cachable_default;
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index da815d2..10fc041 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -9,6 +9,7 @@
 static pte_t *kmap_pte;
 
 unsigned long highstart_pfn, highend_pfn;
+unsigned int  last_pkmap_nr_arr[FIX_N_COLOURS] = { 0, 1, 2, 3, 4, 5, 6, 7 };
 
 void *kmap(struct page *page)
 {
@@ -53,8 +54,12 @@ void *kmap_atomic(struct page *page)
 		return page_address(page);
 
 	type = kmap_atomic_idx_push();
-	idx = type + KM_TYPE_NR*smp_processor_id();
-	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
+
+	idx = (((unsigned long)lowmem_page_address(page)) &gt;&gt; PAGE_SHIFT) &amp; (FIX_N_COLOURS - 1);
+	idx = (FIX_N_COLOURS - idx);
+	idx = idx + FIX_N_COLOURS * (smp_processor_id() + NR_CPUS * type);
+	vaddr = __fix_to_virt(FIX_KMAP_BEGIN - 1 + idx);    /* actually - FIX_CMAP_END */
+
 #ifdef CONFIG_DEBUG_HIGHMEM
 	BUG_ON(!pte_none(*(kmap_pte - idx)));
 #endif
@@ -75,12 +80,16 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
 
-	type = kmap_atomic_idx();
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
-		int idx = type + KM_TYPE_NR * smp_processor_id();
+		int idx;
+		type = kmap_atomic_idx();
 
-		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
+		idx = ((unsigned long)kvaddr &gt;&gt; PAGE_SHIFT) &amp; (FIX_N_COLOURS - 1);
+		idx = (FIX_N_COLOURS - idx);
+		idx = idx + FIX_N_COLOURS * (smp_processor_id() + NR_CPUS * type);
+
+		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN -1 + idx));
 
 		/*
 		 * force other mappings to Oops if they'll try to access
@@ -95,26 +104,6 @@ void __kunmap_atomic(void *kvaddr)
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
-/*
- * This is the same as kmap_atomic() but can map memory that doesn't
- * have a struct page associated with it.
- */
-void *kmap_atomic_pfn(unsigned long pfn)
-{
-	unsigned long vaddr;
-	int idx, type;
-
-	pagefault_disable();
-
-	type = kmap_atomic_idx_push();
-	idx = type + KM_TYPE_NR*smp_processor_id();
-	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
-	set_pte(kmap_pte-idx, pfn_pte(pfn, PAGE_KERNEL));
-	flush_tlb_one(vaddr);
-
-	return (void*) vaddr;
-}
-
 struct page *kmap_atomic_to_page(void *ptr)
 {
 	unsigned long idx, vaddr = (unsigned long)ptr;
@@ -124,7 +113,7 @@ struct page *kmap_atomic_to_page(void *ptr)
 		return virt_to_page(ptr);
 
 	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
+	pte = kmap_pte - (idx - FIX_KMAP_BEGIN + 1);
 	return pte_page(*pte);
 }
 
@@ -133,6 +122,6 @@ void __init kmap_init(void)
 	unsigned long kmap_vstart;
 
 	/* cache the first kmap pte */
-	kmap_vstart = __fix_to_virt(FIX_KMAP_BEGIN);
+	kmap_vstart = __fix_to_virt(FIX_KMAP_BEGIN - 1); /* actually - FIX_CMAP_END */
 	kmap_pte = kmap_get_fixmap_pte(kmap_vstart);
 }
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index e205ef5..352367b 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -122,7 +122,7 @@ void *kmap_coherent(struct page *page, unsigned long addr)
 	pte_t pte;
 	int tlbidx;
 
-	BUG_ON(Page_dcache_dirty(page));
+	/* BUG_ON(Page_dcache_dirty(page)); - removed for I-cache flush */
 
 	inc_preempt_count();
 	idx = (addr &gt;&gt; PAGE_SHIFT) &amp; (FIX_N_COLOURS - 1);
@@ -213,9 +213,15 @@ void copy_user_highpage(struct page *to, struct page *from,
 		copy_page(vto, vfrom);
 		kunmap_atomic(vfrom);
 	}
-	if ((!cpu_has_ic_fills_f_dc) ||
-	    pages_do_alias((unsigned long)vto, vaddr &amp; PAGE_MASK))
+	if (cpu_has_dc_aliases)
+		SetPageDcacheDirty(to);
+	if (((vma-&gt;vm_flags &amp; VM_EXEC) &amp;&amp; !cpu_has_ic_fills_f_dc) ||
+	    cpu_has_vtag_dcache || (cpu_has_dc_aliases &amp;&amp;
+	     pages_do_alias((unsigned long)vto, vaddr &amp; PAGE_MASK))) {
 		flush_data_cache_page((unsigned long)vto);
+		if (cpu_has_dc_aliases)
+			ClearPageDcacheDirty(to);
+	}
 	kunmap_atomic(vto);
 	/* Make sure this page is cleared on other CPU's too before using it */
 	smp_wmb();
@@ -235,8 +241,14 @@ void copy_to_user_page(struct vm_area_struct *vma,
 		if (cpu_has_dc_aliases)
 			SetPageDcacheDirty(page);
 	}
-	if ((vma-&gt;vm_flags &amp; VM_EXEC) &amp;&amp; !cpu_has_ic_fills_f_dc)
+	if (((vma-&gt;vm_flags &amp; VM_EXEC) &amp;&amp; !cpu_has_ic_fills_f_dc) ||
+	    (Page_dcache_dirty(page) &amp;&amp;
+	     pages_do_alias((unsigned long)dst &amp; PAGE_MASK,
+			    vaddr &amp; PAGE_MASK))) {
 		flush_cache_page(vma, vaddr, page_to_pfn(page));
+		if (cpu_has_dc_aliases)
+			ClearPageDcacheDirty(page);
+	}
 }
 
 void copy_from_user_page(struct vm_area_struct *vma,
@@ -248,11 +260,8 @@ void copy_from_user_page(struct vm_area_struct *vma,
 		void *vfrom = kmap_coherent(page, vaddr) + (vaddr &amp; ~PAGE_MASK);
 		memcpy(dst, vfrom, len);
 		kunmap_coherent();
-	} else {
+	} else
 		memcpy(dst, src, len);
-		if (cpu_has_dc_aliases)
-			SetPageDcacheDirty(page);
-	}
 }
 EXPORT_SYMBOL_GPL(copy_from_user_page);
 
@@ -323,7 +332,7 @@ int page_is_ram(unsigned long pagenr)
 void __init paging_init(void)
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
-	unsigned long lastpfn __maybe_unused;
+	unsigned long lastpfn;
 
 	pagetable_init();
 
@@ -343,14 +352,6 @@ void __init paging_init(void)
 #ifdef CONFIG_HIGHMEM
 	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
 	lastpfn = highend_pfn;
-
-	if (cpu_has_dc_aliases &amp;&amp; max_low_pfn != highend_pfn) {
-		printk(KERN_WARNING "This processor doesn't support highmem."
-		       " %ldk highmem ignored\n",
-		       (highend_pfn - max_low_pfn) &lt;&lt; (PAGE_SHIFT - 10));
-		max_zone_pfns[ZONE_HIGHMEM] = max_low_pfn;
-		lastpfn = max_low_pfn;
-	}
 #endif
 
 	free_area_init_nodes(max_zone_pfns);
diff --git a/arch/mips/mm/sc-mips.c b/arch/mips/mm/sc-mips.c
index 08d05ae..a801f6b 100644
--- a/arch/mips/mm/sc-mips.c
+++ b/arch/mips/mm/sc-mips.c
@@ -24,6 +24,7 @@
  */
 static void mips_sc_wback_inv(unsigned long addr, unsigned long size)
 {
+	__sync();
</pre>
      </blockquote>
      <pre wrap="">
This again seems unrelated to the rest of the patch.  Please submit
in a separate patch.</pre>
    </blockquote>
    <br>
    SYNC is required, see above a note on L1D/L1I cache flush with Arch
    Vol II statement.<br>
    <br>
    <blockquote cite="mid:20131001172451.GB12616@linux-mips.org"
      type="cite">
      <pre wrap="">
  Ralf
</pre>
    </blockquote>
    <br>
    - Leonid.<br>
    <br>
  </body>
</html>

--------------060106000609060307010904--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
