Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA06280281
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:28:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e8so328635wmc.2
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:28:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o20sor3592224wro.12.2017.11.10.01.28.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:28:15 -0800 (PST)
Date: Fri, 10 Nov 2017 10:28:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110092812.ad2i6fj5wmdmheuf@gmail.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
 <20171110091703.7izzr7p3jkyxh7vd@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110091703.7izzr7p3jkyxh7vd@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Ingo Molnar <mingo@kernel.org> wrote:

> > --- a/arch/x86/boot/compressed/head_64.S
> > +++ b/arch/x86/boot/compressed/head_64.S
> > @@ -315,6 +315,18 @@ ENTRY(startup_64)
> >  	 * The first step is go into compatibility mode.
> >  	 */
> >  
> > +	/*
> > +	 * Find suitable place for trampoline and populate it.
> > +	 * The address will be stored in RCX.
> > +	 *
> > +	 * RSI holds real mode data and need to be preserved across
> > +	 * a function call.
> > +	 */
> > +	pushq	%rsi
> > +	call	place_trampoline
> > +	popq	%rsi
> > +	movq	%rax, %rcx
> > +
> >  	/* Clear additional page table */
> >  	leaq	lvl5_pgtable(%rbx), %rdi
> >  	xorq	%rax, %rax
> 
> One request: it's always going to be fragile if the _only_ thing that uses the 
> trampoline is the 5-level paging code.
> 
> Could we use the trampoline in the 4-level paging case too? It's not required, but 
> would test much of the trampoline allocation and copying machinery - and the 
> performance cost is negligible.

Note that right now the trampoline is pointless on 4-level setups, so there's 
nothing to copy - but we could perhaps make it meaningful. But maybe it's not a 
good idea.

One other detail I noticed:

        /* Bound size of trampoline code */
        .org    lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE_SIZE

will this generate a build error if the trampoline code exceeds 0x40?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
