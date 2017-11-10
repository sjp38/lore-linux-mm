Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2400F280281
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:29:38 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v88so4605533wrb.22
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:29:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor3507930wrg.89.2017.11.10.01.29.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:29:37 -0800 (PST)
Date: Fri, 10 Nov 2017 10:29:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110092933.gt4f3ofhjl4fpuqt@gmail.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -315,6 +315,18 @@ ENTRY(startup_64)
>  	 * The first step is go into compatibility mode.
>  	 */
>  
> +	/*
> +	 * Find suitable place for trampoline and populate it.
> +	 * The address will be stored in RCX.
> +	 *
> +	 * RSI holds real mode data and need to be preserved across
> +	 * a function call.
> +	 */
> +	pushq	%rsi
> +	call	place_trampoline
> +	popq	%rsi
> +	movq	%rax, %rcx
> +
>  	/* Clear additional page table */
>  	leaq	lvl5_pgtable(%rbx), %rdi
>  	xorq	%rax, %rax

So in the final version of this code we now have:

	pushq	%rsi
	call	need_to_enabled_l5
	popq	%rsi

	/* If need_to_enabled_l5() returned zero, we're done here. */
	cmpq	$0, %rax
	je	lvl5

	/*
	 * At this point we are in long mode with 4-level paging enabled,
	 * but we want to enable 5-level paging.
	 *
	 * The problem is that we cannot do it directly. Setting LA57 in
	 * long mode would trigger #GP. So we need to switch off long mode
	 * first.
	 *
	 * We use trampoline in lower memory to handle situation when
	 * bootloader put the kernel image above 4G.
	 *
	 * The first step is go into compatibility mode.
	 */

	/*
	 * Find suitable place for trampoline and populate it.
	 * The address will be stored in RCX.
	 *
	 * RSI holds real mode data and need to be preserved across
	 * a function call.
	 */
	pushq	%rsi
	call	place_trampoline
	popq	%rsi
	movq	%rax, %rcx

Firstly, the 'need_to_enabled_l5' name sucks because it includes a typo, but also 
because the prefix is way too generic.

Something like:

	l5_paging_required()

would read a lot better - and would also provide a namespace for all L5 paging 
related functions.

Secondly, couldn't this be combined into a single .c function, named accordingly:

	l5_paging_prepare()

which would return true if L5 paging is available and should be enabled. In this 
case the trampoline copying function would be called in C, by l5_paging_prepare().

This further reduces the amount of assembly code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
