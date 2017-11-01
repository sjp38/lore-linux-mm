Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 595F2280245
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 76so2527478pfr.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si1312495pfb.219.2017.11.01.08.37.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 17/18] xfs: Implement xfs_filemap_pfn_mkwrite() using __xfs_filemap_fault()
Date: Wed,  1 Nov 2017 16:36:46 +0100
Message-Id: <20171101153648.30166-18-jack@suse.cz>
In-Reply-To: <20171101153648.30166-1-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

xfs_filemap_pfn_mkwrite() duplicates a lot of __xfs_filemap_fault().
It will also need to handle flushing for synchronous page faults. So
just make that function use __xfs_filemap_fault().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/xfs/xfs_file.c  | 29 ++++-------------------------
 fs/xfs/xfs_trace.h |  2 --
 2 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 7c6b8def6eed..4496b45678de 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1085,37 +1085,16 @@ xfs_filemap_page_mkwrite(
 }
 
 /*
- * pfn_mkwrite was originally inteneded to ensure we capture time stamp
- * updates on write faults. In reality, it's need to serialise against
- * truncate similar to page_mkwrite. Hence we cycle the XFS_MMAPLOCK_SHARED
- * to ensure we serialise the fault barrier in place.
+ * pfn_mkwrite was originally intended to ensure we capture time stamp updates
+ * on write faults. In reality, it needs to serialise against truncate and
+ * prepare memory for writing so handle is as standard write fault.
  */
 static int
 xfs_filemap_pfn_mkwrite(
 	struct vm_fault		*vmf)
 {
 
-	struct inode		*inode = file_inode(vmf->vma->vm_file);
-	struct xfs_inode	*ip = XFS_I(inode);
-	int			ret = VM_FAULT_NOPAGE;
-	loff_t			size;
-
-	trace_xfs_filemap_pfn_mkwrite(ip);
-
-	sb_start_pagefault(inode->i_sb);
-	file_update_time(vmf->vma->vm_file);
-
-	/* check if the faulting page hasn't raced with truncate */
-	xfs_ilock(ip, XFS_MMAPLOCK_SHARED);
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (vmf->pgoff >= size)
-		ret = VM_FAULT_SIGBUS;
-	else if (IS_DAX(inode))
-		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, NULL, &xfs_iomap_ops);
-	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
-	sb_end_pagefault(inode->i_sb);
-	return ret;
-
+	return __xfs_filemap_fault(vmf, PE_SIZE_PTE, true);
 }
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index bb5514688d47..6333ad09e0f3 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -688,8 +688,6 @@ DEFINE_INODE_EVENT(xfs_inode_set_cowblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_clear_cowblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_free_cowblocks_invalid);
 
-DEFINE_INODE_EVENT(xfs_filemap_pfn_mkwrite);
-
 TRACE_EVENT(xfs_filemap_fault,
 	TP_PROTO(struct xfs_inode *ip, enum page_entry_size pe_size,
 		 bool write_fault),
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
