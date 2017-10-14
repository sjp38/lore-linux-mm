Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A09426B0284
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 03:33:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p46so2223827wrb.1
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 00:33:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor720919wmh.60.2017.10.14.00.33.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 00:33:56 -0700 (PDT)
Date: Sat, 14 Oct 2017 09:33:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv2, RFC] x86/boot/compressed/64: Handle 5-level paging
 boot if kernel is above 4G
Message-ID: <20171014073353.trbh3w4lo7t2njsi@gmail.com>
References: <20171013122345.86304-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013122345.86304-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch addresses shortcoming in current boot process on machines
> that supports 5-level paging.
> 
> If bootloader enables 64-bit mode with 4-level paging, we need to
> switch over to 5-level paging. The switching requires disabling paging.
> It works fine if kernel itself is loaded below 4G.
> 
> If bootloader put the kernel above 4G (not sure if anybody does this),
> we would loose control as soon as paging is disabled as code becomes
> unreachable.
> 
> This patch implements trampoline in lower memory to handle this
> situation.
> 
> Apart from trampoline itself we also need place to store top level page
> table in lower memory as we don't have a way to load 64-bit value into
> CR3 from 32-bit mode. We only really need 8-bytes there as we only use
> the very first entry of the page table.
> 
> place_trampoline() would choose an address for the trampoline page.
> The implementation is based on reserve_bios_regions(). We take a page
> next to end of lowmem.
> 
> We only need the page  for very short time, until main kernel image
> setup its own page tables.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/head_64.S | 87 ++++++++++++++++++++++++++------------
>  arch/x86/boot/compressed/misc.c    | 25 +++++++++++
>  2 files changed, 84 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> index cefe4958fda9..961c72755986 100644
> --- a/arch/x86/boot/compressed/head_64.S
> +++ b/arch/x86/boot/compressed/head_64.S
> @@ -288,8 +288,23 @@ ENTRY(startup_64)
>  	leaq	boot_stack_end(%rbx), %rsp
>  
>  #ifdef CONFIG_X86_5LEVEL
> +/*
> + * We need trampoline in lower memory switch from 4- to 5-level paging for
> + * cases when bootloader put kernel above 4G, but didn't enable 5-level paging
> + * for us.
> + *
> + * We also have to have top page table in lower memory as we don't have a way
> + * to load 64-bit value into CR3 from 32-bit mode. We only need 8-bytes there
> + * as we only use the very first entry of the page table.
> + *
> + * The same page can be used to place both trampoline code and top level page
> + * table. place_trampoline() will find suitable place for the trampoline page.
> + * Code will be placed with offset 0x100 from beginning of the page.
> + */
> +#define LVL5_TRAMPOLINE_CODE	0x100
> +
>  	/* Preserve RBX across CPUID */
> -	movq	%rbx, %r8
> +	movq	%rbx, %r15
>  
>  	/* Check if leaf 7 is supported */
>  	xorl	%eax, %eax
> @@ -307,9 +322,6 @@ ENTRY(startup_64)
>  	andl	$(1 << 16), %ecx
>  	jz	lvl5
>  
> -	/* Restore RBX */
> -	movq	%r8, %rbx
> -
>  	/* Check if 5-level paging has already been enabled */
>  	movq	%cr4, %rax
>  	testl	$X86_CR4_LA57, %eax
> @@ -323,34 +335,53 @@ ENTRY(startup_64)
>  	 * long mode would trigger #GP. So we need to switch off long mode
>  	 * first.
>  	 *
> -	 * NOTE: This is not going to work if bootloader put us above 4G
> -	 * limit.
> +	 * We use trampoline in lower memory to handle situation when
> +	 * bootloader put the kernel image above 4G.
>  	 *
>  	 * The first step is go into compatibility mode.
>  	 */
>  
> -	/* Clear additional page table */
> -	leaq	lvl5_pgtable(%rbx), %rdi
> -	xorq	%rax, %rax
> -	movq	$(PAGE_SIZE/8), %rcx
> -	rep	stosq
> +	/*
> +	 * Find sitable place for trampoline.
> +	 * The address will be stored in RBX.
> +	 */
> +	call	place_trampoline
> +	movq	%rax, %rbx
> +
> +	/* Preserve RSI, to be used by movsb below */
> +	movq	%rsi, %r14
> +
> +	/* Copy trampoline code in place */
> +	leaq	lvl5_trampoline_src(%rip), %rsi
> +	leaq	LVL5_TRAMPOLINE_CODE(%rbx), %rdi
> +	movq	$(lvl5_trampoline_end - lvl5_trampoline_src), %rcx
> +	rep	movsb
> +
> +	/* Restore RSI */
> +	movq	%r14, %rsi

Yeah, so first most of this code should be moved from assembly to C. Any reason 
why that cannot be done?

Cleanups like that are a precondition to adding this patch or other 5-level 
paging complications like the dynamic boot time switching.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
