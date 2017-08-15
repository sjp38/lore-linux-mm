Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9FA6B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:18:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so999218pgb.13
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:18:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q6si5044829pgn.509.2017.08.14.23.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 23:18:41 -0700 (PDT)
Subject: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for adding
 new mmap flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 14 Aug 2017 23:12:16 -0700
Message-ID: <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

The mmap syscall suffers from the ABI anti-pattern of not validating
unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
mechanism to define new behavior that is known to fail on older kernels
without the feature. Use the fact that specifying MAP_SHARED and
MAP_PRIVATE at the same time is invalid as a cute hack to allow a new
set of validated flags to be introduced.

This also introduces the ->fmmap() file operation that is ->mmap() plus
flags. Each ->fmmap() implementation must fail requests when a locally
unsupported flag is specified.

Cc: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h                     |    7 +++++++
 include/linux/mm.h                     |    2 +-
 include/linux/mman.h                   |    3 +++
 include/uapi/asm-generic/mman-common.h |    1 +
 mm/mmap.c                              |   20 +++++++++++++++++---
 5 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1104e5df39ef..bbe755d0caee 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1674,6 +1674,7 @@ struct file_operations {
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*fmmap) (struct file *, struct vm_area_struct *, unsigned long);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
@@ -1748,6 +1749,12 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
 	return file->f_op->mmap(file, vma);
 }
 
+static inline int call_fmmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long flags)
+{
+	return file->f_op->fmmap(file, vma, flags);
+}
+
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			      unsigned long nr_segs, unsigned long fast_segs,
 			      struct iovec *fast_pointer,
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
index c8367041fafd..73d4ac7e7136 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -7,6 +7,9 @@
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
 
+/* the MAP_VALIDATE set of supported flags */
+#define	MAP_SUPPORTED_MASK (0)
+
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0c5c08..8bf8c7828275 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -24,6 +24,7 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
+#define MAP_VALIDATE (MAP_SHARED|MAP_PRIVATE) /* mechanism to define new shared semantics */
 
 /*
  * Flags for mlock
diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf75418..d2919a9e25bf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1388,6 +1388,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		struct inode *inode = file_inode(file);
 
 		switch (flags & MAP_TYPE) {
+		case MAP_VALIDATE:
+			if (flags & ~(MAP_SUPPORTED_MASK | MAP_VALIDATE))
+				return -EINVAL;
+			if (!file->f_op->fmmap)
+				return -EOPNOTSUPP;
+			/* fall through */
 		case MAP_SHARED:
 			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
 				return -EACCES;
@@ -1464,7 +1470,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	if ((flags & MAP_VALIDATE) == MAP_VALIDATE)
+		flags &= MAP_SUPPORTED_MASK;
+	else
+		flags = 0;
+
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, flags);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1601,7 +1612,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		struct list_head *uf, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1686,7 +1697,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * new file must not have been exposed to user-space, yet.
 		 */
 		vma->vm_file = get_file(file);
-		error = call_mmap(file, vma);
+		if (flags)
+			error = call_fmmap(file, vma, flags);
+		else
+			error = call_mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
