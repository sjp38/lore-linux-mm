Date: Fri, 8 Jun 2007 12:25:05 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070608032505.GA13227@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 07, 2007 at 07:47:09PM -0700, Christoph Lameter wrote:
> On Thu, 7 Jun 2007, Andrew Morton wrote:
> 
> > Well I took silence as assent.
> 
> Well, grudgingly. How far are we willing to go to support these asymmetric 
> setups? The NUMA code initially was designed for mostly symmetric systems 
> with roughly the same amount of memory on each node. The farther we go 
> from this the more options we will have to add special casing to deal with 
> these imbalances.
> 
Well, this doesn't all have to be dynamic either. I opted for the
mpolinit= approach first so we wouldn't make the accounting for the
common case heavier, but certainly having it dynamic is less hassle. The
asymmetric case will likely be the common case for embedded, but it's
obviously possible to try to work that in to SLOB or something similar,
if making SLUB or SLAB lighterweight and more tunable for these cases
ends up being a real barrier.

On the other hand, as we start having machines with multiple gigs of RAM
that are stashed in node 0 (with many smaller memories in other nodes),
SLOB isn't going to be a long-term option either.

The pgdat is already special cased for things like flatmem and memory
hotplug, throwing in something similar to scheduler domains in the pgdat
for node behavioural hints might be the least intrusive (and could be
ifdefed out for symmetric nodes).

> With memoryless nodes we already have one issue that will ripple through 
> the kernel likely requiring numerous modifications and special casing. 
> Then we now have the ZONE_DMA issues reording the zonelists. Now we will 
> support systems with 1MB size nodes? We will need to modify the slab 
> allocators to only allocate on special processors?
> 
Unfortunately CONFIG_NUMA deals with all of the problems that embedded
with multiple memories has (albeit perhaps somewhat heavy-handed), so
extending this seems to be a far more productive approach than
reinventing things. If we have to do this through a special allocator for
the asymmetric node case, so be it, but I don't expect the problem to go
away.

Even with just the mempolicy changes for dynamic interleave, a 128k or
512k node is already usable (despite slab and slub both chewing through a
good chunk of it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
