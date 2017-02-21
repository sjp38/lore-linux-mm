Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26B446B03A1
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 07:05:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u63so15509610wmu.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:05:09 -0800 (PST)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id 89si27855364wrs.86.2017.02.21.04.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 04:05:08 -0800 (PST)
Received: by mail-wr0-x236.google.com with SMTP id 97so2098682wrb.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:05:07 -0800 (PST)
Date: Tue, 21 Feb 2017 12:05:05 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v4 13/28] efi: Update efi_mem_type() to return
 defined EFI mem types
Message-ID: <20170221120505.GQ28416@codeblueprint.co.uk>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154457.19244.5369.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216154457.19244.5369.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, 16 Feb, at 09:44:57AM, Tom Lendacky wrote:
> Update the efi_mem_type() to return EFI_RESERVED_TYPE instead of a
> hardcoded 0.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/platform/efi/efi.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
> index a15cf81..6407103 100644
> --- a/arch/x86/platform/efi/efi.c
> +++ b/arch/x86/platform/efi/efi.c
> @@ -1037,7 +1037,7 @@ u32 efi_mem_type(unsigned long phys_addr)
>  	efi_memory_desc_t *md;
>  
>  	if (!efi_enabled(EFI_MEMMAP))
> -		return 0;
> +		return EFI_RESERVED_TYPE;
>  
>  	for_each_efi_memory_desc(md) {
>  		if ((md->phys_addr <= phys_addr) &&
> @@ -1045,7 +1045,7 @@ u32 efi_mem_type(unsigned long phys_addr)
>  				  (md->num_pages << EFI_PAGE_SHIFT))))
>  			return md->type;
>  	}
> -	return 0;
> +	return EFI_RESERVED_TYPE;
>  }

I see what you're getting at here, but arguably the return value in
these cases never should have been zero to begin with (your change
just makes that more obvious).

Returning EFI_RESERVED_TYPE implies an EFI memmap entry exists for
this address, which is misleading because it doesn't in the hunks
you've modified above.

Instead, could you look at returning a negative error value in the
usual way we do in the Linux kernel, and update the function prototype
to match? I don't think any callers actually require the return type
to be u32.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
