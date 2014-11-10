Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 33C3382BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 23:06:56 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so7387855pad.11
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 20:06:55 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id ef7si15435132pac.71.2014.11.09.20.06.53
        for <linux-mm@kvack.org>;
        Sun, 09 Nov 2014 20:06:54 -0800 (PST)
Date: Mon, 10 Nov 2014 15:03:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH -mm v2 3/9] vmscan: shrink slab on memcg pressure
Message-ID: <20141110040342.GM23575@dastard>
References: <cover.1414145862.git.vdavydov@parallels.com>
 <68df6349e5cecdf8b2950e8eb2c27965163a110b.1414145863.git.vdavydov@parallels.com>
 <20141106152135.GA17628@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106152135.GA17628@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 06, 2014 at 10:21:35AM -0500, Johannes Weiner wrote:
> On Fri, Oct 24, 2014 at 02:37:34PM +0400, Vladimir Davydov wrote:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a384339bf718..2cf6b04a4e0c 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -339,6 +339,26 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> >  	return freed;
> >  }
> >  
> > +static unsigned long
> > +run_shrinker(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> > +	     unsigned long nr_pages_scanned, unsigned long lru_pages)
> > +{
> > +	unsigned long freed = 0;
> > +
> > +	if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
> > +		shrinkctl->nid = 0;
> > +		return shrink_slab_node(shrinkctl, shrinker,
> > +					nr_pages_scanned, lru_pages);
> > +	}
> > +
> > +	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
> > +		if (node_online(shrinkctl->nid))
> > +			freed += shrink_slab_node(shrinkctl, shrinker,
> > +						  nr_pages_scanned, lru_pages);
> > +	}
> > +	return freed;
> > +}
> 
> The slab shrinking logic accumulates the lru pages, as well as the
> nodes_to_scan mask, when going over the zones, only to go over the
> zones here again using the accumulated node information.  Why not just
> invoke the thing per-zone instead in the first place?

It's not iterating zones here - it's iterating nodes. This is the
external interface that other subsystems call to cause reclaim to
occur, and they can specify multiple nodes to scan at once (e.g.
drop-slab()). Hence we have to iterate....

Indeed, shrink_zones() requires this because it can be passed an
arbtrary zonelist that may span multiple nodes. Hence shrink_slab()
can be passed a shrinkctl with multiple nodes set in it's nodemask
and so, again, iteration is required.

If you want other callers from the VM that guarantee only a single
node needs to be scanned (such as __zone_reclaim()) to avoid the
zone iteration, then factor the code such that shrink_slab_node()
can be called directly by those functions.

> Kswapd already
> does that (although it could probably work with the per-zone lru_pages
> and nr_scanned deltas) and direct reclaim should as well.  It would
> simplify the existing code as well as your series a lot.
> 
> > +		/*
> > +		 * For memcg-aware shrinkers iterate over the target memcg
> > +		 * hierarchy and run the shrinker on each kmem-active memcg
> > +		 * found in the hierarchy.
> > +		 */
> > +		shrinkctl->memcg = shrinkctl->target_mem_cgroup;
> > +		do {
> > +			if (!shrinkctl->memcg ||
> > +			    memcg_kmem_is_active(shrinkctl->memcg))
> > +				freed += run_shrinker(shrinkctl, shrinker,
> >  						nr_pages_scanned, lru_pages);
> > -
> > -		}
> > +		} while ((shrinkctl->memcg =
> > +			  mem_cgroup_iter(shrinkctl->target_mem_cgroup,
> > +					  shrinkctl->memcg, NULL)) != NULL);
> 
> More symptoms of the above.  This hierarchy walk is duplicative and
> potentially quite expensive.

Same again - if the "zone" being reclaimed is controlled by a memcg
rather than a node ID, then ensure that shrink_slab_foo() can be
called directly with the correct shrinkctl configuration to avoid
unnecessary iteration.

> The reclaim code walks zonelists according to a nodemask, and within
> each zone it walks lruvecs according to the memcg hierarchy.  The
> shrinkers are wrong in making up an ad-hoc concept of NUMA nodes that
> otherwise does not exist anywhere in the VM.

Hardly. the shrinker API is an *external VM interface*, just like
memory allocation is an external interface.  Node IDs and node masks
are exactly the way memory locality is conveyed to the MM subsystem
during allocation, so reclaim interfaces should match that for
consistency. IOWs, the shrinker matches the "ad-hoc concept of NUMA
nodes" that exists everywhere *outside* the VM.

IOWs, the shrinkers have not "made up" anything - they conform to
the existing VM abstractions that everyone is used to. Yes, the
layers between the core VM LRU reclaim code and the shrinker
infrastructure could do with some improvement and refinement, but
the external interface is consistent with all the other external
locality interfaces the VM provides....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
