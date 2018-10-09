Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC8C6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:51:51 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d1-v6so3036893qkb.11
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:51:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x28-v6si8882139qtm.5.2018.10.09.15.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:51:50 -0700 (PDT)
Date: Tue, 9 Oct 2018 18:51:47 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181009225147.GD9307@redhat.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <alpine.DEB.2.21.1810091424170.57306@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810091424170.57306@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Oct 09, 2018 at 03:17:30PM -0700, David Rientjes wrote:
> causes workloads to severely regress both in fault and access latency when 
> we know that direct reclaim is unlikely to make direct compaction free an 
> entire pageblock.  It's more likely than not that the reclaim was 
> pointless and the allocation will still fail.

How do you know that? If all RAM is full of filesystem cache, but it's
not heavily fragmented by slab or other unmovable objects, compaction
will succeed every single time after reclaim frees 2M of cache like
it's asked to do.

reclaim succeeds every time, compaction then succeeds every time.

Not doing reclaim after COMPACT_SKIPPED is returned simply makes
compaction unable to compact memory once all nodes are filled by
filesystem cache.

Certainly it's better not to invoke reclaim at all if __GFP_THISNODE
is set, than swapping out heavy over the local node. Doing so however
has the drawback of reducing the direct compaction effectiveness. I
don't think it's true that reclaim is generally "pointless", it's just
that invoking any reclaim backfired so bad if __GFP_THISNODE was set,
than anything else (including weakining compaction effectiveness) was
better.

> If memory compaction were patched such that it can report that it could 
> successfully free a page of the specified order if there were free pages 
> at the end of the zone it could migrate to, reclaim might be helpful.  But 
> with the current implementation, I don't think that is reliably possible.  
> These free pages could easily be skipped over by the migration scanner 
> because of the presence of slab pages, for example, and unavailable to the 
> freeing scanner.

Yes there's one case where reclaim is "pointless", but it happens once
and then COMPACT_DEFERRED is returned and __GFP_NORETRY will skip
reclaim then.

So you're right when we hit fragmentation there's one and only one
"pointless" reclaim invocation. And immediately after we also
exponentially backoff on the compaction invocations with the
compaction deferred logic.

We could try optimize away such "pointless" reclaim event for sure,
but it's probably an optimization that may just get lost in the noise
and may not be measurable, because it only happens once when the first
full fragmentation is encountered.

> I really think that for this patch to be merged over my proposed change 
> that it needs to be clearly demonstrated that reclaim was successful in 
> that it freed memory that was subsequently available to the compaction 
> freeing scanner and that enabled entire pageblocks to become free.  That, 
> in my experience, will very very seldom be successful because of internal 
> slab fragmentation, compaction_alloc() cannot soak up pages from the 
> reclaimed memory, and potentially thrash the zone completely pointlessly.  
> The last point is the problem being reported here, but the other two are 
> as legitimate.

I think the demonstration can already be inferred, because if hit full
memory fragmentation after every reclaim, __GFP_NORETRY would have
solved the "pathological THP allocation behavior" without requiring
your change to __GFP_NORETRY that makes it behave like
__GFP_COMPACT_ONLY for order == HPAGE_PMD_ORDER.

Anyway you can add a few statistic counters and verify in more
accurate way how often a COMPACT_SKIPPED + reclaim cycle is followed
by a COMPACT_DEFERRED.

> I'd appreciate if Andrea can test this patch, have a rebuttal that we 
> should still remove __GFP_THISNODE because we don't care about locality as 
> much as forming a hugepage, we can make that change, and then merge this 
> instead of causing such massive fault and access latencies.

I can certainly test, but from source review I'm already convinced
it'll solve fine the "pathological THP allocation behavior", no
argument about that. It's certainly better and more correct your patch
than the current upstream (no security issues with lack of permissions
for __GFP_THISNODE anymore either).

I expect your patch will run 100% equivalent to __GFP_COMPACT_ONLY
alternative I posted, for our testcase that hit into the "pathological
THP allocation behavior".

Your patch encodes __GFP_COMPACT_ONLY into the __GFP_NORETRY semantics
and hardcodes the __GFP_COMPACT_ONLY for all orders = HPAGE_PMD_SIZE
no matter which is the caller.

As opposed I let the caller choose and left __GFP_NORETRY semantics
alone and orthogonal to the __GFP_COMPACT_ONLY semantics. I think
letting the caller decide instead of hardcoding it for order 9 is
better, because __GFP_COMPACT_ONLY made sense to be set only if
__GFP_THISNODE was also set by the caller.

If a driver does an order 9 allocation with __GFP_THISNODE not set,
your patch will prevent it to allocate remote THP if all remote nodes
are full of cache (which is a reasonable common assumption as more THP
are allocated over time eating in all free memory). My patch didn't
alter that so I tend to prefer the __GFP_COMPACT_ONLY than the
hardcoding __GFP_COMPACT_ONLY for all order 9 allocations regardless
if __GFP_THISNODE is set or not.

Last but not the last, from another point of view, I thought calling
remote compaction was a feature especially for MADV_HUGEPAGE. However
if avoiding the 40% increase latency for MADV_HUGEPAGE was the primary
motivation for __GFP_THISNODE, not sure how we can say that such an
high allocation latency is only a concern for order 9 allocations and
all other costly_order allocations (potentially with orders even
higher than HPAGE_PMD_ORDER in fact) are ok to keep calling remote
compaction and incur in the 40% higher latency.

Thanks,
Andrea
