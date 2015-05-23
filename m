Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id C7715829A8
	for <linux-mm@kvack.org>; Sat, 23 May 2015 00:00:14 -0400 (EDT)
Received: by oihd6 with SMTP id d6so26934493oih.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 21:00:14 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d6si2525374oif.77.2015.05.22.21.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 21:00:13 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 1/2] mm/hugetlb: compute/return the number of regions added by region_add()
Date: Fri, 22 May 2015 20:55:03 -0700
Message-Id: <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modify region_add() to keep track of regions(pages) added to the
reserve map and return this value.  The return value can be
compared to the return value of region_chg() to determine if the
map was modified between calls.

Add documentation to the reserve/region map routines.

Make vma_commit_reservation() also pass along the return value of
region_add().  In the normal case, we want vma_commit_reservation
to return the same value as the preceding call to vma_needs_reservation.
Create a common __vma_reservation_common routine to help keep the
special case return values in sync

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 94 insertions(+), 26 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 54f129d..3855889 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -212,8 +212,16 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
  *
- * The region data structures are embedded into a resv_map and
- * protected by a resv_map's lock
+ * The region data structures are embedded into a resv_map and protected
+ * by a resv_map's lock.  The set of regions within the resv_map represent
+ * reservations for huge pages, or huge pages that have already been
+ * instantiated within the map.  The from and to elements are huge page
+ * indicies into the associated mapping.  from indicates the starting index
+ * of the region.  to represents the first index past the end of  the region.
+ * For example, a file region structure with from == 0 and to == 4 represents
+ * four huge pages in a mapping.  It is important to note that the to element
+ * represents the first element past the end of the region. This is used in
+ * arithmetic as 4(to) - 0(from) = 4 huge pages in the region.
  */
 struct file_region {
 	struct list_head link;
@@ -221,10 +229,23 @@ struct file_region {
 	long to;
 };
 
+/*
+ * Add the huge page range represented by indicies f (from)
+ * and t (to) to the reserve map.  Existing regions will be
+ * expanded to accommodate the specified range.  We know only
+ * existing regions need to be expanded, because region_add
+ * is only called after region_chg(with the same range).  If
+ * a new file_region structure must be allocated, it is done
+ * in region_chg.
+ *
+ * Return the number of new huge pages added to the map.  This
+ * number is greater than or equal to zero.
+ */
 static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg, *trg;
+	long add = 0;
 
 	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
@@ -250,16 +271,44 @@ static long region_add(struct resv_map *resv, long f, long t)
 		if (rg->to > t)
 			t = rg->to;
 		if (rg != nrg) {
+			/* Decrement return value by the deleted range.
+			 * Another range will span this area so that by
+			 * end of routine add will be >= zero
+			 */
+			add -= (rg->to - rg->from);
 			list_del(&rg->link);
 			kfree(rg);
 		}
 	}
+
+	add += (nrg->from - f);		/* Added to beginning of region */
 	nrg->from = f;
+	add += t - nrg->to;		/* Added to end of region */
 	nrg->to = t;
+
 	spin_unlock(&resv->lock);
-	return 0;
+	return add;
 }
 
+/*
+ * Examine the existing reserve map and determine how many
+ * huge pages in the specified range (f, t) are NOT currently
+ * represented.  This routine is called before a subsequent
+ * call to region_add that will actually modify the reserve
+ * map to add the specified range (f, t).  region_chg does
+ * not change the number of huge pages represented by the
+ * map.  However, if the existing regions in the map can not
+ * be expanded to represent the new range, a new file_region
+ * structure is added to the map as a placeholder.  This is
+ * so that the subsequent region_add call will have all
+ * regions it needs and will not fail.
+ *
+ * Returns the number of huge pages that need to be added
+ * to the existing reservation map for the range (f, t).
+ * This number is greater or equal to zero.  -ENOMEM is
+ * returned if a new  file_region structure can not be
+ * allocated.
+ */
 static long region_chg(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
@@ -326,6 +375,11 @@ out_nrg:
 	return chg;
 }
 
+/*
+ * Truncate the reserve map at index 'end'.  Modify/truncate any
+ * region which contains end.  Delete any regions past end.
+ * Return the number of huge pages removed from the map.
+ */
 static long region_truncate(struct resv_map *resv, long end)
 {
 	struct list_head *head = &resv->regions;
@@ -361,6 +415,10 @@ out:
 	return chg;
 }
 
+/*
+ * Count and return the number of huge pages in the reserve map
+ * that intersect with the range (f, t).
+ */
 static long region_count(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
@@ -1424,46 +1482,56 @@ static void return_unused_surplus_pages(struct hstate *h,
 }
 
 /*
- * Determine if the huge page at addr within the vma has an associated
- * reservation.  Where it does not we will need to logically increase
- * reservation and actually increase subpool usage before an allocation
- * can occur.  Where any new reservation would be required the
- * reservation change is prepared, but not committed.  Once the page
- * has been allocated from the subpool and instantiated the change should
- * be committed via vma_commit_reservation.  No action is required on
- * failure.
+ * vma_needs_reservation and vma_commit_reservation are used by the huge
+ * page allocation routines to manage reservations.
+ *
+ * vma_needs_reservation is called to determine if the huge page at addr
+ * within the vma has an associated reservation.  If a reservation is
+ * needed, the value 1 is returned.  The caller is then responsible for
+ * managing the global reservation and subpool usage counts.  After
+ * the huge page has been allocated, vma_commit_reservation is called
+ * to add the page to the reservation map.
+ *
+ * In the normal case, vma_commit_reservation should return the same value
+ * as the preceding vma_needs_reservation call.  The only time this is
+ * not the case is if a reserve map was changed between calls.  It is the
+ * responsibility of the caller to notice the difference and take appropriate
+ * action.
  */
-static long vma_needs_reservation(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long addr)
+static long __vma_reservation_common(struct hstate *h,
+				struct vm_area_struct *vma, unsigned long addr,
+				bool needs)
 {
 	struct resv_map *resv;
 	pgoff_t idx;
-	long chg;
+	long ret;
 
 	resv = vma_resv_map(vma);
 	if (!resv)
 		return 1;
 
 	idx = vma_hugecache_offset(h, vma, addr);
-	chg = region_chg(resv, idx, idx + 1);
+	if (needs)
+		ret = region_chg(resv, idx, idx + 1);
+	else
+		ret = region_add(resv, idx, idx + 1);
 
 	if (vma->vm_flags & VM_MAYSHARE)
-		return chg;
+		return ret;
 	else
-		return chg < 0 ? chg : 0;
+		return ret < 0 ? ret : 0;
 }
-static void vma_commit_reservation(struct hstate *h,
+
+static long vma_needs_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	struct resv_map *resv;
-	pgoff_t idx;
-
-	resv = vma_resv_map(vma);
-	if (!resv)
-		return;
+	return __vma_reservation_common(h, vma, addr, (bool)1);
+}
 
-	idx = vma_hugecache_offset(h, vma, addr);
-	region_add(resv, idx, idx + 1);
+static long vma_commit_reservation(struct hstate *h,
+			struct vm_area_struct *vma, unsigned long addr)
+{
+	return __vma_reservation_common(h, vma, addr, (bool)0);
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
