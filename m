Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1575A6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:02:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a107so2567979wrc.11
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:02:21 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id p108si1794857wrb.221.2017.11.29.12.02.17
        for <linux-mm@kvack.org>;
        Wed, 29 Nov 2017 12:02:17 -0800 (PST)
Date: Wed, 29 Nov 2017 21:02:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 5/6] x86/mm/kaiser: Optimize RESTORE_CR3
Message-ID: <20171129200212.gze3avcjofxrpy4t@pd.tnic>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.869504878@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171129103512.869504878@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Wed, Nov 29, 2017 at 11:33:06AM +0100, Peter Zijlstra wrote:
> Currently RESTORE_CR3 does an unconditional flush
> (SAVE_AND_SWITCH_TO_KERNEL_CR3 does not set bit 63 on \save_reg).
> 
> When restoring to a user ASID, check the user_asid_flush_mask to see
> if we can avoid the flush.
> 
> For kernel ASIDs we can unconditionaly avoid the flush, since we do
> explicit flushes for them.
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/x86/entry/calling.h  |   29 +++++++++++++++++++++++++++--
>  arch/x86/entry/entry_64.S |    4 ++--
>  2 files changed, 29 insertions(+), 4 deletions(-)
> 
> --- a/arch/x86/entry/calling.h
> +++ b/arch/x86/entry/calling.h
> @@ -263,8 +263,33 @@ For 32-bit we have the following convent
>  .Ldone_\@:
>  .endm
>  
> -.macro RESTORE_CR3 save_reg:req
> +.macro RESTORE_CR3 scratch_reg:req save_reg:req
>  	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
> +
> +	/* ASID bit 11 is for user */
> +	bt	$11, \save_reg

<---- newline here.

> +	/*
> +	 * KERNEL pages can always resume with NOFLUSH as we do
> +	 * explicit flushes.
> +	 */
> +	jnc	.Lnoflush_\@
> +
> +	/*
> +	 * Check if there's a pending flush for the user ASID we're
> +	 * about to set.
> +	 */
> +	movq	\save_reg, \scratch_reg
> +	andq	$(0x7FF), \scratch_reg
> +	bt	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> +	jnc	.Lnoflush_\@
> +
> +	btr	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> +	jmp	.Ldo_\@

Can you save yourself one of the BT-insns?

	...
	andq	$(0x7FF), \scratch_reg
	btr     \scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
	jnc	.Lnoflush_\@
	jmp     .Ldo_\@
	...

or am I missing a case?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
