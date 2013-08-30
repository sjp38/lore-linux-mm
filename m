Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9D9EC6B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:19:22 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/2 v2] split page table lock for hugepage
Date: Fri, 30 Aug 2013 13:18:38 -0400
Message-Id: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Hi,

I revised the split page table lock patch (v1 is [1]), and got some numbers
to confirm the performance improvement.

This patchset simply replaces all of locking/unlocking of mm->page_table_lock
in hugepage context with page->ptl when USE_SPLIT_PTLOCKS is true, which
breaks single mm wide locking into multiple small (pmd/pte sized) address
range locking, so we can clearly expect better performance when many threads
access to virtual memory of a process simultaneously.

Here is the result of my testing [2], where I measured the time (in seconds)
taken to execute a specific workload in various conditions. So the smaller
number means the better performance. The workload is like this:
  1) allocate N hugepages/thps and touch them once,
  2) create T threads with pthread_create(), and
  3) each thread accesses to the whole pages sequentially 10 times.

           |             hugetlb             |               thp               |
 N      T  |   v3.11-rc3    |    patched     |   v3.11-rc3    |    patched     |
100    100 |  0.13 (+-0.04) |  0.07 (+-0.01) |  0.10 (+-0.01) |  0.08 (+-0.03) |
100   3000 | 11.67 (+-0.47) |  6.54 (+-0.38) | 11.21 (+-0.28) |  6.44 (+-0.26) |
6000   100 |  2.87 (+-0.07) |  2.79 (+-0.06) |  3.21 (+-0.06) |  3.10 (+-0.06) |
6000  3000 | 18.76 (+-0.50) | 13.68 (+-0.35) | 19.44 (+-0.78) | 14.03 (+-0.43) |

  * Numbers are the averages (and stddev) of 20 testing respectively.

This result shows that for both of hugetlb/thp patched kernel provides better
results, so patches works fine. The performance gain is larger for larger T.
Interestingly, in more detailed analysis the improvement mostly comes from 2).
I got a little improvement for 3), but no visible improvement for 1).

[1] http://thread.gmane.org/gmane.linux.kernel.mm/100856/focus=100858
[2] https://github.com/Naoya-Horiguchi/test_split_page_table_lock_for_hugepage

Naoya Horiguchi (2):
      hugetlbfs: support split page table lock
      thp: support split page table lock

 arch/powerpc/mm/hugetlbpage.c |   6 +-
 arch/powerpc/mm/pgtable_64.c  |   8 +-
 arch/s390/mm/pgtable.c        |   4 +-
 arch/sparc/mm/tlb.c           |   4 +-
 arch/tile/mm/hugetlbpage.c    |   6 +-
 fs/proc/task_mmu.c            |  17 +++--
 include/linux/huge_mm.h       |  11 +--
 include/linux/hugetlb.h       |  20 +++++
 include/linux/mm.h            |   3 +
 mm/huge_memory.c              | 170 +++++++++++++++++++++++++-----------------
 mm/hugetlb.c                  |  92 ++++++++++++++---------
 mm/memcontrol.c               |  14 ++--
 mm/memory.c                   |  15 ++--
 mm/mempolicy.c                |   5 +-
 mm/migrate.c                  |  12 +--
 mm/mprotect.c                 |   5 +-
 mm/pgtable-generic.c          |  10 +--
 mm/rmap.c                     |  13 ++--
 18 files changed, 251 insertions(+), 164 deletions(-)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
