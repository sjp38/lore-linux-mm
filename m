Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 155D86B0261
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:42:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c137so38848974pga.6
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:42:16 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d8si2029160pfh.621.2017.10.06.15.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:42:14 -0700 (PDT)
Subject: [PATCH v7 06/12] xfs: wire up MAP_DIRECT
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:35:49 -0700
Message-ID: <150732934955.22363.14950885120988262779.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

MAP_DIRECT is an mmap(2) flag with the following semantics:

  MAP_DIRECT
  When specified with MAP_SHARED_VALIDATE, sets up a file lease with the
  same lifetime as the mapping. Unlike a typical F_RDLCK lease this lease
  is broken when a "lease breaker" attempts to write(2), change the block
  map (fallocate), or change the size of the file. Otherwise the mechanism
  of a lease break is identical to the typical lease break case where the
  lease needs to be removed (munmap) within the number of seconds
  specified by /proc/sys/fs/lease-break-time. If the lease holder fails to
  remove the lease in time the kernel will invalidate the mapping and
  force all future accesses to the mapping to trigger SIGBUS.

  In addition to lease break timeouts causing faults in the mapping to
  result in SIGBUS, other states of the file will trigger SIGBUS at fault
  time:

      * The file is not DAX capable
      * The file has reflinked (copy-on-write) blocks
      * The fault would trigger the filesystem to allocate blocks
      * The fault would trigger the filesystem to perform extent conversion

  In other words, MAP_DIRECT expects and enforces a fully allocated file
  where faults can be satisfied without modifying block map metadata.

  An unprivileged process may establish a MAP_DIRECT mapping on a file
  whose UID (owner) matches the filesystem UID of the  process. A process
  with the CAP_LEASE capability may establish a MAP_DIRECT mapping on
  arbitrary files

  ERRORS
  EACCES Beyond the typical mmap(2) conditions that trigger EACCES
  MAP_DIRECT also requires the permission to set a file lease.

  EOPNOTSUPP The filesystem explicitly does not support the flag

  SIGBUS Attempted to write a MAP_DIRECT mapping at a file offset that
         might require block-map updates, or the lease timed out and the
         kernel invalidated the mapping.

Cc: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/xfs/Kconfig                  |    2 -
 fs/xfs/xfs_file.c               |  102 +++++++++++++++++++++++++++++++++++++++
 include/linux/mman.h            |    3 +
 include/uapi/asm-generic/mman.h |    1 
 4 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/Kconfig b/fs/xfs/Kconfig
index f62fc6629abb..f8765653a438 100644
--- a/fs/xfs/Kconfig
+++ b/fs/xfs/Kconfig
@@ -112,4 +112,4 @@ config XFS_ASSERT_FATAL
 
 config XFS_LAYOUT
 	def_bool y
-	depends on EXPORTFS_BLOCK_OPS
+	depends on EXPORTFS_BLOCK_OPS || FS_DAX
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index ebdd0bd2b261..e35518600e28 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -40,12 +40,22 @@
 #include "xfs_iomap.h"
 #include "xfs_reflink.h"
 
+#include <linux/mman.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
+#include <linux/mapdirect.h>
 #include <linux/backing-dev.h>
 
 static const struct vm_operations_struct xfs_file_vm_ops;
+static const struct vm_operations_struct xfs_file_vm_direct_ops;
+
+static inline bool
+is_xfs_map_direct(
+		struct vm_area_struct *vma)
+{
+	return vma->vm_ops == &xfs_file_vm_direct_ops;
+}
 
 /*
  * Clear the specified ranges to zero through either the pagecache or DAX.
@@ -1008,6 +1018,26 @@ xfs_file_llseek(
 	return vfs_setpos(file, offset, inode->i_sb->s_maxbytes);
 }
 
+static int
+xfs_vma_checks(
+	struct vm_area_struct	*vma,
+	struct inode		*inode)
+{
+	if (!is_xfs_map_direct(vma))
+		return 0;
+
+	if (!is_map_direct_valid(vma->vm_private_data))
+		return VM_FAULT_SIGBUS;
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
@@ -1024,6 +1054,7 @@ __xfs_filemap_fault(
 	enum page_entry_size	pe_size,
 	bool			write_fault)
 {
+	struct vm_area_struct	*vma = vmf->vma;
 	struct inode		*inode = file_inode(vmf->vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
 	int			ret;
@@ -1032,10 +1063,14 @@ __xfs_filemap_fault(
 
 	if (write_fault) {
 		sb_start_pagefault(inode->i_sb);
-		file_update_time(vmf->vma->vm_file);
+		file_update_time(vma->vm_file);
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	ret = xfs_vma_checks(vma, inode);
+	if (ret)
+		goto out_unlock;
+
 	if (IS_DAX(inode)) {
 		ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
 	} else {
@@ -1044,6 +1079,8 @@ __xfs_filemap_fault(
 		else
 			ret = filemap_fault(vmf);
 	}
+
+out_unlock:
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (write_fault)
@@ -1115,6 +1152,31 @@ xfs_filemap_pfn_mkwrite(
 
 }
 
+static void
+xfs_filemap_direct_open(
+	struct vm_area_struct	*vma)
+{
+	get_map_direct_vma(vma->vm_private_data);
+}
+
+static void
+xfs_filemap_direct_close(
+	struct vm_area_struct	*vma)
+{
+	put_map_direct_vma(vma->vm_private_data);
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
@@ -1135,6 +1197,43 @@ xfs_file_mmap(
 	return 0;
 }
 
+#define XFS_MAP_SUPPORTED (LEGACY_MAP_MASK | MAP_DIRECT)
+
+STATIC int
+xfs_file_mmap_validate(
+	struct file		*filp,
+	struct vm_area_struct	*vma,
+	unsigned long		map_flags,
+	int			fd)
+{
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+	struct map_direct_state	*mds;
+
+	if (map_flags & ~(XFS_MAP_SUPPORTED))
+		return -EOPNOTSUPP;
+
+	if ((map_flags & MAP_DIRECT) == 0)
+		return xfs_file_mmap(filp, vma);
+
+	file_accessed(filp);
+	vma->vm_ops = &xfs_file_vm_direct_ops;
+	if (IS_DAX(inode))
+		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+
+	mds = map_direct_register(fd, vma);
+	if (IS_ERR(mds))
+		return PTR_ERR(mds);
+
+	/* flush in-flight faults */
+	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
+
+	vma->vm_private_data = mds;
+
+	return 0;
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read_iter	= xfs_file_read_iter,
@@ -1146,6 +1245,7 @@ const struct file_operations xfs_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.mmap		= xfs_file_mmap,
+	.mmap_validate	= xfs_file_mmap_validate,
 	.open		= xfs_file_open,
 	.release	= xfs_file_release,
 	.fsync		= xfs_file_fsync,
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 94b63b4d71ff..fab393a9dda9 100644
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
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 7162cd4cca73..c916f22008e0 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_DIRECT	0x80000		/* leased block map (layout) for DAX */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
