Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 792426B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:34 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so29255346igb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id er5si3802589pad.227.2015.03.19.10.08.33
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail pages
Date: Thu, 19 Mar 2015 19:08:06 +0200
Message-Id: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently we take naive approach to page flags on compound -- we set the
flag on the page without consideration if the flag makes sense for tail
page or for compound page in general. This patchset try to sort this out
by defining per-flag policy on what need to be done if page-flag helper
operate on compound page.

The last patch in patchset also sanitize usege of page->mapping for tail
pages. We don't define meaning of page->mapping for tail pages. Currently
it's always NULL, which can be inconsistent with head page and potentially
lead to problems.

For now I catched one case of illigal usage of page flags or ->mapping:
sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
It leads to setting dirty bit on tail pages and access to tail_page's
->mapping. I don't see any bad behaviour caused by this, but worth fixing
anyway.

This patchset makes more sense if you take my THP refcounting into
account: we will see more compound pages mapped with PTEs and we need to
define behaviour of flags on compound pages to avoid bugs.

Kirill A. Shutemov (16):
  mm: consolidate all page-flags helpers in <linux/page-flags.h>
  page-flags: trivial cleanup for PageTrans* helpers
  page-flags: introduce page flags policies wrt compound pages
  page-flags: define PG_locked behavior on compound pages
  page-flags: define behavior of FS/IO-related flags on compound pages
  page-flags: define behavior of LRU-related flags on compound pages
  page-flags: define behavior SL*B-related flags on compound pages
  page-flags: define behavior of Xen-related flags on compound pages
  page-flags: define PG_reserved behavior on compound pages
  page-flags: define PG_swapbacked behavior on compound pages
  page-flags: define PG_swapcache behavior on compound pages
  page-flags: define PG_mlocked behavior on compound pages
  page-flags: define PG_uncached behavior on compound pages
  page-flags: define PG_uptodate behavior on compound pages
  page-flags: look on head page if the flag is encoded in page->mapping
  mm: sanitize page->mapping for tail pages

 fs/cifs/file.c             |   8 +-
 include/linux/hugetlb.h    |   7 -
 include/linux/ksm.h        |  17 ---
 include/linux/mm.h         | 122 +----------------
 include/linux/page-flags.h | 317 ++++++++++++++++++++++++++++++++++-----------
 include/linux/pagemap.h    |  25 ++--
 include/linux/poison.h     |   4 +
 mm/filemap.c               |  15 ++-
 mm/huge_memory.c           |   2 +-
 mm/ksm.c                   |   2 +-
 mm/memory-failure.c        |   2 +-
 mm/memory.c                |   2 +-
 mm/migrate.c               |   2 +-
 mm/page_alloc.c            |   7 +
 mm/shmem.c                 |   4 +-
 mm/slub.c                  |   2 +
 mm/swap_state.c            |   4 +-
 mm/util.c                  |   5 +-
 mm/vmscan.c                |   4 +-
 mm/zswap.c                 |   4 +-
 20 files changed, 294 insertions(+), 261 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
