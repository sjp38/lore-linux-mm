From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] SLOB memory ordering issue
Date: Thu, 16 Oct 2008 05:50:04 +1100
References: <200810160334.13082.nickpiggin@yahoo.com.au> <200810160506.14261.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151116430.3288@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0810151116430.3288@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810160550.04321.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 05:26, Linus Torvalds wrote:
> On Thu, 16 Oct 2008, Nick Piggin wrote:
> > Who was it that said memory ordering was self-evident?
>
> Nobody has _ever_ said that memory ordering is self-evident. Quite the
> reverse.

Heh, no that was a dig at someone who actually did say that the
other day. Not you or Matt.


> What we've said is that it's not a ctor issue. This has nothing
> what-so-ever to do with ctors, and everything to do with the fact that
> lockless is hard.
>
> And the general rule is: to find a page (or any other data structures) on
> another CPU, you need to insert it into the right data structures. And
> that insertion event needs to either be locked, or it needs to be ordered.

Sure. And "ordered" doesn't come by itself, but specifically with preceeding
stores that initialise the object.


> But notice that it's the _insertion_ event. Not the ctor. Not the
> allocator. It's the person _doing_ the allocation that needs to order
> things.
>
> See?

I see it as a joint effort between the code initialising the object, and
the code making it visible. But whatever. Whether or not we agree on the
exact obviousness or whatever, I don't want to argue. I think the solution
is agreed more or less "very unlikely to be bugs, and anyway the only way
to fix them is to document it and read code".


> And no, I didn't look at your exact case. But for pages in page tables,
> we'd need to have the right smp_wmb() at the "set_pte[_at]()" stage,
> either inside that macro or in the caller.

The example was actually talking about _page table pages_ in page tables.


> We used to only care about the page _contents_ (because the only unlocked
> access was the one that was done by hardware), but now that we do unlocked
> lookups in software too, we need to make sure the "struct page" itself is
> also valid.

I added those. Actually we _also_ need them for lockless hardware and
software walks, and not just for struct page, but also page table page
contents (which is what some architectures initialise with ctor).

Because otherwise you can insert your page table page, only to have that
store pass an earlier store to invalidate one of its ptes, and boom!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
