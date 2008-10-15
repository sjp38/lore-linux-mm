From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] SLOB memory ordering issue
Date: Thu, 16 Oct 2008 04:45:28 +1100
References: <200810160334.13082.nickpiggin@yahoo.com.au> <200810160410.49894.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810160445.28781.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 04:33, Linus Torvalds wrote:
> On Thu, 16 Oct 2008, Nick Piggin wrote:
> > Now they allocate these guys, take a lock, then insert them into the
> > page tables. The lock is only an acquire barrier, so it can leak past
> > stores.
>
> I think that Matt's point was that the code is buggy regardless of any
> ctor or not.
>
> If you make an allocation visible to other CPU's, you would need to make
> sure that allocation is stable with a smp_wmb() before you update the
> pointer to that allocation.

What do you mean by the allocation is stable? Let's just talk in loads and
stores and order. You need to make sure previous stores to initialise the
object become visible before subsequent store to make the object visible.
No questions about that (I think that's what you meant by make the alloc
stable).

1. However, if the object is already fully initialised at the point the caller
gets it out of the allocator, then the caller doesn't need to make any
stores to initialise it obviously.

2. I think it could be easy to assume that the allocated object that was
initialised with a ctor for us already will have its initializing stores
ordered when we get it from slab.

So in my page table almost-example, by combining 1 and 2, one might think
it is OK to leave out those smp_wmb()s. And it would be valid code if all
those assumptions _were_ true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
