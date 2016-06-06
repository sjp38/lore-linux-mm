Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50D506B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:50:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id w64so130403279iow.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:50:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l144si13643446ita.19.2016.06.06.10.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:50:04 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/6] hugetlb support for userfaultfd
Date: Mon,  6 Jun 2016 10:45:25 -0700
Message-Id: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

With fallcoate hole punch now supported by hugetlbfs, users of this
functionality would like to catch subsequent faults to holes.  The
use case is based on a database model where:
- Many tasks map the same huegtlbfs file to provide a large shared area
- One management task determines that part of this area is no longer used
  and releases the associated pages by fallocate hole punch
- It is an error if any of the tasks fault on the hole
userfaultfd can be used to catch faults to the holes, and the application
can take appropriate action.

This patch set replicates the functionality of the existing userfaultfd
routines __mcopy_atomic and mcopy_atomic_pte with modifications for huge
pages.  The register/unregister routines are modified to accept hugetlb
vma's and a hook is added to huge page fault handling.  The existing
selftest is modified to work with huge pages so that the new code can be
exercised and tested.

To test the code with selftest, this patch is required:
https://lkml.org/lkml/2016/5/31/782

Some issues to consider in the RFC
- Is hugetlb.c the best place for hugetlb_mcopy_atomic_pte?
- Is there a better way to handle mmap_sem locking on entry/exit
  to __mcopy_atomic_hugetlb?
- Is there a better way to do huge page alignment/sanity checking
  in the register/unregister routines?  Unfortunately, we do not
  know we are dealing with huge pages until looking at the vma's.
- userfaultfd for hugepmd does not support UFFDIO_ZEROPAGE as there
  is no zero page support for huge pages (except THP case).
- Should there be another config option?  Support is now provided
  if both userfaultfd and hugetlb are configured.
- This has only been tested on x86, but the code should be arch
  independent.

Mike Kravetz (6):
  mm/memory: add copy_huge_page_from_user for hugetlb userfaultfd
    support
  mm/hugetlb: add hugetlb_mcopy_atomic_pte for userfaultfd support
  mm/userfaultfd: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
  mm/hugetlb: add userfaultfd hugetlb hook
  fs/userfaultfd: allow registration of ranges containing huge pages
  selftests/userfaultfd: add userfaultfd_hugetlb test

 fs/userfaultfd.c                         |  69 +++++++++++-
 include/linux/hugetlb.h                  |   8 +-
 include/linux/mm.h                       |   3 +
 include/uapi/linux/userfaultfd.h         |   3 +
 mm/hugetlb.c                             | 102 ++++++++++++++++++
 mm/memory.c                              |  22 ++++
 mm/userfaultfd.c                         | 179 +++++++++++++++++++++++++++++++
 tools/testing/selftests/vm/Makefile      |   3 +
 tools/testing/selftests/vm/run_vmtests   |  13 +++
 tools/testing/selftests/vm/userfaultfd.c | 161 ++++++++++++++++++++++++---
 10 files changed, 540 insertions(+), 23 deletions(-)

-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
