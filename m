Date: Tue, 12 Jun 2007 22:12:10 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070613031210.GL11115@waste.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <20070608145011.GE11115@waste.org> <20070612094359.GA5803@linux-sh.org> <20070612153234.GI11115@waste.org> <466F520D.9080206@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466F520D.9080206@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 12:10:21PM +1000, Nick Piggin wrote:
> Matt Mackall wrote:
> >On Tue, Jun 12, 2007 at 06:43:59PM +0900, Paul Mundt wrote:
> >
> >>On Fri, Jun 08, 2007 at 09:50:11AM -0500, Matt Mackall wrote:
> >>
> >>>SLOB's big scalability problem at this point is number of CPUs.
> >>>Throwing some fine-grained locking at it or the like may be able to
> >>>help with that too.
> >>>
> >>>Why would you even want to bother making it scale that large? For
> >>>starters, it's less affected by things like dcache fragmentation. The
> >>>majority of pages pinned by long-lived dcache entries will still be
> >>>available to other allocations.
> >>>
> >>>Haven't given any thought to NUMA yet though..
> >>>
> >>
> >>This is what I've hacked together and tested with my small nodes. It's
> >>not terribly intelligent, and it pushes off most of the logic to the page
> >>allocator. Obviously it's not terribly scalable, and I haven't tested it
> >>with page migration, either. Still, it works for me with my simple tmpfs
> >>+ mpol policy tests.
> >>
> >>Tested on a UP + SPARSEMEM (static, not extreme) + NUMA (2 nodes) + SLOB
> >>configuration.
> >>
> >>Flame away!
> >
> >
> >For starters, it's not against the current SLOB, which no longer has
> >the bigblock list.
> >
> >
> >>-void *__kmalloc(size_t size, gfp_t gfp)
> >>+static void *__kmalloc_alloc(size_t size, gfp_t gfp, int node)
> >
> >
> >That's a ridiculous name. So, uh.. more underbars!
> >
> >Though really, I think you can just name it __kmalloc_node?
> >
> >
> >>+		if (node == -1)
> >>+			pages = alloc_pages(flags, get_order(c->size));
> >>+		else
> >>+			pages = alloc_pages_node(node, flags,
> >>+						get_order(c->size));
> >
> >
> >This fragment appears a few times. Looks like it ought to get its own
> >function. And that function can reduce to a trivial inline in the
> >!NUMA case.
> 
> BTW. what I would like to see tried initially -- which may give reasonable
> scalability and NUMAness -- is perhaps a percpu or per-node free pages
> lists. However these lists would not be exclusively per-cpu, because that
> would result in worse memory consumption (we should always try to put
> memory consumption above all else with SLOB).
>
> So each list would have its own lock and can be accessed by any CPU, but
> they would default to their own list first (or in the case of a
> kmalloc_node, they could default to some other list).
> 
> Then we'd probably like to introduce a *little* bit of slack, so that we
> will allocate a new page on our local list even if there is a small amount
> of memory free on another list. I think this might be enough to get a
> reasonable number of list-local allocations without blowing out the memory
> usage much. The slack ratio could be configurable so at one extreme we
> could always allocate from our local lists for best NUMA placement I guess.
> 
> I haven't given it a great deal of thought, so this strategy might go
> horribly wrong in some cases... but I have a feeling something reasonably
> simple like that might go a long way to improving locking scalability and
> NUMAness.

It's an interesting problem. There's a fair amount more we can do to
get performance up on SMP which should probably happen before we think
too much about NUMA.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
