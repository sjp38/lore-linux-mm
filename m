Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A075F6B02F4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:15:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so13709432pfj.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:15:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y7si5462323pgr.181.2017.08.30.16.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:14:58 -0700 (PDT)
Subject: [PATCH 2/2] mm: introduce MAP_VALIDATE,
 a mechanism for for safely defining new mmap flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Aug 2017 16:08:26 -0700
Message-ID: <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: jack@suse.cz, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@lst.de

The mmap(2) syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
mechanism to define new behavior that is known to fail on older kernels
without the support. Define a new MAP_VALIDATE flag pattern that is
guaranteed to fail on all legacy mmap implementations.

With this in place new flags can be defined as:

    #define MAP_new (MAP_VALIDATE | val)

MAP_VALIDATE depends on Christoph's observation that the legacy mmap
path does:

    include/uapi/asm-generic/mman-common.h:

        #define MAP_SHARED      0x01            /* Share changes */
        #define MAP_PRIVATE     0x02            /* Changes are private */
        #define MAP_TYPE        0x0f            /* Mask for type of mapping */

     mm/mmap.c:

        switch (flags & MAP_TYPE) {
        case MAP_SHARED:
                ...
        case MAP_PRIVATE:
                ...
        default:
                return -EINVAL;
        }

Where any value in the MAP_TYPE mask outside of MAP_{SHARED|PRIVATE} is
explicitly failed. However, the ability to specify MAP_VALIDATE as a
flag distinct from MAP_{SHARED|PRIVATE}, but still in the MAP_TYPE mask
fails on parisc where MAP_TYPE is defined as 0x3. For parisc to support
new mmap flags it will need a new syscall and libc infrastructure to
opt-in to a new flag handling scheme. In the meantime, internal to the
kernel, we can default MAP_VALIDATE and any new flags to be equal to
MAP_TYPE to force them to be invalid.

Similar to ->fallocate() we also want the ability to validate the
support for new flags on a per ->mmap() 'struct file_operations'
instance basis.  Towards that end arrange for flags to be generically
validated against a mmap_supported_mask exported by 'struct
file_operations'. By default all existing flags are implicitly
supported, but new flags require per-instance-opt-in.

Cc: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h                     |    1 +
 include/linux/mm.h                     |    2 +
 include/linux/mman.h                   |   50 ++++++++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h |    1 +
 mm/mmap.c                              |   22 ++++++++++++--
 5 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 47249bbe973c..c3653283d9de 100644
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
index c8367041fafd..289051f6ab1e 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -7,6 +7,56 @@
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
+ * If the architecture does not define MAP_VALIDATE, default it to a
+ * known invalid pattern that do_mmap() will reject.
+ */
+#ifndef MAP_VALIDATE
+#define MAP_VALIDATE MAP_TYPE
+#endif
+
+/*
+ * The historical set of flags that all mmap implementations implicitly
+ * support when file_operations.mmap_supported_mask is zero. With the
+ * mmap3 syscall the deprecated MAP_DENYWRITE and MAP_EXECUTABLE bit
+ * values are explicitly rejected with EOPNOTSUPP rather than being
+ * silently accepted.
+ */
+#define LEGACY_MAP_MASK (MAP_SHARED \
+		| MAP_PRIVATE \
+		| MAP_FIXED \
+		| MAP_ANONYMOUS \
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
+#define	MAP_SUPPORTED_MASK (LEGACY_MAP_MASK)
+
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0c5c08..a7697c18a91c 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -16,6 +16,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_VALIDATE	0x04		/* Validate flags beyond LEGACY_MAP_MASK */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 744faae86781..6936bb39e04a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1387,7 +1387,23 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	if (file) {
 		struct inode *inode = file_inode(file);
 
+		if ((flags & MAP_VALIDATE) == MAP_TYPE)
+			return -EINVAL;
+
+		if (flags & MAP_VALIDATE) {
+			unsigned long f_supported;
+
+			f_supported = file->f_op->mmap_supported_mask;
+			if (!f_supported)
+				f_supported = LEGACY_MAP_MASK;
+			if (flags & ~(f_supported | MAP_VALIDATE))
+				return -EOPNOTSUPP;
+		}
+
 		switch (flags & MAP_TYPE) {
+		case (MAP_SHARED|MAP_VALIDATE):
+			/* TODO: new map flags */
+			return -EINVAL;
 		case MAP_SHARED:
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
 				return -EACCES;
@@ -1464,7 +1480,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1601,7 +1617,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		struct list_head *uf, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1686,7 +1702,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
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
