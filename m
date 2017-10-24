Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D99F6B0266
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so8355409wmd.9
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 106si393846wrc.224.2017.10.24.08.25.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:28 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/17] mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags
Date: Tue, 24 Oct 2017 17:23:58 +0200
Message-Id: <20171024152415.22864-2-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

From: Dan Williams <dan.j.williams@intel.com>

The mmap(2) syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC need a mechanism to
define new behavior that is known to fail on older kernels without the
support. Define a new MAP_SHARED_VALIDATE flag pattern that is
guaranteed to fail on all legacy mmap implementations.

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
validated against a mmap_supported_flags exported by 'struct
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
Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/alpha/include/uapi/asm/mman.h           |  1 +
 arch/mips/include/uapi/asm/mman.h            |  1 +
 arch/parisc/include/uapi/asm/mman.h          |  1 +
 arch/xtensa/include/uapi/asm/mman.h          |  1 +
 include/linux/fs.h                           |  1 +
 include/linux/mman.h                         | 39 ++++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h       |  1 +
 mm/mmap.c                                    | 15 +++++++++++
 tools/include/uapi/asm-generic/mman-common.h |  1 +
 9 files changed, 61 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 3b26cc62dadb..f6d118aaedb9 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -11,6 +11,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping (OSF/1 is _wrong_) */
 #define MAP_FIXED	0x100		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index da3216007fe0..93268e4cd3c7 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -28,6 +28,7 @@
  */
 #define MAP_SHARED	0x001		/* Share changes */
 #define MAP_PRIVATE	0x002		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x003	/* share + validate extension flags */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
 
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 775b5d5e41a1..bca652aa1677 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -11,6 +11,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
 #define MAP_TYPE	0x03		/* Mask for type of mapping */
 #define MAP_FIXED	0x04		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x10		/* don't use a file */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index b15b278aa314..9ab426374714 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -35,6 +35,7 @@
  */
 #define MAP_SHARED	0x001		/* Share changes */
 #define MAP_PRIVATE	0x002		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x003	/* share + validate extension flags */
 #define MAP_TYPE	0x00f		/* Mask for type of mapping */
 #define MAP_FIXED	0x010		/* Interpret addr exactly */
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 13dab191a23e..57added3201d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1701,6 +1701,7 @@ struct file_operations {
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
+	unsigned long mmap_supported_flags;
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
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
index 203268f9231e..8ce7f5a0800f 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -16,6 +16,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506faceae..924839fac0e6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1387,9 +1387,24 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 
 	if (file) {
 		struct inode *inode = file_inode(file);
+		unsigned long flags_mask;
+
+		flags_mask = LEGACY_MAP_MASK | file->f_op->mmap_supported_flags;
 
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
+			/*
+			 * Force use of MAP_SHARED_VALIDATE with non-legacy
+			 * flags. E.g. MAP_SYNC is dangerous to use with
+			 * MAP_SHARED as you don't know which consistency model
+			 * you will get. We silently ignore unsupported flags
+			 * with MAP_SHARED to preserve backward compatibility.
+			 */
+			flags &= LEGACY_MAP_MASK;
+			/* fall through */
+		case MAP_SHARED_VALIDATE:
+			if (flags & ~flags_mask)
+				return -EOPNOTSUPP;
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
 				return -EACCES;
 
diff --git a/tools/include/uapi/asm-generic/mman-common.h b/tools/include/uapi/asm-generic/mman-common.h
index 203268f9231e..8ce7f5a0800f 100644
--- a/tools/include/uapi/asm-generic/mman-common.h
+++ b/tools/include/uapi/asm-generic/mman-common.h
@@ -16,6 +16,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
