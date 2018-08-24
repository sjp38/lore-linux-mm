Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAB776B2EC6
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:47:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h17-v6so849219itj.0
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:47:42 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j69-v6si648186itb.57.2018.08.24.01.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 Aug 2018 01:47:41 -0700 (PDT)
Date: Fri, 24 Aug 2018 10:47:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180824084717.GK24124@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823133958.GA1496@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, Aug 23, 2018 at 02:39:59PM +0100, Will Deacon wrote:
> The only problem with this approach is that we've lost track of the granule
> size by the point we get to the tlb_flush(), so we can't adjust the stride of
> the TLB invalidations for huge mappings, which actually works nicely in the
> synchronous case (e.g. we perform a single invalidation for a 2MB mapping,
> rather than iterating over it at a 4k granule).
> 
> One thing we could do is switch to synchronous mode if we detect a change in
> granule (i.e. treat it like a batch failure).

We could use tlb_start_vma() to track that, I think. Shouldn't be too
hard.
