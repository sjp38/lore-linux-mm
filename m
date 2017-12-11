Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 592E16B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 09:26:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so4643813wmd.0
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 06:26:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n82sor2075651wmf.57.2017.12.11.06.26.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 06:26:21 -0800 (PST)
Date: Mon, 11 Dec 2017 15:26:18 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv5 2/3] x86/boot/compressed/64: Introduce
 place_trampoline()
Message-ID: <20171211142618.rrcg5javpoinbigg@gmail.com>
References: <20171208130922.21488-1-kirill.shutemov@linux.intel.com>
 <20171208130922.21488-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208130922.21488-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> If a bootloader enables 64-bit mode with 4-level paging, we might need to
> switch over to 5-level paging. The switching requires the disabling
> paging. It works fine if kernel itself is loaded below 4G.
> 
> But if the bootloader put the kernel above 4G (not sure if anybody does
> this), we would lose control as soon as paging is disabled, because the
> code becomes unreachable to the CPU.
> 
> To handle the situation, we need a trampoline in lower memory that would
> take care of switching on 5-level paging.
> 
> Apart from the trampoline code itself we also need a place to store top
> level page table in lower memory as we don't have a way to load 64-bit
> values into CR3 in 32-bit mode. We only really need 8 bytes there as we
> only use the very first entry of the page table. But we allocate a whole
> page anyway.
> 
> We cannot have the code in the same page as the page table because there's
> a risk that a CPU would read the page table speculatively and get confused
> by seeing garbage. It's never a good idea to have junk in PTE entries
> visible to the CPU.
> 
> We also need a small stack in the trampoline to re-enable long mode via
> long return. But stack and code can share the page just fine.
> 
> This patch introduces paging_prepare() that checks if we need to enable
> 5-level paging and then finds a right spot in lower memory for the
> trampoline. Then it copies the trampoline code there and sets up the new
> top level page table for 5-level paging.
> 
> At this point we do all the preparation, but don't use trampoline yet.
> It will be done in the following patch.
> 
> The trampoline will be used even on 4-level paging machines. This way we
> will get better test coverage and the keep the trampoline code in shape.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S    | 44 ++++++++++++-------------
>  arch/x86/boot/compressed/pgtable.h    | 18 +++++++++++
>  arch/x86/boot/compressed/pgtable_64.c | 61 ++++++++++++++++++++++++++++-------
>  3 files changed, 89 insertions(+), 34 deletions(-)
>  create mode 100644 arch/x86/boot/compressed/pgtable.h
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index fc313e29fe2c..392324004d99 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -304,20 +304,6 @@ ENTRY(startup_64)
>  	/* Set up the stack */
>  	leaq	boot_stack_end(%rbx), %rsp
>  
> -#ifdef CONFIG_X86_5LEVEL
> -	/*
> -	 * Check if we need to enable 5-level paging.
> -	 * RSI holds real mode data and need to be preserved across
> -	 * a function call.
> -	 */
> -	pushq	%rsi
> -	call	l5_paging_required
> -	popq	%rsi
> -
> -	/* If l5_paging_required() returned zero, we're done here. */
> -	cmpq	$0, %rax
> -	je	lvl5
> -
>  	/*
>  	 * At this point we are in long mode with 4-level paging enabled,
>  	 * but we want to enable 5-level paging.
> @@ -325,12 +311,28 @@ ENTRY(startup_64)
>  	 * The problem is that we cannot do it directly. Setting LA57 in
>  	 * long mode would trigger #GP. So we need to switch off long mode
>  	 * first.
> +	 */
> +
> +	/*
> +	 * paging_prepare() would set up the trampoline and check if we need to
> +	 * enable 5-level paging.
>  	 *
> -	 * NOTE: This is not going to work if bootloader put us above 4G
> -	 * limit.
> +	 * Address of the trampoline is returned in RAX. Bit 0 is used to
> +	 * encode if we need to enable 5-level paging.

Hm, that encodig looks unnecessarily complicated - why not return a 128-bit 
struct, where the first 64 bits get into RAX and the second into RDX?

That way RAX can be 

Also, the patch looks a bit complex - could we split it into three more parts:

 - First part introduces the calling of paging_prepare(), and does the LA57 return 
   code handling. The trampoline is not allocated and 0 is returned as the 
   trampoline address (it's not used)

 - Second part allocates, initializes and returns the trampoline - but does not 
   use it yet

 - Third patch uses the trampoline

This way if there's any breakage there's a very specific, dedicated patch to 
bisect to.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
