Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6544C6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:35:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z6so1625396pgu.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 01:35:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k33-v6si3081206pld.100.2018.04.19.01.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 01:35:28 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2] mm, gup: prevent pmd checking race in follow_pmd_mask()
Date: Thu, 19 Apr 2018 16:35:14 +0800
Message-Id: <20180419083514.1365-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

mmap_sem will be read locked when calling follow_pmd_mask().  But this
cannot prevent PMD from being changed for all cases when PTL is
unlocked, for example, from pmd_trans_huge() to pmd_none() via
MADV_DONTNEED.  So it is possible for the pmd_present() check in
follow_pmd_mask() encounter a none PMD.  This may cause incorrect
VM_BUG_ON() or infinite loop.  Fixed this via reading PMD entry into a
local variable with READ_ONCE() and checking the local variable and
pmd_none() in the retry loop.

As Kirill pointed out, with PTL unlocked, the *pmd may be changed
under us, so read it directly again and again may incur weird bugs.
So although using *pmd directly other than pmd_present() checking may
be safe, it is still better to replace them to read *pmd once and
check the local variable for multiple times.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
 # When PTL unlocked, replace all *pmd with local variable
Suggested-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>

V2:

- Added some code comments for why use READ_ONCE() and check pmd_none().
---
 mm/gup.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 76af4cfeaf68..111e97900136 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -212,53 +212,69 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 				    unsigned long address, pud_t *pudp,
 				    unsigned int flags, unsigned int *page_mask)
 {
-	pmd_t *pmd;
+	pmd_t *pmd, pmdval;
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
 	pmd = pmd_offset(pudp, address);
-	if (pmd_none(*pmd))
+	/*
+	 * The READ_ONCE() will stabilize the pmdval in a register or
+	 * on the stack so that it will stop changing under the code.
+	 */
+	pmdval = READ_ONCE(*pmd);
+	if (pmd_none(pmdval))
 		return no_page_table(vma, flags);
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
+	if (pmd_huge(pmdval) && vma->vm_flags & VM_HUGETLB) {
 		page = follow_huge_pmd(mm, address, pmd, flags);
 		if (page)
 			return page;
 		return no_page_table(vma, flags);
 	}
-	if (is_hugepd(__hugepd(pmd_val(*pmd)))) {
+	if (is_hugepd(__hugepd(pmd_val(pmdval)))) {
 		page = follow_huge_pd(vma, address,
-				      __hugepd(pmd_val(*pmd)), flags,
+				      __hugepd(pmd_val(pmdval)), flags,
 				      PMD_SHIFT);
 		if (page)
 			return page;
 		return no_page_table(vma, flags);
 	}
 retry:
-	if (!pmd_present(*pmd)) {
+	if (!pmd_present(pmdval)) {
 		if (likely(!(flags & FOLL_MIGRATION)))
 			return no_page_table(vma, flags);
 		VM_BUG_ON(thp_migration_supported() &&
-				  !is_pmd_migration_entry(*pmd));
-		if (is_pmd_migration_entry(*pmd))
+				  !is_pmd_migration_entry(pmdval));
+		if (is_pmd_migration_entry(pmdval))
 			pmd_migration_entry_wait(mm, pmd);
+		pmdval = READ_ONCE(*pmd);
+		/*
+		 * MADV_DONTNEED may convert the pmd to null because
+		 * mmap_sem is held in read mode
+		 */
+		if (pmd_none(pmdval))
+			return no_page_table(vma, flags);
 		goto retry;
 	}
-	if (pmd_devmap(*pmd)) {
+	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
 		page = follow_devmap_pmd(vma, address, pmd, flags);
 		spin_unlock(ptl);
 		if (page)
 			return page;
 	}
-	if (likely(!pmd_trans_huge(*pmd)))
+	if (likely(!pmd_trans_huge(pmdval)))
 		return follow_page_pte(vma, address, pmd, flags);
 
-	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
+	if ((flags & FOLL_NUMA) && pmd_protnone(pmdval))
 		return no_page_table(vma, flags);
 
 retry_locked:
 	ptl = pmd_lock(mm, pmd);
+	if (unlikely(pmd_none(*pmd))) {
+		spin_unlock(ptl);
+		return no_page_table(vma, flags);
+	}
 	if (unlikely(!pmd_present(*pmd))) {
 		spin_unlock(ptl);
 		if (likely(!(flags & FOLL_MIGRATION)))
-- 
2.15.1
