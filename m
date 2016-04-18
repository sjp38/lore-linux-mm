Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D70746B0268
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:36:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a125so255618wmd.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:36:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy10si67275105wjc.144.2016.04.18.14.35.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:54 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 17/18] dax: Use radix tree entry lock to protect cow faults
Date: Mon, 18 Apr 2016 23:35:40 +0200
Message-Id: <1461015341-20153-18-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

When doing cow faults, we cannot directly fill in PTE as we do for other
faults as we rely on generic code to do proper accounting of the cowed page.
We also have no page to lock to protect against races with truncate as
other faults have and we need the protection to extend until the moment
generic code inserts cowed page into PTE thus at that point we have no
protection of fs-specific i_mmap_sem. So far we relied on using
i_mmap_lock for the protection however that is completely special to cow
faults. To make fault locking more uniform use DAX entry lock instead.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 12 +++++-------
 include/linux/dax.h |  7 +++++++
 include/linux/mm.h  |  7 +++++++
 mm/memory.c         | 38 ++++++++++++++++++--------------------
 4 files changed, 37 insertions(+), 27 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index be68d18a98c1..d907bf8b07a0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -509,7 +509,7 @@ static void wake_mapping_entry_waiter(struct address_space *mapping,
 	}
 }
 
-static void unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
+void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
 	void *ret, **slot;
 
@@ -532,7 +532,7 @@ static void put_locked_mapping_entry(struct address_space *mapping,
 		unlock_page(entry);
 		put_page(entry);
 	} else {
-		unlock_mapping_entry(mapping, index);
+		dax_unlock_mapping_entry(mapping, index);
 	}
 }
 
@@ -912,12 +912,10 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			goto unlock_entry;
 		if (!radix_tree_exceptional_entry(entry)) {
 			vmf->page = entry;
-		} else {
-			unlock_mapping_entry(mapping, vmf->pgoff);
-			i_mmap_lock_read(mapping);
-			vmf->page = NULL;
+			return VM_FAULT_LOCKED;
 		}
-		return VM_FAULT_LOCKED;
+		vmf->entry = entry;
+		return VM_FAULT_DAX_LOCKED;
 	}
 
 	if (!buffer_mapped(&bh)) {
diff --git a/include/linux/dax.h b/include/linux/dax.h
index c5522f912344..ef94fa71368c 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -20,12 +20,19 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
+void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index);
 #else
 static inline struct page *read_dax_sector(struct block_device *bdev,
 		sector_t n)
 {
 	return ERR_PTR(-ENXIO);
 }
+/* Shouldn't ever be called when dax is disabled. */
+static inline void dax_unlock_mapping_entry(struct address_space *mapping,
+					    pgoff_t index)
+{
+	BUG();
+}
 #endif
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_BROKEN)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a55e5be0894f..0ef9dc720ec3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -299,6 +299,12 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+	void *entry;			/* ->fault handler can alternatively
+					 * return locked DAX entry. In that
+					 * case handler should return
+					 * VM_FAULT_DAX_LOCKED and fill in
+					 * entry here.
+					 */
 	/* for ->map_pages() only */
 	pgoff_t max_pgoff;		/* map pages for offset from pgoff till
 					 * max_pgoff inclusive */
@@ -1084,6 +1090,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
+#define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index 93897f23cc11..f09cdb8d48fa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -63,6 +63,7 @@
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/dax.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2785,7 +2786,8 @@ oom:
  */
 static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 			pgoff_t pgoff, unsigned int flags,
-			struct page *cow_page, struct page **page)
+			struct page *cow_page, struct page **page,
+			void **entry)
 {
 	struct vm_fault vmf;
 	int ret;
@@ -2800,8 +2802,10 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
-	if (!vmf.page)
-		goto out;
+	if (ret & VM_FAULT_DAX_LOCKED) {
+		*entry = vmf.entry;
+		return ret;
+	}
 
 	if (unlikely(PageHWPoison(vmf.page))) {
 		if (ret & VM_FAULT_LOCKED)
@@ -2815,7 +2819,6 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	else
 		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
 
- out:
 	*page = vmf.page;
 	return ret;
 }
@@ -2987,7 +2990,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3010,6 +3013,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page, *new_page;
+	void *fault_entry;
 	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
 	pte_t *pte;
@@ -3027,26 +3031,24 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page,
+			 &fault_entry);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
-	if (fault_page)
+	if (!(ret & VM_FAULT_DAX_LOCKED))
 		copy_user_highpage(new_page, fault_page, address, vma);
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
-		if (fault_page) {
+		if (!(ret & VM_FAULT_DAX_LOCKED)) {
 			unlock_page(fault_page);
 			put_page(fault_page);
 		} else {
-			/*
-			 * The fault handler has no page to lock, so it holds
-			 * i_mmap_lock for read to protect against truncate.
-			 */
-			i_mmap_unlock_read(vma->vm_file->f_mapping);
+			dax_unlock_mapping_entry(vma->vm_file->f_mapping,
+						 pgoff);
 		}
 		goto uncharge_out;
 	}
@@ -3054,15 +3056,11 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
-	if (fault_page) {
+	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(fault_page);
 		put_page(fault_page);
 	} else {
-		/*
-		 * The fault handler has no page to lock, so it holds
-		 * i_mmap_lock for read to protect against truncate.
-		 */
-		i_mmap_unlock_read(vma->vm_file->f_mapping);
+		dax_unlock_mapping_entry(vma->vm_file->f_mapping, pgoff);
 	}
 	return ret;
 uncharge_out:
@@ -3082,7 +3080,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
