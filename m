Date: Fri, 8 Jun 2007 09:50:11 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070608145011.GE11115@waste.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070608032505.GA13227@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 08, 2007 at 12:25:05PM +0900, Paul Mundt wrote:
> On Thu, Jun 07, 2007 at 07:47:09PM -0700, Christoph Lameter wrote:
> > On Thu, 7 Jun 2007, Andrew Morton wrote:
> > 
> > > Well I took silence as assent.
> > 
> > Well, grudgingly. How far are we willing to go to support these asymmetric 
> > setups? The NUMA code initially was designed for mostly symmetric systems 
> > with roughly the same amount of memory on each node. The farther we go 
> > from this the more options we will have to add special casing to deal with 
> > these imbalances.
> > 
> Well, this doesn't all have to be dynamic either. I opted for the
> mpolinit= approach first so we wouldn't make the accounting for the
> common case heavier, but certainly having it dynamic is less hassle. The
> asymmetric case will likely be the common case for embedded, but it's
> obviously possible to try to work that in to SLOB or something similar,
> if making SLUB or SLAB lighterweight and more tunable for these cases
> ends up being a real barrier.
> 
> On the other hand, as we start having machines with multiple gigs of RAM
> that are stashed in node 0 (with many smaller memories in other nodes),
> SLOB isn't going to be a long-term option either.

SLOB in -mm should scale to this size reasonably well now, and Nick
and I have another tweak planned that should make it quite fast here.

SLOB's big scalability problem at this point is number of CPUs.
Throwing some fine-grained locking at it or the like may be able to
help with that too.

Why would you even want to bother making it scale that large? For
starters, it's less affected by things like dcache fragmentation. The
majority of pages pinned by long-lived dcache entries will still be
available to other allocations.

Haven't given any thought to NUMA yet though..

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
