Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 74B146B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 04:55:23 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so2289661pab.22
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:55:23 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id zz3si32662269pac.115.2014.05.22.01.55.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:55:22 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id x10so2283873pdj.3
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:55:22 -0700 (PDT)
Date: Thu, 22 May 2014 01:55:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: compaction is still too expensive for thp
In-Reply-To: <537DB0E5.40602@suse.cz>
Message-ID: <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <537DB0E5.40602@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Thu, 22 May 2014, Vlastimil Babka wrote:

> > With -mm, it turns out that while egregious thp fault latencies were
> > reduced, faulting 64MB of memory backed by thp on a fragmented 128GB
> > machine can result in latencies of 1-3s for the entire 64MB.  Collecting
> > compaction stats from older kernels that give more insight into
> > regressions, one such incident is as follows.
> > 
> > Baseline:
> > compact_blocks_moved 8181986
> > compact_pages_moved 6549560
> > compact_pagemigrate_failed 1612070
> > compact_stall 101959
> > compact_fail 100895
> > compact_success 1064
> > 
> > 5s later:
> > compact_blocks_moved 8182447
> > compact_pages_moved 6550286
> > compact_pagemigrate_failed 1612092
> > compact_stall 102023
> > compact_fail 100959
> > compact_success 1064
> > 
> > This represents faulting two 64MB ranges of anonymous memory.  As you can
> > see, it results in falling back to 4KB pages because all 64 faults of
> > hugepages ends up triggering compaction and failing to allocate.  Over the
> > 64 async compactions, we scan on average 7.2 pageblocks per call,
> > successfully migrate 11.3 pages per call, and fail migrating 0.34 pages
> > per call.
> > 
> > If each async compaction scans 7.2 pageblocks per call, it would have to
> > be called 9103 times to scan all memory on this 128GB machine.  We're
> > simply not scanning enough memory as a result of ISOLATE_ABORT due to
> > need_resched().
> 
> Well, the two objectives of not being expensive and at the same time scanning
> "enough memory" (which is hard to define as well) are clearly quite opposite
> :/
> 

Agreed.

> > So the net result is that -mm is much better than Linus's tree, where such
> > faulting of 64MB ranges could stall 8-9s, but we're still very expensive.
> 
> So I guess the difference here is mainly thanks to not doing sync compaction?

Not doing sync compaction for thp and caching the migration pfn for async 
so that it doesn't iterate over a ton of memory that may not be eligible 
for async compaction every time it is called.  But when we avoid sync 
compaction, we also lose deferred compaction.

> So if I understand correctly, your intention is to scan more in a single scan,

More will be scanned instead of ~7 pageblocks for every call to async 
compaction with the data that I presented but also reduce how expensive 
every pageblock scan is by avoiding needlessly migrating memory (and 
dealing with rmap locks) when it will not result in 2MB of contiguous 
memory for thp faults.

> but balance the increased latencies by introducing deferring for async
> compaction.
> 
> Offhand I can think of two issues with that.
> 
> 1) the result will be that often the latency will be low thanks to defer, but
> then there will be a huge (?) spike by scanning whole 1GB (as you suggest
> further in the mail) at once. I think that's similar to what you had now with
> the sync compaction?
> 

Not at all, with MIGRATE_SYNC_LIGHT before there is no termination other 
than an entire scan of memory so we were potentially scanning 128GB and 
failing if thp cannot be allocated.

If we are to avoid migrating memory needlessly that will not result in 
cc->order memory being allocated, then the cost should be relatively 
constant for a span of memory.  My 32GB system can iterate all memory with 
MIGRATE_ASYNC and no need_resched() aborts in ~530ms.

> 2) 1GB could have a good chance of being successful (?) so there would be no
> defer anyway.
> 

If we terminate early because order-9 is allocatable or we end up scanning 
the entire 1GB and the hugepage is allocated, then we have prevented 511 
other pagefaults in my testcase where faulting 64MB of memory with thp 
enabled can currently take 1-3s on a 128GB machine with fragmentation.  I 
think the deferral is unnecessary in such a case.

Are you suggesting we should try without the deferral first?

> > I have a few improvements in mind, but thought it would be better to
> > get feedback on it first because it's a substantial rewrite of the
> > pageblock migration:
> > 
> >   - For all async compaction, avoid migrating memory unless enough
> >     contiguous memory is migrated to allow a cc->order allocation.
> 
> Yes I suggested something like this earlier. Also in the scanner, skip to the
> next cc->order aligned block as soon as any page fails the isolation and is
> not PageBuddy.

Agreed.

> I would just dinstinguish kswapd and direct compaction, not "all async
> compaction". Or maybe kswapd could be switched to sync compaction.
> 

To generalize this, I'm thinking that it is pointless for async compaction 
to migrate memory in a contiguous span if it will not cause a cc->order 
page allocation to succeed.

> >     This
> >     would remove the COMPACT_CLUSTER_MAX restriction on pageblock
> >     compaction
> 
> Yes.
> 
> >     and keep pages on the cc->migratepages list between
> >     calls to isolate_migratepages_range().
> 
> This might not be needed. It's called within a single pageblock (except maybe
> CMA but that's quite a different thing) and I think we can ignore order >
> pageblock_nr_order here.
> 

Ok, I guess pageblocks within a zone are always pageblock_order aligned 
for all platforms so if we encounter any non-migratable (or PageBuddy) 
memory in a block where pageblock_order == HPAGE_PMD_NR, then we can abort 
that block immediately for thp faults.

> >     When an unmigratable page is encountered or memory hole is found,
> >     put all pages on cc->migratepages back on the lru lists unless
> >     cc->nr_migratepages >= (1 << cc->order).  Otherwise, migrate when
> >     enough contiguous memory has been isolated.
> > 
> >   - Remove the need_resched() checks entirely from compaction and
> >     consider only doing a set amount of scanning for each call, such
> >     as 1GB per call.
> > 
> >     If there is contention on zone->lru_lock, then we can still abort
> >     to avoid excessive stalls, but need_resched() is a poor heuristic
> >     to determine when async compaction is taking too long.
> 
> I tend to agree. I've also realized that because need_resched() leads to
> cc->contended = true, direct reclaim and second compaction that would normally
> follow (used to be sync, now only in hugepaged) is skipped. need_resched()
> seems to be indeed unsuitable for this.
> 

It's hard to replace with an alternative, though, to determine when enough 
is enough :)  1GB might be a sane starting point, though, and then try 
reclaim and avoid the second call to async compaction on failure.  I'm not 
sure if the deferral would be needed in this case or not.

> >     The expense of calling async compaction if this is done is easily
> >     quantified since we're not migrating any memory unless it is
> >     sufficient for the page allocation: it would simply be the iteration
> >     over 1GB of memory and avoiding contention on zone->lru_lock.
> > 
> > We may also need to consider deferring async compaction for subsequent
> > faults in the near future even though scanning the previous 1GB does not
> > decrease or have any impact whatsoever in the success of defragmenting the
> > next 1GB.
> > 
> > Any other suggestions that may be helpful?
> 
> I suggested already the idea of turning the deferred compaction into a
> live-tuned amount of how much to scan, instead of doing a whole zone (before)
> or an arbitrary amount like 1GB, with the hope of reducing the latency spikes.
> But I realize this would be tricky.
> 

By live-tuned, do you mean something that is tuned by the kernel over time 
depending on how successful compaction is or do you mean something that 
the user would alter?  If we are to go this route, I agree that we can 
allow the user to tune the 1GB.

> Even less concrete, it might be worth revisiting the rules we use for deciding
> if compaction is worth trying, and the decisions if to continue or we believe
> the allocation will succeed.

Ah, tuning compaction_suitable() might be another opportunity.  I'm 
wondering if we should be considering thp specially here since it's in the 
fault path.

> It relies heavily on watermark checks that also
> consider the order, and I found it somewhat fragile. For example, in the alloc
> slowpath -> direct compaction path, a check in compaction concludes that
> allocation should succeed and finishes the compaction, and few moments later
> the same check in the allocation will conclude that everything is fine up to
> order 8, but there probably isn't a page of order 9. In between, the
> nr_free_pages has *increased*. I suspect it's because the watermark checking
> is racy and the counters drift, but I'm not sure yet.

The watermark checks both in compaction_suitable() and and 
compact_finished() are indeed racy with respect to the actual page 
allocation.

> However, this particular problem should be gone when I finish my series that
> would capture the page that compaction has just freed. But still, the
> decisions regarding compaction could be suboptimal.
> 

This should also avoid the race between COMPACT_PARTIAL, returning to the 
page allocator, and finding that the high-order memory you thought was now 
available has been allocated by someone else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
