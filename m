Date: Tue, 18 Oct 2005 17:58:29 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] Ray's sys_migrate_pages implementation using swap based page
 migration
Message-ID: <Pine.LNX.4.62.0510181756070.9556@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lee.schermerhorn@hp.com
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

This is the original API proposed by Ray Bryant in his posts during the
first half of 2005 on linux-mm@kvack.org and linux-kernel@vger.kernel.org.

The intend of sys_migrate is to migrate memory of a process. A process may have
migrated to another node f.e. by the scheduler. Memory was allocated 
optimally for the prior context. sys_migrate_pages allows to shift the 
memory to the new node.

sys_migrate_pages is also useful if the processes available memory nodes have
changed through cpuset operations to manually move the processes memory. Paul
Jackson is working on an automated mechanism that will allow an automatic
migration if the cpuset of a process is changed. However, a user may decide
to manually control the migration.

This implementation is put into the policy layer since it uses concepts and
functions that are also needed for mbind and friends. The patch also provides
a do_migrate_pages function that may be useful for cpusets to automatically move
memory. sys_migrate_pages does not modify policies in contrast to Ray's implementation.

There is a slight change to check_range(): If a pagelist is specified then it does
not check for continuity of addresses.

The current code here is based on the swap based page migration capability and thus
not able to preserve the physical layout relative to it containing nodeset (which
may be a cpuset). When direct page migration becomes available then the
implementation needs to be changed to do a isomorphic move of pages between different
nodesets. The current implementation simply evicts all pages in source
nodeset that are not in the target nodeset.

This post is an RFC and does only contain the necessary definitions for IA64.
The final patch will contain additional definitions for other arches.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/mempolicy.c	2005-10-18 09:14:28.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/mempolicy.c	2005-10-18 17:54:16.000000000 -0700
@@ -304,10 +304,13 @@ check_range(struct mm_struct *mm, unsign
 		return ERR_PTR(-EACCES);
 	prev = NULL;
 	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
-		if (!vma->vm_next && vma->vm_end < end)
-			return ERR_PTR(-EFAULT);
-		if (prev && prev->vm_end < vma->vm_start)
-			return ERR_PTR(-EFAULT);
+		if (!pagelist) {
+			/* Continuity checks */
+			if (!vma->vm_next && vma->vm_end < end)
+				return ERR_PTR(-EFAULT);
+			if (prev && prev->vm_end < vma->vm_start)
+				return ERR_PTR(-EFAULT);
+		}
 		if (!is_vm_hugetlb_page(vma) &&
 		    ((flags & MPOL_MF_STRICT) ||
 		     ((flags & MPOL_MF_MOVE) && vma_migratable(vma))
@@ -558,6 +561,36 @@ long do_get_mempolicy(int *policy, nodem
 }
 
 /*
+ * For now migrate_pages simply swaps out the pages from nodes that are in
+ * the source set but not in the target set. In the future, we would
+ * want a function that moves pages between the two nodesets in such
+ * a way as to preserve the physical layout as much as possible.
+ *
+ * Returns the number of page that could not be moved.
+ */
+int do_migrate_pages(struct mm_struct *mm,
+	nodemask_t *from_nodes, nodemask_t *to_nodes)
+{
+	LIST_HEAD(pagelist);
+	int count = 0;
+	nodemask_t nodes;
+
+	nodes_andnot(nodes, *from_nodes, *to_nodes);
+	nodes_complement(nodes, nodes);
+
+	down_read(&mm->mmap_sem);
+	check_range(mm, mm->mmap->vm_start, TASK_SIZE -1, &nodes,
+			MPOL_MF_MOVE, &pagelist);
+	if (!list_empty(&pagelist)) {
+		swapout_pages(&pagelist);
+		if (!list_empty(&pagelist))
+			count = putback_lru_pages(&pagelist);
+	}
+	up_read(&mm->mmap_sem);
+	return count;
+}
+
+/*
  * User space interface with variable sized bitmaps for nodelists.
  */
 
@@ -651,6 +684,44 @@ asmlinkage long sys_set_mempolicy(int mo
 	return do_set_mempolicy(mode, &nodes);
 }
 
+asmlinkage long sys_migrate_pages(pid_t pid, int maxnode,
+		unsigned long __user *old_nodes,
+		unsigned long __user *new_nodes)
+{
+	struct mm_struct *mm;
+	struct task_struct *task;
+	nodemask_t old;
+	nodemask_t new;
+	int err;
+
+	err = get_nodes(&old, old_nodes, maxnode);
+	if (err)
+		return err;
+
+	err = get_nodes(&new, new_nodes, maxnode);
+	if (err)
+		return err;
+
+	/* Find the mm_struct */
+	read_lock(&tasklist_lock);
+	task = pid ? find_task_by_pid(pid) : current;
+	if (!task) {
+		read_unlock(&tasklist_lock);
+		return -ESRCH;
+	}
+	mm = get_task_mm(task);
+	read_unlock(&tasklist_lock);
+
+	if (!mm)
+		return -EINVAL;
+
+	err = do_migrate_pages(mm, &old, &new);
+
+	mmput(mm);
+	return err;
+}
+
+
 /* Retrieve NUMA policy */
 asmlinkage long sys_get_mempolicy(int __user *policy,
 				unsigned long __user *nmask,
Index: linux-2.6.14-rc4-mm1/kernel/sys_ni.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/kernel/sys_ni.c	2005-10-10 18:19:19.000000000 -0700
+++ linux-2.6.14-rc4-mm1/kernel/sys_ni.c	2005-10-18 10:14:19.000000000 -0700
@@ -82,6 +82,7 @@ cond_syscall(compat_sys_socketcall);
 cond_syscall(sys_inotify_init);
 cond_syscall(sys_inotify_add_watch);
 cond_syscall(sys_inotify_rm_watch);
+cond_syscall(sys_migrate_pages);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
Index: linux-2.6.14-rc4-mm1/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.14-rc4-mm1.orig/arch/ia64/kernel/entry.S	2005-10-10 18:19:19.000000000 -0700
+++ linux-2.6.14-rc4-mm1/arch/ia64/kernel/entry.S	2005-10-18 10:14:19.000000000 -0700
@@ -1600,5 +1600,6 @@ sys_call_table:
 	data8 sys_inotify_init
 	data8 sys_inotify_add_watch
 	data8 sys_inotify_rm_watch
+	data8 sys_migrate_pages
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
Index: linux-2.6.14-rc4-mm1/include/asm-ia64/unistd.h
===================================================================
--- linux-2.6.14-rc4-mm1.orig/include/asm-ia64/unistd.h	2005-10-17 10:24:22.000000000 -0700
+++ linux-2.6.14-rc4-mm1/include/asm-ia64/unistd.h	2005-10-18 10:14:19.000000000 -0700
@@ -269,12 +269,12 @@
 #define __NR_inotify_init		1277
 #define __NR_inotify_add_watch		1278
 #define __NR_inotify_rm_watch		1279
-
+#define __NR_migrate_pages		1280
 #ifdef __KERNEL__
 
 #include <linux/config.h>
 
-#define NR_syscalls			256 /* length of syscall table */
+#define NR_syscalls			257 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
