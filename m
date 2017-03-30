Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1336B03AD
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:39:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o123so50680977pga.16
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:39:14 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t9si2613626pfa.157.2017.03.30.09.39.13
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 09:39:13 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH 0/4] Add hstate parameter to huge_pte_offset()
Date: Thu, 30 Mar 2017 17:38:45 +0100
Message-Id: <20170330163849.18402-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com

On architectures that support hugepages composed of contiguous pte(s)
as well as block entries at the same level in the page table,
huge_pte_offset() is not able to determine the correct offset to
return when it encounters a swap entry (which is used to mark poisoned
as well as migrated pages in the page table).

huge_pte_offset() needs to know the size of the hugepage at the
requested address to determine the offset to return - the current
entry or the first entry of a set of contiguous hugepages. This came
up while enabling support for memory failure handling on arm64 (Patch
3-4 add this support and are included here for completeness).

Patch 1 adds a hstate parameter to huge_pte_offset() to provide
additional information about the target address. It also updates the
signatures (and usage) of huge_pte_offset() for architectures that
override the generic implementation.

Patch 2 uses the size determined by the parameter added in Patch 1, to
return the correct page table offset in the arm64 implementation of
huge_pte_offset().

The patchset is based on top of v4.11-rc4 and the arm64 huge page
cleanup for break-before-make[0]. Previous posting can be found at
[1].

Changes RFC -> v1

* Fixed a missing conversion of huge_pte_offset() prototype to add
  hstate parameter. Reported by 0-day.

[0] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/497027.html
[1] https://lkml.org/lkml/2017/3/23/293


Jonathan (Zhixiong) Zhang (2):
  arm64: hwpoison: add VM_FAULT_HWPOISON[_LARGE] handling
  arm64: kconfig: allow support for memory failure handling

Punit Agrawal (2):
  mm/hugetlb.c: add hstate parameter to huge_pte_offset()
  arm64: hugetlbpages: Correctly handle swap entries in
    huge_pte_offset()

 arch/arm64/Kconfig            |  1 +
 arch/arm64/mm/fault.c         | 22 +++++++++++++++++++---
 arch/arm64/mm/hugetlbpage.c   | 34 ++++++++++++++++++----------------
 arch/ia64/mm/hugetlbpage.c    |  4 ++--
 arch/metag/mm/hugetlbpage.c   |  3 ++-
 arch/mips/mm/hugetlbpage.c    |  3 ++-
 arch/parisc/mm/hugetlbpage.c  |  3 ++-
 arch/powerpc/mm/hugetlbpage.c |  2 +-
 arch/s390/mm/hugetlbpage.c    |  3 ++-
 arch/sh/mm/hugetlbpage.c      |  3 ++-
 arch/sparc/mm/hugetlbpage.c   |  3 ++-
 arch/tile/mm/hugetlbpage.c    |  3 ++-
 arch/x86/mm/hugetlbpage.c     |  2 +-
 drivers/acpi/apei/Kconfig     |  1 +
 fs/userfaultfd.c              |  7 +++++--
 include/linux/hugetlb.h       |  5 +++--
 mm/hugetlb.c                  | 21 ++++++++++++---------
 mm/page_vma_mapped.c          |  3 ++-
 mm/pagewalk.c                 |  2 +-
 19 files changed, 80 insertions(+), 45 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
