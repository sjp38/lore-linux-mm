Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5B006B285B
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:22:51 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id d9-v6so1678090uaa.22
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:22:51 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id w67-v6si1654372vkf.281.2018.08.22.22.22.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Aug 2018 22:22:50 -0700 (PDT)
Message-ID: <457fb409b4dcd213e2f162792e79e31c09cd55a4.camel@kernel.crashing.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2018 15:21:30 +1000
In-Reply-To: <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	 <20180822154046.823850812@infradead.org>
	 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
	 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 2018-08-22 at 22:11 -0700, Linus Torvalds wrote:
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

 .../...

> So instead, when you get to the actual "tlb_flush(tlb)", you do
> exactly that - flush the tlb. And the mmu_gather structure shows you
> how much you need to flush. If you see that "freed_tables" is set,
> then you know that you need to also do the special instruction to
> flush the inner level caches. The range continues to show the page
> range.

Yup. That looks like a generic version of the "need_flush_all" flag we
have, which is fine by us.

Just don't blame powerpc for all the historical crap :-)

Cheers,
Ben.

> 
>            Linus
