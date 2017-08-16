Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25FBD6B02FD
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:50:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r62so6671186pfj.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:50:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b27si155013pfk.505.2017.08.16.00.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 00:50:47 -0700 (PDT)
Subject: [PATCH v5 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Aug 2017 00:44:22 -0700
Message-ID: <150286946261.8837.1454297295346610351.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org

The mmap(2) syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
mechanism to define new behavior that is known to fail on older kernels
without the support. Define a new mmap3 syscall that checks for
unsupported flags at syscall entry and add a 'mmap_supported_mask' to
'struct file_operations' so generic code can validate the ->mmap()
handler knows about the specified flags. This also arranges for the
flags to be passed to the handler so it can do further local validation
if the requested behavior can be fulfilled.

Cc: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 include/linux/fs.h                     |    3 ++-
 include/linux/mm.h                     |    2 +-
 include/linux/mman.h                   |   34 ++++++++++++++++++++++++++++++++
 include/linux/syscalls.h               |    3 +++
 mm/mmap.c                              |   32 +++++++++++++++++++++++++++---
 7 files changed, 71 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 448ac2161112..0618b5b38b45 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -391,3 +391,4 @@
 382	i386	pkey_free		sys_pkey_free
 383	i386	statx			sys_statx
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
+385	i386	mmap3			sys_mmap_pgoff_strict
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 5aef183e2f85..e204c736d7e9 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -339,6 +339,7 @@
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
 332	common	statx			sys_statx
+333	common  mmap3			sys_mmap_pgoff_strict
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 405976022752..db42da9f98c4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1674,6 +1674,7 @@ struct file_operations {
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *, unsigned long);
+	unsigned long mmap_supported_mask;
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
@@ -1746,7 +1747,7 @@ static inline ssize_t call_write_iter(struct file *file, struct kiocb *kio,
 static inline int call_mmap(struct file *file, struct vm_area_struct *vma,
 			    unsigned long flags)
 {
-	return file->f_op->mmap(file, vma, 0);
+	return file->f_op->mmap(file, vma, flags);
 }
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..49eef48da4b7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2090,7 +2090,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-	struct list_head *uf);
+	struct list_head *uf, unsigned long flags);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
diff --git a/include/linux/mman.h b/include/linux/mman.h
index c8367041fafd..0e1de42c836f 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -7,6 +7,40 @@
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
 
+#ifndef MAP_32BIT
+#define MAP_32BIT 0
+#endif
+#ifndef MAP_HUGE_2MB
+#define MAP_HUGE_2MB 0
+#endif
+#ifndef MAP_HUGE_1GB
+#define MAP_HUGE_1GB 0
+#endif
+
+/*
+ * The historical set of flags that all mmap implementations implicitly
+ * support when file_operations.mmap_supported_mask is zero.
+ */
+#define LEGACY_MAP_SUPPORTED_MASK (MAP_SHARED \
+		| MAP_PRIVATE \
+		| MAP_FIXED \
+		| MAP_ANONYMOUS \
+		| MAP_UNINITIALIZED \
+		| MAP_GROWSDOWN \
+		| MAP_DENYWRITE \
+		| MAP_EXECUTABLE \
+		| MAP_LOCKED \
+		| MAP_NORESERVE \
+		| MAP_POPULATE \
+		| MAP_NONBLOCK \
+		| MAP_STACK \
+		| MAP_HUGETLB \
+		| MAP_32BIT \
+		| MAP_HUGE_2MB \
+		| MAP_HUGE_1GB)
+
+#define	MAP_SUPPORTED_MASK (LEGACY_MAP_SUPPORTED_MASK)
+
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3cb15ea48aee..c0e0c99cf4ad 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -858,6 +858,9 @@ asmlinkage long sys_perf_event_open(
 asmlinkage long sys_mmap_pgoff(unsigned long addr, unsigned long len,
 			unsigned long prot, unsigned long flags,
 			unsigned long fd, unsigned long pgoff);
+asmlinkage long sys_mmap_pgoff_strict(unsigned long addr, unsigned long len,
+			unsigned long prot, unsigned long flags,
+			unsigned long fd, unsigned long pgoff);
 asmlinkage long sys_old_mmap(struct mmap_arg_struct __user *arg);
 asmlinkage long sys_name_to_handle_at(int dfd, const char __user *name,
 				      struct file_handle __user *handle,
diff --git a/mm/mmap.c b/mm/mmap.c
index 744faae86781..386706831d67 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1464,7 +1464,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1521,6 +1521,32 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	return retval;
 }
 
+SYSCALL_DEFINE6(mmap_pgoff_strict, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	if (flags & ~(MAP_SUPPORTED_MASK))
+		return -EOPNOTSUPP;
+
+	if (!(flags & MAP_ANONYMOUS)) {
+		unsigned long f_supported;
+		struct file *file;
+
+		audit_mmap_fd(fd, flags);
+		file = fget(fd);
+		if (!file)
+			return -EBADF;
+		f_supported = file->f_op->mmap_supported_mask;
+		fput(file);
+		if (!f_supported)
+			f_supported = LEGACY_MAP_SUPPORTED_MASK;
+		if (flags & ~f_supported)
+			return -EOPNOTSUPP;
+	}
+
+	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+}
+
 #ifdef __ARCH_WANT_SYS_OLD_MMAP
 struct mmap_arg_struct {
 	unsigned long addr;
@@ -1601,7 +1627,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		struct list_head *uf, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1686,7 +1712,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * new file must not have been exposed to user-space, yet.
 		 */
 		vma->vm_file = get_file(file);
-		error = call_mmap(file, vma, 0);
+		error = call_mmap(file, vma, flags);
 		if (error)
 			goto unmap_and_free_vma;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
