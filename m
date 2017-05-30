Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE106B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 13:46:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d142so99523739oib.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 10:46:36 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0081.outbound.protection.outlook.com. [104.47.37.81])
        by mx.google.com with ESMTPS id w131si5698597oia.109.2017.05.30.10.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 10:46:34 -0700 (PDT)
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <5927AC6E.8080209@redhat.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <de4d2efc-6636-4120-98d9-7fdf4707f68d@amd.com>
Date: Tue, 30 May 2017 12:46:14 -0500
MIME-Version: 1.0
In-Reply-To: <5927AC6E.8080209@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xlpang@redhat.com, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 5/25/2017 11:17 PM, Xunlei Pang wrote:
> On 04/19/2017 at 05:21 AM, Tom Lendacky wrote:
>> Provide support so that kexec can be used to boot a kernel when SME is
>> enabled.
>>
>> Support is needed to allocate pages for kexec without encryption.  This
>> is needed in order to be able to reboot in the kernel in the same manner
>> as originally booted.
> 
> Hi Tom,
> 
> Looks like kdump will break, I didn't see the similar handling for kdump cases, see kernel:
>      kimage_alloc_crash_control_pages(), kimage_load_crash_segment(), etc. >
> We need to support kdump with SME, kdump kernel/initramfs/purgatory/elfcorehdr/etc
> are all loaded into the reserved memory(see crashkernel=X) by userspace kexec-tools.
> I think a straightforward way would be to mark the whole reserved memory range without
> encryption before loading all the kexec segments for kdump, I guess we can handle this
> easily in arch_kexec_unprotect_crashkres().

Yes, that would work.

> 
> Moreover, now that "elfcorehdr=X" is left as decrypted, it needs to be remapped to the
> encrypted data.

This is an area that I'm not familiar with, so I don't completely
understand the flow in regards to where/when/how the ELF headers are
copied and what needs to be done.

Can you elaborate a bit on this?

Thanks,
Tom

> 
> Regards,
> Xunlei
> 
>>
>> Additionally, when shutting down all of the CPUs we need to be sure to
>> flush the caches and then halt. This is needed when booting from a state
>> where SME was not active into a state where SME is active (or vice-versa).
>> Without these steps, it is possible for cache lines to exist for the same
>> physical location but tagged both with and without the encryption bit. This
>> can cause random memory corruption when caches are flushed depending on
>> which cacheline is written last.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/init.h          |    1 +
>>   arch/x86/include/asm/irqflags.h      |    5 +++++
>>   arch/x86/include/asm/kexec.h         |    8 ++++++++
>>   arch/x86/include/asm/pgtable_types.h |    1 +
>>   arch/x86/kernel/machine_kexec_64.c   |   35 +++++++++++++++++++++++++++++++++-
>>   arch/x86/kernel/process.c            |   26 +++++++++++++++++++++++--
>>   arch/x86/mm/ident_map.c              |   11 +++++++----
>>   include/linux/kexec.h                |   14 ++++++++++++++
>>   kernel/kexec_core.c                  |    7 +++++++
>>   9 files changed, 101 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/init.h b/arch/x86/include/asm/init.h
>> index 737da62..b2ec511 100644
>> --- a/arch/x86/include/asm/init.h
>> +++ b/arch/x86/include/asm/init.h
>> @@ -6,6 +6,7 @@ struct x86_mapping_info {
>>   	void *context;			 /* context for alloc_pgt_page */
>>   	unsigned long pmd_flag;		 /* page flag for PMD entry */
>>   	unsigned long offset;		 /* ident mapping offset */
>> +	unsigned long kernpg_flag;	 /* kernel pagetable flag override */
>>   };
>>   
>>   int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
>> diff --git a/arch/x86/include/asm/irqflags.h b/arch/x86/include/asm/irqflags.h
>> index ac7692d..38b5920 100644
>> --- a/arch/x86/include/asm/irqflags.h
>> +++ b/arch/x86/include/asm/irqflags.h
>> @@ -58,6 +58,11 @@ static inline __cpuidle void native_halt(void)
>>   	asm volatile("hlt": : :"memory");
>>   }
>>   
>> +static inline __cpuidle void native_wbinvd_halt(void)
>> +{
>> +	asm volatile("wbinvd; hlt" : : : "memory");
>> +}
>> +
>>   #endif
>>   
>>   #ifdef CONFIG_PARAVIRT
>> diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
>> index 70ef205..e8183ac 100644
>> --- a/arch/x86/include/asm/kexec.h
>> +++ b/arch/x86/include/asm/kexec.h
>> @@ -207,6 +207,14 @@ struct kexec_entry64_regs {
>>   	uint64_t r15;
>>   	uint64_t rip;
>>   };
>> +
>> +extern int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages,
>> +				       gfp_t gfp);
>> +#define arch_kexec_post_alloc_pages arch_kexec_post_alloc_pages
>> +
>> +extern void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages);
>> +#define arch_kexec_pre_free_pages arch_kexec_pre_free_pages
>> +
>>   #endif
>>   
>>   typedef void crash_vmclear_fn(void);
>> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
>> index ce8cb1c..0f326f4 100644
>> --- a/arch/x86/include/asm/pgtable_types.h
>> +++ b/arch/x86/include/asm/pgtable_types.h
>> @@ -213,6 +213,7 @@ enum page_cache_mode {
>>   #define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
>>   #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
>>   #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
>> +#define PAGE_KERNEL_EXEC_NOENC	__pgprot(__PAGE_KERNEL_EXEC)
>>   #define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
>>   #define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
>>   #define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
>> diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
>> index 085c3b3..11c0ca9 100644
>> --- a/arch/x86/kernel/machine_kexec_64.c
>> +++ b/arch/x86/kernel/machine_kexec_64.c
>> @@ -86,7 +86,7 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>>   		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>>   	}
>>   	pte = pte_offset_kernel(pmd, vaddr);
>> -	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
>> +	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC_NOENC));
>>   	return 0;
>>   err:
>>   	free_transition_pgtable(image);
>> @@ -114,6 +114,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
>>   		.alloc_pgt_page	= alloc_pgt_page,
>>   		.context	= image,
>>   		.pmd_flag	= __PAGE_KERNEL_LARGE_EXEC,
>> +		.kernpg_flag	= _KERNPG_TABLE_NOENC,
>>   	};
>>   	unsigned long mstart, mend;
>>   	pgd_t *level4p;
>> @@ -597,3 +598,35 @@ void arch_kexec_unprotect_crashkres(void)
>>   {
>>   	kexec_mark_crashkres(false);
>>   }
>> +
>> +int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp)
>> +{
>> +	int ret;
>> +
>> +	if (sme_active()) {
>> +		/*
>> +		 * If SME is active we need to be sure that kexec pages are
>> +		 * not encrypted because when we boot to the new kernel the
>> +		 * pages won't be accessed encrypted (initially).
>> +		 */
>> +		ret = set_memory_decrypted((unsigned long)vaddr, pages);
>> +		if (ret)
>> +			return ret;
>> +
>> +		if (gfp & __GFP_ZERO)
>> +			memset(vaddr, 0, pages * PAGE_SIZE);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages)
>> +{
>> +	if (sme_active()) {
>> +		/*
>> +		 * If SME is active we need to reset the pages back to being
>> +		 * an encrypted mapping before freeing them.
>> +		 */
>> +		set_memory_encrypted((unsigned long)vaddr, pages);
>> +	}
>> +}
>> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
>> index 0bb8842..f4e5de6 100644
>> --- a/arch/x86/kernel/process.c
>> +++ b/arch/x86/kernel/process.c
>> @@ -24,6 +24,7 @@
>>   #include <linux/cpuidle.h>
>>   #include <trace/events/power.h>
>>   #include <linux/hw_breakpoint.h>
>> +#include <linux/kexec.h>
>>   #include <asm/cpu.h>
>>   #include <asm/apic.h>
>>   #include <asm/syscalls.h>
>> @@ -355,8 +356,25 @@ bool xen_set_default_idle(void)
>>   	return ret;
>>   }
>>   #endif
>> +
>>   void stop_this_cpu(void *dummy)
>>   {
>> +	bool do_wbinvd_halt = false;
>> +
>> +	if (kexec_in_progress && boot_cpu_has(X86_FEATURE_SME)) {
>> +		/*
>> +		 * If we are performing a kexec and the processor supports
>> +		 * SME then we need to clear out cache information before
>> +		 * halting. With kexec, going from SME inactive to SME active
>> +		 * requires clearing cache entries so that addresses without
>> +		 * the encryption bit set don't corrupt the same physical
>> +		 * address that has the encryption bit set when caches are
>> +		 * flushed. Perform a wbinvd followed by a halt to achieve
>> +		 * this.
>> +		 */
>> +		do_wbinvd_halt = true;
>> +	}
>> +
>>   	local_irq_disable();
>>   	/*
>>   	 * Remove this CPU:
>> @@ -365,8 +383,12 @@ void stop_this_cpu(void *dummy)
>>   	disable_local_APIC();
>>   	mcheck_cpu_clear(this_cpu_ptr(&cpu_info));
>>   
>> -	for (;;)
>> -		halt();
>> +	for (;;) {
>> +		if (do_wbinvd_halt)
>> +			native_wbinvd_halt();
>> +		else
>> +			halt();
>> +	}
>>   }
>>   
>>   /*
>> diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
>> index 04210a2..2c9fd3e 100644
>> --- a/arch/x86/mm/ident_map.c
>> +++ b/arch/x86/mm/ident_map.c
>> @@ -20,6 +20,7 @@ static void ident_pmd_init(struct x86_mapping_info *info, pmd_t *pmd_page,
>>   static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
>>   			  unsigned long addr, unsigned long end)
>>   {
>> +	unsigned long kernpg_flag = info->kernpg_flag ? : _KERNPG_TABLE;
>>   	unsigned long next;
>>   
>>   	for (; addr < end; addr = next) {
>> @@ -39,7 +40,7 @@ static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
>>   		if (!pmd)
>>   			return -ENOMEM;
>>   		ident_pmd_init(info, pmd, addr, next);
>> -		set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE));
>> +		set_pud(pud, __pud(__pa(pmd) | kernpg_flag));
>>   	}
>>   
>>   	return 0;
>> @@ -48,6 +49,7 @@ static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
>>   static int ident_p4d_init(struct x86_mapping_info *info, p4d_t *p4d_page,
>>   			  unsigned long addr, unsigned long end)
>>   {
>> +	unsigned long kernpg_flag = info->kernpg_flag ? : _KERNPG_TABLE;
>>   	unsigned long next;
>>   
>>   	for (; addr < end; addr = next) {
>> @@ -67,7 +69,7 @@ static int ident_p4d_init(struct x86_mapping_info *info, p4d_t *p4d_page,
>>   		if (!pud)
>>   			return -ENOMEM;
>>   		ident_pud_init(info, pud, addr, next);
>> -		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
>> +		set_p4d(p4d, __p4d(__pa(pud) | kernpg_flag));
>>   	}
>>   
>>   	return 0;
>> @@ -76,6 +78,7 @@ static int ident_p4d_init(struct x86_mapping_info *info, p4d_t *p4d_page,
>>   int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
>>   			      unsigned long pstart, unsigned long pend)
>>   {
>> +	unsigned long kernpg_flag = info->kernpg_flag ? : _KERNPG_TABLE;
>>   	unsigned long addr = pstart + info->offset;
>>   	unsigned long end = pend + info->offset;
>>   	unsigned long next;
>> @@ -104,14 +107,14 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
>>   		if (result)
>>   			return result;
>>   		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
>> -			set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
>> +			set_pgd(pgd, __pgd(__pa(p4d) | kernpg_flag));
>>   		} else {
>>   			/*
>>   			 * With p4d folded, pgd is equal to p4d.
>>   			 * The pgd entry has to point to the pud page table in this case.
>>   			 */
>>   			pud_t *pud = pud_offset(p4d, 0);
>> -			set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE));
>> +			set_pgd(pgd, __pgd(__pa(pud) | kernpg_flag));
>>   		}
>>   	}
>>   
>> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
>> index d419d0e..1c76e3b 100644
>> --- a/include/linux/kexec.h
>> +++ b/include/linux/kexec.h
>> @@ -383,6 +383,20 @@ static inline void *boot_phys_to_virt(unsigned long entry)
>>   	return phys_to_virt(boot_phys_to_phys(entry));
>>   }
>>   
>> +#ifndef arch_kexec_post_alloc_pages
>> +static inline int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages,
>> +					      gfp_t gfp)
>> +{
>> +	return 0;
>> +}
>> +#endif
>> +
>> +#ifndef arch_kexec_pre_free_pages
>> +static inline void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages)
>> +{
>> +}
>> +#endif
>> +
>>   #else /* !CONFIG_KEXEC_CORE */
>>   struct pt_regs;
>>   struct task_struct;
>> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
>> index bfe62d5..bb5e7e3 100644
>> --- a/kernel/kexec_core.c
>> +++ b/kernel/kexec_core.c
>> @@ -38,6 +38,7 @@
>>   #include <linux/syscore_ops.h>
>>   #include <linux/compiler.h>
>>   #include <linux/hugetlb.h>
>> +#include <linux/mem_encrypt.h>
>>   
>>   #include <asm/page.h>
>>   #include <asm/sections.h>
>> @@ -315,6 +316,9 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
>>   		count = 1 << order;
>>   		for (i = 0; i < count; i++)
>>   			SetPageReserved(pages + i);
>> +
>> +		arch_kexec_post_alloc_pages(page_address(pages), count,
>> +					    gfp_mask);
>>   	}
>>   
>>   	return pages;
>> @@ -326,6 +330,9 @@ static void kimage_free_pages(struct page *page)
>>   
>>   	order = page_private(page);
>>   	count = 1 << order;
>> +
>> +	arch_kexec_pre_free_pages(page_address(page), count);
>> +
>>   	for (i = 0; i < count; i++)
>>   		ClearPageReserved(page + i);
>>   	__free_pages(page, order);
>>
>>
>> _______________________________________________
>> kexec mailing list
>> kexec@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/kexec
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
