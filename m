Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD898280310
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:43:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w127so9184536pfd.5
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:43:21 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d6si8425069pgc.951.2017.08.22.03.43.19
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:43:20 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v7 0/9] arm64: Enable contiguous pte hugepage support
Date: Tue, 22 Aug 2017 11:42:40 +0100
Message-Id: <20170822104249.2189-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com

Hi,

This series re-enables contiguous hugepage support for arm64.

Changes in v7 -

* Patch 4 - "Add break-before-make logic for contiguous entries"
  - get_clear_flush() - unconditionally clear the ptes (even if they
    are not present). This is to bring huge_ptep_get_and_clear()
    in line with generic implementation.
  - get_clear_flush() - Only flush the TLBs if the cleared entry was
    valid.
  - huge_ptep_set_wrprotect() - simplified based on Catalin's
    feedback.

* Patch 6 - "Override huge_pte_clear() to support"
  - Address compile warnings due to non-existence of certain levels of
    the page table when using 16 and 64k pages.

All the dependent series ([2], [3]) for enabling contiguous hugepage
support have been merged in the previous cycle. Additionally, a patch
to clarify the semantics of huge_pte_offset() in generic code[6] is
currently in the -mm tree.

Previous postings can be found at [0], [1], [4], [5], [7].

The patches are based on v4.13-rc6. If there are no further comments
please consider merging for the next release cycle.

Thanks,
Punit

[0] https://www.spinics.net/lists/arm-kernel/msg570422.html
[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/497027.html
[2] https://www.spinics.net/lists/arm-kernel/msg581657.html
[3] https://www.spinics.net/lists/arm-kernel/msg583342.html
[4] https://www.spinics.net/lists/arm-kernel/msg583367.html
[5] https://www.spinics.net/lists/arm-kernel/msg582758.html
[6] https://lkml.org/lkml/2017/8/18/678
[7] https://www.spinics.net/lists/arm-kernel/msg597777.html
[8] http://www.spinics.net/lists/linux-mm/msg133176.html

Punit Agrawal (4):
  arm64: hugetlb: Handle swap entries in huge_pte_offset() for
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
 arch/arm64/mm/hugetlbpage.c      | 316 ++++++++++++++++++++++++++++-----------
 2 files changed, 240 insertions(+), 85 deletions(-)

-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
