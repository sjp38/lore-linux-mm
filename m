Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB9C6B003A
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:37:08 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id i4so5628019oah.27
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 09:37:08 -0800 (PST)
Received: from g1t0027.austin.hp.com (g1t0027.austin.hp.com. [15.216.28.34])
        by mx.google.com with ESMTPS id yn6si5204355oeb.45.2014.01.31.09.37.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 09:37:07 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v2 5/6] mm, hugetlb: use vma_resv_map() map types
Date: Fri, 31 Jan 2014 09:36:45 -0800
Message-Id: <1391189806-13319-6-git-send-email-davidlohr@hp.com>
In-Reply-To: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
References: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Util now, we get a resv_map by two ways according to each mapping type.
This makes code dirty and unreadable. Unify it.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
[code cleanups]
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 95 ++++++++++++++++++++++++++++--------------------------------
 1 file changed, 45 insertions(+), 50 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dfe81b4..7ab913c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -419,13 +419,24 @@ void resv_map_release(struct kref *ref)
 	kfree(resv_map);
 }
 
+static inline struct resv_map *inode_resv_map(struct inode *inode)
+{
+	return inode->i_mapping->private_data;
+}
+
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	if (!(vma->vm_flags & VM_MAYSHARE))
+	if (vma->vm_flags & VM_MAYSHARE) {
+		struct address_space *mapping = vma->vm_file->f_mapping;
+		struct inode *inode = mapping->host;
+
+		return inode_resv_map(inode);
+
+	} else {
 		return (struct resv_map *)(get_vma_private_data(vma) &
 							~HPAGE_RESV_MASK);
-	return NULL;
+	}
 }
 
 static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
@@ -1167,48 +1178,34 @@ static void return_unused_surplus_pages(struct hstate *h,
 static long vma_needs_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	struct inode *inode = mapping->host;
-
-	if (vma->vm_flags & VM_MAYSHARE) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *resv = inode->i_mapping->private_data;
-
-		return region_chg(resv, idx, idx + 1);
+	struct resv_map *resv;
+	pgoff_t idx;
+	long chg;
 
-	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
+	resv = vma_resv_map(vma);
+	if (!resv)
 		return 1;
 
-	} else  {
-		long err;
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *resv = vma_resv_map(vma);
+	idx = vma_hugecache_offset(h, vma, addr);
+	chg = region_chg(resv, idx, idx + 1);
 
-		err = region_chg(resv, idx, idx + 1);
-		if (err < 0)
-			return err;
-		return 0;
-	}
+	if (vma->vm_flags & VM_MAYSHARE)
+		return chg;
+	else
+		return chg < 0 ? chg : 0;
 }
 static void vma_commit_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	struct inode *inode = mapping->host;
-
-	if (vma->vm_flags & VM_MAYSHARE) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *resv = inode->i_mapping->private_data;
-
-		region_add(resv, idx, idx + 1);
+	struct resv_map *resv;
+	pgoff_t idx;
 
-	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
-		struct resv_map *resv = vma_resv_map(vma);
+	resv = vma_resv_map(vma);
+	if (!resv)
+		return;
 
-		/* Mark this page used in the map. */
-		region_add(resv, idx, idx + 1);
-	}
+	idx = vma_hugecache_offset(h, vma, addr);
+	region_add(resv, idx, idx + 1);
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -2271,7 +2268,7 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
 	 * after this open call completes.  It is therefore safe to take a
 	 * new reference here without additional locking.
 	 */
-	if (resv)
+	if (resv && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		kref_get(&resv->refs);
 }
 
@@ -2280,23 +2277,21 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 	struct hstate *h = hstate_vma(vma);
 	struct resv_map *resv = vma_resv_map(vma);
 	struct hugepage_subpool *spool = subpool_vma(vma);
-	unsigned long reserve;
-	unsigned long start;
-	unsigned long end;
+	unsigned long reserve, start, end;
 
-	if (resv) {
-		start = vma_hugecache_offset(h, vma, vma->vm_start);
-		end = vma_hugecache_offset(h, vma, vma->vm_end);
+	if (!resv || !is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+		return;
 
-		reserve = (end - start) -
-			region_count(resv, start, end);
+	start = vma_hugecache_offset(h, vma, vma->vm_start);
+	end = vma_hugecache_offset(h, vma, vma->vm_end);
 
-		kref_put(&resv->refs, resv_map_release);
+	reserve = (end - start) - region_count(resv, start, end);
 
-		if (reserve) {
-			hugetlb_acct_memory(h, -reserve);
-			hugepage_subpool_put_pages(spool, reserve);
-		}
+	kref_put(&resv->refs, resv_map_release);
+
+	if (reserve) {
+		hugetlb_acct_memory(h, -reserve);
+		hugepage_subpool_put_pages(spool, reserve);
 	}
 }
 
@@ -3189,7 +3184,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * called to make the mapping read-write. Assume !vma is a shm mapping
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
-		resv_map = inode->i_mapping->private_data;
+		resv_map = inode_resv_map(inode);
 
 		chg = region_chg(resv_map, from, to);
 
@@ -3248,7 +3243,7 @@ out_err:
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
 	struct hstate *h = hstate_inode(inode);
-	struct resv_map *resv_map = inode->i_mapping->private_data;
+	struct resv_map *resv_map = inode_resv_map(inode);
 	long chg = 0;
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
