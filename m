Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A92F828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so72034175lfi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tx8si620819wjb.53.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/15] mm: Lift vm_fault structure creation from do_page_mkwrite()
Date: Fri, 22 Jul 2016 14:19:38 +0200
Message-Id: <1469189981-19000-13-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Move creation of struct vm_fault up from do_page_mkwrite() to avoid
passing some parameters and actually safe creating it in one case.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c3f639c33232..1d2916c53d43 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2033,17 +2033,12 @@ static void init_vmf(struct vm_fault *vmf, struct vm_area_struct *vma,
  *
  * We do this without the lock held, so that it can sleep if it needs to.
  */
-static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
-	       unsigned long address, pmd_t *pmd, pte_t orig_pte)
+static int do_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct vm_fault vmf;
 	int ret;
+	struct page *page = vmf->page;
 
-	init_vmf(&vmf, vma, address, pmd, page->index,
-		 FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE, orig_pte);
-	vmf.page = page;
-
-	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
+	ret = vma->vm_ops->page_mkwrite(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
@@ -2311,9 +2306,14 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (vma->vm_ops->page_mkwrite) {
 		int tmp;
+		struct vm_fault vmf;
 
 		pte_unmap_unlock(page_table, ptl);
-		tmp = do_page_mkwrite(vma, old_page, address, pmd, orig_pte);
+
+		init_vmf(&vmf, vma, address, pmd, old_page->index,
+			 FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE, orig_pte);
+		vmf.page = old_page;
+		tmp = do_page_mkwrite(vma, &vmf);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(old_page);
@@ -3137,7 +3137,6 @@ uncharge_out:
 static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_fault *vmf)
 {
-	unsigned long address = (unsigned long)vmf->virtual_address;
 	int ret, tmp;
 
 	ret = __do_fault(vma, vmf);
@@ -3150,8 +3149,8 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->page_mkwrite) {
 		unlock_page(vmf->page);
-		tmp = do_page_mkwrite(vma, vmf->page, address, vmf->pmd,
-				      vmf->orig_pte);
+		vmf->flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
+		tmp = do_page_mkwrite(vma, vmf);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(vmf->page);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
