Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C415B6B040A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:47:41 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id k3so19563994uak.4
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:47:41 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b64si1614110uab.101.2017.02.15.13.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:47:41 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for shared mappings
Date: Wed, 15 Feb 2017 13:46:50 -0800
Message-Id: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>

When userfaultfd hugetlbfs support was originally added, it followed
the pattern of anon mappings and did not support any vmas marked
VM_SHARED.  As such, support was only added for private mappings.

Remove this limitation and support shared mappings.  The primary
functional change required is adding pages to the page cache.  More
subtle changes are required for huge page reservation handling in
error paths.  A lengthy comment in the code describes the reservation
handling.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 mm/hugetlb.c     | 25 +++++++++++++++++++++--
 mm/userfaultfd.c | 60 +++++++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 67 insertions(+), 18 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d0d1d08..41f6c51 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4029,6 +4029,18 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	__SetPageUptodate(page);
 	set_page_huge_active(page);
 
+	/*
+	 * If shared, add to page cache
+	 */
+	if (dst_vma->vm_flags & VM_SHARED) {
+		struct address_space *mapping = dst_vma->vm_file->f_mapping;
+		pgoff_t idx = vma_hugecache_offset(h, dst_vma, dst_addr);
+
+		ret = huge_add_to_page_cache(page, mapping, idx);
+		if (ret)
+			goto out_release_nounlock;
+	}
+
 	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
 	spin_lock(ptl);
 
@@ -4036,8 +4048,12 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	if (!huge_pte_none(huge_ptep_get(dst_pte)))
 		goto out_release_unlock;
 
-	ClearPagePrivate(page);
-	hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);
+	if (dst_vma->vm_flags & VM_SHARED) {
+		page_dup_rmap(page, true);
+	} else {
+		ClearPagePrivate(page);
+		hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);
+	}
 
 	_dst_pte = make_huge_pte(dst_vma, page, dst_vma->vm_flags & VM_WRITE);
 	if (dst_vma->vm_flags & VM_WRITE)
@@ -4054,11 +4070,16 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	update_mmu_cache(dst_vma, dst_addr, dst_pte);
 
 	spin_unlock(ptl);
+	if (dst_vma->vm_flags & VM_SHARED)
+		unlock_page(page);
 	ret = 0;
 out:
 	return ret;
 out_release_unlock:
 	spin_unlock(ptl);
+out_release_nounlock:
+	if (dst_vma->vm_flags & VM_SHARED)
+		unlock_page(page);
 	put_page(page);
 	goto out;
 }
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index b861cf9..6703308 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -211,11 +211,9 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 			goto out_unlock;
 
 		/*
-		 * Make sure the vma is not shared, that the remaining dst
-		 * range is both valid and fully within a single existing vma.
+		 * Make sure the remaining dst range is both valid and
+		 * fully within a single existing vma.
 		 */
-		if (dst_vma->vm_flags & VM_SHARED)
-			goto out_unlock;
 		if (dst_start < dst_vma->vm_start ||
 		    dst_start + len > dst_vma->vm_end)
 			goto out_unlock;
@@ -226,11 +224,13 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		goto out_unlock;
 
 	/*
-	 * Ensure the dst_vma has a anon_vma.
+	 * If not shared, ensure the dst_vma has a anon_vma.
 	 */
 	err = -ENOMEM;
-	if (unlikely(anon_vma_prepare(dst_vma)))
-		goto out_unlock;
+	if (!(dst_vma->vm_flags & VM_SHARED)) {
+		if (unlikely(anon_vma_prepare(dst_vma)))
+			goto out_unlock;
+	}
 
 	h = hstate_vma(dst_vma);
 
@@ -306,18 +306,45 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	if (page) {
 		/*
 		 * We encountered an error and are about to free a newly
-		 * allocated huge page.  It is possible that there was a
-		 * reservation associated with the page that has been
-		 * consumed.  See the routine restore_reserve_on_error
-		 * for details.  Unfortunately, we can not call
-		 * restore_reserve_on_error now as it would require holding
-		 * mmap_sem.  Clear the PagePrivate flag so that the global
+		 * allocated huge page.
+		 *
+		 * Reservation handling is very subtle, and is different for
+		 * private and shared mappings.  See the routine
+		 * restore_reserve_on_error for details.  Unfortunately, we
+		 * can not call restore_reserve_on_error now as it would
+		 * require holding mmap_sem.
+		 *
+		 * If a reservation for the page existed in the reservation
+		 * map of a private mapping, the map was modified to indicate
+		 * the reservation was consumed when the page was allocated.
+		 * We clear the PagePrivate flag now so that the global
 		 * reserve count will not be incremented in free_huge_page.
 		 * The reservation map will still indicate the reservation
 		 * was consumed and possibly prevent later page allocation.
-		 * This is better than leaking a global reservation.
+		 * This is better than leaking a global reservation.  If no
+		 * reservation existed, it is still safe to clear PagePrivate
+		 * as no adjustments to reservation counts were made during
+		 * allocation.
+		 *
+		 * The reservation map for shared mappings indicates which
+		 * pages have reservations.  When a huge page is allocated
+		 * for an address with a reservation, no change is made to
+		 * the reserve map.  In this case PagePrivate will be set
+		 * to indicate that the global reservation count should be
+		 * incremented when the page is freed.  This is the desired
+		 * behavior.  However, when a huge page is allocated for an
+		 * address without a reservation a reservation entry is added
+		 * to the reservation map, and PagePrivate will not be set.
+		 * When the page is freed, the global reserve count will NOT
+		 * be incremented and it will appear as though we have leaked
+		 * reserved page.  In this case, set PagePrivate so that the
+		 * global reserve count will be incremented to match the
+		 * reservation map entry which was created.
 		 */
-		ClearPagePrivate(page);
+		if (dst_vma->vm_flags & VM_SHARED)
+			SetPagePrivate(page);
+		else
+			ClearPagePrivate(page);
 		put_page(page);
 	}
 	BUG_ON(copied < 0);
@@ -386,7 +413,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		goto out_unlock;
 
 	err = -EINVAL;
-	if (!vma_is_shmem(dst_vma) && dst_vma->vm_flags & VM_SHARED)
+	if (!vma_is_shmem(dst_vma) && !is_vm_hugetlb_page(dst_vma) &&
+	    dst_vma->vm_flags & VM_SHARED)
 		goto out_unlock;
 	if (dst_start < dst_vma->vm_start ||
 	    dst_start + len > dst_vma->vm_end)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
