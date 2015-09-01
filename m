Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCFA6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 06:23:08 -0400 (EDT)
Received: by pader10 with SMTP id er10so2192929pad.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 03:23:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ep11si29047556pac.239.2015.09.01.03.22.50
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 03:22:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, dax: VMA with vm_ops->pfn_mkwrite wants to be write-notified
Date: Tue,  1 Sep 2015 13:22:41 +0300
Message-Id: <1441102961-68041-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yigal Korman <yigal@plexistor.com>, Boaz Harrosh <boaz@plexistor.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>

For VM_PFNMAP and VM_MIXEDMAP we use vm_ops->pfn_mkwrite instead of
vm_ops->page_mkwrite to notify abort write access. This means we want
vma->vm_page_prot to be write-protected if the VMA provides this vm_ops.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Yigal Korman <yigal@plexistor.com>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>
---
 mm/mmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index df6d5f07035b..3f78bceefe5a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1498,7 +1498,8 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
 		return 0;
 
 	/* The backer wishes to know when pages are first written to? */
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
+	if (vma->vm_ops &&
+			(vma->vm_ops->page_mkwrite || vma->vm_ops->pfn_mkwrite))
 		return 1;
 
 	/* The open routine did something to the protections that pgprot_modify
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
