Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B49AF6B2EB3
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:36:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r206-v6so6574789iod.2
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:36:26 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q186-v6si623248ita.48.2018.08.24.01.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 Aug 2018 01:36:25 -0700 (PDT)
Date: Fri, 24 Aug 2018 10:35:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180824083556.GI24124@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, Aug 23, 2018 at 02:54:20PM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2018-08-22 at 20:59 -0700, Linus Torvalds wrote:

> > The problem is that x86 _used_ to do this all correctly long long ago.
> > 
> > And then we switched over to the "generic" table flushing (which
> > harkens back to the powerpc code).
> 
> Yes, we wrote it the RCU stuff to solve the races with SW walking,
> which is completely orthogonal with HW walking & TLB content. We didn't
> do the move to generic code though ;-)
> 
> > Which actually turned out to be not generic at all, and did not flush
> > the internal pages like x86 used to (back when x86 just used
> > tlb_remove_page for everything).
> 
> Well, having RCU do the flushing is rather generic, it makes sense
> whenever there's somebody doing a SW walk *and* you don't have IPIs to
> synchronize your flushes (ie, anybody with HW TLB invalidation
> broadcast basically, so ARM and us).

Right, so (many many years ago) I moved it over to generic code because
Sparc-hash wanted fast_gup and I figured having multiple copies of this
stuff wasn't ideal.

Then ARM came along and used it because it does the invalidate
broadcast.

And then when we switched x86 over last year or so; because paravirt; I
had long since forgotten all details and completely overlooked this.

Worse; somewhere along the line we tried to get s390 on this and they
ran into the exact problem being fixed now. That _should_ have been a
big clue, but somehow I never got around to thinking about it properly
and they went back to a private copy of all this.

So double fail on me I suppose :-/

Anyway, its sorted now; although I'd like to write me a fairly big
comment in asm-generic/tlb.h about things, before I forget again.
