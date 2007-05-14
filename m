Date: Mon, 14 May 2007 15:01:44 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
Message-ID: <20070514200144.GI11115@waste.org>
References: <20070514131904.440041502@chello.nl> <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com> <20070514161224.GC11115@waste.org> <20070514124451.c868c4c0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070514124451.c868c4c0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, May 14, 2007 at 12:44:51PM -0700, Andrew Morton wrote:
> On Mon, 14 May 2007 11:12:24 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > If I understand this correctly:
> > 
> > privileged thread                      unprivileged greedy process
> > kmem_cache_alloc(...)
> >    adds new slab page from lowmem pool
> > do_io()
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        ...
> >                                           eats it all
> > kmem_cache_alloc(...) -> ENOMEM
> >    who ate my donuts?!
> 
> Yes, that's my understanding also.
> 
> I can see why it's a problem in theory, but I don't think Peter has yet
> revealed to us why it's a problem in practice.  I got all excited when
> Christoph asked "I am not sure what the point of all of this is.", but
> Peter cunningly avoided answering that ;)
> 
> What observed problem is being fixed here?

(From my recollection of looking at this problem a few years ago:)

There are various critical I/O paths that aren't protected by
mempools that need to dip into reserves when we approach OOM.

If, say, we need some number of SKBs in the critical I/O cleaning path
while something else is cheerfully sending non-I/O data, that second
stream can eat the SKBs that the first had budgeted for in its
reserve.

I think the simplest thing to do is to make everyone either fail or
sleep if they're not marked critical and a global memory crisis flag
is set.

To make this not impact the fast path, we could pull some trick like
swapping out and hiding all the real slab caches when turning the crisis
flag on.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
