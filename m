Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59543828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so32897478wma.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a62si9814958wmc.78.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/15] mm: Create vm_fault structure earlier
Date: Fri, 22 Jul 2016 14:19:27 +0200
Message-Id: <1469189981-19000-2-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently we create vm_fault structure just before calling the ->fault
handler. Create it earlier and thus avoid passing all the arguments into
several functions.

When moving the initializers, create a helper function init_vmf() which
performs basic initialization of the structure and make sure all instances
of vm_fault structure are initialized using it.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 143 ++++++++++++++++++++++++++----------------------------------
 1 file changed, 63 insertions(+), 80 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9e046819e619..4ee0aa96d78d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2013,6 +2013,17 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
 	return GFP_KERNEL;
 }
 
+static void init_vmf(struct vm_fault *vmf, struct vm_area_struct *vma,
+		     unsigned long address, pgoff_t pgoff, unsigned int flags)
+{
+	vmf->virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf->pgoff = pgoff;
+	vmf->flags = flags;
+	vmf->page = NULL;
+	vmf->gfp_mask = __get_fault_gfp_mask(vma);
+	vmf->cow_page = NULL;
+}
+
 /*
  * Notify the address space that the page is about to become writable so that
  * it can prohibit this or wait for the page to get into an appropriate state.
@@ -2025,12 +2036,9 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	struct vm_fault vmf;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
-	vmf.pgoff = page->index;
-	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
+	init_vmf(&vmf, vma, address, page->index,
+		 FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE);
 	vmf.page = page;
-	vmf.cow_page = NULL;
 
 	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
@@ -2259,15 +2267,12 @@ static int wp_pfn_shared(struct mm_struct *mm,
 			pmd_t *pmd)
 {
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
-		struct vm_fault vmf = {
-			.page = NULL,
-			.pgoff = linear_page_index(vma, address),
-			.virtual_address = (void __user *)(address & PAGE_MASK),
-			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
-		};
+		struct vm_fault vmf;
 		int ret;
 
 		pte_unmap_unlock(page_table, ptl);
+		init_vmf(&vmf, vma, address, linear_page_index(vma, address),
+			 FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE);
 		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
@@ -2821,42 +2826,26 @@ oom:
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-			pgoff_t pgoff, unsigned int flags,
-			struct page *cow_page, struct page **page,
-			void **entry)
+static int __do_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct vm_fault vmf;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
-	vmf.pgoff = pgoff;
-	vmf.flags = flags;
-	vmf.page = NULL;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
-	vmf.cow_page = cow_page;
-
-	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-		return ret;
-	if (ret & VM_FAULT_DAX_LOCKED) {
-		*entry = vmf.entry;
+	ret = vma->vm_ops->fault(vma, vmf);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
+			    VM_FAULT_DAX_LOCKED)))
 		return ret;
-	}
 
-	if (unlikely(PageHWPoison(vmf.page))) {
+	if (unlikely(PageHWPoison(vmf->page))) {
 		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf.page);
-		put_page(vmf.page);
+			unlock_page(vmf->page);
+		put_page(vmf->page);
 		return VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
-		lock_page(vmf.page);
+		lock_page(vmf->page);
 	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
-
-	*page = vmf.page;
+		VM_BUG_ON_PAGE(!PageLocked(vmf->page), vmf->page);
 	return ret;
 }
 
@@ -2996,23 +2985,19 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte++;
 	}
 
-	vmf.virtual_address = (void __user *) start_addr;
+	init_vmf(&vmf, vma, start_addr, pgoff, flags);
 	vmf.pte = pte;
-	vmf.pgoff = pgoff;
 	vmf.max_pgoff = max_pgoff;
-	vmf.flags = flags;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vma->vm_ops->map_pages(vma, &vmf);
 }
 
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pmd_t *pmd, pte_t orig_pte, struct vm_fault *vmf)
 {
-	struct page *fault_page;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int ret = 0;
+	unsigned long address = (unsigned long)vmf->virtual_address;
 
 	/*
 	 * Let's call ->map_pages() first and use ->fault() as fallback
@@ -3021,40 +3006,39 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
+		do_fault_around(vma, address, pte, vmf->pgoff, vmf->flags);
 		if (!pte_same(*pte, orig_pte))
 			goto unlock_out;
 		pte_unmap_unlock(pte, ptl);
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page, NULL);
+	ret = __do_fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
-		unlock_page(fault_page);
-		put_page(fault_page);
+		unlock_page(vmf->page);
+		put_page(vmf->page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false);
-	unlock_page(fault_page);
+	do_set_pte(vma, address, vmf->page, pte, false, false);
+	unlock_page(vmf->page);
 unlock_out:
 	pte_unmap_unlock(pte, ptl);
 	return ret;
 }
 
 static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pmd_t *pmd, pte_t orig_pte, struct vm_fault *vmf)
 {
-	struct page *fault_page, *new_page;
-	void *fault_entry;
+	struct page *new_page;
 	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int ret;
+	unsigned long address = (unsigned long)vmf->virtual_address;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
@@ -3068,24 +3052,24 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page,
-			 &fault_entry);
+	vmf->cow_page = new_page;
+	ret = __do_fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
 	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(new_page, fault_page, address, vma);
+		copy_user_highpage(new_page, vmf->page, address, vma);
 	__SetPageUptodate(new_page);
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		if (!(ret & VM_FAULT_DAX_LOCKED)) {
-			unlock_page(fault_page);
-			put_page(fault_page);
+			unlock_page(vmf->page);
+			put_page(vmf->page);
 		} else {
 			dax_unlock_mapping_entry(vma->vm_file->f_mapping,
-						 pgoff);
+						 vmf->pgoff);
 		}
 		goto uncharge_out;
 	}
@@ -3094,10 +3078,10 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
-		unlock_page(fault_page);
-		put_page(fault_page);
+		unlock_page(vmf->page);
+		put_page(vmf->page);
 	} else {
-		dax_unlock_mapping_entry(vma->vm_file->f_mapping, pgoff);
+		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
 	}
 	return ret;
 uncharge_out:
@@ -3107,17 +3091,16 @@ uncharge_out:
 }
 
 static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pmd_t *pmd, pte_t orig_pte, struct vm_fault *vmf)
 {
-	struct page *fault_page;
 	struct address_space *mapping;
+	unsigned long address = (unsigned long)vmf->virtual_address;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page, NULL);
+	ret = __do_fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3126,11 +3109,11 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * about to become writable
 	 */
 	if (vma->vm_ops->page_mkwrite) {
-		unlock_page(fault_page);
-		tmp = do_page_mkwrite(vma, fault_page, address);
+		unlock_page(vmf->page);
+		tmp = do_page_mkwrite(vma, vmf->page, address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			put_page(fault_page);
+			put_page(vmf->page);
 			return tmp;
 		}
 	}
@@ -3138,14 +3121,14 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
-		unlock_page(fault_page);
-		put_page(fault_page);
+		unlock_page(vmf->page);
+		put_page(vmf->page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false);
+	do_set_pte(vma, address, vmf->page, pte, true, false);
 	pte_unmap_unlock(pte, ptl);
 
-	if (set_page_dirty(fault_page))
+	if (set_page_dirty(vmf->page))
 		dirtied = 1;
 	/*
 	 * Take a local copy of the address_space - page.mapping may be zeroed
@@ -3153,8 +3136,8 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
 	 * release semantics to prevent the compiler from undoing this copying.
 	 */
-	mapping = page_rmapping(fault_page);
-	unlock_page(fault_page);
+	mapping = page_rmapping(vmf->page);
+	unlock_page(vmf->page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
 		/*
 		 * Some device drivers do not set page.mapping but still
@@ -3180,18 +3163,18 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff = linear_page_index(vma, address);
+	struct vm_fault vmf;
 
 	pte_unmap(page_table);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
+	init_vmf(&vmf, vma, address, pgoff, flags);
 	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
+		return do_read_fault(mm, vma, pmd, orig_pte, &vmf);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+		return do_cow_fault(mm, vma, pmd, orig_pte, &vmf);
+	return do_shared_fault(mm, vma, pmd, orig_pte, &vmf);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
