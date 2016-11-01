Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10EE86B02D8
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:45:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p190so537599wmp.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:45:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bg10si39163531wjb.57.2016.11.01.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/21] mm: Use passed vm_fault structure for in wp_pfn_shared()
Date: Tue,  1 Nov 2016 23:36:14 +0100
Message-Id: <1478039794-20253-9-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

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
