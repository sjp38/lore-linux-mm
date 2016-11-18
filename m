Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE7D96B03E6
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:19:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so9684050wmw.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:19:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lr1si6717062wjb.36.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/20] mm: Use vmf->page during WP faults
Date: Fri, 18 Nov 2016 10:17:17 +0100
Message-Id: <1479460644-25076-14-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

So far we set vmf->page during WP faults only when we needed to pass it
to the ->page_mkwrite handler. Set it in all the cases now and use that
instead of passing page pointer explicitly around.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 58 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6d4e1b1cea51..8d08015ed44d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2106,11 +2106,12 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static inline int wp_page_reuse(struct vm_fault *vmf, struct page *page,
+static inline int wp_page_reuse(struct vm_fault *vmf,
 				int page_mkwrite, int dirty_shared)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
+	struct page *page = vmf->page;
 	pte_t entry;
 	/*
 	 * Clear the pages cpupid information as the existing
@@ -2154,10 +2155,11 @@ static inline int wp_page_reuse(struct vm_fault *vmf, struct page *page,
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct vm_fault *vmf, struct page *old_page)
+static int wp_page_copy(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
+	struct page *old_page = vmf->page;
 	struct page *new_page = NULL;
 	pte_t entry;
 	int page_copied = 0;
@@ -2309,26 +2311,25 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 			return 0;
 		}
 	}
-	return wp_page_reuse(vmf, NULL, 0, 0);
+	return wp_page_reuse(vmf, 0, 0);
 }
 
-static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
+static int wp_page_shared(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	int page_mkwrite = 0;
 
-	get_page(old_page);
+	get_page(vmf->page);
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		vmf->page = old_page;
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			put_page(old_page);
+			put_page(vmf->page);
 			return tmp;
 		}
 		/*
@@ -2340,15 +2341,15 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
 		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 						vmf->address, &vmf->ptl);
 		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
-			unlock_page(old_page);
+			unlock_page(vmf->page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
-			put_page(old_page);
+			put_page(vmf->page);
 			return 0;
 		}
 		page_mkwrite = 1;
 	}
 
-	return wp_page_reuse(vmf, old_page, page_mkwrite, 1);
+	return wp_page_reuse(vmf, page_mkwrite, 1);
 }
 
 /*
@@ -2373,10 +2374,9 @@ static int do_wp_page(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *old_page;
 
-	old_page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
-	if (!old_page) {
+	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
+	if (!vmf->page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
 		 * VM_PFNMAP VMA.
@@ -2389,30 +2389,30 @@ static int do_wp_page(struct vm_fault *vmf)
 			return wp_pfn_shared(vmf);
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		return wp_page_copy(vmf, old_page);
+		return wp_page_copy(vmf);
 	}
 
 	/*
 	 * Take out anonymous pages first, anonymous shared vmas are
 	 * not dirty accountable.
 	 */
-	if (PageAnon(old_page) && !PageKsm(old_page)) {
+	if (PageAnon(vmf->page) && !PageKsm(vmf->page)) {
 		int total_mapcount;
-		if (!trylock_page(old_page)) {
-			get_page(old_page);
+		if (!trylock_page(vmf->page)) {
+			get_page(vmf->page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
-			lock_page(old_page);
+			lock_page(vmf->page);
 			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
 					vmf->address, &vmf->ptl);
 			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
-				unlock_page(old_page);
+				unlock_page(vmf->page);
 				pte_unmap_unlock(vmf->pte, vmf->ptl);
-				put_page(old_page);
+				put_page(vmf->page);
 				return 0;
 			}
-			put_page(old_page);
+			put_page(vmf->page);
 		}
-		if (reuse_swap_page(old_page, &total_mapcount)) {
+		if (reuse_swap_page(vmf->page, &total_mapcount)) {
 			if (total_mapcount == 1) {
 				/*
 				 * The page is all ours. Move it to
@@ -2421,24 +2421,24 @@ static int do_wp_page(struct vm_fault *vmf)
 				 * Protected against the rmap code by
 				 * the page lock.
 				 */
-				page_move_anon_rmap(old_page, vma);
+				page_move_anon_rmap(vmf->page, vma);
 			}
-			unlock_page(old_page);
-			return wp_page_reuse(vmf, old_page, 0, 0);
+			unlock_page(vmf->page);
+			return wp_page_reuse(vmf, 0, 0);
 		}
-		unlock_page(old_page);
+		unlock_page(vmf->page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
-		return wp_page_shared(vmf, old_page);
+		return wp_page_shared(vmf);
 	}
 
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
-	get_page(old_page);
+	get_page(vmf->page);
 
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	return wp_page_copy(vmf, old_page);
+	return wp_page_copy(vmf);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
