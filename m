Message-Id: <20070806102922.907530000@chello.nl>
Date: Mon, 06 Aug 2007 12:29:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/10] foundations for reserve-based allocation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

In the interrest of getting swap over network working and posting in smaller
series, here is the first series.

This series lays the foundations needed to do reserve based allocation.
Traditionally we have used mempools (and others like radix_tree_preload) to
handle the problem.

However this does not fit the network stack. It is built around variable
sized allocations using kmalloc().

This calls for a different approach.

We want a guarantee for N bytes from kmalloc(), this translates to a demand
on the slab allocator for 2*N+m (due to the power-of-two nature of kmalloc 
slabs), where m is the meta-data needed by the allocator itself.

The slab allocator then puts a demand of P pages on the page allocator.

So we need functions translating our demanded kmalloc space into a page
reserve limit, and then need to provide a reserve of pages.

And we need to ensure that once we hit the reserve, the slab allocator honours
the reserve's access. That is, a regular allocation may not get objects from
a slab allocated from the reserves.

There is already a page reserve, but it does not fully comply with our needs.
For example, it does not guarantee a strict level (due to the relative nature
of ALLOC_HIGH and ALLOC_HARDER). Hence we augment this reserve with a strict
limit.

Furthermore a new __GFP flag is added to allow easy access to the reserves
along-side the existing PF_MEMALLOC.

Users of this infrastructure will need to do the necessary bean counting to
ensure they stay within the requested limits.

NOTE: I have currently only implemented SLUB support, I'm still hoping
at least one of the others will die soon and save me the trouble.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
