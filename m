Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEECC6B30E1
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 14:08:35 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y130-v6so8434436qka.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:08:35 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z24-v6si192355qtq.37.2018.08.24.11.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 11:08:34 -0700 (PDT)
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
Date: Fri, 24 Aug 2018 11:08:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180824084157.GD29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/24/2018 01:41 AM, Michal Hocko wrote:
> On Thu 23-08-18 13:59:16, Mike Kravetz wrote:
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> One nit below.
> 
> [...]
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 3103099f64fd..a73c5728e961 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4548,6 +4548,9 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>>  	return saddr;
>>  }
>>  
>> +#define _range_in_vma(vma, start, end) \
>> +	((vma)->vm_start <= (start) && (end) <= (vma)->vm_end)
>> +
> 
> static inline please. Macros and potential side effects on given
> arguments are just not worth the risk. I also think this is something
> for more general use. We have that pattern at many places. So I would
> stick that to linux/mm.h

Thanks Michal,

Here is an updated patch which does as you suggest above.

-- 
Mike Kravetz

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 24 Aug 2018 10:58:20 -0700
Subject: [PATCH v7 1/2] mm: migration: fix migration of huge PMD shared pages

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
 include/linux/mm.h      |  6 ++++++
 mm/hugetlb.c            | 37 ++++++++++++++++++++++++++++++++++--
 mm/rmap.c               | 42 ++++++++++++++++++++++++++++++++++++++---
 4 files changed, 94 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..4ee95d8c8413 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -140,6 +140,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 pte_t *huge_pte_offset(struct mm_struct *mm,
 		       unsigned long addr, unsigned long sz);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
+void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
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
+static inline void adjust_range_if_pmd_sharing_possible(
+				struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end)
+{
+}
+
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 68a5121694ef..40ad93bc9548 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2463,6 +2463,12 @@ static inline struct vm_area_struct *find_exact_vma(struct mm_struct *mm,
 	return vma;
 }
 
+static inline bool range_in_vma(struct vm_area_struct *vma,
+				unsigned long start, unsigned long end)
+{
+	return (vma && vma->vm_start <= start && end <= vma->vm_end);
+}
+
 #ifdef CONFIG_MMU
 pgprot_t vm_get_page_prot(unsigned long vm_flags);
 void vma_set_page_prot(struct vm_area_struct *vma);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3103099f64fd..f469315a6a0f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4556,12 +4556,40 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 	/*
 	 * check on proper vm_flags and page table alignment
 	 */
-	if (vma->vm_flags & VM_MAYSHARE &&
-	    vma->vm_start <= base && end <= vma->vm_end)
+	if (vma->vm_flags & VM_MAYSHARE && range_in_vma(vma, base, end))
 		return true;
 	return false;
 }
 
+/*
+ * Determine if start,end range within vma could be mapped by shared pmd.
+ * If yes, adjust start and end to cover range associated with possible
+ * shared pmd mappings.
+ */
+void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end)
+{
+	unsigned long check_addr = *start;
+
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		return;
+
+	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
+		unsigned long a_start = check_addr & PUD_MASK;
+		unsigned long a_end = a_start + PUD_SIZE;
+
+		/*
+		 * If sharing is possible, adjust start/end if necessary.
+		 */
+		if (range_in_vma(vma, a_start, a_end)) {
+			if (a_start < *start)
+				*start = a_start;
+			if (a_end > *end)
+				*end = a_end;
+		}
+	}
+}
+
 /*
  * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
  * and returns the corresponding pte. While this is not necessary for the
@@ -4659,6 +4687,11 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 {
 	return 0;
 }
+
+void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
+				unsigned long *start, unsigned long *end)
+{
+}
 #define want_pmd_share()	(0)
 #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
 
diff --git a/mm/rmap.c b/mm/rmap.c
index eb477809a5c0..1e79fac3186b 100644
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
+		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
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
