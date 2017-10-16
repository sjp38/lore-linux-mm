Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEFB6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:39:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m189so17229766qke.21
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:39:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e88si5838624qtb.484.2017.10.16.15.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 15:39:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: hugetlbfs: prevent UFFDIO_COPY to fill beyond the end of i_size
Date: Tue, 17 Oct 2017 00:39:14 +0200
Message-Id: <20171016223914.2421-2-aarcange@redhat.com>
In-Reply-To: <20171016223914.2421-1-aarcange@redhat.com>
References: <20171016223914.2421-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

kernel BUG at fs/hugetlbfs/inode.c:484!
RIP: 0010:[<ffffffff815f8520>]  [<ffffffff815f8520>] remove_inode_hugepages+0x3d0/0x410
Call Trace:
 [<ffffffff815f95b9>] hugetlbfs_setattr+0xd9/0x130
 [<ffffffff81526312>] notify_change+0x292/0x410
 [<ffffffff816cc6b6>] ? security_inode_need_killpriv+0x16/0x20
 [<ffffffff81503c65>] do_truncate+0x65/0xa0
 [<ffffffff81504035>] ? do_sys_ftruncate.constprop.3+0xe5/0x180
 [<ffffffff8150406a>] do_sys_ftruncate.constprop.3+0x11a/0x180
 [<ffffffff8150410e>] SyS_ftruncate+0xe/0x10
 [<ffffffff81999f27>] tracesys+0xd9/0xde

This oops was caused by the lack of i_size check in
hugetlb_mcopy_atomic_pte. mmap() can still succeed beyond the end of
the i_size after vmtruncate zapped vmas in those ranges, but the
faults must not succeed, and that includes UFFDIO_COPY.

We could differentiate the retval to userland to represent a SIGBUS
like a page fault would do (vs SIGSEGV), but it doesn't seem very
useful and we'd need to pick a random retval as there's no meaningful
syscall retval that would differentiate from SIGSEGV and SIGBUS,
there's just -EFAULT.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 357161bd1519..0cbb7c37dc33 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4012,6 +4012,9 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 			    unsigned long src_addr,
 			    struct page **pagep)
 {
+	struct address_space *mapping;
+	pgoff_t idx;
+	unsigned long size;
 	int vm_shared = dst_vma->vm_flags & VM_SHARED;
 	struct hstate *h = hstate_vma(dst_vma);
 	pte_t _dst_pte;
@@ -4049,13 +4052,24 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	__SetPageUptodate(page);
 	__set_page_huge_active(page);
 
+	mapping = dst_vma->vm_file->f_mapping;
+	idx = vma_hugecache_offset(h, dst_vma, dst_addr);
+
 	/*
 	 * If shared, add to page cache
 	 */
 	if (vm_shared) {
-		struct address_space *mapping = dst_vma->vm_file->f_mapping;
-		pgoff_t idx = vma_hugecache_offset(h, dst_vma, dst_addr);
+		size = i_size_read(mapping->host) >> huge_page_shift(h);
+		ret = -EFAULT;
+		if (idx >= size)
+			goto out_release_nounlock;
 
+		/*
+		 * Serialization between remove_inode_hugepages() and
+		 * huge_add_to_page_cache() below happens through the
+		 * hugetlb_fault_mutex_table that here must be hold by
+		 * the caller.
+		 */
 		ret = huge_add_to_page_cache(page, mapping, idx);
 		if (ret)
 			goto out_release_nounlock;
@@ -4064,6 +4078,20 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
 	spin_lock(ptl);
 
+	/*
+	 * Recheck the i_size after holding PT lock to make sure not
+	 * to leave any page mapped (as page_mapped()) beyond the end
+	 * of the i_size (remove_inode_hugepages() is strict about
+	 * enforcing that). If we bail out here, we'll also leave a
+	 * page in the radix tree in the vm_shared case beyond the end
+	 * of the i_size, but remove_inode_hugepages() will take care
+	 * of it as soon as we drop the hugetlb_fault_mutex_table.
+	 */
+	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	ret = -EFAULT;
+	if (idx >= size)
+		goto out_release_unlock;
+
 	ret = -EEXIST;
 	if (!huge_pte_none(huge_ptep_get(dst_pte)))
 		goto out_release_unlock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
