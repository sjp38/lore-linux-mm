Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 92AC99003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:52 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so28357615pdj.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id uj2si15991650pab.146.2015.07.10.13.29.37
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:37 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 09/10] ext4: Huge page fault support
Date: Fri, 10 Jul 2015 16:29:24 -0400
Message-Id: <1436560165-8943-10-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Use DAX to provide support for huge pages.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/file.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 34d814f..ca5302a 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -210,6 +210,13 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return dax_fault(vma, vmf, ext4_get_block_write, ext4_end_io_unwritten);
 }
 
+static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
+						pmd_t *pmd, unsigned int flags)
+{
+	return dax_pmd_fault(vma, addr, pmd, flags, ext4_get_block_write,
+				ext4_end_io_unwritten);
+}
+
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return dax_mkwrite(vma, vmf, ext4_get_block_write,
@@ -218,6 +225,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
+	.pmd_fault	= ext4_dax_pmd_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
 	.pfn_mkwrite	= dax_pfn_mkwrite,
 };
@@ -245,7 +253,7 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 	file_accessed(file);
 	if (IS_DAX(file_inode(file))) {
 		vma->vm_ops = &ext4_dax_vm_ops;
-		vma->vm_flags |= VM_MIXEDMAP;
+		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
 	} else {
 		vma->vm_ops = &ext4_file_vm_ops;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
