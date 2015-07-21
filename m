Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id EDC999003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:10:34 -0400 (EDT)
Received: by ykax123 with SMTP id x123so173058403yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:10:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z188si17197918ywa.99.2015.07.21.11.10.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 11:10:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 02/10] mm/hugetlb: add region_del() to delete a specific range of entries
Date: Tue, 21 Jul 2015 11:09:36 -0700
Message-Id: <1437502184-14269-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

fallocate hole punch will want to remove a specific range of pages.
The existing region_truncate() routine deletes all region/reserve
map entries after a specified offset.  region_del() will provide
this same functionality if the end of region is specified as LONG_MAX.
Hence, region_del() can replace region_truncate().

Unlike region_truncate(), region_del() can return an error in the
rare case where it can not allocate memory for a region descriptor.
This ONLY happens in the case where an existing region must be split.
Current callers passing LONG_MAX as end of range will never experience
this error and do not need to deal with error handling.  Future
callers of region_del() (such as fallocate hole punch) will need to
handle this error.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 122 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 85 insertions(+), 37 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c3923a1..a573396 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -462,43 +462,90 @@ static void region_abort(struct resv_map *resv, long f, long t)
 }
 
 /*
- * Truncate the reserve map at index 'end'.  Modify/truncate any
- * region which contains end.  Delete any regions past end.
- * Return the number of huge pages removed from the map.
+ * Delete the specified range [f, t) from the reserve map.  If the
+ * t parameter is LONG_MAX, this indicates that ALL regions after f
+ * should be deleted.  Locate the regions which intersect [f, t)
+ * and either trim, delete or split the existing regions.
+ *
+ * Returns the number of huge pages deleted from the reserve map.
+ * In the normal case, the return value is zero or more.  In the
+ * case where a region must be split, a new region descriptor must
+ * be allocated.  If the allocation fails, -ENOMEM will be returned.
+ * NOTE: If the parameter t == LONG_MAX, then we will never split
+ * a region and possibly return -ENOMEM.  Callers specifying
+ * t == LONG_MAX do not need to check for -ENOMEM error.
  */
-static long region_truncate(struct resv_map *resv, long end)
+static long region_del(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *trg;
-	long chg = 0;
+	struct file_region *nrg = NULL;
+	long del = 0;
 
+retry:
 	spin_lock(&resv->lock);
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
+	list_for_each_entry_safe(rg, trg, head, link) {
+		if (rg->to <= f)
+			continue;
+		if (rg->from >= t)
 			break;
-	if (&rg->link == head)
-		goto out;
 
-	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
-		rg = list_entry(rg->link.next, typeof(*rg), link);
-	}
+		if (f > rg->from && t < rg->to) { /* Must split region */
+			/*
+			 * Check for an entry in the cache before dropping
+			 * lock and attempting allocation.
+			 */
+			if (!nrg &&
+			    resv->rgn_cache_count > resv->adds_in_progress) {
+				nrg = list_first_entry(&resv->rgn_cache,
+							struct file_region,
+							link);
+				list_del(&nrg->link);
+				resv->rgn_cache_count--;
+			}
 
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
+			if (!nrg) {
+				spin_unlock(&resv->lock);
+				nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+				if (!nrg)
+					return -ENOMEM;
+				goto retry;
+			}
+
+			del += t - f;
+
+			/* New entry for end of split region */
+			nrg->from = t;
+			nrg->to = rg->to;
+			INIT_LIST_HEAD(&nrg->link);
+
+			/* Original entry is trimmed */
+			rg->to = f;
+
+			list_add(&nrg->link, &rg->link);
+			nrg = NULL;
 			break;
-		chg += rg->to - rg->from;
-		list_del(&rg->link);
-		kfree(rg);
+		}
+
+		if (f <= rg->from && t >= rg->to) { /* Remove entire region */
+			del += rg->to - rg->from;
+			list_del(&rg->link);
+			kfree(rg);
+			continue;
+		}
+
+		if (f <= rg->from) {	/* Trim beginning of region */
+			del += t - rg->from;
+			rg->from = t;
+		} else {		/* Trim end of region */
+			del += rg->to - f;
+			rg->to = f;
+		}
 	}
 
-out:
 	spin_unlock(&resv->lock);
-	return chg;
+	kfree(nrg);
+	return del;
 }
 
 /*
@@ -649,7 +696,7 @@ void resv_map_release(struct kref *ref)
 	struct file_region *rg, *trg;
 
 	/* Clear out any active regions before we release the map. */
-	region_truncate(resv_map, 0);
+	region_del(resv_map, 0, LONG_MAX);
 
 	/* ... and any entries left in the cache */
 	list_for_each_entry_safe(rg, trg, head, link) {
@@ -1574,7 +1621,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 
 
 /*
- * vma_needs_reservation, vma_commit_reservation and vma_abort_reservation
+ * vma_needs_reservation, vma_commit_reservation and vma_end_reservation
  * are used by the huge page allocation routines to manage reservations.
  *
  * vma_needs_reservation is called to determine if the huge page at addr
@@ -1582,8 +1629,9 @@ static void return_unused_surplus_pages(struct hstate *h,
  * needed, the value 1 is returned.  The caller is then responsible for
  * managing the global reservation and subpool usage counts.  After
  * the huge page has been allocated, vma_commit_reservation is called
- * to add the page to the reservation map.  If the reservation must be
- * aborted instead of committed, vma_abort_reservation is called.
+ * to add the page to the reservation map.  If the page allocation fails,
+ * the reservation must be ended instead of committed.  vma_end_reservation
+ * is called in such cases.
  *
  * In the normal case, vma_commit_reservation returns the same value
  * as the preceding vma_needs_reservation call.  The only time this
@@ -1594,7 +1642,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 enum vma_resv_mode {
 	VMA_NEEDS_RESV,
 	VMA_COMMIT_RESV,
-	VMA_ABORT_RESV,
+	VMA_END_RESV,
 };
 static long __vma_reservation_common(struct hstate *h,
 				struct vm_area_struct *vma, unsigned long addr,
@@ -1616,7 +1664,7 @@ static long __vma_reservation_common(struct hstate *h,
 	case VMA_COMMIT_RESV:
 		ret = region_add(resv, idx, idx + 1);
 		break;
-	case VMA_ABORT_RESV:
+	case VMA_END_RESV:
 		region_abort(resv, idx, idx + 1);
 		ret = 0;
 		break;
@@ -1642,10 +1690,10 @@ static long vma_commit_reservation(struct hstate *h,
 	return __vma_reservation_common(h, vma, addr, VMA_COMMIT_RESV);
 }
 
-static void vma_abort_reservation(struct hstate *h,
+static void vma_end_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	(void)__vma_reservation_common(h, vma, addr, VMA_ABORT_RESV);
+	(void)__vma_reservation_common(h, vma, addr, VMA_END_RESV);
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -1672,7 +1720,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		return ERR_PTR(-ENOMEM);
 	if (chg || avoid_reserve)
 		if (hugepage_subpool_get_pages(spool, 1) < 0) {
-			vma_abort_reservation(h, vma, addr);
+			vma_end_reservation(h, vma, addr);
 			return ERR_PTR(-ENOSPC);
 		}
 
@@ -1720,7 +1768,7 @@ out_uncharge_cgroup:
 out_subpool_put:
 	if (chg || avoid_reserve)
 		hugepage_subpool_put_pages(spool, 1);
-	vma_abort_reservation(h, vma, addr);
+	vma_end_reservation(h, vma, addr);
 	return ERR_PTR(-ENOSPC);
 }
 
@@ -3367,7 +3415,7 @@ retry:
 			goto backout_unlocked;
 		}
 		/* Just decrements count, does not deallocate */
-		vma_abort_reservation(h, vma, address);
+		vma_end_reservation(h, vma, address);
 	}
 
 	ptl = huge_pte_lockptr(h, mm, ptep);
@@ -3516,7 +3564,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			goto out_mutex;
 		}
 		/* Just decrements count, does not deallocate */
-		vma_abort_reservation(h, vma, address);
+		vma_end_reservation(h, vma, address);
 
 		if (!(vma->vm_flags & VM_MAYSHARE))
 			pagecache_page = hugetlbfs_pagecache_page(h,
@@ -3872,7 +3920,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	long gbl_reserve;
 
 	if (resv_map)
-		chg = region_truncate(resv_map, offset);
+		chg = region_del(resv_map, offset, LONG_MAX);
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
