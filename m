Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 336958E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:57:36 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w15so20276253qtk.19
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 23:57:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z54si1671979qtb.1.2019.01.20.23.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 23:57:34 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC 00/24] userfaultfd: write protection support
Date: Mon, 21 Jan 2019 15:56:58 +0800
Message-Id: <20190121075722.7945-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, peterx@redhat.com, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

Hi,

This series implements initial write protection support for
userfaultfd.  Currently both shmem and hugetlbfs are not supported
yet, but only anonymous memory.

To be simple, either "userfaultfd-wp" or "uffd-wp" might be used in
later paragraphs.

The whole series can also be found at:

  https://github.com/xzpeter/linux/tree/uffd-wp-merged

Any comment would be greatly welcomed.   Thanks.

Overview
====================

The uffd-wp work was initialized by Shaohua Li [1], and later
continued by Andrea [2]. This series is based upon Andrea's latest
userfaultfd tree, and it is a continuous works from both Shaohua and
Andrea.  Many of the follow up ideas come from Andrea too.

Besides the old MISSING register mode of userfaultfd, the new uffd-wp
support provides another alternative register mode called
UFFDIO_REGISTER_MODE_WP that can be used to listen to not only missing
page faults but also write protection page faults, or even they can be
registered together.  At the same time, the new feature also provides
a new userfaultfd ioctl called UFFDIO_WRITEPROTECT which allows the
userspace to write protect a range or memory or fixup write permission
of faulted pages.

Please refer to the document patch "userfaultfd: wp:
UFFDIO_REGISTER_MODE_WP documentation update" for more information on
the new interface and what it can do.

The major workflow of an uffd-wp program should be:

  1. Register a memory region with WP mode using UFFDIO_REGISTER_MODE_WP

  2. Write protect part of the whole registered region using
     UFFDIO_WRITEPROTECT, passing in UFFDIO_WRITEPROTECT_MODE_WP to
     show that we want to write protect the range.

  3. Start a working thread that modifies the protected pages,
     meanwhile listening to UFFD messages.

  4. When a write is detected upon the protected range, page fault
     happens, a UFFD message will be generated and reported to the
     page fault handling thread

  5. The page fault handler thread resolves the page fault using the
     new UFFDIO_WRITEPROTECT ioctl, but this time passing in
     !UFFDIO_WRITEPROTECT_MODE_WP instead showing that we want to
     recover the write permission.  Before this operation, the fault
     handler thread can do anything it wants, e.g., dumps the page to
     a persistent storage.

  6. The worker thread will continue running with the correctly
     applied write permission from step 5.

Currently there are already two projects that are based on this new
userfaultfd feature.

QEMU Live Snapshot: The project provides a way to allow the QEMU
                    hypervisor to take snapshot of VMs without
                    stopping the VM [3].

LLNL umap library:  The project provides a mmap-like interface and
                    "allow to have an application specific buffer of
                    pages cached from a large file, i.e. out-of-core
                    execution using memory map" [4][5].

Before posting the patchset, this series was smoke tested against QEMU
live snapshot and the LLNL umap library (by doing parallel quicksort
using 128 sorting threads + 80 uffd servicing threads).  My sincere
thanks to Marty Mcfadden and Denis Plotnikov for the help along the
way.

Implementation
==============

Patch 1-4: The whole uffd-wp requires the kernel page fault path to
           take more than one retries.  In the previous works starting
           from Shaohua, a new fault flag FAULT_FLAG_ALLOW_UFFD_RETRY
           was introduced for this [6]. However in this series we have
           dropped that patch, instead the whole work is based on the
           recent series "[PATCH RFC v3 0/4] mm: some enhancements to
           the page fault mechanism" [7] which removes the assuption
           that VM_FAULT_RETRY can only happen once.  This four
           patches are identital patches but picked up here.  Please
           refer to the cover letter [7] for more information.  More
           discussion upstream shows that this work could even benefit
           existing use case [8] so please help justify whether
           patches 1-4 can be consider to be accepted even earlier
           than the rest of the series.

Patch 5-21:   Implements the uffd-wp logic.  To avoid collision with
              existing write protections (e.g., an private anonymous
              page can be write protected if it was shared between
              multiple processes), a new PTE bit (_PAGE_UFFD_WP) was
              introduced to explicitly mark a PTE as userfault
              write-protected.  A similar bit was also used in the
              swap/migration entry (_PAGE_SWP_UFFD_WP) to make sure
              even if the pages were swapped or migrated, the uffd-wp
              tracking information won't be lost.  When resolving a
              page fault, we'll do a page copy before hand if the page
              was COWed to make sure we won't corrupt any shared
              pages.  Etc.  Please see separated patches for more
              details.

Patch 22:     Documentation update for uffd-wp

Patch 23,24:  Uffd-wp selftests

TODO
=============

- hugetlbfs/shmem support
- performance
- more architectures
- ...

References
==========

[1] https://lwn.net/Articles/666187/
[2] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/log/?h=userfault
[3] https://github.com/denis-plotnikov/qemu/commits/background-snapshot-kvm
[4] https://github.com/LLNL/umap
[5] https://llnl-umap.readthedocs.io/en/develop/
[6] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=b245ecf6cf59156966f3da6e6b674f6695a5ffa5
[7] https://lkml.org/lkml/2018/11/21/370
[8] https://lkml.org/lkml/2018/12/30/64

Andrea Arcangeli (5):
  userfaultfd: wp: add the writeprotect API to userfaultfd ioctl
  userfaultfd: wp: hook userfault handler to write protection fault
  userfaultfd: wp: add WP pagetable tracking to x86
  userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
  userfaultfd: wp: add UFFDIO_COPY_MODE_WP

Martin Cracauer (1):
  userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update

Peter Xu (15):
  mm: gup: rename "nonblocking" to "locked" where proper
  mm: userfault: return VM_FAULT_RETRY on signals
  mm: allow VM_FAULT_RETRY for multiple times
  mm: gup: allow VM_FAULT_RETRY for multiple times
  mm: merge parameters for change_protection()
  userfaultfd: wp: apply _PAGE_UFFD_WP bit
  mm: export wp_page_copy()
  userfaultfd: wp: handle COW properly for uffd-wp
  userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
  userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
  userfaultfd: wp: support swap and page migration
  userfaultfd: wp: don't wake up when doing write protect
  khugepaged: skip collapse if uffd-wp detected
  userfaultfd: selftests: refactor statistics
  userfaultfd: selftests: add write-protect test

Shaohua Li (3):
  userfaultfd: wp: add helper for writeprotect check
  userfaultfd: wp: support write protection for userfault vma range
  userfaultfd: wp: enabled write protection in userfaultfd API

 Documentation/admin-guide/mm/userfaultfd.rst |  51 +++++
 arch/alpha/mm/fault.c                        |   4 +-
 arch/arc/mm/fault.c                          |  12 +-
 arch/arm/mm/fault.c                          |  17 +-
 arch/arm64/mm/fault.c                        |  11 +-
 arch/hexagon/mm/vm_fault.c                   |   3 +-
 arch/ia64/mm/fault.c                         |   3 +-
 arch/m68k/mm/fault.c                         |   5 +-
 arch/microblaze/mm/fault.c                   |   3 +-
 arch/mips/mm/fault.c                         |   3 +-
 arch/nds32/mm/fault.c                        |   7 +-
 arch/nios2/mm/fault.c                        |   5 +-
 arch/openrisc/mm/fault.c                     |   3 +-
 arch/parisc/mm/fault.c                       |   4 +-
 arch/powerpc/mm/fault.c                      |   9 +-
 arch/riscv/mm/fault.c                        |   9 +-
 arch/s390/mm/fault.c                         |  14 +-
 arch/sh/mm/fault.c                           |   5 +-
 arch/sparc/mm/fault_32.c                     |   4 +-
 arch/sparc/mm/fault_64.c                     |   4 +-
 arch/um/kernel/trap.c                        |   6 +-
 arch/unicore32/mm/fault.c                    |  10 +-
 arch/x86/Kconfig                             |   1 +
 arch/x86/include/asm/pgtable.h               |  67 ++++++
 arch/x86/include/asm/pgtable_64.h            |   8 +-
 arch/x86/include/asm/pgtable_types.h         |  11 +-
 arch/x86/mm/fault.c                          |  13 +-
 arch/xtensa/mm/fault.c                       |   4 +-
 fs/userfaultfd.c                             | 110 +++++----
 include/asm-generic/pgtable.h                |   1 +
 include/asm-generic/pgtable_uffd.h           |  66 ++++++
 include/linux/huge_mm.h                      |   2 +-
 include/linux/mm.h                           |  21 +-
 include/linux/swapops.h                      |   2 +
 include/linux/userfaultfd_k.h                |  41 +++-
 include/trace/events/huge_memory.h           |   1 +
 include/uapi/linux/userfaultfd.h             |  28 ++-
 init/Kconfig                                 |   5 +
 mm/gup.c                                     |  61 ++---
 mm/huge_memory.c                             |  28 ++-
 mm/hugetlb.c                                 |   8 +-
 mm/khugepaged.c                              |  23 ++
 mm/memory.c                                  |  28 ++-
 mm/mempolicy.c                               |   2 +-
 mm/migrate.c                                 |   7 +
 mm/mprotect.c                                |  99 +++++++--
 mm/rmap.c                                    |   6 +
 mm/userfaultfd.c                             |  92 +++++++-
 tools/testing/selftests/vm/userfaultfd.c     | 222 ++++++++++++++-----
 49 files changed, 898 insertions(+), 251 deletions(-)
 create mode 100644 include/asm-generic/pgtable_uffd.h

-- 
2.17.1
