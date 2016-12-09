Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C07866B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 09:26:57 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y205so16708927qkb.4
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 06:26:57 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0040.outbound.protection.outlook.com. [104.47.33.40])
        by mx.google.com with ESMTPS id d39si20158054qtf.148.2016.12.09.06.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 06:26:56 -0800 (PST)
Subject: Re: [RFC PATCH v3 10/20] Add support to access boot related data in
 the clear
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003631.3280.73292.stgit@tlendack-t1.amdoffice.net>
 <20161207131903.GU20785@codeblueprint.co.uk>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <8aebb166-12ae-64aa-bf1a-3f46fe8b52dd@amd.com>
Date: Fri, 9 Dec 2016 08:26:40 -0600
MIME-Version: 1.0
In-Reply-To: <20161207131903.GU20785@codeblueprint.co.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On 12/7/2016 7:19 AM, Matt Fleming wrote:
> On Wed, 09 Nov, at 06:36:31PM, Tom Lendacky wrote:
>> Boot data (such as EFI related data) is not encrypted when the system is
>> booted and needs to be accessed unencrypted.  Add support to apply the
>> proper attributes to the EFI page tables and to the early_memremap and
>> memremap APIs to identify the type of data being accessed so that the
>> proper encryption attribute can be applied.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/e820.h    |    1 
>>  arch/x86/kernel/e820.c         |   16 +++++++
>>  arch/x86/mm/ioremap.c          |   89 ++++++++++++++++++++++++++++++++++++++++
>>  arch/x86/platform/efi/efi_64.c |   12 ++++-
>>  drivers/firmware/efi/efi.c     |   33 +++++++++++++++
>>  include/linux/efi.h            |    2 +
>>  kernel/memremap.c              |    8 +++-
>>  mm/early_ioremap.c             |   18 +++++++-
>>  8 files changed, 172 insertions(+), 7 deletions(-)
>  
> FWIW, I think this version is an improvement over all the previous
> ones.
> 
> [...]
> 
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index ff542cd..ee347c2 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -20,6 +20,9 @@
>>  #include <asm/tlbflush.h>
>>  #include <asm/pgalloc.h>
>>  #include <asm/pat.h>
>> +#include <asm/e820.h>
>> +#include <asm/setup.h>
>> +#include <linux/efi.h>
>>  
>>  #include "physaddr.h"
>>  
>> @@ -418,6 +421,92 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>>  	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
>>  }
>>  
>> +static bool memremap_setup_data(resource_size_t phys_addr,
>> +				unsigned long size)
>> +{
>> +	u64 paddr;
>> +
>> +	if (phys_addr == boot_params.hdr.setup_data)
>> +		return true;
>> +
> 
> Why is the setup_data linked list not traversed when checking for
> matching addresses? Am I reading this incorrectly? I don't see how
> this can work.

Yeah, I caught that too after I sent this out. I think the best way to
handle this would be to create a list/array of setup data addresses in
the parse_setup_data() routine and then check the address against that
list in this routine.

> 
>> +	paddr = boot_params.efi_info.efi_memmap_hi;
>> +	paddr <<= 32;
>> +	paddr |= boot_params.efi_info.efi_memmap;
>> +	if (phys_addr == paddr)
>> +		return true;
>> +
>> +	paddr = boot_params.efi_info.efi_systab_hi;
>> +	paddr <<= 32;
>> +	paddr |= boot_params.efi_info.efi_systab;
>> +	if (phys_addr == paddr)
>> +		return true;
>> +
>> +	if (efi_table_address_match(phys_addr))
>> +		return true;
>> +
>> +	return false;
>> +}
>> +
>> +static bool memremap_apply_encryption(resource_size_t phys_addr,
>> +				      unsigned long size)
>> +{
>> +	/* SME is not active, just return true */
>> +	if (!sme_me_mask)
>> +		return true;
>> +
>> +	/* Check if the address is part of the setup data */
>> +	if (memremap_setup_data(phys_addr, size))
>> +		return false;
>> +
>> +	/* Check if the address is part of EFI boot/runtime data */
>> +	switch (efi_mem_type(phys_addr)) {
>> +	case EFI_BOOT_SERVICES_DATA:
>> +	case EFI_RUNTIME_SERVICES_DATA:
>> +		return false;
>> +	}
> 
> EFI_LOADER_DATA is notable by its absence.
> 
> We use that memory type for allocations inside of the EFI boot stub
> that are than used while the kernel is running. One use that comes to
> mind is for initrd files, see handle_cmdline_files().
> 
> Oh I see you handle that in PATCH 9, never mind.
> 
>> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
>> index 58b0f80..3f89179 100644
>> --- a/arch/x86/platform/efi/efi_64.c
>> +++ b/arch/x86/platform/efi/efi_64.c
>> @@ -221,7 +221,13 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>>  	if (efi_enabled(EFI_OLD_MEMMAP))
>>  		return 0;
>>  
>> -	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
>> +	/*
>> +	 * Since the PGD is encrypted, set the encryption mask so that when
>> +	 * this value is loaded into cr3 the PGD will be decrypted during
>> +	 * the pagetable walk.
>> +	 */
>> +	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
>> +
>>  	pgd = efi_pgd;
>>  
>>  	/*
> 
> Do all callers of __pa() in arch/x86 need fixing up like this?

No, currently this is only be needed when we're dealing with values that
will be used in the cr3 register.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
