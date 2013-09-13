Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DA9B86B0033
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 09:06:29 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/9] split page table lock for PMD tables
Date: Fri, 13 Sep 2013 16:06:07 +0300
Message-Id: <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20130910074748.GA2971@gmail.com>
References: <20130910074748.GA2971@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Alex Thorlton noticed that some massivly threaded workloads work poorly,
if THP enabled. This patchset fixes this by introducing split page table
lock for PMD tables. hugetlbfs is not covered yet.

This patchset is based on work by Naoya Horiguchi.

Benchmark (from Alex): ftp://shell.sgi.com/collect/appsx_test/pthread_test.tar.gz

THP off:
--------

 Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):

    1738259.808012 task-clock                #   47.571 CPUs utilized            ( +-  9.49% )
           147,359 context-switches          #    0.085 K/sec                    ( +-  9.67% )
                14 cpu-migrations            #    0.000 K/sec                    ( +- 13.25% )
        24,410,139 page-faults               #    0.014 M/sec                    ( +-  0.00% )
 4,149,037,526,252 cycles                    #    2.387 GHz                      ( +-  9.50% )
 3,649,839,735,027 stalled-cycles-frontend   #   87.97% frontend cycles idle     ( +-  6.60% )
 2,455,558,969,567 stalled-cycles-backend    #   59.18% backend  cycles idle     ( +- 22.92% )
 1,434,961,518,604 instructions              #    0.35  insns per cycle
                                             #    2.54  stalled cycles per insn  ( +- 92.86% )
   241,472,020,951 branches                  #  138.916 M/sec                    ( +- 91.72% )
        84,022,172 branch-misses             #    0.03% of all branches          ( +-  3.16% )

      36.540185552 seconds time elapsed                                          ( +- 18.36% )

THP on, no patchset:
--------------------
 Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):

    2528378.966949 task-clock                #   50.715 CPUs utilized            ( +- 11.86% )
           214,063 context-switches          #    0.085 K/sec                    ( +- 11.94% )
                19 cpu-migrations            #    0.000 K/sec                    ( +- 22.72% )
            49,226 page-faults               #    0.019 K/sec                    ( +-  0.33% )
 6,034,640,598,498 cycles                    #    2.387 GHz                      ( +- 11.91% )
 5,685,933,794,081 stalled-cycles-frontend   #   94.22% frontend cycles idle     ( +-  7.67% )
 4,414,381,393,353 stalled-cycles-backend    #   73.15% backend  cycles idle     ( +-  2.09% )
   952,086,804,776 instructions              #    0.16  insns per cycle
                                             #    5.97  stalled cycles per insn  ( +- 89.59% )
   166,191,211,974 branches                  #   65.730 M/sec                    ( +- 85.52% )
        33,341,022 branch-misses             #    0.02% of all branches          ( +-  3.90% )

      49.854741504 seconds time elapsed                                          ( +- 14.76% )

THP on, with patchset:
----------------------

echo always > /sys/kernel/mm/transparent_hugepage/enabled
 Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):

    1538763.343568 task-clock                #   45.386 CPUs utilized            ( +-  7.21% )
           130,469 context-switches          #    0.085 K/sec                    ( +-  7.32% )
                14 cpu-migrations            #    0.000 K/sec                    ( +- 23.58% )
            49,299 page-faults               #    0.032 K/sec                    ( +-  0.15% )
 3,666,748,502,650 cycles                    #    2.383 GHz                      ( +-  7.25% )
 3,330,488,035,212 stalled-cycles-frontend   #   90.83% frontend cycles idle     ( +-  4.70% )
 2,383,357,073,990 stalled-cycles-backend    #   65.00% backend  cycles idle     ( +- 16.06% )
   935,504,610,528 instructions              #    0.26  insns per cycle
                                             #    3.56  stalled cycles per insn  ( +- 91.16% )
   161,466,689,532 branches                  #  104.933 M/sec                    ( +- 87.67% )
        22,602,225 branch-misses             #    0.01% of all branches          ( +-  6.43% )

      33.903917543 seconds time elapsed                                          ( +- 12.57% )

Kirill A. Shutemov (9):
  mm: rename SPLIT_PTLOCKS to SPLIT_PTE_PTLOCKS
  mm: convert mm->nr_ptes to atomic_t
  mm: introduce api for split page table lock for PMD level
  mm, thp: change pmd_trans_huge_lock() to return taken lock
  mm, thp: move ptl taking inside page_check_address_pmd()
  mm, thp: do not access mm->pmd_huge_pte directly
  mm: convent the rest to new page table lock api
  mm: implement split page table lock for PMD level
  x86, mm: enable split page table lock for PMD level

 arch/arm/mm/fault-armv.c            |   6 +-
 arch/s390/mm/pgtable.c              |  12 +--
 arch/sparc/mm/tlb.c                 |  12 +--
 arch/um/defconfig                   |   2 +-
 arch/x86/Kconfig                    |   4 +
 arch/x86/include/asm/pgalloc.h      |   8 +-
 arch/x86/xen/mmu.c                  |   6 +-
 arch/xtensa/configs/iss_defconfig   |   2 +-
 arch/xtensa/configs/s6105_defconfig |   2 +-
 fs/proc/task_mmu.c                  |  15 +--
 include/linux/huge_mm.h             |  17 +--
 include/linux/mm.h                  |  51 ++++++++-
 include/linux/mm_types.h            |  15 ++-
 kernel/fork.c                       |   6 +-
 mm/Kconfig                          |  12 ++-
 mm/huge_memory.c                    | 201 +++++++++++++++++++++---------------
 mm/memcontrol.c                     |  10 +-
 mm/memory.c                         |  21 ++--
 mm/migrate.c                        |   7 +-
 mm/mmap.c                           |   3 +-
 mm/mprotect.c                       |   4 +-
 mm/oom_kill.c                       |   6 +-
 mm/pgtable-generic.c                |  16 +--
 mm/rmap.c                           |  13 +--
 24 files changed, 280 insertions(+), 171 deletions(-)

-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
