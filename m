Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6B16B039E
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:56:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id v125so56418252qkh.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:56:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d204si2249542qka.207.2017.03.07.22.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 22:56:11 -0800 (PST)
Date: Wed, 8 Mar 2017 14:55:55 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
Message-ID: <20170308065555.GA11045@dhcp-128-65.nay.redhat.com>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 02/16/17 at 09:45am, Tom Lendacky wrote:
[snip]
> + * This function determines if an address should be mapped encrypted.
> + * Boot setup data, EFI data and E820 areas are checked in making this
> + * determination.
> + */
> +static bool memremap_should_map_encrypted(resource_size_t phys_addr,
> +					  unsigned long size)
> +{
> +	/*
> +	 * SME is not active, return true:
> +	 *   - For early_memremap_pgprot_adjust(), returning true or false
> +	 *     results in the same protection value
> +	 *   - For arch_memremap_do_ram_remap(), returning true will allow
> +	 *     the RAM remap to occur instead of falling back to ioremap()
> +	 */
> +	if (!sme_active())
> +		return true;

>From the function name shouldn't above be return false? 

> +
> +	/* Check if the address is part of the setup data */
> +	if (memremap_is_setup_data(phys_addr, size))
> +		return false;
> +
> +	/* Check if the address is part of EFI boot/runtime data */
> +	switch (efi_mem_type(phys_addr)) {
> +	case EFI_BOOT_SERVICES_DATA:
> +	case EFI_RUNTIME_SERVICES_DATA:

Only these two types needed? I'm not sure about this, just bring up the
question.

> +		return false;
> +	default:
> +		break;
> +	}
> +
> +	/* Check if the address is outside kernel usable area */
> +	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
> +	case E820_TYPE_RESERVED:
> +	case E820_TYPE_ACPI:
> +	case E820_TYPE_NVS:
> +	case E820_TYPE_UNUSABLE:
> +		return false;
> +	default:
> +		break;
> +	}
> +
> +	return true;
> +}
> +

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
