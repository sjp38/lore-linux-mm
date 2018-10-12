Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D91CD6B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 00:00:27 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id o204-v6so7561130oif.10
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 21:00:27 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w26si8931351otl.265.2018.10.11.21.00.26
        for <linux-mm@kvack.org>;
        Thu, 11 Oct 2018 21:00:26 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH V2 0/5] arm64/mm: Enable HugeTLB migration
Date: Fri, 12 Oct 2018 09:29:54 +0530
Message-Id: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

This patch series enables HugeTLB migration support for all supported
huge page sizes at all levels including contiguous bit implementation.
Following HugeTLB migration support matrix has been enabled with this
patch series. All permutations have been tested except for the 16GB.

         CONT PTE    PMD    CONT PMD    PUD
         --------    ---    --------    ---
4K:         64K     2M         32M     1G
16K:         2M    32M          1G
64K:         2M   512M         16G

First the series adds migration support for PUD based huge pages. It
then adds a platform specific hook to query an architecture if a
given huge page size is supported for migration while also providing
a default fallback option preserving the existing semantics which just
checks for (PMD|PUD|PGDIR)_SHIFT macros. The last two patches enables
HugeTLB migration on arm64 and subscribe to this new platform specific
hook by defining an override.

The second patch differentiates between movability and migratability
aspects of huge pages and implements hugepage_movable_supported() which
can then be used during allocation to decide whether to place the huge
page in movable zone or not.

Changes in V2:

- Added a new patch which differentiates migratability and movability
  of huge pages and implements hugepage_movable_supported() function
  as suggested by Michal Hocko.

Anshuman Khandual (5):
  mm/hugetlb: Enable PUD level huge page migration
  mm/hugetlb: Distinguish between migratability and movability
  mm/hugetlb: Enable arch specific huge page size support for migration
  arm64/mm: Enable HugeTLB migration
  arm64/mm: Enable HugeTLB migration for contiguous bit HugeTLB pages

 arch/arm64/Kconfig               |  4 ++++
 arch/arm64/include/asm/hugetlb.h |  5 +++++
 arch/arm64/mm/hugetlbpage.c      | 20 +++++++++++++++++
 include/linux/hugetlb.h          | 48 +++++++++++++++++++++++++++++++++++++---
 mm/hugetlb.c                     |  2 +-
 5 files changed, 75 insertions(+), 4 deletions(-)

-- 
2.7.4
