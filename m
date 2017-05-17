Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3140D6B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 14:54:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so15321340pfh.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 11:54:53 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0048.outbound.protection.outlook.com. [104.47.38.48])
        by mx.google.com with ESMTPS id r11si2818718pfk.91.2017.05.17.11.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 May 2017 11:54:50 -0700 (PDT)
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
Date: Wed, 17 May 2017 13:54:39 -0500
MIME-Version: 1.0
In-Reply-To: <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/15/2017 1:35 PM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:19:21PM -0500, Tom Lendacky wrote:
>> Boot data (such as EFI related data) is not encrypted when the system is
>> booted because UEFI/BIOS does not run with SME active. In order to access
>> this data properly it needs to be mapped decrypted.
>>
>> The early_memremap() support is updated to provide an arch specific
>
> "Update early_memremap() to provide... "

Will do.

>
>> routine to modify the pagetable protection attributes before they are
>> applied to the new mapping. This is used to remove the encryption mask
>> for boot related data.
>>
>> The memremap() support is updated to provide an arch specific routine
>
> Ditto. Passive tone always reads harder than an active tone,
> "doer"-sentence.

Ditto.

>
>> to determine if RAM remapping is allowed.  RAM remapping will cause an
>> encrypted mapping to be generated. By preventing RAM remapping,
>> ioremap_cache() will be used instead, which will provide a decrypted
>> mapping of the boot related data.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/io.h |    4 +
>>  arch/x86/mm/ioremap.c     |  182 +++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/io.h        |    2
>>  kernel/memremap.c         |   20 ++++-
>>  mm/early_ioremap.c        |   18 ++++
>>  5 files changed, 219 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
>> index 7afb0e2..75f2858 100644
>> --- a/arch/x86/include/asm/io.h
>> +++ b/arch/x86/include/asm/io.h
>> @@ -381,4 +381,8 @@ extern int __must_check arch_phys_wc_add(unsigned long base,
>>  #define arch_io_reserve_memtype_wc arch_io_reserve_memtype_wc
>>  #endif
>>
>> +extern bool arch_memremap_do_ram_remap(resource_size_t offset, size_t size,
>> +				       unsigned long flags);
>> +#define arch_memremap_do_ram_remap arch_memremap_do_ram_remap
>> +
>>  #endif /* _ASM_X86_IO_H */
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index 9bfcb1f..bce0604 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -13,6 +13,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/vmalloc.h>
>>  #include <linux/mmiotrace.h>
>> +#include <linux/efi.h>
>>
>>  #include <asm/cacheflush.h>
>>  #include <asm/e820/api.h>
>> @@ -21,6 +22,7 @@
>>  #include <asm/tlbflush.h>
>>  #include <asm/pgalloc.h>
>>  #include <asm/pat.h>
>> +#include <asm/setup.h>
>>
>>  #include "physaddr.h"
>>
>> @@ -419,6 +421,186 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>>  	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
>>  }
>>
>> +/*
>> + * Examine the physical address to determine if it is an area of memory
>> + * that should be mapped decrypted.  If the memory is not part of the
>> + * kernel usable area it was accessed and created decrypted, so these
>> + * areas should be mapped decrypted.
>> + */
>> +static bool memremap_should_map_decrypted(resource_size_t phys_addr,
>> +					  unsigned long size)
>> +{
>> +	/* Check if the address is outside kernel usable area */
>> +	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
>> +	case E820_TYPE_RESERVED:
>> +	case E820_TYPE_ACPI:
>> +	case E820_TYPE_NVS:
>> +	case E820_TYPE_UNUSABLE:
>> +		return true;
>> +	default:
>> +		break;
>> +	}
>> +
>> +	return false;
>> +}
>> +
>> +/*
>> + * Examine the physical address to determine if it is EFI data. Check
>> + * it against the boot params structure and EFI tables and memory types.
>> + */
>> +static bool memremap_is_efi_data(resource_size_t phys_addr,
>> +				 unsigned long size)
>> +{
>> +	u64 paddr;
>> +
>> +	/* Check if the address is part of EFI boot/runtime data */
>> +	if (efi_enabled(EFI_BOOT)) {
>
> Save indentation level:
>
> 	if (!efi_enabled(EFI_BOOT))
> 		return false;
>

I was worried what the compiler might do when CONFIG_EFI is not set,
but it appears to take care of it. I'll double check though.

>
>> +		paddr = boot_params.efi_info.efi_memmap_hi;
>> +		paddr <<= 32;
>> +		paddr |= boot_params.efi_info.efi_memmap;
>> +		if (phys_addr == paddr)
>> +			return true;
>> +
>> +		paddr = boot_params.efi_info.efi_systab_hi;
>> +		paddr <<= 32;
>> +		paddr |= boot_params.efi_info.efi_systab;
>
> So those two above look like could be two global vars which are
> initialized somewhere in the EFI init path:
>
> efi_memmap_phys and efi_systab_phys or so.
>
> Matt ?
>
> And then you won't need to create that paddr each time on the fly. I
> mean, it's not a lot of instructions but still...
>
>> +		if (phys_addr == paddr)
>> +			return true;
>> +
>> +		if (efi_table_address_match(phys_addr))
>> +			return true;
>> +
>> +		switch (efi_mem_type(phys_addr)) {
>> +		case EFI_BOOT_SERVICES_DATA:
>> +		case EFI_RUNTIME_SERVICES_DATA:
>> +			return true;
>> +		default:
>> +			break;
>> +		}
>> +	}
>> +
>> +	return false;
>> +}
>> +
>> +/*
>> + * Examine the physical address to determine if it is boot data by checking
>> + * it against the boot params setup_data chain.
>> + */
>> +static bool memremap_is_setup_data(resource_size_t phys_addr,
>> +				   unsigned long size)
>> +{
>> +	struct setup_data *data;
>> +	u64 paddr, paddr_next;
>> +
>> +	paddr = boot_params.hdr.setup_data;
>> +	while (paddr) {
>> +		bool is_setup_data = false;
>
> You don't need that bool:
>
> static bool memremap_is_setup_data(resource_size_t phys_addr,
>                                    unsigned long size)
> {
>         struct setup_data *data;
>         u64 paddr, paddr_next;
>
>         paddr = boot_params.hdr.setup_data;
>         while (paddr) {
>                 if (phys_addr == paddr)
>                         return true;
>
>                 data = memremap(paddr, sizeof(*data), MEMREMAP_WB | MEMREMAP_DEC);
>
>                 paddr_next = data->next;
>
>                 if ((phys_addr > paddr) && (phys_addr < (paddr + data->len))) {
>                         memunmap(data);
>                         return true;
>                 }
>
>                 memunmap(data);
>
>                 paddr = paddr_next;
>         }
>         return false;
> }
>
> Flow is a bit clearer.

I may introduce a length variable to capture data->len right after
paddr_next is set and then have just a single memunmap() call before
the if check.

>
>> +/*
>> + * Examine the physical address to determine if it is boot data by checking
>> + * it against the boot params setup_data chain (early boot version).
>> + */
>> +static bool __init early_memremap_is_setup_data(resource_size_t phys_addr,
>> +						unsigned long size)
>> +{
>> +	struct setup_data *data;
>> +	u64 paddr, paddr_next;
>> +
>> +	paddr = boot_params.hdr.setup_data;
>> +	while (paddr) {
>> +		bool is_setup_data = false;
>> +
>> +		if (phys_addr == paddr)
>> +			return true;
>> +
>> +		data = early_memremap_decrypted(paddr, sizeof(*data));
>> +
>> +		paddr_next = data->next;
>> +
>> +		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
>> +			is_setup_data = true;
>> +
>> +		early_memunmap(data, sizeof(*data));
>> +
>> +		if (is_setup_data)
>> +			return true;
>> +
>> +		paddr = paddr_next;
>> +	}
>> +
>> +	return false;
>> +}
>
> This one is begging to be unified with memremap_is_setup_data() to both
> call a __ worker function.

I tried that, but calling an "__init" function (early_memremap()) from
a non "__init" function generated warnings. I suppose I can pass in a
function for the map and unmap but that looks worse to me (also the
unmap functions take different arguments).

>
>> +
>> +/*
>> + * Architecture function to determine if RAM remap is allowed. By default, a
>> + * RAM remap will map the data as encrypted. Determine if a RAM remap should
>> + * not be done so that the data will be mapped decrypted.
>> + */
>> +bool arch_memremap_do_ram_remap(resource_size_t phys_addr, unsigned long size,
>> +				unsigned long flags)
>
> So this function doesn't do anything - it replies to a yes/no question.
> So the name should not say "do" but sound like a question. Maybe:
>
> 	if (arch_memremap_can_remap( ... ))
>
> or so...

Ok, I'll change that.

>
>> +{
>> +	if (!sme_active())
>> +		return true;
>> +
>> +	if (flags & MEMREMAP_ENC)
>> +		return true;
>> +
>> +	if (flags & MEMREMAP_DEC)
>> +		return false;
>
> So this looks strange to me: both flags MEMREMAP_ENC and _DEC override
> setup and efi data checking. But we want to remap setup and EFI  data
> *always* decrypted because that data was not encrypted as, as you say,
> firmware doesn't run with SME active.
>
> So my simple logic says that EFI stuff should *always* be mapped DEC,
> regardless of flags. Ditto for setup data. So that check below should
> actually *override* the flags checks and go before them, no?

This is like the chicken and the egg scenario. In order to determine if
an address is setup data I have to explicitly map the setup data chain
as decrypted. In order to do that I have to supply a flag to explicitly
map the data decrypted otherwise I wind up back in the
memremap_is_setup_data() function again and again and again...

>
>> +
>> +	if (memremap_is_setup_data(phys_addr, size) ||
>> +	    memremap_is_efi_data(phys_addr, size) ||
>> +	    memremap_should_map_decrypted(phys_addr, size))
>> +		return false;
>> +
>> +	return true;
>> +}
>> +
>> +/*
>> + * Architecture override of __weak function to adjust the protection attributes
>> + * used when remapping memory. By default, early_memremp() will map the data
>
> early_memremAp() - a is missing.

Got it.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
