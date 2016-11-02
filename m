Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 247746B0296
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d67so24805997qkc.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r32si1947692qte.1.2016.11.02.12.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/33] userfaultfd tmpfs/hugetlbfs/non-cooperative
Date: Wed,  2 Nov 2016 20:33:32 +0100
Message-Id: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

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

In addition there's a few related pending fixes and cleanups.

The "mm: mprotect: use pmd_trans_unstable instead of taking the
pmd_lock" patch is actually required for the WP support that will come
later, but it looks a nice cleanup + optimization for upstream too so
I'm sending it already.

Andrea Arcangeli (10):
  userfaultfd: document _IOR/_IOW
  userfaultfd: correct comment about UFFD_FEATURE_PAGEFAULT_FLAG_WP
  userfaultfd: convert BUG() to WARN_ON_ONCE()
  userfaultfd: use vma_is_anonymous
  userfaultfd: non-cooperative: report all available features to
    userland
  userfaultfd: non-cooperative: Add fork() event, build warning fix
  userfaultfd: shmem: add tlbflush.h header for microblaze
  userfaultfd: shmem: lock the page before adding it to pagecache
  userfaultfd: shmem: avoid leaking blocks and used blocks in
    UFFDIO_COPY
  mm: mprotect: use pmd_trans_unstable instead of taking the pmd_lock

Mike Kravetz (7):
  userfaultfd: hugetlbfs: add copy_huge_page_from_user for hugetlb
    userfaultfd support
  userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd
    support
  userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb for huge page
    UFFDIO_COPY
  userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
  userfaultfd: hugetlbfs: allow registration of ranges containing huge
    pages
  userfaultfd: hugetlbfs: add userfaultfd_hugetlb test
  userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges

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

 fs/userfaultfd.c                         | 445 +++++++++++++++++++++++++++++--
 include/linux/hugetlb.h                  |   8 +-
 include/linux/mm.h                       |  13 +
 include/linux/shmem_fs.h                 |  11 +
 include/linux/userfaultfd_k.h            |  42 +++
 include/uapi/asm-generic/ioctl.h         |  10 +-
 include/uapi/linux/userfaultfd.h         |  39 ++-
 kernel/fork.c                            |  10 +-
 mm/hugetlb.c                             | 114 ++++++++
 mm/madvise.c                             |   2 +
 mm/memory.c                              |  25 ++
 mm/mprotect.c                            |  44 ++-
 mm/mremap.c                              |  17 +-
 mm/shmem.c                               | 159 ++++++++++-
 mm/userfaultfd.c                         | 211 ++++++++++++++-
 tools/testing/selftests/vm/Makefile      |   8 +
 tools/testing/selftests/vm/run_vmtests   |  24 ++
 tools/testing/selftests/vm/userfaultfd.c | 405 +++++++++++++++++++++++++---
 18 files changed, 1453 insertions(+), 134 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
