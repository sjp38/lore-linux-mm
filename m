Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E36BB6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 07:18:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so4534861wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 04:18:48 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id nd8si936133wjb.77.2016.06.08.04.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 04:18:47 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id n184so176638716wmn.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 04:18:47 -0700 (PDT)
Date: Wed, 8 Jun 2016 12:18:44 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160608111844.GV2658@codeblueprint.co.uk>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, 26 Apr, at 05:57:40PM, Tom Lendacky wrote:
> The EFI tables are not encrypted and need to be accessed as such. Be sure
> to memmap them without the encryption attribute set. For EFI support that
> lives outside of the arch/x86 tree, create a routine that uses the __weak
> attribute so that it can be overridden by an architecture specific routine.
> 
> When freeing boot services related memory, since it has been mapped as
> un-encrypted, be sure to change the mapping to encrypted for future use.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cacheflush.h  |    3 +
>  arch/x86/include/asm/mem_encrypt.h |   22 +++++++++++
>  arch/x86/kernel/setup.c            |    6 +--
>  arch/x86/mm/mem_encrypt.c          |   56 +++++++++++++++++++++++++++
>  arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
>  arch/x86/platform/efi/efi.c        |   26 +++++++-----
>  arch/x86/platform/efi/efi_64.c     |    9 +++-
>  arch/x86/platform/efi/quirks.c     |   12 +++++-
>  drivers/firmware/efi/efi.c         |   18 +++++++--
>  drivers/firmware/efi/esrt.c        |   12 +++---
>  include/linux/efi.h                |    3 +
>  11 files changed, 212 insertions(+), 30 deletions(-)

[...]

> diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
> index 994a7df8..871b213 100644
> --- a/arch/x86/platform/efi/efi.c
> +++ b/arch/x86/platform/efi/efi.c
> @@ -53,6 +53,7 @@
>  #include <asm/x86_init.h>
>  #include <asm/rtc.h>
>  #include <asm/uv/uv.h>
> +#include <asm/mem_encrypt.h>
>  
>  #define EFI_DEBUG
>  
> @@ -261,12 +262,12 @@ static int __init efi_systab_init(void *phys)
>  		u64 tmp = 0;
>  
>  		if (efi_setup) {
> -			data = early_memremap(efi_setup, sizeof(*data));
> +			data = sme_early_memremap(efi_setup, sizeof(*data));
>  			if (!data)
>  				return -ENOMEM;
>  		}

Beware, this data comes from a previous kernel that kexec'd this
kernel. Unless you've updated bzImage64_load() to allocate an
unencrypted region 'efi_setup' will in fact be encrypted.

> @@ -690,6 +691,7 @@ static void *realloc_pages(void *old_memmap, int old_shift)
>  	ret = (void *)__get_free_pages(GFP_KERNEL, old_shift + 1);
>  	if (!ret)
>  		goto out;
> +	sme_set_mem_dec(ret, PAGE_SIZE << (old_shift + 1));
>  
>  	/*
>  	 * A first-time allocation doesn't have anything to copy.

I'm not sure why it's necessary to mark this region as unencrypted,
because at this point the kernel controls the platform and when we
call into the firmware it should be using our page tables. I wouldn't
expect the firmware to mess with the SYSCFG MSR either.

Have you come across a situation where the above was required?

> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
> index 49e4dd4..834a992 100644
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -223,7 +223,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	if (efi_enabled(EFI_OLD_MEMMAP))
>  		return 0;
>  
> -	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
> +	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
>  	pgd = efi_pgd;
>  
>  	/*

Huh? Why does __pa() now OR in sme_mas_mask? I thought SME only
required the page table structures to be modified, not the end
address?

> @@ -262,7 +262,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  		pfn = md->phys_addr >> PAGE_SHIFT;
>  		npages = md->num_pages;
>  
> -		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages, _PAGE_RW)) {
> +		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages,
> +					    _PAGE_RW | _PAGE_ENC)) {
>  			pr_err("Failed to map 1:1 memory\n");
>  			return 1;
>  		}

Could you push the _PAGE_ENC addition down into
kernel_map_pages_in_pgd()? Other flags are also handled that way, see
_PAGE_PRESENT.

> @@ -272,6 +273,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	if (!page)
>  		panic("Unable to allocate EFI runtime stack < 4GB\n");
>  
> +	sme_set_mem_dec(page_address(page), PAGE_SIZE);
>  	efi_scratch.phys_stack = virt_to_phys(page_address(page));
>  	efi_scratch.phys_stack += PAGE_SIZE; /* stack grows down */
>  

We should not need to mark the stack as unencrypted, the firmware
should respect our SME settings, right?

> diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
> index ab50ada..dde4fb6b 100644
> --- a/arch/x86/platform/efi/quirks.c
> +++ b/arch/x86/platform/efi/quirks.c
> @@ -13,6 +13,7 @@
>  #include <linux/dmi.h>
>  #include <asm/efi.h>
>  #include <asm/uv/uv.h>
> +#include <asm/mem_encrypt.h>
>  
>  #define EFI_MIN_RESERVE 5120
>  
> @@ -265,6 +266,13 @@ void __init efi_free_boot_services(void)
>  		if (md->attribute & EFI_MEMORY_RUNTIME)
>  			continue;
>  
> +		/*
> +		 * Change the mapping to encrypted memory before freeing.
> +		 * This insures any future allocations of this mapped area
> +		 * are used encrypted.
> +		 */
> +		sme_set_mem_enc(__va(start), size);
> +
>  		free_bootmem_late(start, size);
>  	}
>  

I don't think it's necessary to have to mark the __va() mapping of
these regions as encrypted at this point. They should be setup that
way initially.

The reason is that it'd be a bug if these regions were accessed via
the __va() mappings before this point. Unless there's something I'm
missing.

> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index 3a69ed5..25010c7 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -76,6 +76,16 @@ static int __init parse_efi_cmdline(char *str)
>  }
>  early_param("efi", parse_efi_cmdline);
>  
> +/*
> + * If memory encryption is supported, then an override to this function
> + * will be provided.
> + */
> +void __weak __init *efi_me_early_memremap(resource_size_t phys_addr,
> +					  unsigned long size)
> +{
> +	return early_memremap(phys_addr, size);
> +}
> +
>  struct kobject *efi_kobj;
>  
>  /*

Like I said in my other mail, I'd much prefer to see this buried in
arch/x86 by passing a flag to early_memremap() which can be parsed in
arch directories.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
