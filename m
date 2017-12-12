Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DECA76B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:42:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 11so12464041wrb.18
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:42:21 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t9si13162045wra.449.2017.12.12.10.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 10:42:20 -0800 (PST)
Date: Tue, 12 Dec 2017 19:41:39 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
In-Reply-To: <20171212182906.cg635muwcdnh6p66@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.20.1712121940230.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de> <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com> <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net>
 <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com> <C3141266-5522-4B5E-A0CE-65523F598F6D@amacapital.net> <20171212182906.cg635muwcdnh6p66@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Peter Zijlstra wrote:

> On Tue, Dec 12, 2017 at 10:22:48AM -0800, Andy Lutomirski wrote:
> > 
> > Also, why is LAR deferred to user exit?  And I thought that LAR didn't
> > set the accessed bit.
> 
> LAR does not set the ACCESSED bit indeed, we need to explicitly set that
> when creating the descriptor.
> 
> It also works if you do the LAR right after LLDT (which is what I
> originally had). The reason its a TIF flag is that I originally LAR'ed
> every entry in the table.
> 
> It got reduced to CS/SS, but the TIF thing stayed.
> 
> > If I had to guess, I'd guess that LAR is actually generating a read
> > fault and forcing the pagetables to get populated.  If so, then it
> > means the VMA code isn't quite right, or you're susceptible to
> > failures under memory pressure.
> > 
> > Now maybe LAR will repopulate the PTE every time if you were to never
> > clear it, but ick.
> 
> I did not observe #PFs from LAR, we had a giant pile of trace_printk()
> in there.

The pages are populated _before_ the new ldt is installed. So no memory
pressure issue, nothing. If the populate fails, then modify_ldt() returns
with an error.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
