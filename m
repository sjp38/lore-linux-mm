Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAE66B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 01:48:10 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so48083238pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 22:48:10 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [125.16.236.4])
        by mx.google.com with ESMTPS id ua9si9410597pab.25.2016.04.06.22.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 22:48:09 -0700 (PDT)
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 7 Apr 2016 11:07:54 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u375c64E19136846
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:08:07 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u375biSC005961
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:07:48 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 00/10] Enable HugeTLB page migration on POWER
Date: Thu,  7 Apr 2016 11:07:34 +0530
Message-Id: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

This patch series enables HugeTLB page migration on POWER platform.
This series has some core VM changes (patch 1, 2, 3) and some powerpc
specific changes (patch 4, 5, 6, 7, 8, 9, 10). Comments, suggestions
and inputs are welcome.

Anshuman Khandual (10):
  mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK inside mmap_pgoff
  mm/hugetlb: Add PGD based implementation awareness
  mm/hugetlb: Protect follow_huge_(pud|pgd) functions from race
  powerpc/hugetlb: Add ABI defines for MAP_HUGE_16MB and MAP_HUGE_16GB
  powerpc/hugetlb: Split the function 'huge_pte_alloc'
  powerpc/hugetlb: Split the function 'huge_pte_offset'
  powerpc/hugetlb: Prepare arch functions for ARCH_WANT_GENERAL_HUGETLB
  powerpc/hugetlb: Selectively enable ARCH_WANT_GENERAL_HUGETLB
  powerpc/hugetlb: Selectively enable ARCH_ENABLE_HUGEPAGE_MIGRATION
  selfttest/powerpc: Add memory page migration tests

 arch/powerpc/Kconfig                               |   8 +
 arch/powerpc/include/asm/book3s/64/hash-64k.h      |  10 +
 arch/powerpc/include/uapi/asm/mman.h               |   3 +
 arch/powerpc/mm/hugetlbpage.c                      |  60 +++---
 include/linux/hugetlb.h                            |   3 +
 include/linux/mm.h                                 |  33 ++++
 mm/gup.c                                           |   6 +
 mm/hugetlb.c                                       |  75 +++++++-
 mm/mmap.c                                          |   2 +-
 tools/testing/selftests/powerpc/mm/Makefile        |  14 +-
 .../selftests/powerpc/mm/hugepage-migration.c      |  30 +++
 tools/testing/selftests/powerpc/mm/migration.h     | 205 +++++++++++++++++++++
 .../testing/selftests/powerpc/mm/page-migration.c  |  33 ++++
 tools/testing/selftests/powerpc/mm/run_mmtests     | 104 +++++++++++
 14 files changed, 552 insertions(+), 34 deletions(-)
 create mode 100644 tools/testing/selftests/powerpc/mm/hugepage-migration.c
 create mode 100644 tools/testing/selftests/powerpc/mm/migration.h
 create mode 100644 tools/testing/selftests/powerpc/mm/page-migration.c
 create mode 100755 tools/testing/selftests/powerpc/mm/run_mmtests

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
