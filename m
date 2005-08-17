Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7HJBPSj011223
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:11:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJBPKl289880
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:11:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJBEgN025454
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:11:15 -0400
Subject: [PATCH 4/4] htlb-fault
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1124304966.3139.37.camel@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 14:05:48 -0500
Message-Id: <1124305548.3139.46.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

Version 2 (Wed, 17 Aug 2005)
        Removed spurious WARN_ON()
    Patches added earlier in the series:
        Check for p?d_none() in arch/i386/mm/hugetlbpage.c:huge_pte_offset()
	Move i386 stale pte check into huge_pte_alloc()

Initial Post (Fri, 05 Aug 2005)

Below is a patch to implement demand faulting for huge pages.  The main
motivation for changing from prefaulting to demand faulting is so that
huge page memory areas can be allocated according to NUMA policy.

Thanks to consolidated hugetlb code, switching the behavior requires changing
only one fault handler.  The bulk of the patch just moves the logic from 
hugelb_prefault() to hugetlb_pte_fault().

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 fs/hugetlbfs/inode.c    |    6 --
 include/linux/hugetlb.h |    2 
 mm/hugetlb.c            |  137 +++++++++++++++++++++++++++---------------------
 mm/memory.c             |    7 --
 4 files changed, 82 insertions(+), 70 deletions(-)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -48,7 +48,6 @@ int sysctl_hugetlb_shm_group;
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct address_space *mapping = inode->i_mapping;
 	loff_t len, vma_len;
 	int ret;
 
@@ -79,10 +78,7 @@ static int hugetlbfs_file_mmap(struct fi
 	if (!(vma->vm_flags & VM_WRITE) && len > inode->i_size)
 		goto out;
 
-	ret = hugetlb_prefault(mapping, vma);
-	if (ret)
-		goto out;
-
+	ret = 0;
 	if (inode->i_size < len)
 		inode->i_size = len;
 out:
diff -upN reference/include/linux/hugetlb.h current/include/linux/hugetlb.h
--- reference/include/linux/hugetlb.h
+++ current/include/linux/hugetlb.h
@@ -25,6 +25,8 @@ int is_hugepage_mem_enough(size_t);
 unsigned long hugetlb_total_pages(void);
 struct page *alloc_huge_page(void);
 void free_huge_page(struct page *);
+int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct * vma,
+			unsigned long address, int write_access);
 
 extern unsigned long max_huge_pages;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -277,18 +277,20 @@ int copy_hugetlb_page_range(struct mm_st
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
 
-	while (addr < end) {
+	for (; addr < end; addr += HPAGE_SIZE) {
+		src_pte = huge_pte_offset(src, addr);
+		if (!src_pte || pte_none(*src_pte))
+			continue;
+		
 		dst_pte = huge_pte_alloc(dst, addr);
 		if (!dst_pte)
 			goto nomem;
-		src_pte = huge_pte_offset(src, addr);
-		BUG_ON(!src_pte || pte_none(*src_pte)); /* prefaulted */
+		BUG_ON(!src_pte);
 		entry = *src_pte;
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		add_mm_counter(dst, rss, HPAGE_SIZE / PAGE_SIZE);
 		set_huge_pte_at(dst, addr, dst_pte, entry);
-		addr += HPAGE_SIZE;
 	}
 	return 0;
 
@@ -338,61 +340,6 @@ void zap_hugepage_range(struct vm_area_s
 	spin_unlock(&mm->page_table_lock);
 }
 
-int hugetlb_prefault(struct address_space *mapping, struct vm_area_struct *vma)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr;
-	int ret = 0;
-
-	WARN_ON(!is_vm_hugetlb_page(vma));
-	BUG_ON(vma->vm_start & ~HPAGE_MASK);
-	BUG_ON(vma->vm_end & ~HPAGE_MASK);
-
-	hugetlb_prefault_arch_hook(mm);
-
-	spin_lock(&mm->page_table_lock);
-	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
-		unsigned long idx;
-		pte_t *pte = huge_pte_alloc(mm, addr);
-		struct page *page;
-
-		if (!pte) {
-			ret = -ENOMEM;
-			goto out;
-		}
-
-		idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
-			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
-		page = find_get_page(mapping, idx);
-		if (!page) {
-			/* charge the fs quota first */
-			if (hugetlb_get_quota(mapping)) {
-				ret = -ENOMEM;
-				goto out;
-			}
-			page = alloc_huge_page();
-			if (!page) {
-				hugetlb_put_quota(mapping);
-				ret = -ENOMEM;
-				goto out;
-			}
-			ret = add_to_page_cache(page, mapping, idx, GFP_ATOMIC);
-			if (! ret) {
-				unlock_page(page);
-			} else {
-				hugetlb_put_quota(mapping);
-				free_huge_page(page);
-				goto out;
-			}
-		}
-		add_mm_counter(mm, rss, HPAGE_SIZE / PAGE_SIZE);
-		set_huge_pte_at(mm, addr, pte, make_huge_pte(vma, page));
-	}
-out:
-	spin_unlock(&mm->page_table_lock);
-	return ret;
-}
-
 int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i)
@@ -440,3 +387,75 @@ int follow_hugetlb_page(struct mm_struct
 
 	return i;
 }
+
+int hugetlb_pte_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, int write_access)
+{
+	int ret = VM_FAULT_MINOR;
+	unsigned long idx;
+	pte_t *pte;
+	struct page *page;
+	struct address_space *mapping;
+
+	BUG_ON(vma->vm_start & ~HPAGE_MASK);
+	BUG_ON(vma->vm_end & ~HPAGE_MASK);
+	BUG_ON(!vma->vm_file);
+
+	pte = huge_pte_alloc(mm, address);
+	if (!pte) {
+		ret = VM_FAULT_SIGBUS;
+		goto out;
+	}
+	if (! pte_none(*pte))
+		goto flush;
+
+	mapping = vma->vm_file->f_mapping;
+	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
+		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+retry:
+	page = find_get_page(mapping, idx);
+	if (!page) {
+		/* charge the fs quota first */
+		if (hugetlb_get_quota(mapping)) {
+			ret = VM_FAULT_SIGBUS;
+			goto out;
+		}
+		page = alloc_huge_page();
+		if (!page) {
+			hugetlb_put_quota(mapping);
+			ret = VM_FAULT_SIGBUS;
+			goto out;
+		}
+		if (add_to_page_cache(page, mapping, idx, GFP_ATOMIC)) {
+			put_page(page);
+			goto retry;
+		}
+		unlock_page(page);
+	}
+	add_mm_counter(mm, rss, HPAGE_SIZE / PAGE_SIZE);
+	set_huge_pte_at(mm, address, pte, make_huge_pte(vma, page));
+flush:
+	flush_tlb_page(vma, address);
+out:
+	return ret;
+}
+
+int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, int write_access)
+{
+	pte_t *ptep;
+	int rc = VM_FAULT_MINOR;
+
+	spin_lock(&mm->page_table_lock);
+
+	ptep = huge_pte_alloc(mm, address & HPAGE_MASK);
+	if (! ptep) {
+		rc = VM_FAULT_SIGBUS;
+		goto out;
+	}
+	if (pte_none(*ptep))
+		rc = hugetlb_pte_fault(mm, vma, address, write_access);
+out:
+	spin_unlock(&mm->page_table_lock);
+	return rc;
+}
diff -upN reference/mm/memory.c current/mm/memory.c
--- reference/mm/memory.c
+++ current/mm/memory.c
@@ -937,11 +937,6 @@ int get_user_pages(struct task_struct *t
 				|| !(flags & vma->vm_flags))
 			return i ? : -EFAULT;
 
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-						&start, &len, i);
-			continue;
-		}
 		spin_lock(&mm->page_table_lock);
 		do {
 			int write_access = write;
@@ -2034,7 +2029,7 @@ int __handle_mm_fault(struct mm_struct *
 	inc_page_state(pgfault);
 
 	if (is_vm_hugetlb_page(vma))
-		return VM_FAULT_SIGBUS;	/* mapping truncation does this. */
+		return hugetlb_fault(mm, vma, address, write_access);
 
 	/*
 	 * We need the page table lock to synchronize with kswapd


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
