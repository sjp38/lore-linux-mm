Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8FE6B0083
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:49 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so6870274pdb.35
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id so2si18193516pab.132.2014.10.08.06.25.48
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:48 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 7/7] ext4: Huge page fault support
Date: Wed,  8 Oct 2014 09:25:29 -0400
Message-Id: <1412774729-23956-8-git-send-email-matthew.r.wilcox@intel.com>
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
 fs/ext4/file.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 9c7bde5..9e3b4d3 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -198,6 +198,12 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 					/* Is this the right get_block? */
 }
 
+static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
+						pmd_t *pmd, unsigned int flags)
+{
+	return dax_pmd_fault(vma, addr, pmd, flags, ext4_get_block);
+}
+
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return dax_mkwrite(vma, vmf, ext4_get_block);
@@ -205,6 +211,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
+	.pmd_fault	= ext4_dax_pmd_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
@@ -224,7 +231,7 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 	file_accessed(file);
 	if (IS_DAX(file_inode(file))) {
 		vma->vm_ops = &ext4_dax_vm_ops;
-		vma->vm_flags |= VM_MIXEDMAP;
+		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	} else {
 		vma->vm_ops = &ext4_file_vm_ops;
 	}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
