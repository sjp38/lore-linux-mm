Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91FC46B42F6
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 19:15:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y54-v6so648849qta.8
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:15:03 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id e186-v6si554422qkf.291.2018.08.27.16.15.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Aug 2018 16:15:02 -0700 (PDT)
Message-ID: <30def1abb307dc4a2d232e69717d6755a1369492.camel@kernel.crashing.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 28 Aug 2018 08:13:45 +1000
In-Reply-To: <20180827190213.6c7d85ca@roar.ozlabs.ibm.com>
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
	 <20180827190213.6c7d85ca@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 2018-08-27 at 19:02 +1000, Nicholas Piggin wrote:
> > More tlbies ? With the cost of the broadasts on the fabric ? I don't
> > think so.. or I'm not understanding your point...
> 
> More tlbies are no good, but there will be some places where it works
> out much better (and fewer tlbies). Worst possible case for current code
> is a big unmap with lots of scattered page sizes. We _should_ get that
> with just a single PID flush at the end, but what we will get today is
> a bunch of PID and VA flushes.
> 
> I don't propose doing that though, I'd rather be explicit about
> tracking start and end range of each page size. Still not "optimal"
> but neither is existing single range for sparse mappings... anyway it
> will need to be profiled, but my point is we don't really fit exactly
> what x86/arm want.

If we have an arch specific part, we could just remember up to N
"large" pages there without actually flushing, and if that overflows,
upgrade to a full flush.

Cheers,
Ben.
