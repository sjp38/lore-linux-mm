Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D305E6B20AE
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:59:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id a15-v6so17639309qtj.15
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:59:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f85-v6si2310471qkf.159.2018.08.21.13.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 13:59:14 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 2/2] hugetlb: take PMD sharing into account when flushing tlb/caches
Date: Tue, 21 Aug 2018 13:59:02 -0700
Message-Id: <20180821205902.21223-3-mike.kravetz@oracle.com>
In-Reply-To: <20180821205902.21223-1-mike.kravetz@oracle.com>
References: <20180821205902.21223-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When fixing an issue with PMD sharing and migration, it was discovered
via code inspection that other callers of huge_pmd_unshare potentially
have an issue with cache and tlb flushing.

Use the routine huge_pmd_sharing_possible() to calculate worst case
ranges for mmu notifiers.  Ensure that this range is flushed if
huge_pmd_unshare succeeds and unmaps a PUD_SUZE area.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 53 +++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 44 insertions(+), 9 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fd155dc52117..c31d92889775 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3333,8 +3333,8 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
-	const unsigned long mmun_start = start;	/* For mmu_notifiers */
-	const unsigned long mmun_end   = end;	/* For mmu_notifiers */
+	unsigned long mmun_start = start;	/* For mmu_notifiers */
+	unsigned long mmun_end   = end;		/* For mmu_notifiers */
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~huge_page_mask(h));
@@ -3346,6 +3346,11 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 */
 	tlb_remove_check_page_size_change(tlb, sz);
 	tlb_start_vma(tlb, vma);
+
+	/*
+	 * If sharing possible, alert mmu notifiers of worst case.
+	 */
+	(void)huge_pmd_sharing_possible(vma, &mmun_start, &mmun_end);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
 	for (; address < end; address += sz) {
@@ -3356,6 +3361,10 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		ptl = huge_pte_lock(h, mm, ptep);
 		if (huge_pmd_unshare(mm, &address, ptep)) {
 			spin_unlock(ptl);
+			/*
+			 * We just unmapped a page of PMDs by clearing a PUD.
+			 * The caller's TLB flush range should cover this area.
+			 */
 			continue;
 		}
 
@@ -3438,12 +3447,23 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 {
 	struct mm_struct *mm;
 	struct mmu_gather tlb;
+	unsigned long tlb_start = start;
+	unsigned long tlb_end = end;
+
+	/*
+	 * If shared PMDs were possibly used within this vma range, adjust
+	 * start/end for worst case tlb flushing.
+	 * Note that we can not be sure if PMDs are shared until we try to
+	 * unmap pages.  However, we want to make sure TLB flushing covers
+	 * the largest possible range.
+	 */
+	(void)huge_pmd_sharing_possible(vma, &tlb_start, &tlb_end);
 
 	mm = vma->vm_mm;
 
-	tlb_gather_mmu(&tlb, mm, start, end);
+	tlb_gather_mmu(&tlb, mm, tlb_start, tlb_end);
 	__unmap_hugepage_range(&tlb, vma, start, end, ref_page);
-	tlb_finish_mmu(&tlb, start, end);
+	tlb_finish_mmu(&tlb, tlb_start, tlb_end);
 }
 
 /*
@@ -4309,11 +4329,21 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long pages = 0;
+	unsigned long f_start = start;
+	unsigned long f_end = end;
+	bool shared_pmd = false;
+
+	/*
+	 * In the case of shared PMDs, the area to flush could be beyond
+	 * start/end.  Set f_start/f_end to cover the maximum possible
+	 * range if PMD sharing is possible.
+	 */
+	(void)huge_pmd_sharing_possible(vma, &f_start, &f_end);
 
 	BUG_ON(address >= end);
-	flush_cache_range(vma, address, end);
+	flush_cache_range(vma, f_start, f_end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, f_start, f_end);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -4324,6 +4354,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		if (huge_pmd_unshare(mm, &address, ptep)) {
 			pages++;
 			spin_unlock(ptl);
+			shared_pmd = true;
 			continue;
 		}
 		pte = huge_ptep_get(ptep);
@@ -4359,9 +4390,13 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * Must flush TLB before releasing i_mmap_rwsem: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
 	 * once we release i_mmap_rwsem, another task can do the final put_page
-	 * and that page table be reused and filled with junk.
+	 * and that page table be reused and filled with junk.  If we actually
+	 * did unshare a page of pmds, flush the range corresponding to the pud.
 	 */
-	flush_hugetlb_tlb_range(vma, start, end);
+	if (shared_pmd)
+		flush_hugetlb_tlb_range(vma, f_start, f_end);
+	else
+		flush_hugetlb_tlb_range(vma, start, end);
 	/*
 	 * No need to call mmu_notifier_invalidate_range() we are downgrading
 	 * page table protection not changing it to point to a new page.
@@ -4369,7 +4404,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * See Documentation/vm/mmu_notifier.rst
 	 */
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, f_start, f_end);
 
 	return pages << h->order;
 }
-- 
2.17.1
