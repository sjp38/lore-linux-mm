Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C2B966B00E7
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:23 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:18:36 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBH3pB3129564
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:17:03 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBMHld020207
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:18 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 8/9] hugetlbfs: Add task migration support
Date: Mon, 20 Feb 2012 16:51:41 +0530
Message-Id: <1329736902-26870-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch add task migration support to hugetlb cgroup. When task migrate we
don't move charge across hugetlb cgroup.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |   74 ----------------------
 fs/hugetlbfs/region.c          |   24 -------
 include/linux/hugetlb.h        |    1 -
 include/linux/hugetlb_cgroup.h |   17 -----
 mm/hugetlb.c                   |  134 +++++++++++++++-------------------------
 5 files changed, 49 insertions(+), 201 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index b8b319b..44b3d5e 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -114,29 +114,6 @@ int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event)
 	return 0;
 }
 
-static int hugetlbcgroup_can_attach(struct cgroup_subsys *ss,
-				    struct cgroup *new_cgrp,
-				    struct cgroup_taskset *set)
-{
-	struct hugetlb_cgroup *h_cg;
-	struct task_struct *task = cgroup_taskset_first(set);
-	/*
-	 * Make sure all the task in the set are in root cgroup
-	 * We only allow move from root cgroup to other cgroup.
-	 */
-	while (task != NULL) {
-		rcu_read_lock();
-		h_cg = task_hugetlbcgroup(task);
-		if (!hugetlb_cgroup_is_root(h_cg)) {
-			rcu_read_unlock();
-			return -EOPNOTSUPP;
-		}
-		rcu_read_unlock();
-		task = cgroup_taskset_next(set);
-	}
-	return 0;
-}
-
 /*
  * called from kernel/cgroup.c with cgroup_lock() held.
  */
@@ -202,7 +179,6 @@ static int hugetlbcgroup_populate(struct cgroup_subsys *ss,
 
 struct cgroup_subsys hugetlb_subsys = {
 	.name = "hugetlb",
-	.can_attach = hugetlbcgroup_can_attach,
 	.create     = hugetlbcgroup_create,
 	.pre_destroy = hugetlbcgroup_pre_destroy,
 	.destroy    = hugetlbcgroup_destroy,
@@ -406,53 +382,3 @@ long hugetlb_truncate_cgroup_range(struct hstate *h,
 	}
 	return chg;
 }
-
-int hugetlb_priv_page_charge(struct resv_map *map, struct hstate *h, long chg)
-{
-	long csize;
-	int idx, ret;
-	struct hugetlb_cgroup *h_cg;
-	struct res_counter *fail_res;
-
-	/*
-	 * Get the task cgroup within rcu_readlock and also
-	 * get cgroup reference to make sure cgroup destroy won't
-	 * race with page_charge. We don't allow a cgroup destroy
-	 * when the cgroup have some charge against it
-	 */
-	rcu_read_lock();
-	h_cg = task_hugetlbcgroup(current);
-	css_get(&h_cg->css);
-	rcu_read_unlock();
-
-	if (hugetlb_cgroup_is_root(h_cg)) {
-		ret = chg;
-		goto err_out;
-	}
-
-	csize = chg * huge_page_size(h);
-	idx = h - hstates;
-	ret = res_counter_charge(&h_cg->memhuge[idx], csize, &fail_res);
-	if (!ret) {
-		map->nr_pages[idx] += chg << huge_page_order(h);
-		ret = chg;
-	}
-err_out:
-	css_put(&h_cg->css);
-	return ret;
-}
-
-void hugetlb_priv_page_uncharge(struct resv_map *map, int idx, long nr_pages)
-{
-	struct hugetlb_cgroup *h_cg;
-	unsigned long csize = nr_pages * PAGE_SIZE;
-
-	rcu_read_lock();
-	h_cg = task_hugetlbcgroup(current);
-	if (!hugetlb_cgroup_is_root(h_cg)) {
-		res_counter_uncharge(&h_cg->memhuge[idx], csize);
-		map->nr_pages[idx] -= nr_pages;
-	}
-	rcu_read_unlock();
-	return;
-}
diff --git a/fs/hugetlbfs/region.c b/fs/hugetlbfs/region.c
index 8ac63b0..483473f 100644
--- a/fs/hugetlbfs/region.c
+++ b/fs/hugetlbfs/region.c
@@ -177,30 +177,6 @@ long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
-long region_count(struct list_head *head, long f, long t)
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
-
 long region_truncate_range(struct list_head *head, long from, long to)
 {
 	long chg = 0;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8576fa0..226f488 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -255,7 +255,6 @@ struct hstate *size_to_hstate(unsigned long size);
 
 struct resv_map {
 	struct kref refs;
-	long nr_pages[HUGE_MAX_HSTATE];
 	struct list_head regions;
 };
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 68c1d61..9d51235 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -26,7 +26,6 @@ extern long region_chg(struct list_head *head, long f, long t,
 extern void region_add(struct list_head *head, long f, long t,
 		       unsigned long data);
 extern long region_truncate(struct list_head *head, long end);
-extern long region_count(struct list_head *head, long f, long t);
 extern long region_truncate_range(struct list_head *head, long from, long end);
 #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
 extern u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft);
@@ -43,10 +42,6 @@ extern long hugetlb_truncate_cgroup(struct hstate *h,
 extern long  hugetlb_truncate_cgroup_range(struct hstate *h,
 					   struct list_head *head,
 					   long from, long end);
-extern int hugetlb_priv_page_charge(struct resv_map *map,
-				    struct hstate *h, long chg);
-extern void hugetlb_priv_page_uncharge(struct resv_map *map,
-				       int idx, long nr_pages);
 #else
 static inline long hugetlb_page_charge(struct list_head *head,
 				       struct hstate *h, long f, long t)
@@ -78,17 +73,5 @@ static inline long  hugetlb_truncate_cgroup_range(struct hstate *h,
 {
 	return region_truncate_range(head, from, end);
 }
-
-static inline int hugetlb_priv_page_charge(struct resv_map *map,
-					   struct hstate *h, long chg)
-{
-	return chg;
-}
-
-static inline void hugetlb_priv_page_uncharge(struct resv_map *map,
-					      int idx, long nr_pages)
-{
-	return;
-}
 #endif /* CONFIG_CGROUP_HUGETLB_RES_CTLR */
 #endif
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 08555c6..aaed6d3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -156,18 +156,15 @@ static struct resv_map *resv_map_alloc(void)
 	return resv_map;
 }
 
-static void resv_map_release(struct kref *ref)
+static void resv_map_release(struct hstate *h, struct resv_map *resv_map)
 {
-	int idx;
-	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
-
-	/* Clear out any active regions before we release the map. */
-	region_truncate(&resv_map->regions, 0);
-	/* drop the hugetlb cgroup charge */
-	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
-		hugetlb_priv_page_uncharge(resv_map, idx,
-					   resv_map->nr_pages[idx]);
-	}
+	/*
+	 * We should not have any regions left here, if we were able to
+	 * do memory allocation when in trunage_cgroup_range.
+	 *
+	 * Clear out any active regions before we release the map
+	 */
+	hugetlb_truncate_cgroup(h, &resv_map->regions, 0);
 	kfree(resv_map);
 }
 
@@ -380,9 +377,7 @@ static void free_huge_page(struct page *page)
 	 */
 	struct hstate *h = page_hstate(page);
 	int nid = page_to_nid(page);
-	struct address_space *mapping;
 
-	mapping = (struct address_space *) page_private(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	BUG_ON(page_count(page));
@@ -398,8 +393,6 @@ static void free_huge_page(struct page *page)
 		enqueue_huge_page(h, page);
 	}
 	spin_unlock(&hugetlb_lock);
-	if (mapping)
-		hugetlb_put_quota(mapping, 1);
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
@@ -822,12 +815,12 @@ static void return_unused_surplus_pages(struct hstate *h,
 static long vma_needs_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
+	pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 
 	if (vma->vm_flags & VM_MAYSHARE) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		return hugetlb_page_charge(&inode->i_mapping->private_list,
 					   h, idx, idx + 1);
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
@@ -842,18 +835,13 @@ static long vma_needs_reservation(struct hstate *h,
 				return -ENOMEM;
 			set_vma_resv_map(vma, resv_map);
 		}
-		return hugetlb_priv_page_charge(resv_map, h, 1);
-	} else  {
-		/* We did the priv page charging in mmap call */
-		long err;
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *reservations = vma_resv_map(vma);
-
-		err = region_chg(&reservations->regions, idx, idx + 1, 0);
-		if (err < 0)
-			return err;
-		return 0;
+		return hugetlb_page_charge(&resv_map->regions,
+					   h, idx, idx + 1);
 	}
+	/*
+	 * We did the private page charging in mmap call
+	 */
+	return 0;
 }
 
 static void vma_uncharge_reservation(struct hstate *h,
@@ -861,40 +849,37 @@ static void vma_uncharge_reservation(struct hstate *h,
 				     unsigned long chg)
 {
 	int idx = h - hstates;
+	struct list_head *region_list;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 
-	if (vma->vm_flags & VM_MAYSHARE) {
-		return hugetlb_page_uncharge(&inode->i_mapping->private_list,
-					     idx, chg << huge_page_order(h));
-	} else {
+	if (vma->vm_flags & VM_MAYSHARE)
+		region_list = &inode->i_mapping->private_list;
+	else {
 		struct resv_map *resv_map = vma_resv_map(vma);
-
-		return hugetlb_priv_page_uncharge(resv_map,
-						  idx,
-						  chg << huge_page_order(h));
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
-		hugetlb_commit_page_charge(&inode->i_mapping->private_list,
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
+	hugetlb_commit_page_charge(region_list, idx, idx + 1);
+	return;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -937,10 +922,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
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
 
@@ -2045,20 +2029,19 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
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
+			resv_map_release(h, resv_map);
+		}
 		if (reserve) {
 			hugetlb_acct_memory(h, -reserve);
 			hugetlb_put_quota(vma->vm_file->f_mapping, reserve);
@@ -2842,6 +2825,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 					vm_flags_t vm_flags)
 {
 	long ret, chg;
+	struct list_head *region_list;
 	struct hstate *h = hstate_inode(inode);
 	struct resv_map *resv_map = NULL;
 	/*
@@ -2859,20 +2843,17 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
-		chg = hugetlb_page_charge(&inode->i_mapping->private_list,
-					  h, from, to);
+		region_list = &inode->i_mapping->private_list;
 	} else {
 		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
 
-		chg = to - from;
-
 		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
-		chg = hugetlb_priv_page_charge(resv_map, h, chg);
+		region_list = &resv_map->regions;
 	}
-
+	chg = hugetlb_page_charge(region_list, h, from, to);
 	if (chg < 0)
 		return chg;
 
@@ -2888,32 +2869,15 @@ int hugetlb_reserve_pages(struct inode *inode,
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
-		hugetlb_commit_page_charge(&inode->i_mapping->private_list,
-					   from, to);
+
+	hugetlb_commit_page_charge(region_list, from, to);
 	return 0;
 err_acct_mem:
 	hugetlb_put_quota(inode->i_mapping, chg);
 err_quota:
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		hugetlb_page_uncharge(&inode->i_mapping->private_list,
-				      h - hstates, chg << huge_page_order(h));
-	else
-		hugetlb_priv_page_uncharge(resv_map, h - hstates,
-					   chg << huge_page_order(h));
+	hugetlb_page_uncharge(region_list, h - hstates,
+			      chg << huge_page_order(h));
 	return ret;
-
 }
 
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
@@ -2927,7 +2891,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
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
