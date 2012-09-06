Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E14666B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 09:25:56 -0400 (EDT)
Date: Thu, 6 Sep 2012 14:25:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120906132551.GS11266@suse.de>
References: <20120906104404.GA12718@kernel.org>
 <20120906121725.GQ11266@suse.de>
 <20120906125526.GA1025@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120906125526.GA1025@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu, Sep 06, 2012 at 08:55:26PM +0800, Shaohua Li wrote:
> On Thu, Sep 06, 2012 at 01:17:25PM +0100, Mel Gorman wrote:
> > On Thu, Sep 06, 2012 at 06:44:04PM +0800, Shaohua Li wrote:
> > > 
> > > isolate_migratepages_range() might isolate none pages, for example, when
> > > zone->lru_lock is contended and compaction is async. In this case, we should
> > > abort compaction, otherwise, compact_zone will run a useless loop and make
> > > zone->lru_lock is even contended.
> > > 
> > 
> > It might also isolate no pages because the range was 100% allocated and
> > there were no free pages to isolate. This is perfectly normal and I suspect
> > this patch effectively disables compaction. What problem did you observe
> > that this patch is aimed at?
> 
> I'm running a random swapin/out workload. When memory is fragmented enough, I
> saw 100% cpu usage. perf shows zone->lru_lock is heavily contended in
> isolate_migratepages_range. I'm using slub(I didn't see the problem with slab),
> the allocation is for radix_tree_node slab, which needs 4 pages.

Ok, the fragmentaiton is due to high-order unmovable kernel allocations from
SLUB which will have diminishing returns over time.  One option to address
this is to check if it's a high-order kernel allocation that can fail and
not compact in that case. SLUB will fall back to using order-0 instead.

> Even If I just
> apply the second patch, the system is still in 100% cpu usage. The
> spin_is_contended check can't cure the problem completely.

Are you sure it's really contention in that case and not just a lot of
time is spent in compaction trying to satisfy the radix_tree_node
allocation requests?

> Trace shows
> compact_zone will run a useless loop and each loop contend the lru_lock. With
> this patch, the cpu usage becomes normal (about 20% utilization).

I suspect the reason why this patch has an effect is because compaction is
no longer running. It finds a 100% full pageblock quickly and then aborts and
that is not the right fix. Can you try something like this instead please?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8f6eea3..bd5bd6d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2114,6 +2114,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
+	/* Do not compact for high-order kernel allocations that can fail */
+	if ((gfp_mask & (__GFP_NORETRY | __GFP_MOVABLE)) == __GFP_NORETRY)
+		return NULL;
+
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, sync_migration,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
