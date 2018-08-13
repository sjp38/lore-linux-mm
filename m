Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF256B0005
	for <linux-mm@kvack.org>; Sun, 12 Aug 2018 23:41:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x204-v6so15866104qka.6
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 20:41:40 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k1-v6si3268942qkc.104.2018.08.12.20.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Aug 2018 20:41:39 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm: migration: fix migration of huge PMD shared pages
Date: Sun, 12 Aug 2018 20:41:08 -0700
Message-Id: <20180813034108.27269-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

The page migration code employs try_to_unmap() to try and unmap the
source page.  This is accomplished by using rmap_walk to find all
vmas where the page is mapped.  This search stops when page mapcount
is zero.  For shared PMD huge pages, the page map count is always 1
not matter the number of mappings.  Shared mappings are tracked via
the reference count of the PMD page.  Therefore, try_to_unmap stops
prematurely and does not completely unmap all mappings of the source
page.

This problem can result is data corruption as writes to the original
source page can happen after contents of the page are copied to the
target page.  Hence, data is lost.

This problem was originally seen as DB corruption of shared global
areas after a huge page was soft offlined.  DB developers noticed
they could reproduce the issue by (hotplug) offlining memory used
to back huge pages.  A simple testcase can reproduce the problem by
creating a shared PMD mapping (note that this must be at least
PUD_SIZE in size and PUD_SIZE aligned (1GB on x86)), and using
migrate_pages() to migrate process pages between nodes.

To fix, have the try_to_unmap_one routine check for huge PMD sharing
by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
shared mapping it will be 'unshared' which removes the page table
entry and drops reference on PMD page.  After this, flush caches and
TLB.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
I am not %100 sure on the required flushing, so suggestions would be
appreciated.  This also should go to stable.  It has been around for
a long time so still looking for an appropriate 'fixes:'.

 mm/rmap.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index 09a799c9aebd..45583758bf16 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1409,6 +1409,27 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
 		address = pvmw.address;
 
+		/*
+		 * PMDs for hugetlbfs pages could be shared.  In this case,
+		 * pages with shared PMDs will have a mapcount of 1 no matter
+		 * how many times it is actually mapped.  Map counting for
+		 * PMD sharing is mostly done via the reference count on the
+		 * PMD page itself.  If the page we are trying to unmap is a
+		 * hugetlbfs page, attempt to 'unshare' at the PMD level.
+		 * huge_pmd_unshare takes care of clearing the PUD and
+		 * reference counting on the PMD page which effectively unmaps
+		 * the page.  Take care of flushing cache and TLB for page in
+		 * this specific mapping here.
+		 */
+		if (PageHuge(page) &&
+		    huge_pmd_unshare(mm, &address, pvmw.pte)) {
+			unsigned long end_add = address + vma_mmu_pagesize(vma);
+
+			flush_cache_range(vma, address, end_add);
+			flush_tlb_range(vma, address, end_add);
+			mmu_notifier_invalidate_range(mm, address, end_add);
+			continue;
+		}
 
 		if (IS_ENABLED(CONFIG_MIGRATION) &&
 		    (flags & TTU_MIGRATION) &&
-- 
2.17.1
