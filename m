Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 017526B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 10:05:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c202so20965186wme.10
        for <linux-mm@kvack.org>; Tue, 16 May 2017 07:05:00 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id 88si1996153wrf.233.2017.05.16.07.04.58
        for <linux-mm@kvack.org>;
        Tue, 16 May 2017 07:04:58 -0700 (PDT)
Date: Tue, 16 May 2017 16:04:49 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 19/32] x86/mm: Add support to access persistent memory
 in the clear
Message-ID: <20170516140449.zmp3sm4krro55bbi@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211941.10190.19751.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418211941.10190.19751.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:19:42PM -0500, Tom Lendacky wrote:
> Persistent memory is expected to persist across reboots. The encryption
> key used by SME will change across reboots which will result in corrupted
> persistent memory.  Persistent memory is handed out by block devices
> through memory remapping functions, so be sure not to map this memory as
> encrypted.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/mm/ioremap.c |   31 ++++++++++++++++++++++++++++++-
>  1 file changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index bce0604..55317ba 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -425,17 +425,46 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>   * Examine the physical address to determine if it is an area of memory
>   * that should be mapped decrypted.  If the memory is not part of the
>   * kernel usable area it was accessed and created decrypted, so these
> - * areas should be mapped decrypted.
> + * areas should be mapped decrypted. And since the encryption key can
> + * change across reboots, persistent memory should also be mapped
> + * decrypted.
>   */
>  static bool memremap_should_map_decrypted(resource_size_t phys_addr,
>  					  unsigned long size)
>  {
> +	int is_pmem;
> +
> +	/*
> +	 * Check if the address is part of a persistent memory region.
> +	 * This check covers areas added by E820, EFI and ACPI.
> +	 */
> +	is_pmem = region_intersects(phys_addr, size, IORESOURCE_MEM,
> +				    IORES_DESC_PERSISTENT_MEMORY);
> +	if (is_pmem != REGION_DISJOINT)
> +		return true;
> +
> +	/*
> +	 * Check if the non-volatile attribute is set for an EFI
> +	 * reserved area.
> +	 */
> +	if (efi_enabled(EFI_BOOT)) {
> +		switch (efi_mem_type(phys_addr)) {
> +		case EFI_RESERVED_TYPE:
> +			if (efi_mem_attributes(phys_addr) & EFI_MEMORY_NV)
> +				return true;
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +
>  	/* Check if the address is outside kernel usable area */
>  	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
>  	case E820_TYPE_RESERVED:
>  	case E820_TYPE_ACPI:
>  	case E820_TYPE_NVS:
>  	case E820_TYPE_UNUSABLE:
> +	case E820_TYPE_PRAM:

Can't you simply add:

	case E820_TYPE_PMEM:

here too and thus get rid of the region_intersects() thing above?

Because, for example, e820_type_to_iores_desc() maps E820_TYPE_PMEM to
IORES_DESC_PERSISTENT_MEMORY so those should be equivalent...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
