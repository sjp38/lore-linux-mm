Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B18B06B304F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:50:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w12-v6so7874414oie.12
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:50:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a125-v6si5022012oii.107.2018.08.24.08.50.03
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 08:50:03 -0700 (PDT)
Date: Fri, 24 Aug 2018 16:49:53 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180824154953.GA15226@brain-police>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <20180824083556.GI24124@hirez.programming.kicks-ass.net>
 <20180824131332.GM24142@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824131332.GM24142@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Benjamin Herrenschmidt <benh@au1.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

Hi Peter,

On Fri, Aug 24, 2018 at 03:13:32PM +0200, Peter Zijlstra wrote:
> On Fri, Aug 24, 2018 at 10:35:56AM +0200, Peter Zijlstra wrote:
> 
> > Anyway, its sorted now; although I'd like to write me a fairly big
> > comment in asm-generic/tlb.h about things, before I forget again.
> 
> How's something like so? There's a little page_size thingy in this;
> mostly because I couldn't be arsed to split it for now.
> 
> Will has opinions on the page_size thing; I'll let him explain.

They're not especially strong opinions, it's just that I don't think the
page size is necessarily the right thing to track and I'd rather remove that
altogether.

In the patches I've hacked up (I'll post shortly as an RFC), I track the
levels of page-table instead so you can relate the mmu_gather explicitly
with the page-table structure, rather than have to infer it from the page
size. For example, if an architecture could put down huge mappings at the
pte level (e.g. using a contiguous hint in the pte like we have on arm64),
then actually you want to know about the level rather than the size. You can
also track the levels using only 4 bits in the gather structure.

Finally, both approaches have a funny corner case when a VMA contains a
mixture of granule sizes. With the "page size has changed so flush
synchronously" you can theoretically end up with a lot of flushes, where
you'd have been better off just invalidating the whole mm. If you track the
levels instead and postpone a flush using the smallest level you saw, then
you're likely to hit whatever threshold you have and nuke the mm.

Will
