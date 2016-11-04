Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 910A36B02B5
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y16so8462273wmd.6
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt8si12935345wjb.240.2016.11.03.21.25.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/21] mm: Pass vm_fault structure into do_page_mkwrite()
Date: Fri,  4 Nov 2016 05:25:09 +0100
Message-Id: <1478233517-3571-14-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

We will need more information in the ->page_mkwrite() helper for DAX to
be able to fully finish faults there. Pass vm_fault structure to
do_page_mkwrite() and use it there so that information propagates
properly from upper layers.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4da66c984c2c..c89f99c270bc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2038,20 +2038,14 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
  *
  * We do this without the lock held, so that it can sleep if it needs to.
  */
-static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
-	       unsigned long address)
+static int do_page_mkwrite(struct vm_fault *vmf)
 {
-	struct vm_fault vmf;
 	int ret;
+	struct page *page = vmf->page;
 
-	vmf.address = address;
-	vmf.pgoff = page->index;
-	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
-	vmf.page = page;
-	vmf.cow_page = NULL;
+	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
-	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
+	ret = vmf->vma->vm_ops->page_mkwrite(vmf->vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
@@ -2327,7 +2321,8 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
 		int tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		tmp = do_page_mkwrite(vma, old_page, vmf->address);
+		vmf->page = old_page;
+		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(old_page);
@@ -3292,7 +3287,7 @@ static int do_shared_fault(struct vm_fault *vmf)
 	 */
 	if (vma->vm_ops->page_mkwrite) {
 		unlock_page(vmf->page);
-		tmp = do_page_mkwrite(vma, vmf->page, vmf->address);
+		tmp = do_page_mkwrite(vmf);
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
