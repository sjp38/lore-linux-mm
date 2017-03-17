Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC136B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 15:50:24 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 76so43203495itj.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 12:50:24 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0083.outbound.protection.outlook.com. [104.47.38.83])
        by mx.google.com with ESMTPS id 136si3146671ita.98.2017.03.17.12.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 12:50:23 -0700 (PDT)
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
 <20170308065555.GA11045@dhcp-128-65.nay.redhat.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <79f1c44e-0138-8b50-8931-723a5d243644@amd.com>
Date: Fri, 17 Mar 2017 14:50:14 -0500
MIME-Version: 1.0
In-Reply-To: <20170308065555.GA11045@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 3/8/2017 12:55 AM, Dave Young wrote:
> On 02/16/17 at 09:45am, Tom Lendacky wrote:
> [snip]
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
>
> From the function name shouldn't above be return false?

I've re-worked this so that the check is in a different location and
doesn't cause confusion.

>
>> +
>> +	/* Check if the address is part of the setup data */
>> +	if (memremap_is_setup_data(phys_addr, size))
>> +		return false;
>> +
>> +	/* Check if the address is part of EFI boot/runtime data */
>> +	switch (efi_mem_type(phys_addr)) {
>> +	case EFI_BOOT_SERVICES_DATA:
>> +	case EFI_RUNTIME_SERVICES_DATA:
>
> Only these two types needed? I'm not sure about this, just bring up the
> question.

I've re-worked this code so that there is a single EFI routine that
checks boot_params.efi_info.efi_memmap/efi_systab, EFI tables and the
EFI memtype.  As for the EFI memtypes, I believe those are the only
ones required.  Some of the other types will be picked up by the e820
checks (ACPI, NVS, etc.).

Thanks,
Tom

>
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
>
> Thanks
> Dave
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
