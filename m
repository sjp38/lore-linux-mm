Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E0BC36B025B
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:34:33 -0500 (EST)
Received: by wmww144 with SMTP id w144so136369458wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:33 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id r16si41878593wmb.2.2015.11.19.14.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:34:32 -0800 (PST)
Received: by wmww144 with SMTP id w144so257184046wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:32 -0800 (PST)
Date: Thu, 19 Nov 2015 22:34:30 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v2 04/12] arm64/efi: split off EFI init and runtime code
 for reuse by 32-bit ARM
Message-ID: <20151119223430.GB2577@codeblueprint.co.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, linux@arm.linux.org.uk, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, 16 Nov, at 07:32:29PM, Ard Biesheuvel wrote:
> +
> +	pr_info("EFI v%u.%.02u by %s\n",
> +		efi.systab->hdr.revision >> 16,
> +		efi.systab->hdr.revision & 0xffff, vendor);
> +
> +	table_size = sizeof(efi_config_table_64_t) * efi.systab->nr_tables;
> +	config_tables = early_memremap(efi_to_phys(efi.systab->tables),
> +				       table_size);

You should probably check the return value of early_memremap().

> +
> +	retval = efi_config_parse_tables(config_tables, efi.systab->nr_tables,
> +					 sizeof(efi_config_table_64_t), NULL);
> +
> +	early_memunmap(config_tables, table_size);
> +out:
> +	early_memunmap(efi.systab,  sizeof(efi_system_table_t));
> +	return retval;
> +}
> +
> +/*
> + * Return true for RAM regions we want to permanently reserve.
> + */
> +static __init int is_reserve_region(efi_memory_desc_t *md)
> +{
> +	switch (md->type) {
> +	case EFI_LOADER_CODE:
> +	case EFI_LOADER_DATA:
> +	case EFI_BOOT_SERVICES_CODE:
> +	case EFI_BOOT_SERVICES_DATA:
> +	case EFI_CONVENTIONAL_MEMORY:
> +	case EFI_PERSISTENT_MEMORY:
> +		return 0;
> +	default:
> +		break;
> +	}
> +	return is_normal_ram(md);
> +}
> +
> +static __init void reserve_regions(void)
> +{
> +	efi_memory_desc_t *md;
> +	u64 paddr, npages, size;
> +
> +	if (efi_enabled(EFI_DBG))
> +		pr_info("Processing EFI memory map:\n");
> +
> +	for_each_efi_memory_desc(&memmap, md) {
> +		paddr = md->phys_addr;
> +		npages = md->num_pages;
> +
> +		if (efi_enabled(EFI_DBG)) {
> +			char buf[64];
> +
> +			pr_info("  0x%012llx-0x%012llx %s",
> +				paddr, paddr + (npages << EFI_PAGE_SHIFT) - 1,
> +				efi_md_typeattr_format(buf, sizeof(buf), md));
> +		}
> +
> +		memrange_efi_to_native(&paddr, &npages);
> +		size = npages << PAGE_SHIFT;

The use of EFI_PAGE_SHIFT and PAGE_SHIFT seem to get mingled in this
code. What's the correct constant to use throughout, because it
doesn't look like PAGE_SHIFT == EFI_PAGE_SHIFT always?

> +
> +		if (is_normal_ram(md))
> +			early_init_dt_add_memory_arch(paddr, size);
> +
> +		if (is_reserve_region(md)) {
> +			memblock_mark_nomap(paddr, size);

Hmm.. I was going to point out the fact that you're not checking the
return value of memblock_mark_nomap() which can fail if you run out of
memory when resizing the memblock arrays, until I realised that you
haven't called memblock_allow_resize() yet. Oh well.

> +			if (efi_enabled(EFI_DBG))
> +				pr_cont("*");
> +		}
> +
> +		if (efi_enabled(EFI_DBG))
> +			pr_cont("\n");
> +	}
> +
> +	set_bit(EFI_MEMMAP, &efi.flags);
> +}
> +
> +void __init efi_init(void)
> +{
> +	struct efi_fdt_params params;
> +
> +	/* Grab UEFI information placed in FDT by stub */
> +	if (!efi_get_fdt_params(&params))
> +		return;
> +
> +	efi_system_table = params.system_table;
> +
> +	memmap.phys_map = params.mmap;
> +	memmap.map = early_memremap(params.mmap, params.mmap_size);

Better check the return value?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
