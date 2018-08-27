Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA966B40F0
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 10:29:57 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p5-v6so11868734pfh.11
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:29:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10-v6sor3778565pgf.430.2018.08.27.07.29.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 07:29:56 -0700 (PDT)
Date: Tue, 28 Aug 2018 00:29:47 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180828002947.2bdea9b8@roar.ozlabs.ibm.com>
In-Reply-To: <405ba257e730d4f0ad9007490e7ac47cc343c720.camel@surriel.com>
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
	<405ba257e730d4f0ad9007490e7ac47cc343c720.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 27 Aug 2018 09:36:50 -0400
Rik van Riel <riel@surriel.com> wrote:

> On Mon, 2018-08-27 at 18:04 +1000, Nicholas Piggin wrote:
> 
> > It could do that. It requires a tlbie that matches the page size,
> > so it means 3 sizes. I think possibly even that would be better
> > than current code, but we could do better if we had a few specific
> > fields in there.  
> 
> Would it cause a noticeable overhead to keep track
> of which page sizes were removed, and to simply flush
> the whole TLB in the (unlikely?) event that multiple
> page sizes were removed in the same munmap?
> 
> Once the unmap is so large that multiple page sizes
> were covered, you may already be looking at so many
> individual flush operations that a full flush might
> be faster.

It will take some profiling and measuring. unmapping a small number of
huge pages plus a small number of surrounding small pages may not be
uncommon if THP is working well. That could become a lot more expensive.

> 
> Is there a point on PPC where simply flushing the
> whole TLB, and having other things be reloaded later,
> is faster than flushing every individual page mapping
> that got unmapped?

There is. For local TLB flushes that point is well over 100 individual
invalidates though. We're generally better off flushing all page sizes
for that case.

Thanks,
Nick
