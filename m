Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B57BC6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:28:56 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so173630864pac.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:28:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id if3si29135855pbc.192.2015.09.15.03.28.55
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 03:28:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 0/7] Fix compound_head() race
Date: Tue, 15 Sep 2015 13:28:08 +0300
Message-Id: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's my attempt on fixing race in compound_head(). It should make
compound_head() reliable in all contexts.

The last patch is optional.

It applies cleanly into mmotm patchstack just before my page-flags
patchset.

As expected, it causes few conflicts with patches:

 page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
 mm-sanitize-page-mapping-for-tail-pages.patch
 include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch

Updated patches with solved conflicts can be found here:

 http://marc.info/?l=linux-kernel&m=144007388303804&q=p4
 http://marc.info/?l=linux-kernel&m=144007388303804&q=p5
 http://marc.info/?l=linux-kernel&m=144007388303804&q=p3

v6:
   - cosmetic-only changes based on feedback form Vlastimil Babka
     and Alexander Duyck;
   - More Ackes/Reviewed-by;

v5:
   - Fix collision with hugetlb_cgroup (see updated patch description in
     patch 5/7);

v4:
   - init page->lru on init_reserved_page() for
     DEFERRED_STRUCT_PAGE_INIT=n;
   - fix zsmalloc breakage (repored by Sergey Senozhatsky);
   - move #ifdef CONFIG_64BIT into separate patch;
   - enum compound_dtor_id;
   - move pmd_huge_pte to other word to avoid conflict with compound_head;
   - compile-time LIST_POISON1 sanity check;
   - few cleanups around page->rcu_head;

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

Kirill A. Shutemov (7):
  mm: drop page->slab_page
  slab, slub: use page->rcu_head instead of page->lru plus cast
  zsmalloc: use page->private instead of page->first_page
  mm: pack compound_dtor and compound_order into one word in struct page
  mm: make compound_head() robust
  mm: use 'unsigned int' for page order
  mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT

 Documentation/vm/split_page_table_lock |  4 +-
 arch/xtensa/configs/iss_defconfig      |  1 -
 include/linux/hugetlb_cgroup.h         |  4 +-
 include/linux/mm.h                     | 82 ++++++++++-----------------------
 include/linux/mm_types.h               | 40 ++++++++++++----
 include/linux/page-flags.h             | 80 ++++++++------------------------
 mm/Kconfig                             | 12 -----
 mm/debug.c                             |  5 --
 mm/huge_memory.c                       |  3 +-
 mm/hugetlb.c                           | 35 +++++++-------
 mm/hugetlb_cgroup.c                    |  2 +-
 mm/internal.h                          |  8 ++--
 mm/memory-failure.c                    |  7 ---
 mm/page_alloc.c                        | 84 ++++++++++++++++++++++------------
 mm/slab.c                              | 17 ++-----
 mm/slub.c                              |  5 +-
 mm/swap.c                              |  4 +-
 mm/zsmalloc.c                          | 11 ++---
 18 files changed, 165 insertions(+), 239 deletions(-)

-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
