Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B8EF782F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 11:20:58 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id q3so129737693pav.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:20:58 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id se8si9718085pac.136.2015.12.24.08.20.45
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 08:20:45 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 8/8] ext4: Transparent support for PUD-sized transparent huge pages
Date: Thu, 24 Dec 2015 11:20:37 -0500
Message-Id: <1450974037-24775-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

Call into DAX to provide support for PUD pages, just like the PMD cases.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/ext4/file.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 60683ab..b0cba51 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -262,6 +262,42 @@ static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 	return result;
 }
 
+static int ext4_dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
+						pud_t *pud, unsigned int flags)
+{
+	int result;
+	handle_t *handle = NULL;
+	struct inode *inode = file_inode(vma->vm_file);
+	struct super_block *sb = inode->i_sb;
+	bool write = flags & FAULT_FLAG_WRITE;
+
+	if (write) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+		down_read(&EXT4_I(inode)->i_mmap_sem);
+		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
+				ext4_chunk_trans_blocks(inode,
+							PMD_SIZE / PAGE_SIZE));
+	} else
+		down_read(&EXT4_I(inode)->i_mmap_sem);
+
+	if (IS_ERR(handle))
+		result = VM_FAULT_SIGBUS;
+	else
+		result = __dax_pud_fault(vma, addr, pud, flags,
+				ext4_dax_mmap_get_block, NULL);
+
+	if (write) {
+		if (!IS_ERR(handle))
+			ext4_journal_stop(handle);
+		up_read(&EXT4_I(inode)->i_mmap_sem);
+		sb_end_pagefault(sb);
+	} else
+		up_read(&EXT4_I(inode)->i_mmap_sem);
+
+	return result;
+}
+
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	int err;
@@ -309,6 +345,7 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
 	.pmd_fault	= ext4_dax_pmd_fault,
+	.pud_fault	= ext4_dax_pud_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
 	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
 };
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
