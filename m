Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EF5676B0268
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:57:36 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id 184so42538426pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:57:36 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 73si7241952pfp.195.2016.04.06.15.51.36
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 24/30] shmem: get_unmapped_area align huge page
Date: Thu,  7 Apr 2016 01:51:14 +0300
Message-Id: <1459983080-106718-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Hugh Dickins <hughd@google.com>

Provide a shmem_get_unmapped_area method in file_operations, called
at mmap time to decide the mapping address.  It could be conditional
on CONFIG_TRANSPARENT_HUGEPAGE, but save #ifdefs in other places by
making it unconditional.

shmem_get_unmapped_area() first calls the usual mm->get_unmapped_area
(which we treat as a black box, highly dependent on architecture and
config and executable layout).  Lots of conditions, and in most cases
it just goes with the address that chose; but when our huge stars are
rightly aligned, yet that did not provide a suitable address, go back
to ask for a larger arena, within which to align the mapping suitably.

There have to be some direct calls to shmem_get_unmapped_area(),
not via the file_operations: because of the way shmem_zero_setup()
is called to create a shmem object late in the mmap sequence, when
MAP_SHARED is requested with MAP_ANONYMOUS or /dev/zero.  Though
this only matters when /proc/sys/vm/shmem_huge has been set.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/char/mem.c       | 24 ++++++++++++
 include/linux/shmem_fs.h |  2 +
 ipc/shm.c                |  6 ++-
 mm/mmap.c                | 16 +++++++-
 mm/shmem.c               | 98 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 142 insertions(+), 4 deletions(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 71025c2f6bbb..9656f1095c19 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -22,6 +22,7 @@
 #include <linux/device.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
+#include <linux/shmem_fs.h>
 #include <linux/splice.h>
 #include <linux/pfn.h>
 #include <linux/export.h>
@@ -661,6 +662,28 @@ static int mmap_zero(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
+static unsigned long get_unmapped_area_zero(struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags)
+{
+#ifdef CONFIG_MMU
+	if (flags & MAP_SHARED) {
+		/*
+		 * mmap_zero() will call shmem_zero_setup() to create a file,
+		 * so use shmem's get_unmapped_area in case it can be huge;
+		 * and pass NULL for file as in mmap.c's get_unmapped_area(),
+		 * so as not to confuse shmem with our handle on "/dev/zero".
+		 */
+		return shmem_get_unmapped_area(NULL, addr, len, pgoff, flags);
+	}
+
+	/* Otherwise flags & MAP_PRIVATE: with no shmem object beneath it */
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+#else
+	return -ENOSYS;
+#endif
+}
+
 static ssize_t write_full(struct file *file, const char __user *buf,
 			  size_t count, loff_t *ppos)
 {
@@ -768,6 +791,7 @@ static const struct file_operations zero_fops = {
 	.read_iter	= read_iter_zero,
 	.write_iter	= write_iter_zero,
 	.mmap		= mmap_zero,
+	.get_unmapped_area = get_unmapped_area_zero,
 #ifndef CONFIG_MMU
 	.mmap_capabilities = zero_mmap_capabilities,
 #endif
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 466f18c73a49..ff2de4bab61f 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -50,6 +50,8 @@ extern struct file *shmem_file_setup(const char *name,
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
+extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
 extern void shmem_unlock_mapping(struct address_space *mapping);
diff --git a/ipc/shm.c b/ipc/shm.c
index 331fc1b0b3c7..b1ed484eeda1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -476,13 +476,15 @@ static const struct file_operations shm_file_operations = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
 	.release	= shm_release,
-#ifndef CONFIG_MMU
 	.get_unmapped_area	= shm_get_unmapped_area,
-#endif
 	.llseek		= noop_llseek,
 	.fallocate	= shm_fallocate,
 };
 
+/*
+ * shm_file_operations_huge is now identical to shm_file_operations,
+ * but we keep it distinct for the sake of is_file_shm_hugepages().
+ */
 static const struct file_operations shm_file_operations_huge = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
diff --git a/mm/mmap.c b/mm/mmap.c
index 0a68cf0b37e7..cc1fa2b0d14f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -25,6 +25,7 @@
 #include <linux/personality.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
 #include <linux/profile.h>
 #include <linux/export.h>
 #include <linux/mount.h>
@@ -1900,8 +1901,19 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		return -ENOMEM;
 
 	get_area = current->mm->get_unmapped_area;
-	if (file && file->f_op->get_unmapped_area)
-		get_area = file->f_op->get_unmapped_area;
+	if (file) {
+		if (file->f_op->get_unmapped_area)
+			get_area = file->f_op->get_unmapped_area;
+	} else if (flags & MAP_SHARED) {
+		/*
+		 * mmap_region() will call shmem_zero_setup() to create a file,
+		 * so use shmem's get_unmapped_area in case it can be huge.
+		 * do_mmap_pgoff() will clear pgoff, so match alignment.
+		 */
+		pgoff = 0;
+		get_area = shmem_get_unmapped_area;
+	}
+
 	addr = get_area(file, addr, len, pgoff, flags);
 	if (IS_ERR_VALUE(addr))
 		return addr;
diff --git a/mm/shmem.c b/mm/shmem.c
index 8dec1c8500fe..b44bfa0d6360 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1525,6 +1525,94 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
+unsigned long shmem_get_unmapped_area(struct file *file,
+				      unsigned long uaddr, unsigned long len,
+				      unsigned long pgoff, unsigned long flags)
+{
+	unsigned long (*get_area)(struct file *,
+		unsigned long, unsigned long, unsigned long, unsigned long);
+	unsigned long addr;
+	unsigned long offset;
+	unsigned long inflated_len;
+	unsigned long inflated_addr;
+	unsigned long inflated_offset;
+
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
+	get_area = current->mm->get_unmapped_area;
+	addr = get_area(file, uaddr, len, pgoff, flags);
+
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return addr;
+	if (IS_ERR_VALUE(addr))
+		return addr;
+	if (addr & ~PAGE_MASK)
+		return addr;
+	if (addr > TASK_SIZE - len)
+		return addr;
+
+	if (shmem_huge == SHMEM_HUGE_DENY)
+		return addr;
+	if (len < HPAGE_PMD_SIZE)
+		return addr;
+	if (flags & MAP_FIXED)
+		return addr;
+	/*
+	 * Our priority is to support MAP_SHARED mapped hugely;
+	 * and support MAP_PRIVATE mapped hugely too, until it is COWed.
+	 * But if caller specified an address hint, respect that as before.
+	 */
+	if (uaddr)
+		return addr;
+
+	if (shmem_huge != SHMEM_HUGE_FORCE) {
+		struct super_block *sb;
+
+		if (file) {
+			VM_BUG_ON(file->f_op != &shmem_file_operations);
+			sb = file_inode(file)->i_sb;
+		} else {
+			/*
+			 * Called directly from mm/mmap.c, or drivers/char/mem.c
+			 * for "/dev/zero", to create a shared anonymous object.
+			 */
+			if (IS_ERR(shm_mnt))
+				return addr;
+			sb = shm_mnt->mnt_sb;
+		}
+		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
+			return addr;
+	}
+
+	offset = (pgoff << PAGE_SHIFT) & (HPAGE_PMD_SIZE-1);
+	if (offset && offset + len < 2 * HPAGE_PMD_SIZE)
+		return addr;
+	if ((addr & (HPAGE_PMD_SIZE-1)) == offset)
+		return addr;
+
+	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
+	if (inflated_len > TASK_SIZE)
+		return addr;
+	if (inflated_len < len)
+		return addr;
+
+	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);
+	if (IS_ERR_VALUE(inflated_addr))
+		return addr;
+	if (inflated_addr & ~PAGE_MASK)
+		return addr;
+
+	inflated_offset = inflated_addr & (HPAGE_PMD_SIZE-1);
+	inflated_addr += offset - inflated_offset;
+	if (inflated_offset > offset)
+		inflated_addr += HPAGE_PMD_SIZE;
+
+	if (inflated_addr > TASK_SIZE - len)
+		return addr;
+	return inflated_addr;
+}
+
 #ifdef CONFIG_NUMA
 static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *mpol)
 {
@@ -3268,6 +3356,7 @@ static const struct address_space_operations shmem_aops = {
 
 static const struct file_operations shmem_file_operations = {
 	.mmap		= shmem_mmap,
+	.get_unmapped_area = shmem_get_unmapped_area,
 #ifdef CONFIG_TMPFS
 	.llseek		= shmem_file_llseek,
 	.read_iter	= shmem_file_read_iter,
@@ -3503,6 +3592,15 @@ void shmem_unlock_mapping(struct address_space *mapping)
 {
 }
 
+#ifdef CONFIG_MMU
+unsigned long shmem_get_unmapped_area(struct file *file,
+				      unsigned long addr, unsigned long len,
+				      unsigned long pgoff, unsigned long flags)
+{
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+}
+#endif
+
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	truncate_inode_pages_range(inode->i_mapping, lstart, lend);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
