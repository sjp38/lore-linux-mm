From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] SLOB memory ordering issue
Date: Thu, 16 Oct 2008 05:06:14 +1100
References: <200810160334.13082.nickpiggin@yahoo.com.au> <1224089658.3316.218.camel@calx> <200810160410.49894.nickpiggin@yahoo.com.au>
In-Reply-To: <200810160410.49894.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810160506.14261.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh@veritas.com>
Cc: torvalds@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 04:10, Nick Piggin wrote:
> On Thursday 16 October 2008 03:54, Matt Mackall wrote:
> > On Thu, 2008-10-16 at 03:34 +1100, Nick Piggin wrote:
> > > I think I see a possible memory ordering problem with SLOB:
> > > In slab caches with constructors, the constructor is run
> > > before returning the object to caller, with no memory barrier
> > > afterwards.
> > >
> > > Now there is nothing that indicates the _exact_ behaviour
> > > required here. Is it at all reasonable to expect ->ctor() to
> > > be visible to all CPUs and not just the allocating CPU?
> >
> > Do you have a failure scenario in mind?
> >
> > First, it's a categorical mistake for another CPU to be looking at the
> > contents of an object unless it knows that it's in an allocated state.
> >
> > For another CPU to receive that knowledge (by reading a causally-valid
> > pointer to it in memory), a memory barrier has to occur, no?
>
> No.
>
> For (slightly bad) example. Some architectures have a ctor for their
> page table page slabs. Not a bad thing to do.
>
> Now they allocate these guys, take a lock, then insert them into the
> page tables. The lock is only an acquire barrier, so it can leak past
> stores.
>
> The read side is all lockless and in some cases even done by hardware.
>
> Now in _practice_, this is not a problem because some architectures
> don't have ctors, and I spotted the issue and put proper barriers in
> there. But it was a known fact that ctors were always used, and if I
> had assumed ctors were barriers so didn't need the wmb, then there
> would be a bug.
>
> Especially the fact that a lock doesn't order the stores makes me
> worried that a lockless read-side algorithm might have a bug here.
> Fortunately, most of them use RCU and probably use rcu_assign_pointer
> even if they do have ctors. But I can't be sure...

OK, now I have something that'll blow your fuckin mind.

anon_vma_cachep.

P0
do_anonymous_page()
 anon_vma_prepare()
  ctor(anon_vma)
  [sets vma->anon_vma = anon_vma]

P1
do_anonymous_page()
 anon_vma_prepare()
  [sees P0 already allocated it]
 lru_cache_add(page)
  [flushes page to lru]
 page_add_anon_rmap (increments mapcount)
  page_set_anon_rmap
   [sets page->anon_vma = anon_vma]

P2
find page from lru
page_referenced()
 page_referenced_anon()
  page_lock_anon_vma()
   [loads anon_vma from page->anon_vma]
   spin_lock(&anon_vma->lock)


Who was it that said memory ordering was self-evident?

For everyone else:

P1 sees P0's store to vma->anon_vma, then P2 sees P1's store
to page->anon_vma (among others), but P2 does not see P0's ctor
store to initialise anon_vma->lock.

And there seems like another bug there too, but just a plain control
race rather than strictly[*] a data race, P0 is executing list_add_tail
of vma to anon_vma->head at some point here too, so even assuming
we're running on a machine with transitive store ordering, then the
above race can't hit, then P2 subsequently wants to run a
list_for_each_entry over anon_vma->head while P0 is in the process of
modifying it.

Am I the one who's bamboozled, or can anyone confirm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
