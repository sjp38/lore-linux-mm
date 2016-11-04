Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65DC66B02C8
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n67so8412766wme.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ju1si12957270wjc.128.2016.11.03.21.25.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/21] mm: Use passed vm_fault structure for in wp_pfn_shared()
Date: Fri,  4 Nov 2016 05:25:02 +0100
Message-Id: <1478233517-3571-7-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Instead of creating another vm_fault structure, use the one passed to
wp_pfn_shared() for passing arguments into pfn_mkwrite handler.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index f5ef7b8a30c5..5f6bc9028a88 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2277,16 +2277,11 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
 	struct vm_area_struct *vma = vmf->vma;
 
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
-		struct vm_fault vmf2 = {
-			.page = NULL,
-			.pgoff = vmf->pgoff,
-			.address = vmf->address,
-			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
-		};
 		int ret;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf2);
+		vmf->flags |= FAULT_FLAG_MKWRITE;
+		ret = vma->vm_ops->pfn_mkwrite(vma, vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
 		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
