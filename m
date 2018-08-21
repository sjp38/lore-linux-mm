Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7BF6B20AF
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:59:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n23-v6so3355367qkn.19
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:59:16 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b3-v6si12671152qvm.158.2018.08.21.13.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 13:59:15 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared pages
Date: Tue, 21 Aug 2018 13:59:01 -0700
Message-Id: <20180821205902.21223-2-mike.kravetz@oracle.com>
In-Reply-To: <20180821205902.21223-1-mike.kravetz@oracle.com>
References: <20180821205902.21223-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

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

mmu notifiers are called before locking page tables, but we can not
be sure of PMD sharing until page tables are locked.  Therefore,
check for the possibility of PMD sharing before locking so that
notifiers can prepare for the worst possible case.

Fixes: 39dde65c9940 ("shared page table for hugetlb page")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 14 ++++++++++++++
 mm/hugetlb.c            | 40 +++++++++++++++++++++++++++++++++++++++
 mm/rmap.c               | 42 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 93 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..1c6cde68487f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -140,6 +140,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
+bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pd(struct vm_area_struct *vma,
@@ -170,6 +172,18 @@ static inline unsigned long hugetlb_total_pages(void)
 	return 0;
 }
 
+static inline int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr,
+					pte_t *ptep)
+{
+	return 0;
+}
+
+bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end)
+{
+	return false;
+}
+
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3103099f64fd..fd155dc52117 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4555,6 +4555,9 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 
 	/*
 	 * check on proper vm_flags and page table alignment
+	 *
+	 * Note that this is the same check used in huge_pmd_sharing_possible.
+	 * If you change one, consider changing both.
 	 */
 	if (vma->vm_flags & VM_MAYSHARE &&
 	    vma->vm_start <= base && end <= vma->vm_end)
@@ -4562,6 +4565,43 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 	return false;
 }
 
+/*
+ * Determine if start,end range within vma could be mapped by shared pmd.
+ * If yes, adjust start and end to cover range associated with possible
+ * shared pmd mappings.
+ */
+bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end)
+{
+	unsigned long check_addr = *start;
+	bool ret = false;
+
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		return ret;
+
+	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
+		unsigned long a_start = check_addr & PUD_MASK;
+		unsigned long a_end = a_start + PUD_SIZE;
+
+		/*
+		 * If sharing is possible, adjust start/end if necessary.
+		 *
+		 * Note that this is the same check used in vma_shareable.  If
+		 * you change one, consider changing both.
+		 */
+		if (vma->vm_start <= a_start && a_end <= vma->vm_end) {
+			if (a_start < *start)
+				*start = a_start;
+			if (a_end > *end)
+				*end = a_end;
+
+			ret = true;
+		}
+	}
+
+	return ret;
+}
+
 /*
  * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
  * and returns the corresponding pte. While this is not necessary for the
diff --git a/mm/rmap.c b/mm/rmap.c
index eb477809a5c0..8cf853a4b093 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1362,11 +1362,21 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	/*
-	 * We have to assume the worse case ie pmd for invalidation. Note that
-	 * the page can not be free in this function as call of try_to_unmap()
-	 * must hold a reference on the page.
+	 * For THP, we have to assume the worse case ie pmd for invalidation.
+	 * For hugetlb, it could be much worse if we need to do pud
+	 * invalidation in the case of pmd sharing.
+	 *
+	 * Note that the page can not be free in this function as call of
+	 * try_to_unmap() must hold a reference on the page.
 	 */
 	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
+	if (PageHuge(page)) {
+		/*
+		 * If sharing is possible, start and end will be adjusted
+		 * accordingly.
+		 */
+		(void)huge_pmd_sharing_possible(vma, &start, &end);
+	}
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
 		address = pvmw.address;
 
+		if (PageHuge(page)) {
+			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
+				/*
+				 * huge_pmd_unshare unmapped an entire PMD
+				 * page.  There is no way of knowing exactly
+				 * which PMDs may be cached for this mm, so
+				 * we must flush them all.  start/end were
+				 * already adjusted above to cover this range.
+				 */
+				flush_cache_range(vma, start, end);
+				flush_tlb_range(vma, start, end);
+				mmu_notifier_invalidate_range(mm, start, end);
+
+				/*
+				 * The ref count of the PMD page was dropped
+				 * which is part of the way map counting
+				 * is done for shared PMDs.  Return 'true'
+				 * here.  When there is no other sharing,
+				 * huge_pmd_unshare returns false and we will
+				 * unmap the actual page and drop map count
+				 * to zero.
+				 */
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
+		}
 
 		if (IS_ENABLED(CONFIG_MIGRATION) &&
 		    (flags & TTU_MIGRATION) &&
-- 
2.17.1
