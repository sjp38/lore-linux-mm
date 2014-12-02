Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 230CB6B006E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 03:38:09 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so12750872pde.33
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 00:38:08 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id d13si32428117pdk.227.2014.12.02.00.38.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 00:38:06 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id sB28c0qQ026757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 17:38:02 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/8] hugepage migration fixes (v5)
Date: Tue, 2 Dec 2014 08:26:38 +0000
Message-ID: <1417508759-10848-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi everyone,

This is ver.5 patchset for fixing hugepage migration's race problem.

In ver.4, Hugh enlighted me about the problem around pmd_huge(), where
pmd_huge() returned false for migration/hwpoison entry and we treated them
as normal pages. IOW, we didn't handle !pmd_present case properly.

So I added a new separate patch for this problem as patch 2/8, and I change=
d
patch "mm/hugetlb: take page table lock in follow_huge_pmd()" (3/8 in this
series) to handle non-present hugetlb case in follow_huge_pmd().

Other than that, changes in this version are minor ones like comment fix.

Can I beg your comments and reviews again?

Thanks,
Naoya Horiguchi
---
Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: mmotm-2014-11-26-15-45/fix_hugetlbfs_follow_page.v5

v2: http://thread.gmane.org/gmane.linux.kernel/1761065
v3: http://thread.gmane.org/gmane.linux.kernel/1776585
v4: http://thread.gmane.org/gmane.linux.kernel/1788215
---
Summary:

Naoya Horiguchi (8):
      mm/hugetlb: reduce arch dependent code around follow_huge_*
      mm/hugetlb: pmd_huge() returns true for non-present hugepage
      mm/hugetlb: take page table lock in follow_huge_pmd()
      mm/hugetlb: fix getting refcount 0 page in hugetlb_fault()
      mm/hugetlb: add migration/hwpoisoned entry check in hugetlb_change_pr=
otection
      mm/hugetlb: add migration entry check in __unmap_hugepage_range
      mm/hugetlb: fix suboptimal migration/hwpoisoned entry check
      mm/hugetlb: cleanup and rename is_hugetlb_entry_(migration|hwpoisoned=
)()

 arch/arm/mm/hugetlbpage.c     |   6 --
 arch/arm64/mm/hugetlbpage.c   |   6 --
 arch/ia64/mm/hugetlbpage.c    |   6 --
 arch/metag/mm/hugetlbpage.c   |   6 --
 arch/mips/mm/hugetlbpage.c    |  18 ----
 arch/powerpc/mm/hugetlbpage.c |   8 ++
 arch/s390/mm/hugetlbpage.c    |  20 -----
 arch/sh/mm/hugetlbpage.c      |  12 ---
 arch/sparc/mm/hugetlbpage.c   |  12 ---
 arch/tile/mm/hugetlbpage.c    |  28 ------
 arch/x86/mm/gup.c             |   2 +-
 arch/x86/mm/hugetlbpage.c     |  20 ++---
 include/linux/hugetlb.h       |   8 +-
 include/linux/swapops.h       |   4 +
 mm/gup.c                      |  25 ++----
 mm/hugetlb.c                  | 196 ++++++++++++++++++++++++++------------=
----
 mm/migrate.c                  |   5 +-
 17 files changed, 156 insertions(+), 226 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
