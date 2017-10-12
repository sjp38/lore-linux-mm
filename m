Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 673646B0270
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 20:54:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z80so7649330pff.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:54:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h132si946732pfe.87.2017.10.11.17.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 17:54:05 -0700 (PDT)
Subject: [PATCH v9 6/6] xfs: wire up MAP_DIRECT
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 17:47:40 -0700
Message-ID: <150776926029.9144.10163099373354512491.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

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

  EPERM The file does not permit MAP_DIRECT mappings. Potential reasons
  are that DAX access is not available or the file has reflink extents.

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
 fs/xfs/xfs_file.c               |  107 ++++++++++++++++++++++++++++++++++++++-
 include/linux/mman.h            |    3 +
 include/uapi/asm-generic/mman.h |    1 
 4 files changed, 110 insertions(+), 3 deletions(-)

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
index 3cc7292b2e9f..71dbe0307746 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -41,12 +41,22 @@
 #include "xfs_reflink.h"
 #include "xfs_layout.h"
 
+#include <linux/mman.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
+#include <linux/mapdirect.h>
 #include <linux/backing-dev.h>
 
 static const struct vm_operations_struct xfs_file_vm_ops;
+static const struct vm_operations_struct xfs_file_vm_direct_ops;
+
+static bool
+xfs_vma_is_direct(
+	struct vm_area_struct	*vma)
+{
+	return vma->vm_ops == &xfs_file_vm_direct_ops;
+}
 
 /*
  * Clear the specified ranges to zero through either the pagecache or DAX.
@@ -1013,6 +1023,25 @@ xfs_file_llseek(
 }
 
 /*
+ * MAP_DIRECT faults can only be serviced while the FL_LAYOUT lease is
+ * valid. See map_direct_invalidate.
+ */
+static bool
+xfs_vma_has_direct_lease(
+	struct vm_area_struct	*vma)
+{
+	/* Non MAP_DIRECT vmas do not require layout leases */
+	if (!xfs_vma_is_direct(vma))
+		return true;
+
+	if (!test_map_direct_valid(vma->vm_private_data))
+		return false;
+
+	/* We have a valid lease */
+	return true;
+}
+
+/*
  * Locking for serialisation of IO during page faults. This results in a lock
  * ordering of:
  *
@@ -1028,7 +1057,8 @@ __xfs_filemap_fault(
 	enum page_entry_size	pe_size,
 	bool			write_fault)
 {
-	struct inode		*inode = file_inode(vmf->vma->vm_file);
+	struct vm_area_struct	*vma = vmf->vma;
+	struct inode		*inode = file_inode(vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
 	int			ret;
 
@@ -1036,10 +1066,15 @@ __xfs_filemap_fault(
 
 	if (write_fault) {
 		sb_start_pagefault(inode->i_sb);
-		file_update_time(vmf->vma->vm_file);
+		file_update_time(vma->vm_file);
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	if (!xfs_vma_has_direct_lease(vma)) {
+		ret = VM_FAULT_SIGBUS;
+		goto out_unlock;
+	}
+
 	if (IS_DAX(inode)) {
 		ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
 	} else {
@@ -1048,6 +1083,8 @@ __xfs_filemap_fault(
 		else
 			ret = filemap_fault(vmf);
 	}
+
+out_unlock:
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (write_fault)
@@ -1119,6 +1156,17 @@ xfs_filemap_pfn_mkwrite(
 
 }
 
+static const struct vm_operations_struct xfs_file_vm_direct_ops = {
+	.fault		= xfs_filemap_fault,
+	.huge_fault	= xfs_filemap_huge_fault,
+	.map_pages	= filemap_map_pages,
+	.page_mkwrite	= xfs_filemap_page_mkwrite,
+	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
+
+	.open		= generic_map_direct_open,
+	.close		= generic_map_direct_close,
+};
+
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
 	.huge_fault	= xfs_filemap_huge_fault,
@@ -1139,6 +1187,60 @@ xfs_file_mmap(
 	return 0;
 }
 
+static int
+xfs_file_mmap_direct(
+	struct file		*filp,
+	struct vm_area_struct	*vma,
+	int			fd)
+{
+	struct inode		*inode = file_inode(filp);
+	struct xfs_inode	*ip = XFS_I(inode);
+	struct map_direct_state	*mds;
+
+	/*
+	 * Not permitted to set up MAP_DIRECT mapping over reflinked or
+	 * non-DAX extents since reflink may cause block moves /
+	 * copy-on-write, and non-DAX is by definition always indirect
+	 * through the page cache.
+	 */
+	if (xfs_is_reflink_inode(ip))
+		return -EPERM;
+	if (!IS_DAX(inode))
+		return -EPERM;
+
+	mds = map_direct_register(fd, vma);
+	if (IS_ERR(mds))
+		return PTR_ERR(mds);
+
+	file_accessed(filp);
+	vma->vm_ops = &xfs_file_vm_direct_ops;
+	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+
+	/*
+	 * generic_map_direct_{open,close} expect ->vm_private_data is
+	 * set to the result of map_direct_register
+	 */
+	vma->vm_private_data = mds;
+	return 0;
+}
+
+#define XFS_MAP_SUPPORTED (LEGACY_MAP_MASK | MAP_DIRECT)
+
+static int
+xfs_file_mmap_validate(
+	struct file		*filp,
+	struct vm_area_struct	*vma,
+	unsigned long		map_flags,
+	int			fd)
+{
+	if (map_flags & ~(XFS_MAP_SUPPORTED))
+		return -EOPNOTSUPP;
+
+	if ((map_flags & MAP_DIRECT) == 0)
+		return xfs_file_mmap(filp, vma);
+	return xfs_file_mmap_direct(filp, vma, fd);
+}
+
 const struct file_operations xfs_file_operations = {
 	.llseek		= xfs_file_llseek,
 	.read_iter	= xfs_file_read_iter,
@@ -1150,6 +1252,7 @@ const struct file_operations xfs_file_operations = {
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
