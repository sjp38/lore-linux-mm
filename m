Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E1C0A6B0256
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 11:09:43 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so110515733pab.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 08:09:43 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id be4si25012193pbd.67.2015.08.17.08.09.42
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 08:09:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/4] Fix compound_head() race
Date: Mon, 17 Aug 2015 18:09:01 +0300
Message-Id: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's my attempt on fixing recently discovered race in compound_head().
It should make compound_head() reliable in all contexts.

The patchset is against Linus' tree. Let me know if it need to be rebased
onto different baseline.

It's expected to have conflicts with my page-flags patchset and probably
should be applied before it.

v2: Per Hugh's suggestion page->compound_head is moved into third double
    word. This way we can avoid memory overhead which v1 had in some
    cases.

    This place in struct page is rather overloaded. More testing is
    required to make sure we don't collide with anyone.

Kirill A. Shutemov (4):
  mm: drop page->slab_page
  zsmalloc: use page->private instead of page->first_page
  mm: pack compound_dtor and compound_order into one word in struct page
  mm: make compound_head() robust

 Documentation/vm/split_page_table_lock |  4 +-
 arch/xtensa/configs/iss_defconfig      |  1 -
 include/linux/mm.h                     | 75 +++++++++----------------------
 include/linux/mm_types.h               | 20 ++++++---
 include/linux/page-flags.h             | 80 ++++++++--------------------------
 mm/Kconfig                             | 12 -----
 mm/debug.c                             |  5 ---
 mm/huge_memory.c                       |  3 +-
 mm/hugetlb.c                           | 16 +++----
 mm/internal.h                          |  4 +-
 mm/memory-failure.c                    |  7 ---
 mm/page_alloc.c                        | 37 ++++++++++------
 mm/swap.c                              |  4 +-
 mm/zsmalloc.c                          | 11 +++--
 14 files changed, 94 insertions(+), 185 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
