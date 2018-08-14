Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 164E36B0003
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 20:31:11 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id w11-v6so8713433uaj.20
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 17:31:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u186-v6si8316609vku.155.2018.08.13.17.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 17:31:09 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] mm: migration: fix migration of huge PMD shared pages
Date: Mon, 13 Aug 2018 17:30:58 -0700
Message-Id: <20180814003058.19732-1-mike.kravetz@oracle.com>
In-Reply-To: <201808131221.zDDttbc8%fengguang.wu@intel.com>
References: <201808131221.zDDttbc8%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>

The page migration code employs try_to_unmap() to try and unmap the
source page.  This is accomplished by using rmap_walk to find all
vmas where the page is mapped.  This search stops when page mapcount
is zero.  For shared PMD huge pages, the page map count is always 1
no matter the number of mappings.  Shared mappings are tracked via
the reference count of the PMD page.  Therefore, try_to_unmap stops
prematurely and does not completely unmap all mappings of the source
page.

This problem can result is data corruption as writes to the original
source page can happen after contents of the page are copied to the
target page.  Hence, data is lost.

This problem was originally seen as DB corruption of shared global
areas after a huge page was soft offlined due to ECC memory errors.
DB developers noticed they could reproduce the issue by (hotplug)
offlining memory used to back huge pages.  A simple testcase can
reproduce the problem by creating a shared PMD mapping (note that
this must be at least PUD_SIZE in size and PUD_SIZE aligned (1GB on
x86)), and using migrate_pages() to migrate process pages between
nodes while continually writing to the huge pages being migrated.

To fix, have the try_to_unmap_one routine check for huge PMD sharing
by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
shared mapping it will be 'unshared' which removes the page table
entry and drops the reference on the PMD page.  After this, flush
caches and TLB.

Fixes: 39dde65c9940 ("shared page table for hugetlb page")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
v2: Fixed build issue for !CONFIG_HUGETLB_PAGE and typos in comment

 include/linux/hugetlb.h |  6 ++++++
 mm/rmap.c               | 21 +++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..7524663028ec 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -170,6 +170,12 @@ static inline unsigned long hugetlb_total_pages(void)
 	return 0;
 }
 
+static inline int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr,
+					pte_t *ptep)
+{
+	return 0;
+}
+
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
diff --git a/mm/rmap.c b/mm/rmap.c
index 09a799c9aebd..cf2340adad10 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1409,6 +1409,27 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
 		address = pvmw.address;
 
+		/*
+		 * PMDs for hugetlbfs pages could be shared.  In this case,
+		 * pages with shared PMDs will have a mapcount of 1 no matter
+		 * how many times they are actually mapped.  Map counting for
+		 * PMD sharing is mostly done via the reference count on the
+		 * PMD page itself.  If the page we are trying to unmap is a
+		 * hugetlbfs page, attempt to 'unshare' at the PMD level.
+		 * huge_pmd_unshare clears the PUD and adjusts reference
+		 * counting on the PMD page which effectively unmaps the page.
+		 * Take care of flushing cache and TLB for page in this
+		 * specific mapping here.
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
