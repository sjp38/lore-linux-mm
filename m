Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA68A6B000E
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:29:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c83so2895892pfk.5
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:29:18 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z188si7915332pfz.46.2018.02.26.20.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 20:29:17 -0800 (PST)
Subject: [PATCH v4 03/12] ext2, dax: finish implementing dax_sem helpers
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 20:20:11 -0800
Message-ID: <151970521121.26729.7741760690622342144.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Jan Kara <jack@suse.com>

dax_sem_{up,down}_write_sem() allow the ext2 dax semaphore to be compiled
out in the CONFIG_FS_DAX=n case. However there are still some open coded
uses of the semaphore. Add dax_sem_{up_read,down_read,_is_locked}()
helpers and convert all open-coded usages of the semaphore to the
helpers.

Cc: Jan Kara <jack@suse.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/ext2/ext2.h  |    6 ++++++
 fs/ext2/file.c  |    5 ++---
 fs/ext2/inode.c |    4 +---
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index 032295e1d386..7ceb29733cdb 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -711,9 +711,15 @@ struct ext2_inode_info {
 #ifdef CONFIG_FS_DAX
 #define dax_sem_down_write(ext2_inode)	down_write(&(ext2_inode)->dax_sem)
 #define dax_sem_up_write(ext2_inode)	up_write(&(ext2_inode)->dax_sem)
+#define dax_sem_is_locked(ext2_inode)	rwsem_is_locked(&(ext2_inode)->dax_sem)
+#define dax_sem_down_read(ext2_inode)	down_read(&(ext2_inode)->dax_sem)
+#define dax_sem_up_read(ext2_inode)	up_read(&(ext2_inode)->dax_sem)
 #else
 #define dax_sem_down_write(ext2_inode)
 #define dax_sem_up_write(ext2_inode)
+#define dax_sem_is_locked(ext2_inode)	(true)
+#define dax_sem_down_read(ext2_inode)
+#define dax_sem_up_read(ext2_inode)
 #endif
 
 /*
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 09640220fda8..1c7ea1bcddde 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -91,18 +91,17 @@ static ssize_t ext2_dax_write_iter(struct kiocb *iocb, struct iov_iter *from)
 static int ext2_dax_fault(struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vmf->vma->vm_file);
-	struct ext2_inode_info *ei = EXT2_I(inode);
 	int ret;
 
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
 		file_update_time(vmf->vma->vm_file);
 	}
-	down_read(&ei->dax_sem);
+	dax_sem_down_read(EXT2_I(inode));
 
 	ret = dax_iomap_fault(vmf, PE_SIZE_PTE, NULL, NULL, &ext2_iomap_ops);
 
-	up_read(&ei->dax_sem);
+	dax_sem_up_read(EXT2_I(inode));
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		sb_end_pagefault(inode->i_sb);
 	return ret;
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 9b2ac55ac34f..e04295e99d90 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1187,9 +1187,7 @@ static void __ext2_truncate_blocks(struct inode *inode, loff_t offset)
 	blocksize = inode->i_sb->s_blocksize;
 	iblock = (offset + blocksize-1) >> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
 
-#ifdef CONFIG_FS_DAX
-	WARN_ON(!rwsem_is_locked(&ei->dax_sem));
-#endif
+	WARN_ON(!dax_sem_is_locked(ei));
 
 	n = ext2_block_to_path(inode, iblock, offsets, NULL);
 	if (n == 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
