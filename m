Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 651156B0027
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 23:03:13 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t12-v6so4462767plo.9
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 20:03:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u6si3417684pgc.707.2018.03.01.20.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 20:03:12 -0800 (PST)
Subject: [PATCH v5 06/12] ext2, dax: replace IS_DAX() with IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:54:06 -0800
Message-ID: <151996284593.28483.4922911524438696817.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-xfs@vger.kernel.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for fixing the broken definition of S_DAX in the
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case, convert all IS_DAX() usages to
use explicit tests for FSDAX since DAX is ambiguous.

Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/ext2/file.c  |    6 +++---
 fs/ext2/inode.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 5ac98d074323..702a36df6c01 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -119,7 +119,7 @@ static const struct vm_operations_struct ext2_dax_vm_ops = {
 
 static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
-	if (!IS_DAX(file_inode(file)))
+	if (!IS_FSDAX(file_inode(file)))
 		return generic_file_mmap(file, vma);
 
 	file_accessed(file);
@@ -158,14 +158,14 @@ int ext2_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 static ssize_t ext2_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
-	if (IS_DAX(iocb->ki_filp->f_mapping->host))
+	if (IS_FSDAX(iocb->ki_filp->f_mapping->host))
 		return ext2_dax_read_iter(iocb, to);
 	return generic_file_read_iter(iocb, to);
 }
 
 static ssize_t ext2_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
-	if (IS_DAX(iocb->ki_filp->f_mapping->host))
+	if (IS_FSDAX(iocb->ki_filp->f_mapping->host))
 		return ext2_dax_write_iter(iocb, from);
 	return generic_file_write_iter(iocb, from);
 }
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 4783db0e4873..5352207da9d5 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -733,7 +733,7 @@ static int ext2_get_blocks(struct inode *inode,
 		goto cleanup;
 	}
 
-	if (IS_DAX(inode)) {
+	if (IS_FSDAX(inode)) {
 		/*
 		 * We must unmap blocks before zeroing so that writeback cannot
 		 * overwrite zeros with stale data from block device page cache.
@@ -940,7 +940,7 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t offset = iocb->ki_pos;
 	ssize_t ret;
 
-	if (WARN_ON_ONCE(IS_DAX(inode)))
+	if (WARN_ON_ONCE(IS_FSDAX(inode)))
 		return -EIO;
 
 	ret = blockdev_direct_IO(iocb, inode, iter, ext2_get_block);
@@ -1294,7 +1294,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
 
 	inode_dio_wait(inode);
 
-	if (IS_DAX(inode)) {
+	if (IS_FSDAX(inode)) {
 		error = iomap_zero_range(inode, newsize,
 					 PAGE_ALIGN(newsize) - newsize, NULL,
 					 &ext2_iomap_ops);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
