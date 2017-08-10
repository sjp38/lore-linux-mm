Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAF16B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:09:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o82so12710544pfj.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:09:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x10si4711477plm.860.2017.08.10.10.09.54
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 10:09:54 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v6 0/9] arm64: Enable contiguous pte hugepage support
Date: Thu, 10 Aug 2017 18:08:57 +0100
Message-Id: <20170810170906.30772-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com

Hi,

This series re-enables contiguous hugepage support for arm64. In v6,
I've addressed all the concerns raised on the previous version.

Notable changes in this version -

* Patch 4 - "Add break-before-make logic for contiguous entries"
  - added clear_flush() and use it in set_huge_pte_at()
  - Updated huge_ptep_clear_flush() to use clear_flush()
  - Track dirty bit based on returned value from get_clear_flush() in
    huge_ptep_set_access_flags()
  - Dropped Mark's reviewed-by (please re-apply if you're still happy
    with the patch)

All the dependent series ([2], [3]) for enabling contiguous hugepage
support have been merged in the previous cycle. Additionally, a patch
to clarify the semantics of huge_pte_offset() in generic code[6] is
currently in the -mm tree.

Previous postings can be found at [0], [1], [4], [5], [7].

The patches are based on v4.13-rc4. If there are no further comments
please consider merging for the next release cycle.

Thanks,
Punit

[0] https://www.spinics.net/lists/arm-kernel/msg570422.html
[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/497027.html
[2] https://www.spinics.net/lists/arm-kernel/msg581657.html
[3] https://www.spinics.net/lists/arm-kernel/msg583342.html
[4] https://www.spinics.net/lists/arm-kernel/msg583367.html
[5] https://www.spinics.net/lists/arm-kernel/msg582758.html
[6] https://lkml.org/lkml/2017/7/25/536
[7] https://www.spinics.net/lists/arm-kernel/msg597777.html

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
 arch/arm64/mm/hugetlbpage.c      | 310 ++++++++++++++++++++++++++++-----------
 2 files changed, 236 insertions(+), 83 deletions(-)

-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
