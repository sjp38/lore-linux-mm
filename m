Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6368F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:12:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n128so84982991ith.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:12:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w84si4700743itf.94.2016.08.19.06.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 06:12:03 -0700 (PDT)
Date: Fri, 19 Aug 2016 15:12:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
Message-ID: <20160819131200.kyqmfcabttkjvhe2@redhat.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

Hello Mel,

On Fri, Jul 08, 2016 at 10:34:36AM +0100, Mel Gorman wrote:
> Minor changes this time
> 
> Changelog since v8
> This is the latest version of a series that moves LRUs from the zones to

I'm afraid this is a bit incomplete...

I had troubles in rebasing the compaction-enabled zone_reclaim feature
(now node_reclaim) to the node model. That is because compaction is
still zone based, and so I would need to do a loop of compaction calls
(for each zone in the node), but what's the point? Movable memory can
always go anywhere, can't it? So it would be better to compact across
the whole node without care of the zone boundaries. Then if the
classzone_idx passed to compaction is not for the highest classzone,
it'll do zone_reclaim and focus itself on the lower zones (but it can
still cross the zone boundaries among those lower zones).

No matter how I tweak my code it doesn't make much sense to do a
manual loop and leave compaction unable to cross zone boundaries. Is
anybody working to complete this work to make compaction work on node
basis instead of zone basis? Or am I missing something for why
compaction scan "lowpfn, highpfn" starting positions cannot possibly
cross zone boundaries?

I'm also uncertain what's the meaning now of zonelist_order=z (default
setting) considering it'll always behave like zone_order=n
anyway... On the same lines, I'm also uncertain of the meaning of the
zonelist in the first place and why it's not a "nodelist +
classzone_idx". Why is there still a zonelist_order=z default setting
and a zonelist_order option in the first place, and a zonelist instead
of a nodelist?

I use zonelist_order=n on my NUMA systems and I always liked the LRU
to be per-node (despite it uses more CPU when you allocate from a
lower classzone as you need to skip the pages of the higher zones not
contained in the classzone_idx). So to be clear I'm not against this
work (I tend to believe there are more pros than cons), but to port
some code to the node model in the right way, I'd need to do too much
work myself on the compaction side.

Also note, the main security left that allows this change to work
stable is in the lowmem reserve ratio feature in the page allocator
that prevents lower classzones to be completely filled by non movable
allocations from higher classzones (i.e. pagetables). As there's no
priority anymore to start shrinking from the higher zone of the
classzone_idx of the allocation (especially effective logic if using
zonelist_order=z which happens to be the default, even though I almost
always use zonelist_order=n which in fact already behaved much closer
to the new behavior). The removal of the bias against the highest zone
to me is the biggest cons in terms of stability in the corner cases,
overall but I believe the security of the lowmem reserve ratio should
suffice.

I also expect this work to make negligible difference for those
systems where DMA32 and DMA zones don't exist or are tiny, as the
node:zone relation is practically already 1:1 there. I believe this
actually will help more in systems where the DMA32 zone is relevant if
compared to the total memory size (as long as there are not too many
DMA32 allocations from pci32 devices, and the zone exists just in
case, for an lowmem allocation once in a while). So this isn't a
change for the long run, it'll be more noticeable on low end systems
or highmem 32bit systems, and it's going to be a noop if you've got a
terabytes of RAM (perhaps some pointer dereference is avoided, but
that difference should get not measurable).

On a side note the compaction enabled node_reclaim that makes
node_reclaim fully effective with THP on, works better with
zonelist_order=z too, so it should work even better with the node
model that practically makes zonelist_order=z impossible to achieve
any longer (which also shows it was a bad default and it was good idea
to manually set it to =n :). It's just the compaction zone model that
forces me to write a for-each-zone loop that isn't ideal and it would
defeat the purpose of the node model as far as compaction is concerned.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
