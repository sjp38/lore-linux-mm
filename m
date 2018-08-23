Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 945536B2848
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:11:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k143-v6so860917ite.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:11:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2-v6sor1137743iom.215.2018.08.22.22.11.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 22:11:52 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com> <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
In-Reply-To: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 22:11:41 -0700
Message-ID: <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>
Cc: Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 9:54 PM Benjamin Herrenschmidt <benh@au1.ibm.com> wrote:
>
>
> So we do need a different flush instruction for the page tables vs. the
> normal TLB pages.

Right. ARM wants it too. x86 is odd in that a regular "invlpg" already
invalidates all the internal tlb cache nodes.

So the "new world order" is exactly that patch that PeterZ sent you, that adds a

+       unsigned int            freed_tables : 1;

to the 'struct mmu_gather', and then makes all those
pte/pmd/pud/p4d_free_tlb() functions set that bit.

So I'm referring to the email PeterZ sent you in this thread that said:

  Nick, Will is already looking at using this to remove the synchronous
  invalidation from __p*_free_tlb() for ARM, could you have a look to see
  if PowerPC-radix could benefit from that too?

  Basically, using a patch like the below, would give your tlb_flush()
  information on if tables were removed or not.

then, in that model, you do *not* need to override these
pte/pmd/pud/p4d_free_tlb() macros at all (well, you *can* if you want
to, for doing games with the range modification, but let's sayt that
you don't need that right now).

So instead, when you get to the actual "tlb_flush(tlb)", you do
exactly that - flush the tlb. And the mmu_gather structure shows you
how much you need to flush. If you see that "freed_tables" is set,
then you know that you need to also do the special instruction to
flush the inner level caches. The range continues to show the page
range.

           Linus
