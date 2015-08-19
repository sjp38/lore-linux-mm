Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3125F6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 05:22:02 -0400 (EDT)
Received: by pawq9 with SMTP id q9so56927791paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 02:22:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tl1si150627pac.65.2015.08.19.02.22.01
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 02:22:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/5] Fix compound_head() race
Date: Wed, 19 Aug 2015 12:21:41 +0300
Message-Id: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
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

v3:
   - Fix build without hugetlb;
   - Drop page->first_page;
   - Update comment for free_compound_page();
   - Use 'unsigned int' for page order;

v2: Per Hugh's suggestion page->compound_head is moved into third double
    word. This way we can avoid memory overhead which v1 had in some
    cases.

    This place in struct page is rather overloaded. More testing is
    required to make sure we don't collide with anyone.

Kirill A. Shutemov (5):
  mm: drop page->slab_page
  zsmalloc: use page->private instead of page->first_page
  mm: pack compound_dtor and compound_order into one word in struct page
  mm: make compound_head() robust
  mm: use 'unsigned int' for page order

 Documentation/vm/split_page_table_lock |  4 +-
 arch/xtensa/configs/iss_defconfig      |  1 -
 include/linux/mm.h                     | 82 +++++++++++-----------------------
 include/linux/mm_types.h               | 21 ++++++---
 include/linux/page-flags.h             | 80 ++++++++-------------------------
 mm/Kconfig                             | 12 -----
 mm/debug.c                             |  5 ---
 mm/huge_memory.c                       |  3 +-
 mm/hugetlb.c                           | 35 +++++++--------
 mm/internal.h                          |  8 ++--
 mm/memory-failure.c                    |  7 ---
 mm/page_alloc.c                        | 76 ++++++++++++++++++-------------
 mm/swap.c                              |  4 +-
 mm/zsmalloc.c                          | 11 +++--
 14 files changed, 133 insertions(+), 216 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
