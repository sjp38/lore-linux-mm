Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFDF36B2873
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:58:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m25-v6so2287521pgv.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:58:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i185-v6sor1038302pge.205.2018.08.22.22.58.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 22:58:58 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:58:49 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823155849.37ca4118@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFwiNaQAW=Xf9cYDAk4GKkRt=1A-Ojy0TUnVVK160ygXWw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	<20180823143349.65cb0da0@roar.ozlabs.ibm.com>
	<CA+55aFwiNaQAW=Xf9cYDAk4GKkRt=1A-Ojy0TUnVVK160ygXWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 22:03:40 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Aug 22, 2018 at 9:33 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > I think it was quite well understood and fixed here, a145abf12c9 but
> > again that was before I really started looking at it.  
> 
> You don't understand the problem.

More fundamentally I think I didn't understand this fix, I think
actually powerpc/radix does have a bug here. a145abf12c9 was really
just a replacement for x86's hack of expanding the TLB invalidation
range when freeing page table to capture page walk cache (powerpc/radix
needs a different instruction so that didn't work for us).

But I hadn't really looked at this fix closely rather Peter's follow up
post about making powerpc page walk cache flushing design a generic
concept.

My point in this reply was more that my patches from the other month
weren't a blundering issue to fix this bug without realising it, they
were purely about avoiding the x86 TLB range expanding hack (that won't
be needed if generic users all move over).

> 
> All the x86 people thought WE ALREADY DID THAT.
> 
> Because we had done this all correctly over a decade ago!
> 
> Nobody realized that it had been screwed up by the powerpc code, and

The powerpc/hash code is not screwed up though AFAIKS. You can't
take arch specific code and slap a "generic" label on it, least of all
the crazy powerpc/hash code, you of all people would agree with that :)

> the commit you point to was believed to be a new *powerpc* only issue,
> because the semantics on powerpc has changed because of the radix
> tree.
> 
> The semantics on x86 have never changed, they've always been the same.
> So why would the x86 people react to powerpc doing something that x86
> had already always done.
> 
> See?
> 
> Nobody cared one whit about commit a145abf12c9, because it just
> handles a new powerpc-specific case.
> 
> > I don't really understand what the issue you have with powerpc here.
> > powerpc hash has the page table flushing accessors which are just
> > no-ops, it's the generic code that fails to call them properly. Surely
> > there was no powerpc patch that removed those calls from generic code?  
> 
> Yes there was.
> 
> Look where the generic code *came* from.
> 
> It's powerpc code.
> 
> See commit 267239116987 ("mm, powerpc: move the RCU page-table freeing
> into generic code").
> 
> The powerpc code was made into the generic code, because the powerpc
> code had to handle all those special RCU freeing things etc that
> others didn't.
> 
> It's just that when x86 was then switched over to use the "generic"
> code, people didn't realize that the generic code didn't do the TLB
> invalidations for page tables, because they hadn't been needed on
> powerpc.

Sure, there was a minor bug in the port. Not that it was a closely
guarded secret that powerpc didn't flush page table pages, but it's a
relatively subtle issue in complex code. That happens.

> 
> So the powerpc code that was made generic, never really was. The new
> "generic" code had a powerpc-specific quirk.
> 
> That then very subtly broke x86, without the x86 people ever
> realizing. Because the old simple non-RCU x86 code had never had that
> issue, it just treated the leaf pages and the directory pages exactly
> the same.
> 
> See?
> 
> And THAT is why I talk about the powerpc code. Because what is
> "generic" code in 4.18 (and several releases before) oisn't actually
> generic.
> 
> And that's basically exactly the bug that the patches from PeterZ is
> fixing. Making the "tlb_remove_table()" code always flush the tlb, the
> way it should have when it was made generic.

It just sounded like you were blaming correct powerpc/hash code for
this. It's just a minor bug in taking that code into generic, not really
a big deal, right? Or are you saying powerpc devs or code could be doing
something better to play nicer with the rest of the archs?

Honestly trying to improve things here, and encouraged by x86 and ARM
looking to move over to a saner page walk cache tracking design and
sharing more code with powerpc/radix. I would help with reviewing
things or writing code or porting powerpc bits if I can.

Thanks,
Nick
