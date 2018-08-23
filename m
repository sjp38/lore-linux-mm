Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 657E56B283E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:03:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s15-v6so3355528iob.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:03:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i67-v6sor1550071itg.120.2018.08.22.22.03.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 22:03:52 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com> <20180823143349.65cb0da0@roar.ozlabs.ibm.com>
In-Reply-To: <20180823143349.65cb0da0@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 22:03:40 -0700
Message-ID: <CA+55aFwiNaQAW=Xf9cYDAk4GKkRt=1A-Ojy0TUnVVK160ygXWw@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 9:33 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> I think it was quite well understood and fixed here, a145abf12c9 but
> again that was before I really started looking at it.

You don't understand the problem.

All the x86 people thought WE ALREADY DID THAT.

Because we had done this all correctly over a decade ago!

Nobody realized that it had been screwed up by the powerpc code, and
the commit you point to was believed to be a new *powerpc* only issue,
because the semantics on powerpc has changed because of the radix
tree.

The semantics on x86 have never changed, they've always been the same.
So why would the x86 people react to powerpc doing something that x86
had already always done.

See?

Nobody cared one whit about commit a145abf12c9, because it just
handles a new powerpc-specific case.

> I don't really understand what the issue you have with powerpc here.
> powerpc hash has the page table flushing accessors which are just
> no-ops, it's the generic code that fails to call them properly. Surely
> there was no powerpc patch that removed those calls from generic code?

Yes there was.

Look where the generic code *came* from.

It's powerpc code.

See commit 267239116987 ("mm, powerpc: move the RCU page-table freeing
into generic code").

The powerpc code was made into the generic code, because the powerpc
code had to handle all those special RCU freeing things etc that
others didn't.

It's just that when x86 was then switched over to use the "generic"
code, people didn't realize that the generic code didn't do the TLB
invalidations for page tables, because they hadn't been needed on
powerpc.

So the powerpc code that was made generic, never really was. The new
"generic" code had a powerpc-specific quirk.

That then very subtly broke x86, without the x86 people ever
realizing. Because the old simple non-RCU x86 code had never had that
issue, it just treated the leaf pages and the directory pages exactly
the same.

See?

And THAT is why I talk about the powerpc code. Because what is
"generic" code in 4.18 (and several releases before) oisn't actually
generic.

And that's basically exactly the bug that the patches from PeterZ is
fixing. Making the "tlb_remove_table()" code always flush the tlb, the
way it should have when it was made generic.

              Linus
