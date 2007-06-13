Date: Tue, 12 Jun 2007 22:16:21 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070613031621.GM11115@waste.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <20070608145011.GE11115@waste.org> <20070612094359.GA5803@linux-sh.org> <20070612153234.GI11115@waste.org> <20070613025337.GA15009@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070613025337.GA15009@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 11:53:37AM +0900, Paul Mundt wrote:
> On Tue, Jun 12, 2007 at 10:32:34AM -0500, Matt Mackall wrote:
> > On Tue, Jun 12, 2007 at 06:43:59PM +0900, Paul Mundt wrote:
> > > On Fri, Jun 08, 2007 at 09:50:11AM -0500, Matt Mackall wrote:
> > > > Haven't given any thought to NUMA yet though..
> > > > 
> > > This is what I've hacked together and tested with my small nodes. It's
> > > not terribly intelligent, and it pushes off most of the logic to the page
> > > allocator. Obviously it's not terribly scalable, and I haven't tested it
> > > with page migration, either. Still, it works for me with my simple tmpfs
> > > + mpol policy tests.
> > > 
> > > Tested on a UP + SPARSEMEM (static, not extreme) + NUMA (2 nodes) + SLOB
> > > configuration.
> > > 
> > > Flame away!
> > 
> > For starters, it's not against the current SLOB, which no longer has
> > the bigblock list.
> > 
> Sorry about that, seems I used the wrong tree.
> 
> > > -void *__kmalloc(size_t size, gfp_t gfp)
> > > +static void *__kmalloc_alloc(size_t size, gfp_t gfp, int node)
> > 
> > That's a ridiculous name. So, uh.. more underbars!
> > 
> Agreed, though I couldn't think of a better one.
> 
> > Though really, I think you can just name it __kmalloc_node?
> > 
> No, kmalloc_node and __kmalloc_node are both required by CONFIG_NUMA,
> otherwise that would have been the logical choice.

What I'm suggesting is: _always_ have __kmalloc_node and have
__kmalloc be a trivial inline that calls it. Together with cleaning up
the following piece, it may compile down to what we currently have on UP/SMP:

> > > +		if (node == -1)
> > > +			pages = alloc_pages(flags, get_order(c->size));
> > > +		else
> > > +			pages = alloc_pages_node(node, flags,
> > > +						get_order(c->size));
> > 
> > This fragment appears a few times. Looks like it ought to get its own
> > function. And that function can reduce to a trivial inline in the
> > !NUMA case.
> > 
> Ok.
> 
> > > +void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
> > > +{
> > > +	return __kmem_cache_alloc(c, flags, node);
> > > +}
> > 
> > If we make the underlying functions all take a node, this stuff all
> > gets simpler.
> > 
> Could you elaborate on that?

See above. Just make the non-node versions wrappers around the node
versions everywhere.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
