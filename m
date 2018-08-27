Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9A716B3F57
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:11:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n23-v6so14332671qkn.19
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:11:25 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id g29-v6si3841383qtm.361.2018.08.27.01.11.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Aug 2018 01:11:25 -0700 (PDT)
Message-ID: <4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 27 Aug 2018 18:09:50 +1000
In-Reply-To: <20180827180458.4af9b2ac@roar.ozlabs.ibm.com>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 2018-08-27 at 18:04 +1000, Nicholas Piggin wrote:
> > Yes.. I see that. tlb_remove_check_page_size_change() really is a rather
> > ugly thing, it can cause loads of TLB flushes. Do you really _have_ to
> > do that? The way ARM and x86 work is that using INVLPG in a 4K stride is
> > still correct for huge pages, inefficient maybe, but so is flushing
> > every other page because 'sparse' transparant-huge-pages.
> 
> It could do that. It requires a tlbie that matches the page size,
> so it means 3 sizes. I think possibly even that would be better
> than current code, but we could do better if we had a few specific
> fields in there.

More tlbies ? With the cost of the broadasts on the fabric ? I don't
think so.. or I'm not understanding your point...

Sadly our architecture requires a precise match between the page size
specified in the tlbie instruction and the entry in the TLB or it won't
be flushed.

Ben.
