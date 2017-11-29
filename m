Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A57A76B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:32:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so2362241pfh.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:32:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x23si1179457pln.821.2017.11.29.04.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 04:32:06 -0800 (PST)
Date: Wed, 29 Nov 2017 13:31:58 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/6] x86/mm/kaiser: Support PCID without INVPCID
Message-ID: <20171129123158.xqgiusjamnt2udag@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.819130098@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129103512.819130098@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andy Lutomirski <luto@amacapital.net>

On Wed, Nov 29, 2017 at 11:33:05AM +0100, Peter Zijlstra wrote:
> @@ -220,7 +215,27 @@ For 32-bit we have the following convent
>  .macro SWITCH_TO_USER_CR3 scratch_reg:req
>  	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
>  	mov	%cr3, \scratch_reg
> -	ADJUST_USER_CR3 \scratch_reg
> +
> +	/*
> +	 * Test if the ASID needs a flush.
> +	 */
> +	push	\scratch_reg			/* preserve CR3 */

So I was just staring at disasm of a few functions and I noticed this
one reads like push, while others read like pushq.

So does the stupid assembler thing really do a 32bit push if you provide
it with a 64bit register?

> +	andq	$(0x7FF), \scratch_reg		/* mask ASID */
> +	bt	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> +	jnc	.Lnoflush_\@
> +
> +	/* Flush needed, clear the bit */
> +	btr	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> +	pop	\scratch_reg			/* original CR3 */
> +	jmp	.Ldo_\@
> +
> +.Lnoflush_\@:
> +	pop	\scratch_reg			/* original CR3 */
> +	ALTERNATIVE "", "bts $63, \scratch_reg", X86_FEATURE_PCID
> +
> +.Ldo_\@:
> +	/* Flip the PGD and ASID to the user version */
> +	orq     $(KAISER_SWITCH_MASK), \scratch_reg
>  	mov	\scratch_reg, %cr3
>  .Lend_\@:
>  .endm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
