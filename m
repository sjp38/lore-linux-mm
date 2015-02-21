Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 72B5A6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 22:49:26 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so11991786pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:49:25 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id oq4si5844473pbb.10.2015.02.20.19.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 19:49:25 -0800 (PST)
Received: by pdbnh10 with SMTP id nh10so11919911pdb.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:49:25 -0800 (PST)
Date: Fri, 20 Feb 2015 19:49:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 00/24] huge tmpfs: an alternative approach to THPageCache
Message-ID: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I warned last month that I have been working on "huge tmpfs":
an implementation of Transparent Huge Page Cache in tmpfs,
for those who are tired of the limitations of hugetlbfs.

Here's a fully working patchset, against v3.19 so that you can give it
a try against a stable base.  I've not yet studied how well it applies
to current git: probably lots of easily resolved clashes with nonlinear
removal.  Against mmotm, the rmap.c differences looked nontrivial.

Fully working?  Well, at present page migration just keeps away from
these teams of pages.  And once memory pressure has disbanded a team
to swap it out, there is nothing to put it together again later on,
to restore the original hugepage performance.  Those must follow,
but no thought yet (khugepaged? maybe).

Yes, I realize there's nothing yet under Documentation, nor fs/proc
beyond meminfo, nor other debug/visibility files: must follow, but
I've cared more to provide the basic functionality.

I don't expect to update this patchset in the next few weeks: now that
it's posted, my priority is look at other people's work before LSF/MM;
and in particular, of course, your (Kirill's) THP refcounting redesign.

01 mm: update_lru_size warn and reset bad lru_size
02 mm: update_lru_size do the __mod_zone_page_state
03 mm: use __SetPageSwapBacked and don't ClearPageSwapBacked
04 mm: make page migration's newpage handling more robust
05 tmpfs: preliminary minor tidyups
06 huge tmpfs: prepare counts in meminfo, vmstat and SysRq-m
07 huge tmpfs: include shmem freeholes in available memory counts
08 huge tmpfs: prepare huge=N mount option and /proc/sys/vm/shmem_huge
09 huge tmpfs: try to allocate huge pages, split into a team
10 huge tmpfs: avoid team pages in a few places
11 huge tmpfs: shrinker to migrate and free underused holes
12 huge tmpfs: get_unmapped_area align and fault supply huge page
13 huge tmpfs: extend get_user_pages_fast to shmem pmd
14 huge tmpfs: extend vma_adjust_trans_huge to shmem pmd
15 huge tmpfs: rework page_referenced_one and try_to_unmap_one
16 huge tmpfs: fix problems from premature exposure of pagetable
17 huge tmpfs: map shmem by huge page pmd or by page team ptes
18 huge tmpfs: mmap_sem is unlocked when truncation splits huge pmd
19 huge tmpfs: disband split huge pmds on race or memory failure
20 huge tmpfs: use Unevictable lru with variable hpage_nr_pages()
21 huge tmpfs: fix Mlocked meminfo, tracking huge and unhuge mlocks
22 huge tmpfs: fix Mapped meminfo, tracking huge and unhuge mappings
23 kvm: plumb return of hva when resolving page fault.
24 kvm: teach kvm to map page teams as huge pages.

 arch/mips/mm/gup.c             |   17 
 arch/powerpc/mm/pgtable_64.c   |    7 
 arch/s390/mm/gup.c             |   22 
 arch/sparc/mm/gup.c            |   22 
 arch/x86/kvm/mmu.c             |  171 +++-
 arch/x86/kvm/paging_tmpl.h     |    6 
 arch/x86/mm/gup.c              |   17 
 drivers/base/node.c            |   20 
 drivers/char/mem.c             |   23 
 fs/proc/meminfo.c              |   17 
 include/linux/huge_mm.h        |   18 
 include/linux/kvm_host.h       |    2 
 include/linux/memcontrol.h     |   11 
 include/linux/mempolicy.h      |    6 
 include/linux/migrate.h        |    3 
 include/linux/mm.h             |   95 +-
 include/linux/mm_inline.h      |   24 
 include/linux/mm_types.h       |    1 
 include/linux/mmzone.h         |    5 
 include/linux/page-flags.h     |    6 
 include/linux/pageteam.h       |  289 +++++++
 include/linux/shmem_fs.h       |   21 
 include/trace/events/migrate.h |    3 
 ipc/shm.c                      |    6 
 kernel/sysctl.c                |   12 
 mm/balloon_compaction.c        |   10 
 mm/compaction.c                |    6 
 mm/filemap.c                   |   10 
 mm/gup.c                       |   22 
 mm/huge_memory.c               |  281 ++++++-
 mm/internal.h                  |   25 
 mm/memcontrol.c                |   42 -
 mm/memory-failure.c            |    8 
 mm/memory.c                    |  227 +++--
 mm/migrate.c                   |  139 +--
 mm/mlock.c                     |  181 ++--
 mm/mmap.c                      |   17 
 mm/page-writeback.c            |    2 
 mm/page_alloc.c                |   13 
 mm/rmap.c                      |  207 +++--
 mm/shmem.c                     | 1235 +++++++++++++++++++++++++++++--
 mm/swap.c                      |    5 
 mm/swap_state.c                |    3 
 mm/truncate.c                  |    2 
 mm/vmscan.c                    |   76 +
 mm/vmstat.c                    |    3 
 mm/zswap.c                     |    3 
 virt/kvm/kvm_main.c            |   24 
 48 files changed, 2790 insertions(+), 575 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
