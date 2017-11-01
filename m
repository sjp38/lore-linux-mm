Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0E6E6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 14:18:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e75so1681485wmi.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 11:18:17 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id 31si1071314wri.328.2017.11.01.11.18.16
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 11:18:16 -0700 (PDT)
Date: Wed, 1 Nov 2017 19:18:05 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
Message-ID: <20171101181805.3jjzfe6vhmgorjtp@pd.tnic>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223148.5334003A@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171031223148.5334003A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, Oct 31, 2017 at 03:31:48PM -0700, Dave Hansen wrote:
> diff -puN arch/x86/entry/calling.h~kaiser-luto-base-cr3-work arch/x86/entry/calling.h
> --- a/arch/x86/entry/calling.h~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.105007253 -0700
> +++ b/arch/x86/entry/calling.h	2017-10-31 15:03:48.113007631 -0700
> @@ -1,5 +1,6 @@
>  #include <linux/jump_label.h>
>  #include <asm/unwind_hints.h>
> +#include <asm/cpufeatures.h>
>  
>  /*
>  
> @@ -217,6 +218,45 @@ For 32-bit we have the following convent
>  #endif
>  .endm
>  
> +.macro ADJUST_KERNEL_CR3 reg:req
> +.endm
> +
> +.macro ADJUST_USER_CR3 reg:req
> +.endm
> +
> +.macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
> +	mov	%cr3, \scratch_reg
> +	ADJUST_KERNEL_CR3 \scratch_reg
> +	mov	\scratch_reg, %cr3
> +.endm
> +
> +.macro SWITCH_TO_USER_CR3 scratch_reg:req
> +	mov	%cr3, \scratch_reg
> +	ADJUST_USER_CR3 \scratch_reg
> +	mov	\scratch_reg, %cr3
> +.endm
> +
> +.macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
> +	movq	%cr3, %r\scratch_reg
> +	movq	%r\scratch_reg, \save_reg

So one of the args gets passed as "ax", for example, which then gets
completed to a register with the "%r" prepended and the other is a full
register: %r14.

What for? Can we stick with one format pls?

> +	/*
> +	 * Just stick a random bit in here that never gets set.  Fixed
> +	 * up in real KAISER patches in a moment.
> +	 */
> +	bt	$63, %r\scratch_reg
> +	jz	.Ldone_\@
> +
> +	ADJUST_KERNEL_CR3 %r\scratch_reg
> +	movq	%r\scratch_reg, %cr3
> +
> +.Ldone_\@:
> +.endm
> +
> +.macro RESTORE_CR3 save_reg:req
> +	/* optimize this */
> +	movq	\save_reg, %cr3
> +.endm
> +
>  #endif /* CONFIG_X86_64 */
>  
>  /*
> diff -puN arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64_compat.S
> --- a/arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.107007348 -0700
> +++ b/arch/x86/entry/entry_64_compat.S	2017-10-31 15:03:48.113007631 -0700
> @@ -48,8 +48,13 @@
>  ENTRY(entry_SYSENTER_compat)
>  	/* Interrupts are off on entry. */
>  	SWAPGS_UNSAFE_STACK
> +
>  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>  
> +	pushq	%rdi
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
> +	popq	%rdi

So we switch to kernel CR3 right after we've setup kernel stack...

> +
>  	/*
>  	 * User tracing code (ptrace or signal handlers) might assume that
>  	 * the saved RAX contains a 32-bit number when we're invoking a 32-bit
> @@ -91,6 +96,9 @@ ENTRY(entry_SYSENTER_compat)
>  	pushq   $0			/* pt_regs->r15 = 0 */
>  	cld
>  
> +	pushq	%rdi
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
> +	popq	%rdi

... and switch here *again*, after pushing pt_regs?!? What's up?

>  	/*
>  	 * SYSENTER doesn't filter flags, so we need to clear NT and AC
>  	 * ourselves.  To save a few cycles, we can check whether
-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
