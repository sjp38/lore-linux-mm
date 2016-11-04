Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 668336B02CF
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m203so8565375wma.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x130si2905122wmg.27.2016.11.03.21.25.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/21] mm: Trim __do_fault() arguments
Date: Fri,  4 Nov 2016 05:25:01 +0100
Message-Id: <1478233517-3571-6-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Use vm_fault structure to pass cow_page, page, and entry in and out of
the function. That reduces number of __do_fault() arguments from 4 to 1.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 53 +++++++++++++++++++++++------------------------------
 1 file changed, 23 insertions(+), 30 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8145dadb2645..f5ef7b8a30c5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2848,26 +2848,22 @@ static int do_anonymous_page(struct vm_fault *vmf)
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_fault *vmf, struct page *cow_page,
-		      struct page **page, void **entry)
+static int __do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	int ret;
 
-	vmf->cow_page = cow_page;
-
 	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
-	if (ret & VM_FAULT_DAX_LOCKED) {
-		*entry = vmf->entry;
+	if (ret & VM_FAULT_DAX_LOCKED)
 		return ret;
-	}
 
 	if (unlikely(PageHWPoison(vmf->page))) {
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf->page);
 		put_page(vmf->page);
+		vmf->page = NULL;
 		return VM_FAULT_HWPOISON;
 	}
 
@@ -2876,7 +2872,6 @@ static int __do_fault(struct vm_fault *vmf, struct page *cow_page,
 	else
 		VM_BUG_ON_PAGE(!PageLocked(vmf->page), vmf->page);
 
-	*page = vmf->page;
 	return ret;
 }
 
@@ -3173,7 +3168,6 @@ static int do_fault_around(struct vm_fault *vmf)
 static int do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *fault_page;
 	int ret = 0;
 
 	/*
@@ -3187,24 +3181,23 @@ static int do_read_fault(struct vm_fault *vmf)
 			return ret;
 	}
 
-	ret = __do_fault(vmf, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	ret |= alloc_set_pte(vmf, NULL, fault_page);
+	ret |= alloc_set_pte(vmf, NULL, vmf->page);
 	if (vmf->pte)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-	unlock_page(fault_page);
+	unlock_page(vmf->page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-		put_page(fault_page);
+		put_page(vmf->page);
 	return ret;
 }
 
 static int do_cow_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *fault_page, *new_page;
-	void *fault_entry;
+	struct page *new_page;
 	struct mem_cgroup *memcg;
 	int ret;
 
@@ -3221,20 +3214,21 @@ static int do_cow_fault(struct vm_fault *vmf)
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vmf, new_page, &fault_page, &fault_entry);
+	vmf->cow_page = new_page;
+	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
 	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(new_page, fault_page, vmf->address, vma);
+		copy_user_highpage(new_page, vmf->page, vmf->address, vma);
 	__SetPageUptodate(new_page);
 
 	ret |= alloc_set_pte(vmf, memcg, new_page);
 	if (vmf->pte)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
-		unlock_page(fault_page);
-		put_page(fault_page);
+		unlock_page(vmf->page);
+		put_page(vmf->page);
 	} else {
 		dax_unlock_mapping_entry(vma->vm_file->f_mapping, vmf->pgoff);
 	}
@@ -3250,12 +3244,11 @@ static int do_cow_fault(struct vm_fault *vmf)
 static int do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *fault_page;
 	struct address_space *mapping;
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vmf, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3264,26 +3257,26 @@ static int do_shared_fault(struct vm_fault *vmf)
 	 * about to become writable
 	 */
 	if (vma->vm_ops->page_mkwrite) {
-		unlock_page(fault_page);
-		tmp = do_page_mkwrite(vma, fault_page, vmf->address);
+		unlock_page(vmf->page);
+		tmp = do_page_mkwrite(vma, vmf->page, vmf->address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			put_page(fault_page);
+			put_page(vmf->page);
 			return tmp;
 		}
 	}
 
-	ret |= alloc_set_pte(vmf, NULL, fault_page);
+	ret |= alloc_set_pte(vmf, NULL, vmf->page);
 	if (vmf->pte)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
 					VM_FAULT_RETRY))) {
-		unlock_page(fault_page);
-		put_page(fault_page);
+		unlock_page(vmf->page);
+		put_page(vmf->page);
 		return ret;
 	}
 
-	if (set_page_dirty(fault_page))
+	if (set_page_dirty(vmf->page))
 		dirtied = 1;
 	/*
 	 * Take a local copy of the address_space - page.mapping may be zeroed
@@ -3291,8 +3284,8 @@ static int do_shared_fault(struct vm_fault *vmf)
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
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
