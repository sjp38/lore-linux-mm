From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [git pull] more SLUB updates for 2.6.25
Date: Fri, 8 Feb 2008 19:08:55 +1100
References: <Pine.LNX.4.64.0802071755580.7473@schroedinger.engr.sgi.com> <200802081812.22513.nickpiggin@yahoo.com.au> <47AC04CD.9090407@cosmosbay.com>
In-Reply-To: <47AC04CD.9090407@cosmosbay.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200802081908.55512.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 08 February 2008 18:29, Eric Dumazet wrote:
> Nick Piggin a ecrit :
> > On Friday 08 February 2008 13:13, Christoph Lameter wrote:
> >> are available in the git repository at:
> >>
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git
> >> slub-linus
> >>
> >> (includes the cmpxchg_local fastpath since the cmpxchg_local work
> >> by Matheiu is in now, and the non atomic unlock by Nick. Verified that
> >> this is not doing any harm after some other patches had been removed.
> >
> > Ah, good. I think it is always a good thing to be able to remove atomics.
> > They place quite a bit of burden on the CPU, especially x86 where it also
> > has implicit memory ordering semantics (although x86 can speculatively
> > get around much of the problem, it's obviously worse than no restriction)
> >
> > Even if perhaps some cache coherency or timing quirk makes the non-atomic
> > version slower (all else being equal), then I'd still say that the non
> > atomic version should be preferred.
>
> What about IRQ masking then ?

I really did mean all else being equal. eg. "clear_bit" vs "__clear_bit".


> Many CPU pay high cost for cli/sti pair...

True, and many UP architectures have to implement atomic operations
with cli/sti pairs... so those are more reasons to use non-atomics.


> And SLAB/SLUB allocators, even if only used from process context, want to
> disable/re-enable interrupts...
>
> I understand kmalloc() want generic pools, but dedicated pools could avoid
> this cli/sti

Sure, I guess that would be possible. I've kind of toyed with doing
some cli/sti mitigation in the page allocator, but in that case I
found that it wasn't a win outside microbenchmarks: the cache
characteristics of the returned pages are just as important if not
more so than cli/sti costs (although that balance would change
depending on the CPU and workload I guess).

For slub yes you could do it with fewer downsides with process context
pools.

Is it possible instead for architectures where cli/sti is so expensive
to change their lowest level of irq handling to do this by setting and
clearing a soft flag somewhere? That's what I'd rather see, if possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
