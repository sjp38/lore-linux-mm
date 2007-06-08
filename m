Date: Fri, 8 Jun 2007 15:27:01 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070608062701.GA15906@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com> <20070608041303.GA13603@linux-sh.org> <Pine.LNX.4.64.0706072123560.27441@schroedinger.engr.sgi.com> <20070608060508.GA13727@linux-sh.org> <Pine.LNX.4.64.0706072307010.28618@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706072307010.28618@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 07, 2007 at 11:09:48PM -0700, Christoph Lameter wrote:
> On Fri, 8 Jun 2007, Paul Mundt wrote:
> 
> > > I think we could do better by constructing a custom zonelist but that will 
> > > be even more special casing.
> > > 
> > I don't know if a custom zonelist is worth the trouble. For the common
> > asymmetric case, you could at least infer that ZONE_NORMAL is the only
> > thing populated per node (well, small nodes other than node 0). If you
> > mean just creating the zonelist from the range of allowable SLUB nodes,
> > that could work.
> 
> Well that is quit difficult because of the other constraints on the alloc. 
> The allocation must consider the cpuset context and the memory policies of 
> the task (which may need special casing already there for interleave). 
> Maybe we can determine from those restrictions a zonelist. Then we need to 
> kick out the zones belonging to the illegal nodes from that zonelist.  
> Then pass that to __alloc_pages to perform the alloc.
> 
> Looks like we are heading for a new alloc function
> 
> alloc_pages_node_not_nodes(order, gfpmask, node, forbidden-nodes)
> 
> But may be the hack of just going to node 0 on a problem is enough???

That depends on the policy, in the MPOL_BIND case we certainly don't want
to bleed out to node 0. For the general case, falling back on node 0 in
the event of a problem seems to be a reasonable compromise.

In the longer term, alloc_pages_not_nodes() may be worthwhile for the
cases where symmetric and asymmetric nodes are both present, without
wanting to put all of the pressure on node 0. This is largely why I was
leaning towards flags in the pgdat, suggesting what the node is willing
to put up with. It would be fairly trivial to construct a map of
allowable SLUB nodes and potentials for the zonelist out of that. This
still doesn't solve the problem of cpuset constraints, though.

Incidentally, the interleave map created for mempol sysinit is something
that could also be picked up by SLUB for the allowable node map (at least
as a starting point, exlucding cpuset constraints).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
