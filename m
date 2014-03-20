Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id B0DD96B0190
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:39:42 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so492389pbc.13
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 23:39:42 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ha5si704059pbc.172.2014.03.19.23.39.39
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 23:39:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v2 0/3] support madvise(MADV_FREE)
Date: Thu, 20 Mar 2014 15:38:55 +0900
Message-Id: <1395297538-10491-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch is an attempt to support MADV_FREE for Linux.

Rationale is following as.

Allocators call munmap(2) when user call free(3) if ptr is
in mmaped area. But munmap isn't cheap because it have to
clean up all pte entries, unlinking a vma and returns free pages
to page allocator so that overhead would be increased linearly
by mmaped area's size. In the end, userspace allocators like
MADV_DONTNEED rather than munmap.

Because MADV_DONTNEED holds read-side lock of mmap_sem so
other threads of the process could go with concurrent page faults
so it is better than munmap if it's not lack of address space.
But a problem of this approach is that most of allocator reuses
freed memory space soonish so users of allocator will see
page fault, page allocation, page zeroing if allocator already
called MADV_DONNEED on the address space.

For avoidng that overheads, other OS have supported MADV_FREE.
The idea is just clear dirty bit from pte when the syscall
is called and purge them if memory pressure happens.

If there is write(ie, store) operation in MADV_FREEed page,
VM checks pte_dirty and don't purge the page so users could
the page without any corruption.

For testing, I tweaked jamalloc to use MADV_FREE.

diff --git a/src/chunk_mmap.c b/src/chunk_mmap.c
index 8a42e75..20e31af 100644
--- a/src/chunk_mmap.c
+++ b/src/chunk_mmap.c
@@ -131,7 +131,7 @@ pages_purge(void *addr, size_t length)
 #  else
 #    error "No method defined for purging unused dirty pages."
 #  endif
-       int err = madvise(addr, length, JEMALLOC_MADV_PURGE);
+       int err = madvise(addr, length, 5);
        unzeroed = (JEMALLOC_MADV_ZEROS == false || err != 0);
 #  undef JEMALLOC_MADV_PURGE
 #  undef JEMALLOC_MADV_ZEROS


RAM 2G, CPU 4, ebizzy benchmark(./ebizzy -S 30 -n 512)

(1.1) stands for 1 process and 1 thread so for exmaple,
(1.4) means 1 process and 4 thread.

vanilla jemalloc         patched jemalloc

1.1       1.1
records:  5               records:  5
avg:      7417.80         avg:      13866.00
std:      82.53(1.11%)    std:      323.16(2.33%)
max:      7559.00         max:      14264.00
min:      7309.00         min:      13543.00
1.4       1.4
records:  5               records:  5
avg:      16353.80        avg:      30380.00
std:      423.30(2.59%)   std:      852.16(2.81%)
max:      16823.00        max:      31819.00
min:      15788.00        min:      29310.00
1.8       1.8
records:  5               records:  5
avg:      15766.00        avg:      27498.40
std:      1073.76(6.81%)  std:      1838.82(6.69%)
max:      17259.00        max:      30070.00
min:      13919.00        min:      24810.00
4.1       4.1
records:  5               records:  5
avg:      4000.40         avg:      7926.60
std:      9.75(0.24%)     std:      126.84(1.60%)
max:      4013.00         max:      8171.00
min:      3984.00         min:      7805.00
4.4       4.4
records:  5               records:  5
avg:      3920.40         avg:      7046.80
std:      73.11(1.86%)    std:      148.47(2.11%)
max:      4044.00         max:      7320.00
min:      3838.00         min:      6876.00
4.8       4.8
records:  5               records:  5
avg:      3951.80         avg:      7024.60
std:      51.47(1.30%)    std:      150.76(2.15%)
max:      4048.00         max:      7284.00
min:      3893.00         min:      6814.00
8.1       8.1
records:  5               records:  5
avg:      1919.80         avg:      3354.00
std:      39.33(2.05%)    std:      100.58(3.00%)
max:      1989.00         max:      3529.00
min:      1870.00         min:      3227.00
8.4       8.4
records:  5               records:  5
avg:      1946.60         avg:      2800.40
std:      22.69(1.17%)    std:      246.64(8.81%)
max:      1977.00         max:      3081.00
min:      1915.00         min:      2394.00
8.8       8.8
records:  5               records:  5
avg:      1947.20         avg:      2249.60
std:      19.54(1.00%)    std:      131.43(5.84%)
max:      1973.00         max:      2505.00
min:      1929.00         min:      2149.00

MADV_FREE is about 2 time faster than MADV_DONTNEED but
it starts slow down as memory pressure is heavy compared to
DONTNEED. It's natural because MADV_FREE needs more steps to
free pages so one thing I have a mind to overcome is just
purge them if memory pressure is severe(ex, kswapd active)
rather than giving a chance to promote freeing page
from inactive LRU when madvise_free is called.

(just wondering, when I used PG_lazyfree(ie, PG_private)
 in previous internal version, I didn't see the  above
 regression in same test. I will investigate what's culprit
 in there.)

Still, I didn't test a lot and surely needs more description
and a few TODO(ex, lazyfree page accoutning and work with
swapless system but it's further enhance, not necessary
in this stage) but it's enough to show the concept and direction
before LSF/MM.

Patchset is based on 3.14-rc6.

Welcome any comment!

* From v1
  * Use custom page table walker for madvise_free - Johannes
  * Remove PG_lazypage flag - Johannes
  * Do madvise_dontneed instead of madvise_freein swapless system

Minchan Kim (3):
  mm: support madvise(MADV_FREE)
  mm: work deactivate_page with anon pages
  mm: deactivate lazyfree pages

 include/linux/mm.h                     |   2 +
 include/linux/mm_inline.h              |   9 ++
 include/linux/rmap.h                   |   6 ++
 include/linux/vm_event_item.h          |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           |  25 +++++
 mm/memory.c                            | 162 ++++++++++++++++++++++++++++++++-
 mm/rmap.c                              |  31 ++++++-
 mm/swap.c                              |  20 ++--
 mm/swap_state.c                        |   3 +-
 mm/vmscan.c                            |  12 +++
 mm/vmstat.c                            |   1 +
 12 files changed, 255 insertions(+), 18 deletions(-)

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
