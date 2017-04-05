Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF0376B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:37:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l78so6695126pfb.10
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:37:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u12si20696900pfg.371.2017.04.05.06.37.35
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:37:35 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 0/9] Support swap entries for contiguous pte hugepages
Date: Wed,  5 Apr 2017 14:37:13 +0100
Message-Id: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, mark.rutland@arm.com

While trying to enable memory failure handling on arm64 I ran into few
issues resulting from the incorrect handling of contiguous pte
hugepages. When contiguous pte hugepage size is enabled, in certain
instances the architecture code does not have the necessary size
information required to manipulate the page table entries leaving the
page tables in an inconsistent state.

Since the previous postings[0][1], I've discovered a few more helpers
that need updating. The patchset can be grouped by related changes as-

* huge_pte_offset() - Patches 1-2
  - patch 1 adds a hugepage size parameter to huge_pte_offset() and
    updates callsites
  - patch 2 uses the hugepage size to find appropriate page table
    offset on arm64 (even if the pte contains a swap entry)
* huge_pte_clear() - Patches 3-4
  - patch 3 adds a size parameter to huge_pte_clear() and makes it a
    weak function to allow overriding by architecture *
    set_huge_pte_at()
  - override huge_pte_clear() for arm64 to clear multiple ptes for
    contiguous hugepages
* set_huge_pte_at() - Patches 5-7
  - introduces an alternate helper set_huge_swap_pte_at() which is to
    be used to put down swap huge ptes. Default implementation
    defaults to calling set_huge_pte_at()
  - update try_to_unmap_one() to use set_huge_swap_pte_at() when
    poisoning hugepages
  - override the set_huge_swap_pte_at() for arm64 to correctly deal
    with contiguous pte hugepages
* enable memory corruption - Patches 8-9
  - these patches enable memory corruption handling for arm64 and are
    included for completeness.
  
The patchset depends on a cleanup/fix series for contiguous pte
hugepages from Steve[2]. I've been using hwpoison testsuite from
mce-test[3] on arm64 hardware. Compile tested on s390 and x86.

All feedback welcome. As well, I'd appreciate input on structuring the
patchset to make it easier for merging.

Thanks,
Punit


v1 -> v2

* switch huge_pte_offset() to use size instead of hstate for
  consistency with the rest of the api
* Expand the series to address huge_pte_clear() and set_huge_pte_at()

RFC -> v1

* Fixed a missing conversion of huge_pte_offset() prototype to add
  hstate parameter. Reported by 0-day.

[0] https://lkml.org/lkml/2017/3/23/293
[1] https://lkml.org/lkml/2017/3/30/770
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/497027.html
[3] https://git.kernel.org/pub/scm/utils/cpu/mce/mce-test.git

Jonathan (Zhixiong) Zhang (2):
  arm64: hwpoison: add VM_FAULT_HWPOISON[_LARGE] handling
  arm64: kconfig: allow support for memory failure handling

Punit Agrawal (7):
  mm/hugetlb: add size parameter to huge_pte_offset()
  arm64: hugetlbpages: Support handling swap entries in
    huge_pte_offset()
  mm/hugetlb: Allow architectures to override huge_pte_clear()
  arm64: hugetlb: Override huge_pte_clear() to support contiguous
    hugepages
  mm/hugetlb: Introduce set_huge_swap_pte_at() helper
  arm64: hugetlb: Override set_huge_swap_pte_at() to support contiguous
    hugepages
  mm: rmap: Use correct helper when poisoning hugepages

 arch/arm64/Kconfig              |  1 +
 arch/arm64/mm/fault.c           | 22 ++++++++++++--
 arch/arm64/mm/hugetlbpage.c     | 66 +++++++++++++++++++++++++++++++----------
 arch/ia64/mm/hugetlbpage.c      |  4 +--
 arch/metag/mm/hugetlbpage.c     |  3 +-
 arch/mips/mm/hugetlbpage.c      |  3 +-
 arch/parisc/mm/hugetlbpage.c    |  3 +-
 arch/powerpc/mm/hugetlbpage.c   |  2 +-
 arch/s390/include/asm/hugetlb.h | 10 ++-----
 arch/s390/mm/hugetlbpage.c      | 12 +++++++-
 arch/sh/mm/hugetlbpage.c        |  3 +-
 arch/sparc/mm/hugetlbpage.c     |  3 +-
 arch/tile/mm/hugetlbpage.c      |  3 +-
 arch/x86/mm/hugetlbpage.c       |  2 +-
 drivers/acpi/apei/Kconfig       |  1 +
 fs/userfaultfd.c                |  7 +++--
 include/asm-generic/hugetlb.h   |  7 ++---
 include/linux/hugetlb.h         |  7 +++--
 mm/hugetlb.c                    | 45 ++++++++++++++++++++--------
 mm/page_vma_mapped.c            |  3 +-
 mm/pagewalk.c                   |  3 +-
 mm/rmap.c                       |  8 +++--
 22 files changed, 154 insertions(+), 64 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
