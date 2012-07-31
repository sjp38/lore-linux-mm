Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 9CA7E6B007D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:42:25 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4882724lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:42:25 -0700 (PDT)
Subject: [PATCH v3 06/10] mm: kill vma flag VM_CAN_NONLINEAR
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:42:21 +0400
Message-ID: <20120731104221.20515.90791.stgit@zurg>
In-Reply-To: <20120731103724.20515.60334.stgit@zurg>
References: <20120731103724.20515.60334.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>

This patch moves actual ptes filling for non-linear file mappings
into special vma operation: ->remap_pages().

File system must implement this method to get non-linear mappings support,
if it uses filemap_fault() then generic_file_remap_pages() can be used.

Now device drivers can implement this method and obtain nonlinear vma support.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Ingo Molnar <mingo@redhat.com>
---
 drivers/staging/android/ashmem.c |    1 -
 fs/9p/vfs_file.c                 |    1 +
 fs/btrfs/file.c                  |    2 +-
 fs/ceph/addr.c                   |    2 +-
 fs/cifs/file.c                   |    1 +
 fs/ext4/file.c                   |    2 +-
 fs/fuse/file.c                   |    1 +
 fs/gfs2/file.c                   |    2 +-
 fs/nfs/file.c                    |    1 +
 fs/nilfs2/file.c                 |    2 +-
 fs/ocfs2/mmap.c                  |    2 +-
 fs/ubifs/file.c                  |    1 +
 fs/xfs/xfs_file.c                |    2 +-
 include/linux/fs.h               |    2 ++
 include/linux/mm.h               |    7 ++++---
 mm/filemap.c                     |    2 +-
 mm/filemap_xip.c                 |    3 ++-
 mm/fremap.c                      |   14 ++++++++------
 mm/mmap.c                        |    3 +--
 mm/nommu.c                       |    8 ++++++++
 mm/shmem.c                       |    3 +--
 21 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 69cf2db..f3655b3 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -332,7 +332,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	vma->vm_file = asma->file;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 out:
 	mutex_unlock(&ashmem_mutex);
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index fc06fd2..34b84f0 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -735,6 +735,7 @@ v9fs_cached_file_write(struct file *filp, const char __user * data,
 static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 9aa01ec..c5217b5 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1598,6 +1598,7 @@ out:
 static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= btrfs_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
@@ -1609,7 +1610,6 @@ static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
 
 	file_accessed(filp);
 	vma->vm_ops = &btrfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	return 0;
 }
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 8b67304..1cd90d8 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1222,6 +1222,7 @@ out:
 static struct vm_operations_struct ceph_vmops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= ceph_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 int ceph_mmap(struct file *file, struct vm_area_struct *vma)
@@ -1232,6 +1233,5 @@ int ceph_mmap(struct file *file, struct vm_area_struct *vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &ceph_vmops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 9154192..66fca97 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2842,6 +2842,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = cifs_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3b0e3bd..04e8967 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -207,6 +207,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
@@ -217,7 +218,6 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &ext4_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index b321a68..1975327 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1376,6 +1376,7 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
 	.page_mkwrite	= fuse_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 9aa6af1..b556a12 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -476,6 +476,7 @@ out:
 static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = gfs2_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 /**
@@ -510,7 +511,6 @@ static int gfs2_mmap(struct file *file, struct vm_area_struct *vma)
 			return error;
 	}
 	vma->vm_ops = &gfs2_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	return 0;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 70d124a..1b9cd19 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -546,6 +546,7 @@ out:
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = nfs_vm_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 62cebc8..6e131bd 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -130,13 +130,13 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= nilfs_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	file_accessed(file);
 	vma->vm_ops = &nilfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 9cd4108..7aef3f4 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -171,6 +171,7 @@ out:
 static const struct vm_operations_struct ocfs2_file_vm_ops = {
 	.fault		= ocfs2_fault,
 	.page_mkwrite	= ocfs2_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
@@ -186,7 +187,6 @@ int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
 	ocfs2_inode_unlock(file->f_dentry->d_inode, lock_level);
 out:
 	vma->vm_ops = &ocfs2_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 35389ca..55144f1 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1536,6 +1536,7 @@ out_unlock:
 static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index c4559c6..cb50841 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -935,7 +935,6 @@ xfs_file_mmap(
 	struct vm_area_struct *vma)
 {
 	vma->vm_ops = &xfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	file_accessed(filp);
 	return 0;
@@ -1130,4 +1129,5 @@ const struct file_operations xfs_dir_file_operations = {
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8fabb03..d3584a3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2413,6 +2413,8 @@ extern int sb_min_blocksize(struct super_block *, int);
 
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_remap_pages(struct vm_area_struct *, unsigned long addr,
+		unsigned long size, pgoff_t pgoff);
 extern int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size);
 int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk);
 extern ssize_t generic_file_aio_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index cdff0ed..6eb4406 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -105,7 +105,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_NODUMP	0x04000000	/* Do not include in the core dump */
 
-#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
@@ -171,8 +170,7 @@ extern pgprot_t protection_map[16];
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
  * pgoff should be used in favour of virtual_address, if possible. If pgoff
- * is used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get nonlinear
- * mapping support.
+ * is used, one may implement ->remap_pages to get nonlinear mapping support.
  */
 struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
@@ -230,6 +228,9 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+	/* called by sys_remap_file_pages() to populate non-linear mapping */
+	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
+			   unsigned long size, pgoff_t pgoff);
 };
 
 struct mmu_gather;
diff --git a/mm/filemap.c b/mm/filemap.c
index a4a5260..517a361 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1714,6 +1714,7 @@ EXPORT_SYMBOL(filemap_fault);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 /* This is used for a general mmap of a disk file */
@@ -1726,7 +1727,6 @@ int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &generic_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 213ca1f..9b0a827 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -304,6 +304,7 @@ out:
 
 static const struct vm_operations_struct xip_file_vm_ops = {
 	.fault	= xip_file_fault,
+	.remap_pages = generic_file_remap_pages,
 };
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
@@ -312,7 +313,7 @@ int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
 
 	file_accessed(file);
 	vma->vm_ops = &xip_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR | VM_MIXEDMAP;
+	vma->vm_flags |= VM_MIXEDMAP;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_file_mmap);
diff --git a/mm/fremap.c b/mm/fremap.c
index 9ed4fd4..c70190a 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -5,6 +5,7 @@
  *
  * started by Ingo Molnar, Copyright (C) 2002, 2003
  */
+#include <linux/export.h>
 #include <linux/backing-dev.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -80,9 +81,10 @@ out:
 	return err;
 }
 
-static int populate_range(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long addr, unsigned long size, pgoff_t pgoff)
+int generic_file_remap_pages(struct vm_area_struct *vma, unsigned long addr,
+			     unsigned long size, pgoff_t pgoff)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
 	do {
@@ -95,9 +97,9 @@ static int populate_range(struct mm_struct *mm, struct vm_area_struct *vma,
 		pgoff++;
 	} while (size);
 
-        return 0;
-
+	return 0;
 }
+EXPORT_SYMBOL(generic_file_remap_pages);
 
 /**
  * sys_remap_file_pages - remap arbitrary pages of an existing VM_SHARED vma
@@ -167,7 +169,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR))
 		goto out;
 
-	if (!(vma->vm_flags & VM_CAN_NONLINEAR))
+	if (!vma->vm_ops->remap_pages)
 		goto out;
 
 	if (start < vma->vm_start || start + size > vma->vm_end)
@@ -229,7 +231,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	}
 
 	mmu_notifier_invalidate_range_start(mm, start, start + size);
-	err = populate_range(mm, vma, start, size, pgoff);
+	err = vma->vm_ops->remap_pages(vma, start, size, pgoff);
 	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (vma->vm_flags & VM_LOCKED) {
diff --git a/mm/mmap.c b/mm/mmap.c
index 47a74c4..56231b7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -669,8 +669,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
 {
-	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
-	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
+	if (vma->vm_flags ^ vm_flags)
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
diff --git a/mm/nommu.c b/mm/nommu.c
index d4b0c10..686d200 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1963,6 +1963,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
 
+int generic_file_remap_pages(struct vm_area_struct *vma, unsigned long addr,
+			     unsigned long size, pgoff_t pgoff)
+{
+	BUG();
+	return 0;
+}
+EXPORT_SYMBOL(generic_file_remap_pages);
+
 static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, int write)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index c15b998..19a3b5c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1348,7 +1348,6 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
@@ -2786,6 +2785,7 @@ static const struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
@@ -2979,7 +2979,6 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 		fput(vma->vm_file);
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
