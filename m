Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l2NMjsDI022065
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:45:54 -0700
Received: from an-out-0708.google.com (ancc35.prod.google.com [10.100.29.35])
	by zps78.corp.google.com with ESMTP id l2NMjFsk021998
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:45:48 -0700
Received: by an-out-0708.google.com with SMTP id c35so1445727anc
        for <linux-mm@kvack.org>; Fri, 23 Mar 2007 15:45:48 -0700 (PDT)
Message-ID: <b040c32a0703231545h79d45d0eof1edd225ef3d8ee9@mail.gmail.com>
Date: Fri, 23 Mar 2007 15:45:47 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch 2/2] hugetlb: add /dev/hugetlb char device
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

add a char device /dev/hugetlb that behaves similar to /dev/zero,
built on top of internal hugetlbfs mount.

Signed-off-by: Ken Chen <kenchen@google.com>


diff -u b/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
--- b/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -795,6 +795,23 @@
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
+const struct file_operations hugetlb_dev_fops = {
+	.mmap			= hugetlb_zero_setup,
+	.get_unmapped_area	= hugetlb_get_unmapped_area,
+};
+
 static int __init init_hugetlbfs_fs(void)
 {
 	int error;
diff -u b/include/linux/hugetlb.h b/include/linux/hugetlb.h
--- b/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -162,6 +162,7 @@
 }

 extern const struct file_operations hugetlbfs_file_operations;
+extern const struct file_operations hugetlb_dev_fops;
 extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(size_t, int);
 int hugetlb_get_quota(struct address_space *mapping);
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -27,6 +27,7 @@ #include <linux/backing-dev.h>
 #include <linux/bootmem.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/pfn.h>
+#include <linux/hugetlb.h>

 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -939,6 +940,12 @@ #ifdef CONFIG_CRASH_DUMP
 			filp->f_op = &oldmem_fops;
 			break;
 #endif
+#ifdef CONFIG_HUGETLBFS
+		case 13:
+			printk("open hugetlb dev device\n");
+			filp->f_op = &hugetlb_dev_fops;
+			break;
+#endif
 		default:
 			return -ENXIO;
 	}
@@ -971,6 +978,9 @@ #endif
 #ifdef CONFIG_CRASH_DUMP
 	{12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
 #endif
+#ifdef CONFIG_HUGETLBFS
+	{13, "hugetlb",S_IRUGO | S_IWUGO,	    &hugetlb_dev_fops},
+#endif
 };

 static struct class *mem_class;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
