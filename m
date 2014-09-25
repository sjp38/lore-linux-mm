Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 67B276B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 16:34:10 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so1781955pdb.31
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:34:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m5si5535291pdi.216.2014.09.25.13.34.02
        for <linux-mm@kvack.org>;
        Thu, 25 Sep 2014 13:34:03 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v11 04/21] mm: Allow page fault handlers to perform the COW
Date: Thu, 25 Sep 2014 16:33:21 -0400
Message-Id: <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

Currently COW of an XIP file is done by first bringing in a read-only
mapping, then retrying the fault and copying the page.  It is much more
efficient to tell the fault handler that a COW is being attempted (by
passing in the pre-allocated page in the vm_fault structure), and allow
the handler to perform the COW operation itself.

The handler cannot insert the page itself if there is already a read-only
mapping at that address, so allow the handler to return VM_FAULT_LOCKED
and set the fault_page to be NULL.  This indicates to the MM code that
the i_mmap_mutex is held instead of the page lock.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 33 ++++++++++++++++++++++++---------
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..0a47817 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -208,6 +208,7 @@ struct vm_fault {
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	void __user *virtual_address;	/* Faulting virtual address */
 
+	struct page *cow_page;		/* Handler may choose to COW */
 	struct page *page;		/* ->fault handlers should return a
 					 * page here, unless VM_FAULT_NOPAGE
 					 * is set (which is also implied by
diff --git a/mm/memory.c b/mm/memory.c
index adeac30..3368785 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2000,6 +2000,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	vmf.pgoff = page->index;
 	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 	vmf.page = page;
+	vmf.cow_page = NULL;
 
 	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
@@ -2698,7 +2699,8 @@ oom:
  * See filemap_fault() and __lock_page_retry().
  */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-		pgoff_t pgoff, unsigned int flags, struct page **page)
+			pgoff_t pgoff, unsigned int flags,
+			struct page *cow_page, struct page **page)
 {
 	struct vm_fault vmf;
 	int ret;
@@ -2707,10 +2709,13 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
+	vmf.cow_page = cow_page;
 
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
+	if (!vmf.page)
+		goto out;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
 		if (ret & VM_FAULT_LOCKED)
@@ -2724,6 +2729,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	else
 		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
 
+ out:
 	*page = vmf.page;
 	return ret;
 }
@@ -2897,7 +2903,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -2937,26 +2943,35 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
-	copy_user_highpage(new_page, fault_page, address, vma);
+	if (fault_page)
+		copy_user_highpage(new_page, fault_page, address, vma);
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
-		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		if (fault_page) {
+			unlock_page(fault_page);
+			page_cache_release(fault_page);
+		} else {
+			mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+		}
 		goto uncharge_out;
 	}
 	do_set_pte(vma, address, new_page, pte, true, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
-	unlock_page(fault_page);
-	page_cache_release(fault_page);
+	if (fault_page) {
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+	} else {
+		mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	}
 	return ret;
 uncharge_out:
 	mem_cgroup_cancel_charge(new_page, memcg);
@@ -2975,7 +2990,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
