Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0888C6B010E
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:23 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so4393749pdj.22
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:23 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id se7si7625602pbb.139.2014.03.23.12.09.22
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:22 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 10/22] Remove get_xip_mem
Date: Sun, 23 Mar 2014 15:08:36 -0400
Message-Id: <c33e3fbffdd1c3043a2797800bfd5dfdaef9c139.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

All callers of get_xip_mem() are now gone.  Remove checks for it,
initialisers of it, documentation of it and the only implementation of it.

Add documentation for writing a filesystem that supports DAX.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Randy Dunlap <rdunlap@infradead.org>
---
 Documentation/filesystems/Locking |  3 --
 Documentation/filesystems/dax.txt | 82 +++++++++++++++++++++++++++++++++++++++
 Documentation/filesystems/xip.txt | 71 ---------------------------------
 fs/exofs/inode.c                  |  1 -
 fs/ext2/inode.c                   |  1 -
 fs/ext2/xip.c                     | 37 ------------------
 fs/ext2/xip.h                     |  3 --
 fs/open.c                         |  5 +--
 include/linux/fs.h                |  2 -
 mm/fadvise.c                      |  6 ++-
 mm/madvise.c                      |  2 +-
 11 files changed, 88 insertions(+), 125 deletions(-)
 create mode 100644 Documentation/filesystems/dax.txt
 delete mode 100644 Documentation/filesystems/xip.txt

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 5b0c083..2780d47 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -194,8 +194,6 @@ prototypes:
 	void (*freepage)(struct page *);
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
-	int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
-				unsigned long *);
 	int (*migratepage)(struct address_space *, struct page *, struct page *);
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, read_descriptor_t *, unsigned long);
@@ -220,7 +218,6 @@ invalidatepage:		yes
 releasepage:		yes
 freepage:		yes
 direct_IO:
-get_xip_mem:					maybe
 migratepage:		yes (both)
 launder_page:		yes
 is_partially_uptodate:	yes
diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
new file mode 100644
index 0000000..06f84e5
--- /dev/null
+++ b/Documentation/filesystems/dax.txt
@@ -0,0 +1,82 @@
+Execute-in-place for file mappings
+----------------------------------
+
+Motivation
+----------
+
+File mappings are usually performed by mapping page cache pages to
+userspace.  In addition, read & write file operations also transfer data
+between the page cache and storage.
+
+For memory backed storage devices that use the block device interface,
+the page cache pages are just copies of the original storage.  The
+execute-in-place code removes the extra copy by performing reads and
+writes directly on the memory backed storage device.  For file mappings,
+the storage device itself is mapped directly into userspace.
+
+
+Implementation Tips for Block Driver Writers
+--------------------------------------------
+
+To support DAX in your block driver, implement the 'direct_access'
+block device operation.  It is used to translate the sector number
+(expressed in units of 512-byte sectors) to a page frame number (pfn)
+that identifies the physical page for the memory.  It also returns a
+kernel virtual address that can be used to access the memory.
+
+The direct_access method takes a 'size' parameter that indicates the
+number of bytes being requested.  The function should return the number
+of bytes that it can provide, although it must not exceed the number of
+bytes requested.  It may also return a negative errno if an error occurs.
+
+In order to support this method, the storage must be byte-accessible by
+the CPU at all times.  If your device uses paging techniques to expose
+a large amount of memory through a smaller window, then you cannot
+implement direct_access.  Equally, if your device can occasionally
+stall the CPU for an extended period, you should also not attempt to
+implement direct_access.
+
+These block devices may be used for inspiration:
+- axonram: Axon DDR2 device driver
+- brd: RAM backed block device driver
+- dcssblk: s390 dcss block device driver
+
+
+Implementation Tips for Filesystem Writers
+------------------------------------------
+
+Filesystem support consists of
+- adding support to mark inodes as being DAX by setting the S_DAX flag in
+  i_flags
+- implementing the direct_IO address space operation, and calling
+  dax_do_io() instead of blockdev_direct_IO() if S_DAX is set
+- implementing an mmap file operation for DAX files which sets the
+  VM_MIXEDMAP flag on the VMA, and setting the vm_ops to include handlers
+  for fault and page_mkwrite (which should probably call dax_fault() and
+  dax_mkwrite(), passing the appropriate get_block() callback)
+- calling dax_truncate_page() instead of block_truncate_page() for DAX files
+- ensuring that there is sufficient locking between reads, writes,
+  truncates and page faults
+
+The get_block() callback passed to the DAX functions may return
+uninitialised extents.  If it does, it must ensure that simultaneous
+calls to get_block() (for example by a page-fault racing with a read()
+or a write()) work correctly.
+
+These filesystems may be used for inspiration:
+- ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
+
+
+Shortcomings
+------------
+
+Even if the kernel or its modules are stored on a filesystem that supports
+DAX on a block device that supports DAX, they will still be copied into RAM.
+
+Calling get_user_pages() on a range of user memory that has been mmaped
+from a DAX file will fail as there are no 'struct page' to describe
+those pages.  This problem is being worked on.  That means that O_DIRECT
+reads/writes to those memory ranges from a non-DAX file will fail (note
+that O_DIRECT reads/writes _of a DAX file_ do work, it is the memory
+that is being accessed that is key here).  Other things that will not
+work include RDMA, sendfile() and splice().
diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
deleted file mode 100644
index b62eabf..0000000
--- a/Documentation/filesystems/xip.txt
+++ /dev/null
@@ -1,71 +0,0 @@
-Execute-in-place for file mappings
-----------------------------------
-
-Motivation
-----------
-File mappings are performed by mapping page cache pages to userspace. In
-addition, read&write type file operations also transfer data from/to the page
-cache.
-
-For memory backed storage devices that use the block device interface, the page
-cache pages are in fact copies of the original storage. Various approaches
-exist to work around the need for an extra copy. The ramdisk driver for example
-does read the data into the page cache, keeps a reference, and discards the
-original data behind later on.
-
-Execute-in-place solves this issue the other way around: instead of keeping
-data in the page cache, the need to have a page cache copy is eliminated
-completely. With execute-in-place, read&write type operations are performed
-directly from/to the memory backed storage device. For file mappings, the
-storage device itself is mapped directly into userspace.
-
-This implementation was initially written for shared memory segments between
-different virtual machines on s390 hardware to allow multiple machines to
-share the same binaries and libraries.
-
-Implementation
---------------
-Execute-in-place is implemented in three steps: block device operation,
-address space operation, and file operations.
-
-A block device operation named direct_access is used to translate the
-block device sector number to a page frame number (pfn) that identifies
-the physical page for the memory.  It also returns a kernel virtual
-address that can be used to access the memory.
-
-The direct_access method takes a 'size' parameter that indicates the
-number of bytes being requested.  The function should return the number
-of bytes that it can provide, although it must not exceed the number of
-bytes requested.  It may also return a negative errno if an error occurs.
-
-The block device operation is optional, these block devices support it as of
-today:
-- dcssblk: s390 dcss block device driver
-
-An address space operation named get_xip_mem is used to retrieve references
-to a page frame number and a kernel address. To obtain these values a reference
-to an address_space is provided. This function assigns values to the kmem and
-pfn parameters. The third argument indicates whether the function should allocate
-blocks if needed.
-
-This address space operation is mutually exclusive with readpage&writepage that
-do page cache read/write operations.
-The following filesystems support it as of today:
-- ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
-
-A set of file operations that do utilize get_xip_page can be found in
-mm/filemap_xip.c . The following file operation implementations are provided:
-- aio_read/aio_write
-- readv/writev
-- sendfile
-
-The generic file operations do_sync_read/do_sync_write can be used to implement
-classic synchronous IO calls.
-
-Shortcomings
-------------
-This implementation is limited to storage devices that are cpu addressable at
-all times (no highmem or such). It works well on rom/ram, but enhancements are
-needed to make it work with flash in read+write mode.
-Putting the Linux kernel and/or its modules on a xip filesystem does not mean
-they are not copied.
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index ee4317fa..f9a5bf6 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -985,7 +985,6 @@ const struct address_space_operations exofs_aops = {
 	.direct_IO	= exofs_direct_IO,
 
 	/* With these NULL has special meaning or default is not exported */
-	.get_xip_mem	= NULL,
 	.migratepage	= NULL,
 	.launder_page	= NULL,
 	.is_partially_uptodate = NULL,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 252481f..b156fe8 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -891,7 +891,6 @@ const struct address_space_operations ext2_aops = {
 
 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
-	.get_xip_mem		= ext2_get_xip_mem,
 	.direct_IO		= ext2_direct_IO,
 };
 
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index fa40091..ca745ff 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -22,27 +22,6 @@ static inline long __inode_direct_access(struct inode *inode, sector_t block,
 	return ops->direct_access(bdev, sector, kaddr, pfn, size);
 }
 
-static inline int
-__ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
-		   sector_t *result)
-{
-	struct buffer_head tmp;
-	int rc;
-
-	memset(&tmp, 0, sizeof(struct buffer_head));
-	tmp.b_size = 1 << inode->i_blkbits;
-	rc = ext2_get_block(inode, pgoff, &tmp, create);
-	*result = tmp.b_blocknr;
-
-	/* did we get a sparse block (hole in the file)? */
-	if (!tmp.b_blocknr && !rc) {
-		BUG_ON(create);
-		rc = -ENODATA;
-	}
-
-	return rc;
-}
-
 int
 ext2_clear_xip_target(struct inode *inode, sector_t block)
 {
@@ -69,19 +48,3 @@ void ext2_xip_verify_sb(struct super_block *sb)
 			     "not supported by bdev");
 	}
 }
-
-int ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
-				void **kmem, unsigned long *pfn)
-{
-	long rc;
-	sector_t block;
-
-	/* first, retrieve the sector number */
-	rc = __ext2_get_block(mapping->host, pgoff, create, &block);
-	if (rc)
-		return rc;
-
-	/* retrieve address of the target data */
-	rc = __inode_direct_access(mapping->host, block, kmem, pfn, PAGE_SIZE);
-	return (rc < 0) ? rc : 0;
-}
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index 29be737..0fa8b7f 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -14,11 +14,8 @@ static inline int ext2_use_xip (struct super_block *sb)
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
 }
-int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
-				void **, unsigned long *);
 #else
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
-#define ext2_get_xip_mem			NULL
 #endif
diff --git a/fs/open.c b/fs/open.c
index b9ed8b2..bc9f002 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -665,11 +665,8 @@ int open_check_o_direct(struct file *f)
 {
 	/* NB: we're sure to have correct a_ops only after f_op->open */
 	if (f->f_flags & O_DIRECT) {
-		if (!f->f_mapping->a_ops ||
-		    ((!f->f_mapping->a_ops->direct_IO) &&
-		    (!f->f_mapping->a_ops->get_xip_mem))) {
+		if (!f->f_mapping->a_ops || !f->f_mapping->a_ops->direct_IO)
 			return -EINVAL;
-		}
 	}
 	return 0;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9752ae5..c777056 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -375,8 +375,6 @@ struct address_space_operations {
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
-	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
-						void **, unsigned long *);
 	/*
 	 * migrate the contents of a page to the specified target. If
 	 * migrate_mode is MIGRATE_ASYNC, it must not block.
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81..1f1925f 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -28,6 +28,7 @@
 SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 {
 	struct fd f = fdget(fd);
+	struct inode *inode;
 	struct address_space *mapping;
 	struct backing_dev_info *bdi;
 	loff_t endbyte;			/* inclusive */
@@ -39,7 +40,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	if (!f.file)
 		return -EBADF;
 
-	if (S_ISFIFO(file_inode(f.file)->i_mode)) {
+	inode = file_inode(f.file);
+	if (S_ISFIFO(inode->i_mode)) {
 		ret = -ESPIPE;
 		goto out;
 	}
@@ -50,7 +52,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		goto out;
 	}
 
-	if (mapping->a_ops->get_xip_mem) {
+	if (IS_DAX(inode)) {
 		switch (advice) {
 		case POSIX_FADV_NORMAL:
 		case POSIX_FADV_RANDOM:
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb9..b6a2f52 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -236,7 +236,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	if (!file)
 		return -EBADF;
 
-	if (file->f_mapping->a_ops->get_xip_mem) {
+	if (IS_DAX(file_inode(file))) {
 		/* no bad return value, but ignore advice */
 		return 0;
 	}
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
