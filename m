Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 02D536B0083
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:19:53 -0400 (EDT)
Subject: [PATCH 1/4] mm: Introduce revoke_file_mappings.
References: <m1fxb2wm0z.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 04 Sep 2009 12:25:28 -0700
In-Reply-To: <m1fxb2wm0z.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 04 Sep 2009 12\:24\:44 -0700")
Message-ID: <m1bplqwlzr.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


When the backing store of a file becomes inaccessible we need a
function to remove that file from the page tables and arrange for page
faults to receive SIGBUS until the file is unmapped.

The current implementation in sysfs almost gets this correct by
intercepting vm_ops, but fails to call vm_ops->close on revoke and in
fact does not have quite enough information available to do so.  Which
can result in leaks for any vm_ops that depend on close to drop
reference counts.

It turns out that revoke_file_mapping is less code and a more straight
forward solution to the problem (except for the locking), as well as
being a general solution that can work for any mmapped and is not
limited to sysfs.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/mm.h |    2 +
 mm/memory.c        |  140 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 142 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9a72cc7..eb6cecb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -790,6 +790,8 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+extern void revoke_file_mappings(struct file *file);
+
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
diff --git a/mm/memory.c b/mm/memory.c
index aede2ce..4b47116 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -55,6 +55,7 @@
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/file.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2410,6 +2411,145 @@ void unmap_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
+static int revoked_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static struct vm_operations_struct revoked_vm_ops = {
+	.fault	= revoked_fault,
+};
+
+static void revoke_one_file_vma(struct file *file,
+	struct mm_struct *mm, unsigned long vma_addr)
+{
+	unsigned long start_addr, end_addr, size;
+	struct vm_area_struct *vma;
+
+	/*
+	 * Must be called with mmap_sem held for write.
+	 *
+	 * Holding the mmap_sem prevents all vm_ops operations from
+	 * being called as well as preventing all other kinds of
+	 * modifications to the mm.
+	 */
+
+	/* Lookup a vma for my file address */
+	vma = find_vma(mm, vma_addr);
+	if (vma->vm_file != file)
+		return;
+
+	start_addr = vma->vm_start;
+	end_addr   = vma->vm_end;
+	size	   = end_addr - start_addr;
+
+	/* Unlock the pages */
+	if (mm->locked_vm && (vma->vm_flags & VM_LOCKED)) {
+		mm->locked_vm -= vma_pages(vma);
+		vma->vm_flags &= ~VM_LOCKED;
+	}
+
+	/* Unmap the vma */
+	zap_page_range(vma, start_addr, size, NULL);
+
+	/* Unlink the vma from the file */
+	unlink_file_vma(vma);
+
+	/* Close the vma */
+	if (vma->vm_ops && vma->vm_ops->close)
+		vma->vm_ops->close(vma);
+	fput(vma->vm_file);
+	vma->vm_file = NULL;
+	if (vma->vm_flags & VM_EXECUTABLE)
+		removed_exe_file_vma(vma->vm_mm);
+
+	/* Repurpose the vma  */
+	vma->vm_private_data = NULL;
+	vma->vm_ops = &revoked_vm_ops;
+	vma->vm_flags &= ~(VM_NONLINEAR | VM_CAN_NONLINEAR | VM_PFNMAP);
+}
+
+void revoke_file_mappings(struct file *file)
+{
+	/* After a file has been marked dead update the vmas */
+	struct address_space *mapping = file->f_mapping;
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	unsigned long start_address;
+	struct mm_struct *mm;
+	int mm_users;
+
+	/*
+	 * The locking here is a bit complex.
+	 *
+	 * - revoke_one_file_vma needs to be able to sleep so it can
+         *   call vm_ops->close().
+	 *
+	 * - i_mmap_lock needs to be held to iterate the list of vmas
+	 *   for a file.
+	 *
+	 * - The mm can be exiting when we find the vma on our list.
+	 *
+	 * - This function can not return until we can guarantee for
+	 *   all vmas associated with file that no vm_ops method will
+	 *   be called.
+	 *
+	 * This code increments mm_users to ensure that the mm will
+	 * not go away after it drops i_mmap_lock, and then grabs
+	 * mmap_sem for write to block all other modifications to the
+	 * mm, before refinding the the vma and removing it.
+	 *
+	 * If mm_users is already 0 indicated that exit_mmap is
+	 * running on the mm the code simply drop the locks and sleeps
+	 * giving exit_mmap a chance to finish.  If exit_mmap has not
+	 * freed our vma when we rescan the list we repeat until it has.
+	 */
+	spin_lock(&mapping->i_mmap_lock);
+restart_tree:
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX) {
+		/* Skip quickly over vmas that do not need to be touched */
+		if (vma->vm_file != file)
+			continue;
+		start_address = vma->vm_start;
+		mm = vma->vm_mm;
+		mm_users = atomic_inc_not_zero(&mm->mm_users);
+		spin_unlock(&mapping->i_mmap_lock);
+		if (mm_users) {
+			down_write(&mm->mmap_sem);
+			revoke_one_file_vma(file, mm, start_address);
+			up_write(&mm->mmap_sem);
+			mmput(mm);
+		} else {
+			schedule(); /* wait for exit_mmap to remove the vma */
+		}
+		spin_lock(&mapping->i_mmap_lock);
+		goto restart_tree;
+	}
+
+restart_list:
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list) {
+		/* Skip quickly over vmas that do not need to be touched */
+		if (vma->vm_file != file)
+			continue;
+		start_address = vma->vm_start;
+		mm = vma->vm_mm;
+		mm_users = atomic_inc_not_zero(&mm->mm_users);
+		spin_unlock(&mapping->i_mmap_lock);
+		if (mm_users) {
+			down_write(&mm->mmap_sem);
+			revoke_one_file_vma(file, mm, start_address);
+			up_write(&mm->mmap_sem);
+			mmput(mm);
+		} else {
+			schedule(); /* wait for exit_mmap to remove the vma */
+		}
+		spin_lock(&mapping->i_mmap_lock);
+		goto restart_list;
+	}
+
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
 /**
  * vmtruncate - unmap mappings "freed" by truncate() syscall
  * @inode: inode of the file used
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
