Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id D460F6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:56:38 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id s143so80538903ywg.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:56:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g204si522746ywg.691.2017.08.11.16.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 16:56:37 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/2] mm/shmem: add hugetlbfs support to memfd_create()
Date: Fri, 11 Aug 2017 16:56:11 -0700
Message-Id: <1502495772-24736-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1502495772-24736-1-git-send-email-mike.kravetz@oracle.com>
References: <1502495772-24736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This patch came out of discussions in this e-mail thread:
http://lkml.kernel.org/r/1499357846-7481-1-git-send-email-mike.kravetz%40oracle.com

The Oracle JVM team is developing a new garbage collection model.  This
new model requires multiple mappings of the same anonymous memory.  One
straight forward way to accomplish this is with memfd_create.  They can
use the returned fd to create multiple mappings of the same memory.

The JVM today has an option to use (static hugetlb) huge pages.  If this
option is specified, they would like to use the same garbage collection
model requiring multiple mappings to the same memory.  Using hugetlbfs,
it is possible to explicitly mount a filesystem and specify file paths
in order to get an fd that can be used for multiple mappings.  However,
this introduces additional system admin work and coordination.

Ideally they would like to get a hugetlbfs fd without requiring explicit
mounting of a filesystem.   Today, mmap and shmget can make use of
hugetlbfs without explicitly mounting a filesystem.  The patch adds this
functionality to memfd_create.

Add a new flag MFD_HUGETLB to memfd_create() that will specify the
file to be created resides in the hugetlbfs filesystem.  This is
the generic hugetlbfs filesystem not associated with any specific
mount point.  As with other system calls that request hugetlbfs
backed pages, there is the ability to encode huge page size in the
flag arguments.

hugetlbfs does not support sealing operations, therefore specifying
MFD_ALLOW_SEALING with MFD_HUGETLB will result in EINVAL.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/uapi/linux/memfd.h | 24 ++++++++++++++++++++++++
 mm/shmem.c                 | 37 +++++++++++++++++++++++++++++++------
 2 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
index 534e364..7f3a722 100644
--- a/include/uapi/linux/memfd.h
+++ b/include/uapi/linux/memfd.h
@@ -1,8 +1,32 @@
 #ifndef _UAPI_LINUX_MEMFD_H
 #define _UAPI_LINUX_MEMFD_H
 
+#include <asm-generic/hugetlb_encode.h>
+
 /* flags for memfd_create(2) (unsigned int) */
 #define MFD_CLOEXEC		0x0001U
 #define MFD_ALLOW_SEALING	0x0002U
+#define MFD_HUGETLB		0x0004U
+
+/*
+ * Huge page size encoding when MFD_HUGETLB is specified, and a huge page
+ * size other than the default is desired.  See hugetlb_encode.h.
+ * All known huge page size encodings are provided here.  It is the
+ * responsibility of the application to know which sizes are supported on
+ * the running system.  See mmap(2) man page for details.
+ */
+#define MFD_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
+#define MFD_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
+
+#define MFD_HUGE_64KB	HUGETLB_FLAG_ENCODE_64KB
+#define MFD_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
+#define MFD_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
+#define MFD_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
+#define MFD_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
+#define MFD_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
+#define MFD_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
+#define MFD_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
+#define MFD_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
+#define MFD_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
 
 #endif /* _UAPI_LINUX_MEMFD_H */
diff --git a/mm/shmem.c b/mm/shmem.c
index b0aa607..3db79ce 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -34,6 +34,7 @@
 #include <linux/swap.h>
 #include <linux/uio.h>
 #include <linux/khugepaged.h>
+#include <linux/hugetlb.h>
 
 #include <asm/tlbflush.h> /* for arch/microblaze update_mmu_cache() */
 
@@ -3627,7 +3628,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 #define MFD_NAME_PREFIX_LEN (sizeof(MFD_NAME_PREFIX) - 1)
 #define MFD_NAME_MAX_LEN (NAME_MAX - MFD_NAME_PREFIX_LEN)
 
-#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING)
+#define MFD_ALL_FLAGS (MFD_CLOEXEC | MFD_ALLOW_SEALING | MFD_HUGETLB)
 
 SYSCALL_DEFINE2(memfd_create,
 		const char __user *, uname,
@@ -3639,8 +3640,18 @@ SYSCALL_DEFINE2(memfd_create,
 	char *name;
 	long len;
 
-	if (flags & ~(unsigned int)MFD_ALL_FLAGS)
-		return -EINVAL;
+	if (!(flags & MFD_HUGETLB)) {
+		if (flags & ~(unsigned int)MFD_ALL_FLAGS)
+			return -EINVAL;
+	} else {
+		/* Sealing not supported in hugetlbfs (MFD_HUGETLB) */
+		if (flags & MFD_ALLOW_SEALING)
+			return -EINVAL;
+		/* Allow huge page size encoding in flags. */
+		if (flags & ~(unsigned int)(MFD_ALL_FLAGS |
+				(MFD_HUGE_MASK << MFD_HUGE_SHIFT)))
+			return -EINVAL;
+	}
 
 	/* length includes terminating zero */
 	len = strnlen_user(uname, MFD_NAME_MAX_LEN + 1);
@@ -3671,16 +3682,30 @@ SYSCALL_DEFINE2(memfd_create,
 		goto err_name;
 	}
 
-	file = shmem_file_setup(name, 0, VM_NORESERVE);
+	if (flags & MFD_HUGETLB) {
+		struct user_struct *user = NULL;
+
+		file = hugetlb_file_setup(name, 0, VM_NORESERVE, &user,
+					HUGETLB_ANONHUGE_INODE,
+					(flags >> MFD_HUGE_SHIFT) &
+					MFD_HUGE_MASK);
+	} else
+		file = shmem_file_setup(name, 0, VM_NORESERVE);
 	if (IS_ERR(file)) {
 		error = PTR_ERR(file);
 		goto err_fd;
 	}
-	info = SHMEM_I(file_inode(file));
 	file->f_mode |= FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE;
 	file->f_flags |= O_RDWR | O_LARGEFILE;
-	if (flags & MFD_ALLOW_SEALING)
+
+	if (flags & MFD_ALLOW_SEALING) {
+		/*
+		 * flags check at beginning of function ensures
+		 * this is not a hugetlbfs (MFD_HUGETLB) file.
+		 */
+		info = SHMEM_I(file_inode(file));
 		info->seals &= ~F_SEAL_SEAL;
+	}
 
 	fd_install(fd, file);
 	kfree(name);
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
