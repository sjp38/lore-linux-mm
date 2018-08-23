Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4832E6B2857
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:20:45 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k9-v6so3389697iob.16
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:20:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor1224835iob.83.2018.08.22.22.20.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 22:20:44 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com> <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
In-Reply-To: <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 22:20:32 -0700
Message-ID: <CA+55aFw3edpf6JBn-pbqYhtvMPZJ7VmJTkGfO_9=uQMO=dV32g@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>
Cc: Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 10:11 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So instead, when you get to the actual "tlb_flush(tlb)", you do
> exactly that - flush the tlb. And the mmu_gather structure shows you
> how much you need to flush. If you see that "freed_tables" is set,
> then you know that you need to also do the special instruction to
> flush the inner level caches. The range continues to show the page
> range.

Note that this obviously works fine for a hashed table model too - you
just ignore the "freed_tables" bit entirely and continue to do
whatever you always did.

And we can ignore it on x86 too, because we just see the range, and we
invalidate the range, and that will always invalidate the mid-level
caching too.

So the new bit is literally for arm and powerpc-radix (and maybe
s390), but we want to make the actual VM interface truly generic and
not have one set of code with five different behaviors (which we
_currently_ kind of have with the whole in addition to all the
HAVE_RCU_TABLE_FREE etc config options that modify how the code works.

It would be good to also cut down on the millions of functions that
each architecture can override, because Christ, it got very confusing
at times to follow just how the code flowed from generic code to
architecture-specific macros back to generic code and then
arch-specific inline helper functions.

It's a maze of underscores and "page" vs "table", and "flush" vs "remove" etc.

But that "it would be good to really make everybody to use as much of
the generic code as possible" and everybody have the same pattern,
that's a future thing. But the whole "let's just add that
"freed_tables" thing would be part of trying to get people to use the
same overall pattern, even if some architectures might not care about
that detail.

              Linus
