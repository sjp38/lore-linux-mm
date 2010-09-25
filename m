Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B462C6B007B
	for <linux-mm@kvack.org>; Sat, 25 Sep 2010 19:33:53 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
Date: Sat, 25 Sep 2010 16:33:48 -0700
In-Reply-To: <m1sk0x9z62.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Sat, 25 Sep 2010 16:33:09 -0700")
Message-ID: <m1ocbl9z4z.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [PATCH 1/3] mm: Introduce revoke_mappings.
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


When the backing store of a file becomes inaccessible we need a function
to remove that file from the page tables and arrange for page faults
to trigger SIGBUS.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/mm.h |    2 +
 mm/Makefile        |    2 +-
 mm/nommu.c         |    5 ++
 mm/revoke.c        |  180 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 188 insertions(+), 1 deletions(-)
 create mode 100644 mm/revoke.c

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..444544c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -828,6 +828,8 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 
 int invalidate_inode_page(struct page *page);
 
+extern void revoke_mappings(struct address_space *mapping);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
diff --git a/mm/Makefile b/mm/Makefile
index 34b2546..e741676 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o
+			   vmalloc.o pagewalk.o revoke.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
diff --git a/mm/nommu.c b/mm/nommu.c
index 88ff091..3e8b5ec 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1785,6 +1785,11 @@ void unmap_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
+void revoke_mappings(struct address_space *mapping)
+{
+}
+EXPORT_SYMBOL_GPL(revoke_mappings);
+
 /*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
diff --git a/mm/revoke.c b/mm/revoke.c
new file mode 100644
index 0000000..a76cd1a
--- /dev/null
+++ b/mm/revoke.c
@@ -0,0 +1,180 @@
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/anon_inodes.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/perf_event.h>
+
+#include "internal.h"
+
+/* Make revoked areas file backed */
+static struct file *revoked_filp;
+
+static int revoked_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static const struct vm_operations_struct revoked_vm_ops = {
+	.fault	= revoked_fault,
+};
+
+static int revoked_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &revoked_vm_ops;
+	return 0;
+}
+
+static const struct file_operations revoked_fops = {
+	.mmap	= revoked_mmap,
+};
+
+/* Flags preserved from the original revoked vma.
+ */
+#define REVOKED_VM_FLAGS (\
+	VM_READ		| \
+	VM_WRITE	| \
+	VM_EXEC		| \
+	VM_MAYREAD	| \
+	VM_MAYWRITE	| \
+	VM_MAYEXEC	| \
+	VM_DONTCOPY	| \
+	VM_NORESERVE	| \
+	0		)
+
+static void revoke_vma(struct vm_area_struct *old)
+{
+	/* Atomically replace a vma with an identical one that returns
+	 * VM_FAULT_SIGBUS to every mmap request.
+	 *
+	 * This function must be called with the mm->mmap semaphore held.
+	 */
+	unsigned long start, end, len, pgoff, vm_flags;
+	struct vm_area_struct *new;
+	struct mm_struct *mm;
+	struct file *file;
+
+	file  = revoked_filp;
+	mm    = old->vm_mm;
+	start = old->vm_start;
+	end   = old->vm_end;
+	len   = end - start;
+	pgoff = old->vm_pgoff;
+
+	/* Preserve user visble vm_flags. */
+	vm_flags = VM_SHARED | VM_MAYSHARE | (old->vm_flags & REVOKED_VM_FLAGS);
+
+	/* If kmem_cache_zalloc fails return and ultimately try again */
+	new = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (!new)
+		goto out;
+
+	/* I am freeing exactly one vma so munmap should never fail.
+	 * If munmap fails return and ultimately try again.
+	 */
+	if (unlikely(do_munmap(mm, start, len)))
+		goto fail;
+
+	INIT_LIST_HEAD(&new->anon_vma_chain);
+	new->vm_mm    = mm;
+	new->vm_start = start;
+	new->vm_end   = end;
+	new->vm_flags = vm_flags;
+	new->vm_page_prot = vm_get_page_prot(vm_flags);
+	new->vm_pgoff = pgoff;
+	new->vm_file  = file;
+	get_file(file);
+	new->vm_ops   = &revoked_vm_ops;
+
+	/* Since the area was just umapped there is no excuse for
+	 * insert_vm_struct to fail.
+	 *
+	 * If insert_vm_struct fails we will cause a SIGSEGV instead
+	 * a SIGBUS.  A shame but not the end of the world.
+	 */
+	if (unlikely(insert_vm_struct(mm, new)))
+		goto fail;
+
+	mm->total_vm += len >> PAGE_SHIFT;
+
+	perf_event_mmap(new);
+
+	return;
+fail:
+	kmem_cache_free(vm_area_cachep, new);
+	WARN_ONCE(1, "%s failed\n", __func__);
+out:
+	return;
+}
+
+static bool revoke_mapping(struct address_space *mapping, struct mm_struct *mm,
+			   unsigned long addr)
+{
+	/* Returns true if the locks were dropped */
+	struct vm_area_struct *vma;
+
+	/*
+	 * Drop i_mmap_lock and grab the mm sempahore so I can call
+	 * revoke_vma. 
+	 */
+	if (!atomic_inc_not_zero(&mm->mm_users))
+		return false;
+	spin_unlock(&mapping->i_mmap_lock);
+	down_write(&mm->mmap_sem);
+
+	/* There was a vma at mm, addr that needed to be revoked.
+	 * Look and see if there is still a vma there that needs
+	 * to be revoked.
+	 */
+	vma = find_vma(mm, addr);
+	if (vma->vm_file->f_mapping == mapping)
+		revoke_vma(vma);
+
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+	spin_lock(&mapping->i_mmap_lock);
+	return true;
+}
+
+void revoke_mappings(struct address_space *mapping)
+{
+	/* Make any access to previously mapped pages trigger a SIGBUS,
+	 * and stop calling vm_ops methods.
+	 *
+	 * When revoke_mappings returns invocations of vm_ops->close
+	 * may still be in progress, but no invocations of any other
+	 * vm_ops methods will be.
+	 */
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+
+	spin_lock(&mapping->i_mmap_lock);
+
+restart_tree:
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX) {
+		if (revoke_mapping(mapping, vma->vm_mm, vma->vm_start))
+			goto restart_tree;
+	}
+
+restart_list:
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list) {
+		if (revoke_mapping(mapping, vma->vm_mm, vma->vm_start))
+			goto restart_list;
+	}
+
+	spin_unlock(&mapping->i_mmap_lock);
+}
+EXPORT_SYMBOL_GPL(revoke_mappings);
+
+static int __init revoke_init(void)
+{
+	int ret = 0;
+	revoked_filp = anon_inode_getfile("[revoked]", &revoked_fops, NULL,
+					  O_RDWR /* do flags matter here? */);
+	if (IS_ERR(revoked_filp))
+		ret = PTR_ERR(revoked_filp);
+	return ret;
+}
+module_init(revoke_init);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
