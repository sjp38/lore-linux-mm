Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93BAF6B04A6
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 15:41:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so199074pfd.2
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 12:41:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id o13si2240780pli.560.2017.09.08.12.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 12:41:38 -0700 (PDT)
Subject: [RFC PATCH v8 2/2] mm: introduce MAP_SHARED_VALIDATE,
 a mechanism to safely define new mmap flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Sep 2017 12:35:13 -0700
Message-ID: <150489931339.29460.8760855724603300792.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150489930202.29460.5141541423730649272.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150489930202.29460.5141541423730649272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

The mmap(2) syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
mechanism to define new behavior that is known to fail on older kernels
without the support. Define a new MAP_SHARED_VALIDATE flag pattern that
is guaranteed to fail on all legacy mmap implementations.

With this in place new flags can be defined as:

    #define MAP_new (MAP_SHARED_VALIDATE | val)

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

Cc: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Christoph Hellwig <hch@lst.de>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/alpha/include/uapi/asm/mman.h           |    1 +
 arch/mips/include/uapi/asm/mman.h            |    1 +
 arch/parisc/include/uapi/asm/mman.h          |    1 +
 arch/xtensa/include/uapi/asm/mman.h          |    1 +
 include/linux/fs.h                           |    1 +
 include/linux/mman.h                         |   44 ++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h       |    1 +
 mm/mmap.c                                    |   10 +++++-
 tools/include/uapi/asm-generic/mman-common.h |    1 +
 9 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 3b26cc62dadb..c32276c4196a 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -14,6 +14,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping (OSF/1 is _wrong_) */
 #define MAP_FIXED	0x100		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 /* not used by linux, but here to make sure we don't clash with OSF/1 defines */
 #define _MAP_HASSEMAPHORE 0x0200
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index da3216007fe0..9abca34eab2c 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -30,6 +30,7 @@
 #define MAP_PRIVATE	0x002		/* Changes are private */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 /* not used by linux, but here to make sure we don't clash with ABI defines */
 #define MAP_RENAME	0x020		/* Assign page to file */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 775b5d5e41a1..0459bd8642dd 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -14,6 +14,7 @@
 #define MAP_TYPE	0x03		/* Mask for type of mapping */
 #define MAP_FIXED	0x04		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index b15b278aa314..8cf11f7402ac 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -37,6 +37,7 @@
 #define MAP_PRIVATE	0x002		/* Changes are private */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 /* not used by linux, but here to make sure we don't clash with ABI defines */
 #define MAP_RENAME	0x020		/* Assign page to file */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2a4d8016bbf7..db2edf8815b2 100644
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
diff --git a/include/linux/mman.h b/include/linux/mman.h
index c8367041fafd..26609ee46079 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -7,6 +7,50 @@
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
+ * support when file_operations.mmap_supported_mask is zero. Deprecated
+ * flags like MAP_DENYWRITE and MAP_EXECUTABLE continue to be silently
+ * accepted. Only new flags defined with MAP_SHARED_VALIDATE are
+ * explicitly checked.
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
+#define	MAP_SUPPORTED_MASK (LEGACY_MAP_MASK)
+
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 203268f9231e..2404db8c71df 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -24,6 +24,7 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 /*
  * Flags for mlock
diff --git a/mm/mmap.c b/mm/mmap.c
index 77d5aecf49dc..f43f2c444e2b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1387,8 +1387,16 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 
 	if (file) {
 		struct inode *inode = file_inode(file);
+		unsigned long f_supported;
 
 		switch (flags & MAP_TYPE) {
+		case (MAP_SHARED_VALIDATE):
+			f_supported = file->f_op->mmap_supported_mask;
+			if (!f_supported)
+				f_supported = LEGACY_MAP_MASK;
+			if (flags & ~f_supported)
+				return -EOPNOTSUPP;
+			/* fall through */
 		case MAP_SHARED:
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
 				return -EACCES;
@@ -1465,7 +1473,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, 0);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
diff --git a/tools/include/uapi/asm-generic/mman-common.h b/tools/include/uapi/asm-generic/mman-common.h
index 8c27db0c5c08..911aea581928 100644
--- a/tools/include/uapi/asm-generic/mman-common.h
+++ b/tools/include/uapi/asm-generic/mman-common.h
@@ -24,6 +24,7 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
+#define MAP_SHARED_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* validate extension flags */
 
 /*
  * Flags for mlock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
