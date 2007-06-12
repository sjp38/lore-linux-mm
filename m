Date: Tue, 12 Jun 2007 10:32:34 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070612153234.GI11115@waste.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <20070608145011.GE11115@waste.org> <20070612094359.GA5803@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612094359.GA5803@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 12, 2007 at 06:43:59PM +0900, Paul Mundt wrote:
> On Fri, Jun 08, 2007 at 09:50:11AM -0500, Matt Mackall wrote:
> > SLOB's big scalability problem at this point is number of CPUs.
> > Throwing some fine-grained locking at it or the like may be able to
> > help with that too.
> > 
> > Why would you even want to bother making it scale that large? For
> > starters, it's less affected by things like dcache fragmentation. The
> > majority of pages pinned by long-lived dcache entries will still be
> > available to other allocations.
> > 
> > Haven't given any thought to NUMA yet though..
> > 
> This is what I've hacked together and tested with my small nodes. It's
> not terribly intelligent, and it pushes off most of the logic to the page
> allocator. Obviously it's not terribly scalable, and I haven't tested it
> with page migration, either. Still, it works for me with my simple tmpfs
> + mpol policy tests.
> 
> Tested on a UP + SPARSEMEM (static, not extreme) + NUMA (2 nodes) + SLOB
> configuration.
> 
> Flame away!

For starters, it's not against the current SLOB, which no longer has
the bigblock list.

> -void *__kmalloc(size_t size, gfp_t gfp)
> +static void *__kmalloc_alloc(size_t size, gfp_t gfp, int node)

That's a ridiculous name. So, uh.. more underbars!

Though really, I think you can just name it __kmalloc_node?

> +		if (node == -1)
> +			pages = alloc_pages(flags, get_order(c->size));
> +		else
> +			pages = alloc_pages_node(node, flags,
> +						get_order(c->size));

This fragment appears a few times. Looks like it ought to get its own
function. And that function can reduce to a trivial inline in the
!NUMA case.

> +void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
> +{
> +	return __kmem_cache_alloc(c, flags, node);
> +}

If we make the underlying functions all take a node, this stuff all
gets simpler.

>  static void slob_timer_cbk(void)

This is gone in the latest SLOB too.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
