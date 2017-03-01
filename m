Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 822706B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:36:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b5so29527473pfa.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:36:46 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0068.outbound.protection.outlook.com. [104.47.41.68])
        by mx.google.com with ESMTPS id 7si4913834pll.64.2017.03.01.07.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:36:45 -0800 (PST)
Subject: Re: [RFC PATCH v4 26/28] x86: Allow kexec to be used with SME
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154755.19244.51276.stgit@tlendack-t1.amdoffice.net>
 <20170228103505.yfwwsrwonoztuknl@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <cdad1eae-e97e-8f1a-5bf0-1729eeaa5fd5@amd.com>
Date: Wed, 1 Mar 2017 09:36:35 -0600
MIME-Version: 1.0
In-Reply-To: <20170228103505.yfwwsrwonoztuknl@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, kexec@lists.infradead.org

+kexec list

On 2/28/2017 4:35 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:47:55AM -0600, Tom Lendacky wrote:
>> Provide support so that kexec can be used to boot a kernel when SME is
>> enabled.
>>
>> Support is needed to allocate pages for kexec without encryption.  This
>> is needed in order to be able to reboot in the kernel in the same manner
>> as originally booted.
>>
>> Additionally, when shutting down all of the CPUs we need to be sure to
>> disable caches, flush the caches and then halt. This is needed when booting
>> from a state where SME was not active into a state where SME is active.
>> Without these steps, it is possible for cache lines to exist for the same
>> physical location but tagged both with and without the encryption bit. This
>> can cause random memory corruption when caches are flushed depending on
>> which cacheline is written last.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/cacheflush.h    |    2 ++
>>  arch/x86/include/asm/init.h          |    1 +
>>  arch/x86/include/asm/mem_encrypt.h   |   10 ++++++++
>>  arch/x86/include/asm/pgtable_types.h |    1 +
>>  arch/x86/kernel/machine_kexec_64.c   |    3 ++
>>  arch/x86/kernel/process.c            |   43 +++++++++++++++++++++++++++++++++-
>>  arch/x86/kernel/smp.c                |    4 ++-
>>  arch/x86/mm/ident_map.c              |    6 +++--
>>  arch/x86/mm/pageattr.c               |    2 ++
>>  include/linux/mem_encrypt.h          |   10 ++++++++
>>  kernel/kexec_core.c                  |   24 +++++++++++++++++++
>>  11 files changed, 100 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
>> index 33ae60a..2180cd5 100644
>> --- a/arch/x86/include/asm/cacheflush.h
>> +++ b/arch/x86/include/asm/cacheflush.h
>> @@ -48,8 +48,10 @@
>>  int set_memory_rw(unsigned long addr, int numpages);
>>  int set_memory_np(unsigned long addr, int numpages);
>>  int set_memory_4k(unsigned long addr, int numpages);
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>>  int set_memory_encrypted(unsigned long addr, int numpages);
>>  int set_memory_decrypted(unsigned long addr, int numpages);
>> +#endif
>>
>>  int set_memory_array_uc(unsigned long *addr, int addrinarray);
>>  int set_memory_array_wc(unsigned long *addr, int addrinarray);
>
> Hmm, why is this ifdeffery creeping in now?
>
> Just supply !CONFIG_AMD_MEM_ENCRYPT versions which don't do anything but
> return the address.

This was added because the set_memory_decrypted() call is now called
from kernel/kexec_core.c.  And since all the set_memory() functions
are defined in an arch include I had to swizzle things around. I think
I should probably do something similar to the SWIOTLB support and have
a __weak function to alter the memory area attributes.

>
>> diff --git a/arch/x86/include/asm/init.h b/arch/x86/include/asm/init.h
>> index 737da62..b2ec511 100644
>> --- a/arch/x86/include/asm/init.h
>> +++ b/arch/x86/include/asm/init.h
>> @@ -6,6 +6,7 @@ struct x86_mapping_info {
>>  	void *context;			 /* context for alloc_pgt_page */
>>  	unsigned long pmd_flag;		 /* page flag for PMD entry */
>>  	unsigned long offset;		 /* ident mapping offset */
>> +	unsigned long kernpg_flag;	 /* kernel pagetable flag override */
>>  };
>>
>>  int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index 5a17f1b..1fd5426 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -64,6 +64,16 @@ static inline u64 sme_dma_mask(void)
>>  	return 0ULL;
>>  }
>>
>> +static inline int set_memory_encrypted(unsigned long vaddr, int numpages)
>> +{
>> +	return 0;
>> +}
>> +
>> +static inline int set_memory_decrypted(unsigned long vaddr, int numpages)
>> +{
>> +	return 0;
>> +}
>> +
>>  #endif
>>
>>  static inline void __init sme_early_encrypt(resource_size_t paddr,
>> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
>> index f00e70f..456c5cc 100644
>> --- a/arch/x86/include/asm/pgtable_types.h
>> +++ b/arch/x86/include/asm/pgtable_types.h
>> @@ -213,6 +213,7 @@ enum page_cache_mode {
>>  #define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
>>  #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
>>  #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
>> +#define PAGE_KERNEL_EXEC_NOENC	__pgprot(__PAGE_KERNEL_EXEC)
>>  #define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
>>  #define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
>>  #define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
>> diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
>> index 307b1f4..b01648c 100644
>> --- a/arch/x86/kernel/machine_kexec_64.c
>> +++ b/arch/x86/kernel/machine_kexec_64.c
>> @@ -76,7 +76,7 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>>  		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>>  	}
>>  	pte = pte_offset_kernel(pmd, vaddr);
>> -	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
>> +	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC_NOENC));
>>  	return 0;
>>  err:
>>  	free_transition_pgtable(image);
>> @@ -104,6 +104,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
>>  		.alloc_pgt_page	= alloc_pgt_page,
>>  		.context	= image,
>>  		.pmd_flag	= __PAGE_KERNEL_LARGE_EXEC,
>> +		.kernpg_flag	= _KERNPG_TABLE_NOENC,
>>  	};
>>  	unsigned long mstart, mend;
>>  	pgd_t *level4p;
>> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
>> index 3ed869c..9b01261 100644
>> --- a/arch/x86/kernel/process.c
>> +++ b/arch/x86/kernel/process.c
>> @@ -279,8 +279,43 @@ bool xen_set_default_idle(void)
>>  	return ret;
>>  }
>>  #endif
>> -void stop_this_cpu(void *dummy)
>> +
>> +static bool is_smt_thread(int cpu)
>>  {
>> +#ifdef CONFIG_SCHED_SMT
>> +	if (cpumask_test_cpu(smp_processor_id(), cpu_smt_mask(cpu)))
>> +		return true;
>> +#endif
>
> No, no sched stuff in here. Just
>
> 	if (cpumask_test_cpu(smp_processor_id(), topology_sibling_cpumask(cpu)))

Ah, ok, much nicer.

>
>
>> +	return false;
>> +}
>> +
>> +void stop_this_cpu(void *data)
>> +{
>> +	atomic_t *stopping_cpu = data;
>> +	bool do_cache_disable = false;
>> +	bool do_wbinvd = false;
>> +
>> +	if (stopping_cpu) {
>> +		int stopping_id = atomic_read(stopping_cpu);
>> +		struct cpuinfo_x86 *c = &cpu_data(stopping_id);
>> +
>> +		/*
>> +		 * If the processor supports SME then we need to clear
>> +		 * out cache information before halting it because we could
>> +		 * be performing a kexec. With kexec, going from SME
>> +		 * inactive to SME active requires clearing cache entries
>> +		 * so that addresses without the encryption bit set don't
>> +		 * corrupt the same physical address that has the encryption
>> +		 * bit set when caches are flushed. If this is not an SMT
>> +		 * thread of the stopping CPU then we disable caching at this
>> +		 * point to keep the cache clean.
>> +		 */
>> +		if (cpu_has(c, X86_FEATURE_SME)) {
>> +			do_cache_disable = !is_smt_thread(stopping_id);
>> +			do_wbinvd = true;
>> +		}
>> +	}
>
> Let's simplify this (diff ontop of yours). Notice the sme_active() call
> in there - I believe we want to do this only when SME is active - not on
> any CPU which merely supports SME.

No, because we could be going from SME not active and rebooting using
kexec to a state where SME is active.  This is where the cache line
issue can arise.

>
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index 9b012612698d..e771d7a42e49 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -296,9 +296,6 @@ void stop_this_cpu(void *data)
>  	bool do_wbinvd = false;
>
>  	if (stopping_cpu) {
> -		int stopping_id = atomic_read(stopping_cpu);
> -		struct cpuinfo_x86 *c = &cpu_data(stopping_id);
> -
>  		/*
>  		 * If the processor supports SME then we need to clear
>  		 * out cache information before halting it because we could
> @@ -310,8 +307,8 @@ void stop_this_cpu(void *data)
>  		 * thread of the stopping CPU then we disable caching at this
>  		 * point to keep the cache clean.
>  		 */
> -		if (cpu_has(c, X86_FEATURE_SME)) {
> -			do_cache_disable = !is_smt_thread(stopping_id);
> +		if (sme_active()) {
> +			do_cache_disable = !is_smt_thread(atomic_read(stopping_cpu));
>  			do_wbinvd = true;
>  		}
>  	}
>
>>  	local_irq_disable();
>>  	/*
>>  	 * Remove this CPU:
>> @@ -289,6 +324,12 @@ void stop_this_cpu(void *dummy)
>>  	disable_local_APIC();
>>  	mcheck_cpu_clear(this_cpu_ptr(&cpu_info));
>>
>> +	if (do_cache_disable)
>> +		write_cr0(read_cr0() | X86_CR0_CD);
>
> Question: what clears CD back again? The CPU online path?

Yes, when the CPU comes back online the cache is re-enabled.

>
>> +
>> +	if (do_wbinvd)
>> +		wbinvd();
>> +
>
> Ok, so this whole shebang is pretty much crippling the machine.
> And, AFAICT, you're doing this now from smp_stop_nmi_callback() and
> smp_reboot_interrupt() as they both pass a !NULL arg to stop_this_cpu().

I'll take a closer look at the sysfs support to see how moving a cpu
to/from online is affected.

>
> And AFAICT those are not all cases where we kexec.

Yes, kexec can be invoked through a reboot command.
>
> What you need instead, IMO, is __crash_kexec() ->
> machine_crash_shutdown() -> native_machine_crash_shutdown() and put all
> the SME special handling there.
>
> I *think*.

I'll take a closer look at the kexec path to see what can be done. I
might be able to do something with determining if SME is configured
in the kernel and what the default SME state is combined with checking
the command line of the kernel being kexeced.

Thanks,
Tom

>
>>  	for (;;)
>>  		halt();
>>  }
>
> ...
>
>> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
>> index 9710f5c..46cc89d 100644
>> --- a/arch/x86/mm/pageattr.c
>> +++ b/arch/x86/mm/pageattr.c
>> @@ -1742,6 +1742,7 @@ int set_memory_4k(unsigned long addr, int numpages)
>>  					__pgprot(0), 1, 0, NULL);
>>  }
>>
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>>  static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
>>  {
>>  	struct cpa_data cpa;
>> @@ -1807,6 +1808,7 @@ int set_memory_decrypted(unsigned long addr, int numpages)
>>  	return __set_memory_enc_dec(addr, numpages, false);
>>  }
>>  EXPORT_SYMBOL(set_memory_decrypted);
>> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
>
> Btw, I don't see those things used in modules to justify the
> EXPORT_SYMBOL(). And it should be EXPORT_SYMBOL_GPL() since it is a new
> symbol.

Ok.

>
> So you could put those wrappers in a header and do the ifdeffery there and
> __set_memory_enc_dec() you can do like this:

I'll look at making it cleaner. It would be simple if all the
set_memory() functions weren't arch specific. The earlier response about
making it an arch callback function might be best.

>
> static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
> {
> 	if (!IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT))
> 		return 0;
>
> ...
>
> }
>
> so that you can save yourself the ifdeffery. The compiler would still
> parse the function body so everything else used in there would have to
> be defined too, even in the !CONFIG_AMD_MEM_ENCRYPT case.
>
>>
>>  int set_pages_uc(struct page *page, int numpages)
>>  {
>> diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
>> index 6829ff1..913cf80 100644
>> --- a/include/linux/mem_encrypt.h
>> +++ b/include/linux/mem_encrypt.h
>> @@ -34,6 +34,16 @@ static inline u64 sme_dma_mask(void)
>>  	return 0ULL;
>>  }
>>
>> +static inline int set_memory_encrypted(unsigned long vaddr, int numpages)
>> +{
>> +	return 0;
>> +}
>> +
>> +static inline int set_memory_decrypted(unsigned long vaddr, int numpages)
>> +{
>> +	return 0;
>> +}
>> +
>>  #endif
>>
>>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
>> index 5617cc4..ab62f41 100644
>> --- a/kernel/kexec_core.c
>> +++ b/kernel/kexec_core.c
>> @@ -38,6 +38,7 @@
>>  #include <linux/syscore_ops.h>
>>  #include <linux/compiler.h>
>>  #include <linux/hugetlb.h>
>> +#include <linux/mem_encrypt.h>
>>
>>  #include <asm/page.h>
>>  #include <asm/sections.h>
>> @@ -315,6 +316,18 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
>>  		count = 1 << order;
>>  		for (i = 0; i < count; i++)
>>  			SetPageReserved(pages + i);
>> +
>> +		/*
>> +		 * If SME is active we need to be sure that kexec pages are
>> +		 * not encrypted because when we boot to the new kernel the
>> +		 * pages won't be accessed encrypted (initially).
>> +		 */
>> +		if (sme_active()) {
>> +			void *vaddr = page_address(pages);
>> +
>> +			set_memory_decrypted((unsigned long)vaddr, count);
>> +			memset(vaddr, 0, count * PAGE_SIZE);
>
> Why the memset?

Since the memory attribute was changed, a page with all zeroes in memory
when it was an encrypted page would now read as random data (since the
data on the page won't be decrypted). So after setting the attribute
the memset just clears it to zero. I guess I can to the memset only if
__GFP_ZERO is present inf gfp_mask.

>
>> +		}
>>  	}
>>
>>  	return pages;
>> @@ -326,6 +339,17 @@ static void kimage_free_pages(struct page *page)
>>
>>  	order = page_private(page);
>>  	count = 1 << order;
>> +
>> +	/*
>> +	 * If SME is active we need to reset the pages back to being an
>> +	 * encrypted mapping before freeing them.
>> +	 */
>> +	if (sme_active()) {
>> +		void *vaddr = page_address(page);
>> +
>> +		set_memory_encrypted((unsigned long)vaddr, count);
>
>         if (sme_active())
>                 set_memory_encrypted((unsigned long)page_address(page), count);
>
> looks ok to me too.

Ok.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
