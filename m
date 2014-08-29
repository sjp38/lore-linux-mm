Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0A26B003C
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 22:02:10 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so1569323qaj.21
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 19:02:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t6si8496343qak.85.2014.08.28.19.02.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Aug 2014 19:02:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/6] hugepage migration fixes (v3)
Date: Thu, 28 Aug 2014 21:38:54 -0400
Message-Id: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This is the ver.3 of hugepage migration fix patchset.

The original problem discussed with Hugh was that follow_huge_pmd(FOLL_GET)
looks to do get_page() without any locking (fixed in patch 2/6). However,
thorough testing showed that we have more fundamental issue on hugetlb_fault(),
where it suffers the race related to migration entry. This will be fixed in
patch 3/6.

And as a cosmetic/readability issue, currently follow_huge_(addr|pud|pmd) are
defined in common code or in arch-dependent code, depending on
CONFIG_ARCH_WANT_GENERAL_HUGETLB. But in reality, most architectures are doing
the same thing, so patch 1/6 cleans it up and leaves arch-dependent implementation
only if necessary, which decreases code by more than 100 lines.

Another point mentioned in the previous cycle is that we repeated fixing
migration entry issues again and again, which is inefficient considering
all such patches are backported to stable trees. So it's nice to completely
fix the similar problems at one time.
I researched the all code calling huge_pte_offset() and checked if !pte_present()
case is properly handled or not, and found that only 2 points missed it,
each of which is fixed in patch 4/6 and 5/6.
There are some non-trivial cases, so I put justifications for them below:
- mincore_hugetlb_page_range() determines present only by
  (ptep && !huge_pte_none()), but it's fine because we can consider migrating
  hugepage or hwpoisoned hugepage as in-memory.
- follow_huge_addr@arch/ia64/mm/hugetlbpage.c don't have to check pte_present,
  because ia64 doesn't support hugepage migration or hwpoison, so never sees
  migration entry.
- huge_pmd_share() is called only when pud_none() returns true, but then
  pmd is never migration/hwpoisoned entry.

Patch 6/6 is a just cleanup of an unused parameter.

This patchset is based on mmotm-2014-08-25-16-52 and shows no regression
in libhugetlbfs test.

I'd like to add Hugh's Suggested-by tags on patch 2 and 3 if he is OK,
because the solutions are mostly based on his idea.

Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: mmotm-2014-08-25-16-52/fix_follow_huge_pmd.v3

v2: http://thread.gmane.org/gmane.linux.kernel/1761065
---
Summary:

Naoya Horiguchi (6):
      mm/hugetlb: reduce arch dependent code around follow_huge_*
      mm/hugetlb: take page table lock in follow_huge_(addr|pmd|pud)()
      mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
      mm/hugetlb: add migration entry check in hugetlb_change_protection
      mm/hugetlb: add migration entry check in __unmap_hugepage_range
      mm/hugetlb: remove unused argument of follow_huge_addr()

 arch/arm/mm/hugetlbpage.c     |   6 --
 arch/arm64/mm/hugetlbpage.c   |   6 --
 arch/ia64/mm/hugetlbpage.c    |  17 +++---
 arch/metag/mm/hugetlbpage.c   |  10 +---
 arch/mips/mm/hugetlbpage.c    |  18 ------
 arch/powerpc/mm/hugetlbpage.c |  28 +++++----
 arch/s390/mm/hugetlbpage.c    |  20 -------
 arch/sh/mm/hugetlbpage.c      |  12 ----
 arch/sparc/mm/hugetlbpage.c   |  12 ----
 arch/tile/mm/hugetlbpage.c    |  28 ---------
 arch/x86/mm/hugetlbpage.c     |  14 +----
 include/linux/hugetlb.h       |  17 +++---
 mm/gup.c                      |  27 ++-------
 mm/hugetlb.c                  | 130 +++++++++++++++++++++++++++++-------------
 14 files changed, 131 insertions(+), 214 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
