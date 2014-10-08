Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F26E76B0082
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:47 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id eu11so8998179pac.7
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pw4si18188963pbb.98.2014.10.08.06.25.45
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:45 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 6/7] ext2: Huge page fault support
Date: Wed,  8 Oct 2014 09:25:28 -0400
Message-Id: <1412774729-23956-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Use DAX to provide support for huge pages.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext2/file.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 5b8cab5..4379393 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -31,6 +31,12 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return dax_fault(vma, vmf, ext2_get_block);
 }
 
+static int ext2_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
+						pmd_t *pmd, unsigned int flags)
+{
+	return dax_pmd_fault(vma, addr, pmd, flags, ext2_get_block);
+}
+
 static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return dax_mkwrite(vma, vmf, ext2_get_block);
@@ -38,6 +44,7 @@ static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
+	.pmd_fault	= ext2_dax_pmd_fault,
 	.page_mkwrite	= ext2_dax_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
@@ -49,7 +56,7 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	file_accessed(file);
 	vma->vm_ops = &ext2_dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP;
+	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	return 0;
 }
 #else
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
