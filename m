Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD5366B02F3
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:18:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so874407pgd.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:18:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p9si5061065pgd.519.2017.08.14.23.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 23:18:46 -0700 (PDT)
Subject: [PATCH v4 3/3] fs,
 xfs: introduce MAP_DIRECT for creating block-map-sealed file ranges
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 14 Aug 2017 23:12:22 -0700
Message-ID: <150277754211.23945.458876600578531019.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

MAP_DIRECT is an mmap(2) flag with the following semantics:

  MAP_DIRECT
  In addition to this mapping having MAP_SHARED semantics, successful
  faults in this range may assume that the block map (logical-file-offset
  to physical memory address) is pinned for the lifetime of the mapping.
  Successful MAP_DIRECT faults establish mappings that bypass any kernel
  indirections like the page-cache. All updates are carried directly
  through to the underlying file physical blocks (modulo cpu cache
  effects).

  ETXTBSY is returned on attempts to change the block map (allocate blocks
  / convert unwritten extents / break shared extents) in the mapped range.
  Some filesystems may extend these same restrictions outside the mapped
  range and return ETXTBSY to any file operations that might mutate the
  block map. MAP_DIRECT faults may fail with a SIGSEGV if the filesystem
  needs to write the block map to satisfy the fault. For example, if the
  mapping was established over a hole in a sparse file.

  The kernel ignores attempts to mark a MAP_DIRECT mapping MAP_PRIVATE and
  will silently fall back to MAP_SHARED semantics.

  ERRORS
  EACCES A MAP_DIRECT mapping was requested and PROT_WRITE was not set.

  EINVAL MAP_ANONYMOUS was specified with MAP_DIRECT.

  EOPNOTSUPP The filesystem explicitly does not support the flag

  SIGSEGV Attempted to write a MAP_DIRECT mapping at a file offset that
          might require block-map updates.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c                               |    2 +
 fs/xfs/xfs_file.c                      |  109 ++++++++++++++++++++++++++++++++
 fs/xfs/xfs_inode.h                     |    1 
 fs/xfs/xfs_super.c                     |    1 
 include/linux/mm_types.h               |    1 
 include/linux/mman.h                   |    2 -
 include/uapi/asm-generic/mman-common.h |    1 
 mm/mmap.c                              |    2 +
 8 files changed, 117 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 306c2b603fb8..a654b2dd9016 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1121,6 +1121,8 @@ static int dax_fault_return(int error)
 		return VM_FAULT_NOPAGE;
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM;
+	if (error == -ETXTBSY)
+		return VM_FAULT_SIGSEGV;
 	return VM_FAULT_SIGBUS;
 }
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index c4893e226fd8..fcdf6d5768aa 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -40,6 +40,7 @@
 #include "xfs_iomap.h"
 #include "xfs_reflink.h"
 
+#include <linux/mman.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
@@ -1001,6 +1002,23 @@ xfs_file_llseek(
 	return vfs_setpos(file, offset, inode->i_sb->s_maxbytes);
 }
 
+STATIC int
+xfs_vma_checks(
+	struct vm_area_struct	*vma,
+	struct inode		*inode)
+{
+	if ((vma->fs_flags & MAP_DIRECT) != MAP_DIRECT)
+		return 0;
+
+	if (xfs_is_reflink_inode(XFS_I(inode)))
+		return VM_FAULT_SIGSEGV;
+
+	if (!IS_DAX(inode))
+		return VM_FAULT_SIGSEGV;
+
+	return 0;
+}
+
 /*
  * Locking for serialisation of IO during page faults. This results in a lock
  * ordering of:
@@ -1031,6 +1049,10 @@ xfs_filemap_page_mkwrite(
 	file_update_time(vmf->vma->vm_file);
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
+	ret = xfs_vma_checks(vmf->vma, inode);
+	if (ret)
+		goto out_unlock;
+
 	if (IS_DAX(inode)) {
 		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	} else {
@@ -1038,6 +1060,7 @@ xfs_filemap_page_mkwrite(
 		ret = block_page_mkwrite_return(ret);
 	}
 
+out_unlock:
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 
@@ -1058,10 +1081,15 @@ xfs_filemap_fault(
 		return xfs_filemap_page_mkwrite(vmf);
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	ret = xfs_vma_checks(vmf->vma, inode);
+	if (ret)
+		goto out_unlock;
+
 	if (IS_DAX(inode))
 		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	else
 		ret = filemap_fault(vmf);
+out_unlock:
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	return ret;
@@ -1094,7 +1122,9 @@ xfs_filemap_huge_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
+	ret = xfs_vma_checks(vmf->vma, inode);
+	if (ret == 0)
+		ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
@@ -1137,12 +1167,63 @@ xfs_filemap_pfn_mkwrite(
 
 }
 
+STATIC void
+xfs_filemap_open(
+	struct vm_area_struct	*vma)
+{
+	struct file		*filp = vma->vm_file;
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
+	if ((vma->fs_flags & MAP_DIRECT) != MAP_DIRECT)
+		return;
+	atomic_inc(&ip->i_mapdcount);
+}
+
+STATIC int
+atomic_dec_and_xfs_ilock(
+	atomic_t		*atomic,
+	struct xfs_inode	*ip,
+	uint			lock_flags)
+{
+	/* Subtract 1 from counter unless that drops it to 0 (ie. it was 1) */
+	if (atomic_add_unless(atomic, -1, 1))
+		return 0;
+
+	/* Otherwise do it the slow way */
+	xfs_ilock(ip, lock_flags);
+	if (atomic_dec_and_test(atomic))
+		return 1;
+	xfs_iunlock(ip, lock_flags);
+	return 0;
+}
+
+STATIC void
+xfs_filemap_close(
+	struct vm_area_struct	*vma)
+{
+	struct file		*filp = vma->vm_file;
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
+	if ((vma->fs_flags & MAP_DIRECT) != MAP_DIRECT)
+		return;
+
+	if (!atomic_dec_and_xfs_ilock(&ip->i_mapdcount, ip,
+				XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL))
+		return;
+	inode->i_flags &= ~S_IOMAP_SEALED;
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+}
+
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
 	.huge_fault	= xfs_filemap_huge_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_filemap_page_mkwrite,
 	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
+	.open		= xfs_filemap_open,
+	.close		= xfs_filemap_close,
 };
 
 STATIC int
@@ -1157,6 +1238,31 @@ xfs_file_mmap(
 	return 0;
 }
 
+#define	XFS_MAP_SUPPORTED (MAP_DIRECT)
+
+STATIC int
+xfs_file_fmmap(
+	struct file		*filp,
+	struct vm_area_struct	*vma,
+	unsigned long		flags)
+{
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
+	if (flags & ~(XFS_MAP_SUPPORTED))
+		return -EOPNOTSUPP;
+
+	xfs_ilock(ip, XFS_MMAPLOCK_EXCL|XFS_IOLOCK_EXCL);
+	if ((flags & MAP_DIRECT) == MAP_DIRECT) {
+		vma->fs_flags |= MAP_DIRECT;
+		inode->i_flags |= S_IOMAP_SEALED;
+		atomic_inc(&ip->i_mapdcount);
+	}
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL|XFS_IOLOCK_EXCL);
+
+	return xfs_file_mmap(filp, vma);
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read_iter	= xfs_file_read_iter,
@@ -1168,6 +1274,7 @@ const struct file_operations xfs_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.mmap		= xfs_file_mmap,
+	.fmmap		= xfs_file_fmmap,
 	.open		= xfs_file_open,
 	.release	= xfs_file_release,
 	.fsync		= xfs_file_fsync,
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 0ee453de239a..50d3e1bca1a9 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -58,6 +58,7 @@ typedef struct xfs_inode {
 	mrlock_t		i_lock;		/* inode lock */
 	mrlock_t		i_mmaplock;	/* inode mmap IO lock */
 	atomic_t		i_pincount;	/* inode pin count */
+	atomic_t		i_mapdcount;	/* inode MAP_DIRECT count */
 	spinlock_t		i_flags_lock;	/* inode i_flags lock */
 	/* Miscellaneous state. */
 	unsigned long		i_flags;	/* see defined flags below */
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 664db709cd1a..2604568354db 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1011,6 +1011,7 @@ xfs_fs_inode_init_once(
 
 	/* xfs inode */
 	atomic_set(&ip->i_pincount, 0);
+	atomic_set(&ip->i_mapdcount, 0);
 	spin_lock_init(&ip->i_flags_lock);
 
 	mrlock_init(&ip->i_mmaplock, MRLOCK_ALLOW_EQUAL_PRI|MRLOCK_BARRIER,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ff151814a02d..73fdc0ada9ee 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -306,6 +306,7 @@ struct vm_area_struct {
 	struct mm_struct *vm_mm;	/* The address space we belong to. */
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
+	unsigned long fs_flags;		/* fs flags, see MAP_DIRECT etc */
 
 	/*
 	 * For areas with an address space and backing store,
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 73d4ac7e7136..dc120995f684 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -8,7 +8,7 @@
 #include <uapi/linux/mman.h>
 
 /* the MAP_VALIDATE set of supported flags */
-#define	MAP_SUPPORTED_MASK (0)
+#define	MAP_SUPPORTED_MASK (MAP_DIRECT)
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8bf8c7828275..a16184402c45 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -25,6 +25,7 @@
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
 #define MAP_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* mechanism to define new shared semantics */
+#define MAP_DIRECT (MAP_VALIDATE | 0x40)	/* shared, sealed, and no page cache */
 
 /*
  * Flags for mlock
diff --git a/mm/mmap.c b/mm/mmap.c
index d2919a9e25bf..f12de3859fec 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1393,6 +1393,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 				return -EINVAL;
 			if (!file->f_op->fmmap)
 				return -EOPNOTSUPP;
+			if ((flags & MAP_DIRECT) && !(prot & PROT_WRITE))
+				return -EACCES;
 			/* fall through */
 		case MAP_SHARED:
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
