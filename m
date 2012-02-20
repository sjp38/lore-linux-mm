Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E7B906B0092
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:38 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:19:01 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBGp2s3059756
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:16:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBM8kD019851
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:08 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 4/9] hugetlbfs: Add controller support for shared mapping
Date: Mon, 20 Feb 2012 16:51:37 +0530
Message-Id: <1329736902-26870-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

HugeTLB controller is different from a memory controller in that we charge
controller during mmap() time and not fault time. This make sure userspace
can fallback to non-hugepage allocation when mmap fails during to controller
limit.

For shared mapping we need to track the hugetlb cgroup along with the range.
If two task in two different cgroup map the same area only the non-overlapping
part should be charged to the second task. Hence we need to track the cgroup
along with range.  We always charge during mmap(2) and we do uncharge during
truncate. The region list is tracked in the inode->i_mapping->private_list.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |  114 ++++++++++++++++++++++++++++++++++++++++
 fs/hugetlbfs/inode.c           |    1 +
 include/linux/hugetlb_cgroup.h |   39 ++++++++++++++
 mm/hugetlb.c                   |   84 ++++++++++++++++++++---------
 4 files changed, 212 insertions(+), 26 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index 9bd2691..4806d43 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -17,6 +17,7 @@
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
 #include <linux/res_counter.h>
+#include <linux/list.h>
 
 /* lifted from mem control */
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -333,3 +334,116 @@ struct cgroup_subsys hugetlb_subsys = {
 	.populate   = hugetlbcgroup_populate,
 	.subsys_id  = hugetlb_subsys_id,
 };
+
+long hugetlb_page_charge(struct list_head *head,
+			struct hstate *h, long f, long t)
+{
+	long chg;
+	int ret = 0, idx;
+	unsigned long csize;
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
+	chg = region_chg_with_same(head, f, t, (unsigned long)h_cg);
+	if (chg < 0)
+		goto err_out;
+
+	if (hugetlb_cgroup_is_root(h_cg))
+		goto err_out;
+
+	csize = chg * huge_page_size(h);
+	idx = h - hstates;
+	ret = res_counter_charge(&h_cg->memhuge[idx], csize, &fail_res);
+
+err_out:
+	/* Now that we have charged we can drop cgroup reference */
+	css_put(&h_cg->css);
+	if (!ret)
+		return chg;
+
+	/* We don't worry about region_uncharge */
+	return ret;
+}
+
+void hugetlb_page_uncharge(struct list_head *head, int idx, long nr_pages)
+{
+	struct hugetlb_cgroup *h_cg;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	rcu_read_lock();
+	h_cg = task_hugetlbcgroup(current);
+
+	if (!hugetlb_cgroup_is_root(h_cg))
+		res_counter_uncharge(&h_cg->memhuge[idx], csize);
+	rcu_read_unlock();
+	/*
+	 * We could ideally remove zero size regions from
+	 * resv map hcg_regions here
+	 */
+	return;
+}
+
+void hugetlb_commit_page_charge(struct list_head *head, long f, long t)
+{
+	struct hugetlb_cgroup *h_cg;
+
+	rcu_read_lock();
+	h_cg = task_hugetlbcgroup(current);
+	region_add_with_same(head, f, t, (unsigned long)h_cg);
+	rcu_read_unlock();
+	return;
+}
+
+long hugetlb_truncate_cgroup(struct hstate *h,
+			     struct list_head *head, long end)
+{
+	long chg = 0, csize;
+	int idx = h - hstates;
+	struct hugetlb_cgroup *h_cg;
+	struct file_region_with_data *rg, *trg;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (end <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (end > rg->from) {
+		chg = rg->to - end;
+		rg->to = end;
+		h_cg = (struct hugetlb_cgroup *)rg->data;
+		if (!hugetlb_cgroup_is_root(h_cg)) {
+			csize = chg * huge_page_size(h);
+			res_counter_uncharge(&h_cg->memhuge[idx], csize);
+		}
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+
+	/* Drop any remaining regions. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		chg += rg->to - rg->from;
+		h_cg = (struct hugetlb_cgroup *)rg->data;
+		if (!hugetlb_cgroup_is_root(h_cg)) {
+			csize = (rg->to - rg->from) * huge_page_size(h);
+			res_counter_uncharge(&h_cg->memhuge[idx], csize);
+		}
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 1e85a7a..2680578 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/magic.h>
 #include <linux/migrate.h>
+#include <linux/hugetlb_cgroup.h>
 
 #include <asm/uaccess.h>
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 11cd6c4..9240e99 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -15,8 +15,47 @@
 #ifndef _LINUX_HUGETLB_CGROUP_H
 #define _LINUX_HUGETLB_CGROUP_H
 
+extern long region_add(struct list_head *head, long f, long t);
+extern long region_chg(struct list_head *head, long f, long t);
+extern long region_truncate(struct list_head *head, long end);
+extern long region_count(struct list_head *head, long f, long t);
+
+#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
 extern u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft);
 extern int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
 				const char *buffer);
 extern int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event);
+extern long hugetlb_page_charge(struct list_head *head,
+				struct hstate *h, long f, long t);
+extern void hugetlb_page_uncharge(struct list_head *head,
+				  int idx, long nr_pages);
+extern void hugetlb_commit_page_charge(struct list_head *head, long f, long t);
+extern long hugetlb_truncate_cgroup(struct hstate *h,
+				    struct list_head *head, long from);
+#else
+static inline long hugetlb_page_charge(struct list_head *head,
+				       struct hstate *h, long f, long t)
+{
+	return region_chg(head, f, t);
+}
+
+static inline void hugetlb_page_uncharge(struct list_head *head,
+					 int idx, long nr_pages)
+{
+	return;
+}
+
+static inline void hugetlb_commit_page_charge(struct list_head *head,
+					      long f, long t)
+{
+	region_add(head, f, t);
+	return;
+}
+
+static inline long hugetlb_truncate_cgroup(struct hstate *h,
+					   struct list_head *head, long from)
+{
+	return region_truncate(head, from);
+}
+#endif /* CONFIG_CGROUP_HUGETLB_RES_CTLR */
 #endif
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 865b41f..80ee085 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -78,7 +78,7 @@ struct file_region {
 	long to;
 };
 
-static long region_add(struct list_head *head, long f, long t)
+long region_add(struct list_head *head, long f, long t)
 {
 	struct file_region *rg, *nrg, *trg;
 
@@ -114,7 +114,7 @@ static long region_add(struct list_head *head, long f, long t)
 	return 0;
 }
 
-static long region_chg(struct list_head *head, long f, long t)
+long region_chg(struct list_head *head, long f, long t)
 {
 	struct file_region *rg, *nrg;
 	long chg = 0;
@@ -163,7 +163,7 @@ static long region_chg(struct list_head *head, long f, long t)
 	return chg;
 }
 
-static long region_truncate(struct list_head *head, long end)
+long region_truncate(struct list_head *head, long end)
 {
 	struct file_region *rg, *trg;
 	long chg = 0;
@@ -193,7 +193,7 @@ static long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
-static long region_count(struct list_head *head, long f, long t)
+long region_count(struct list_head *head, long f, long t)
 {
 	struct file_region *rg;
 	long chg = 0;
@@ -983,11 +983,11 @@ static long vma_needs_reservation(struct hstate *h,
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
+
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		return region_chg(&inode->i_mapping->private_list,
-							idx, idx + 1);
-
+		return hugetlb_page_charge(&inode->i_mapping->private_list,
+					   h, idx, idx + 1);
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
 
@@ -1002,16 +1002,33 @@ static long vma_needs_reservation(struct hstate *h,
 		return 0;
 	}
 }
+
+static void vma_uncharge_reservation(struct hstate *h,
+				     struct vm_area_struct *vma,
+				     unsigned long chg)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct inode *inode = mapping->host;
+
+
+	if (vma->vm_flags & VM_MAYSHARE) {
+		return hugetlb_page_uncharge(&inode->i_mapping->private_list,
+					     h - hstates,
+					     chg << huge_page_order(h));
+	}
+}
+
 static void vma_commit_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
+
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		region_add(&inode->i_mapping->private_list, idx, idx + 1);
-
+		hugetlb_commit_page_charge(&inode->i_mapping->private_list,
+					   idx, idx + 1);
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
@@ -1040,9 +1057,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
 		return ERR_PTR(-VM_FAULT_OOM);
-	if (chg)
-		if (hugetlb_get_quota(inode->i_mapping, chg))
+	if (chg) {
+		if (hugetlb_get_quota(inode->i_mapping, chg)) {
+			vma_uncharge_reservation(h, vma, chg);
 			return ERR_PTR(-VM_FAULT_SIGBUS);
+		}
+	}
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
@@ -1051,7 +1071,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (!page) {
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
-			hugetlb_put_quota(inode->i_mapping, chg);
+			if (chg) {
+				vma_uncharge_reservation(h, vma, chg);
+				hugetlb_put_quota(inode->i_mapping, chg);
+			}
 			return ERR_PTR(-VM_FAULT_SIGBUS);
 		}
 	}
@@ -1059,7 +1082,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long) mapping);
 
 	vma_commit_reservation(h, vma, addr);
-
 	return page;
 }
 
@@ -2961,9 +2983,10 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * to reserve the full area even if read-only as mprotect() may be
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		chg = region_chg(&inode->i_mapping->private_list, from, to);
-	else {
+	if (!vma || vma->vm_flags & VM_MAYSHARE) {
+		chg = hugetlb_page_charge(&inode->i_mapping->private_list,
+					  h, from, to);
+	} else {
 		struct resv_map *resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
@@ -2978,19 +3001,17 @@ int hugetlb_reserve_pages(struct inode *inode,
 		return chg;
 
 	/* There must be enough filesystem quota for the mapping */
-	if (hugetlb_get_quota(inode->i_mapping, chg))
-		return -ENOSPC;
-
+	if (hugetlb_get_quota(inode->i_mapping, chg)) {
+		ret = -ENOSPC;
+		goto err_quota;
+	}
 	/*
 	 * Check enough hugepages are available for the reservation.
 	 * Hand back the quota if there are not
 	 */
 	ret = hugetlb_acct_memory(h, chg);
-	if (ret < 0) {
-		hugetlb_put_quota(inode->i_mapping, chg);
-		return ret;
-	}
-
+	if (ret < 0)
+		goto err_acct_mem;
 	/*
 	 * Account for the reservations made. Shared mappings record regions
 	 * that have reservations as they are shared by multiple VMAs.
@@ -3003,15 +3024,26 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&inode->i_mapping->private_list, from, to);
+		hugetlb_commit_page_charge(&inode->i_mapping->private_list,
+					   from, to);
 	return 0;
+err_acct_mem:
+	hugetlb_put_quota(inode->i_mapping, chg);
+err_quota:
+	if (!vma || vma->vm_flags & VM_MAYSHARE)
+		hugetlb_page_uncharge(&inode->i_mapping->private_list,
+				      h - hstates, chg << huge_page_order(h));
+	return ret;
+
 }
 
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
+	long chg;
 	struct hstate *h = hstate_inode(inode);
-	long chg = region_truncate(&inode->i_mapping->private_list, offset);
 
+	chg = hugetlb_truncate_cgroup(h, &inode->i_mapping->private_list,
+				      offset);
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
