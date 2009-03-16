Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 030206B0062
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:23 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 00/35] Cleanup and optimise the page allocator V3
Date: Mon, 16 Mar 2009 09:45:55 +0000
Message-Id: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Here is V3 of an attempt to cleanup and optimise the page allocator and should
be ready for general testing. The page allocator is now faster (16%
reduced time overall for kernbench on one machine) and it has a smaller cache
footprint (16.5% less L1 cache misses and 19.5% less L2 cache misses for
kernbench on one machine). The text footprint has unfortunately increased,
largely due to the introduction of a form of lazy buddy merging mechanism
that avoids cache misses by postponing buddy merging until a high-order
allocation needs it.

I tested the patchset with kernbench, hackbench, sysbench-postgres and netperf
UDP and TCP with a variety of sizes. Many machines and loads showed improved
performance *however* it was not universal. On some machines, one load would
be faster and another slower (perversely, sometimes netperf-UDP would be
faster with netperf-TCP slower). On an different machines, the workloads
that gained or lost would differ.  I haven't fully pinned down why this is
yet but I have observed on at least one machine lock contention is higher
and more time is spent in functions like rb_erase(), both which might imply
some sort of scheduling artifact. I've also noted that while the allocator
incurs fewer cache misses, sometimes cache misses overall are increased
for the workload but the increased lock contention might account for this.

In some cases, more time is spent in copy_user_generic_string()[1] which
might imply that strings are getting the same colour with the greater
effort spent giving back hot pages but theories as to why this is not a
universal effect are welcome. I've also noted that machines with many CPUs
with different caches suffer because struct page is not cache-aligned but
aligning it hurts other machines so I left it alone. Finally, the performance
characteristics are vary depending on if you use SLAB, SLUB or SLQB.

So, while the page allocator is faster in most cases, making all workloads
universally go faster needs to now look at other areas like the sl*b
allocator and the scheduler.

Here is the patchset as it stands and I think it's ready for wider testing
and to be considered for merging depending on the outcome of testing and
reviews.

[1] copy_user_generic_unrolled on one machine was slowed down by an extreme
amount. I did not check if there was a pattern of slowdowns versus which
version of copy_user_generic() was used

Changes since V2
  o Remove brances by treating watermark flags as array indices
  o Remove branch by assuming __GFP_HIGH == ALLOC_HIGH
  o Do not check for compound on every page free
  o Remove branch by always ensuring the migratetype is known on free
  o Simplify buffered_rmqueue further
  o Reintroduce improved version of batched bulk free of pcp pages
  o Use allocation flags as an index to zone watermarks
  o Work out __GFP_COLD only once
  o Reduce the number of times zone stats are updated
  o Do not dump reserve pages back into the allocator. Instead treat them
    as MOVABLE so that MIGRATE_RESERVE gets used on the max-order-overlapped
    boundaries without causing trouble
  o Allow pages up to PAGE_ALLOC_COSTLY_ORDER to use the per-cpu allocator.
    order-1 allocations are frequently enough in particular to justify this
  o Rearrange inlining such that the hot-path is inlined but not in a way
    that increases the text size of the page allocator
  o Make the check for needing additional zonelist filtering due to NUMA
    or cpusets as light as possible
  o Do not destroy compound pages going to the PCP lists
  o Delay the merging of buddies until a high-order allocation needs them
    or anti-fragmentation is being forced to fallback
  o Count high-order pages as 1

Changes since V1
  o Remove the ifdef CONFIG_CPUSETS from inside get_page_from_freelist()
  o Use non-lock bit operations for clearing the mlock flag
  o Factor out alloc_flags calculation so it is only done once (Peter)
  o Make gfp.h a bit prettier and clear-cut (Peter)
  o Instead of deleting a debugging check, replace page_count() in the
    free path with a version that does not check for compound pages (Nick)
  o Drop the alteration for hot/cold page freeing until we know if it
    helps or not

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
