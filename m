Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 590526B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 09:11:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e131so193773894pfh.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 06:11:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d90si24827884pfm.216.2017.05.24.06.11.37
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 06:11:37 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 0/9] arm64: Enable contiguous pte hugepage support
Date: Wed, 24 May 2017 14:11:13 +0100
Message-Id: <20170524131122.5309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-arm-kernel@lists.infradead.org, steve.capper@arm.com, mark.rutland@arm.com, linux-mm@kvack.org

Hi,

This patchset addresses all the known issues with contiguous hugetlb
pages. Support for contiguous hugepages is useful on systems where the
PMD hugepage size is too large (512MB hugepage when using 64k page
granule) and contiguous hugepages can be used to provide reasonable
hugepage sizes to the user.

The patches can be split as 

* Patches 1-3, 9 cleanups and improvements

* Patch 4 addresses the break-before-make requirement of the
  architecture for contiguous hugepages. These patches depend on
  enabling memory failure handling on arm64[2].

* Patch 5-7 add support for handling swap entries for contiguous pte
  hugepages. These patches depend on fixes to core code required to
  support contiguous hugepages[3].

* Patch 8 enables contiguous hugepage support for arm64

The patches are based on v4.12-rc2. Previous postings can be found at
[0], [1].

All feedback welcome.

Thanks,
Punit

[0] https://www.spinics.net/lists/arm-kernel/msg570422.html
[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/497027.html
[2] https://www.spinics.net/lists/arm-kernel/msg581657.html
[3] https://www.spinics.net/lists/arm-kernel/msg583342.html

Changes v3 -> v4
* Moved Patches 2 and 4 to [3] due to dependencies

Changes v2 -> v3
* Rebased on v4.12-rc2
* Included swap related fixes in this series
* Enable contiguous pte hugepages

Changes v1 -> v2:
* Marked patch 2 for stable
* Fixed comment issues in patch 7
* Added tags

Punit Agrawal (4):
  arm64: hugetlbpages: Handle swap entries in huge_pte_offset() for
    contiguous hugepages
  arm64: hugetlb: Override huge_pte_clear() to support contiguous
    hugepages
  arm64: hugetlb: Override set_huge_swap_pte_at() to support contiguous
    hugepages
  arm64: Re-enable support for contiguous hugepages

Steve Capper (5):
  arm64: hugetlb: set_huge_pte_at Add WARN_ON on !pte_present
  arm64: hugetlb: Introduce pte_pgprot helper
  arm64: hugetlb: Spring clean huge pte accessors
  arm64: hugetlb: Add break-before-make logic for contiguous entries
  arm64: hugetlb: Cleanup setup_hugepagesz

 arch/arm64/include/asm/hugetlb.h |   9 +-
 arch/arm64/mm/hugetlbpage.c      | 287 ++++++++++++++++++++++++++++-----------
 2 files changed, 213 insertions(+), 83 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
