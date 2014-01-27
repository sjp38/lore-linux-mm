Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id D69CF6B0031
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 22:52:52 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id m1so6103060oag.20
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 19:52:52 -0800 (PST)
Received: from g4t0017.houston.hp.com (g4t0017.houston.hp.com. [15.201.24.20])
        by mx.google.com with ESMTPS id bx5si4472650oec.130.2014.01.26.19.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 19:52:51 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/8] mm, hugetlb: unify region structure handling
Date: Sun, 26 Jan 2014 19:52:19 -0800
Message-Id: <1390794746-16755-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, to track reserved and allocated regions, we use two different
ways, depending on the mapping. For MAP_SHARED, we use address_mapping's
private_list and, while for MAP_PRIVATE, we use a resv_map.

Now, we are preparing to change a coarse grained lock which protect a
region structure to fine grained lock, and this difference hinder it.
So, before changing it, unify region structure handling, consistently
using a resv_map regardless of the kind of mapping.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
[Updated changelog]
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 fs/hugetlbfs/inode.c    | 17 +++++++++++++++--
 include/linux/hugetlb.h |  9 +++++++++
 mm/hugetlb.c            | 37 +++++++++++++++++++++----------------
 3 files changed, 45 insertions(+), 18 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d19b30a..2040275 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -366,7 +366,13 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
+	struct resv_map *resv_map;
+
 	truncate_hugepages(inode, 0);
+	resv_map = (struct resv_map *)inode->i_mapping->private_data;
+	/* root inode doesn't have the resv_map, so we should check it */
+	if (resv_map)
+		resv_map_release(&resv_map->refs);
 	clear_inode(inode);
 }
 
@@ -476,6 +482,11 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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
@@ -487,7 +498,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-		INIT_LIST_HEAD(&inode->i_mapping->private_list);
+		inode->i_mapping->private_data = resv_map;
 		info = HUGETLBFS_I(inode);
 		/*
 		 * The policy is initialized here even if we are creating a
@@ -517,7 +528,9 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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
index d01cc97..29c9371 100644
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
index 04306b9..fbed1b7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -376,12 +376,7 @@ static void set_vma_private_data(struct vm_area_struct *vma,
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
@@ -393,7 +388,7 @@ static struct resv_map *resv_map_alloc(void)
 	return resv_map;
 }
 
-static void resv_map_release(struct kref *ref)
+void resv_map_release(struct kref *ref)
 {
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
@@ -1155,8 +1150,9 @@ static long vma_needs_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		return region_chg(&inode->i_mapping->private_list,
-							idx, idx + 1);
+		struct resv_map *resv = inode->i_mapping->private_data;
+
+		return region_chg(&resv->regions, idx, idx + 1);
 
 	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		return 1;
@@ -1180,7 +1176,9 @@ static void vma_commit_reservation(struct hstate *h,
 
 	if (vma->vm_flags & VM_MAYSHARE) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		region_add(&inode->i_mapping->private_list, idx, idx + 1);
+		struct resv_map *resv = inode->i_mapping->private_data;
+
+		region_add(&resv->regions, idx, idx + 1);
 
 	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
@@ -3161,6 +3159,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	long ret, chg;
 	struct hstate *h = hstate_inode(inode);
 	struct hugepage_subpool *spool = subpool_inode(inode);
+	struct resv_map *resv_map;
 
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
@@ -3176,10 +3175,13 @@ int hugetlb_reserve_pages(struct inode *inode,
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
 
@@ -3222,7 +3224,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		region_add(&inode->i_mapping->private_list, from, to);
+		region_add(&resv_map->regions, from, to);
 	return 0;
 out_err:
 	if (vma)
@@ -3233,9 +3235,12 @@ out_err:
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
