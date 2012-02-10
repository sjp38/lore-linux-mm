Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C4FE36B13F1
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 16:37:43 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 11 Feb 2012 03:07:40 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1ALbIhR2416696
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 03:07:18 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1ALbILK001723
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 08:37:18 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 5/6] hugetlbfs: Add controller support for private mapping
Date: Sat, 11 Feb 2012 03:06:45 +0530
Message-Id: <1328909806-15236-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aneesh.kumar@linux.vnet.ibm.com

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

HugeTLB controller is different from a memory controller in that we charge
controller during mmap() time and not fault time. This make sure userspace
can fallback to non-hugepage allocation when mmap fails due to controller
limit.

For private mapping we always charge/uncharge from the current task cgroup.
Charging happens during mmap(2) and uncharge happens during the
vm_operations->close when resv_map refcount reaches zero. The uncharge count
is stored in struct resv_map. For child task after fork the charging happens
during fault time in alloc_huge_page. We also need to make sure for private
mapping each vma for hugeTLB mapping have struct resv_map allocated so that we
can store the uncharge count in resv_map.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |   50 ++++++++++++++++++++++++++++++++
 include/linux/hugetlb.h        |    7 ++++
 include/linux/hugetlb_cgroup.h |   16 ++++++++++
 mm/hugetlb.c                   |   62 ++++++++++++++++++++++++++++++++--------
 4 files changed, 123 insertions(+), 12 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index c478fb0..f828fb2 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -458,3 +458,53 @@ long  hugetlb_truncate_cgroup_charge(struct hstate *h,
 	}
 	return chg;
 }
+
+int hugetlb_priv_page_charge(struct resv_map *map, struct hstate *h, long chg)
+{
+	long csize;
+	int idx, ret;
+	struct hugetlb_cgroup *h_cg;
+	struct res_counter *fail_res;
+
+	/*
+	 * Get the task cgroup within rcu_readlock and also
+	 * get cgroup reference to make sure cgroup destroy won't
+	 * race with page_charge. We don't allow a cgroup destroy
+	 * when the cgroup have some charge against it
+	 */
+	rcu_read_lock();
+	h_cg = task_hugetlbcgroup(current);
+	css_get(&h_cg->css);
+	rcu_read_unlock();
+
+	if (hugetlb_cgroup_is_root(h_cg)) {
+		ret = chg;
+		goto err_out;
+	}
+
+	csize = chg * huge_page_size(h);
+	idx = h - hstates;
+	ret = res_counter_charge(&h_cg->memhuge[idx], csize, &fail_res);
+	if (!ret) {
+		map->nr_pages[idx] += chg << huge_page_order(h);
+		ret = chg;
+	}
+err_out:
+	css_put(&h_cg->css);
+	return ret;
+}
+
+void hugetlb_priv_page_uncharge(struct resv_map *map, int idx, int nr_pages)
+{
+	struct hugetlb_cgroup *h_cg;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	rcu_read_lock();
+	h_cg = task_hugetlbcgroup(current);
+	if (!hugetlb_cgroup_is_root(h_cg)) {
+		res_counter_uncharge(&h_cg->memhuge[idx], csize);
+		map->nr_pages[idx] -= nr_pages;
+	}
+	rcu_read_unlock();
+	return;
+}
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 4392b6a..e2ba381 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -233,6 +233,12 @@ struct hstate {
 	char name[HSTATE_NAME_LEN];
 };
 
+struct resv_map {
+	struct kref refs;
+	int nr_pages[HUGE_MAX_HSTATE];
+	struct list_head regions;
+};
+
 struct huge_bootmem_page {
 	struct list_head list;
 	struct hstate *hstate;
@@ -323,6 +329,7 @@ static inline unsigned hstate_index_to_shift(unsigned index)
 
 #else
 struct hstate {};
+struct resv_map {};
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 3131d62..c3738df 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -32,6 +32,10 @@ extern void hugetlb_page_uncharge(struct list_head *head,
 extern void hugetlb_commit_page_charge(struct list_head *head, long f, long t);
 extern long hugetlb_truncate_cgroup_charge(struct hstate *h,
 					   struct list_head *head, long from);
+extern int hugetlb_priv_page_charge(struct resv_map *map,
+				    struct hstate *h, long chg);
+extern void hugetlb_priv_page_uncharge(struct resv_map *map,
+				       int idx, int nr_pages);
 #else
 static inline long hugetlb_page_charge(struct list_head *head,
 				       struct hstate *h, long f, long t)
@@ -58,5 +62,17 @@ static inline long hugetlb_truncate_cgroup_charge(struct hstate *h,
 {
 	return region_truncate(head, from);
 }
+
+static inline int hugetlb_priv_page_charge(struct resv_map *map,
+					   struct hstate *h, long chg)
+{
+	return chg;
+}
+
+static inline void hugetlb_priv_page_uncharge(struct resv_map *map,
+					      int idx, int nr_pages)
+{
+	return;
+}
 #endif /* CONFIG_CGROUP_HUGETLB_RES_CTLR */
 #endif
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 102410f..5a91838 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -303,14 +303,9 @@ static void set_vma_private_data(struct vm_area_struct *vma,
 	vma->vm_private_data = (void *)value;
 }
 
-struct resv_map {
-	struct kref refs;
-	struct list_head regions;
-};
-
 static struct resv_map *resv_map_alloc(void)
 {
-	struct resv_map *resv_map = kmalloc(sizeof(*resv_map), GFP_KERNEL);
+	struct resv_map *resv_map = kzalloc(sizeof(*resv_map), GFP_KERNEL);
 	if (!resv_map)
 		return NULL;
 
@@ -322,10 +317,16 @@ static struct resv_map *resv_map_alloc(void)
 
 static void resv_map_release(struct kref *ref)
 {
+	int idx;
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
 	/* Clear out any active regions before we release the map. */
 	region_truncate(&resv_map->regions, 0);
+	/* drop the hugetlb cgroup charge */
+	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
+		hugetlb_priv_page_uncharge(resv_map, idx,
+					   resv_map->nr_pages[idx]);
+	}
 	kfree(resv_map);
 }
 
@@ -989,9 +990,20 @@ static long vma_needs_reservation(struct hstate *h,
 		return hugetlb_page_charge(&inode->i_mapping->private_list,
 					   h, idx, idx + 1);
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		return 1;
-
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
+		return hugetlb_priv_page_charge(resv_map, h, 1);
 	} else  {
+		/* We did the priv page charging in mmap call */
 		long err;
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
@@ -1007,14 +1019,20 @@ static void vma_uncharge_reservation(struct hstate *h,
 				     struct vm_area_struct *vma,
 				     unsigned long chg)
 {
+	int idx = h - hstates;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		return hugetlb_page_uncharge(&inode->i_mapping->private_list,
-					     h - hstates,
-					     chg << huge_page_order(h));
+					     idx, chg << huge_page_order(h));
+	} else {
+		struct resv_map *resv_map = vma_resv_map(vma);
+
+		return hugetlb_priv_page_uncharge(resv_map,
+						  idx,
+						  chg << huge_page_order(h));
 	}
 }
 
@@ -2165,6 +2183,22 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
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
@@ -2968,7 +3002,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 {
 	long ret, chg;
 	struct hstate *h = hstate_inode(inode);
-
+	struct resv_map *resv_map = NULL;
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
 	 * attempt will be made for VM_NORESERVE to allocate a page
@@ -2987,7 +3021,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 		chg = hugetlb_page_charge(&inode->i_mapping->private_list,
 					  h, from, to);
 	} else {
-		struct resv_map *resv_map = resv_map_alloc();
+		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
 
@@ -2995,6 +3029,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 
 		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
+		chg = hugetlb_priv_page_charge(resv_map, h, chg);
 	}
 
 	if (chg < 0)
@@ -3033,6 +3068,9 @@ err_quota:
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
 		hugetlb_page_uncharge(&inode->i_mapping->private_list,
 				      h - hstates, chg << huge_page_order(h));
+	else
+		hugetlb_priv_page_uncharge(resv_map, h - hstates,
+					   chg << huge_page_order(h));
 	return ret;
 
 }
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
