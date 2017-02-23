Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 409E56B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 16:34:45 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r54so3560134qtr.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 13:34:45 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0048.outbound.protection.outlook.com. [104.47.33.48])
        by mx.google.com with ESMTPS id m47si4186808qtc.283.2017.02.23.13.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 13:34:44 -0800 (PST)
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
 <20170221150625.lohyskz5bjuey7fa@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <031277bf-25ad-3d41-d189-1ad6b4d27c93@amd.com>
Date: Thu, 23 Feb 2017 15:34:30 -0600
MIME-Version: 1.0
In-Reply-To: <20170221150625.lohyskz5bjuey7fa@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/21/2017 9:06 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:45:09AM -0600, Tom Lendacky wrote:
>> Boot data (such as EFI related data) is not encrypted when the system is
>> booted and needs to be mapped decrypted.  Add support to apply the proper
>> attributes to the EFI page tables and to the early_memremap and memremap
>> APIs to identify the type of data being accessed so that the proper
>> encryption attribute can be applied.
>
> So this doesn't even begin to explain *why* we need this. The emphasis
> being on *why*.
>
> Lemme guess? kexec? And because of efi_reuse_config?

Hmm... maybe I'm missing something here.  This doesn't have anything to
do with kexec or efi_reuse_config.  This has to do with the fact that
when a system boots the setup data and the EFI data are not encrypted.
Since it's not encrypted we need to be sure that any early_memremap()
and memremap() calls remove the encryption mask from the resulting
pagetable entry that is created so the data can be accessed properly.

>
> If so, then that whole ad-hoc caching in parse_setup_data() needs to go.
> Especially if efi_reuse_config() already sees those addresses so while
> we're there, we could save them somewhere or whatnot. But not doing the
> whole thing again in parse_setup_data().
>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/io.h      |    3 +
>>  arch/x86/include/asm/setup.h   |    8 +++
>>  arch/x86/kernel/setup.c        |   33 ++++++++++++
>>  arch/x86/mm/ioremap.c          |  111 ++++++++++++++++++++++++++++++++++++++++
>>  arch/x86/platform/efi/efi_64.c |   16 ++++--
>>  kernel/memremap.c              |   11 ++++
>>  mm/early_ioremap.c             |   18 +++++-
>>  7 files changed, 192 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
>> index 7afb0e2..833f7cc 100644
>> --- a/arch/x86/include/asm/io.h
>> +++ b/arch/x86/include/asm/io.h
>> @@ -381,4 +381,7 @@ extern int __must_check arch_phys_wc_add(unsigned long base,
>>  #define arch_io_reserve_memtype_wc arch_io_reserve_memtype_wc
>>  #endif
>>
>> +extern bool arch_memremap_do_ram_remap(resource_size_t offset, size_t size);
>> +#define arch_memremap_do_ram_remap arch_memremap_do_ram_remap
>> +
>>  #endif /* _ASM_X86_IO_H */
>> diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
>> index ac1d5da..99998d9 100644
>> --- a/arch/x86/include/asm/setup.h
>> +++ b/arch/x86/include/asm/setup.h
>> @@ -63,6 +63,14 @@ static inline void x86_ce4100_early_setup(void) { }
>>  #include <asm/espfix.h>
>>  #include <linux/kernel.h>
>>
>> +struct setup_data_attrs {
>> +	u64 paddr;
>> +	unsigned long size;
>> +};
>> +
>> +extern struct setup_data_attrs setup_data_list[];
>> +extern unsigned int setup_data_list_count;
>> +
>>  /*
>>   * This is set up by the setup-routine at boot-time
>>   */
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index bd5b9a7..d2234bf 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -148,6 +148,9 @@ int default_check_phys_apicid_present(int phys_apicid)
>>
>>  struct boot_params boot_params;
>>
>> +struct setup_data_attrs setup_data_list[32];
>> +unsigned int setup_data_list_count;
>> +
>>  /*
>>   * Machine setup..
>>   */
>> @@ -419,6 +422,32 @@ static void __init reserve_initrd(void)
>>  }
>>  #endif /* CONFIG_BLK_DEV_INITRD */
>>
>> +static void __init update_setup_data_list(u64 pa_data, unsigned long size)
>> +{
>> +	unsigned int i;
>> +
>> +	for (i = 0; i < setup_data_list_count; i++) {
>> +		if (setup_data_list[i].paddr != pa_data)
>> +			continue;
>> +
>> +		setup_data_list[i].size = size;
>> +		break;
>> +	}
>> +}
>> +
>> +static void __init add_to_setup_data_list(u64 pa_data, unsigned long size)
>> +{
>> +	if (!sme_active())
>> +		return;
>> +
>> +	if (!WARN(setup_data_list_count == ARRAY_SIZE(setup_data_list),
>> +		  "exceeded maximum setup data list slots")) {
>> +		setup_data_list[setup_data_list_count].paddr = pa_data;
>> +		setup_data_list[setup_data_list_count].size = size;
>> +		setup_data_list_count++;
>> +	}
>> +}
>> +
>>  static void __init parse_setup_data(void)
>>  {
>>  	struct setup_data *data;
>> @@ -428,12 +457,16 @@ static void __init parse_setup_data(void)
>>  	while (pa_data) {
>>  		u32 data_len, data_type;
>>
>> +		add_to_setup_data_list(pa_data, sizeof(*data));
>> +
>>  		data = early_memremap(pa_data, sizeof(*data));
>>  		data_len = data->len + sizeof(struct setup_data);
>>  		data_type = data->type;
>>  		pa_next = data->next;
>>  		early_memunmap(data, sizeof(*data));
>>
>> +		update_setup_data_list(pa_data, data_len);
>> +
>>  		switch (data_type) {
>>  		case SETUP_E820_EXT:
>>  			e820__memory_setup_extended(pa_data, data_len);
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index 2385e70..b0ff6bc 100644
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
>> @@ -419,6 +421,115 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>>  	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
>>  }
>>
>> +/*
>> + * Examine the physical address to determine if it is boot data. Check
>> + * it against the boot params structure and EFI tables.
>> + */
>> +static bool memremap_is_setup_data(resource_size_t phys_addr,
>> +				   unsigned long size)
>> +{
>> +	unsigned int i;
>> +	u64 paddr;
>> +
>> +	for (i = 0; i < setup_data_list_count; i++) {
>> +		if (phys_addr < setup_data_list[i].paddr)
>> +			continue;
>> +
>> +		if (phys_addr >= (setup_data_list[i].paddr +
>> +				  setup_data_list[i].size))
>> +			continue;
>> +
>> +		/* Address is within setup data range */
>> +		return true;
>> +	}
>> +
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
>> +/*
>> + * This function determines if an address should be mapped encrypted.
>> + * Boot setup data, EFI data and E820 areas are checked in making this
>> + * determination.
>> + */
>> +static bool memremap_should_map_encrypted(resource_size_t phys_addr,
>> +					  unsigned long size)
>> +{
>> +	/*
>> +	 * SME is not active, return true:
>> +	 *   - For early_memremap_pgprot_adjust(), returning true or false
>> +	 *     results in the same protection value
>> +	 *   - For arch_memremap_do_ram_remap(), returning true will allow
>> +	 *     the RAM remap to occur instead of falling back to ioremap()
>> +	 */
>> +	if (!sme_active())
>> +		return true;
>> +
>> +	/* Check if the address is part of the setup data */
>> +	if (memremap_is_setup_data(phys_addr, size))
>> +		return false;
>> +
>> +	/* Check if the address is part of EFI boot/runtime data */
>> +	switch (efi_mem_type(phys_addr)) {
>
> arch/x86/built-in.o: In function `memremap_should_map_encrypted':
> /home/boris/kernel/alt-linux/arch/x86/mm/ioremap.c:487: undefined reference to `efi_mem_type'
> make: *** [vmlinux] Error 1
>
> That's a !CONFIG_EFI .config.

Missed that, I'll fix it.

>
>> +	case EFI_BOOT_SERVICES_DATA:
>> +	case EFI_RUNTIME_SERVICES_DATA:
>> +		return false;
>> +	default:
>> +		break;
>> +	}
>> +
>> +	/* Check if the address is outside kernel usable area */
>> +	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
>> +	case E820_TYPE_RESERVED:
>> +	case E820_TYPE_ACPI:
>> +	case E820_TYPE_NVS:
>> +	case E820_TYPE_UNUSABLE:
>> +		return false;
>> +	default:
>> +		break;
>> +	}
>> +
>> +	return true;
>> +}
>> +
>> +/*
>> + * Architecure function to determine if RAM remap is allowed.
>> + */
>> +bool arch_memremap_do_ram_remap(resource_size_t phys_addr, unsigned long size)
>> +{
>> +	return memremap_should_map_encrypted(phys_addr, size);
>> +}
>> +
>> +/*
>> + * Architecure override of __weak function to adjust the protection attributes
>> + * used when remapping memory.
>> + */
>> +pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
>> +					     unsigned long size,
>> +					     pgprot_t prot)
>> +{
>> +	if (memremap_should_map_encrypted(phys_addr, size))
>> +		prot = pgprot_encrypted(prot);
>> +	else
>> +		prot = pgprot_decrypted(prot);
>> +
>> +	return prot;
>> +}
>> +
>>  #ifdef CONFIG_ARCH_USE_MEMREMAP_PROT
>>  /* Remap memory with encryption */
>>  void __init *early_memremap_encrypted(resource_size_t phys_addr,
>> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
>> index 2ee7694..2d8674d 100644
>> --- a/arch/x86/platform/efi/efi_64.c
>> +++ b/arch/x86/platform/efi/efi_64.c
>> @@ -243,7 +243,7 @@ void efi_sync_low_kernel_mappings(void)
>>
>>  int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>>  {
>> -	unsigned long pfn, text;
>> +	unsigned long pfn, text, pf;
>>  	struct page *page;
>>  	unsigned npages;
>>  	pgd_t *pgd;
>> @@ -251,7 +251,13 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
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
>> @@ -261,7 +267,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>>  	 * phys_efi_set_virtual_address_map().
>>  	 */
>>  	pfn = pa_memmap >> PAGE_SHIFT;
>> -	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW)) {
>> +	pf = _PAGE_NX | _PAGE_RW | _PAGE_ENC;
>> +	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, pf)) {
>>  		pr_err("Error ident-mapping new memmap (0x%lx)!\n", pa_memmap);
>>  		return 1;
>>  	}
>> @@ -304,7 +311,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>>  	text = __pa(_text);
>>  	pfn = text >> PAGE_SHIFT;
>>
>> -	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW)) {
>> +	pf = _PAGE_RW | _PAGE_ENC;
>> +	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, pf)) {
>>  		pr_err("Failed to map kernel text 1:1\n");
>>  		return 1;
>>  	}
>
> Those changes should be in a separate patch IMHO.

I can break out the mapping changes from the EFI pagetable changes.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
