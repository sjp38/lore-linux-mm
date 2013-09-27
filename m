Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 193EE6B004D
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:17:01 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so2546061pbb.34
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:17:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/10] split page table lock for PMD tables
Date: Fri, 27 Sep 2013 16:16:17 +0300
Message-Id: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Alex Thorlton noticed that some massively threaded workloads work poorly,
if THP enabled. This patchset fixes this by introducing split page table
lock for PMD tables. hugetlbfs is not covered yet.

This patchset is based on work by Naoya Horiguchi.

Please review and consider applying.

Changes:
 v4:
  - convert hugetlb to new locking;
 v3:
  - fix USE_SPLIT_PMD_PTLOCKS;
  - fix warning in fs/proc/task_mmu.c;
 v2:
  - reuse CONFIG_SPLIT_PTLOCK_CPUS for PMD split lock;
  - s/huge_pmd_lock/pmd_lock/g;
  - assume pgtable_pmd_page_ctor() can fail;
  - fix format line in task_mem() for VmPTE;

THP off, v3.12-rc2:
-------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

    1037072.835207 task-clock                #   57.426 CPUs utilized            ( +-  3.59% )
            95,093 context-switches          #    0.092 K/sec                    ( +-  3.93% )
               140 cpu-migrations            #    0.000 K/sec                    ( +-  5.28% )
        10,000,550 page-faults               #    0.010 M/sec                    ( +-  0.00% )
 2,455,210,400,261 cycles                    #    2.367 GHz                      ( +-  3.62% ) [83.33%]
 2,429,281,882,056 stalled-cycles-frontend   #   98.94% frontend cycles idle     ( +-  3.67% ) [83.33%]
 1,975,960,019,659 stalled-cycles-backend    #   80.48% backend  cycles idle     ( +-  3.88% ) [66.68%]
    46,503,296,013 instructions              #    0.02  insns per cycle
                                             #   52.24  stalled cycles per insn  ( +-  3.21% ) [83.34%]
     9,278,997,542 branches                  #    8.947 M/sec                    ( +-  4.00% ) [83.34%]
        89,881,640 branch-misses             #    0.97% of all branches          ( +-  1.17% ) [83.33%]

      18.059261877 seconds time elapsed                                          ( +-  2.65% )

THP on, v3.12-rc2:
------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

    3114745.395974 task-clock                #   73.875 CPUs utilized            ( +-  1.84% )
           267,356 context-switches          #    0.086 K/sec                    ( +-  1.84% )
                99 cpu-migrations            #    0.000 K/sec                    ( +-  1.40% )
            58,313 page-faults               #    0.019 K/sec                    ( +-  0.28% )
 7,416,635,817,510 cycles                    #    2.381 GHz                      ( +-  1.83% ) [83.33%]
 7,342,619,196,993 stalled-cycles-frontend   #   99.00% frontend cycles idle     ( +-  1.88% ) [83.33%]
 6,267,671,641,967 stalled-cycles-backend    #   84.51% backend  cycles idle     ( +-  2.03% ) [66.67%]
   117,819,935,165 instructions              #    0.02  insns per cycle
                                             #   62.32  stalled cycles per insn  ( +-  4.39% ) [83.34%]
    28,899,314,777 branches                  #    9.278 M/sec                    ( +-  4.48% ) [83.34%]
        71,787,032 branch-misses             #    0.25% of all branches          ( +-  1.03% ) [83.33%]

      42.162306788 seconds time elapsed                                          ( +-  1.73% )

HUGETLB, v3.12-rc2:
-------------------

 Performance counter stats for './thp_memscale_hugetlbfs -c 80 -b 512M' (5 runs):

    2588052.787264 task-clock                #   54.400 CPUs utilized            ( +-  3.69% )
           246,831 context-switches          #    0.095 K/sec                    ( +-  4.15% )
               138 cpu-migrations            #    0.000 K/sec                    ( +-  5.30% )
            21,027 page-faults               #    0.008 K/sec                    ( +-  0.01% )
 6,166,666,307,263 cycles                    #    2.383 GHz                      ( +-  3.68% ) [83.33%]
 6,086,008,929,407 stalled-cycles-frontend   #   98.69% frontend cycles idle     ( +-  3.77% ) [83.33%]
 5,087,874,435,481 stalled-cycles-backend    #   82.51% backend  cycles idle     ( +-  4.41% ) [66.67%]
   133,782,831,249 instructions              #    0.02  insns per cycle
                                             #   45.49  stalled cycles per insn  ( +-  4.30% ) [83.34%]
    34,026,870,541 branches                  #   13.148 M/sec                    ( +-  4.24% ) [83.34%]
        68,670,942 branch-misses             #    0.20% of all branches          ( +-  3.26% ) [83.33%]

      47.574936948 seconds time elapsed                                          ( +-  2.09% )

THP off, patched:
-----------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

     943301.957892 task-clock                #   56.256 CPUs utilized            ( +-  3.01% )
            86,218 context-switches          #    0.091 K/sec                    ( +-  3.17% )
               121 cpu-migrations            #    0.000 K/sec                    ( +-  6.64% )
        10,000,551 page-faults               #    0.011 M/sec                    ( +-  0.00% )
 2,230,462,457,654 cycles                    #    2.365 GHz                      ( +-  3.04% ) [83.32%]
 2,204,616,385,805 stalled-cycles-frontend   #   98.84% frontend cycles idle     ( +-  3.09% ) [83.32%]
 1,778,640,046,926 stalled-cycles-backend    #   79.74% backend  cycles idle     ( +-  3.47% ) [66.69%]
    45,995,472,617 instructions              #    0.02  insns per cycle
                                             #   47.93  stalled cycles per insn  ( +-  2.51% ) [83.34%]
     9,179,700,174 branches                  #    9.731 M/sec                    ( +-  3.04% ) [83.35%]
        89,166,529 branch-misses             #    0.97% of all branches          ( +-  1.45% ) [83.33%]

      16.768027318 seconds time elapsed                                          ( +-  2.47% )

THP on, patched:
----------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

     458793.837905 task-clock                #   54.632 CPUs utilized            ( +-  0.79% )
            41,831 context-switches          #    0.091 K/sec                    ( +-  0.97% )
                98 cpu-migrations            #    0.000 K/sec                    ( +-  1.66% )
            57,829 page-faults               #    0.126 K/sec                    ( +-  0.62% )
 1,077,543,336,716 cycles                    #    2.349 GHz                      ( +-  0.81% ) [83.33%]
 1,067,403,802,964 stalled-cycles-frontend   #   99.06% frontend cycles idle     ( +-  0.87% ) [83.33%]
   864,764,616,143 stalled-cycles-backend    #   80.25% backend  cycles idle     ( +-  0.73% ) [66.68%]
    16,129,177,440 instructions              #    0.01  insns per cycle
                                             #   66.18  stalled cycles per insn  ( +-  7.94% ) [83.35%]
     3,618,938,569 branches                  #    7.888 M/sec                    ( +-  8.46% ) [83.36%]
        33,242,032 branch-misses             #    0.92% of all branches          ( +-  2.02% ) [83.32%]

       8.397885779 seconds time elapsed                                          ( +-  0.18% )

HUGETLB, patched:
-----------------

 Performance counter stats for './thp_memscale_hugetlbfs -c 80 -b 512M' (5 runs):

     395353.076837 task-clock                #   20.329 CPUs utilized            ( +-  8.16% )
            55,730 context-switches          #    0.141 K/sec                    ( +-  5.31% )
               138 cpu-migrations            #    0.000 K/sec                    ( +-  4.24% )
            21,027 page-faults               #    0.053 K/sec                    ( +-  0.00% )
   930,219,717,244 cycles                    #    2.353 GHz                      ( +-  8.21% ) [83.32%]
   914,295,694,103 stalled-cycles-frontend   #   98.29% frontend cycles idle     ( +-  8.35% ) [83.33%]
   704,137,950,187 stalled-cycles-backend    #   75.70% backend  cycles idle     ( +-  9.16% ) [66.69%]
    30,541,538,385 instructions              #    0.03  insns per cycle
                                             #   29.94  stalled cycles per insn  ( +-  3.98% ) [83.35%]
     8,415,376,631 branches                  #   21.286 M/sec                    ( +-  3.61% ) [83.36%]
        32,645,478 branch-misses             #    0.39% of all branches          ( +-  3.41% ) [83.32%]

      19.447481153 seconds time elapsed                                          ( +-  2.00% )

Kirill A. Shutemov (10):
  mm: rename USE_SPLIT_PTLOCKS to USE_SPLIT_PTE_PTLOCKS
  mm: convert mm->nr_ptes to atomic_t
  mm: introduce api for split page table lock for PMD level
  mm, thp: change pmd_trans_huge_lock() to return taken lock
  mm, thp: move ptl taking inside page_check_address_pmd()
  mm, thp: do not access mm->pmd_huge_pte directly
  mm, hugetlb: convert hugetlbfs to use split pmd lock
  mm: convent the rest to new page table lock api
  mm: implement split page table lock for PMD level
  x86, mm: enable split page table lock for PMD level

 arch/arm/mm/fault-armv.c       |   6 +-
 arch/s390/mm/pgtable.c         |  12 +--
 arch/sparc/mm/tlb.c            |  12 +--
 arch/x86/Kconfig               |   4 +
 arch/x86/include/asm/pgalloc.h |  11 ++-
 arch/x86/xen/mmu.c             |   6 +-
 fs/proc/meminfo.c              |   2 +-
 fs/proc/task_mmu.c             |  16 ++--
 include/linux/huge_mm.h        |  17 ++--
 include/linux/hugetlb.h        |  25 +++++
 include/linux/mm.h             |  52 ++++++++++-
 include/linux/mm_types.h       |  18 ++--
 include/linux/swapops.h        |   7 +-
 kernel/fork.c                  |   6 +-
 mm/Kconfig                     |   3 +
 mm/huge_memory.c               | 201 ++++++++++++++++++++++++-----------------
 mm/hugetlb.c                   | 108 +++++++++++++---------
 mm/memcontrol.c                |  10 +-
 mm/memory.c                    |  21 +++--
 mm/mempolicy.c                 |   5 +-
 mm/migrate.c                   |  14 +--
 mm/mmap.c                      |   3 +-
 mm/mprotect.c                  |   4 +-
 mm/oom_kill.c                  |   6 +-
 mm/pgtable-generic.c           |  16 ++--
 mm/rmap.c                      |  15 ++-
 26 files changed, 379 insertions(+), 221 deletions(-)

-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
