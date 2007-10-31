From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Date: Wed, 31 Oct 2007 21:46:02 +1100
References: <20071030160401.296770000@chello.nl> <200710311437.28630.nickpiggin@yahoo.com.au> <1193827358.27652.126.camel@twins>
In-Reply-To: <1193827358.27652.126.camel@twins>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200710312146.03351.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 21:42, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 14:37 +1100, Nick Piggin wrote:
> > On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > > contexts that are entitled to it.
> > >
> > > Care is taken to only touch the SLUB slow path.
> > >
> > > This is done to ensure reserve pages don't leak out and get consumed.
> >
> > I think this is generally a good idea (to prevent slab allocators
> > from stealing reserve). However I naively think the implementation
> > is a bit overengineered and thus has a few holes.
> >
> > Humour me, what was the problem with failing the slab allocation
> > (actually, not fail but just call into the page allocator to do
> > correct waiting  / reclaim) in the slowpath if the process fails the
> > watermark checks?
>
> Ah, we actually need slabs below the watermarks.

Right, I'd still allow those guys to allocate slabs. Provided they
have the right allocation context, right?


> Its just that once I 
> allocated those slabs using __GFP_MEMALLOC/PF_MEMALLOC I don't want
> allocation contexts that do not have rights to those pages to walk off
> with objects.

And I'd prevent these ones from doing so.

Without keeping track of "reserve" pages, which doesn't feel
too clean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
