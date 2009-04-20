Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 913E45F0002
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:02 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 00/25] Cleanup and optimise the page allocator V6
Date: Mon, 20 Apr 2009 23:19:46 +0100
Message-Id: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Here is V6 of the cleanup and optimisation of the page allocator and it
should be ready for wider testing. Please consider a possibility for
merging as a Pass 1 at making the page allocator faster. Other passes
will occur later when this one has had a bit of exercise. This patchset
is based on mmotm-2009-04-17 but I haven't widely tested it myself due to
problems I'm encountering with the test grid I use (mostly unrelated to
the kernel). It doesn't apply cleanly to linux-next due to dependencies on
patches in -mm but the conflicts are fairly straight-forward to resolve.
I'm working on getting three local test machines built to test there but
it'll take a while and I wanted to get these patches out.

Hence, the following report is the same from V5 and based on an older
kernel. However, I expect similar results in a newer kernel.

======== Old Report ========

Performance is improved in a variety of cases but note it's not universal due
to lock contention which I'll explain later. Text is reduced by 497 bytes on
the x86-64 config I checked. 18.78% less clock cycles were sampled in the page
allocator paths excluding zeroing which is roughly the same in either kernel,
L1 cache misses are reduced by about 7.36% and L2 cache misses were reduced
by 17.91% cache misses incurred within the allocator itself are reduced.

The lock contention on some machines goes up for the the zone->lru_lock
and zone->lock locks which can regress some workloads even though others on
the same machine still go faster. For netperf, a lock called slock-AF_INET
seemed very important although I didn't look too closely other than noting
contention went up. The zone->lock gets hammered a lot by high order allocs
and frees coming from SLUB which are not covered by the PCP allocator in
this patchset. zone->lru_lock goes up is less clear but as it's page cache
releases but overall contention may be up because CPUs are spending less
time with interrupts disabled and more time trying to do real work but
contending on the locks.

============

Change since V5
  o Rebase to mmotm-2009-04-17

Changes since V4
  o Drop the more controversial patches for now and focus on the "obvious win"
    material.
  o Add reviewed-by notes
  o Fix changelog entry to say __rmqueue_fallback instead __rmqueue
  o Add unlikely() for the clearMlocked check
  o Change where PGFREE is accounted in free_hot_cold_page() to have symmetry
    with __free_pages_ok()
  o Convert num_online_nodes() to use a static value so that callers do
    not have to be individually updated
  o Rebase to mmotm-2003-03-13

Changes since V3
  o Drop the more controversial patches for now and focus on the "obvious win"
    material
  o Add reviewed-by notes
  o Fix changelog entry to say __rmqueue_fallback instead __rmqueue
  o Add unlikely() for the clearMlocked check
  o Change where PGFREE is accounted in free_hot_cold_page() to have symmetry
    with __free_pages_ok()

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
