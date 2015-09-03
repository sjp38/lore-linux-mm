Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1F02E6B0264
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:14:02 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so49518666pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:14:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pe7si19111930pbb.152.2015.09.03.08.13.52
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:13:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 07/36] thp, mlock: do not allow huge pages in mlocked area
Date: Thu,  3 Sep 2015 18:12:53 +0300
Message-Id: <1441293202-137314-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting THP can belong to several VMAs. This makes tricky
to track THP pages, when they partially mlocked. It can lead to leaking
mlocked pages to non-VM_LOCKED vmas and other problems.

With this patch we will split all pages on mlock and avoid
fault-in/collapse new THP in VM_LOCKED vmas.

I've tried alternative approach: do not mark THP pages mlocked and keep
them on normal LRUs. This way vmscan could try to split huge pages on
memory pressure and free up subpages which doesn't belong to VM_LOCKED
vmas.  But this is user-visible change: we screw up Mlocked accouting
reported in meminfo, so I had to leave this approach aside.

We can bring something better later, but this should be good enough for
now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/gup.c         |  3 ++-
 mm/huge_memory.c |  5 ++++-
 mm/memory.c      |  3 ++-
 mm/mlock.c       | 51 +++++++++++++++++++--------------------------------
 4 files changed, 27 insertions(+), 35 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6880085d3790..20fa606b4e76 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -927,7 +927,8 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
 		gup_flags &= ~FOLL_POPULATE;
-
+	if (vma->vm_flags & VM_LOCKED)
+		gup_flags |= FOLL_SPLIT;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 18931b8ef1e7..304c7d2825eb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -815,6 +815,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
+	if (vma->vm_flags & VM_LOCKED)
+		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
@@ -2541,7 +2543,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
-
+	if (vma->vm_flags & VM_LOCKED)
+		return false;
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
diff --git a/mm/memory.c b/mm/memory.c
index 56ae7fd1ef37..4814f6706ced 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2161,7 +2161,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	pte_unmap_unlock(page_table, ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	if (old_page) {
+	/* THP pages are never mlocked */
+	if (old_page && !PageTransCompound(old_page)) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
diff --git a/mm/mlock.c b/mm/mlock.c
index c0ac9f58b139..8314cd3eee87 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -443,39 +443,26 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
 				&page_mask);
 
-		if (page && !IS_ERR(page)) {
-			if (PageTransHuge(page)) {
-				lock_page(page);
-				/*
-				 * Any THP page found by follow_page_mask() may
-				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
-				 */
-				page_mask = munlock_vma_page(page);
-				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
-			} else {
-				/*
-				 * Non-huge pages are handled in batches via
-				 * pagevec. The pin from follow_page_mask()
-				 * prevents them from collapsing by THP.
-				 */
-				pagevec_add(&pvec, page);
-				zone = page_zone(page);
-				zoneid = page_zone_id(page);
+		if (page && !IS_ERR(page) && !PageTransCompound(page)) {
+			/*
+			 * Non-huge pages are handled in batches via
+			 * pagevec. The pin from follow_page_mask()
+			 * prevents them from collapsing by THP.
+			 */
+			pagevec_add(&pvec, page);
+			zone = page_zone(page);
+			zoneid = page_zone_id(page);
 
-				/*
-				 * Try to fill the rest of pagevec using fast
-				 * pte walk. This will also update start to
-				 * the next page to process. Then munlock the
-				 * pagevec.
-				 */
-				start = __munlock_pagevec_fill(&pvec, vma,
-						zoneid, start, end);
-				__munlock_pagevec(&pvec, zone);
-				goto next;
-			}
+			/*
+			 * Try to fill the rest of pagevec using fast
+			 * pte walk. This will also update start to
+			 * the next page to process. Then munlock the
+			 * pagevec.
+			 */
+			start = __munlock_pagevec_fill(&pvec, vma,
+					zoneid, start, end);
+			__munlock_pagevec(&pvec, zone);
+			goto next;
 		}
 		/* It's a bug to munlock in the middle of a THP page */
 		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
