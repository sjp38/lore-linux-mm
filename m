Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id B68186B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 07:22:06 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id as1so4931475iec.3
        for <linux-mm@kvack.org>; Fri, 02 May 2014 04:22:06 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id u6si749393icp.200.2014.05.02.04.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 04:22:05 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id z10so3242384pdj.28
        for <linux-mm@kvack.org>; Fri, 02 May 2014 04:22:05 -0700 (PDT)
Date: Fri, 2 May 2014 04:22:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 4/4] mm, thp: do not perform sync compaction on
 pagefault
In-Reply-To: <20140502102231.GQ23991@suse.de>
Message-ID: <alpine.DEB.2.02.1405020402500.19297@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com> <20140502102231.GQ23991@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 May 2014, Mel Gorman wrote:

> > Synchronous memory compaction can be very expensive: it can iterate an enormous 
> > amount of memory without aborting, constantly rescheduling, waiting on page
> > locks and lru_lock, etc, if a pageblock cannot be defragmented.
> > 
> > Unfortunately, it's too expensive for pagefault for transparent hugepages and 
> > it's much better to simply fallback to pages.  On 128GB machines, we find that 
> > synchronous memory compaction can take O(seconds) for a single thp fault.
> > 
> > Now that async compaction remembers where it left off without strictly relying
> > on sync compaction, this makes thp allocations best-effort without causing
> > egregious latency during pagefault.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Compaction uses MIGRATE_SYNC_LIGHT which in the current implementation
> avoids calling ->writepage to clean dirty page in the fallback migrate
> case
> 
> static int fallback_migrate_page(struct address_space *mapping,
>         struct page *newpage, struct page *page, enum migrate_mode mode)
> {
>         if (PageDirty(page)) {
>                 /* Only writeback pages in full synchronous migration */
>                 if (mode != MIGRATE_SYNC)
>                         return -EBUSY;
>                 return writeout(mapping, page);
>         }
> 
> or waiting on page writeback in other cases
> 
>                 /*
>                  * Only in the case of a full synchronous migration is it
>                  * necessary to wait for PageWriteback. In the async case,
>                  * the retry loop is too short and in the sync-light case,
>                  * the overhead of stalling is too much
>                  */
>                 if (mode != MIGRATE_SYNC) {
>                         rc = -EBUSY;
>                         goto uncharge;
>                 }
> 
> or on acquiring the page lock for unforced migrations.
> 

The page locks I'm referring to is the lock_page() in __unmap_and_move() 
that gets called for sync compaction after the migrate_pages() iteration 
makes a few passes and unsuccessfully grabs it.  This becomes a forced 
migration since __unmap_and_move() returns -EAGAIN when the trylock fails.

> However, buffers still get locked in the SYNC_LIGHT case causing stalls
> in buffer_migrate_lock_buffers which may be undesirable or maybe you are
> hitting some other case.

We have perf profiles from one workload in particular that shows 
contention on i_mmap_mutex (anon isn't interesting since the vast majority 
of memory on this workload [120GB on a 128GB machine] is has a gup pin and 
doesn't get isolated because of 119d6d59dcc0 ("mm, compaction: avoid 
isolating pinned pages")) between cpus all doing memory compaction trying 
to fault thp memory.

That's one example that we've seen, but the fact remains that at times 
sync compaction will iterate the entire 128GB machine and not allow an 
order-9 page to be allocated and there's nothing to preempt it like the 
need_resched() or lock contention checks that async compaction has.  (I 
say "at times" because deferred compaction does help if it's triggered and 
the cached pfn values help, but the worst case scenario is when the entire 
machine is iterated.)  Would it make sense when HPAGE_PMD_ORDER == 
pageblock_order, which is usually the case, that we don't even try to 
migrate pages unless the entire pageblock is successfully isolated and 
gfp_mask & __GFP_NO_KSWAPD?  That's the only other thing that I can think 
that will avoid such a problem other than this patch.

We're struggling to find the logic that ensures sync compaction does not 
become too expensive at pagefault and unless that can be guaranteed, it 
seemed best to avoid it entirely.

> It would be preferable to identify what is
> getting stalled in SYNC_LIGHT compaction and fix that rather than
> disabling it entirely. You may also want to distinguish between a direct
> compaction by a process and collapsing huge pages as done by khugepaged.
> 

I'm referring to latencies of 8-9 seconds to fault 64MB of transparent 
hugepages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
