Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9B8186B004D
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:26:37 -0400 (EDT)
Subject: [PATCH 2/4] sysfs: Use revoke_file_mappings
References: <m1fxb2wm0z.fsf@fess.ebiederm.org>
	<m1bplqwlzr.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 04 Sep 2009 12:26:40 -0700
In-Reply-To: <m1bplqwlzr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 04 Sep 2009 12\:25\:28 -0700")
Message-ID: <m17hwewlxr.fsf_-_@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


Now that we have a generic helper simply sysfs by using it.

This requires a bit of a logic change because revoke_file_mappings
does proper clean up of the vmas which means it will call
fput which can call release, which grabs sysfs_bin_lock.  So I remove
each bin_buffer from the list and drop sysfs_bin_lock before calling
revoke_file_mappings.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/sysfs/bin.c |  210 ++++----------------------------------------------------
 1 files changed, 13 insertions(+), 197 deletions(-)

diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index 2524714..530459f 100644
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -39,8 +39,6 @@ static DEFINE_MUTEX(sysfs_bin_lock);
 struct bin_buffer {
 	struct mutex			mutex;
 	void				*buffer;
-	int				mmapped;
-	struct vm_operations_struct 	*vm_ops;
 	struct file			*file;
 	struct hlist_node		list;
 };
@@ -175,175 +173,6 @@ static ssize_t write(struct file *file, const char __user *userbuf,
 	return count;
 }
 
-static void bin_vma_open(struct vm_area_struct *vma)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-
-	if (!bb->vm_ops || !bb->vm_ops->open)
-		return;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return;
-
-	bb->vm_ops->open(vma);
-
-	sysfs_put_active_two(attr_sd);
-}
-
-static void bin_vma_close(struct vm_area_struct *vma)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-
-	if (!bb->vm_ops || !bb->vm_ops->close)
-		return;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return;
-
-	bb->vm_ops->close(vma);
-
-	sysfs_put_active_two(attr_sd);
-}
-
-static int bin_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	int ret;
-
-	if (!bb->vm_ops || !bb->vm_ops->fault)
-		return VM_FAULT_SIGBUS;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return VM_FAULT_SIGBUS;
-
-	ret = bb->vm_ops->fault(vma, vmf);
-
-	sysfs_put_active_two(attr_sd);
-	return ret;
-}
-
-static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	int ret;
-
-	if (!bb->vm_ops)
-		return VM_FAULT_SIGBUS;
-
-	if (!bb->vm_ops->page_mkwrite)
-		return 0;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return VM_FAULT_SIGBUS;
-
-	ret = bb->vm_ops->page_mkwrite(vma, vmf);
-
-	sysfs_put_active_two(attr_sd);
-	return ret;
-}
-
-static int bin_access(struct vm_area_struct *vma, unsigned long addr,
-		  void *buf, int len, int write)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	int ret;
-
-	if (!bb->vm_ops || !bb->vm_ops->access)
-		return -EINVAL;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return -EINVAL;
-
-	ret = bb->vm_ops->access(vma, addr, buf, len, write);
-
-	sysfs_put_active_two(attr_sd);
-	return ret;
-}
-
-#ifdef CONFIG_NUMA
-static int bin_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	int ret;
-
-	if (!bb->vm_ops || !bb->vm_ops->set_policy)
-		return 0;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return -EINVAL;
-
-	ret = bb->vm_ops->set_policy(vma, new);
-
-	sysfs_put_active_two(attr_sd);
-	return ret;
-}
-
-static struct mempolicy *bin_get_policy(struct vm_area_struct *vma,
-					unsigned long addr)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	struct mempolicy *pol;
-
-	if (!bb->vm_ops || !bb->vm_ops->get_policy)
-		return vma->vm_policy;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return vma->vm_policy;
-
-	pol = bb->vm_ops->get_policy(vma, addr);
-
-	sysfs_put_active_two(attr_sd);
-	return pol;
-}
-
-static int bin_migrate(struct vm_area_struct *vma, const nodemask_t *from,
-			const nodemask_t *to, unsigned long flags)
-{
-	struct file *file = vma->vm_file;
-	struct bin_buffer *bb = file->private_data;
-	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
-	int ret;
-
-	if (!bb->vm_ops || !bb->vm_ops->migrate)
-		return 0;
-
-	if (!sysfs_get_active_two(attr_sd))
-		return 0;
-
-	ret = bb->vm_ops->migrate(vma, from, to, flags);
-
-	sysfs_put_active_two(attr_sd);
-	return ret;
-}
-#endif
-
-static struct vm_operations_struct bin_vm_ops = {
-	.open		= bin_vma_open,
-	.close		= bin_vma_close,
-	.fault		= bin_fault,
-	.page_mkwrite	= bin_page_mkwrite,
-	.access		= bin_access,
-#ifdef CONFIG_NUMA
-	.set_policy	= bin_set_policy,
-	.get_policy	= bin_get_policy,
-	.migrate	= bin_migrate,
-#endif
-};
-
 static int mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct bin_buffer *bb = file->private_data;
@@ -367,22 +196,7 @@ static int mmap(struct file *file, struct vm_area_struct *vma)
 	if (rc)
 		goto out_put;
 
-	/*
-	 * PowerPC's pci_mmap of legacy_mem uses shmem_zero_setup()
-	 * to satisfy versions of X which crash if the mmap fails: that
-	 * substitutes a new vm_file, and we don't then want bin_vm_ops.
-	 */
-	if (vma->vm_file != file)
-		goto out_put;
-
-	rc = -EINVAL;
-	if (bb->mmapped && bb->vm_ops != vma->vm_ops)
-		goto out_put;
-
 	rc = 0;
-	bb->mmapped = 1;
-	bb->vm_ops = vma->vm_ops;
-	vma->vm_ops = &bin_vm_ops;
 out_put:
 	sysfs_put_active_two(attr_sd);
 out_unlock:
@@ -440,7 +254,7 @@ static int release(struct inode * inode, struct file * file)
 	struct bin_buffer *bb = file->private_data;
 
 	mutex_lock(&sysfs_bin_lock);
-	hlist_del(&bb->list);
+	hlist_del_init(&bb->list);
 	mutex_unlock(&sysfs_bin_lock);
 
 	kfree(bb->buffer);
@@ -461,20 +275,22 @@ const struct file_operations bin_fops = {
 void unmap_bin_file(struct sysfs_dirent *attr_sd)
 {
 	struct bin_buffer *bb;
-	struct hlist_node *tmp;
 
 	if (sysfs_type(attr_sd) != SYSFS_KOBJ_BIN_ATTR)
 		return;
 
-	mutex_lock(&sysfs_bin_lock);
-
-	hlist_for_each_entry(bb, tmp, &attr_sd->s_bin_attr.buffers, list) {
-		struct inode *inode = bb->file->f_path.dentry->d_inode;
-
-		unmap_mapping_range(inode->i_mapping, 0, 0, 1);
-	}
-
-	mutex_unlock(&sysfs_bin_lock);
+	do {
+		bb = NULL;
+		mutex_lock(&sysfs_bin_lock);
+		if (!hlist_empty(&attr_sd->s_bin_attr.buffers)) {
+			bb = hlist_entry(attr_sd->s_bin_attr.buffers.first,
+					 struct bin_buffer, list);
+			hlist_del_init(&bb->list);
+		}
+		mutex_unlock(&sysfs_bin_lock);
+		if (bb)
+			revoke_file_mappings(bb->file);
+	} while (bb);
 }
 
 /**
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
