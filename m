Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6235B6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:52 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 00/11] Support vrange for anonymous page
Date: Tue, 12 Mar 2013 16:38:24 +0900
Message-Id: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

First of all, let's define the term.
>From now on, I'd like to call it as vrange(a.k.a volatile range)
for anonymous page. If you have a better name in mind, please suggest.

This version is still *RFC* because it's just quick prototype so
it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
Before further sorting out issues, I'd like to post current direction
and discuss it. Of course, I'd like to extend this discussion in
comming LSF/MM.

In this version, I changed lots of thing, expecially removed vma-based
approach because it needs write-side lock for mmap_sem, which will drop
performance in mutli-threaded big SMP system, KOSAKI pointed out.
And vma-based approach is hard to meet requirement of new system call by
John Stultz's suggested semantic for consistent purged handling.
(http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)

I tested this patchset with modified jemalloc allocator which was
leaded by Jason Evans(jemalloc author) who was interest in this feature
and was happy to port his allocator to use new system call.
Super Thanks Jason!

The benchmark for test is ebizzy. It have been used for testing the
allocator performance so it's good for me. Again, thanks for recommending
the benchmark, Jason.
(http://people.freebsd.org/~kris/scaling/ebizzy.html)

The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)

	ebizzy -S 20

jemalloc-vanilla: 52389 records/sec
jemalloc-vrange: 203414 records/sec

	ebizzy -S 20 with background memory pressure

jemalloc-vanilla: 40746 records/sec
jemalloc-vrange: 174910 records/sec

And it's much improved on KVM virtual machine.

This patchset is based on v3.9-rc2

- What's the sys_vrange(addr, length, mode, behavior)?

  It's a hint that user deliver to kernel so kernel can *discard*
  pages in a range anytime. mode is one of VRANGE_VOLATILE and
  VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
  kernel coudn't discard any pages any more while VRANGE_VOLATILE
  is memory unpin opeartion so kernel can discard pages in vrange
  anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
  PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
  discard page in a vrange, please, discard all of pages in a
  vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
  that please discard of some pages in a vrange. But now I didn't
  implemented VRANGE_PARTIAL handling yet.

- What happens if user access page(ie, virtual address) discarded
  by kernel?

  The user can encounter SIGBUS.

- What should user do for avoding SIGBUS?
  He should call vrange(addr, length, VRANGE_NOVOLATILE, mode) before
  accessing the range which was called
  vrange(addr, length, VRANGE_VOLATILE, mode)

- What happens if user access page(ie, virtual address) doesn't
  discarded by kernel?

  The user can see vaild data which was there before calling
vrange(., VRANGE_VOLATILE) without page fault.

- What's different with madvise(DONTNEED)?

  System call semantic

  DONTNEED makes sure user always can see zero-fill pages after
  he calls madvise while vrange can see data or encounter SIGBUS.

  Internal implementation

  The madvise(DONTNEED) should zap all mapped pages in range so
  overhead is increased linearly with the number of mapped pages.
  Even, if user access zapped pages as write mode, page fault +
  page allocation + memset should be happened.

  The vrange just register a address range instead of zapping all of pte
  n the vma so it doesn't touch ptes any more.

- What's the benefit compared to DONTNEED?

  1. The system call overhead is smaller because vrange just registers
     a range using interval tree instead of zapping all the page in a range
     so overhead should be really cheap.

  2. It has a chance to eliminate overheads (ex, zapping pte + page fault
     + page allocation + memset(PAGE_SIZE)) if memory pressure isn't
     severe.

  3. It has a potential to zap all ptes and free the pages if memory
     pressure is severe so discard scanning overhead could be smaller - TODO

- What's for targetting?

  Firstly, user-space allocator like ptmalloc, jemalloc or heap management
  of virtual machine like Dalvik. Also, it comes in handy for embedded
  which doesn't have swap device so they can't reclaim anonymous pages.
  By discarding instead of swapout, it could be used in the non-swap system.

Changelog from v6 - There are many changes.
 * Remove vma-based approach
 * Change system call semantic
 * Add more meaningful experiment

Changelog from v5 - There are many changes.

 * Support CONFIG_VOLATILE_PAGE
 * Working with THP/KSM
 * Remove vma hacking logic in m[no]volatile system call
 * Discard page without swap cache
 * Kswapd discard volatile page so we can discard volatile pages
   although we don't have swap.

Changelog from v4

 * Add new system call mvolatile/mnovolatile
 * Add sigbus when user try to access volatile range
 * Rebased on v3.7
 * Applied bug fix from John Stultz, Thanks!

Changelog from v3

 * Removing madvise(addr, length, MADV_NOVOLATILE).
 * add vmstat about the number of discarded volatile pages
 * discard volatile pages without promotion in reclaim path

Minchan Kim (11):
  vrange: enable generic interval tree
  add vrange basic data structure and functions
  add new system call vrange(2)
  add proc/pid/vrange information
  Add purge operation
  send SIGBUS when user try to access purged page
  keep mm_struct to vrange when system call context
  add LRU handling for victim vrange
  Get rid of depenceny that all pages is from a zone in shrink_page_list
  Purging vrange pages without swap
  add purged page information in vmstat

 arch/x86/include/asm/pgtable_types.h   |   2 +
 arch/x86/syscalls/syscall_64.tbl       |   1 +
 fs/proc/base.c                         |   1 +
 fs/proc/internal.h                     |   6 +
 fs/proc/task_mmu.c                     | 129 ++++++
 include/asm-generic/pgtable.h          |  11 +
 include/linux/mm_types.h               |   5 +
 include/linux/rmap.h                   |  15 +-
 include/linux/swap.h                   |   1 +
 include/linux/vm_event_item.h          |   4 +
 include/linux/vrange.h                 |  59 +++
 include/uapi/asm-generic/mman-common.h |   5 +
 init/main.c                            |   2 +
 kernel/fork.c                          |   3 +
 lib/Makefile                           |   2 +-
 mm/Makefile                            |   2 +-
 mm/ksm.c                               |   2 +-
 mm/memory.c                            |  24 +-
 mm/rmap.c                              |  23 +-
 mm/swapfile.c                          |  36 ++
 mm/vmscan.c                            |  74 +++-
 mm/vmstat.c                            |   4 +
 mm/vrange.c                            | 754 +++++++++++++++++++++++++++++++++
 23 files changed, 1143 insertions(+), 22 deletions(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 mm/vrange.c

-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
