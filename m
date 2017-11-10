Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31E68280278
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:13:43 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o14so4648933wrf.6
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:13:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124sor265519wmv.23.2017.11.10.01.13.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:13:42 -0800 (PST)
Date: Fri, 10 Nov 2017 10:13:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/4] x86/boot/compressed/64: Detect and handle 5-level
 paging at boot-time
Message-ID: <20171110091339.rvqhdce55pil5c6k@gmail.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101115503.18358-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch prepare decompression code to boot-time switching between 4-
> and 5-level paging.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S   | 16 ++++++++++++----
>  arch/x86/boot/compressed/pagetable.c | 19 +++++++++++++++++++
>  2 files changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index b4a5d284391c..6ac8239af2b6 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -288,10 +288,18 @@ ENTRY(startup_64)
>  	leaq	boot_stack_end(%rbx), %rsp
>  
>  #ifdef CONFIG_X86_5LEVEL
> -	/* Check if 5-level paging has already enabled */
> -	movq	%cr4, %rax
> -	testl	$X86_CR4_LA57, %eax
> -	jnz	lvl5
> +	/*
> +	 * Check if we need to enable 5-level paging.
> +	 * RSI holds real mode data and need to be preserved across
> +	 * a function call.
> +	 */
> +	pushq	%rsi
> +	call	need_to_enabled_l5
> +	popq	%rsi
> +
> +	/* If need_to_enabled_l5() returned zero, we're done here. */
> +	cmpq	$0, %rax
> +	je	lvl5
>  
>  	/*
>  	 * At this point we are in long mode with 4-level paging enabled,
> diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
> index a15bbfcb3413..cd2dd49333cc 100644
> --- a/arch/x86/boot/compressed/pagetable.c
> +++ b/arch/x86/boot/compressed/pagetable.c
> @@ -154,3 +154,22 @@ void finalize_identity_maps(void)
>  }
>  
>  #endif /* CONFIG_RANDOMIZE_BASE */
> +
> +#ifdef CONFIG_X86_5LEVEL
> +int need_to_enabled_l5(void)
> +{
> +	/* Check i leaf 7 is supported. */
> +	if (native_cpuid_eax(0) < 7)
> +		return 0;
> +
> +	/* Check if la57 is supported. */
> +	if (!(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
> +		return 0;
> +
> +	/* Check if 5-level paging has already been enabled. */
> +	if (native_read_cr4() & X86_CR4_LA57)
> +		return 0;
> +
> +	return 1;
> +}
> +#endif

Ok, I like this a lot better than doing this at the assembly level - and this 
could provide a model for how to further reduce assembly code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
