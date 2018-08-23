Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC7B6B2887
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 02:16:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v195-v6so2376648pgb.0
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:16:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u68-v6sor1171778pfi.99.2018.08.22.23.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 23:16:01 -0700 (PDT)
Date: Thu, 23 Aug 2018 16:15:52 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823161552.6e3114c0@roar.ozlabs.ibm.com>
In-Reply-To: <457fb409b4dcd213e2f162792e79e31c09cd55a4.camel@kernel.crashing.org>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	<776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	<CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
	<457fb409b4dcd213e2f162792e79e31c09cd55a4.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, 23 Aug 2018 15:21:30 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Wed, 2018-08-22 at 22:11 -0700, Linus Torvalds wrote:
> > On Wed, Aug 22, 2018 at 9:54 PM Benjamin Herrenschmidt <benh@au1.ibm.com> wrote:  
> > > 
> > > 
> > > So we do need a different flush instruction for the page tables vs. the
> > > normal TLB pages.  
> > 
> > Right. ARM wants it too. x86 is odd in that a regular "invlpg" already
> > invalidates all the internal tlb cache nodes.
> > 
> > So the "new world order" is exactly that patch that PeterZ sent you, that adds a
> > 
> > +       unsigned int            freed_tables : 1;
> >   
> 
>  .../...
> 
> > So instead, when you get to the actual "tlb_flush(tlb)", you do
> > exactly that - flush the tlb. And the mmu_gather structure shows you
> > how much you need to flush. If you see that "freed_tables" is set,
> > then you know that you need to also do the special instruction to
> > flush the inner level caches. The range continues to show the page
> > range.  
> 
> Yup. That looks like a generic version of the "need_flush_all" flag we
> have, which is fine by us.
> 
> Just don't blame powerpc for all the historical crap :-)

And yes we very much want to remove the x86 hacks from generic code and
have them use the sane powerpc/radix page walk cache flushing model.
That would indeed allow us to stop overriding those macros and start
sharing more code with other archs. We can help write or review code to
make sure bugs don't creep in when moving it to generic implementation.
It will be much more relevant to us now because radix is very similar to
x86.

The hack is not the powerpc override macros though, let's be clear
about that. Even x86 will be helped out by removing that crap because
it won't have to do a full TLB flush caused by massive TLB range if it
frees 0..small number of pages that happen to also free some page
tables.

Thanks,
Nick
