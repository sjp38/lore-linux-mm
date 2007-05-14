Date: Mon, 14 May 2007 10:57:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179164453.2942.26.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <20070514161224.GC11115@waste.org>  <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
 <1179164453.2942.26.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> On Mon, 2007-05-14 at 09:29 -0700, Christoph Lameter wrote:
> > On Mon, 14 May 2007, Matt Mackall wrote:
> > 
> > > privileged thread                      unprivileged greedy process
> > > kmem_cache_alloc(...)
> > >    adds new slab page from lowmem pool
> > 
> > Yes but it returns an object for the privileged thread. Is that not 
> > enough?
> 
> No, because we reserved memory for n objects, and like matt illustrates
> most of those that will be eaten by the greedy process.
> We could reserve 1 page per object but that rather bloats the reserve.

1 slab per object not one page. But yes thats some bloat.

You can pull the big switch (only on a SLUB slab I fear) to switch 
off the fast path. Do SetSlabDebug() when allocating a precious 
allocation that should not be gobbled up by lower level processes. 
Then you can do whatever you want in the __slab_alloc debug section and we 
wont care because its not the hot path.

SLAB is a bit different. There we already have issues with the fast path 
due to the attempt to handle numa policies at the object level. SLUB fixes 
that issue (if we can avoid you hot path patch). It intentionally does 
defer all special object handling to the slab level to increase NUMA 
performance. If you do the same to SLAB then you will get the NUMA 
troubles propagated to the SMP and UP level.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
