Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 049446B007E
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:29:18 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1494120bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:29:18 -0700 (PDT)
Subject: [PATCH 3/7] mm: kill vma flag VM_CAN_NONLINEAR
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:29:15 +0400
Message-ID: <20120331092915.19920.14205.stgit@zurg>
In-Reply-To: <20120331091049.19373.28994.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>

This patch moves actual ptes filling for non-linear file mappings
into special vma operation: ->remap_pages().

Now fs must implement this method to get non-linear mappings support.
If fs uses filemap_fault() then it can use generic_file_remap_pages() for this.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
---
 drivers/staging/android/ashmem.c |    1 -
 fs/9p/vfs_file.c                 |    1 +
 fs/btrfs/file.c                  |    2 +-
 fs/ceph/addr.c                   |    2 +-
 fs/cifs/file.c                   |    1 +
 fs/ecryptfs/file.c               |    1 +
 fs/ext4/file.c                   |    2 +-
 fs/fuse/file.c                   |    1 +
 fs/gfs2/file.c                   |    2 +-
 fs/nfs/file.c                    |    1 +
 fs/nilfs2/file.c                 |    2 +-
 fs/ocfs2/mmap.c                  |    2 +-
 fs/ubifs/file.c                  |    1 +
 fs/xfs/xfs_file.c                |    2 +-
 include/linux/fs.h               |    2 ++
 include/linux/mm.h               |    6 +++---
 mm/filemap.c                     |    2 +-
 mm/filemap_xip.c                 |    3 ++-
 mm/fremap.c                      |   14 ++++++++------
 mm/mmap.c                        |    3 +--
 mm/nommu.c                       |    8 ++++++++
 mm/shmem.c                       |    3 +--
 22 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 9f1f27e..8b36d3d 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -329,7 +329,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
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
index d83260d..29a8cfb 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1576,6 +1576,7 @@ out:
 static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= btrfs_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
@@ -1587,7 +1588,6 @@ static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
 
 	file_accessed(filp);
 	vma->vm_ops = &btrfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	return 0;
 }
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 173b1d2..1745051 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1219,6 +1219,7 @@ out:
 static struct vm_operations_struct ceph_vmops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= ceph_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 int ceph_mmap(struct file *file, struct vm_area_struct *vma)
@@ -1229,6 +1230,5 @@ int ceph_mmap(struct file *file, struct vm_area_struct *vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &ceph_vmops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 460d87b..591757f 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2557,6 +2557,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = cifs_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index 2b17f2f..367de3b 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -146,6 +146,7 @@ static void ecryptfs_vma_close(struct vm_area_struct *vma)
 static const struct vm_operations_struct ecryptfs_file_vm_ops = {
 	.close		= ecryptfs_vma_close,
 	.fault		= filemap_fault,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int ecryptfs_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index cb70f18..adc9a39 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -144,6 +144,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
@@ -154,7 +155,6 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &ext4_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index a841868..804f0ac 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1331,6 +1331,7 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
 	.page_mkwrite	= fuse_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 7683458..9f0804b 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -470,6 +470,7 @@ out:
 static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = gfs2_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 /**
@@ -504,7 +505,6 @@ static int gfs2_mmap(struct file *file, struct vm_area_struct *vma)
 			return error;
 	}
 	vma->vm_ops = &gfs2_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	return 0;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index aa9b709..31eae53 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -550,6 +550,7 @@ out:
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = nfs_vm_page_mkwrite,
+	.remap_pages = generic_file_remap_pages,
 };
 
 static int nfs_need_sync_write(struct file *filp, struct inode *inode)
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 2660152..303cbb9 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -126,13 +126,13 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
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
index 5c8f6dc..fc59462 100644
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
index 54a67dd..4381874 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -987,7 +987,6 @@ xfs_file_mmap(
 	struct vm_area_struct *vma)
 {
 	vma->vm_ops = &xfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 	file_accessed(filp);
 	return 0;
@@ -1041,4 +1040,5 @@ const struct file_operations xfs_dir_file_operations = {
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
+	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 135693e..db55afd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2356,6 +2356,8 @@ extern int sb_min_blocksize(struct super_block *, int);
 
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_remap_pages(struct vm_area_struct *, unsigned long addr,
+		unsigned long size, pgoff_t pgoff);
 extern int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size);
 int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk);
 extern ssize_t generic_file_aio_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a444f47..0dad037 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -106,7 +106,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_NODUMP	0x04000000	/* Do not include in the core dump */
 
-#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
@@ -177,8 +176,7 @@ static inline int is_pfn_mapping(struct vm_area_struct *vma)
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
  * pgoff should be used in favour of virtual_address, if possible. If pgoff
- * is used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get nonlinear
- * mapping support.
+ * is used, one may implement ->remap_pages to get nonlinear mapping support.
  */
 struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
@@ -236,6 +234,8 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
+			   unsigned long size, pgoff_t pgoff);
 };
 
 struct mmu_gather;
diff --git a/mm/filemap.c b/mm/filemap.c
index 79c4b2b..34cce46 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1753,6 +1753,7 @@ EXPORT_SYMBOL(filemap_fault);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.remap_pages	= generic_file_remap_pages,
 };
 
 /* This is used for a general mmap of a disk file */
@@ -1765,7 +1766,6 @@ int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &generic_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index a4eb311..3c38d07 100644
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
index a7bf6a3..1a23d2c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -649,8 +649,7 @@ again:			remove_next = 1 + (end > next->vm_end);
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
index f59e170..afa0a15 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1961,6 +1961,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
index f99ff3e..617621a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1112,7 +1112,6 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
@@ -2430,6 +2429,7 @@ static const struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+	.remap_pages	= generic_file_remap_pages,
 };
 
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
@@ -2623,7 +2623,6 @@ int shmem_zero_setup(struct vm_area_struct *vma)
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
