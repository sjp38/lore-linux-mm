Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC7EC6B3F5A
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:47:25 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b17-v6so14513558wrq.0
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 00:47:25 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 136-v6si6316307wmf.64.2018.08.27.00.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 00:47:24 -0700 (PDT)
Date: Mon, 27 Aug 2018 09:47:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180827074701.GW24124@hirez.programming.kicks-ass.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827150008.13bce08f@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 03:00:08PM +1000, Nicholas Piggin wrote:
> On Fri, 24 Aug 2018 13:39:53 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> > On Fri, Aug 24, 2018 at 01:32:14PM +0200, Peter Zijlstra wrote:

> > > Hurm.. look at commit:
> > > 
> > >   e77b0852b551 ("mm/mmu_gather: track page size with mmu gather and force flush if page size change")  
> > 
> > Ah, good, it seems that already got cleaned up a lot. But it all moved
> > into the power code.. blergh.
> 
> I lost track of what the problem is here?

Aside from the commit above being absolute crap (which did get fixed up,
luckily) I would really like to get rid of all arch specific mmu_gather.

We can have opt-in bits to the generic code, but the endless back and
forth between common and arch code is an utter pain in the arse.

And there's only like 4 architectures that still have a custom
mmu_gather:

  - sh
  - arm
  - ia64
  - s390

sh is trivial, arm seems doable, with a bit of luck we can do 'rm -rf
arch/ia64' leaving us with s390.

After that everyone uses the common code and we can clean up.

> For powerpc, tlb_start_vma is not the right API to use for this because
> it wants to deal with different page sizes within a vma.

Yes.. I see that. tlb_remove_check_page_size_change() really is a rather
ugly thing, it can cause loads of TLB flushes. Do you really _have_ to
do that? The way ARM and x86 work is that using INVLPG in a 4K stride is
still correct for huge pages, inefficient maybe, but so is flushing
every other page because 'sparse' transparant-huge-pages.
