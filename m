Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAD76B02AE
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:37:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so521252wmd.0
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:37:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay9si19316891wjc.120.2016.11.01.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/21] mm: Use passed vm_fault structure in __do_fault()
Date: Tue,  1 Nov 2016 23:36:12 +0100
Message-Id: <1478039794-20253-7-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Instead of creating another vm_fault structure, use the one passed to
__do_fault() for passing arguments into fault handler.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3b79eace8d23..8145dadb2645 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2852,37 +2852,31 @@ static int __do_fault(struct vm_fault *vmf, struct page *cow_page,
 		      struct page **page, void **entry)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct vm_fault vmf2;
 	int ret;
 
-	vmf2.address = vmf->address;
-	vmf2.pgoff = vmf->pgoff;
-	vmf2.flags = vmf->flags;
-	vmf2.page = NULL;
-	vmf2.gfp_mask = __get_fault_gfp_mask(vma);
-	vmf2.cow_page = cow_page;
+	vmf->cow_page = cow_page;
 
-	ret = vma->vm_ops->fault(vma, &vmf2);
+	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (ret & VM_FAULT_DAX_LOCKED) {
-		*entry = vmf2.entry;
+		*entry = vmf->entry;
 		return ret;
 	}
 
-	if (unlikely(PageHWPoison(vmf2.page))) {
+	if (unlikely(PageHWPoison(vmf->page))) {
 		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf2.page);
-		put_page(vmf2.page);
+			unlock_page(vmf->page);
+		put_page(vmf->page);
 		return VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
-		lock_page(vmf2.page);
+		lock_page(vmf->page);
 	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf2.page), vmf2.page);
+		VM_BUG_ON_PAGE(!PageLocked(vmf->page), vmf->page);
 
-	*page = vmf2.page;
+	*page = vmf->page;
 	return ret;
 }
 
@@ -3579,6 +3573,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.address = address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
+		.gfp_mask = __get_fault_gfp_mask(vma),
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
