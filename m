Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1616B03A0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:16:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 4so12223230wrc.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 00:16:17 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v127si12383526wma.59.2017.06.21.00.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 00:16:15 -0700 (PDT)
Date: Wed, 21 Jun 2017 09:16:05 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v7 08/36] x86/mm: Add support to enable SME in early boot
 processing
In-Reply-To: <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
Message-ID: <alpine.DEB.2.20.1706202259290.2157@nanos>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net> <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?ISO-8859-2?Q?Radim_Kr=E8m=E1=F8?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, 16 Jun 2017, Tom Lendacky wrote:
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index a105796..988b336 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -15,16 +15,24 @@
>  
>  #ifndef __ASSEMBLY__
>  
> +#include <linux/init.h>
> +
>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>  
>  extern unsigned long sme_me_mask;
>  
> +void __init sme_enable(void);
> +
>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>  
>  #define sme_me_mask	0UL
>  
> +static inline void __init sme_enable(void) { }
> +
>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>  
> +unsigned long sme_get_me_mask(void);

Why is this an unconditional function? Isn't the mask simply 0 when the MEM
ENCRYPT support is disabled?

> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
> index 6225550..ef12729 100644
> --- a/arch/x86/kernel/head_64.S
> +++ b/arch/x86/kernel/head_64.S
> @@ -78,7 +78,29 @@ startup_64:
>  	call	__startup_64
>  	popq	%rsi
>  
> -	movq	$(early_top_pgt - __START_KERNEL_map), %rax
> +	/*
> +	 * Encrypt the kernel if SME is active.
> +	 * The real_mode_data address is in %rsi and that register can be
> +	 * clobbered by the called function so be sure to save it.
> +	 */
> +	push	%rsi
> +	call	sme_encrypt_kernel
> +	pop	%rsi

That does not make any sense. Neither the call to sme_encrypt_kernel() nor
the following call to sme_get_me_mask().

__startup_64() is already C code, so why can't you simply call that from
__startup_64() in C and return the mask from there?

> @@ -98,7 +120,20 @@ ENTRY(secondary_startup_64)
>  	/* Sanitize CPU configuration */
>  	call verify_cpu
>  
> -	movq	$(init_top_pgt - __START_KERNEL_map), %rax
> +	/*
> +	 * Get the SME encryption mask.
> +	 *  The encryption mask will be returned in %rax so we do an ADD
> +	 *  below to be sure that the encryption mask is part of the
> +	 *  value that will stored in %cr3.
> +	 *
> +	 * The real_mode_data address is in %rsi and that register can be
> +	 * clobbered by the called function so be sure to save it.
> +	 */
> +	push	%rsi
> +	call	sme_get_me_mask
> +	pop	%rsi

Do we really need a call here? The mask is established at this point, so
it's either 0 when the encryption stuff is not compiled in or it can be
retrieved from a variable which is accessible at this point.

> +
> +	addq	$(init_top_pgt - __START_KERNEL_map), %rax
>  1:
>  
>  	/* Enable PAE mode, PGE and LA57 */

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
