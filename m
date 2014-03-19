Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 65C436B0170
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 15:07:56 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id mz13so632731bkb.17
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:55 -0700 (PDT)
Received: from mail-bk0-x233.google.com (mail-bk0-x233.google.com [2a00:1450:4008:c01::233])
        by mx.google.com with ESMTPS id x9si6583530bkn.167.2014.03.19.12.07.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 12:07:54 -0700 (PDT)
Received: by mail-bk0-f51.google.com with SMTP id 6so611154bkj.24
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:53 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH 2/6] shm: add sealing API
Date: Wed, 19 Mar 2014 20:06:47 +0100
Message-Id: <1395256011-2423-3-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, David Herrmann <dh.herrmann@gmail.com>

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
specific set of operations is blocked until this seal is removed again.
Unlike locks, seals can only be modified if you own an exclusive reference
to the file. Hence, if, and only if you hold a reference to a file, you
can be sure that no-one else can modify the seals besides you (and you can
only modify them, if you are the exclusive holder). This makes sealing
useful in situations where no trust-relationship is given.

An initial set of SEALS is introduced by this patch:
  - SHRINK: If SEAL_SHRINK is set, the file in question cannot be reduced
            in size. This currently affects only ftruncate().
  - GROW: If SEAL_GROW is set, the file in question cannot be increased
          in size. This affects ftruncate(), fallocate() and write().
  - WRITE: If SEAL_WRITE is set, no write operations (besides resizing)
           are possible. This affects fallocate(PUNCH_HOLE), mmap() and
           write().

The described use-cases can easily use these seals to provide safe use
without any trust-relationship:
  1) The graphics server can verify that a passed file-descriptor has
     SEAL_SHRINK set. This allows safe scanout, while the client is
     allowed to increase buffer size for window-resizing on-the-fly.
     Concurrent writes are explicitly allowed.
  2) Both processes can verify that SEAL_SHRINK, SEAL_GROW and SEAL_WRITE
     are set. This guarantees that neither process can modify the data
     while the other side parses it. Furthermore, it guarantees that even
     with writable FDs passed to the peer, it cannot increase the size to
     hit memory-limits of the source process (in case the file-storage is
     accounted to the source).

There is one exception to setting seals: Imagine a library makes use of
sealing. While creating a new memory object with an FD, another thread may
fork(), retaining a copy of the FD and thus also a reference. Sealing
wouldn't be possible anymore, until this process closes the FDs or
exec()s. To avoid this race initial seals can be set on non-exclusive FDs.
This is safe as both sides can, and always have to, verify that the
required set of seals is set. Once they are set, neither side can extend,
reduce or modify the set of seals as long as they have no exclusive
reference.
Note that this exception also allows keeping read-only mmaps() around
during initial sealing (mmaps() also own a reference to the file).

The new API is an extension to fcntl(), adding two new commands:
  SHMEM_GET_SEALS: Return a bitset describing the seals on the file. This
                   can be called on any FD if the underlying file supports
                   sealing.
  SHMEM_SET_SEALS: Change the seals of a given file. This requires WRITE
                   access to the file. If at least one seal is already
                   set, this also requires an exclusive reference. Note
                   that this call will fail with EPERM if there is any
                   active mapping with MAP_SHARED set.

The fcntl() handler is currently specific to shmem. There is no intention
to support this on other file-systems, that's why the bits are prefixed
with SHMEM_*. Furthermore, sealing is supported on all shmem-files.
Setting seals requires write-access, so this doesn't allow any DoS attacks
onto existing shmem users (just like mandatory locking).

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 fs/fcntl.c                 |  12 ++-
 include/linux/shmem_fs.h   |  17 ++++
 include/uapi/linux/fcntl.h |  13 +++
 mm/shmem.c                 | 200 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 236 insertions(+), 6 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index ef68665..eea0b65 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/poll.h>
 #include <asm/siginfo.h>
@@ -248,9 +249,10 @@ static int f_getowner_uids(struct file *filp, unsigned long arg)
 #endif
 
 static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
-		struct file *filp)
+		     struct fd f)
 {
 	long err = -EINVAL;
+	struct file *filp = f.file;
 
 	switch (cmd) {
 	case F_DUPFD:
@@ -326,6 +328,10 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	case F_GETPIPE_SZ:
 		err = pipe_fcntl(filp, cmd, arg);
 		break;
+	case SHMEM_SET_SEALS:
+	case SHMEM_GET_SEALS:
+		err = shmem_fcntl(f, cmd, arg);
+		break;
 	default:
 		break;
 	}
@@ -360,7 +366,7 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 
 	err = security_file_fcntl(f.file, cmd, arg);
 	if (!err)
-		err = do_fcntl(fd, cmd, arg, f.file);
+		err = do_fcntl(fd, cmd, arg, f);
 
 out1:
  	fdput(f);
@@ -397,7 +403,7 @@ SYSCALL_DEFINE3(fcntl64, unsigned int, fd, unsigned int, cmd,
 					(struct flock64 __user *) arg);
 			break;
 		default:
-			err = do_fcntl(fd, cmd, arg, f.file);
+			err = do_fcntl(fd, cmd, arg, f);
 			break;
 	}
 out1:
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 9d55438..6a3f685 100644
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
 
@@ -57,6 +59,21 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
+#ifdef CONFIG_SHMEM
+
+extern int shmem_set_seals(struct file *file, u32 seals);
+extern int shmem_get_seals(struct file *file);
+extern long shmem_fcntl(struct fd f, unsigned int cmd, unsigned long arg);
+
+#else
+
+static inline long shmem_fcntl(struct fd f, unsigned int cmd, unsigned long arg)
+{
+	return -EINVAL;
+}
+
+#endif
+
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
 {
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 074b886..8f31bef 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -28,6 +28,19 @@
 #define F_GETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 8)
 
 /*
+ * Set/Get seals
+ */
+#define SHMEM_SET_SEALS	(F_LINUX_SPECIFIC_BASE + 9)
+#define SHMEM_GET_SEALS	(F_LINUX_SPECIFIC_BASE + 10)
+
+/*
+ * Types of seals
+ */
+#define SHMEM_SEAL_SHRINK	0x0001	/* prevent file from shrinking */
+#define SHMEM_SEAL_GROW		0x0002	/* prevent file from growing */
+#define SHMEM_SEAL_WRITE	0x0004	/* prevent writes */
+
+/*
  * Types of directory notifications that may be requested.
  */
 #define DN_ACCESS	0x00000001	/* File accessed */
diff --git a/mm/shmem.c b/mm/shmem.c
index 1f18c9d..44d7f3b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -66,6 +66,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/fcntl.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -596,16 +597,23 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
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
+		if ((newsize < oldsize && (info->seals & SHMEM_SEAL_SHRINK)) ||
+		    (newsize > oldsize && (info->seals & SHMEM_SEAL_GROW)))
+			return -EPERM;
+	}
 
+	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
 		if (newsize != oldsize) {
 			i_size_write(inode, newsize);
 			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
@@ -1354,6 +1362,13 @@ out_nomem:
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct inode *inode = file_inode(file);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	/* protected by mmap_sem and owns additional file-reference */
+	if ((info->seals & SHMEM_SEAL_WRITE) && (vma->vm_flags & VM_SHARED))
+		return -EPERM;
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	return 0;
@@ -1433,7 +1448,15 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	struct inode *inode = mapping->host;
+	struct shmem_inode_info *info = SHMEM_I(inode);
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+
+	/* i_mutex is held by caller */
+	if (info->seals & SHMEM_SEAL_WRITE)
+		return -EPERM;
+	if ((info->seals & SHMEM_SEAL_GROW) && pos + len > inode->i_size)
+		return -EPERM;
+
 	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
 }
 
@@ -1802,11 +1825,171 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	return offset;
 }
 
+#define SHMEM_ALL_SEALS (SHMEM_SEAL_SHRINK | \
+			 SHMEM_SEAL_GROW | \
+			 SHMEM_SEAL_WRITE)
+
+int shmem_set_seals(struct file *file, u32 seals)
+{
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	bool has_writers, has_readers;
+	int r;
+
+	/*
+	 * SHMEM SEALING
+	 * Sealing allows multiple parties to share a shmem-file but restrict
+	 * access to a specific subset of file operations as long as more than
+	 * one party has access to the inode. This way, mutually untrusted
+	 * parties can share common memory regions with a well-defined policy.
+	 *
+	 * Seals can be set on any shmem-file, but always affect the whole
+	 * underlying inode. Once a seal is set, it may prevent some kinds of
+	 * access to the file. Currently, the following seals are defined:
+	 *   SHRINK: Prevent the file from shrinking
+	 *   GROW: Prevent the file from growing
+	 *   WRITE: Prevent write access to the file
+	 *
+	 * As we don't require any trust relationship between two parties, we
+	 * cannot allow asynchronous sealing. Instead, sealing is only allowed
+	 * if you own an exclusive reference to the shmem-file. Each FD, each
+	 * mmap and any link increase the ref-count. So as long as you have any
+	 * access to the file, you can be sure no-one (besides perhaps you) can
+	 * modify the seals.
+	 * There is one exception: Setting initial seals is allowed even if
+	 * there are multiple references to the file (but no writable mappings
+	 * may exist). Once *any* seal is set, removing or changing it requires
+	 * an exclusive reference, though.
+	 *
+	 * The combination of SHRINK and WRITE also guarantees that any mapped
+	 * region will not get destructed asynchronously. Even if at some point
+	 * revoke() is supported, the region will stay mapped (maybe only
+	 * privately) and accessible.
+	 */
+
+	if (file->f_op != &shmem_file_operations)
+		return -EBADF;
+
+	/* require write-access to modify seals */
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EPERM;
+
+	if (seals & ~(u32)SHMEM_ALL_SEALS)
+		return -EINVAL;
+
+	/*
+	 * - i_mutex prevents racing write/ftruncate/fallocate/..
+	 * - mmap_sem prevents racing mmap() calls
+	 * - i_lock prevents racing open() calls and new inode-refs
+	 */
+
+	mutex_lock(&inode->i_mutex);
+	down_read(&current->mm->mmap_sem);
+	spin_lock(&inode->i_lock);
+
+	/*
+	 * Changing seals is only allowed on exclusive references. Exception is
+	 * initial sealing, which allows other readers. We need to test for
+	 * i_mmap_writable to prevent VM_SHARED vmas on our exclusive writer.
+	 * i_writecount is not checked, as we explicitly allow writable FDs
+	 * even if sealed. It's the write-operation that is blocked, not the
+	 * writable FD itself.
+	 * Readers are tested the same way F_SETLEASE does it. One dentry,
+	 * inode and file ref combination is allowed.
+	 * Note that we actually allow 2 file-refs: One is the ref in the
+	 * file-table, the other is from the current context.
+	 * Note: for racing dup() calls see GET_SEALS
+	 */
+	has_writers = file->f_mapping->i_mmap_writable > 0;
+
+	has_readers = d_count(dentry) > 1 || atomic_read(&inode->i_count) > 1;
+	has_readers = has_readers || file_count(file) > 2;
+
+	if (has_writers || (has_readers && info->seals != 0)) {
+		r = -EPERM;
+	} else {
+		info->seals = seals;
+		r = 0;
+	}
+
+	spin_unlock(&inode->i_lock);
+	up_read(&current->mm->mmap_sem);
+	mutex_unlock(&inode->i_mutex);
+
+	return r;
+}
+EXPORT_SYMBOL(shmem_set_seals);
+
+int shmem_get_seals(struct file *file)
+{
+	struct inode *inode = file_inode(file);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	unsigned long flags;
+	int r;
+
+	if (file->f_op != &shmem_file_operations)
+		return -EBADF;
+
+	/*
+	 * Lock i_lock so we don't read seals between file_count() and setting
+	 * the seals in SET_SEALS. Racing get_file()s could end up with an
+	 * inconsistent view.
+	 */
+
+	spin_lock_irqsave(&inode->i_lock, flags);
+	r = info->seals;
+	spin_unlock_irqrestore(&inode->i_lock, flags);
+
+	return r;
+}
+EXPORT_SYMBOL(shmem_get_seals);
+
+long shmem_fcntl(struct fd f, unsigned int cmd, unsigned long arg)
+{
+	long r;
+
+	if (f.file->f_op != &shmem_file_operations)
+		return -EBADF;
+
+	switch (cmd) {
+	case SHMEM_SET_SEALS:
+		/* disallow upper 32bit */
+		if (arg >> 32)
+			return -EINVAL;
+
+		/*
+		 * shmem_set_seals() allows 2 file-refs, one of the owner and
+		 * one of the current context. Make sure we have a real
+		 * owner-ref here, otherwise the fast-path of __fdget_light
+		 * breaks the assumptions in shmem_set_seals().
+		 */
+
+		if (!(f.flags & FDPUT_FPUT))
+			get_file(f.file);
+
+		r = shmem_set_seals(f.file, arg);
+
+		if (!(f.flags & FDPUT_FPUT))
+			fput(f.file);
+		break;
+	case SHMEM_GET_SEALS:
+		r = shmem_get_seals(f.file);
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
@@ -1818,6 +2001,12 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		loff_t unmap_start = round_up(offset, PAGE_SIZE);
 		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
 
+		/* protected by i_mutex */
+		if (info->seals & SHMEM_SEAL_WRITE) {
+			error = -EPERM;
+			goto out;
+		}
+
 		if ((u64)unmap_end > (u64)unmap_start)
 			unmap_mapping_range(mapping, unmap_start,
 					    1 + unmap_end - unmap_start, 0);
@@ -1832,6 +2021,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 	if (error)
 		goto out;
 
+	if ((info->seals & SHMEM_SEAL_GROW) && offset + len > inode->i_size) {
+		error = -EPERM;
+		goto out;
+	}
+
 	start = offset >> PAGE_CACHE_SHIFT;
 	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	/* Try to avoid a swapstorm if len is impossible to satisfy */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
