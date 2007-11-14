Message-Id: <20071114201528.363733000@chello.nl>
References: <20071114200136.009242000@chello.nl>
Date: Wed, 14 Nov 2007 21:01:38 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/3] vfs: ->mmap_prepare()
Content-Disposition: inline; filename=mmap_prepare.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Some filesystems (NFS) need i_mutex in ->mmap(), this violates the normal
locking order. Provide a hook before we take mmap_sem.

This leaves a window between ->mmap_prepare() and ->mmap(), if thats a problem
(Trond?) we could also provide ->mmap_finish() and guarantee it being called
if ->mmap_prepare() returned success.

This would allow holding state and thereby close the window.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/filesystems/Locking |   11 ++++++++++-
 Documentation/filesystems/vfs.txt |    3 +++
 include/linux/fs.h                |    1 +
 ipc/shm.c                         |   13 +++++++++++++
 mm/mmap.c                         |   12 ++++++++++++
 mm/nommu.c                        |   12 ++++++++++++
 6 files changed, 51 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -1172,6 +1172,7 @@ struct file_operations {
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
+	int (*mmap_prepare) (struct file *, unsigned long len, unsigned long prot, unsigned long flags, unsigned long pgoff);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -1035,6 +1035,12 @@ unsigned long do_mmap_pgoff(struct file 
 	struct mm_struct *mm = current->mm;
 	unsigned long ret;
 
+	if (file && file->f_op && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
 	down_write(&mm->mmap_sem);
 	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&mm->mmap_sem);
@@ -1054,6 +1060,12 @@ unsigned long do_mmap(struct file *file,
 	if ((offset + PAGE_ALIGN(len)) < offset || (offset & ~PAGE_MASK))
 		return ret;
 
+	if (file && file->f_op && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
 	down_write(&mm->mmap_sem);
 	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&mm->mmap_sem);
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -1025,6 +1025,12 @@ unsigned long do_mmap_pgoff(struct file 
 	struct mm_struct *mm = current->mm;
 	unsigned long ret;
 
+	if (file && file->f_op && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
 	down_write(&mm->mmap_sem);
 	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&mm->mmap_sem);
@@ -1044,6 +1050,12 @@ unsigned long do_mmap(struct file *file,
 	if ((offset + PAGE_ALIGN(len)) < offset || (offset & ~PAGE_MASK))
 		return ret;
 
+	if (file && file->f_op && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
 	down_write(&mm->mmap_sem);
 	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&mm->mmap_sem);
Index: linux-2.6/ipc/shm.c
===================================================================
--- linux-2.6.orig/ipc/shm.c
+++ linux-2.6/ipc/shm.c
@@ -300,6 +300,12 @@ static int shm_mmap(struct file * file, 
 	struct shm_file_data *sfd = shm_file_data(file);
 	int ret;
 
+	/*
+	 * SHM backing filesystems may not have mmap_prepare!
+	 * See so_shmat().
+	 */
+	WARN_ON(sfd->file->f_op->mmap_prepare);
+
 	ret = sfd->file->f_op->mmap(sfd->file, vma);
 	if (ret != 0)
 		return ret;
@@ -1012,6 +1018,13 @@ long do_shmat(int shmid, char __user *sh
 			goto invalid;
 	}
 		
+	/*
+	 *  The usage of ___do_mmap_locked() is needed because we must already
+	 *  hold the mmap_sem here due to find_vma_intersection vs mmap races.
+	 *
+	 *  This prohibits in SHM backing filesystems from using
+	 *  f_op->mmap_prepare().
+	 */
 	user_addr = ___do_mmap_pgoff (file, addr, size, prot, flags, 0);
 	*raddr = user_addr;
 	err = 0;
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -378,6 +378,8 @@ prototypes:
 			unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
+	int (*mmap_prepare) (struct file *, unsigned long len, unsigned long prot,
+			unsigned long flags, unsigned long pgoff);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *);
@@ -413,7 +415,8 @@ poll:			no
 ioctl:			yes	(see below)
 unlocked_ioctl:		no	(see below)
 compat_ioctl:		no
-mmap:			no
+mmap_prepare:		no	(see below)
+mmap:			no	(see below)
 open:			maybe	(see below)
 flush:			no
 release:		no
@@ -436,6 +439,12 @@ For many filesystems, it is probably saf
 semaphore.  Note some filesystems (i.e. remote ones) provide no
 protection for i_size so you will need to use the BKL.
 
+->mmap_prepare() is called on mmap(2) _before_ acquisition of the mmap_sem,
+filesystems can use this hook to prepare the file for being mapped, and can
+take i_mutex if they need to.
+
+->mmap() is called while the mmap_sem is held.
+
 ->open() locking is in-transit: big lock partially moved into the methods.
 The only exception is ->open() in the instances of file_operations that never
 end up in ->i_fop/->proc_fops, i.e. ones that belong to character devices
Index: linux-2.6/Documentation/filesystems/vfs.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/vfs.txt
+++ linux-2.6/Documentation/filesystems/vfs.txt
@@ -762,6 +762,7 @@ struct file_operations {
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
+	int (*mmap_prepare) (struct file *, unsigned long len, unsigned long prot, unsigned long flags, unsigned long pgoff);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *);
@@ -809,6 +810,8 @@ otherwise noted.
   compat_ioctl: called by the ioctl(2) system call when 32 bit system calls
  	 are used on 64 bit kernels.
 
+  mmap_prepare: called by the mmap(2) system call
+
   mmap: called by the mmap(2) system call
 
   open: called by the VFS when an inode should be opened. When the VFS

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
