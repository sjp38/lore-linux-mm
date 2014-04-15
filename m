Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C99E96B0038
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:38:56 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so9744320pdj.17
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:56 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id u6si11289741paa.462.2014.04.15.11.38.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 11:38:55 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so9875221pbb.17
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:55 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v2 1/3] shm: add sealing API
Date: Tue, 15 Apr 2014 20:38:36 +0200
Message-Id: <1397587118-1214-2-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, David Herrmann <dh.herrmann@gmail.com>

If two processes share a common memory region, they usually want some
guarantees to allow safe access. This often includes:
  - one side cannot overwrite data while the other reads it
  - one side cannot shrink the buffer while the other accesses it
  - one side cannot grow the buffer beyond previously set boundaries

If there is a trust-relationship between both parties, there is no need
for policy enforcement. However, if there's no trust relationship (eg.,
for general-purpose IPC) sharing memory-regions is highly fragile and
often not possible without local copies. Look at the following two
use-cases:
  1) A graphics client wants to share its rendering-buffer with a
     graphics-server. The memory-region is allocated by the client for
     read/write access and a second FD is passed to the server. While
     scanning out from the memory region, the server has no guarantee that
     the client doesn't shrink the buffer at any time, requiring rather
     cumbersome SIGBUS handling.
  2) A process wants to perform an RPC on another process. To avoid huge
     bandwidth consumption, zero-copy is preferred. After a message is
     assembled in-memory and a FD is passed to the remote side, both sides
     want to be sure that neither modifies this shared copy, anymore. The
     source may have put sensible data into the message without a separate
     copy and the target may want to parse the message inline, to avoid a
     local copy.

While SIGBUS handling, POSIX mandatory locking and MAP_DENYWRITE provide
ways to achieve most of this, the first one is unproportionally ugly to
use in libraries and the latter two are broken/racy or even disabled due
to denial of service attacks.

This patch introduces the concept of SEALING. If you seal a file, a
specific set of operations is blocked on that file forever.
Unlike locks, seals can only be set, never removed. Hence, once you
verified a specific set of seals is set, you're guaranteed that no-one can
perform the blocked operations on this file, anymore.

An initial set of SEALS is introduced by this patch:
  - SHRINK: If SEAL_SHRINK is set, the file in question cannot be reduced
            in size. This affects ftruncate() and open(O_TRUNC).
  - GROW: If SEAL_GROW is set, the file in question cannot be increased
          in size. This affects ftruncate(), fallocate() and write().
  - WRITE: If SEAL_WRITE is set, no write operations (besides resizing)
           are possible. This affects fallocate(PUNCH_HOLE), mmap() and
           write().
  - SEAL: If SEAL_SEAL is set, no further seals can be added to a file.
          This basically prevents the F_ADD_SEAL operation on a file and
          can be set to prevent others from adding further seals that you
          don't want.

The described use-cases can easily use these seals to provide safe use
without any trust-relationship:
  1) The graphics server can verify that a passed file-descriptor has
     SEAL_SHRINK set. This allows safe scanout, while the client is
     allowed to increase buffer size for window-resizing on-the-fly.
     Concurrent writes are explicitly allowed.
  2) For general-purpose IPC, both processes can verify that SEAL_SHRINK,
     SEAL_GROW and SEAL_WRITE are set. This guarantees that neither
     process can modify the data while the other side parses it.
     Furthermore, it guarantees that even with writable FDs passed to the
     peer, it cannot increase the size to hit memory-limits of the source
     process (in case the file-storage is accounted to the source).

The new API is an extension to fcntl(), adding two new commands:
  F_GET_SEALS: Return a bitset describing the seals on the file. This
               can be called on any FD if the underlying file supports
               sealing.
  F_ADD_SEALS: Change the seals of a given file. This requires WRITE
               access to the file and F_SEAL_SEAL may not already be set.
               Furthermore, the underlying file must support sealing and
               there may not be any existing shared mapping of that file.
               Otherwise, EBADF/EPERM is returned.
               The given seals are _added_ to the existing set of seals
               on the file. You cannot remove seals again.

The fcntl() handler is currently specific to shmem and disabled on all
files. A file needs to explicitly support sealing for this interface to
work. A separate syscall is added in a follow-up, which creates files that
support sealing. There is no intention to support this on other
file-systems. Semantics are unclear for non-volatile files and we lack any
use-case right now. Therefore, the implementation is specific to shmem.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 fs/fcntl.c                 |   5 ++
 include/linux/shmem_fs.h   |  20 ++++++
 include/uapi/linux/fcntl.h |  15 +++++
 mm/shmem.c                 | 162 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 199 insertions(+), 3 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 9ead159..1a7a722 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/poll.h>
 #include <asm/siginfo.h>
@@ -336,6 +337,10 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	case F_GETPIPE_SZ:
 		err = pipe_fcntl(filp, cmd, arg);
 		break;
+	case F_ADD_SEALS:
+	case F_GET_SEALS:
+		err = shmem_fcntl(filp, cmd, arg);
+		break;
 	default:
 		break;
 	}
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d1771c..c043d67 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -1,6 +1,7 @@
 #ifndef __SHMEM_FS_H
 #define __SHMEM_FS_H
 
+#include <linux/file.h>
 #include <linux/swap.h>
 #include <linux/mempolicy.h>
 #include <linux/pagemap.h>
@@ -20,6 +21,7 @@ struct shmem_inode_info {
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
+	u32			seals;		/* shmem seals */
 	struct inode		vfs_inode;
 };
 
@@ -65,4 +67,22 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+/* marks inode to support sealing */
+#define SHMEM_ALLOW_SEALING (1U << 31)
+
+#ifdef CONFIG_SHMEM
+
+extern int shmem_add_seals(struct file *file, u32 seals);
+extern int shmem_get_seals(struct file *file);
+extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
+
+#else
+
+static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
+{
+	return -EINVAL;
+}
+
+#endif
+
 #endif
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 074b886..1b9b9f4 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -28,6 +28,21 @@
 #define F_GETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 8)
 
 /*
+ * Set/Get seals
+ */
+#define F_ADD_SEALS	(F_LINUX_SPECIFIC_BASE + 9)
+#define F_GET_SEALS	(F_LINUX_SPECIFIC_BASE + 10)
+
+/*
+ * Types of seals
+ */
+#define F_SEAL_SEAL	0x0001	/* prevent further seals from being set */
+#define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
+#define F_SEAL_GROW	0x0004	/* prevent file from growing */
+#define F_SEAL_WRITE	0x0008	/* prevent writes */
+/* (1U << 31) is reserved for internal use */
+
+/*
  * Types of directory notifications that may be requested.
  */
 #define DN_ACCESS	0x00000001	/* File accessed */
diff --git a/mm/shmem.c b/mm/shmem.c
index 9f70e02..175a5b8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -66,6 +66,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/fcntl.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -531,16 +532,23 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
 static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	loff_t oldsize = inode->i_size;
+	loff_t newsize = attr->ia_size;
 	int error;
 
 	error = inode_change_ok(inode, attr);
 	if (error)
 		return error;
 
-	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
-		loff_t oldsize = inode->i_size;
-		loff_t newsize = attr->ia_size;
+	/* protected by i_mutex */
+	if (attr->ia_valid & ATTR_SIZE) {
+		if ((newsize < oldsize && (info->seals & F_SEAL_SHRINK)) ||
+		    (newsize > oldsize && (info->seals & F_SEAL_GROW)))
+			return -EPERM;
+	}
 
+	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
 		if (newsize != oldsize) {
 			i_size_write(inode, newsize);
 			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
@@ -1289,6 +1297,13 @@ out_nomem:
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct inode *inode = file_inode(file);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	/* protected by mmap_sem */
+	if ((info->seals & F_SEAL_WRITE) && (vma->vm_flags & VM_SHARED))
+		return -EPERM;
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	return 0;
@@ -1373,7 +1388,15 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	struct inode *inode = mapping->host;
+	struct shmem_inode_info *info = SHMEM_I(inode);
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+
+	/* i_mutex is held by caller */
+	if (info->seals & F_SEAL_WRITE)
+		return -EPERM;
+	if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
+		return -EPERM;
+
 	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
 }
 
@@ -1719,11 +1742,133 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	return offset;
 }
 
+#define F_ALL_SEALS (F_SEAL_SEAL | \
+		     F_SEAL_SHRINK | \
+		     F_SEAL_GROW | \
+		     F_SEAL_WRITE)
+
+int shmem_add_seals(struct file *file, u32 seals)
+{
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	int r;
+
+	/* SHMEM_ALLOW_SEALING is a private, unused bit */
+	BUILD_BUG_ON(F_ALL_SEALS & SHMEM_ALLOW_SEALING);
+
+	/*
+	 * SEALING
+	 * Sealing allows multiple parties to share a shmem-file but restrict
+	 * access to a specific subset of file operations. Seals can only be
+	 * added, but never removed. This way, mutually untrusted parties can
+	 * share common memory regions with a well-defined policy. A malicious
+	 * peer can thus never perform unwanted operations on a shared object.
+	 *
+	 * Seals are only supported on special shmem-files and always affect
+	 * the whole underlying inode. Once a seal is set, it may prevent some
+	 * kinds of access to the file. Currently, the following seals are
+	 * defined:
+	 *   SEAL_SEAL: Prevent further seals from being set on this file
+	 *   SEAL_SHRINK: Prevent the file from shrinking
+	 *   SEAL_GROW: Prevent the file from growing
+	 *   SEAL_WRITE: Prevent write access to the file
+	 *
+	 * As we don't require any trust relationship between two parties, we
+	 * must prevent seals from being removed. Therefore, sealing a file
+	 * only adds a given set of seals to the file, it never touches
+	 * existing seals. Furthermore, the "setting seals"-operation can be
+	 * sealed itself, which basically prevents any further seal from being
+	 * added.
+	 *
+	 * Semantics of sealing are only defined on volatile files. Only
+	 * anonymous shmem files support sealing. More importantly, seals are
+	 * never written to disk. Therefore, there's no plan to support it on
+	 * other file types.
+	 */
+
+	if (file->f_op != &shmem_file_operations)
+		return -EBADF;
+	if (!(info->seals & SHMEM_ALLOW_SEALING))
+		return -EBADF;
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EPERM;
+	if (seals & ~(u32)F_ALL_SEALS)
+		return -EINVAL;
+
+	/*
+	 * - i_mutex prevents racing write/ftruncate/fallocate/..
+	 * - mmap_sem prevents racing mmap() calls
+	 */
+
+	mutex_lock(&inode->i_mutex);
+	down_read(&current->mm->mmap_sem);
+
+	/* you cannot seal while shared mappings exist */
+	if (file->f_mapping->i_mmap_writable > 0) {
+		r = -EPERM;
+		goto unlock;
+	}
+
+	if (info->seals & F_SEAL_SEAL) {
+		r = -EPERM;
+		goto unlock;
+	}
+
+	info->seals |= seals;
+	r = 0;
+
+unlock:
+	up_read(&current->mm->mmap_sem);
+	mutex_unlock(&inode->i_mutex);
+	return r;
+}
+EXPORT_SYMBOL(shmem_add_seals);
+
+int shmem_get_seals(struct file *file)
+{
+	struct shmem_inode_info *info;
+
+	if (file->f_op != &shmem_file_operations)
+		return -EBADF;
+
+	info = SHMEM_I(file_inode(file));
+	if (!(info->seals & SHMEM_ALLOW_SEALING))
+		return -EBADF;
+
+	return info->seals & F_ALL_SEALS;
+}
+EXPORT_SYMBOL(shmem_get_seals);
+
+long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	long r;
+
+	switch (cmd) {
+	case F_ADD_SEALS:
+		/* disallow upper 32bit */
+		if (arg >> 32)
+			return -EINVAL;
+
+		r = shmem_add_seals(file, arg);
+		break;
+	case F_GET_SEALS:
+		r = shmem_get_seals(file);
+		break;
+	default:
+		r = -EINVAL;
+		break;
+	}
+
+	return r;
+}
+
 static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 							 loff_t len)
 {
 	struct inode *inode = file_inode(file);
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_falloc shmem_falloc;
 	pgoff_t start, index, end;
 	int error;
@@ -1735,6 +1880,12 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		loff_t unmap_start = round_up(offset, PAGE_SIZE);
 		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
 
+		/* protected by i_mutex */
+		if (info->seals & F_SEAL_WRITE) {
+			error = -EPERM;
+			goto out;
+		}
+
 		if ((u64)unmap_end > (u64)unmap_start)
 			unmap_mapping_range(mapping, unmap_start,
 					    1 + unmap_end - unmap_start, 0);
@@ -1749,6 +1900,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 	if (error)
 		goto out;
 
+	if ((info->seals & F_SEAL_GROW) && offset + len > inode->i_size) {
+		error = -EPERM;
+		goto out;
+	}
+
 	start = offset >> PAGE_CACHE_SHIFT;
 	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	/* Try to avoid a swapstorm if len is impossible to satisfy */
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
