Date: Mon, 18 Feb 2002 18:35:42 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16czvB-0000z2-00@starship.berlin>
Message-ID: <Pine.LNX.4.33.0202181822470.24671-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On Tue, 19 Feb 2002, Daniel Phillips wrote:
> >
> > Which implies that the swapper needs to look up all mm's some way anyway,
>
> Ick.  With rmap this is straightforward, but without, what?

It is not at ALL straightforward with rmap either.

Remember: one of the big original _points_ of the pmd sharing was to avoid
having to do the rmap overhead for shared page tables. The fact that it
works without rmap too was just a nice bonus, and makes apples-to-apples
comparisons possible.

So if you do the rmap overhead even when sharing, you're toast. No more
shared pmd's.

> Maybe page tables should be unshared on swapin/out after all, only on arches
> that need special tlb treatment, or until we have rmap.

There is no "or until we have rmap". It doesn't help. All the same issues
hold - if you have to invalidate multiple mm's, you have to find them all.
That's the same whether you have rmap or not, and is a fundamental issue
with sharing pmd's.

Dang, I should have noticed before this.

Note that "swapin" is certainly not the problem - we don't need to swap
the thing into all mm's at the same time, so if a unshare happens just
before/after the swapin and the unshared process doesn't get the thing,
we're still perfectly fine.

In fact, swapin is not even a spacial case. It's just the same as any
other page fault - we can continue to share page tables over "read-only"
page faults, and even that is _purely_ an optimization (yeah, it needs
some trivial "cmpxchg()" magic on the pmd to work, but it has no TLB
invalidation issues or anything really complex like that).

The only problem is swapout. And "swapout()" is always a problem, in fact.
It's always been special, because it is quite fundamentally the only VM
operation that ever is "nonlocal". We've had tons of races with swapout
over time, it's always been the nastiest VM operation by _far_ when it
comes to page table coherency.

We can, of course, introduce a "pmd-rmap" thing, with a pointer to a
circular list of all mm's using that pmd inside the "struct page *" of the
pmd. Right now the rmap patches just make the pointer point directly to
the one exclusive mm that holds the pmd, right?

(This could be a good "gradual introduction to some of the rmap data
structures" thing too).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
