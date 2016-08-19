Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1A96B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 10:54:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so19640185wme.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 07:54:03 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id v7si6581925wjm.289.2016.08.19.07.54.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 07:54:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8F20D99586
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 14:54:01 +0000 (UTC)
Date: Fri, 19 Aug 2016 15:53:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
Message-ID: <20160819145359.GO8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <20160819131200.kyqmfcabttkjvhe2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160819131200.kyqmfcabttkjvhe2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2016 at 03:12:00PM +0200, Andrea Arcangeli wrote:
> Hello Mel,
> 
> On Fri, Jul 08, 2016 at 10:34:36AM +0100, Mel Gorman wrote:
> > Minor changes this time
> > 
> > Changelog since v8
> > This is the latest version of a series that moves LRUs from the zones to
> 
> I'm afraid this is a bit incomplete...
> 

Compaction is not the same as LRU management.

> I had troubles in rebasing the compaction-enabled zone_reclaim feature
> (now node_reclaim) to the node model.

I'm not familiar with this although from the name, I can guess what it's
doing -- migrating pages from lowmem instead of reclaiming.

> That is because compaction is
> still zone based, and so I would need to do a loop of compaction calls
> (for each zone in the node), but what's the point? Movable memory can
> always go anywhere, can't it?

That is not guaranteed. At the time of migration, it is unknown if the
original allocation had addressing limitations or not. I did not audit
the address-limited allocations to see if any of them allow migration.

The filesystems would be the ones that need careful auditing. There are
some places that add lowmem pages to the LRU but far less obvious if any
of them would successfully migrate.

I'm not familiar with the specifics of the series you're working on but
as compaction was zone-based, you'd have to loop across the zones whether
the LRU is node or zone based. Even if cross-zone compaction was allowed,
it does not make a difference how the LRUs are managed.

Historically, the possibility that pages being compacted were address-limited
was the first reason didn't compact across zones. The other was that it
could introduce page aging problems. For example, migrating DMA32 to a
small NORMAL potentially allowed the page to be reclaimed prematurely by
reclaim. That is less of a concern with node-lru.

> So it would be better to compact across
> the whole node without care of the zone boundaries.

That is likely true as long as migration is always towards higher address.

> Then if the
> classzone_idx passed to compaction is not for the highest classzone,
> it'll do zone_reclaim and focus itself on the lower zones (but it can
> still cross the zone boundaries among those lower zones).
> 
> No matter how I tweak my code it doesn't make much sense to do a
> manual loop and leave compaction unable to cross zone boundaries. Is
> anybody working to complete this work to make compaction work on node
> basis instead of zone basis?

Not that I'm aware of but compaction across zones is not directly related
to LRU management.

> Or am I missing something for why
> compaction scan "lowpfn, highpfn" starting positions cannot possibly
> cross zone boundaries?
> 

An audit of all additions to the LRU that are address-limited allocations
is required to determine if any of those pages can migrate.

> I'm also uncertain what's the meaning now of zonelist_order=z (default
> setting) considering it'll always behave like zone_order=n
> anyway...

I'm not sure I understand. The zone allocation preference has the same
meaning as it always had.

>  On the same lines, I'm also uncertain of the meaning of the
> zonelist in the first place and why it's not a "nodelist +
> classzone_idx". Why is there still a zonelist_order=z default setting

On 64-bit, the default order is NODE. Are you using 32-bit NUMA systems?

> and a zonelist_order option in the first place, and a zonelist instead
> of a nodelist?
> 

The zonelist ordering is still required to satisfy address-limited allocation
requests. If it wasn't, free pages could be managed on a per-node basis.

> I use zonelist_order=n on my NUMA systems and I always liked the LRU
> to be per-node (despite it uses more CPU when you allocate from a
> lower classzone as you need to skip the pages of the higher zones not
> contained in the classzone_idx). So to be clear I'm not against this
> work (I tend to believe there are more pros than cons), but to port
> some code to the node model in the right way, I'd need to do too much
> work myself on the compaction side.
> 

Compaction working across zones would be nice to have unconditionally.
It's ortogonal to whether LRUs are managed per-node or not.

> Also note, the main security left that allows this change to work
> stable is in the lowmem reserve ratio feature in the page allocator
> that prevents lower classzones to be completely filled by non movable
> allocations from higher classzones (i.e. pagetables). As there's no
> priority anymore to start shrinking from the higher zone of the
> classzone_idx of the allocation (especially effective logic if using
> zonelist_order=z which happens to be the default, even though I almost
> always use zonelist_order=n which in fact already behaved much closer
> to the new behavior). The removal of the bias against the highest zone
> to me is the biggest cons in terms of stability in the corner cases,
> overall but I believe the security of the lowmem reserve ratio should
> suffice.
> 

It's expected that the lowmem reserve ratio will suffice with the corner
case of lowmem-restricted allocations potentially having to sacn more.

> I also expect this work to make negligible difference for those
> systems where DMA32 and DMA zones don't exist or are tiny, as the
> node:zone relation is practically already 1:1 there. I believe this
> actually will help more in systems where the DMA32 zone is relevant if
> compared to the total memory size (as long as there are not too many
> DMA32 allocations from pci32 devices, and the zone exists just in
> case, for an lowmem allocation once in a while). So this isn't a
> change for the long run, it'll be more noticeable on low end systems
> or highmem 32bit systems, and it's going to be a noop if you've got a
> terabytes of RAM (perhaps some pointer dereference is avoided, but
> that difference should get not measurable).
> 

32-bit systems with large highmem zones are expected to be a rarity. It
was a different story 10 years ago. A system with terabytes of RAM is
not going to be 32-bit.

> On a side note the compaction enabled node_reclaim that makes
> node_reclaim fully effective with THP on, works better with
> zonelist_order=z too, so it should work even better with the node
> model that practically makes zonelist_order=z impossible to achieve
> any longer (which also shows it was a bad default and it was good idea
> to manually set it to =n :). It's just the compaction zone model that
> forces me to write a for-each-zone loop that isn't ideal and it would
> defeat the purpose of the node model as far as compaction is concerned.
> 

Compacting across zones was/is a problem regardless of how the LRU is
managed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
