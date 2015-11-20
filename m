Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED8DE6B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:20:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so108179242pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 23:20:22 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id cv1si17707943pbb.202.2015.11.19.23.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 23:20:22 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so108178890pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 23:20:22 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by wrong reserve count
Date: Fri, 20 Nov 2015 16:20:17 +0900
Message-Id: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back to
alloc_buddy_huge_page() to directly create a hugepage from the buddy allocator.
In that case, however, if alloc_buddy_huge_page() succeeds we don't decrement
h->resv_huge_pages, which means that successful hugetlb_fault() returns without
releasing the reserve count. As a result, subsequent hugetlb_fault() might fail
despite that there are still free hugepages.

This patch simply adds decrementing code on that code path.

I reproduced this problem when testing v4.3 kernel in the following situation:
- the test machine/VM is a NUMA system,
- hugepage overcommiting is enabled,
- most of hugepages are allocated and there's only one free hugepage
  which is on node 0 (for example),
- another program, which calls set_mempolicy(MPOL_BIND) to bind itself to
  node 1, tries to allocate a hugepage,
- the allocation should fail but the reserve count is still hold.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org> [3.16+]
---
- the reason why I set stable target to "3.16+" is that this patch can be
  applied easily/automatically on these versions. But this bug seems to be
  old one, so if you are interested in backporting to older kernels,
  please let me know.
---
 mm/hugetlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git v4.3/mm/hugetlb.c v4.3_patched/mm/hugetlb.c
index 9cc7734..77c518c 100644
--- v4.3/mm/hugetlb.c
+++ v4.3_patched/mm/hugetlb.c
@@ -1790,7 +1790,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page)
 			goto out_uncharge_cgroup;
-
+		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
+			SetPagePrivate(page);
+			h->resv_huge_pages--;
+		}
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
 		/* Fall through */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
