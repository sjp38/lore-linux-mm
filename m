Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 651B96B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:17:07 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:09:16 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219BVYo2896052
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:11:31 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219H1W6004467
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:17:02 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 6/9] hugetlbfs: Add memory controller support for private mapping
Date: Thu,  1 Mar 2012 14:46:17 +0530
Message-Id: <1330593380-1361-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For private mapping we always charge/uncharge from the current task memcg.
Charging happens during mmap(2) and uncharge happens during the
vm_operations->close. For child task after fork the charging happens
during fault time in alloc_huge_page. We also need to make sure for private
mapping each vma for hugeTLB mapping have struct resv_map allocated so that we
can store the charge list in resv_map.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c |  176 +++++++++++++++++++++++++++++++++------------------------
 1 files changed, 102 insertions(+), 74 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 664c663..2d99d0a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -126,6 +126,22 @@ long hugetlb_truncate_cgroup(struct hstate *h,
 #endif
 }
 
+long hugetlb_truncate_cgroup_range(struct hstate *h,
+				   struct list_head *head, long from, long end)
+{
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
+	long chg;
+	from = from << huge_page_order(h);
+	end  = end << huge_page_order(h);
+	chg  = mem_cgroup_truncate_chglist_range(head, from, end, h - hstates);
+	if (chg > 0)
+		return chg >> huge_page_order(h);
+	return chg;
+#else
+	return region_truncate_range(head, from, end);
+#endif
+}
+
 /*
  * Convert the address within this vma to the page offset within
  * the mapping, in pagecache page units; huge pages here.
@@ -229,13 +245,19 @@ static struct resv_map *resv_map_alloc(void)
 	return resv_map;
 }
 
-static void resv_map_release(struct kref *ref)
+static unsigned long resv_map_release(struct hstate *h,
+				      struct resv_map *resv_map)
 {
-	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
-
-	/* Clear out any active regions before we release the map. */
-	region_truncate(&resv_map->regions, 0);
+	unsigned long reserve;
+	/*
+	 * We should not have any regions left here, if we were able to
+	 * do memory allocation when in trunage_cgroup_range.
+	 *
+	 * Clear out any active regions before we release the map
+	 */
+	reserve = hugetlb_truncate_cgroup(h, &resv_map->regions, 0);
 	kfree(resv_map);
+	return reserve;
 }
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
@@ -447,9 +469,7 @@ static void free_huge_page(struct page *page)
 	 */
 	struct hstate *h = page_hstate(page);
 	int nid = page_to_nid(page);
-	struct address_space *mapping;
 
-	mapping = (struct address_space *) page_private(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	BUG_ON(page_count(page));
@@ -465,8 +485,6 @@ static void free_huge_page(struct page *page)
 		enqueue_huge_page(h, page);
 	}
 	spin_unlock(&hugetlb_lock);
-	if (mapping)
-		hugetlb_put_quota(mapping, 1);
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
@@ -887,63 +905,74 @@ static void return_unused_surplus_pages(struct hstate *h,
  * No action is required on failure.
  */
 static long vma_needs_reservation(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long addr)
+				  struct vm_area_struct *vma,
+				  unsigned long addr)
 {
+	pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
+
 	if (vma->vm_flags & VM_MAYSHARE) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		return hugetlb_page_charge(&inode->i_mapping->private_list,
 					   h, idx, idx + 1);
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		return 1;
-
-	} else  {
-		long err;
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *reservations = vma_resv_map(vma);
-
-		err = region_chg(&reservations->regions, idx, idx + 1, 0);
-		if (err < 0)
-			return err;
-		return 0;
+		struct resv_map *resv_map = vma_resv_map(vma);
+		if (!resv_map) {
+			/*
+			 * We didn't allocate resv_map for this vma.
+			 * Allocate it here.
+			 */
+			resv_map = resv_map_alloc();
+			if (!resv_map)
+				return -ENOMEM;
+			set_vma_resv_map(vma, resv_map);
+		}
+		return hugetlb_page_charge(&resv_map->regions,
+					   h, idx, idx + 1);
 	}
+	/*
+	 * We did the private page charging in mmap call
+	 */
+	return 0;
 }
 
 static void vma_uncharge_reservation(struct hstate *h,
 				     struct vm_area_struct *vma,
 				     unsigned long chg)
 {
+	int idx = h - hstates;
+	struct list_head *region_list;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 
-	if (vma->vm_flags & VM_MAYSHARE) {
-		return hugetlb_page_uncharge(&inode->i_mapping->private_list,
-					     h - hstates,
-					     chg << huge_page_order(h));
+	if (vma->vm_flags & VM_MAYSHARE)
+		region_list = &inode->i_mapping->private_list;
+	else {
+		struct resv_map *resv_map = vma_resv_map(vma);
+		region_list = &resv_map->regions;
 	}
+	return hugetlb_page_uncharge(region_list,
+				     idx, chg << huge_page_order(h));
 }
 
 static void vma_commit_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-
+	struct list_head *region_list;
+	pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 	if (vma->vm_flags & VM_MAYSHARE) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		hugetlb_commit_page_charge(h, &inode->i_mapping->private_list,
-					   idx, idx + 1);
-	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
+		region_list = &inode->i_mapping->private_list;
+	} else  {
 		struct resv_map *reservations = vma_resv_map(vma);
-
-		/* Mark this page used in the map. */
-		region_add(&reservations->regions, idx, idx + 1, 0);
+		region_list = &reservations->regions;
 	}
+	hugetlb_commit_page_charge(h, region_list, idx, idx + 1);
+	return;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -986,10 +1015,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			return ERR_PTR(-VM_FAULT_SIGBUS);
 		}
 	}
-
 	set_page_private(page, (unsigned long) mapping);
-
-	vma_commit_reservation(h, vma, addr);
+	if (chg)
+		vma_commit_reservation(h, vma, addr);
 	return page;
 }
 
@@ -2001,25 +2029,40 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
 	 */
 	if (reservations)
 		kref_get(&reservations->refs);
+	else if (!(vma->vm_flags & VM_MAYSHARE)) {
+		/*
+		 * for non shared vma we need resv map to track
+		 * hugetlb cgroup usage. Allocate it here. Charging
+		 * the cgroup will take place in fault path.
+		 */
+		struct resv_map *resv_map = resv_map_alloc();
+		/*
+		 * If we fail to allocate resv_map here. We will allocate
+		 * one when we do alloc_huge_page. So we don't handle
+		 * ENOMEM here. The function also return void. So there is
+		 * nothing much we can do.
+		 */
+		if (resv_map)
+			set_vma_resv_map(vma, resv_map);
+	}
 }
 
 static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 {
 	struct hstate *h = hstate_vma(vma);
-	struct resv_map *reservations = vma_resv_map(vma);
-	unsigned long reserve;
-	unsigned long start;
-	unsigned long end;
+	struct resv_map *resv_map = vma_resv_map(vma);
+	unsigned long reserve, start, end;
 
-	if (reservations) {
+	if (resv_map) {
 		start = vma_hugecache_offset(h, vma, vma->vm_start);
 		end = vma_hugecache_offset(h, vma, vma->vm_end);
 
-		reserve = (end - start) -
-			region_count(&reservations->regions, start, end);
-
-		kref_put(&reservations->refs, resv_map_release);
-
+		reserve = hugetlb_truncate_cgroup_range(h, &resv_map->regions,
+							start, end);
+		/* open coded kref_put */
+		if (atomic_sub_and_test(1, &resv_map->refs.refcount)) {
+			reserve += resv_map_release(h, resv_map);
+		}
 		if (reserve) {
 			hugetlb_acct_memory(h, -reserve);
 			hugetlb_put_quota(vma->vm_file->f_mapping, reserve);
@@ -2803,8 +2846,9 @@ int hugetlb_reserve_pages(struct inode *inode,
 					vm_flags_t vm_flags)
 {
 	long ret, chg;
+	struct list_head *region_list;
 	struct hstate *h = hstate_inode(inode);
-
+	struct resv_map *resv_map = NULL;
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
 	 * attempt will be made for VM_NORESERVE to allocate a page
@@ -2820,19 +2864,17 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
-		chg = hugetlb_page_charge(&inode->i_mapping->private_list,
-					  h, from, to);
+		region_list = &inode->i_mapping->private_list;
 	} else {
-		struct resv_map *resv_map = resv_map_alloc();
+		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
 
-		chg = to - from;
-
 		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
+		region_list = &resv_map->regions;
 	}
-
+	chg = hugetlb_page_charge(region_list, h, from, to);
 	if (chg < 0)
 		return chg;
 
@@ -2848,29 +2890,15 @@ int hugetlb_reserve_pages(struct inode *inode,
 	ret = hugetlb_acct_memory(h, chg);
 	if (ret < 0)
 		goto err_acct_mem;
-	/*
-	 * Account for the reservations made. Shared mappings record regions
-	 * that have reservations as they are shared by multiple VMAs.
-	 * When the last VMA disappears, the region map says how much
-	 * the reservation was and the page cache tells how much of
-	 * the reservation was consumed. Private mappings are per-VMA and
-	 * only the consumed reservations are tracked. When the VMA
-	 * disappears, the original reservation is the VMA size and the
-	 * consumed reservations are stored in the map. Hence, nothing
-	 * else has to be done for private mappings here
-	 */
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		hugetlb_commit_page_charge(h, &inode->i_mapping->private_list,
-					   from, to);
+
+	hugetlb_commit_page_charge(h, region_list, from, to);
 	return 0;
 err_acct_mem:
 	hugetlb_put_quota(inode->i_mapping, chg);
 err_quota:
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		hugetlb_page_uncharge(&inode->i_mapping->private_list,
-				      h - hstates, chg << huge_page_order(h));
+	hugetlb_page_uncharge(region_list, h - hstates,
+			      chg << huge_page_order(h));
 	return ret;
-
 }
 
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
@@ -2884,7 +2912,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
 
-	hugetlb_put_quota(inode->i_mapping, (chg - freed));
+	hugetlb_put_quota(inode->i_mapping, chg);
 	hugetlb_acct_memory(h, -(chg - freed));
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
