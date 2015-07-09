Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8092E9003CE
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 20:23:17 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so175894228qkh.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:23:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 71si4768330qhy.37.2015.07.08.17.23.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 17:23:16 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 09/10] hugetlbfs: add hugetlbfs_fallocate()
Date: Wed,  8 Jul 2015 17:21:40 -0700
Message-Id: <1436401301-18839-10-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436401301-18839-1-git-send-email-mike.kravetz@oracle.com>
References: <1436401301-18839-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

This is based on the shmem version, but it has diverged quite
a bit.  We have no swap to worry about, nor the new file sealing.
Add synchronication via the fault mutex table to coordinate
page faults,  fallocate allocation and fallocate hole punch.

What this allows us to do is move physical memory in and out of
a hugetlbfs file without having it mapped.  This also gives us
the ability to support MADV_REMOVE since it is currently
implemented using fallocate().  MADV_REMOVE lets madvise() remove
pages from the middle of a hugetlbfs file, which wasn't possible
before.

hugetlbfs fallocate only operates on whole huge pages.

Based-on code-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 158 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/hugetlb.h |   3 +
 mm/hugetlb.c            |   2 +-
 3 files changed, 161 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index f869993..002bafa 100644
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
@@ -479,6 +480,160 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	return 0;
 }
 
+static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
+{
+	struct hstate *h = hstate_inode(inode);
+	loff_t hpage_size = huge_page_size(h);
+	loff_t hole_start, hole_end;
+
+	/*
+	 * For hole punch round up the beginning offset of the hole and
+	 * round down the end.
+	 */
+	hole_start = round_up(offset, hpage_size);
+	hole_end = round_down(offset + len, hpage_size);
+
+	if (hole_end > hole_start) {
+		struct address_space *mapping = inode->i_mapping;
+
+		mutex_lock(&inode->i_mutex);
+		i_mmap_lock_write(mapping);
+		if (!RB_EMPTY_ROOT(&mapping->i_mmap))
+			hugetlb_vmdelete_list(&mapping->i_mmap,
+						hole_start >> PAGE_SHIFT,
+						hole_end  >> PAGE_SHIFT);
+		i_mmap_unlock_write(mapping);
+		remove_inode_hugepages(inode, hole_start, hole_end);
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
+	struct mm_struct *mm = current->mm;
+	loff_t hpage_size = huge_page_size(h);
+	unsigned long hpage_shift = huge_page_shift(h);
+	pgoff_t start, index, end;
+	int error;
+	u32 hash;
+
+	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
+		return -EOPNOTSUPP;
+
+	if (mode & FALLOC_FL_PUNCH_HOLE)
+		return hugetlbfs_punch_hole(inode, offset, len);
+
+	/*
+	 * Default preallocate case.
+	 * For this range, start is rounded down and end is rounded up
+	 * as well as being converted to page offsets.
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
+	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
+	pseudo_vma.vm_file = file;
+
+	for (index = start; index < end; index++) {
+		/*
+		 * This is supposed to be the vaddr where the page is being
+		 * faulted in, but we have no vaddr here.
+		 */
+		struct page *page;
+		unsigned long addr;
+		int avoid_reserve = 0;
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
+
+		/* Get policy based on index */
+		pseudo_vma.vm_policy =
+			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
+							index);
+
+		/* addr is the offset within the file (zero based) */
+		addr = index * hpage_size;
+
+		/* mutex taken here, fault path and hole punch */
+		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
+						index, addr);
+		mutex_lock(&hugetlb_fault_mutex_table[hash]);
+
+		/* See if already present in mapping to avoid alloc/free */
+		page = find_get_page(mapping, index);
+		if (page) {
+			put_page(page);
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			mpol_cond_put(pseudo_vma.vm_policy);
+			continue;
+		}
+
+		/* Allocate page and add to page cache */
+		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
+		mpol_cond_put(pseudo_vma.vm_policy);
+		if (IS_ERR(page)) {
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			error = PTR_ERR(page);
+			goto out;
+		}
+		clear_huge_page(page, addr, pages_per_huge_page(h));
+		__SetPageUptodate(page);
+		error = huge_add_to_page_cache(page, mapping, index);
+		if (unlikely(error)) {
+			put_page(page);
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			goto out;
+		}
+
+		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+
+		/*
+		 * page_put due to reference from alloc_huge_page()
+		 * unlock_page because locked by add_to_page_cache()
+		 */
+		put_page(page);
+		unlock_page(page);
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
 static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = d_inode(dentry);
@@ -790,7 +945,8 @@ const struct file_operations hugetlbfs_file_operations = {
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= noop_fsync,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
-	.llseek		= default_llseek,
+	.llseek			= default_llseek,
+	.fallocate		= hugetlbfs_fallocate,
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 657ef26..386dcbf 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -330,6 +330,8 @@ struct huge_bootmem_page {
 #endif
 };
 
+struct page *alloc_huge_page(struct vm_area_struct *vma,
+				unsigned long addr, int avoid_reserve);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
@@ -483,6 +485,7 @@ static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
 
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
+#define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_noerr(v, a, r) NULL
 #define alloc_bootmem_huge_page(h) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5d48436..aded2c3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1725,7 +1725,7 @@ static void vma_abort_reservation(struct hstate *h,
 	(void)__vma_reservation_common(h, vma, addr, VMA_ABORT_RESV);
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
