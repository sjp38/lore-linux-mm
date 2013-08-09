Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 11FBB6B003A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:13 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 07/20] mm, hugetlb: unify region structure handling
Date: Fri,  9 Aug 2013 18:26:25 +0900
Message-Id: <1376040398-11212-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, to track a reserved and allocated region, we use two different
ways for MAP_SHARED and MAP_PRIVATE. For MAP_SHARED, we use
address_mapping's private_list and, for MAP_PRIVATE, we use a resv_map.
Now, we are preparing to change a coarse grained lock which protect
a region structure to fine grained lock, and this difference hinder it.
So, before changing it, unify region structure handling.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a3f868a..9bf2c4a 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -366,7 +366,12 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
+	struct resv_map *resv_map;
+
 	truncate_hugepages(inode, 0);
+	resv_map = (struct resv_map *)inode->i_mapping->private_data;
+	if (resv_map)
+		kref_put(&resv_map->refs, resv_map_release);
 	clear_inode(inode);
 }
 
@@ -468,6 +473,11 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
+	struct resv_map *resv_map;
+
+	resv_map = resv_map_alloc();
+	if (!resv_map)
+		return NULL;
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -477,7 +487,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-		INIT_LIST_HEAD(&inode->i_mapping->private_list);
+		inode->i_mapping->private_data = resv_map;
 		info = HUGETLBFS_I(inode);
 		/*
 		 * The policy is initialized here even if we are creating a
@@ -507,7 +517,9 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	}
+	} else
+		kref_put(&resv_map->refs, resv_map_release);
+
 	return inode;
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b4890f..2677c07 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -5,6 +5,8 @@
 #include <linux/fs.h>
 #include <linux/hugetlb_inline.h>
 #include <linux/cgroup.h>
+#include <linux/list.h>
+#include <linux/kref.h>
 
 struct ctl_table;
 struct user_struct;
@@ -22,6 +24,13 @@ struct hugepage_subpool {
 	long max_hpages, used_hpages;
 };
 
+struct resv_map {
+	struct kref refs;
+	struct list_head regions;
+};
+extern struct resv_map *resv_map_alloc(void);
+void resv_map_release(struct kref *ref);
+
 extern spinlock_t hugetlb_lock;
 extern int hugetlb_max_hstate __read_mostly;
 #define for_each_hstate(h) \
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3f834f1..8751e2c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -375,12 +375,7 @@ static void set_vma_private_data(struct vm_area_struct *vma,
 	vma->vm_private_data = (void *)value;
 }
 
-struct resv_map {
-	struct kref refs;
-	struct list_head regions;
-};
-
-static struct resv_map *resv_map_alloc(void)
+struct resv_map *resv_map_alloc(void)
 {
 	struct resv_map *resv_map = kmalloc(sizeof(*resv_map), GFP_KERNEL);
 	if (!resv_map)
@@ -392,7 +387,7 @@ static struct resv_map *resv_map_alloc(void)
 	return resv_map;
 }
 
-static void resv_map_release(struct kref *ref)
+void resv_map_release(struct kref *ref)
 {
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
@@ -1092,8 +1087,9 @@ static long vma_needs_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		return region_chg(&inode->i_mapping->private_list,
-							idx, idx + 1);
+		struct resv_map *resv = inode->i_mapping->private_data;
+
+		return region_chg(&resv->regions, idx, idx + 1);
 
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
@@ -1117,7 +1113,9 @@ static void vma_commit_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		region_add(&inode->i_mapping->private_list, idx, idx + 1);
+		struct resv_map *resv = inode->i_mapping->private_data;
+
+		region_add(&resv->regions, idx, idx + 1);
 
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
@@ -3074,6 +3072,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	long ret, chg;
 	struct hstate *h = hstate_inode(inode);
 	struct hugepage_subpool *spool = subpool_inode(inode);
+	struct resv_map *resv_map;
 
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
@@ -3089,10 +3088,13 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * to reserve the full area even if read-only as mprotect() may be
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
-	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		chg = region_chg(&inode->i_mapping->private_list, from, to);
-	else {
-		struct resv_map *resv_map = resv_map_alloc();
+	if (!vma || vma->vm_flags & VM_MAYSHARE) {
+		resv_map = inode->i_mapping->private_data;
+
+		chg = region_chg(&resv_map->regions, from, to);
+
+	} else {
+		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;
 
@@ -3135,7 +3137,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&inode->i_mapping->private_list, from, to);
+		region_add(&resv_map->regions, from, to);
 	return 0;
 out_err:
 	if (vma)
@@ -3146,9 +3148,12 @@ out_err:
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
 	struct hstate *h = hstate_inode(inode);
-	long chg = region_truncate(&inode->i_mapping->private_list, offset);
+	struct resv_map *resv_map = inode->i_mapping->private_data;
+	long chg = 0;
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
+	if (resv_map)
+		chg = region_truncate(&resv_map->regions, offset);
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
