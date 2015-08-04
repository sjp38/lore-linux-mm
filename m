Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF5336B025A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:26 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so15960962pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xv3si748082pab.185.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 05/11] ext4: Start transaction before calling into DAX
Date: Tue,  4 Aug 2015 15:57:59 -0400
Message-Id: <1438718285-21168-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Jan Kara pointed out that in the case where we are writing to a hole,
we can end up with a lock inversion between the page lock and the
journal lock.  We can avoid this by starting the transaction in ext4
before calling into DAX.  The journal lock nests inside the superblock
pagefault lock, so we have to duplicate that code from dax_fault, like
XFS does.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/file.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index d5219e4..113837e 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -207,14 +207,63 @@ static void ext4_end_io_unwritten(struct buffer_head *bh, int uptodate)
 
 static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return dax_fault(vma, vmf, ext4_get_block_dax, ext4_end_io_unwritten);
+	int result;
+	handle_t *handle = NULL;
+	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+
+	if (write) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
+						EXT4_DATA_TRANS_BLOCKS(sb));
+	}
+
+	if (IS_ERR(handle))
+		result = VM_FAULT_SIGBUS;
+	else
+		result = __dax_fault(vma, vmf, ext4_get_block_dax,
+						ext4_end_io_unwritten);
+
+	if (write) {
+		if (!IS_ERR(handle))
+			ext4_journal_stop(handle);
+		sb_end_pagefault(sb);
+	}
+
+	return result;
 }
 
 static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 						pmd_t *pmd, unsigned int flags)
 {
-	return dax_pmd_fault(vma, addr, pmd, flags, ext4_get_block_dax,
-				ext4_end_io_unwritten);
+	int result;
+	handle_t *handle = NULL;
+	struct inode *inode = file_inode(vma->vm_file);
+	struct super_block *sb = inode->i_sb;
+	bool write = flags & FAULT_FLAG_WRITE;
+
+	if (write) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
+				ext4_chunk_trans_blocks(inode,
+							PMD_SIZE / PAGE_SIZE));
+	}
+
+	if (IS_ERR(handle))
+		result = VM_FAULT_SIGBUS;
+	else
+		result = __dax_pmd_fault(vma, addr, pmd, flags,
+				ext4_get_block_dax, ext4_end_io_unwritten);
+
+	if (write) {
+		if (!IS_ERR(handle))
+			ext4_journal_stop(handle);
+		sb_end_pagefault(sb);
+	}
+
+	return result;
 }
 
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
