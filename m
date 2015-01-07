Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCA86B0070
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 17:26:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so7591810pac.8
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 14:26:12 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id oz9si5542107pdb.15.2015.01.07.14.26.09
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 14:26:11 -0800 (PST)
From: Dave Chinner <david@fromorbit.com>
Subject: [RFC PATCH 2/6] xfs: use i_mmaplock on read faults
Date: Thu,  8 Jan 2015 09:25:39 +1100
Message-Id: <1420669543-8093-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Take the i_mmaplock over read page faults. These come through the
->fault callout, so we need to wrap the generic implementation
with the i_mmaplock. While there, add tracepoints for the read
fault as it passes through XFS.

This gives us a lock order of mmap_sem -> i_mmaplock -> page_lock
-> i_lock.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_file.c  | 28 +++++++++++++++++++++++++++-
 fs/xfs/xfs_trace.h |  2 ++
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 13e974e..87535e6 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1349,6 +1349,32 @@ xfs_file_llseek(
 	}
 }
 
+/*
+ * Locking for serialisation of IO during page faults. This results in a lock
+ * ordering of:
+ *
+ * mmap_sem (MM)
+ *   i_mmap_lock (XFS - truncate serialisation)
+ *     page_lock (MM)
+ *       i_lock (XFS - extent map serialisation)
+ */
+STATIC int
+xfs_filemap_fault(
+	struct vm_area_struct	*vma,
+	struct vm_fault		*vmf)
+{
+	struct xfs_inode	*ip = XFS_I(vma->vm_file->f_mapping->host);
+	int			error;
+
+	trace_xfs_filemap_fault(ip);
+
+	xfs_ilock(ip, XFS_MMAPLOCK_SHARED);
+	error = filemap_fault(vma, vmf);
+	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
+
+	return error;
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read		= new_sync_read,
@@ -1381,7 +1407,7 @@ const struct file_operations xfs_dir_file_operations = {
 };
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
-	.fault		= filemap_fault,
+	.fault		= xfs_filemap_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 51372e3..c496153 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -685,6 +685,8 @@ DEFINE_INODE_EVENT(xfs_inode_set_eofblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_clear_eofblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_free_eofblocks_invalid);
 
+DEFINE_INODE_EVENT(xfs_filemap_fault);
+
 DECLARE_EVENT_CLASS(xfs_iref_class,
 	TP_PROTO(struct xfs_inode *ip, unsigned long caller_ip),
 	TP_ARGS(ip, caller_ip),
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
