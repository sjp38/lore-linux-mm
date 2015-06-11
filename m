Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id AD9236B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:22 -0400 (EDT)
Received: by oigz2 with SMTP id z2so10455458oig.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:02:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id az3si1209263obb.45.2015.06.11.14.02.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:02:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v4 PATCH 1/9] mm/hugetlb: add region_del() to delete a specific range of entries
Date: Thu, 11 Jun 2015 14:01:32 -0700
Message-Id: <1434056500-2434-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

fallocate hole punch will want to remove a specific range of pages.
The existing region_truncate() routine deletes all region/reserve
map entries after a specified offset.  region_del() will provide
this same functionality if the end of region is specified as -1.
Hence, region_del() can replace region_truncate().

Unlike region_truncate(), region_del() can return an error in the
rare case where it can not allocate memory for a region descriptor.
This ONLY happens in the case where an existing region must be split.
Current callers passing -1 as end of range will never experience
this error and do not need to deal with error handling.  Future
callers of region_del() (such as fallocate hole punch) will need to
handle this error.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 88 ++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 26 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087..3fc2359 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -385,43 +385,79 @@ out_nrg:
 }
 
 /*
- * Truncate the reserve map at index 'end'.  Modify/truncate any
- * region which contains end.  Delete any regions past end.
- * Return the number of huge pages removed from the map.
+ * Delete the specified range [f, t) from the reserve map.  If the
+ * t parameter is -1, this indicates that ALL regions after f should
+ * be deleted.  Locate the regions which intersect [f, t) and either
+ * trim, delete or split the existing regions.
+ *
+ * Returns the number of huge pages deleted from the reserve map.
+ * In the normal case, the return value is zero or more.  In the
+ * case where a region must be split, a new region descriptor must
+ * be allocated.  If the allocation fails, -ENOMEM will be returned.
+ * NOTE: If the parameter t == -1, then we will never split a region
+ * and possibly return -ENOMEM.  Callers specifying t == -1 do not
+ * need to check for -ENOMEM error.
  */
-static long region_truncate(struct resv_map *resv, long end)
+static long region_del(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *trg;
-	long chg = 0;
+	struct file_region *nrg = NULL;
+	long del = 0;
 
+	if (t == -1)
+		t = LONG_MAX;
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
+			if (!nrg) {
+				spin_unlock(&resv->lock);
+				nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+				if (!nrg)
+					return -ENOMEM;
+				goto retry;
+			}
 
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
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
@@ -559,7 +595,7 @@ void resv_map_release(struct kref *ref)
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
 	/* Clear out any active regions before we release the map. */
-	region_truncate(resv_map, 0);
+	region_del(resv_map, 0, -1);
 	kfree(resv_map);
 }
 
@@ -3740,7 +3776,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	long gbl_reserve;
 
 	if (resv_map)
-		chg = region_truncate(resv_map, offset);
+		chg = region_del(resv_map, offset, -1);
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
