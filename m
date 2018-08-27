Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E80576B3FA8
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:02:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o16-v6so10633660pgv.21
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 02:02:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11-v6sor4374843pfj.120.2018.08.27.02.02.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 02:02:23 -0700 (PDT)
Date: Mon, 27 Aug 2018 19:02:13 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180827190213.6c7d85ca@roar.ozlabs.ibm.com>
In-Reply-To: <4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
References: <20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	<776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	<CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
	<20180823133958.GA1496@brain-police>
	<20180824084717.GK24124@hirez.programming.kicks-ass.net>
	<20180824113214.GK24142@hirez.programming.kicks-ass.net>
	<20180824113953.GL24142@hirez.programming.kicks-ass.net>
	<20180827150008.13bce08f@roar.ozlabs.ibm.com>
	<20180827074701.GW24124@hirez.programming.kicks-ass.net>
	<20180827180458.4af9b2ac@roar.ozlabs.ibm.com>
	<4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 27 Aug 2018 18:09:50 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Mon, 2018-08-27 at 18:04 +1000, Nicholas Piggin wrote:
> > > Yes.. I see that. tlb_remove_check_page_size_change() really is a rather
> > > ugly thing, it can cause loads of TLB flushes. Do you really _have_ to
> > > do that? The way ARM and x86 work is that using INVLPG in a 4K stride is
> > > still correct for huge pages, inefficient maybe, but so is flushing
> > > every other page because 'sparse' transparant-huge-pages.  
> > 
> > It could do that. It requires a tlbie that matches the page size,
> > so it means 3 sizes. I think possibly even that would be better
> > than current code, but we could do better if we had a few specific
> > fields in there.  
> 
> More tlbies ? With the cost of the broadasts on the fabric ? I don't
> think so.. or I'm not understanding your point...

More tlbies are no good, but there will be some places where it works
out much better (and fewer tlbies). Worst possible case for current code
is a big unmap with lots of scattered page sizes. We _should_ get that
with just a single PID flush at the end, but what we will get today is
a bunch of PID and VA flushes.

I don't propose doing that though, I'd rather be explicit about
tracking start and end range of each page size. Still not "optimal"
but neither is existing single range for sparse mappings... anyway it
will need to be profiled, but my point is we don't really fit exactly
what x86/arm want.

Thanks,
Nick
