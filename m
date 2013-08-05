Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id BB5D36B0036
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:44:16 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id 5so3616132pdd.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 12:44:15 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 3/3] ext4: Implement willwrite for the delalloc case
Date: Mon,  5 Aug 2013 12:44:01 -0700
Message-Id: <e7408a082b42ce17872eebf8f59f44252ef63abb.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
References: <cover.1375729665.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 fs/ext4/ext4.h  |  2 ++
 fs/ext4/file.c  |  1 +
 fs/ext4/inode.c | 22 ++++++++++++++++++++++
 3 files changed, 25 insertions(+)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index b577e45..be7308a 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2103,6 +2103,8 @@ extern int ext4_block_zero_page_range(handle_t *handle,
 extern int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
 			     loff_t lstart, loff_t lend);
 extern int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
+extern long ext4_willwrite(struct vm_area_struct *vma,
+			   unsigned long start, unsigned long end);
 extern qsize_t *ext4_get_reserved_space(struct inode *inode);
 extern void ext4_da_update_reserve_space(struct inode *inode,
 					int used, int quota_claim);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 6f4cc56..159226f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -201,6 +201,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+	.willwrite	= ext4_willwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ba33c67..c49e36b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5101,3 +5101,25 @@ out:
 	sb_end_pagefault(inode->i_sb);
 	return ret;
 }
+
+long ext4_willwrite(struct vm_area_struct *vma,
+		    unsigned long start, unsigned long end)
+{
+	int ret = 0;
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	int retries = 0;
+
+	/* We only support the delalloc case */
+	if (test_opt(inode->i_sb, DELALLOC) &&
+	    !ext4_should_journal_data(inode) &&
+	    !ext4_nonda_switch(inode->i_sb)) {
+		do {
+			ret = block_willwrite(vma, start, end,
+					      ext4_da_get_block_prep);
+		} while (ret == -ENOSPC &&
+		       ext4_should_retry_alloc(inode->i_sb, &retries));
+	}
+
+	return ret;
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
