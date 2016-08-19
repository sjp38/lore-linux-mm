Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id C298F6B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 11:33:05 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id x37so101706286ybh.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:33:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p135si4883227qka.197.2016.08.19.08.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 08:33:04 -0700 (PDT)
Date: Fri, 19 Aug 2016 17:32:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
Message-ID: <20160819153259.nszkbsk7dnfzfv5i@redhat.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <20160819131200.kyqmfcabttkjvhe2@redhat.com>
 <20160819145359.GO8119@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160819145359.GO8119@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2016 at 03:53:59PM +0100, Mel Gorman wrote:
> Compaction is not the same as LRU management.

Sure but compaction is invoked by reclaim and if reclaim is node-wide,
it makes more sense if compaction would be node-wide as well.

Otherwise what you compact? Just the higher zone, or all of them?

> That is not guaranteed. At the time of migration, it is unknown if the
> original allocation had addressing limitations or not. I did not audit
> the address-limited allocations to see if any of them allow migration.
> 
> The filesystems would be the ones that need careful auditing. There are
> some places that add lowmem pages to the LRU but far less obvious if any
> of them would successfully migrate.

True but that's a tradeoff. This whole patchset is about optimizing
the common case of allocations from the highest possible
classzone_idx, as if a system has no older hardware, the lowmem
classzone_idx allocations practically never happens.

If that tradeoff is valid, retaining migrability of memory allocated
not with the highest classzone_idx is an optimization that goes in the
opposite direction.

Retaining such "optimization" means increasing the likelihood of
succeeding high order allocations from lower zones yes, but it screws
with the main concept of:

     reclaim node wide at high order -> failure to allocate -> compaction node wide

So if the tradeoff works for reclaim_node I don't see why we should
"optimize" for the opposite case in compaction.

> That is likely true as long as migration is always towards higher address.

Well with a node-wide LRU we got rid of any "towards higher address"
bias. So why to worry about these concepts for high order allocations
provided by compaction, if order 0 allocations provided purely by
shrink_node won't care at all about such a concept any longer?

It sounds backwards to even worry about "towards higher address" in
compaction which is only relevant to provide high order allocations,
when the zero order 4kb allocations will not care at all to go
"towards higher address" anymore.

> An audit of all additions to the LRU that are address-limited allocations
> is required to determine if any of those pages can migrate.

Agreed.

Either that or the pageblock needs to be marked with the classzone_idx
that it can tolerate. And a per-allocation-classzone highpfn,lowpfn
markers needs to be added, instead of being global.

> I'm not sure I understand. The zone allocation preference has the same
> meaning as it always had.

What I mean is zonelist is like:

=n

	[ node0->zone0, node0->zone1, node1->zone0, node1->zone1 ]

or:

=z

	[ node0->zone0, node1->zone0, node0->zone1, node1->zone1 ]

So why to call in order (first case above):

1  shrink_node(node0->zone0->node, allocation_classzone_idx /* to limit */)
2  shrink_node(node0->zone1->node, allocation_classzone_idx /* to limit */)
3  shrink_node(node1->zone0->node, allocation_classzone_idx /* to limit */)
4  shrink_node(node1->zone1->node, allocation_classzone_idx /* to limit */)

When in fact 1 and 2 are doing the exact same thing? And 3, 4 are
doing the same thing as well? All it matters is the classzone_idx, the
zonelist looks irrelevant and an unnecessary repetition.

It's possible I missed something in the code, perhaps I misunderstand
how shrink_node is invoked through the zonelist.

This zonelist vs nodelist issue however is orthogonal to the
per-zone vs per-node compaction issue discussed earlier.

> On 64-bit, the default order is NODE. Are you using 32-bit NUMA systems?

Ah that changed in 3.16 but my grub cmdlines didn't change since
then... Good that the default is =n for 64bit indeed.

> The zonelist ordering is still required to satisfy address-limited allocation
> requests. If it wasn't, free pages could be managed on a per-node basis.

But you pass the node, not the zone, to the shrink_node function, the
whole point I'm making is that the "address-limiting" is provided by
the classzone_idx alone with your change, not by the zonelist anymore.

static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)

There's no zone pointer in "scan control". There's the reclaim_idx
(aka classzone_idx, would have been more clear to call it
classzone_idx).

Then when isolating you do:

		if (page_zonenum(page) > sc->reclaim_idx) {

Confirming the limiting factor comes from reclaim_idx
(i.e. allocation_classzone_idx).

Again I may be missing something in the code...

> Compacting across zones was/is a problem regardless of how the LRU is
> managed.

It is a separate problem to make it work, but wanting to making
compaction work node-wide is very much a side effect of shrink_node
not going serially into zones but going node-wide at all times. Hence
it doesn't make sense anymore to only compact a single zone before
invoking shrink_node again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
