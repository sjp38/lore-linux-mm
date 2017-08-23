Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD96C2803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:55:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 83so19933375pgb.14
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:55:22 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h9si1888817plk.680.2017.08.23.16.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:55:21 -0700 (PDT)
Subject: [PATCH v6 4/5] fs,
 xfs: introduce MAP_DIRECT for creating block-map-atomic file ranges
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Aug 2017 16:48:56 -0700
Message-ID: <150353213655.5039.7662200155640827407.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

MAP_DIRECT is an mmap(2) flag with the following semantics:

  MAP_DIRECT
  When specified with MAP_SHARED a successful fault in this range
  indicates that the kernel is maintaining the block map (user linear
  address to file offset to physical address relationship) in a manner
  that no external agent can observe any inconsistent changes. In other
  words, the block map of the mapping is effectively pinned, or the kernel
  is otherwise able to exchange a new physical extent atomically with
  respect to any hardware / software agent. As implied by this definition
  a successful fault in a MAP_DIRECT range bypasses kernel indirections
  like the page-cache, and all updates are carried directly through to the
  underlying file physical-address blocks (modulo cpu cache effects).

  ETXTBSY may be returned to any third party operation on the file that
  attempts to update the block map (allocate blocks / convert unwritten
  extents / break shared extents). However, whether a filesystem returns
  EXTBSY for a certain state of the block relative to a MAP_DIRECT mapping
  is filesystem and kernel version dependent.

  Some filesystems may extend these operation restrictions outside the
  mapped range and return ETXTBSY to any file operations that might mutate
  the block map. MAP_DIRECT faults may fail with a SIGBUS if the
  filesystem needs to write the block map to satisfy the fault. For
  example, if the mapping was established over a hole in a sparse file.

  ERRORS
  EACCES A MAP_DIRECT mapping was requested and PROT_WRITE was not set,
  or the requesting process is missing CAP_LINUX_IMMUTABLE.

  EINVAL MAP_ANONYMOUS or MAP_PRIVATE was specified with MAP_DIRECT.

  EOPNOTSUPP The filesystem explicitly does not support the flag

  SIGBUS Attempted to write a MAP_DIRECT mapping at a file offset that
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
 fs/xfs/xfs_file.c               |  115 ++++++++++++++++++++++++++++++++++++++-
 fs/xfs/xfs_inode.h              |    1 
 fs/xfs/xfs_super.c              |    1 
 include/linux/mman.h            |    6 ++
 include/uapi/asm-generic/mman.h |    1 
 mm/mmap.c                       |   23 ++++++++
 6 files changed, 142 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index cacc0162a41a..f82bf9416200 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -40,6 +40,7 @@
 #include "xfs_iomap.h"
 #include "xfs_reflink.h"
 
+#include <linux/mman.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
@@ -1001,6 +1002,25 @@ xfs_file_llseek(
 	return vfs_setpos(file, offset, inode->i_sb->s_maxbytes);
 }
 
+static const struct vm_operations_struct xfs_file_vm_direct_ops;
+
+STATIC int
+xfs_vma_checks(
+	struct vm_area_struct	*vma,
+	struct inode		*inode)
+{
+	if (vma->vm_ops != &xfs_file_vm_direct_ops)
+		return 0;
+
+	if (xfs_is_reflink_inode(XFS_I(inode)))
+		return VM_FAULT_SIGBUS;
+
+	if (!IS_DAX(inode))
+		return VM_FAULT_SIGBUS;
+
+	return 0;
+}
+
 /*
  * Locking for serialisation of IO during page faults. This results in a lock
  * ordering of:
@@ -1031,6 +1051,10 @@ xfs_filemap_page_mkwrite(
 	file_update_time(vmf->vma->vm_file);
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
+	ret = xfs_vma_checks(vmf->vma, inode);
+	if (ret)
+		goto out_unlock;
+
 	if (IS_DAX(inode)) {
 		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	} else {
@@ -1038,6 +1062,7 @@ xfs_filemap_page_mkwrite(
 		ret = block_page_mkwrite_return(ret);
 	}
 
+out_unlock:
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 
@@ -1058,10 +1083,15 @@ xfs_filemap_fault(
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
@@ -1094,7 +1124,9 @@ xfs_filemap_huge_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
+	ret = xfs_vma_checks(vmf->vma, inode);
+	if (ret == 0)
+		ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
@@ -1137,6 +1169,61 @@ xfs_filemap_pfn_mkwrite(
 
 }
 
+STATIC void
+xfs_filemap_direct_open(
+	struct vm_area_struct	*vma)
+{
+	struct file		*filp = vma->vm_file;
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
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
+xfs_filemap_direct_close(
+	struct vm_area_struct	*vma)
+{
+	struct file		*filp = vma->vm_file;
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
+	if (!atomic_dec_and_xfs_ilock(&ip->i_mapdcount, ip,
+				XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL))
+		return;
+	inode->i_flags &= ~S_IOMAP_SEALED;
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+}
+
+static const struct vm_operations_struct xfs_file_vm_direct_ops = {
+	.fault		= xfs_filemap_fault,
+	.huge_fault	= xfs_filemap_huge_fault,
+	.map_pages	= filemap_map_pages,
+	.page_mkwrite	= xfs_filemap_page_mkwrite,
+	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
+
+	.open		= xfs_filemap_direct_open,
+	.close		= xfs_filemap_direct_close,
+};
+
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
 	.huge_fault	= xfs_filemap_huge_fault,
@@ -1145,14 +1232,33 @@ static const struct vm_operations_struct xfs_file_vm_ops = {
 	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
 };
 
+#define XFS_MAP_SUPPORTED (LEGACY_MAP_SUPPORTED_MASK | MAP_DIRECT)
+
 STATIC int
-xfs_file_mmap(struct file *filp, struct vm_area_struct *vma,
-	      unsigned long map_flags)
+xfs_file_mmap(
+	struct file		*filp,
+	struct vm_area_struct	*vma,
+	unsigned long		map_flags)
 {
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+
+	if (map_flags & ~(XFS_MAP_SUPPORTED))
+		return -EOPNOTSUPP;
+
 	file_accessed(filp);
-	vma->vm_ops = &xfs_file_vm_ops;
 	if (IS_DAX(file_inode(filp)))
 		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+
+	if (map_flags & MAP_DIRECT) {
+		xfs_ilock(ip, XFS_MMAPLOCK_EXCL|XFS_IOLOCK_EXCL);
+		vma->vm_ops = &xfs_file_vm_direct_ops;
+		inode->i_flags |= S_IOMAP_SEALED;
+		atomic_inc(&ip->i_mapdcount);
+		xfs_iunlock(ip, XFS_MMAPLOCK_EXCL|XFS_IOLOCK_EXCL);
+	} else
+		vma->vm_ops = &xfs_file_vm_ops;
+
 	return 0;
 }
 
@@ -1174,6 +1280,7 @@ const struct file_operations xfs_file_operations = {
 	.fallocate	= xfs_file_fallocate,
 	.clone_file_range = xfs_file_clone_range,
 	.dedupe_file_range = xfs_file_dedupe_range,
+	.mmap_supported_mask = XFS_MAP_SUPPORTED,
 };
 
 const struct file_operations xfs_dir_file_operations = {
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
index 38aaacdbb8b3..88711e01e504 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1011,6 +1011,7 @@ xfs_fs_inode_init_once(
 
 	/* xfs inode */
 	atomic_set(&ip->i_pincount, 0);
+	atomic_set(&ip->i_mapdcount, 0);
 	spin_lock_init(&ip->i_flags_lock);
 
 	mrlock_init(&ip->i_mmaplock, MRLOCK_ALLOW_EQUAL_PRI|MRLOCK_BARRIER,
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 64b6cb3dec70..4bebb4ca0f7b 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -20,6 +20,9 @@
 #ifndef MAP_HUGE_1GB
 #define MAP_HUGE_1GB 0
 #endif
+#ifndef MAP_DIRECT
+#define MAP_DIRECT 0
+#endif
 #ifndef MAP_UNINITIALIZED
 #define MAP_UNINITIALIZED 0
 #endif
@@ -47,7 +50,8 @@
 		| MAP_HUGE_2MB \
 		| MAP_HUGE_1GB)
 
-#define	MAP_SUPPORTED_MASK (LEGACY_MAP_SUPPORTED_MASK)
+#define	MAP_SUPPORTED_MASK (LEGACY_MAP_SUPPORTED_MASK \
+		| MAP_DIRECT)
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 7162cd4cca73..1e7dda3bc56a 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_DIRECT	0x80000		/* shared, sealed, and no page cache */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 386706831d67..32417b2a668c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1393,6 +1393,17 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 				return -EACCES;
 
 			/*
+			 * Require write access and the immutable
+			 * capability for MAP_DIRECT mappings
+			 */
+			if (flags & MAP_DIRECT) {
+				if (!(prot & PROT_WRITE))
+					return -EACCES;
+				if (!capable(CAP_LINUX_IMMUTABLE))
+					return -EACCES;
+			}
+
+			/*
 			 * Make sure we don't allow writing to an append-only
 			 * file..
 			 */
@@ -1411,6 +1422,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 
 			/* fall through */
 		case MAP_PRIVATE:
+			if ((flags & (MAP_PRIVATE|MAP_DIRECT))
+					== (MAP_PRIVATE|MAP_DIRECT))
+				return -EINVAL;
 			if (!(file->f_mode & FMODE_READ))
 				return -EACCES;
 			if (path_noexec(&file->f_path)) {
@@ -1448,6 +1462,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		default:
 			return -EINVAL;
 		}
+
+		if (flags & MAP_DIRECT)
+			return -EINVAL;
 	}
 
 	/*
@@ -1525,6 +1542,12 @@ SYSCALL_DEFINE6(mmap_pgoff_strict, unsigned long, addr, unsigned long, len,
 		unsigned long, prot, unsigned long, flags,
 		unsigned long, fd, unsigned long, pgoff)
 {
+	/*
+	 * since mmap flag definitions are spread over several files,
+	 * sanity check new definitions here.
+	 */
+	BUILD_BUG_ON((MAP_DIRECT & ~LEGACY_MAP_SUPPORTED_MASK) != MAP_DIRECT);
+
 	if (flags & ~(MAP_SUPPORTED_MASK))
 		return -EOPNOTSUPP;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
