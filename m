Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8E96B0267
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:47:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so13146009wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:47:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f187si7259781wmg.1.2016.11.24.01.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 01:47:07 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/6] ext4: Simplify DAX fault path
Date: Thu, 24 Nov 2016 10:46:36 +0100
Message-Id: <1479980796-26161-7-git-send-email-jack@suse.cz>
In-Reply-To: <1479980796-26161-1-git-send-email-jack@suse.cz>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Now that dax_iomap_fault() calls ->iomap_begin() without entry lock, we
can use transaction starting in ext4_iomap_begin() and thus simplify
ext4_dax_fault(). It also provides us proper retries in case of ENOSPC.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 48 ++++++++++--------------------------------------
 1 file changed, 10 insertions(+), 38 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b5f184493c57..d663d3d7c81c 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -258,7 +258,6 @@ ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	int result;
-	handle_t *handle = NULL;
 	struct inode *inode = file_inode(vma->vm_file);
 	struct super_block *sb = inode->i_sb;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
@@ -266,24 +265,12 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vma->vm_file);
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
-						EXT4_DATA_TRANS_BLOCKS(sb));
-	} else
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-
-	if (IS_ERR(handle))
-		result = VM_FAULT_SIGBUS;
-	else
-		result = dax_iomap_fault(vma, vmf, &ext4_iomap_ops);
-
-	if (write) {
-		if (!IS_ERR(handle))
-			ext4_journal_stop(handle);
-		up_read(&EXT4_I(inode)->i_mmap_sem);
+	}
+	down_read(&EXT4_I(inode)->i_mmap_sem);
+	result = dax_iomap_fault(vma, vmf, &ext4_iomap_ops);
+	up_read(&EXT4_I(inode)->i_mmap_sem);
+	if (write)
 		sb_end_pagefault(sb);
-	} else
-		up_read(&EXT4_I(inode)->i_mmap_sem);
 
 	return result;
 }
@@ -292,7 +279,6 @@ static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 						pmd_t *pmd, unsigned int flags)
 {
 	int result;
-	handle_t *handle = NULL;
 	struct inode *inode = file_inode(vma->vm_file);
 	struct super_block *sb = inode->i_sb;
 	bool write = flags & FAULT_FLAG_WRITE;
@@ -300,27 +286,13 @@ static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vma->vm_file);
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
-				ext4_chunk_trans_blocks(inode,
-							PMD_SIZE / PAGE_SIZE));
-	} else
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-
-	if (IS_ERR(handle))
-		result = VM_FAULT_SIGBUS;
-	else {
-		result = dax_iomap_pmd_fault(vma, addr, pmd, flags,
-					     &ext4_iomap_ops);
 	}
-
-	if (write) {
-		if (!IS_ERR(handle))
-			ext4_journal_stop(handle);
-		up_read(&EXT4_I(inode)->i_mmap_sem);
+	down_read(&EXT4_I(inode)->i_mmap_sem);
+	result = dax_iomap_pmd_fault(vma, addr, pmd, flags,
+				     &ext4_iomap_ops);
+	up_read(&EXT4_I(inode)->i_mmap_sem);
+	if (write)
 		sb_end_pagefault(sb);
-	} else
-		up_read(&EXT4_I(inode)->i_mmap_sem);
 
 	return result;
 }
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
