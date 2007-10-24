Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9ODNxtx008097
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ODNxVK113818
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ODNxDR005277
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:59 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/3] hugetlb: Allow bulk updating in hugetlb_*_quota()
Date: Wed, 24 Oct 2007 06:23:57 -0700
Message-Id: <20071024132357.13013.67944.stgit@kernel>
In-Reply-To: <20071024132335.13013.76227.stgit@kernel>
References: <20071024132335.13013.76227.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Add a second parameter 'delta' to hugetlb_get_quota and hugetlb_put_quota
to allow bulk updating of the sbinfo->free_blocks counter.  This will be
used by the next patch in the series.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c    |   12 ++++++------
 include/linux/hugetlb.h |    4 ++--
 mm/hugetlb.c            |   12 ++++++------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 04598e1..df15dee 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -364,7 +364,7 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 			++next;
 			truncate_huge_page(page);
 			unlock_page(page);
-			hugetlb_put_quota(mapping);
+			hugetlb_put_quota(mapping, 1);
 			freed++;
 		}
 		huge_pagevec_release(&pvec);
@@ -859,15 +859,15 @@ out_free:
 	return -ENOMEM;
 }
 
-int hugetlb_get_quota(struct address_space *mapping)
+int hugetlb_get_quota(struct address_space *mapping, long delta)
 {
 	int ret = 0;
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
 
 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks > 0)
-			sbinfo->free_blocks--;
+		if (sbinfo->free_blocks - delta >= 0)
+			sbinfo->free_blocks -= delta;
 		else
 			ret = -ENOMEM;
 		spin_unlock(&sbinfo->stat_lock);
@@ -876,13 +876,13 @@ int hugetlb_get_quota(struct address_space *mapping)
 	return ret;
 }
 
-void hugetlb_put_quota(struct address_space *mapping)
+void hugetlb_put_quota(struct address_space *mapping, long delta)
 {
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
 
 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
-		sbinfo->free_blocks++;
+		sbinfo->free_blocks += delta;
 		spin_unlock(&sbinfo->stat_lock);
 	}
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ea0f50b..770dbed 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -165,8 +165,8 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t);
-int hugetlb_get_quota(struct address_space *mapping);
-void hugetlb_put_quota(struct address_space *mapping);
+int hugetlb_get_quota(struct address_space *mapping, long delta);
+void hugetlb_put_quota(struct address_space *mapping, long delta);
 
 static inline int is_file_hugepages(struct file *file)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0d645ca..eaade8c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -693,7 +693,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			 * this occurs when the file is truncated.
 			 */
 			VM_BUG_ON(PageMapping(page));
-			hugetlb_put_quota(vma->vm_file->f_mapping);
+			hugetlb_put_quota(vma->vm_file->f_mapping, 1);
 			free_huge_page(page);
 		}
 	}
@@ -732,7 +732,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
-	if (hugetlb_get_quota(vma->vm_file->f_mapping))
+	if (hugetlb_get_quota(vma->vm_file->f_mapping, 1))
 		return VM_FAULT_SIGBUS;
 
 	page_cache_get(old_page);
@@ -784,11 +784,11 @@ retry:
 		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 		if (idx >= size)
 			goto out;
-		if (hugetlb_get_quota(mapping))
+		if (hugetlb_get_quota(mapping, 1))
 			goto out;
 		page = alloc_huge_page(vma, address);
 		if (!page) {
-			hugetlb_put_quota(mapping);
+			hugetlb_put_quota(mapping, 1);
 			ret = VM_FAULT_OOM;
 			goto out;
 		}
@@ -800,7 +800,7 @@ retry:
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
 				put_page(page);
-				hugetlb_put_quota(mapping);
+				hugetlb_put_quota(mapping, 1);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
@@ -834,7 +834,7 @@ out:
 
 backout:
 	spin_unlock(&mm->page_table_lock);
-	hugetlb_put_quota(mapping);
+	hugetlb_put_quota(mapping, 1);
 	unlock_page(page);
 	put_page(page);
 	goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
