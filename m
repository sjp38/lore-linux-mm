Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C12C86B0266
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:25 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so21188731itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 11si6150848iob.187.2016.12.16.06.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:24 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/42] userfaultfd tmpfs/hugetlbfs/non-cooperative v2
Date: Fri, 16 Dec 2016 15:47:39 +0100
Message-Id: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello,

these userfaultfd features are finished and are ready for larger
exposure in -mm and upstream merging.

1) tmpfs non present userfault
2) hugetlbfs non present userfault
3) non cooperative userfault for fork/madvise/mremap

qemu development code is already exercising 2) and container postcopy
live migration needs 3).

1) is not currently used but there's a self test and we know some qemu
user for various reasons uses tmpfs as backing for KVM so it'll need
it too to use postcopy live migration with tmpfs memory.

All review feedback from the previous submit has been handled and the
fixes are included. There's no outstanding issue AFIK.

Upstream code just did a s/fe/vmf/ conversion in the page faults and
this has been converted as well incrementally.

In addition to the previous submits, this also wakes up stuck
userfaults during UFFDIO_UNREGISTER. The non cooperative testcase
actually reproduced this problem by getting stuck instead of quitting
clean in some rare case as it could call UFFDIO_UNREGISTER while some
userfault could be still in flight. The other option would have been
to keep leaving it up to userland to serialize itself and to patch the
testcase instead but the wakeup during unregister I think is
preferable.

David also asked the UFFD_FEATURE_MISSING_HUGETLBFS and
UFFD_FEATURE_MISSING_SHMEM feature flags to be added so QEMU can avoid
to probe if the hugetlbfs/shmem missing support is available by
calling UFFDIO_REGISTER. QEMU already checks HUGETLBFS_MAGIC with
fstatfs so if UFFD_FEATURE_MISSING_HUGETLBFS is also set, it knows
UFFDIO_REGISTER will succeed (or if it fails, it's for some other more
concerning reason). There's no reason to worry about adding too many
feature flags. There are 64 available and worst case we've to bump the
API if someday we're really going to run out of them.

The round-trip network latency of hugetlbfs userfaults during postcopy
live migration is still of the order of dozen milliseconds on 10GBit
if at 2MB hugepage granularity so it's working perfectly and it should
provide for higher bandwidth or lower CPU usage (which makes it
interesting to add an option in the future to support THP granularity
too for anonymous memory, UFFDIO_COPY would then have to create THP if
alignment/len allows for it). 1GB hugetlbfs granularity will require
big changes in hugetlbfs to work so it's deferred for later.

Andrea Arcangeli (17):
  userfaultfd: document _IOR/_IOW
  userfaultfd: correct comment about UFFD_FEATURE_PAGEFAULT_FLAG_WP
  userfaultfd: convert BUG() to WARN_ON_ONCE()
  userfaultfd: use vma_is_anonymous
  userfaultfd: non-cooperative: report all available features to
    userland
  userfaultfd: non-cooperative: Add fork() event, build warning fix
  userfaultfd: non-cooperative: optimize mremap_userfaultfd_complete()
  userfaultfd: non-cooperative: avoid MADV_DONTNEED race condition
  userfaultfd: non-cooperative: wake userfaults after UFFDIO_UNREGISTER
  userfaultfd: hugetlbfs: gup: support VM_FAULT_RETRY
  userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_HUGETLBFS
  userfaultfd: shmem: add tlbflush.h header for microblaze
  userfaultfd: shmem: lock the page before adding it to pagecache
  userfaultfd: shmem: avoid leaking blocks and used blocks in
    UFFDIO_COPY
  userfaultfd: hugetlbfs: UFFD_FEATURE_MISSING_SHMEM
  userfaultfd: selftest: test UFFDIO_ZEROPAGE on all memory types
  mm: mprotect: use pmd_trans_unstable instead of taking the pmd_lock

Mike Kravetz (9):
  userfaultfd: hugetlbfs: add copy_huge_page_from_user for hugetlb
    userfaultfd support
  userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd
    support
  userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page
    UFFDIO_COPY
  userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error
    processing
  userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
  userfaultfd: hugetlbfs: allow registration of ranges containing huge
    pages
  userfaultfd: hugetlbfs: add userfaultfd_hugetlb test
  userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges
  userfaultfd: hugetlbfs: reserve count on error in
    __mcopy_atomic_hugetlb

Mike Rapoport (11):
  userfaultfd: non-cooperative: dup_userfaultfd: use mm_count instead of
    mm_users
  userfaultfd: introduce vma_can_userfault
  userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
  userfaultfd: shmem: introduce vma_is_shmem
  userfaultfd: shmem: use shmem_mcopy_atomic_pte for shared memory
  userfaultfd: shmem: add userfaultfd hook for shared memory faults
  userfaultfd: shmem: allow registration of shared memory ranges
  userfaultfd: shmem: add userfaultfd_shmem test
  userfaultfd: non-cooperative: selftest: introduce userfaultfd_open
  userfaultfd: non-cooperative: selftest: add ufd parameter to copy_page
  userfaultfd: non-cooperative: selftest: add test for FORK,
    MADVDONTNEED and REMAP events

Pavel Emelyanov (5):
  userfaultfd: non-cooperative: Split the find_userfault() routine
  userfaultfd: non-cooperative: Add ability to report non-PF events from
    uffd descriptor
  userfaultfd: non-cooperative: Add fork() event
  userfaultfd: non-cooperative: Add mremap() event
  userfaultfd: non-cooperative: Add madvise() event for MADV_DONTNEED
    request

 fs/userfaultfd.c                         | 461 +++++++++++++++++++++++++++--
 include/linux/hugetlb.h                  |  12 +-
 include/linux/mm.h                       |  14 +
 include/linux/shmem_fs.h                 |  11 +
 include/linux/userfaultfd_k.h            |  42 +++
 include/uapi/asm-generic/ioctl.h         |  10 +-
 include/uapi/linux/userfaultfd.h         |  67 ++++-
 kernel/fork.c                            |  10 +-
 mm/gup.c                                 |   2 +-
 mm/hugetlb.c                             | 162 ++++++++++-
 mm/madvise.c                             |   2 +
 mm/memory.c                              |  32 ++
 mm/mprotect.c                            |  44 +--
 mm/mremap.c                              |  17 +-
 mm/shmem.c                               | 147 +++++++++-
 mm/userfaultfd.c                         | 235 ++++++++++++++-
 tools/testing/selftests/vm/Makefile      |   8 +
 tools/testing/selftests/vm/run_vmtests   |  24 ++
 tools/testing/selftests/vm/userfaultfd.c | 486 ++++++++++++++++++++++++++++---
 19 files changed, 1641 insertions(+), 145 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
