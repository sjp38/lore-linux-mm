Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7E8986B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:16:56 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:11:40 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219BLMq2896018
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:11:21 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219Gpw2004061
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:16:52 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 3/9] hugetlbfs: Use the generic region API and drop local one
Date: Thu,  1 Mar 2012 14:46:14 +0530
Message-Id: <1330593380-1361-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use the new region functions added.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c |  160 ++++------------------------------------------------------
 1 files changed, 10 insertions(+), 150 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f34bd8..9fd6d38 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -21,6 +21,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/region.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -66,151 +67,10 @@ static DEFINE_SPINLOCK(hugetlb_lock);
  * or
  *	down_read(&mm->mmap_sem);
  *	mutex_lock(&hugetlb_instantiation_mutex);
+ * shared mapping regions are tracked in inode->i_mapping and
+ * private mapping regions in vma_rea_struct
+ *
  */
-struct file_region {
-	struct list_head link;
-	long from;
-	long to;
-};
-
-static long region_add(struct list_head *head, long f, long t)
-{
-	struct file_region *rg, *nrg, *trg;
-
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-
-	/* Check for and consume any regions we now overlap with. */
-	nrg = rg;
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			break;
-
-		/* If this area reaches higher then extend our area to
-		 * include it completely.  If this is not the first area
-		 * which we intend to reuse, free it. */
-		if (rg->to > t)
-			t = rg->to;
-		if (rg != nrg) {
-			list_del(&rg->link);
-			kfree(rg);
-		}
-	}
-	nrg->from = f;
-	nrg->to = t;
-	return 0;
-}
-
-static long region_chg(struct list_head *head, long f, long t)
-{
-	struct file_region *rg, *nrg;
-	long chg = 0;
-
-	/* Locate the region we are before or in. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	/* If we are below the current region then a new region is required.
-	 * Subtle, allocate a new region at the position but make it zero
-	 * size such that we can guarantee to record the reservation. */
-	if (&rg->link == head || t < rg->from) {
-		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
-		nrg->from = f;
-		nrg->to   = f;
-		INIT_LIST_HEAD(&nrg->link);
-		list_add(&nrg->link, rg->link.prev);
-
-		return t - f;
-	}
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-	chg = t - f;
-
-	/* Check for and consume any regions we now overlap with. */
-	list_for_each_entry(rg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			return chg;
-
-		/* We overlap with this area, if it extends further than
-		 * us then we must extend ourselves.  Account for its
-		 * existing reservation. */
-		if (rg->to > t) {
-			chg += rg->to - t;
-			t = rg->to;
-		}
-		chg -= rg->to - rg->from;
-	}
-	return chg;
-}
-
-static long region_truncate(struct list_head *head, long end)
-{
-	struct file_region *rg, *trg;
-	long chg = 0;
-
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
-			break;
-	if (&rg->link == head)
-		return 0;
-
-	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
-		rg = list_entry(rg->link.next, typeof(*rg), link);
-	}
-
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		chg += rg->to - rg->from;
-		list_del(&rg->link);
-		kfree(rg);
-	}
-	return chg;
-}
-
-static long region_count(struct list_head *head, long f, long t)
-{
-	struct file_region *rg;
-	long chg = 0;
-
-	/* Locate each segment we overlap with, and count that overlap. */
-	list_for_each_entry(rg, head, link) {
-		int seg_from;
-		int seg_to;
-
-		if (rg->to <= f)
-			continue;
-		if (rg->from >= t)
-			break;
-
-		seg_from = max(rg->from, f);
-		seg_to = min(rg->to, t);
-
-		chg += seg_to - seg_from;
-	}
-
-	return chg;
-}
 
 /*
  * Convert the address within this vma to the page offset within
@@ -981,7 +841,7 @@ static long vma_needs_reservation(struct hstate *h,
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		return region_chg(&inode->i_mapping->private_list,
-							idx, idx + 1);
+				  idx, idx + 1, 0);
 
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
@@ -991,7 +851,7 @@ static long vma_needs_reservation(struct hstate *h,
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
 
-		err = region_chg(&reservations->regions, idx, idx + 1);
+		err = region_chg(&reservations->regions, idx, idx + 1, 0);
 		if (err < 0)
 			return err;
 		return 0;
@@ -1005,14 +865,14 @@ static void vma_commit_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		region_add(&inode->i_mapping->private_list, idx, idx + 1);
+		region_add(&inode->i_mapping->private_list, idx, idx + 1, 0);
 
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
 
 		/* Mark this page used in the map. */
-		region_add(&reservations->regions, idx, idx + 1);
+		region_add(&reservations->regions, idx, idx + 1, 0);
 	}
 }
 
@@ -2885,7 +2745,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		chg = region_chg(&inode->i_mapping->private_list, from, to);
+		chg = region_chg(&inode->i_mapping->private_list, from, to, 0);
 	else {
 		struct resv_map *resv_map = resv_map_alloc();
 		if (!resv_map)
@@ -2926,7 +2786,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&inode->i_mapping->private_list, from, to);
+		region_add(&inode->i_mapping->private_list, from, to, 0);
 	return 0;
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
