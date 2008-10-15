From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] SLOB memory ordering issue
Date: Thu, 16 Oct 2008 04:10:49 +1100
References: <200810160334.13082.nickpiggin@yahoo.com.au> <1224089658.3316.218.camel@calx>
In-Reply-To: <1224089658.3316.218.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810160410.49894.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: torvalds@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 03:54, Matt Mackall wrote:
> On Thu, 2008-10-16 at 03:34 +1100, Nick Piggin wrote:
> > I think I see a possible memory ordering problem with SLOB:
> > In slab caches with constructors, the constructor is run
> > before returning the object to caller, with no memory barrier
> > afterwards.
> >
> > Now there is nothing that indicates the _exact_ behaviour
> > required here. Is it at all reasonable to expect ->ctor() to
> > be visible to all CPUs and not just the allocating CPU?
>
> Do you have a failure scenario in mind?
>
> First, it's a categorical mistake for another CPU to be looking at the
> contents of an object unless it knows that it's in an allocated state.
>
> For another CPU to receive that knowledge (by reading a causally-valid
> pointer to it in memory), a memory barrier has to occur, no?

No.

For (slightly bad) example. Some architectures have a ctor for their
page table page slabs. Not a bad thing to do.

Now they allocate these guys, take a lock, then insert them into the
page tables. The lock is only an acquire barrier, so it can leak past
stores.

The read side is all lockless and in some cases even done by hardware.

Now in _practice_, this is not a problem because some architectures
don't have ctors, and I spotted the issue and put proper barriers in
there. But it was a known fact that ctors were always used, and if I
had assumed ctors were barriers so didn't need the wmb, then there
would be a bug.

Especially the fact that a lock doesn't order the stores makes me
worried that a lockless read-side algorithm might have a bug here.
Fortunately, most of them use RCU and probably use rcu_assign_pointer
even if they do have ctors. But I can't be sure...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
