Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 145B46B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 03:02:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p111so18302649wrc.10
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:02:08 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id w22si24673468wra.281.2017.04.11.00.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 00:02:06 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id x75so13195892wma.1
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:02:06 -0700 (PDT)
Date: Tue, 11 Apr 2017 09:02:03 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/8] x86/boot/64: Add support of additional page table
 level during early boot
Message-ID: <20170411070203.GA14621@gmail.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch adds support for 5-level paging during early boot.
> It generalizes boot for 4- and 5-level paging on 64-bit systems with
> compile-time switch between them.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S          | 23 ++++++++++++---
>  arch/x86/include/asm/pgtable_64.h           |  2 ++
>  arch/x86/include/uapi/asm/processor-flags.h |  2 ++
>  arch/x86/kernel/head64.c                    | 44 +++++++++++++++++++++++++----
>  arch/x86/kernel/head_64.S                   | 29 +++++++++++++++----
>  5 files changed, 85 insertions(+), 15 deletions(-)
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index d2ae1f821e0c..3ed26769810b 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -122,9 +122,12 @@ ENTRY(startup_32)
>  	addl	%ebp, gdt+2(%ebp)
>  	lgdt	gdt(%ebp)
>  
> -	/* Enable PAE mode */
> +	/* Enable PAE and LA57 mode */
>  	movl	%cr4, %eax
>  	orl	$X86_CR4_PAE, %eax
> +#ifdef CONFIG_X86_5LEVEL
> +	orl	$X86_CR4_LA57, %eax
> +#endif
>  	movl	%eax, %cr4
>  
>   /*
> @@ -136,13 +139,24 @@ ENTRY(startup_32)
>  	movl	$(BOOT_INIT_PGT_SIZE/4), %ecx
>  	rep	stosl
>  
> +	xorl	%edx, %edx
> +
> +	/* Build Top Level */
> +	leal	pgtable(%ebx,%edx,1), %edi
> +	leal	0x1007 (%edi), %eax
> +	movl	%eax, 0(%edi)
> +
> +#ifdef CONFIG_X86_5LEVEL
>  	/* Build Level 4 */
> -	leal	pgtable + 0(%ebx), %edi
> +	addl	$0x1000, %edx
> +	leal	pgtable(%ebx,%edx), %edi
>  	leal	0x1007 (%edi), %eax
>  	movl	%eax, 0(%edi)
> +#endif
>  
>  	/* Build Level 3 */
> -	leal	pgtable + 0x1000(%ebx), %edi
> +	addl	$0x1000, %edx
> +	leal	pgtable(%ebx,%edx), %edi
>  	leal	0x1007(%edi), %eax
>  	movl	$4, %ecx
>  1:	movl	%eax, 0x00(%edi)
> @@ -152,7 +166,8 @@ ENTRY(startup_32)
>  	jnz	1b
>  
>  	/* Build Level 2 */
> -	leal	pgtable + 0x2000(%ebx), %edi
> +	addl	$0x1000, %edx
> +	leal	pgtable(%ebx,%edx), %edi
>  	movl	$0x00000183, %eax
>  	movl	$2048, %ecx
>  1:	movl	%eax, 0(%edi)

I realize that you had difficulties converting this to C, but it's not going to 
get any easier in the future either, with one more paging mode/level added!

If you are stuck on where it breaks I'd suggest doing it gradually: first add a 
trivial .c, build and link it in and call it separately. Then once that works, 
move functionality from asm to C step by step and test it at every step.

I've applied the first two patches of this series, but we really should convert 
this assembly bit to C too.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
