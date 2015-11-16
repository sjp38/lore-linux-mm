Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AAC396B0258
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:48:41 -0500 (EST)
Received: by wmvv187 with SMTP id v187so191882726wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:48:41 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t19si27556952wme.67.2015.11.16.10.48.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 10:48:39 -0800 (PST)
Date: Mon, 16 Nov 2015 18:48:21 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 04/12] arm64/efi: split off EFI init and runtime code
 for reuse by 32-bit ARM
Message-ID: <20151116184821.GC8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:29PM +0100, Ard Biesheuvel wrote:
> +/*
> + * Enable the UEFI Runtime Services if all prerequisites are in place, i.e.,
> + * non-early mapping of the UEFI system table and virtual mappings for all
> + * EFI_MEMORY_RUNTIME regions.
> + */
> +static int __init arm64_enable_runtime_services(void)
> +{
> +	u64 mapsize;
> +
> +	if (!efi_enabled(EFI_BOOT)) {
> +		pr_info("EFI services will not be available.\n");
> +		return -1;
> +	}
> +
> +	if (efi_runtime_disabled()) {
> +		pr_info("EFI runtime services will be disabled.\n");
> +		return -1;
> +	}
> +
> +	pr_info("Remapping and enabling EFI services.\n");
> +
> +	mapsize = memmap.map_end - memmap.map;
> +	memmap.map = (__force void *)ioremap_cache(memmap.phys_map,
> +						   mapsize);
> +	if (!memmap.map) {
> +		pr_err("Failed to remap EFI memory map\n");
> +		return -1;
> +	}
> +	memmap.map_end = memmap.map + mapsize;
> +	efi.memmap = &memmap;
> +
> +	efi.systab = (__force void *)ioremap_cache(efi_system_table,
> +						   sizeof(efi_system_table_t));
> +	if (!efi.systab) {
> +		pr_err("Failed to remap EFI System Table\n");
> +		return -1;
> +	}
> +	set_bit(EFI_SYSTEM_TABLES, &efi.flags);
> +
> +	if (!efi_virtmap_init()) {
> +		pr_err("No UEFI virtual mapping was installed -- runtime services will not be available\n");
> +		return -1;
> +	}
> +
> +	/* Set up runtime services function pointers */
> +	efi_native_runtime_setup();
> +	set_bit(EFI_RUNTIME_SERVICES, &efi.flags);
> +
> +	efi.runtime_version = efi.systab->hdr.revision;
> +
> +	return 0;
> +}
> +early_initcall(arm64_enable_runtime_services);

The above ought to be fixed - initcalls return negative errno numbers,
so returning -1 from them is really not acceptable.  (The original code
was doing the same - so it should be fixed as a separate patch.)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
