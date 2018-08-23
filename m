Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B91F6B281A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:33:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d40-v6so1940610pla.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:33:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n62-v6sor987591pgn.355.2018.08.22.21.33.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 21:33:57 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:33:49 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823143349.65cb0da0@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 20:59:46 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Aug 22, 2018 at 8:45 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > powerpc/radix has no such issue, it already does this tracking.  
> 
> Yeah, I now realize that this was why you wanted to add that hacky
> thing to the generic code, so that you can add the tlb_flush_pgtable()
> call.
> 
> I thought it was because powerpc had some special flush instruction
> for it, and the regular tlb flush didn't do it. But no.

powerpc/radix does have a special instruction for it, that is why I
posted the patch :)

> It was because
> the regular code had lost the tlb flush _entirely_, because powerpc
> didn't want it.

I think that was long before I started looking at the code.
powerpc/hash hardware has no idea about the page tables so yeah they
don't need it.

> 
> > We were discussing this a couple of months ago, I wasn't aware of ARM's
> > issue but I suggested x86 could go the same way as powerpc.  
> 
> The problem is that x86 _used_ to do this all correctly long long ago.
> 
> And then we switched over to the "generic" table flushing (which
> harkens back to the powerpc code).
> 
> Which actually turned out to be not generic at all, and did not flush
> the internal pages like x86 used to (back when x86 just used
> tlb_remove_page for everything).
> 
> So as a result, x86 had unintentionally lost the TLB flush we used to
> have, because tlb_remove_table() had lost the tlb flushing because of
> a powerpc quirk.
> 
> You then added it back as a hacky per-architecture hook (apparently
> having realized that you never did it at all), which didn't fix the

I think it was quite well understood and fixed here, a145abf12c9 but
again that was before I really started looking at it.

The hooks I added recently are for a different reason, and it's
actaully the opposite problem -- to work around the hacky generic code
that x86 foisted on other archs.

> unintentional lack of flushing on x86.
> 
> So now we're going to do it right.  No more "oh, powerpc didn't need
> to flush because the hash tables weren't in the tlb at all" thing in
> the generic code that then others need to work around.

I don't really understand what the issue you have with powerpc here.
powerpc hash has the page table flushing accessors which are just
no-ops, it's the generic code that fails to call them properly. Surely
there was no powerpc patch that removed those calls from generic code?

powerpc/radix yes it does some arch specific things to do its page walk
cache flushing, but it is a better design than the hacks x86 has in
generic code, surely. I thought you basically agreed and thought x86 /
generic code could move to that kind of model.

Thanks,
Nick
