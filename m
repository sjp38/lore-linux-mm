Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f179.google.com (mail-yw0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id D230A6B0288
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:10:17 -0400 (EDT)
Received: by mail-yw0-f179.google.com with SMTP id i84so26353203ywc.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:10:17 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id s10si8325242ywb.88.2016.04.05.14.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:10:16 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id bx7so1848979pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:10:16 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:10:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 00/31] huge tmpfs: THPagecache implemented by teams
Message-ID: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here is my "huge tmpfs" implementation of Transparent Huge Pagecache,
rebased to v4.6-rc2 plus the "mm: easy preliminaries to THPagecache"
series.

The design is just the same as before, when I posted against v3.19:
using a team of pagecache pages placed within a huge-order extent,
instead of using a compound page (see 04/31 for more info on that).

Patches 01-17 are much as before, but with whatever changes were
needed for the rebase, and bugfixes folded back in.  Patches 18-22
add memcg and smaps visibility.  But the more important ones are
patches 23-29, which add recovery: reassembling a hugepage after
fragmentation or swapping.  Patches 30-31 reflect gfpmask doubts:
you might prefer that I fold 31 back in and keep 30 internal.

It was lack of recovery which stopped me from proposing inclusion
of the series a year ago: this series now is fully featured, and
ready for v4.7 - but I expect we shall want to wait a release to
give time to consider the alternatives.

I currently believe that the same functionality (including the
team implementation's support for small files, standard mlocking,
and recovery) can be achieved with compound pages, but not easily:
I think the huge tmpfs functionality should be made available soon,
then converted at leisure to compound pages, if that works out (but
it's not a job I want to do - what we have here is good enough).

Huge tmpfs has been in use within Google for about a year: it's
been a success, and gaining ever wider adoption.  Several TODOs
have not yet been toDONE, because they just haven't surfaced as
real-life issues yet: that includes NUMA migration, which is at
the top of my list, but so far we've done well enough without it.

01 huge tmpfs: prepare counts in meminfo, vmstat and SysRq-m
02 huge tmpfs: include shmem freeholes in available memory
03 huge tmpfs: huge=N mount option and /proc/sys/vm/shmem_huge
04 huge tmpfs: try to allocate huge pages, split into a team
05 huge tmpfs: avoid team pages in a few places
06 huge tmpfs: shrinker to migrate and free underused holes
07 huge tmpfs: get_unmapped_area align & fault supply huge page
08 huge tmpfs: try_to_unmap_one use page_check_address_transhuge
09 huge tmpfs: avoid premature exposure of new pagetable
10 huge tmpfs: map shmem by huge page pmd or by page team ptes
11 huge tmpfs: disband split huge pmds on race or memory failure
12 huge tmpfs: extend get_user_pages_fast to shmem pmd
13 huge tmpfs: use Unevictable lru with variable hpage_nr_pages
14 huge tmpfs: fix Mlocked meminfo, track huge & unhuge mlocks
15 huge tmpfs: fix Mapped meminfo, track huge & unhuge mappings
16 kvm: plumb return of hva when resolving page fault.
17 kvm: teach kvm to map page teams as huge pages.
18 huge tmpfs: mem_cgroup move charge on shmem huge pages
19 huge tmpfs: mem_cgroup shmem_pmdmapped accounting
20 huge tmpfs: mem_cgroup shmem_hugepages accounting
21 huge tmpfs: show page team flag in pageflags
22 huge tmpfs: /proc/<pid>/smaps show ShmemHugePages
23 huge tmpfs recovery: framework for reconstituting huge pages
24 huge tmpfs recovery: shmem_recovery_populate to fill huge page
25 huge tmpfs recovery: shmem_recovery_remap & remap_team_by_pmd
26 huge tmpfs recovery: shmem_recovery_swapin to read from swap
27 huge tmpfs recovery: tweak shmem_getpage_gfp to fill team
28 huge tmpfs recovery: debugfs stats to complete this phase
29 huge tmpfs recovery: page migration call back into shmem
30 huge tmpfs: shmem_huge_gfpmask and shmem_recovery_gfpmask
31 huge tmpfs: no kswapd by default on sync allocations

 Documentation/cgroup-v1/memory.txt     |    2 
 Documentation/filesystems/proc.txt     |   20 
 Documentation/filesystems/tmpfs.txt    |  106 +
 Documentation/sysctl/vm.txt            |   46 
 Documentation/vm/pagemap.txt           |    2 
 Documentation/vm/transhuge.txt         |   38 
 Documentation/vm/unevictable-lru.txt   |   15 
 arch/mips/mm/gup.c                     |   15 
 arch/s390/mm/gup.c                     |   19 
 arch/sparc/mm/gup.c                    |   19 
 arch/x86/kvm/mmu.c                     |  150 +
 arch/x86/kvm/paging_tmpl.h             |    6 
 arch/x86/mm/gup.c                      |   15 
 drivers/base/node.c                    |   20 
 drivers/char/mem.c                     |   23 
 fs/proc/meminfo.c                      |   11 
 fs/proc/page.c                         |    6 
 fs/proc/task_mmu.c                     |   28 
 include/linux/huge_mm.h                |   14 
 include/linux/kvm_host.h               |    2 
 include/linux/memcontrol.h             |   17 
 include/linux/migrate.h                |    2 
 include/linux/migrate_mode.h           |    2 
 include/linux/mm.h                     |    3 
 include/linux/mm_types.h               |    1 
 include/linux/mmzone.h                 |    5 
 include/linux/page-flags.h             |   10 
 include/linux/shmem_fs.h               |   29 
 include/trace/events/migrate.h         |    7 
 include/trace/events/mmflags.h         |    7 
 include/uapi/linux/kernel-page-flags.h |    3 
 ipc/shm.c                              |    6 
 kernel/sysctl.c                        |   33 
 mm/compaction.c                        |    5 
 mm/filemap.c                           |   10 
 mm/gup.c                               |   19 
 mm/huge_memory.c                       |  363 +++-
 mm/internal.h                          |   26 
 mm/memcontrol.c                        |  187 +-
 mm/memory-failure.c                    |    7 
 mm/memory.c                            |  225 +-
 mm/mempolicy.c                         |   13 
 mm/migrate.c                           |   37 
 mm/mlock.c                             |  183 +-
 mm/mmap.c                              |   16 
 mm/page-writeback.c                    |    2 
 mm/page_alloc.c                        |   55 
 mm/rmap.c                              |  129 -
 mm/shmem.c                             | 2066 ++++++++++++++++++++++-
 mm/swap.c                              |    5 
 mm/truncate.c                          |    2 
 mm/util.c                              |    1 
 mm/vmscan.c                            |   47 
 mm/vmstat.c                            |    3 
 tools/vm/page-types.c                  |    2 
 virt/kvm/kvm_main.c                    |   14 
 56 files changed, 3627 insertions(+), 472 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
