Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id ACC4E6B0031
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 04:25:16 -0400 (EDT)
Received: by mail-ea0-f176.google.com with SMTP id q16so2053035ead.35
        for <linux-mm@kvack.org>; Sat, 07 Sep 2013 01:25:15 -0700 (PDT)
Message-ID: <522AE146.1020707@gmail.com>
Date: Sat, 07 Sep 2013 10:18:14 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 03/19] pramfs: export xip_file_fault
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>

Export xip_file_fault to modules.

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 include/linux/fs.h |    2 ++
 mm/filemap_xip.c   |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3b4cd82..1f61e07 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -41,6 +41,7 @@ struct kobject;
 struct pipe_inode_info;
 struct poll_table_struct;
 struct kstatfs;
+struct vm_fault;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
@@ -2445,6 +2446,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
 #ifdef CONFIG_FS_XIP
 extern ssize_t xip_file_read(struct file *filp, char __user *buf, size_t len,
 			     loff_t *ppos);
+extern int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
 extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
 extern ssize_t xip_file_write(struct file *filp, const char __user *buf,
 			      size_t len, loff_t *ppos);
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 28fe26b..50bbc5d 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -219,7 +219,7 @@ retry:
  *
  * This function is derived from filemap_fault, but used for execute in place
  */
-static int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
@@ -303,6 +303,7 @@ out:
 	}
 }
 
+EXPORT_SYMBOL_GPL(xip_file_fault);
 static const struct vm_operations_struct xip_file_vm_ops = {
 	.fault	= xip_file_fault,
 	.page_mkwrite	= filemap_page_mkwrite,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
