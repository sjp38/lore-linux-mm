Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD30280401
	for <linux-mm@kvack.org>; Tue,  9 May 2017 08:18:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g67so19452887wrd.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 05:18:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i201si34538wmd.25.2017.05.09.05.18.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 05:18:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/4] ext4: Return back to starting transaction in ext4_dax_huge_fault()
Date: Tue,  9 May 2017 14:18:36 +0200
Message-Id: <20170509121837.26153-4-jack@suse.cz>
In-Reply-To: <20170509121837.26153-1-jack@suse.cz>
References: <20170509121837.26153-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, stable@vger.kernel.org

DAX will return to locking exceptional entry before mapping blocks
for a page fault to fix possible races with concurrent writes. To avoid
lock inversion between exceptional entry lock and transaction start,
start the transaction already in ext4_dax_huge_fault().

Fixes: 9f141d6ef6258a3a37a045842d9ba7e68f368956
CC: stable@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index cefa9835f275..831fd6beebf0 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -257,6 +257,7 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size)
 {
 	int result;
+	handle_t *handle = NULL;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
 	struct super_block *sb = inode->i_sb;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
@@ -264,12 +265,24 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
 	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vmf->vma->vm_file);
+		down_read(&EXT4_I(inode)->i_mmap_sem);
+		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
+					       EXT4_DATA_TRANS_BLOCKS(sb));
+	} else {
+		down_read(&EXT4_I(inode)->i_mmap_sem);
 	}
-	down_read(&EXT4_I(inode)->i_mmap_sem);
-	result = dax_iomap_fault(vmf, pe_size, &ext4_iomap_ops);
-	up_read(&EXT4_I(inode)->i_mmap_sem);
-	if (write)
+	if (!IS_ERR(handle))
+		result = dax_iomap_fault(vmf, pe_size, &ext4_iomap_ops);
+	else
+		result = VM_FAULT_SIGBUS;
+	if (write) {
+		if (!IS_ERR(handle))
+			ext4_journal_stop(handle);
+		up_read(&EXT4_I(inode)->i_mmap_sem);
 		sb_end_pagefault(sb);
+	} else {
+		up_read(&EXT4_I(inode)->i_mmap_sem);
+	}
 
 	return result;
 }
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
