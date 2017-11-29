Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3465C6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:48:31 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id h1so1155204plh.23
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 03:48:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q1si1173049plb.432.2017.11.29.03.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 03:48:30 -0800 (PST)
Date: Wed, 29 Nov 2017 12:48:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/6] x86/mm/kaiser: Support PCID without INVPCID
Message-ID: <20171129114814.rait2d6u4gso5qqd@hirez.programming.kicks-ass.net>
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

> XXX we could do a much larger ALTERNATIVE, there is no point in
> testing the mask if we don't have PCID support.

This.

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

Something like so seems to actually compile and generate sensible code,
not tested it though.


--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -216,6 +216,8 @@ For 32-bit we have the following convent
 	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	mov	%cr3, \scratch_reg
 
+	ALTERNATIVE "jmp .Ldo_\@", "", X86_FEATURE_PCID
+
 	/*
 	 * Test if the ASID needs a flush.
 	 */
@@ -231,7 +233,7 @@ For 32-bit we have the following convent
 
 .Lnoflush_\@:
 	pop	\scratch_reg			/* original CR3 */
-	ALTERNATIVE "", "bts $63, \scratch_reg", X86_FEATURE_PCID
+	bts	$63, \scratch_reg
 
 .Ldo_\@:
 	/* Flip the PGD and ASID to the user version */
@@ -266,6 +268,8 @@ For 32-bit we have the following convent
 .macro RESTORE_CR3 scratch_reg:req save_reg:req
 	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 
+	ALTERNATIVE "jmp .Ldo_\@", "", X86_FEATURE_PCID
+
 	/* ASID bit 11 is for user */
 	bt	$11, \save_reg
 	/*
@@ -287,7 +291,7 @@ For 32-bit we have the following convent
 	jmp	.Ldo_\@
 
 .Lnoflush_\@:
-	ALTERNATIVE "", "bts $63, \save_reg", X86_FEATURE_PCID
+	bts	$63, \save_reg
 
 .Ldo_\@:
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
