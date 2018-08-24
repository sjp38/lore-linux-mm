Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1C56B30B5
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 13:26:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r20-v6so6109470pgv.20
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:26:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12-v6sor2258009pgk.331.2018.08.24.10.26.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 10:26:53 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180824084717.GK24124@hirez.programming.kicks-ass.net>
Date: Fri, 24 Aug 2018 10:26:50 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

at 1:47 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Aug 23, 2018 at 02:39:59PM +0100, Will Deacon wrote:
>> The only problem with this approach is that we've lost track of the =
granule
>> size by the point we get to the tlb_flush(), so we can't adjust the =
stride of
>> the TLB invalidations for huge mappings, which actually works nicely =
in the
>> synchronous case (e.g. we perform a single invalidation for a 2MB =
mapping,
>> rather than iterating over it at a 4k granule).
>>=20
>> One thing we could do is switch to synchronous mode if we detect a =
change in
>> granule (i.e. treat it like a batch failure).
>=20
> We could use tlb_start_vma() to track that, I think. Shouldn't be too
> hard.

Somewhat unrelated, but I use this opportunity that TLB got your =
attention
for something that bothers me for some time. clear_fixmap(), which is =
used
in various places (e.g., text_poke()), ends up in doing only a local TLB
flush (in __set_pte_vaddr()).

Is that sufficient?
