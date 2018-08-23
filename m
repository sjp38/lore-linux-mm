Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27B6D6B2A41
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:40:07 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m21-v6so4795219oic.7
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:40:07 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z5-v6si2159596oib.40.2018.08.23.06.40.05
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 06:40:05 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:39:59 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180823133958.GA1496@brain-police>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 10:11:41PM -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2018 at 9:54 PM Benjamin Herrenschmidt <benh@au1.ibm.com> wrote:
> >
> >
> > So we do need a different flush instruction for the page tables vs. the
> > normal TLB pages.
> 
> Right. ARM wants it too. x86 is odd in that a regular "invlpg" already
> invalidates all the internal tlb cache nodes.
> 
> So the "new world order" is exactly that patch that PeterZ sent you, that adds a
> 
> +       unsigned int            freed_tables : 1;
> 
> to the 'struct mmu_gather', and then makes all those
> pte/pmd/pud/p4d_free_tlb() functions set that bit.
> 
> So I'm referring to the email PeterZ sent you in this thread that said:
> 
>   Nick, Will is already looking at using this to remove the synchronous
>   invalidation from __p*_free_tlb() for ARM, could you have a look to see
>   if PowerPC-radix could benefit from that too?
> 
>   Basically, using a patch like the below, would give your tlb_flush()
>   information on if tables were removed or not.
> 
> then, in that model, you do *not* need to override these
> pte/pmd/pud/p4d_free_tlb() macros at all (well, you *can* if you want
> to, for doing games with the range modification, but let's sayt that
> you don't need that right now).
> 
> So instead, when you get to the actual "tlb_flush(tlb)", you do
> exactly that - flush the tlb. And the mmu_gather structure shows you
> how much you need to flush. If you see that "freed_tables" is set,
> then you know that you need to also do the special instruction to
> flush the inner level caches. The range continues to show the page
> range.

The only problem with this approach is that we've lost track of the granule
size by the point we get to the tlb_flush(), so we can't adjust the stride of
the TLB invalidations for huge mappings, which actually works nicely in the
synchronous case (e.g. we perform a single invalidation for a 2MB mapping,
rather than iterating over it at a 4k granule).

One thing we could do is switch to synchronous mode if we detect a change in
granule (i.e. treat it like a batch failure).

Will
