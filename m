Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD74E6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:43:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m5so19223437pgn.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:43:25 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0044.outbound.protection.outlook.com. [104.47.36.44])
        by mx.google.com with ESMTPS id d2si14315pge.232.2017.06.15.10.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 10:43:24 -0700 (PDT)
Subject: Re: [PATCH v6 30/34] x86/mm, kexec: Allow kexec to be used with SME
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191827.28645.93989.stgit@tlendack-t1.amdoffice.net>
 <20170615100345.76pn5ruf6cm3ktpe@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8973bfc5-9d18-f98e-4c38-6452f5d81ebe@amd.com>
Date: Thu, 15 Jun 2017 12:43:13 -0500
MIME-Version: 1.0
In-Reply-To: <20170615100345.76pn5ruf6cm3ktpe@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/15/2017 5:03 AM, Borislav Petkov wrote:
> On Wed, Jun 07, 2017 at 02:18:27PM -0500, Tom Lendacky wrote:
>> Provide support so that kexec can be used to boot a kernel when SME is
>> enabled.
>>
>> Support is needed to allocate pages for kexec without encryption.  This
>> is needed in order to be able to reboot in the kernel in the same manner
>> as originally booted.
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
>>   arch/x86/include/asm/kexec.h         |    8 ++++++++
>>   arch/x86/include/asm/pgtable_types.h |    1 +
>>   arch/x86/kernel/machine_kexec_64.c   |   35 +++++++++++++++++++++++++++++++++-
>>   arch/x86/kernel/process.c            |   17 +++++++++++++++--
>>   arch/x86/mm/ident_map.c              |   12 ++++++++----
>>   include/linux/kexec.h                |   14 ++++++++++++++
>>   kernel/kexec_core.c                  |    6 ++++++
>>   8 files changed, 87 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/init.h b/arch/x86/include/asm/init.h
>> index 474eb8c..05c4aa0 100644
>> --- a/arch/x86/include/asm/init.h
>> +++ b/arch/x86/include/asm/init.h
>> @@ -7,6 +7,7 @@ struct x86_mapping_info {
>>   	unsigned long page_flag;	 /* page flag for PMD or PUD entry */
>>   	unsigned long offset;		 /* ident mapping offset */
>>   	bool direct_gbpages;		 /* PUD level 1GB page support */
>> +	unsigned long kernpg_flag;	 /* kernel pagetable flag override */
>>   };
>>   
>>   int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
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
>> index 6f5ca4e..35e069a 100644
>> --- a/arch/x86/kernel/machine_kexec_64.c
>> +++ b/arch/x86/kernel/machine_kexec_64.c
>> @@ -87,7 +87,7 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>>   		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>>   	}
>>   	pte = pte_offset_kernel(pmd, vaddr);
>> -	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
>> +	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC_NOENC));
>>   	return 0;
>>   err:
>>   	free_transition_pgtable(image);
>> @@ -115,6 +115,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
>>   		.alloc_pgt_page	= alloc_pgt_page,
>>   		.context	= image,
>>   		.page_flag	= __PAGE_KERNEL_LARGE_EXEC,
>> +		.kernpg_flag	= _KERNPG_TABLE_NOENC,
>>   	};
>>   	unsigned long mstart, mend;
>>   	pgd_t *level4p;
>> @@ -602,3 +603,35 @@ void arch_kexec_unprotect_crashkres(void)
>>   {
>>   	kexec_mark_crashkres(false);
>>   }
>> +
>> +int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp)
>> +{
>> +	int ret;
>> +
>> +	if (sme_active()) {
> 
> What happened to flipping the logic and saving an indentation level here?
> 
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
> 
> This is still zeroing the memory a second time. That function has missed
> all my comments from last time.

Hmmm...  not sure what happened, I thought I made changes here.  I'll
take care of it.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
