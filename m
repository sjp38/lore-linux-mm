Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 89DC26B00EA
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:17:44 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:13:56 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219BRwp3653792
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:11:27 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219GwMB004362
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:16:58 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 5/9] hugetlbfs: Add memory controller support for shared mapping
Date: Thu,  1 Mar 2012 14:46:16 +0530
Message-Id: <1330593380-1361-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For shared mapping we need to track the memory controller along with the range.
If two task in two different cgroup map the same area only the non-overlapping
part should be charged to the second task. Hence we need to track the memcg
along with range.  We always charge during mmap(2) and we do uncharge during
truncate. The charge list is tracked in the inode->i_mapping->private_list.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c |  129 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 107 insertions(+), 22 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fd6d38..664c663 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -22,6 +22,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/region.h>
+#include <linux/memcontrol.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -72,6 +73,59 @@ static DEFINE_SPINLOCK(hugetlb_lock);
  *
  */
 
+long hugetlb_page_charge(struct list_head *head,
+			 struct hstate *h, long from, long to)
+{
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
+	long chg;
+	from = from << huge_page_order(h);
+	to   = to << huge_page_order(h);
+	chg  = mem_cgroup_try_noreclaim_charge(head, from, to, h - hstates);
+	if (chg > 0)
+		return chg >> huge_page_order(h);
+	return chg;
+#else
+	return region_chg(head, from, to, 0);
+#endif
+}
+
+void hugetlb_page_uncharge(struct list_head *head, int idx, long nr_pages)
+{
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
+	return mem_cgroup_noreclaim_uncharge(head, idx, nr_pages);
+#else
+	return;
+#endif
+}
+
+void hugetlb_commit_page_charge(struct hstate *h,
+				struct list_head *head, long from, long to)
+{
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
+	from = from << huge_page_order(h);
+	to   = to << huge_page_order(h);
+	return mem_cgroup_commit_noreclaim_charge(head, from, to);
+#else
+	return region_add(head, from, to, 0);
+#endif
+}
+
+long hugetlb_truncate_cgroup(struct hstate *h,
+			     struct list_head *head, long from)
+{
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
+	long chg;
+	from = from << huge_page_order(h);
+	chg  = mem_cgroup_truncate_chglist_range(head, from,
+						 ULONG_MAX, h - hstates);
+	if (chg > 0)
+		return chg >> huge_page_order(h);
+	return chg;
+#else
+	return region_truncate(head, from);
+#endif
+}
+
 /*
  * Convert the address within this vma to the page offset within
  * the mapping, in pagecache page units; huge pages here.
@@ -840,9 +894,8 @@ static long vma_needs_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		return region_chg(&inode->i_mapping->private_list,
-				  idx, idx + 1, 0);
-
+		return hugetlb_page_charge(&inode->i_mapping->private_list,
+					   h, idx, idx + 1);
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
 
@@ -857,16 +910,33 @@ static long vma_needs_reservation(struct hstate *h,
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
-		region_add(&inode->i_mapping->private_list, idx, idx + 1, 0);
-
+		hugetlb_commit_page_charge(h, &inode->i_mapping->private_list,
+					   idx, idx + 1);
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
@@ -895,9 +965,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
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
@@ -906,7 +979,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
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
@@ -914,7 +990,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long) mapping);
 
 	vma_commit_reservation(h, vma, addr);
-
 	return page;
 }
 
@@ -2744,9 +2819,10 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * to reserve the full area even if read-only as mprotect() may be
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		chg = region_chg(&inode->i_mapping->private_list, from, to, 0);
-	else {
+	if (!vma || vma->vm_flags & VM_MAYSHARE) {
+		chg = hugetlb_page_charge(&inode->i_mapping->private_list,
+					  h, from, to);
+	} else {
 		struct resv_map *resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
@@ -2761,19 +2837,17 @@ int hugetlb_reserve_pages(struct inode *inode,
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
@@ -2786,15 +2860,26 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&inode->i_mapping->private_list, from, to, 0);
+		hugetlb_commit_page_charge(h, &inode->i_mapping->private_list,
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
