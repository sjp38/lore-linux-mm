Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDE276B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:18:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i131so1461426wma.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:18:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r19sor59597wmd.86.2017.09.28.01.18.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:18:28 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:18:25 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 06/19] x86/boot/compressed/64: Detect and handle
 5-level paging at boot-time
Message-ID: <20170928081825.mq3gccldrgbvjlnc@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-7-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-7-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch prepare decompression code to boot-time switching between 4-
> and 5-level paging.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index b4a5d284391c..09c85e8558eb 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -288,6 +288,28 @@ ENTRY(startup_64)
>  	leaq	boot_stack_end(%rbx), %rsp
>  
>  #ifdef CONFIG_X86_5LEVEL
> +	/* Preserve rbx across cpuid */
> +	movq	%rbx, %r8
> +
> +	/* Check if leaf 7 is supported */
> +	xorl	%eax, %eax
> +	cpuid
> +	cmpl	$7, %eax
> +	jb	lvl5
> +
> +	/*
> +	 * Check if la57 is supported.
> +	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
> +	 */
> +	movl	$7, %eax
> +	xorl	%ecx, %ecx
> +	cpuid
> +	andl	$(1 << 16), %ecx
> +	jz	lvl5
> +
> +	/* Restore rbx */

In (new) x86 asm code we refer to registers in capital letters.

Also, CPUID should be capitalized consistently as well.

Also, LA57 should be capitalized as well.

> +	movq	%r8, %rbx
> +
>  	/* Check if 5-level paging has already enabled */
>  	movq	%cr4, %rax

BTW., please also fix the typo in this comment while at it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
