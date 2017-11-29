Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB4086B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:06:23 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g2so3993173itf.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:06:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 7si1022522itx.12.2017.11.29.12.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 12:06:22 -0800 (PST)
Date: Wed, 29 Nov 2017 21:06:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/6] x86/mm/kaiser: Optimize RESTORE_CR3
Message-ID: <20171129200608.q63o7mm2hdp26yk7@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.869504878@infradead.org>
 <20171129200212.gze3avcjofxrpy4t@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129200212.gze3avcjofxrpy4t@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Wed, Nov 29, 2017 at 09:02:12PM +0100, Borislav Petkov wrote:
> On Wed, Nov 29, 2017 at 11:33:06AM +0100, Peter Zijlstra wrote:
> > +.macro RESTORE_CR3 scratch_reg:req save_reg:req
> >  	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
> > +
> > +	/* ASID bit 11 is for user */
> > +	bt	$11, \save_reg
> 
> <---- newline here.

Seems weird to me, the bt and jnc are a pair.

> > +	/*
> > +	 * KERNEL pages can always resume with NOFLUSH as we do
> > +	 * explicit flushes.
> > +	 */
> > +	jnc	.Lnoflush_\@
> > +
> > +	/*
> > +	 * Check if there's a pending flush for the user ASID we're
> > +	 * about to set.
> > +	 */
> > +	movq	\save_reg, \scratch_reg
> > +	andq	$(0x7FF), \scratch_reg
> > +	bt	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> > +	jnc	.Lnoflush_\@
> > +
> > +	btr	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> > +	jmp	.Ldo_\@
> 
> Can you save yourself one of the BT-insns?
> 
> 	...
> 	andq	$(0x7FF), \scratch_reg
> 	btr     \scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
> 	jnc	.Lnoflush_\@
> 	jmp     .Ldo_\@
> 	...
> 
> or am I missing a case?

BTR is an unconditional write and will modify the line and cause a
write-back later. The common case is the bit not set, so BT, which is a
pure read, avoids all that overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
