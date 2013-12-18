Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CD1646B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:09 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ld10so5564842pab.39
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:09 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sj5si13538774pab.168.2013.12.17.22.54.06
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:07 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 02/14] mm, hugetlb: region manipulation functions take resv_map rather list_head
Date: Wed, 18 Dec 2013 15:53:48 +0900
Message-Id: <1387349640-8071-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To change a protection method for region tracking to find grained one,
we pass the resv_map, instead of list_head, to region manipulation
functions. This doesn't introduce any functional change, and it is just
for preparing a next step.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2891902..3e7a44b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -151,8 +151,9 @@ struct file_region {
 	long to;
 };
 
-static long region_add(struct list_head *head, long f, long t)
+static long region_add(struct resv_map *resv, long f, long t)
 {
+	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg, *trg;
 
 	/* Locate the region we are either in or before. */
@@ -187,8 +188,9 @@ static long region_add(struct list_head *head, long f, long t)
 	return 0;
 }
 
-static long region_chg(struct list_head *head, long f, long t)
+static long region_chg(struct resv_map *resv, long f, long t)
 {
+	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg;
 	long chg = 0;
 
@@ -236,8 +238,9 @@ static long region_chg(struct list_head *head, long f, long t)
 	return chg;
 }
 
-static long region_truncate(struct list_head *head, long end)
+static long region_truncate(struct resv_map *resv, long end)
 {
+	struct list_head *head = &resv->regions;
 	struct file_region *rg, *trg;
 	long chg = 0;
 
@@ -266,8 +269,9 @@ static long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
-static long region_count(struct list_head *head, long f, long t)
+static long region_count(struct resv_map *resv, long f, long t)
 {
+	struct list_head *head = &resv->regions;
 	struct file_region *rg;
 	long chg = 0;
 
@@ -393,7 +397,7 @@ void resv_map_release(struct kref *ref)
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
 	/* Clear out any active regions before we release the map. */
-	region_truncate(&resv_map->regions, 0);
+	region_truncate(resv_map, 0);
 	kfree(resv_map);
 }
 
@@ -1161,7 +1165,7 @@ static long vma_needs_reservation(struct hstate *h,
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *resv = inode->i_mapping->private_data;
 
-		return region_chg(&resv->regions, idx, idx + 1);
+		return region_chg(resv, idx, idx + 1);
 
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
@@ -1171,7 +1175,7 @@ static long vma_needs_reservation(struct hstate *h,
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *resv = vma_resv_map(vma);
 
-		err = region_chg(&resv->regions, idx, idx + 1);
+		err = region_chg(resv, idx, idx + 1);
 		if (err < 0)
 			return err;
 		return 0;
@@ -1187,14 +1191,14 @@ static void vma_commit_reservation(struct hstate *h,
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *resv = inode->i_mapping->private_data;
 
-		region_add(&resv->regions, idx, idx + 1);
+		region_add(resv, idx, idx + 1);
 
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *resv = vma_resv_map(vma);
 
 		/* Mark this page used in the map. */
-		region_add(&resv->regions, idx, idx + 1);
+		region_add(resv, idx, idx + 1);
 	}
 }
 
@@ -2285,7 +2289,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		end = vma_hugecache_offset(h, vma, vma->vm_end);
 
 		reserve = (end - start) -
-			region_count(&resv->regions, start, end);
+			region_count(resv, start, end);
 
 		resv_map_put(vma);
 
@@ -3176,7 +3180,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
 		resv_map = inode->i_mapping->private_data;
 
-		chg = region_chg(&resv_map->regions, from, to);
+		chg = region_chg(resv_map, from, to);
 
 	} else {
 		resv_map = resv_map_alloc();
@@ -3222,7 +3226,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&resv_map->regions, from, to);
+		region_add(resv_map, from, to);
 	return 0;
 out_err:
 	if (vma)
@@ -3238,7 +3242,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
 	if (resv_map)
-		chg = region_truncate(&resv_map->regions, offset);
+		chg = region_truncate(resv_map, offset);
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
