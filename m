Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B4F4B6B0055
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:23 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Date: Sun, 22 Feb 2009 23:17:09 +0000
Message-Id: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

The complexity of the page allocator has been increasing for some time
and it has now reached the point where the SLUB allocator is doing strange
tricks to avoid the page allocator. This is obviously bad as it may encourage
other subsystems to try avoiding the page allocator as well.

This series of patches is intended to reduce the cost of the page
allocator by doing the following.

Patches 1-3 iron out the entry paths slightly and remove stupid sanity
checks from the fast path.

Patch 4 uses a lookup table instead of a number of branches to decide what
zones are usable given the GFP flags.

Patch 5 avoids repeated checks of the zonelist

Patch 6 breaks the allocator up into a fast and slow path where the fast
path later becomes one long inlined function.

Patches 7-10 avoids calculating the same things repeatedly and instead
calculates them once.

Patches 11-13 inline the whole allocator fast path

Patch 14 avoids calling get_pageblock_migratetype() potentially twice on
every page free

Patch 15 reduces the number of times interrupts are disabled by reworking
what free_page_mlock() does. However, I notice that the cost of calling
TestClearPageMlocked() is still quite high and I'm guessing it's because
it's a locked bit operation. It's be nice if it could be established if
it's safe to use an unlocked version here. Rik, can you comment?

Patch 16 avoids using the zonelist cache on non-NUMA machines

Patch 17 removes an expensive and excessively paranoid check in the
allocator fast path

Patch 18 avoids a list search in the allocator fast path.

Patch 19 avoids repeated checking of an empty list.

Patch 20 gets rid of hot/cold freeing of pages because it incurs cost for
what I believe to be very dubious gain. I'm not sure we currently gain
anything by it but it's further discussed in the patch itself.

Running all of these through a profiler shows me the cost of page allocation
and freeing is reduced by a nice amount without drastically altering how the
allocator actually works. Excluding the cost of zeroing pages, the cost of
allocation is reduced by 25% and the cost of freeing by 12%.  Again excluding
zeroing a page, much of the remaining cost is due to counters, debugging
checks and interrupt disabling.  Of course when a page has to be zeroed,
the dominant cost of a page allocation is zeroing it.

Counters are surprising expensive, we spent a good chuck of our time in
functions like __dec_zone_page_state and __dec_zone_state. In a profiled
run of kernbench, the time spent in __dec_zone_state was roughly equal to
the combined cost of the rest of the page free path. A quick check showed
that almost half of the time in that function is spent on line 233 alone
which for me is;

	(*p)--;

That's worth a separate investigation but it might be a case that
manipulating int8_t on the machine I was using for profiling is unusually
expensive. Converting this to an int might be faster but the increased
memory consumption and cache footprint might be a problem. Opinions?

The downside is that the patches do increase text size because of the
splitting of the fast path into one inlined blob and the slow path into a
number of other functions. On my test machine, text increased by 1.2K so
I might revisit that again and see how much of a difference it really made.

That all said, I'm seeing good results on actual benchmarks with these
patches.

o On many machines, I'm seeing a 0-2% improvement on kernbench. The dominant
  cost in kernbench is the compiler and zeroing allocated pages for
  pagetables.

o For tbench, I have seen an 8-12% improvement on two x86-64 machines (elm3b6
  on test.kernel.org gained 8%) but generally it was less dramatic on
  x86-64 in the range of 0-4%. On one PPC64, the different was also in the
  range of 0-4%. Generally there were gains, but one specific ppc64 showed a
  regression of 7% for one client but a negligible difference for 8 clients.
  It's not clear why this machine regressed and others didn't.

o hackbench is harder to conclude anything from. Most machines showed
  performance gains in the 5-11% range but one machine in particular showed
  a mix of gains and losses depending on the number of clients. Might be
  a caching thing.

o One machine in particular was a major surprise for sysbench with gains
  of 4-8% there which was drastically higher than I was expecting. However,
  on other machines, it was in the more reasonable 0-4% range, still pretty
  respectable. It's not guaranteed though. While most machines showed some
  sort of gain, one ppc64 showed no difference at all.

So, by and large it's an improvement of some sort.

I haven't run a page-allocator micro-benchmark to see what sort of figures
that gives. Christoph, I recall you had some sort of page allocator
micro-benchmark. Do you want to give it a shot or remind me how to use
it please?

All other reviews, comments, alternative benchmark reports are welcome.

 arch/ia64/hp/common/sba_iommu.c   |    2 +-
 arch/ia64/kernel/mca.c            |    3 +-
 arch/ia64/kernel/uncached.c       |    3 +-
 arch/ia64/sn/pci/pci_dma.c        |    3 +-
 arch/powerpc/platforms/cell/ras.c |    2 +-
 arch/x86/kvm/vmx.c                |    2 +-
 drivers/misc/sgi-gru/grufile.c    |    2 +-
 drivers/misc/sgi-xp/xpc_uv.c      |    2 +-
 fs/afs/write.c                    |    4 +-
 fs/btrfs/compression.c            |    2 +-
 fs/btrfs/extent_io.c              |    4 +-
 fs/btrfs/ordered-data.c           |    2 +-
 fs/cifs/file.c                    |    4 +-
 fs/gfs2/ops_address.c             |    2 +-
 fs/hugetlbfs/inode.c              |    2 +-
 fs/nfs/dir.c                      |    2 +-
 fs/ntfs/file.c                    |    2 +-
 fs/ramfs/file-nommu.c             |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c       |    4 +-
 include/linux/gfp.h               |   58 ++--
 include/linux/mm.h                |    1 -
 include/linux/mmzone.h            |    8 +-
 include/linux/pagemap.h           |    2 +-
 include/linux/pagevec.h           |    4 +-
 include/linux/swap.h              |    2 +-
 init/main.c                       |    1 +
 kernel/profile.c                  |    8 +-
 mm/filemap.c                      |    4 +-
 mm/hugetlb.c                      |    4 +-
 mm/internal.h                     |   10 +-
 mm/mempolicy.c                    |    2 +-
 mm/migrate.c                      |    2 +-
 mm/page-writeback.c               |    2 +-
 mm/page_alloc.c                   |  646 ++++++++++++++++++++++-----------
 mm/slab.c                         |    4 +-
 mm/slob.c                         |    4 +-
 mm/slub.c                         |    5 +-
 mm/swap.c                         |   12 +-
 mm/swap_state.c                   |    2 +-
 mm/truncate.c                     |    6 +-
 mm/vmalloc.c                      |    6 +-
 mm/vmscan.c                       |    8 +-
 42 files changed, 517 insertions(+), 333 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
