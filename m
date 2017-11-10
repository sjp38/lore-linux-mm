Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED1D28027D
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:17:07 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y42so4550382wrd.23
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:17:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 82sor265174wmi.76.2017.11.10.01.17.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:17:06 -0800 (PST)
Date: Fri, 10 Nov 2017 10:17:03 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110091703.7izzr7p3jkyxh7vd@gmail.com>
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

> If bootloader enables 64-bit mode with 4-level paging, we need to
> switch over to 5-level paging. The switching requires disabling paging.
> It works fine if kernel itself is loaded below 4G.
> 
> If bootloader put the kernel above 4G (not sure if anybody does this),
> we would loose control as soon as paging is disabled as code becomes
> unreachable.
> 
> To handle the situation, we need a trampoline in lower memory that would
> take care about switching on 5-level paging.
> 
> Apart from trampoline itself we also need place to store top level page
> table in lower memory as we don't have a way to load 64-bit value into
> CR3 from 32-bit mode. We only really need 8-bytes there as we only use
> the very first entry of the page table. But we allocate whole page
> anyway. We cannot have the code in the same because, there's hazard that
> a CPU would read page table speculatively and get confused seeing
> garbage.
> 
> This patch introduces place_trampoline() that finds right spot in lower
> memory for trampoline, copies trampoline code there and setups new top
> level page table for 5-level paging.
> 
> At this point we do all the preparation, but not yet use trampoline.
> It will be done in following patch.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S   | 13 +++++++++++
>  arch/x86/boot/compressed/pagetable.c | 42 ++++++++++++++++++++++++++++++++++++
>  arch/x86/boot/compressed/pagetable.h | 18 ++++++++++++++++
>  3 files changed, 73 insertions(+)
>  create mode 100644 arch/x86/boot/compressed/pagetable.h
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index 6ac8239af2b6..4d1555b39de0 100644
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

One request: it's always going to be fragile if the _only_ thing that uses the 
trampoline is the 5-level paging code.

Could we use the trampoline in the 4-level paging case too? It's not required, but 
would test much of the trampoline allocation and copying machinery - and the 
performance cost is negligible.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
