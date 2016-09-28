Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5EAC28025A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 12:37:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so46317651wmc.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:37:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ka4si9443619wjb.274.2016.09.28.09.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 09:37:41 -0700 (PDT)
Date: Wed, 28 Sep 2016 12:37:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Regression in mobility grouping?
Message-ID: <20160928163735.GB24966@cmpxchg.org>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160928102609.GA3840@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928102609.GA3840@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Mel,

On Wed, Sep 28, 2016 at 11:26:09AM +0100, Mel Gorman wrote:
> On Tue, Sep 27, 2016 at 09:41:48PM -0400, Johannes Weiner wrote:
> > Hi guys,
> > 
> > we noticed what looks like a regression in page mobility grouping
> > during an upgrade from 3.10 to 4.0. Identical machines, workloads, and
> > uptime, but /proc/pagetypeinfo on 3.10 looks like this:
> > 
> > Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate 
> > Node 1, zone   Normal          815          433        31518            2            0 
> > 
> > and on 4.0 like this:
> > 
> > Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate 
> > Node 1, zone   Normal         3880         3530        25356            2            0            0 
> > 
> 
> Unmovable pageblocks is not necessarily related to the number of
> unmovable pages in the system although it is obviously a concern.
> Basically there are two usual approaches to investigating this -- close
> attention to the extfrag tracepoint and analysing high-order allocation
> failures.
> 
> It's drastic, but when migration grouping was first implemented it was
> necessary to use a variation of PAGE_OWNER to walk the movable pageblocks
> identifying unmovable allocations in there. I also used to have a
> debugging patch that would print out the owner of all pages that failed
> to migrate within an unmovable block. Unfortunately I don't have these
> patches any more and they wouldn't apply anyway but it'd be easier to
> implement today than it was 7-8 years ago.

I've stared at the extfrag tracepoint for a while, and there really is
a high rate of block conversion going on, even after some uptime. But
it's not entirely obvious why. You'd think with large parts of memory
already in unmovable blocks - and we know them to be sparse based on
consumer breakdown in /proc/meminfo - there should be enough existing
blocks to choose from.

The PAGE_OWNER part of /proc/pagetypeinfo should be a good start for
seeing how efficiently we're packing by type. Thanks, I'll check that.

> > 4.0 is either polluting pageblocks more aggressively at allocation, or
> > is not able to make pageblocks movable again when the reclaimable and
> > unmovable allocations are released. Invoking compaction manually
> > (/proc/sys/vm/compact_memory) is not bringing them back, either.
> > 
> > The problem we are debugging is that these machines have a very high
> > rate of order-3 allocations (fdtable during fork, network rx), and
> > after the upgrade allocstalls have increased dramatically. I'm not
> > entirely sure this is the same issue, since even order-0 allocations
> > are struggling, but the mobility grouping in itself looks problematic.
> > 
> 
> Network RX is likely to be atomic allocations. Another potentially place
> to focus on is the use of HighAtomic pageblocks and either increasing
> them in size or protecting them more aggressively.

That's a good point in general for these machines and their workloads,
since we push them pretty hard with a combination of high memory
utilization and heavy network traffic with large packets sizes.

But note that MIGRATE_HIGHATOMIC was introduced only after the first
bad kernel.

> > I'm still going through the changes relevant to mobility grouping in
> > that timeframe, but if this rings a bell for anyone, it would help. I
> > hate blaming random patches, but these caught my eye:
> > 
> > 9c0415e mm: more aggressive page stealing for UNMOVABLE allocations
> > 3a1086f mm: always steal split buddies in fallback allocations
> > 99592d5 mm: when stealing freepages, also take pages created by splitting buddy page
> > 
> > The changelog states that by aggressively stealing split buddy pages
> > during a fallback allocation we avoid subsequent stealing. But since
> > there are generally more movable/reclaimable pages available, and so
> > less falling back and stealing freepages on behalf of movable, won't
> > this mean that we could expect exactly that result - growing numbers
> > of unmovable blocks, while rarely stealing them back in movable alloc
> > fallbacks? And the expansion of !MOVABLE blocks would over time make
> > compaction less and less effective too, seeing as it doesn't consider
> > anything !MOVABLE suitable migration targets?
> > 
> 
> It's a solid theory. There has been a lot of activity to weaken fragmentation
> avoidance protection to reduce latency. Unfortunately external fragmentation
> continues to be one of those topics that is very difficult to precisely
> define because it's a matter of definition whether it's important or
> not.

While I generally agree that it's a matter of degree, and a trade-off
between cost and accuracy, what we're observing here is a continued
deterioration of mobility grouping accuracy with uptime, to the point
of over half of memory being in unmovable/reclaimable blocks when the
majority of memory is movable allocations.

The consequences of that are devastating, because actually unmovable
allocations will be grouped less and less efficiently, and that in
turn affects the cost and effectiveness of every compaction run.

> Another avenue worth considering is that compaction used to scan unmovable
> pageblocks and migrate movable pages out of there but that was weakened
> over time trying to allocate THP pages from direct allocation context
> quickly enough. I'm not exactly sure what we do there at the moment and
> whether kcompactd cleans unmovable pageblocks or not. It takes time but
> it also reduces unmovable pageblock steals over time (or at least it did
> a few years ago when I last investigated this in depth).

I don't believe it does. There is a migrate_async_suitable() check
that skips over everything that isn't MOVABLE, but in spite of the
name this check is done for all compaction modes, see:

 isolate_freepages()
  suitable_migration_target()
   migrate_async_suitable()

That's why not even /proc/sys/vm/compact_memory would be able to
defragment these blocks right now.

But the more I think about this issue, the more I think compaction is
the wrong place to address this. Inefficiently packed unmovable blocks
will be less compactable, regardless of how many times the compaction
scanner looks at them. Compaction might be able to get a few chunks in
between actually unmovable pages, but the maximum size of these chunks
will be severely limited, and they won't be able to coalesce with the
surrounding chunks. Compaction cannot really fix up what mobility
grouping lets slide, so reallocating effort from allocation grouping
to compaction scanning will always be a net loss at higher uptimes.

> Unfortunately I do not have any suggestions offhand on how it could be
> easily improved without going back to first principals and identifying
> what pages end up in awkward positions, why and whether the cost of
> "cleaning" unmovable pageblocks during compaction for a high-order
> allocation is justified or not.

I don't think this particular case is a trade-off situation. From 3.10
to current kernels, we have seen both allocation latencies and overall
throughput (number of DB reqs handled per second) get worse.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
