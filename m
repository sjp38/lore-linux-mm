Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF0486B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:38:59 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id a72so2895188ioe.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:38:59 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f76si1536136itf.87.2017.11.29.05.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 05:38:58 -0800 (PST)
Date: Wed, 29 Nov 2017 14:38:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/6] x86/mm/kaiser: Support PCID without INVPCID
Message-ID: <20171129133841.mkphnjpryrffns43@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.819130098@infradead.org>
 <20171129123158.xqgiusjamnt2udag@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129123158.xqgiusjamnt2udag@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andy Lutomirski <luto@amacapital.net>

On Wed, Nov 29, 2017 at 01:31:58PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 29, 2017 at 11:33:05AM +0100, Peter Zijlstra wrote:
> > @@ -220,7 +215,27 @@ For 32-bit we have the following convent
> >  .macro SWITCH_TO_USER_CR3 scratch_reg:req
> >  	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
> >  	mov	%cr3, \scratch_reg
> > -	ADJUST_USER_CR3 \scratch_reg
> > +
> > +	/*
> > +	 * Test if the ASID needs a flush.
> > +	 */
> > +	push	\scratch_reg			/* preserve CR3 */
> 
> So I was just staring at disasm of a few functions and I noticed this
> one reads like push, while others read like pushq.
> 
> So does the stupid assembler thing really do a 32bit push if you provide
> it with a 64bit register?

N/m, I just really cannot read straight today. The pushq's were a mem64,
not a r64 argument to push.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
