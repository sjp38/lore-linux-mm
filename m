Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 448C16B0082
	for <linux-mm@kvack.org>; Wed, 27 May 2015 14:00:15 -0400 (EDT)
Received: by obbnx5 with SMTP id nx5so13782563obb.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 11:00:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d74si11435313oig.64.2015.05.27.11.00.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 11:00:14 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 2/3] mm/hugetlb: compute/return the number of regions added by region_add()
Date: Wed, 27 May 2015 10:56:10 -0700
Message-Id: <1432749371-32220-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>
References: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modify region_add() to keep track of regions(pages) added to the
reserve map and return this value.  The return value can be
compared to the return value of region_chg() to determine if the
map was modified between calls.

Make vma_commit_reservation() also pass along the return value of
region_add().  In the normal case, we want vma_commit_reservation
to return the same value as the preceding call to vma_needs_reservation.
Create a common __vma_reservation_common routine to help keep the
special case return values in sync

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 72 ++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 48 insertions(+), 24 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ad2c628..b3d3d59 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -240,11 +240,15 @@ struct file_region {
  * expanded, because region_add is only called after region_chg
  * with the same range.  If a new file_region structure must
  * be allocated, it is done in region_chg.
+ *
+ * Return the number of new huge pages added to the map.  This
+ * number is greater than or equal to zero.
  */
 static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg, *trg;
+	long add = 0;
 
 	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
@@ -270,14 +274,24 @@ static long region_add(struct resv_map *resv, long f, long t)
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
+	VM_BUG_ON(add < 0);
+	return add;
 }
 
 /*
@@ -1472,46 +1486,56 @@ static void return_unused_surplus_pages(struct hstate *h,
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
+ * In the normal case, vma_commit_reservation returns the same value
+ * as the preceding vma_needs_reservation call.  The only time this
+ * is not the case is if a reserve map was changed between calls.  It
+ * is the responsibility of the caller to notice the difference and
+ * take appropriate action.
  */
-static long vma_needs_reservation(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long addr)
+static long __vma_reservation_common(struct hstate *h,
+				struct vm_area_struct *vma, unsigned long addr,
+				bool commit)
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
+	if (commit)
+		ret = region_add(resv, idx, idx + 1);
+	else
+		ret = region_chg(resv, idx, idx + 1);
 
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
+	return __vma_reservation_common(h, vma, addr, false);
+}
 
-	idx = vma_hugecache_offset(h, vma, addr);
-	region_add(resv, idx, idx + 1);
+static long vma_commit_reservation(struct hstate *h,
+			struct vm_area_struct *vma, unsigned long addr)
+{
+	return __vma_reservation_common(h, vma, addr, true);
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
