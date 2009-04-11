Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C9FD15F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:06:10 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:06:11 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1eivz75u4.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 3/9] sysfs: Use remap_file_mappings.
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


Instead of wrapping all of the sysfs binary file vm operations
when the backing kobject goes away, we can more easily change
vm_ops on the vma when the backing kobject goes away.

Leading to simpler and more easily maintained code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/bin.c |  193 +-------------------------------------------------------
 1 files changed, 2 insertions(+), 191 deletions(-)

diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index 93e0c02..898163c 100644
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
@@ -181,175 +179,6 @@ out_free:
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
@@ -370,25 +199,7 @@ static int mmap(struct file *file, struct vm_area_struct *vma)
 		goto out_put;
 
 	rc = attr->mmap(kobj, attr, vma);
-	if (rc)
-		goto out_put;
-
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
 
-	rc = 0;
-	bb->mmapped = 1;
-	bb->vm_ops = vma->vm_ops;
-	vma->vm_ops = &bin_vm_ops;
 out_put:
 	sysfs_put_active_two(attr_sd);
 out_unlock:
@@ -475,9 +286,9 @@ void unmap_bin_file(struct sysfs_dirent *attr_sd)
 	mutex_lock(&sysfs_bin_lock);
 
 	hlist_for_each_entry(bb, tmp, &attr_sd->s_bin_attr.buffers, list) {
-		struct inode *inode = bb->file->f_path.dentry->d_inode;
+		struct file *file = bb->file;
 
-		unmap_mapping_range(inode->i_mapping, 0, 0, 1);
+		remap_file_mappings(file, &revoked_vm_ops);
 	}
 
 	mutex_unlock(&sysfs_bin_lock);
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
