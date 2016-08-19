Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4516B0069
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 11:55:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so34096590lfe.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:55:50 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id v20si6871389wju.50.2016.08.19.08.55.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 08:55:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 85CB79953F
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 15:55:48 +0000 (UTC)
Date: Fri, 19 Aug 2016 16:55:46 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
Message-ID: <20160819155546.GQ8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <20160819131200.kyqmfcabttkjvhe2@redhat.com>
 <20160819145359.GO8119@techsingularity.net>
 <20160819153259.nszkbsk7dnfzfv5i@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160819153259.nszkbsk7dnfzfv5i@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2016 at 05:32:59PM +0200, Andrea Arcangeli wrote:
> On Fri, Aug 19, 2016 at 03:53:59PM +0100, Mel Gorman wrote:
> > Compaction is not the same as LRU management.
> 
> Sure but compaction is invoked by reclaim and if reclaim is node-wide,
> it makes more sense if compaction would be node-wide as well.
> 

It might be desirable but it's not necessarily effective.  Reclaim/compaction
was always, at best, a heuristic that replaced lumpy-reclaim.

> Otherwise what you compact? Just the higher zone, or all of them?
> 

Right now, all of them taking into account whether the compaction is likely
to succeed.

> > That is not guaranteed. At the time of migration, it is unknown if the
> > original allocation had addressing limitations or not. I did not audit
> > the address-limited allocations to see if any of them allow migration.
> > 
> > The filesystems would be the ones that need careful auditing. There are
> > some places that add lowmem pages to the LRU but far less obvious if any
> > of them would successfully migrate.
> 
> True but that's a tradeoff. This whole patchset is about optimizing
> the common case of allocations from the highest possible
> classzone_idx, as if a system has no older hardware, the lowmem
> classzone_idx allocations practically never happens.
> 

I'll have to take your word for it. It still is the case that the highest
zone is preferred for allocations but the timing will be different due to
when reclaim is triggered and what is reclaimed.

As long as it is reclaiming, the page age will still be priority. Unless the
LRU is almost perfectly interleaves between zones, the effect of node-reclaim
will be that there is a likelihood that reclaim/compaction will succeed
for at least one zone with similar success rates to zone reclaim.

> If that tradeoff is valid, retaining migrability of memory allocated
> not with the highest classzone_idx is an optimization that goes in the
> opposite direction.
> 
> Retaining such "optimization" means increasing the likelihood of
> succeeding high order allocations from lower zones yes, but it screws
> with the main concept of:
> 
>      reclaim node wide at high order -> failure to allocate -> compaction node wide
> 
> So if the tradeoff works for reclaim_node I don't see why we should
> "optimize" for the opposite case in compaction.
> 
> > That is likely true as long as migration is always towards higher address.
> 
> Well with a node-wide LRU we got rid of any "towards higher address"

The allocation preferences of the zonelist continue to favour higher
zones. If anything, there is a stronger preference because zone-lru used
the fair-zone allocation policy to interleave pages between zones to avoid
page age inversion problems with smaller sized high zones.

> bias. So why to worry about these concepts for high order allocations
> provided by compaction, if order 0 allocations provided purely by
> shrink_node won't care at all about such a concept any longer?
> 

At worst, reclaim/compaction is slighly weakened. As the reclaim is in
LRU order, reclaim/compaction will still make progress for at least one
zone at a time.

> It sounds backwards to even worry about "towards higher address" in
> compaction which is only relevant to provide high order allocations,
> when the zero order 4kb allocations will not care at all to go
> "towards higher address" anymore.
> 

Towards higher addresses in compaction is an implementation detail when
it's not going across zones. Specifically, it was the easiest way to avoid
using the same pageblocks as both migration sources and targets.

> > An audit of all additions to the LRU that are address-limited allocations
> > is required to determine if any of those pages can migrate.
> 
> Agreed.
> 
> Either that or the pageblock needs to be marked with the classzone_idx
> that it can tolerate. And a per-allocation-classzone highpfn,lowpfn
> markers needs to be added, instead of being global.
> 

That would be somewhat severe. A single address-restricted allocation
would prevent any pages in that pageblock migrating out of the zone.
The classzone_idx could only be cleared when the entire pageblock was freed.

> > I'm not sure I understand. The zone allocation preference has the same
> > meaning as it always had.
> 
> What I mean is zonelist is like:
> 
> =n
> 
> 	[ node0->zone0, node0->zone1, node1->zone0, node1->zone1 ]
> 
> or:
> 
> =z
> 
> 	[ node0->zone0, node1->zone0, node0->zone1, node1->zone1 ]
> 
> So why to call in order (first case above):
> 
> 1  shrink_node(node0->zone0->node, allocation_classzone_idx /* to limit */)
> 2  shrink_node(node0->zone1->node, allocation_classzone_idx /* to limit */)
> 3  shrink_node(node1->zone0->node, allocation_classzone_idx /* to limit */)
> 4  shrink_node(node1->zone1->node, allocation_classzone_idx /* to limit */)
> 

For =n in the direct reclaim case, there is a check to see if the pgdat
has changed when reclaming in zonelist order. 1 will call shrink_node, 2
will skip, 3 will shrink_node, 4 will skip.

For =z, shrink_node will be called multiple times but it's also not the
default case. If it is a problem then direct reclaim would need to use a
bitmask of nodes shrunk during a zonelist traversal.

> It's possible I missed something in the code, perhaps I misunderstand
> how shrink_node is invoked through the zonelist.
> 

Look for this bit

                        /*
                         * Shrink each node in the zonelist once. If the
                         * zonelist is ordered by zone (not the default)
                         * then a node may be shrunk multiple times but in that
                         * case the user prefers lower zones being preserved.
                         */
                        if (zone->zone_pgdat == last_pgdat)
                                continue;

> > The zonelist ordering is still required to satisfy address-limited allocation
> > requests. If it wasn't, free pages could be managed on a per-node basis.
> 
> But you pass the node, not the zone, to the shrink_node function, the
> whole point I'm making is that the "address-limiting" is provided by
> the classzone_idx alone with your change, not by the zonelist anymore.
> 
> static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> 
> There's no zone pointer in "scan control". There's the reclaim_idx
> (aka classzone_idx, would have been more clear to call it
> classzone_idx).
> 

There is no need for a zone pointer as the reclaim_idx is sufficient. In
the node-ordered case, the node will be shrunk once based on the
restrictions of reclaim_idx.

> > Compacting across zones was/is a problem regardless of how the LRU is
> > managed.
> 
> It is a separate problem to make it work, but wanting to making
> compaction work node-wide is very much a side effect of shrink_node
> not going serially into zones but going node-wide at all times. Hence
> it doesn't make sense anymore to only compact a single zone before
> invoking shrink_node again.

Calling shrink_node will increase the chance of a single zone successfully
compacting. It's not guaranteed to succeed but then again, it never was.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
