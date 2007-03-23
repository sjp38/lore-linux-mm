Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l2N8iflZ006629
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 08:44:41 GMT
Received: from an-out-0708.google.com (ancc17.prod.google.com [10.100.29.17])
	by spaceape11.eur.corp.google.com with ESMTP id l2N8ho3U010005
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 08:44:39 GMT
Received: by an-out-0708.google.com with SMTP id c17so1057930anc
        for <linux-mm@kvack.org>; Fri, 23 Mar 2007 01:44:39 -0700 (PDT)
Message-ID: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
Date: Fri, 23 Mar 2007 01:44:38 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] rfc: introduce /dev/hugetlb
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 3/21/07, Adam Litke <agl@us.ibm.com> wrote:
> The main reason I am advocating a set of pagetable_operations is to
> enable the development of a new hugetlb interface.  During the hugetlb
> BOFS at OLS last year, we talked about a character device that would
> behave like /dev/zero.  Many of the people were talking about how they
> just wanted to create MAP_PRIVATE hugetlb mappings without all the fuss
> about the hugetlbfs filesystem.  /dev/zero is a familiar interface for
> getting anonymous memory so bringing that model to huge pages would make
> programming for anonymous huge pages easier.

I think we have enough infrastructure currently in hugetlbfs to
implement what Adam wants for something like a /dev/hugetlb char
device (except we can't afford to have a zero hugetlb page since it
will be too costly on some arch).

I really like the idea of having something similar to /dev/zero for
hugetlb page.  So I coded it up on top of existing hugetlbfs.  The
core change is really small and half of the patch is really just
moving things around.  I think this at least can partially fulfill the
goal.


Signed-off-by: Ken Chen <kenchen@google.com>

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index f5c160c..56e58f5 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -27,6 +27,7 @@
 #include <linux/bootmem.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/pfn.h>
+#include <linux/hugetlb.h>

 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -872,6 +873,13 @@ static const struct file_operations oldmem_fops = {
 };
 #endif

+#ifdef CONFIG_HUGETLBFS
+static const struct file_operations hugetlb_fops = {
+	.mmap			= hugetlb_zero_setup,
+	.get_unmapped_area	= hugetlb_get_unmapped_area,
+};
+#endif
+
 static ssize_t kmsg_write(struct file * file, const char __user * buf,
 			  size_t count, loff_t *ppos)
 {
@@ -939,6 +947,11 @@ static int memory_open(struct inode *
 			filp->f_op = &oldmem_fops;
 			break;
 #endif
+#ifdef CONFIG_HUGETLBFS
+		case 13:
+			filp->f_op = &hugetlb_fops;
+			break;
+#endif
 		default:
 			return -ENXIO;
 	}
@@ -971,6 +984,9 @@ static const struct {
 #ifdef CONFIG_CRASH_DUMP
 	{12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
 #endif
+#ifdef CONFIG_HUGETLBFS
+	{13, "hugetlb",S_IRUGO | S_IWUGO,	    &hugetlb_fops},
+#endif
 };

 static struct class *mem_class;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8c718a3..af24664 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -97,12 +97,7 @@ out:
 /*
  * Called under down_write(mmap_sem).
  */
-
-#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags);
-#else
-static unsigned long
+unsigned long
 hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
@@ -150,7 +145,6 @@ full_search:
 		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
 	}
 }
-#endif

 /*
  * Read a page. Again trivial. If it didn't already exist
@@ -734,7 +728,7 @@ static int can_do_hugetlb_shm(void)
 			can_do_mlock());
 }

-struct file *hugetlb_zero_setup(size_t size)
+struct file *hugetlb_file_setup(size_t size, int resv)
 {
 	int error = -ENOMEM;
 	struct file *file;
@@ -771,7 +765,7 @@ struct file *hugetlb_zero_setup(size_t size)
 		goto out_file;

 	error = -ENOMEM;
-	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
+	if (resv && hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
 		goto out_inode;

 	d_instantiate(dentry, inode);
@@ -795,6 +789,18 @@ out_shm_unlock:
 	return ERR_PTR(error);
 }

+int hugetlb_zero_setup(struct file *file, struct vm_area_struct *vma)
+{
+	file = hugetlb_file_setup(vma->vm_end - vma->vm_start, 0);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	if (vma->vm_file)
+		fput(vma->vm_file);
+	vma->vm_file = file;
+	return hugetlbfs_file_mmap(file, vma);
+}
+
 static int __init init_hugetlbfs_fs(void)
 {
 	int error;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 3f3e7a6..d2a2190 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -163,9 +163,12 @@ static inline struct hugetlbfs_sb_info *

 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_zero_setup(size_t);
+struct file *hugetlb_file_setup(size_t, int);
+int hugetlb_zero_setup(struct file *, struct vm_area_struct *);
 int hugetlb_get_quota(struct address_space *mapping);
 void hugetlb_put_quota(struct address_space *mapping);
+unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);

 static inline int is_file_hugepages(struct file *file)
 {
@@ -185,7 +188,7 @@ static inline void set_file_hugepages(struct file *file)

 #define is_file_hugepages(file)		0
 #define set_file_hugepages(file)	BUG()
-#define hugetlb_zero_setup(size)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(size, resv)	ERR_PTR(-ENOSYS)

 #endif /* !CONFIG_HUGETLBFS */

diff --git a/ipc/shm.c b/ipc/shm.c
index 4fefbad..c64643f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -366,7 +366,7 @@ static int newseg (struct ipc_namespace *ns

 	if (shmflg & SHM_HUGETLB) {
 		/* hugetlb_zero_setup takes care of mlock user accounting */
-		file = hugetlb_zero_setup(size);
+		file = hugetlb_file_setup(size, 1);
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
