Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0A36B032A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 10:55:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so53012652wma.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 07:55:50 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id x7si3406624wjf.26.2016.11.17.07.55.48
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 07:55:48 -0800 (PST)
Date: Thu, 17 Nov 2016 16:55:44 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 10/20] Add support to access boot related data in
 the clear
Message-ID: <20161117155543.vg3domfqm3bhp4f7@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003631.3280.73292.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20161110003631.3280.73292.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 09, 2016 at 06:36:31PM -0600, Tom Lendacky wrote:
> Boot data (such as EFI related data) is not encrypted when the system is
> booted and needs to be accessed unencrypted.  Add support to apply the
> proper attributes to the EFI page tables and to the early_memremap and
> memremap APIs to identify the type of data being accessed so that the
> proper encryption attribute can be applied.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/e820.h    |    1 
>  arch/x86/kernel/e820.c         |   16 +++++++
>  arch/x86/mm/ioremap.c          |   89 ++++++++++++++++++++++++++++++++++++++++
>  arch/x86/platform/efi/efi_64.c |   12 ++++-
>  drivers/firmware/efi/efi.c     |   33 +++++++++++++++
>  include/linux/efi.h            |    2 +
>  kernel/memremap.c              |    8 +++-
>  mm/early_ioremap.c             |   18 +++++++-
>  8 files changed, 172 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
> index 476b574..186f1d04 100644
> --- a/arch/x86/include/asm/e820.h
> +++ b/arch/x86/include/asm/e820.h
> @@ -16,6 +16,7 @@ extern struct e820map *e820_saved;
>  extern unsigned long pci_mem_start;
>  extern int e820_any_mapped(u64 start, u64 end, unsigned type);
>  extern int e820_all_mapped(u64 start, u64 end, unsigned type);
> +extern unsigned int e820_get_entry_type(u64 start, u64 end);
>  extern void e820_add_region(u64 start, u64 size, int type);
>  extern void e820_print_map(char *who);
>  extern int
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index b85fe5f..92fce4e 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -107,6 +107,22 @@ int __init e820_all_mapped(u64 start, u64 end, unsigned type)
>  	return 0;
>  }
>  
> +unsigned int e820_get_entry_type(u64 start, u64 end)
> +{
> +	int i;
> +
> +	for (i = 0; i < e820->nr_map; i++) {
> +		struct e820entry *ei = &e820->map[i];
> +
> +		if (ei->addr >= end || ei->addr + ei->size <= start)
> +			continue;
> +
> +		return ei->type;
> +	}
> +
> +	return 0;

Please add a

#define E820_TYPE_INVALID	0

or so and return it instead of the naked number 0.

Also, this patch can be split in logical parts. The e820 stuff can be a
separate pre-patch.

efi_table_address_match() and the tables definitions is a second pre-patch.

The rest is then the third patch.

...

> +}
> +
>  /*
>   * Add a memory region to the kernel e820 map.
>   */
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index ff542cd..ee347c2 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -20,6 +20,9 @@
>  #include <asm/tlbflush.h>
>  #include <asm/pgalloc.h>
>  #include <asm/pat.h>
> +#include <asm/e820.h>
> +#include <asm/setup.h>
> +#include <linux/efi.h>
>  
>  #include "physaddr.h"
>  
> @@ -418,6 +421,92 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>  	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
>  }
>  
> +static bool memremap_setup_data(resource_size_t phys_addr,
> +				unsigned long size)

This function name doesn't read like what the function does.

> +{
> +	u64 paddr;
> +
> +	if (phys_addr == boot_params.hdr.setup_data)
> +		return true;
> +
> +	paddr = boot_params.efi_info.efi_memmap_hi;
> +	paddr <<= 32;
> +	paddr |= boot_params.efi_info.efi_memmap;
> +	if (phys_addr == paddr)
> +		return true;
> +
> +	paddr = boot_params.efi_info.efi_systab_hi;
> +	paddr <<= 32;
> +	paddr |= boot_params.efi_info.efi_systab;
> +	if (phys_addr == paddr)
> +		return true;
> +
> +	if (efi_table_address_match(phys_addr))
> +		return true;
> +
> +	return false;
> +}

arch/x86/built-in.o: In function `memremap_setup_data':
/home/boris/kernel/alt-linux/arch/x86/mm/ioremap.c:444: undefined reference to `efi_table_address_match'
arch/x86/built-in.o: In function `memremap_apply_encryption':
/home/boris/kernel/alt-linux/arch/x86/mm/ioremap.c:462: undefined reference to `efi_mem_type'
make: *** [vmlinux] Error 1

I guess due to

# CONFIG_EFI is not set

> +
> +static bool memremap_apply_encryption(resource_size_t phys_addr,
> +				      unsigned long size)

This name is misleading too: it doesn't apply encryption but checks
whether to apply encryption for @phys_addr or not. So something like:

... memremap_should_encrypt(...)
{
	return true - for should
	return false - for should not

should make the whole thing much more straightforward. Or am I
misunderstanding you here?

> +{
> +	/* SME is not active, just return true */
> +	if (!sme_me_mask)
> +		return true;

I don't understand the logic here: SME is not active -> apply encryption?!

> +
> +	/* Check if the address is part of the setup data */

That comment belongs over the function definition of
memremap_setup_data() along with what it is supposed to do.

> +	if (memremap_setup_data(phys_addr, size))
> +		return false;
> +
> +	/* Check if the address is part of EFI boot/runtime data */
> +	switch (efi_mem_type(phys_addr)) {

Please send a pre-patch fix for efi_mem_type() to return
EFI_RESERVED_TYPE instead of naked 0 in the failure case.

> +	case EFI_BOOT_SERVICES_DATA:
> +	case EFI_RUNTIME_SERVICES_DATA:
> +		return false;
> +	}
> +
> +	/* Check if the address is outside kernel usable area */
> +	switch (e820_get_entry_type(phys_addr, phys_addr + size - 1)) {
> +	case E820_RESERVED:
> +	case E820_ACPI:
> +	case E820_NVS:
> +	case E820_UNUSABLE:
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
> +/*
> + * Architecure override of __weak function to prevent ram remap and use the

s/ram/RAM/

> + * architectural remap function.
> + */
> +bool memremap_do_ram_remap(resource_size_t phys_addr, unsigned long size)
> +{
> +	if (!memremap_apply_encryption(phys_addr, size))
> +		return false;
> +
> +	return true;

Do I see it correctly that this could just very simply be:

	return memremap_apply_encryption(phys_addr, size);

?

> +}
> +
> +/*
> + * Architecure override of __weak function to adjust the protection attributes
> + * used when remapping memory.
> + */
> +pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
> +					     unsigned long size,
> +					     pgprot_t prot)
> +{
> +	unsigned long prot_val = pgprot_val(prot);
> +
> +	if (memremap_apply_encryption(phys_addr, size))
> +		prot_val |= _PAGE_ENC;
> +	else
> +		prot_val &= ~_PAGE_ENC;
> +
> +	return __pgprot(prot_val);
> +}
> +
>  /* Remap memory with encryption */
>  void __init *early_memremap_enc(resource_size_t phys_addr,
>  				unsigned long size)
> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
> index 58b0f80..3f89179 100644
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -221,7 +221,13 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	if (efi_enabled(EFI_OLD_MEMMAP))
>  		return 0;
>  
> -	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
> +	/*
> +	 * Since the PGD is encrypted, set the encryption mask so that when
> +	 * this value is loaded into cr3 the PGD will be decrypted during
> +	 * the pagetable walk.
> +	 */
> +	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
> +
>  	pgd = efi_pgd;
>  
>  	/*
> @@ -231,7 +237,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	 * phys_efi_set_virtual_address_map().
>  	 */
>  	pfn = pa_memmap >> PAGE_SHIFT;
> -	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW)) {
> +	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW | _PAGE_ENC)) {

That line sticks too far out, let's shorten it:

	unsigned long pf = _PAGE_NX | _PAGE_RW | _PAGE_ENC;

	...

	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, pf)) {


	..

	pf = _PAGE_RW | _PAGE_ENC;
	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, pf)) {

	..


>  		pr_err("Error ident-mapping new memmap (0x%lx)!\n", pa_memmap);
>  		return 1;
>  	}
> @@ -258,7 +264,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	text = __pa(_text);
>  	pfn = text >> PAGE_SHIFT;
>  
> -	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW)) {
> +	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW | _PAGE_ENC)) {
>  		pr_err("Failed to map kernel text 1:1\n");
>  		return 1;
>  	}
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index 1ac199c..91c06ec 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -51,6 +51,25 @@ struct efi __read_mostly efi = {
>  };
>  EXPORT_SYMBOL(efi);
>  
> +static unsigned long *efi_tables[] = {
> +	&efi.mps,
> +	&efi.acpi,
> +	&efi.acpi20,
> +	&efi.smbios,
> +	&efi.smbios3,
> +	&efi.sal_systab,
> +	&efi.boot_info,
> +	&efi.hcdp,
> +	&efi.uga,
> +	&efi.uv_systab,
> +	&efi.fw_vendor,
> +	&efi.runtime,
> +	&efi.config_table,
> +	&efi.esrt,
> +	&efi.properties_table,
> +	&efi.mem_attr_table,
> +};
> +
>  static bool disable_runtime;
>  static int __init setup_noefi(char *arg)
>  {
> @@ -822,3 +841,17 @@ int efi_status_to_err(efi_status_t status)
>  
>  	return err;
>  }
> +
> +bool efi_table_address_match(unsigned long phys_addr)
> +{
> +	int i;
> +
> +	if (phys_addr == EFI_INVALID_TABLE_ADDR)
> +		return false;
> +
> +	for (i = 0; i < ARRAY_SIZE(efi_tables); i++)
> +		if (*(efi_tables[i]) == phys_addr)
> +			return true;
> +
> +	return false;
> +}
> diff --git a/include/linux/efi.h b/include/linux/efi.h
> index 2d08948..72d89bf 100644
> --- a/include/linux/efi.h
> +++ b/include/linux/efi.h
> @@ -1070,6 +1070,8 @@ efi_capsule_pending(int *reset_type)
>  
>  extern int efi_status_to_err(efi_status_t status);
>  
> +extern bool efi_table_address_match(unsigned long phys_addr);
> +
>  /*
>   * Variable Attributes
>   */
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index b501e39..ac1437e 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -34,12 +34,18 @@ static void *arch_memremap_wb(resource_size_t offset, unsigned long size)
>  }
>  #endif
>  
> +bool __weak memremap_do_ram_remap(resource_size_t offset, size_t size)
> +{
> +	return true;
> +}
> +

Why isn't this an inline in a header?

>  static void *try_ram_remap(resource_size_t offset, size_t size)
>  {
>  	unsigned long pfn = PHYS_PFN(offset);
>  
>  	/* In the simple case just return the existing linear address */
> -	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)))
> +	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)) &&
> +	    memremap_do_ram_remap(offset, size))
>  		return __va(offset);

<---- newline here.

>  	return NULL; /* fallback to arch_memremap_wb */
>  }
> diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
> index d71b98b..34af5b6 100644
> --- a/mm/early_ioremap.c
> +++ b/mm/early_ioremap.c
> @@ -30,6 +30,13 @@ early_param("early_ioremap_debug", early_ioremap_debug_setup);
>  
>  static int after_paging_init __initdata;
>  
> +pgprot_t __init __weak early_memremap_pgprot_adjust(resource_size_t phys_addr,
> +						    unsigned long size,
> +						    pgprot_t prot)
> +{
> +	return prot;
> +}

Also, why isn't this an inline in a header somewhere?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
