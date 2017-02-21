Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2D676B0388
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:18:20 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v85so167299564oia.4
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 09:18:20 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0054.outbound.protection.outlook.com. [104.47.38.54])
        by mx.google.com with ESMTPS id x188si1581765oia.299.2017.02.21.09.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 09:18:19 -0800 (PST)
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
 memory encryption
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
 <20170220152152.apdfjjuvu2u56tik@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <78e1d42a-3a7b-2508-28d6-38a9d45a1c55@amd.com>
Date: Tue, 21 Feb 2017 11:18:08 -0600
MIME-Version: 1.0
In-Reply-To: <20170220152152.apdfjjuvu2u56tik@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/20/2017 9:21 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:43:32AM -0600, Tom Lendacky wrote:
>> Adding general kernel support for memory encryption includes:
>> - Modify and create some page table macros to include the Secure Memory
>>   Encryption (SME) memory encryption mask
>
> Let's not write it like some technical document: "Secure Memory
> Encryption (SME) mask" is perfectly fine.

Ok.

>
>> - Modify and create some macros for calculating physical and virtual
>>   memory addresses
>> - Provide an SME initialization routine to update the protection map with
>>   the memory encryption mask so that it is used by default
>> - #undef CONFIG_AMD_MEM_ENCRYPT in the compressed boot path
>
> These bulletpoints talk about the "what" this patch does but they should
> talk about the "why".
>
> For example, it doesn't say why we're using _KERNPG_TABLE_NOENC when
> building the initial pagetable and that would be an interesting piece of
> information.

I'll work on re-wording this to give a better understanding of the
patch changes.

>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/boot/compressed/pagetable.c |    7 +++++
>>  arch/x86/include/asm/fixmap.h        |    7 +++++
>>  arch/x86/include/asm/mem_encrypt.h   |   14 +++++++++++
>>  arch/x86/include/asm/page.h          |    4 ++-
>>  arch/x86/include/asm/pgtable.h       |   26 ++++++++++++++------
>>  arch/x86/include/asm/pgtable_types.h |   45 ++++++++++++++++++++++------------
>>  arch/x86/include/asm/processor.h     |    3 ++
>>  arch/x86/kernel/espfix_64.c          |    2 +-
>>  arch/x86/kernel/head64.c             |   12 ++++++++-
>>  arch/x86/kernel/head_64.S            |   18 +++++++-------
>>  arch/x86/mm/kasan_init_64.c          |    4 ++-
>>  arch/x86/mm/mem_encrypt.c            |   20 +++++++++++++++
>>  arch/x86/mm/pageattr.c               |    3 ++
>>  include/asm-generic/pgtable.h        |    8 ++++++
>>  14 files changed, 133 insertions(+), 40 deletions(-)
>>
>> diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
>> index 56589d0..411c443 100644
>> --- a/arch/x86/boot/compressed/pagetable.c
>> +++ b/arch/x86/boot/compressed/pagetable.c
>> @@ -15,6 +15,13 @@
>>  #define __pa(x)  ((unsigned long)(x))
>>  #define __va(x)  ((void *)((unsigned long)(x)))
>>
>> +/*
>> + * The pgtable.h and mm/ident_map.c includes make use of the SME related
>> + * information which is not used in the compressed image support. Un-define
>> + * the SME support to avoid any compile and link errors.
>> + */
>> +#undef CONFIG_AMD_MEM_ENCRYPT
>> +
>>  #include "misc.h"
>>
>>  /* These actually do the work of building the kernel identity maps. */
>> diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
>> index 8554f96..83e91f0 100644
>> --- a/arch/x86/include/asm/fixmap.h
>> +++ b/arch/x86/include/asm/fixmap.h
>> @@ -153,6 +153,13 @@ static inline void __set_fixmap(enum fixed_addresses idx,
>>  }
>>  #endif
>>
>> +/*
>> + * Fixmap settings used with memory encryption
>> + *   - FIXMAP_PAGE_NOCACHE is used for MMIO so make sure the memory
>> + *     encryption mask is not part of the page attributes
>
> Make that a regular sentence.

Ok.

>
>> + */
>> +#define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
>> +
>>  #include <asm-generic/fixmap.h>
>>
>>  #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index ccc53b0..547989d 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -15,6 +15,8 @@
>>
>>  #ifndef __ASSEMBLY__
>>
>> +#include <linux/init.h>
>> +
>>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>>
>>  extern unsigned long sme_me_mask;
>> @@ -24,6 +26,11 @@ static inline bool sme_active(void)
>>  	return (sme_me_mask) ? true : false;
>>  }
>>
>> +void __init sme_early_init(void);
>> +
>> +#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
>> +#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
>
> Right, I know we did talk about those but in looking more into the
> future, you'd have to go educate people to use the __sme_pa* variants.
> Otherwise, we'd have to go and fix up code on AMD SME machines because
> someone used __pa_* variants where someone should have been using the
> __sma_pa_* variants.
>
> IOW, should we simply put sme_me_mask in the actual __pa* macro
> definitions?
>
> Or are we saying that the __sme_pa* versions you have above are
> the special ones and we need them only in a handful of places like
> load_cr3(), for example...? And the __pa_* ones should return the
> physical address without the SME mask because callers don't need it?

It's the latter.  It's really only used for working with values that
will either be written to or read from cr3.  I'll add some comments
around the macros as well as expand on it in the commit message.

>
>> +
>>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>>
>>  #ifndef sme_me_mask
>> @@ -35,6 +42,13 @@ static inline bool sme_active(void)
>>  }
>>  #endif
>>
>> +static inline void __init sme_early_init(void)
>> +{
>> +}
>> +
>> +#define __sme_pa		__pa
>> +#define __sme_pa_nodebug	__pa_nodebug
>> +
>>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>>
>>  #endif	/* __ASSEMBLY__ */
>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
>> index cf8f619..b1f7bf6 100644
>> --- a/arch/x86/include/asm/page.h
>> +++ b/arch/x86/include/asm/page.h
>> @@ -15,6 +15,8 @@
>>
>>  #ifndef __ASSEMBLY__
>>
>> +#include <asm/mem_encrypt.h>
>> +
>>  struct page;
>>
>>  #include <linux/range.h>
>> @@ -55,7 +57,7 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
>>  	__phys_addr_symbol(__phys_reloc_hide((unsigned long)(x)))
>>
>>  #ifndef __va
>> -#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
>> +#define __va(x)			((void *)(((unsigned long)(x) & ~sme_me_mask) + PAGE_OFFSET))
>
> You have a bunch of places where you remove the enc mask:
>
> 	address & ~sme_me_mask
>
> so you could do:
>
> #define __sme_unmask(x)		((unsigned long)(x) & ~sme_me_mask)
>
> and use it everywhere. "unmask" is what I could think of, there should
> be a better, short name for it...
>

Ok, I'll try and come up with something...  maybe __sme_rm or
__sme_clear (__sme_clr).

>>  #endif
>>
>>  #define __boot_va(x)		__va(x)
>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
>> index 2d81161..b41caab 100644
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -3,6 +3,7 @@
>
> ...
>
>> @@ -563,8 +575,7 @@ static inline unsigned long pmd_page_vaddr(pmd_t pmd)
>>   * Currently stuck as a macro due to indirect forward reference to
>>   * linux/mmzone.h's __section_mem_map_addr() definition:
>>   */
>> -#define pmd_page(pmd)		\
>> -	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
>> +#define pmd_page(pmd)	pfn_to_page(pmd_pfn(pmd))
>>
>>  /*
>>   * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
>> @@ -632,8 +643,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
>>   * Currently stuck as a macro due to indirect forward reference to
>>   * linux/mmzone.h's __section_mem_map_addr() definition:
>>   */
>> -#define pud_page(pud)		\
>> -	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
>> +#define pud_page(pud)	pfn_to_page(pud_pfn(pud))
>>
>>  /* Find an entry in the second-level page table.. */
>>  static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
>> @@ -673,7 +683,7 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
>>   * Currently stuck as a macro due to indirect forward reference to
>>   * linux/mmzone.h's __section_mem_map_addr() definition:
>>   */
>> -#define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
>> +#define pgd_page(pgd)	pfn_to_page(pgd_pfn(pgd))
>>
>>  /* to find an entry in a page-table-directory. */
>>  static inline unsigned long pud_index(unsigned long address)
>
> This conversion to *_pfn() is an unrelated cleanup. Pls carve it out and
> put it in the front of the patchset as a separate patch.

Will do.

>
> ...
>
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index b99d469..d71df97 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -11,6 +11,10 @@
>>   */
>>
>>  #include <linux/linkage.h>
>> +#include <linux/init.h>
>> +#include <linux/mm.h>
>> +
>> +extern pmdval_t early_pmd_flags;
>
> WARNING: externs should be avoided in .c files
> #476: FILE: arch/x86/mm/mem_encrypt.c:17:
> +extern pmdval_t early_pmd_flags;

I'll add early_pmd_flags to include/asm/pgtable.h file and remove
the extern reference.

Thanks,
Tom

>
>>  /*
>>   * Since SME related variables are set early in the boot process they must
>> @@ -19,3 +23,19 @@
>>   */
>>  unsigned long sme_me_mask __section(.data) = 0;
>>  EXPORT_SYMBOL_GPL(sme_me_mask);
>> +
>> +void __init sme_early_init(void)
>> +{
>> +	unsigned int i;
>> +
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	early_pmd_flags |= sme_me_mask;
>> +
>> +	__supported_pte_mask |= sme_me_mask;
>> +
>> +	/* Update the protection map with memory encryption mask */
>> +	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
>> +		protection_map[i] = pgprot_encrypted(protection_map[i]);
>> +}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
