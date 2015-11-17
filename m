Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7836B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 04:21:45 -0500 (EST)
Received: by igvi2 with SMTP id i2so93057853igv.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 01:21:45 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id m133si27187368ioe.46.2015.11.17.01.21.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 01:21:44 -0800 (PST)
Received: by ioir85 with SMTP id r85so12499731ioi.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 01:21:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116184821.GC8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
	<20151116184821.GC8644@n2100.arm.linux.org.uk>
Date: Tue, 17 Nov 2015 10:21:44 +0100
Message-ID: <CAKv+Gu8+0ezm-8En6MGkjRmb1VkU8tN38rSRixqf0JjL8nDVsg@mail.gmail.com>
Subject: Re: [PATCH v2 04/12] arm64/efi: split off EFI init and runtime code
 for reuse by 32-bit ARM
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 19:48, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 07:32:29PM +0100, Ard Biesheuvel wrote:
>> +/*
>> + * Enable the UEFI Runtime Services if all prerequisites are in place, i.e.,
>> + * non-early mapping of the UEFI system table and virtual mappings for all
>> + * EFI_MEMORY_RUNTIME regions.
>> + */
>> +static int __init arm64_enable_runtime_services(void)
>> +{
>> +     u64 mapsize;
>> +
>> +     if (!efi_enabled(EFI_BOOT)) {
>> +             pr_info("EFI services will not be available.\n");
>> +             return -1;
>> +     }
>> +
>> +     if (efi_runtime_disabled()) {
>> +             pr_info("EFI runtime services will be disabled.\n");
>> +             return -1;
>> +     }
>> +
>> +     pr_info("Remapping and enabling EFI services.\n");
>> +
>> +     mapsize = memmap.map_end - memmap.map;
>> +     memmap.map = (__force void *)ioremap_cache(memmap.phys_map,
>> +                                                mapsize);
>> +     if (!memmap.map) {
>> +             pr_err("Failed to remap EFI memory map\n");
>> +             return -1;
>> +     }
>> +     memmap.map_end = memmap.map + mapsize;
>> +     efi.memmap = &memmap;
>> +
>> +     efi.systab = (__force void *)ioremap_cache(efi_system_table,
>> +                                                sizeof(efi_system_table_t));
>> +     if (!efi.systab) {
>> +             pr_err("Failed to remap EFI System Table\n");
>> +             return -1;
>> +     }
>> +     set_bit(EFI_SYSTEM_TABLES, &efi.flags);
>> +
>> +     if (!efi_virtmap_init()) {
>> +             pr_err("No UEFI virtual mapping was installed -- runtime services will not be available\n");
>> +             return -1;
>> +     }
>> +
>> +     /* Set up runtime services function pointers */
>> +     efi_native_runtime_setup();
>> +     set_bit(EFI_RUNTIME_SERVICES, &efi.flags);
>> +
>> +     efi.runtime_version = efi.systab->hdr.revision;
>> +
>> +     return 0;
>> +}
>> +early_initcall(arm64_enable_runtime_services);
>
> The above ought to be fixed - initcalls return negative errno numbers,
> so returning -1 from them is really not acceptable.  (The original code
> was doing the same - so it should be fixed as a separate patch.)
>

Indeed. I will add a patch to v3 to address this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
