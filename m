Subject: Re: [PATCH 00/10] foundations for reserve-based allocation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708061052160.24256@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
	 <Pine.LNX.4.64.0708061052160.24256@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 20:33:51 +0200
Message-Id: <1186425231.11797.84.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-06 at 10:56 -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Peter Zijlstra wrote:
> 
> > We want a guarantee for N bytes from kmalloc(), this translates to a demand
> > on the slab allocator for 2*N+m (due to the power-of-two nature of kmalloc 
> > slabs), where m is the meta-data needed by the allocator itself.
> 
> The guarantee occurs in what context? Looks like its global here but 
> allocations may be restricted to a cpuset context? What happens in a 
> GFP_THISNODE allocation? Or a memory policy restricted allocations?

>From what I could understand of the low level network allocations these
try to be node affine at best and are not subject to mempolicies due to
taking place from irq context.

> > So we need functions translating our demanded kmalloc space into a page
> > reserve limit, and then need to provide a reserve of pages.
> 
> Only kmalloc? What about skb heads and such?

kmalloc is the hardest thing to get right, there are also functions to
calculate the reserves for kmem_cache like allocations, see
kmem_estimate_pages().

> > And we need to ensure that once we hit the reserve, the slab allocator honours
> > the reserve's access. That is, a regular allocation may not get objects from
> > a slab allocated from the reserves.
> 
> From a cpuset we may hit the reserves since cpuset memory is out and then 
> the rest of the system fails allocations?

No, do see patch 2/10. What we do is we fail cpuset local allocations,
_except_ PF_MEMALLOC (or __GFP_MEMALLOC). These will break out of the
mempolicy bounds before dipping into the reserves.

This has the effect that all nodes will be low before we hit the
reserves. Also, given that PF_MEMALLOC will usually use only a little
amount of memory the impact of breaking out of these bounds is quite
limited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
