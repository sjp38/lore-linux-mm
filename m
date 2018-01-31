Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC7D6B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:34:14 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n205so6238qkn.15
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:34:14 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v8si1180847qtg.435.2018.01.30.18.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 18:34:12 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 2/3] mm: memfd: split out memfd for use by multiple filesystems
Date: Tue, 30 Jan 2018 18:29:10 -0800
Message-Id: <20180131022911.23947-3-mike.kravetz@oracle.com>
In-Reply-To: <20180131022911.23947-1-mike.kravetz@oracle.com>
References: <20180131022911.23947-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When memfd_create support was originally written, it only provided
support for tmpfs.  Hence, the code was added to files providing
tmpfs functionality and build when CONFIG_TMPFS was enabled.

memfd support has recently been added for hugetlbfs.  In an effort
to make it depend on tmpfs -or- hugetlbfs, split out the required
memfd code to separate files.

While moving code, fixed sparse warnings that existed in the
original code to keep kbuild test robot happy.

These files are not used until a subsequent patch which deletes
duplicate code in the orifinal files and enables their use.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/memfd.h |  16 +++
 mm/memfd.c            | 342 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 358 insertions(+)
 create mode 100644 include/linux/memfd.h
 create mode 100644 mm/memfd.c

diff --git a/include/linux/memfd.h b/include/linux/memfd.h
new file mode 100644
index 000000000000..4f1600413f91
--- /dev/null
+++ b/include/linux/memfd.h
@@ -0,0 +1,16 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __LINUX_MEMFD_H
+#define __LINUX_MEMFD_H
+
+#include <linux/file.h>
+
+#ifdef CONFIG_MEMFD_CREATE
+extern long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
+#else
+static inline long memfd_fcntl(struct file *f, unsigned int c, unsigned long a)
+{
+	return -EINVAL;
+}
+#endif
+
+#endif /* __LINUX_MEMFD_H */
diff --git a/mm/memfd.c b/mm/memfd.c
new file mode 100644
index 000000000000..c913fbfa094a
--- /dev/null
+++ b/mm/memfd.c
@@ -0,0 +1,342 @@
+/*
+ * memfd_create system call and file sealing support
+ *
+ * Code was originally included in shmem.c, and broken out to facilitate
+ * use by hugetlbfs as well as tmpfs.
+ *
+ * This file is released under the GPL.
+ */
+
+#include <linux/fs.h>
+#include <linux/vfs.h>
+#include <linux/pagemap.h>
+#include <linux/file.h>
+#include <linux/mm.h>
+#include <linux/sched/signal.h>
+#include <linux/khugepaged.h>
+#include <linux/syscalls.h>
+#include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
+#include <linux/memfd.h>
+#include <uapi/linux/memfd.h>
+
+/*
+ * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
+ * so reuse a tag which we firmly believe is never set or cleared on shmem.
+ */
+#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
+#define LAST_SCAN               4       /* about 150ms max */
+
+static void shmem_tag_pins(struct address_space *mapping)
+{
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	pgoff_t start;
+	struct page *page;
+
+	lru_add_drain();
+	start = 0;
+	rcu_read_lock();
+
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		page = radix_tree_deref_slot(slot);
+		if (!page || radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
+		} else if (page_count(page) - page_mapcount(page) > 1) {
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_set(&mapping->page_tree, iter.index,
+					   SHMEM_TAG_PINNED);
+			spin_unlock_irq(&mapping->tree_lock);
+		}
+
+		if (need_resched()) {
+			slot = radix_tree_iter_resume(slot, &iter);
+			cond_resched_rcu();
+		}
+	}
+	rcu_read_unlock();
+}
+
+/*
+ * Setting SEAL_WRITE requires us to verify there's no pending writer. However,
+ * via get_user_pages(), drivers might have some pending I/O without any active
+ * user-space mappings (eg., direct-IO, AIO). Therefore, we look at all pages
+ * and see whether it has an elevated ref-count. If so, we tag them and wait for
+ * them to be dropped.
+ * The caller must guarantee that no new user will acquire writable references
+ * to those pages to avoid races.
+ */
+static int shmem_wait_for_pins(struct address_space *mapping)
+{
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	pgoff_t start;
+	struct page *page;
+	int error, scan;
+
+	shmem_tag_pins(mapping);
+
+	error = 0;
+	for (scan = 0; scan <= LAST_SCAN; scan++) {
+		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
+			break;
+
+		if (!scan)
+			lru_add_drain_all();
+		else if (schedule_timeout_killable((HZ << scan) / 200))
+			scan = LAST_SCAN;
+
+		start = 0;
+		rcu_read_lock();
+		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
+					   start, SHMEM_TAG_PINNED) {
+
+			page = radix_tree_deref_slot(slot);
+			if (radix_tree_exception(page)) {
+				if (radix_tree_deref_retry(page)) {
+					slot = radix_tree_iter_retry(&iter);
+					continue;
+				}
+
+				page = NULL;
+			}
+
+			if (page &&
+			    page_count(page) - page_mapcount(page) != 1) {
+				if (scan < LAST_SCAN)
+					goto continue_resched;
+
+				/*
+				 * On the last scan, we clean up all those tags
+				 * we inserted; but make a note that we still
+				 * found pages pinned.
+				 */
+				error = -EBUSY;
+			}
+
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_clear(&mapping->page_tree,
+					     iter.index, SHMEM_TAG_PINNED);
+			spin_unlock_irq(&mapping->tree_lock);
+continue_resched:
+			if (need_resched()) {
+				slot = radix_tree_iter_resume(slot, &iter);
+				cond_resched_rcu();
+			}
+		}
+		rcu_read_unlock();
+	}
+
+	return error;
+}
+
+static unsigned int *memfd_file_seals_ptr(struct file *file)
+{
+	if (shmem_file(file))
+		return &SHMEM_I(file_inode(file))->seals;
+
+	if (is_file_hugepages(file))
+		return &HUGETLBFS_I(file_inode(file))->seals;
+
+	return NULL;
+}
+
+#define F_ALL_SEALS (F_SEAL_SEAL | \
+		     F_SEAL_SHRINK | \
+		     F_SEAL_GROW | \
+		     F_SEAL_WRITE)
+
+static int memfd_add_seals(struct file *file, unsigned int seals)
+{
+	struct inode *inode = file_inode(file);
+	unsigned int *file_seals;
+	int error;
+
+	/*
+	 * SEALING
+	 * Sealing allows multiple parties to share a tmpfs or hugetlbfs file
+	 * but restrict access to a specific subset of file operations. Seals
+	 * can only be added, but never removed. This way, mutually untrusted
+	 * parties can share common memory regions with a well-defined policy.
+	 * A malicious peer can thus never perform unwanted operations on a
+	 * shared object.
+	 *
+	 * Seals are only supported on special tmpfs or hugetlbfs files and
+	 * always affect the whole underlying inode. Once a seal is set, it
+	 * may prevent some kinds of access to the file. Currently, the
+	 * following seals are defined:
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
+	 * anonymous tmpfs and hugetlbfs files support sealing. More
+	 * importantly, seals are never written to disk. Therefore, there's
+	 * no plan to support it on other file types.
+	 */
+
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EPERM;
+	if (seals & ~(unsigned int)F_ALL_SEALS)
+		return -EINVAL;
+
+	inode_lock(inode);
+
+	file_seals = memfd_file_seals_ptr(file);
+	if (!file_seals) {
+		error = -EINVAL;
+		goto unlock;
+	}
+
+	if (*file_seals & F_SEAL_SEAL) {
+		error = -EPERM;
+		goto unlock;
+	}
+
+	if ((seals & F_SEAL_WRITE) && !(*file_seals & F_SEAL_WRITE)) {
+		error = mapping_deny_writable(file->f_mapping);
+		if (error)
+			goto unlock;
+
+		error = shmem_wait_for_pins(file->f_mapping);
+		if (error) {
+			mapping_allow_writable(file->f_mapping);
+			goto unlock;
+		}
+	}
+
+	*file_seals |= seals;
+	error = 0;
+
+unlock:
+	inode_unlock(inode);
+	return error;
+}
+
+static int memfd_get_seals(struct file *file)
+{
+	unsigned int *seals = memfd_file_seals_ptr(file);
+
+	return seals ? *seals : -EINVAL;
+}
+
+long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	long error;
+
+	switch (cmd) {
+	case F_ADD_SEALS:
+		/* disallow upper 32bit */
+		if (arg > UINT_MAX)
+			return -EINVAL;
+
+		error = memfd_add_seals(file, arg);
+		break;
+	case F_GET_SEALS:
+		error = memfd_get_seals(file);
+		break;
+	default:
+		error = -EINVAL;
+		break;
+	}
+
+	return error;
+}
+
+#define MFD_NAME_PREFIX "memfd:"
+#define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
+#define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
+
+#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING | MFD_HUGETLB)
+
+SYSCALL_DEFINE2(memfd_create,
+		const char __user *, uname,
+		unsigned int, flags)
+{
+	unsigned int *file_seals;
+	struct file *file;
+	int fd, error;
+	char *name;
+	long len;
+
+	if (!(flags & MFD_HUGETLB)) {
+		if (flags & ~(unsigned int)MFD_ALL_FLAGS)
+			return -EINVAL;
+	} else {
+		/* Allow huge page size encoding in flags. */
+		if (flags & ~(unsigned int)(MFD_ALL_FLAGS |
+				(MFD_HUGE_MASK << MFD_HUGE_SHIFT)))
+			return -EINVAL;
+	}
+
+	/* length includes terminating zero */
+	len = strnlen_user(uname, MFD_NAME_MAX_LEN + 1);
+	if (len <= 0)
+		return -EFAULT;
+	if (len > MFD_NAME_MAX_LEN + 1)
+		return -EINVAL;
+
+	name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	strcpy(name, MFD_NAME_PREFIX);
+	if (copy_from_user(&name[MFD_NAME_PREFIX_LEN], uname, len)) {
+		error = -EFAULT;
+		goto err_name;
+	}
+
+	/* terminating-zero may have changed after strnlen_user() returned */
+	if (name[len + MFD_NAME_PREFIX_LEN - 1]) {
+		error = -EFAULT;
+		goto err_name;
+	}
+
+	fd = get_unused_fd_flags((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0);
+	if (fd < 0) {
+		error = fd;
+		goto err_name;
+	}
+
+	if (flags & MFD_HUGETLB) {
+		struct user_struct *user = NULL;
+
+		file = hugetlb_file_setup(name, 0, VM_NORESERVE, &user,
+					HUGETLB_ANONHUGE_INODE,
+					(flags >> MFD_HUGE_SHIFT) &
+					MFD_HUGE_MASK);
+	} else
+		file = shmem_file_setup(name, 0, VM_NORESERVE);
+	if (IS_ERR(file)) {
+		error = PTR_ERR(file);
+		goto err_fd;
+	}
+	file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
+	file->f_flags |= O_RDWR | O_LARGEFILE;
+
+	if (flags & MFD_ALLOW_SEALING) {
+		file_seals = memfd_file_seals_ptr(file);
+		*file_seals &= ~F_SEAL_SEAL;
+	}
+
+	fd_install(fd, file);
+	kfree(name);
+	return fd;
+
+err_fd:
+	put_unused_fd(fd);
+err_name:
+	kfree(name);
+	return error;
+}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
