Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6286A6B0070
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:03:29 -0400 (EDT)
Received: by oblw8 with SMTP id w8so55612271obl.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 16:03:29 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r138si6503131oie.61.2015.04.16.16.03.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 16:03:28 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/4] hugetlbfs: add hugetlbfs_fallocate()
Date: Thu, 16 Apr 2015 16:02:57 -0700
Message-Id: <1429225378-22965-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
References: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

This is based on the shmem version, but it has diverged quite
a bit.  We have no swap to worry about, nor the new file sealing.

What this allows us to do is move physical memory in and out of
a hugetlbfs file without having it mapped.  This also gives us
the ability to support MADV_REMOVE since it is currently
implemented using fallocate().  MADV_REMOVE lets us remove data
from the middle of a hugetlbfs file, which wasn't possible before.

hugetlbfs fallocate only operates on whole huge pages.

Based-on code-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 139 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/hugetlb.h |   3 ++
 mm/hugetlb.c            |   2 +-
 3 files changed, 143 insertions(+), 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d5b67fd..6d48c8f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/thread_info.h>
 #include <asm/current.h>
 #include <linux/sched.h>		/* remove ASAP */
+#include <linux/falloc.h>
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/file.h>
@@ -377,6 +378,143 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart, loff_t lend)
 	hugetlb_unreserve_pages(inode, start, freed);
 }
 
+static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
+{
+	struct hstate *h = hstate_inode(inode);
+	unsigned long hpage_size = huge_page_size(h);
+	loff_t hole_start, hole_end;
+
+	/*
+	 * For hole punch round up the beginning offset of the hole and
+	 * round down the end.
+	 */
+	hole_start = (offset + hpage_size - 1) & ~huge_page_mask(h);
+	hole_end = (offset + len - (hpage_size - 1)) * ~huge_page_mask(h);
+
+	if ((u64)hole_end > (u64)hole_start) {
+		struct address_space *mapping = &inode->i_data;
+
+		mutex_lock(&inode->i_mutex);
+		unmap_mapping_range(mapping, hole_start, hole_end, 0);
+		truncate_hugepages(inode, hole_start, hole_end);
+		mutex_unlock(&inode->i_mutex);
+	}
+
+	return 0;
+}
+
+static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
+				loff_t len)
+{
+	struct inode *inode = file_inode(file);
+	struct address_space *mapping = inode->i_mapping;
+	struct hstate *h = hstate_inode(inode);
+	struct vm_area_struct pseudo_vma;
+	unsigned long hpage_size = huge_page_size(h);
+	unsigned long hpage_shift = huge_page_shift(h);
+	pgoff_t start, index, end;
+	unsigned long addr;
+	int error;
+
+	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
+		return -EOPNOTSUPP;
+
+	if (mode & FALLOC_FL_PUNCH_HOLE)
+		return hugetlbfs_punch_hole(inode, offset, len);
+
+	/*
+	 * Default preallocate case.
+	 * For this range, start is rounded down and end is rounded up.
+	 */
+	start = offset >> hpage_shift;
+	end = (offset + len + hpage_size - 1) >> hpage_shift;
+
+	mutex_lock(&inode->i_mutex);
+
+	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
+	error = inode_newsize_ok(inode, offset + len);
+	if (error)
+		goto out;
+
+	/*
+	 * Initialize a pseudo vma that just contains the policy used
+	 * when allocating the huge pages.  The actual policy field
+	 * (vm_policy) is determined based on the index in the loop below.
+	 */
+	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
+	pseudo_vma.vm_start = 0;
+	pseudo_vma.vm_flags |= (VM_HUGETLB | VM_MAYSHARE);
+	pseudo_vma.vm_file = file;
+
+	/* addr is the offset within the file (zero based) */
+	addr = start * hpage_size;
+	for (index = start; index < end; index++) {
+		/*
+		 * This is supposed to be the vaddr where the page is being
+		 * faulted in, but we have no vaddr here.
+		 */
+		struct page *page;
+		int avoid_reserve = 1;
+
+		cond_resched();
+
+		/*
+		 * fallocate(2) manpage permits EINTR; we may have been
+		 * interrupted because we are using up too much memory.
+		 */
+		if (signal_pending(current)) {
+			error = -EINTR;
+			break;
+		}
+		page = find_get_page(mapping, index);
+		if (page) {
+			put_page(page);
+			continue;
+		}
+
+		/* Get policy based on index */
+		pseudo_vma.vm_policy =
+			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
+							index);
+
+		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
+		mpol_cond_put(pseudo_vma.vm_policy);
+		if (IS_ERR(page)) {
+			error = PTR_ERR(page);
+			goto out;
+		}
+		clear_huge_page(page, addr, pages_per_huge_page(h));
+		__SetPageUptodate(page);
+		error = huge_add_to_page_cache(page, mapping, index);
+		if (error) {
+			put_page(page);
+			/* Keep going if we see an -EEXIST */
+			if (error != -EEXIST)
+				goto out;  /* FIXME, need to free? */
+		}
+
+		/*
+		 * page_put due to reference from alloc_huge_page()
+		 * unlock_page because locked by add_to_page_cache()
+		 */
+		put_page(page);
+		unlock_page(page);
+
+		/* Increment addr for next huge page */
+		addr += hpage_size;
+	}
+
+	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
+		i_size_write(inode, offset + len);
+	inode->i_ctime = CURRENT_TIME;
+	spin_lock(&inode->i_lock);
+	inode->i_private = NULL;
+	spin_unlock(&inode->i_lock);
+out:
+	mutex_unlock(&inode->i_mutex);
+	return error;
+}
+
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
@@ -743,6 +881,7 @@ const struct file_operations hugetlbfs_file_operations = {
 	.fsync			= noop_fsync,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
 	.llseek		= default_llseek,
+	.fallocate		= hugetlbfs_fallocate,
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6425945..d96b88e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -322,6 +322,8 @@ struct huge_bootmem_page {
 #endif
 };
 
+struct page *alloc_huge_page(struct vm_area_struct *vma,
+				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
@@ -476,6 +478,7 @@ static inline bool hugepages_supported(void)
 
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
+#define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_noerr(v, a, r) NULL
 #define alloc_bootmem_huge_page(h) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7cda328..e130c6d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1363,7 +1363,7 @@ static void vma_commit_reservation(struct hstate *h,
 	region_add(resv, idx, idx + 1);
 }
 
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
+struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
 	struct hugepage_subpool *spool = subpool_vma(vma);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
