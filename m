Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3B96B00A0
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:41:03 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so4558293qae.36
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:41:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w106si4543187qgd.98.2014.09.15.15.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 15:41:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/5] hugepage migration fixes (v4)
Date: Mon, 15 Sep 2014 18:39:54 -0400
Message-Id: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This is the ver.4 of hugepage migration fix patchset.

Major changes from ver.3 are:
- to drop locking from follow_huge_pud() and follow_huge_addr() in patch 2,
  which was buggy and is not necessary now because they don't support FOLL_GET,
- follow_huge_pmd(FOLL_GET) can pin and return tail pages,
- and I fixed bugs accidentally introduced in patch 3 and 5.
Others are code improvements and comment/description fixes.

Two related topics (not included in this series but to be discussed/done)
- follow_huge_pmd() explicitly uses pmd_lockptr() instead of huge_pte_lock().
  This point shed light on the subtlety in huge_page_size == PMD_HUGE check
  in huge_pte_lockptr(). This seems to make no runtime problem now, but might
  look fragile for example when pmd is folded (where PUD_SIZE == PMD_SIZE)
  or when hugepage in your architecture is not bound by page table (where
  hugepage size happens to equal with PMD_SIZE.)
- code around is_hugetlb_entry_migration() and is_hugetlb_entry_hwpoisoned()
  is not beautiful or optimized. Cleanup is necessary.

This patchset is based on mmotm-2014-09-09-14-42 and shows no regression
in libhugetlbfs test.

Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: mmotm-2014-09-09-14-42/fix_follow_huge_pmd.v4

v2: http://thread.gmane.org/gmane.linux.kernel/1761065
v3: http://thread.gmane.org/gmane.linux.kernel/1776585
---
Summary:

Naoya Horiguchi (5):
      mm/hugetlb: reduce arch dependent code around follow_huge_*
      mm/hugetlb: take page table lock in follow_huge_pmd()
      mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
      mm/hugetlb: add migration/hwpoisoned entry check in hugetlb_change_protection
      mm/hugetlb: add migration entry check in __unmap_hugepage_range

 arch/arm/mm/hugetlbpage.c     |   6 --
 arch/arm64/mm/hugetlbpage.c   |   6 --
 arch/ia64/mm/hugetlbpage.c    |   6 --
 arch/metag/mm/hugetlbpage.c   |   6 --
 arch/mips/mm/hugetlbpage.c    |  18 ------
 arch/powerpc/mm/hugetlbpage.c |   8 +++
 arch/s390/mm/hugetlbpage.c    |  20 -------
 arch/sh/mm/hugetlbpage.c      |  12 ----
 arch/sparc/mm/hugetlbpage.c   |  12 ----
 arch/tile/mm/hugetlbpage.c    |  28 ----------
 arch/x86/mm/hugetlbpage.c     |  12 ----
 include/linux/hugetlb.h       |   8 +--
 mm/gup.c                      |  25 ++-------
 mm/hugetlb.c                  | 124 ++++++++++++++++++++++++++++--------------
 mm/migrate.c                  |   3 +-
 15 files changed, 101 insertions(+), 193 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
