Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D8FD26B00C2
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:40 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:26 -0700
Message-Id: <1243893048-17031-1-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 01/23] mm: Introduce revoke_file_mappings.
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@xmission.com>

When the backing store of a file becomes inaccessible we need a function
to remove that file from the page tables and arrange for page faults
to receive SIGBUS until the file is unmapped.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/mm.h |    2 +
 mm/memory.c        |   98 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bff1f0d..5d7480d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -808,6 +808,8 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
+extern void revoke_file_mappings(struct file *file);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
diff --git a/mm/memory.c b/mm/memory.c
index 4126dd1..5cbee3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -55,6 +55,7 @@
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/file.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2358,6 +2359,103 @@ void unmap_mapping_range(struct address_space *mapping,
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
+static void revoke_vma(struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	unsigned long start_addr, end_addr, size;
+	struct mm_struct *mm;
+
+	start_addr = vma->vm_start;
+	end_addr = vma->vm_end;
+
+	/* Switch out the locks so I can maninuplate this under the mm sem.
+	 * Needed so I can call vm_ops->close.
+	 */
+	mm = vma->vm_mm;
+	atomic_inc(&mm->mm_users);
+	spin_unlock(&mapping->i_mmap_lock);
+
+	/* Block page faults and other code modifying the mm. */
+	down_write(&mm->mmap_sem);
+
+	/* Lookup a vma for my file address */
+	vma = find_vma(mm, start_addr);
+	if (vma->vm_file != file)
+		goto out;
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
+	vma->vm_flags &= ~(VM_NONLINEAR | VM_CAN_NONLINEAR);
+out:
+	up_write(&mm->mmap_sem);
+	spin_lock(&mapping->i_mmap_lock);
+}
+
+void revoke_file_mappings(struct file *file)
+{
+	/* After a file has been marked dead update the vmas */
+	struct address_space *mapping = file->f_mapping;
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+
+	spin_lock(&mapping->i_mmap_lock);
+
+restart_tree:
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX) {
+		/* Skip quickly over vmas that do not need to be touched */
+		if (vma->vm_file != file)
+			continue;
+		revoke_vma(vma);
+		goto restart_tree;
+	}
+
+restart_list:
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list) {
+		/* Skip quickly over vmas that do not need to be touched */
+		if (vma->vm_file != file)
+			continue;
+		revoke_vma(vma);
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
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
