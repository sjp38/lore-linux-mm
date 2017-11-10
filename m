Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD7F528028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:55:56 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o14so4706513wrf.6
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:55:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o30sor5651812eda.56.2017.11.10.01.55.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:55:55 -0800 (PST)
Date: Fri, 10 Nov 2017 12:55:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110095553.llbcmvaakn56mhzq@node.shutemov.name>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
 <20171110091703.7izzr7p3jkyxh7vd@gmail.com>
 <20171110092812.ad2i6fj5wmdmheuf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110092812.ad2i6fj5wmdmheuf@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 10, 2017 at 10:28:12AM +0100, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > > --- a/arch/x86/boot/compressed/head_64.S
> > > +++ b/arch/x86/boot/compressed/head_64.S
> > > @@ -315,6 +315,18 @@ ENTRY(startup_64)
> > >  	 * The first step is go into compatibility mode.
> > >  	 */
> > >  
> > > +	/*
> > > +	 * Find suitable place for trampoline and populate it.
> > > +	 * The address will be stored in RCX.
> > > +	 *
> > > +	 * RSI holds real mode data and need to be preserved across
> > > +	 * a function call.
> > > +	 */
> > > +	pushq	%rsi
> > > +	call	place_trampoline
> > > +	popq	%rsi
> > > +	movq	%rax, %rcx
> > > +
> > >  	/* Clear additional page table */
> > >  	leaq	lvl5_pgtable(%rbx), %rdi
> > >  	xorq	%rax, %rax
> > 
> > One request: it's always going to be fragile if the _only_ thing that uses the 
> > trampoline is the 5-level paging code.
> > 
> > Could we use the trampoline in the 4-level paging case too? It's not required, but 
> > would test much of the trampoline allocation and copying machinery - and the 
> > performance cost is negligible.
> 
> Note that right now the trampoline is pointless on 4-level setups, so there's 
> nothing to copy - but we could perhaps make it meaningful. But maybe it's not a 
> good idea.

Let me see how it will play out.

> One other detail I noticed:
> 
>         /* Bound size of trampoline code */
>         .org    lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE_SIZE
> 
> will this generate a build error if the trampoline code exceeds 0x40?

Yes, this is the point. Just a failsafe if trampoline code would grew too
much.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
