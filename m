Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB4736B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 20:53:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so1419013pfk.0
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:53:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e9si11748057pli.519.2017.10.11.17.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 17:53:38 -0700 (PDT)
Subject: [PATCH v9 1/6] mm: introduce MAP_SHARED_VALIDATE,
 a mechanism to safely define new mmap flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 17:47:13 -0700
Message-ID: <150776923320.9144.6119113178052262946.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-api@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

The mmap(2) syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
mechanism to define new behavior that is known to fail on older kernels
without the support. Define a new MAP_SHARED_VALIDATE flag pattern that
is guaranteed to fail on all legacy mmap implementations.

It is worth noting that the original proposal was for a standalone
MAP_VALIDATE flag. However, when that  could not be supported by all
archs Linus observed:

    I see why you *think* you want a bitmap. You think you want
    a bitmap because you want to make MAP_VALIDATE be part of MAP_SYNC
    etc, so that people can do

    ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED
		    | MAP_SYNC, fd, 0);

    and "know" that MAP_SYNC actually takes.

    And I'm saying that whole wish is bogus. You're fundamentally
    depending on special semantics, just make it explicit. It's already
    not portable, so don't try to make it so.

    Rename that MAP_VALIDATE as MAP_SHARED_VALIDATE, make it have a value
    of 0x3, and make people do

    ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED_VALIDATE
		    | MAP_SYNC, fd, 0);

    and then the kernel side is easier too (none of that random garbage
    playing games with looking at the "MAP_VALIDATE bit", but just another
    case statement in that map type thing.

    Boom. Done.

Similar to ->fallocate() we also want the ability to validate the
support for new flags on a per ->mmap() 'struct file_operations'
instance basis.  Towards that end arrange for flags to be generically
validated against a mmap_supported_mask exported by 'struct
file_operations'. By default all existing flags are implicitly
supported, but new flags require MAP_SHARED_VALIDATE and
per-instance-opt-in.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Christoph Hellwig <hch@lst.de>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/alpha/include/uapi/asm/mman.h           |    1 +
 arch/mips/include/uapi/asm/mman.h            |    1 +
 arch/mips/kernel/vdso.c                      |    2 +
 arch/parisc/include/uapi/asm/mman.h          |    1 +
 arch/tile/mm/elf.c                           |    3 +-
 arch/xtensa/include/uapi/asm/mman.h          |    1 +
 include/linux/fs.h                           |    2 +
 include/linux/mm.h                           |    2 +
 include/linux/mman.h                         |   39 ++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h       |    1 +
 mm/mmap.c                                    |   21 ++++++++++++--
 tools/include/uapi/asm-generic/mman-common.h |    1 +
 12 files changed, 69 insertions(+), 6 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 3b26cc62dadb..f85f18ffbf8c 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -11,6 +11,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping (OSF/1 is _wrong_) */
 #define MAP_FIXED	0x100		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index da3216007fe0..054314bb062a 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -28,6 +28,7 @@
  */
 #define MAP_SHARED	0x001		/* Share changes */
 #define MAP_PRIVATE	0x002		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
 
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 019035d7225c..cf10654477a9 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -110,7 +110,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
 			   VM_READ|VM_WRITE|VM_EXEC|
 			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-			   0, NULL);
+			   0, NULL, 0);
 	if (IS_ERR_VALUE(base)) {
 		ret = base;
 		goto out;
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 775b5d5e41a1..a66fdb9c4b6d 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -11,6 +11,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x03		/* Mask for type of mapping */
 #define MAP_FIXED	0x04		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 889901824400..5ffcbe76aef9 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -143,7 +143,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 		unsigned long addr = MEM_USER_INTRPT;
 		addr = mmap_region(NULL, addr, INTRPT_SIZE,
 				   VM_READ|VM_EXEC|
-				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0, NULL);
+				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0,
+				   NULL, 0);
 		if (addr > (unsigned long) -PAGE_SIZE)
 			retval = (int) addr;
 	}
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index b15b278aa314..875b0e6f7499 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -35,6 +35,7 @@
  */
 #define MAP_SHARED	0x001		/* Share changes */
 #define MAP_PRIVATE	0x002		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 13dab191a23e..5aee97d64cae 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1701,6 +1701,8 @@ struct file_operations {
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*mmap_validate) (struct file *, struct vm_area_struct *,
+			unsigned long);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065d99deb847..38f6ed954dde 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2133,7 +2133,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-	struct list_head *uf);
+	struct list_head *uf, unsigned long map_flags);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
diff --git a/include/linux/mman.h b/include/linux/mman.h
index c8367041fafd..94b63b4d71ff 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -7,6 +7,45 @@
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
 
+/*
+ * Arrange for legacy / undefined architecture specific flags to be
+ * ignored by default in LEGACY_MAP_MASK.
+ */
+#ifndef MAP_32BIT
+#define MAP_32BIT 0
+#endif
+#ifndef MAP_HUGE_2MB
+#define MAP_HUGE_2MB 0
+#endif
+#ifndef MAP_HUGE_1GB
+#define MAP_HUGE_1GB 0
+#endif
+#ifndef MAP_UNINITIALIZED
+#define MAP_UNINITIALIZED 0
+#endif
+
+/*
+ * The historical set of flags that all mmap implementations implicitly
+ * support when a ->mmap_validate() op is not provided in file_operations.
+ */
+#define LEGACY_MAP_MASK (MAP_SHARED \
+		| MAP_PRIVATE \
+		| MAP_FIXED \
+		| MAP_ANONYMOUS \
+		| MAP_DENYWRITE \
+		| MAP_EXECUTABLE \
+		| MAP_UNINITIALIZED \
+		| MAP_GROWSDOWN \
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
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 203268f9231e..debd98c2eb83 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -16,6 +16,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506faceae..2649c00581a0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1389,6 +1389,18 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		struct inode *inode = file_inode(file);
 
 		switch (flags & MAP_TYPE) {
+		case MAP_SHARED_VALIDATE:
+			if ((flags & ~LEGACY_MAP_MASK) == 0) {
+				/*
+				 * If all legacy mmap flags, downgrade
+				 * to MAP_SHARED, i.e. invoke ->mmap()
+				 * instead of ->mmap_validate()
+				 */
+				flags &= ~MAP_TYPE;
+				flags |= MAP_SHARED;
+			} else if (!file->f_op->mmap_validate)
+				return -EOPNOTSUPP;
+			/* fall through */
 		case MAP_SHARED:
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
 				return -EACCES;
@@ -1465,7 +1477,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1602,7 +1614,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		struct list_head *uf, unsigned long map_flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1687,7 +1699,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * new file must not have been exposed to user-space, yet.
 		 */
 		vma->vm_file = get_file(file);
-		error = call_mmap(file, vma);
+		if ((map_flags & MAP_TYPE) == MAP_SHARED_VALIDATE)
+			error = file->f_op->mmap_validate(file, vma, map_flags);
+		else
+			error = call_mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
 
diff --git a/tools/include/uapi/asm-generic/mman-common.h b/tools/include/uapi/asm-generic/mman-common.h
index 203268f9231e..debd98c2eb83 100644
--- a/tools/include/uapi/asm-generic/mman-common.h
+++ b/tools/include/uapi/asm-generic/mman-common.h
@@ -16,6 +16,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x3		/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
