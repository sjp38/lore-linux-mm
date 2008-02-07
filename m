Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m171iVBP032604
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 20:44:31 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m171iVIx389040
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 20:44:31 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m171iVfD005755
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 20:44:31 -0500
Subject: [PATCH] procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Wed, 06 Feb 2008 17:44:29 -0800
Message-Id: <1202348669.9062.271.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

The kernel implements readlink of /proc/pid/exe by getting the file from the
first executable VMA. Then the path to the file is reconstructed and reported as
the result. 

Because of the VMA walk the code is slightly different on nommu systems. This
patch avoids separate /proc/pid/exe code on nommu systems. Instead of walking
the VMAs to find the first executable file-backed VMA we store a reference to
the exec'd file in the mm_struct.

That reference would prevent the filesystem holding the executable file from
being unmounted even after unmapping the VMAs. So we track the number of 
VM_EXECUTABLE VMAs and drop the new reference when the last one is unmapped.
This avoids pinning the mounted filesystem.

Andrew, these are the updates I promised. Please consider this patch for
inclusion in -mm.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>
Cc: David Howells <dhowells@redhat.com>
Cc:"Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Hugh Dickins <hugh@veritas.com>
---

 fs/binfmt_flat.c         |    3 +
 fs/exec.c                |    3 +
 fs/proc/base.c           |   73 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/internal.h       |    1 
 fs/proc/task_mmu.c       |   34 ---------------------
 fs/proc/task_nommu.c     |   34 ---------------------
 include/linux/mm.h       |   13 ++++++++
 include/linux/mm_types.h |    6 +++
 include/linux/proc_fs.h  |   20 ++++++++++++
 kernel/fork.c            |    2 +
 mm/mmap.c                |   24 ++++++++++++---
 mm/nommu.c               |   15 +++++++--
 12 files changed, 150 insertions(+), 78 deletions(-)

Changelog:
v2
	Removed spin lock -- reused mmap. Saved about 14 lines of code.
	Fixed CONFIG_PROC_FS=n compile breakage in the fork path
	Fixed struct file leak in fork path without CONFIG_PROC_FS
		by adding get_file() to set_mm_exe_file()
	Moved set_mm_exe_file() to prevent a race where tasks
		reading the symlink could see an empty/nonexistent link.
	Confirmed that sys_remap_file_pages() isn't a problem.
	Fixed an fput() without the necessary removed_exe_file_vma() check
	Successfully retested on x86_64 with 2.6.24-mm1 + hotfixes
	Trimmed irrelevant parts of the description
v1
	Added a counter to keep track of the number of "exec" VMAs
	Drop the exe_file reference when the last of the "exec" VMAs goes away
		The nommu case is untested -- I don't have an mmu-less system
		to test this on.

v0.5:
	Moved fput() calls out of areas holding task_lock
		(pointed out by Andrew Morton. see:
			http://lkml.org/lkml/2007/7/12/402)
	Moved the exe_file reference to the mm_struct from the task struct
		(suggested by Dave Hansen)
	Avoid pinning most mounted fs by dropping both file refs when the VMA is
		removed (problem pointed out by Al Viro. see:
				http://lkml.org/lkml/2007/7/12/398)

Index: linux-2.6.24/fs/binfmt_flat.c
===================================================================
--- linux-2.6.24.orig/fs/binfmt_flat.c
+++ linux-2.6.24/fs/binfmt_flat.c
@@ -529,11 +529,12 @@ static int load_flat_file(struct linux_b
 		 * really care
 		 */
 		DBG_FLT("BINFMT_FLAT: ROM mapping of file (we hope)\n");
 
 		down_write(&current->mm->mmap_sem);
-		textpos = do_mmap(bprm->file, 0, text_len, PROT_READ|PROT_EXEC, MAP_PRIVATE, 0);
+		textpos = do_mmap(bprm->file, 0, text_len, PROT_READ|PROT_EXEC,
+				  MAP_PRIVATE|MAP_EXECUTABLE, 0);
 		up_write(&current->mm->mmap_sem);
 		if (!textpos  || textpos >= (unsigned long) -4096) {
 			if (!textpos)
 				textpos = (unsigned long) -ENOMEM;
 			printk("Unable to mmap process text, errno %d\n", (int)-textpos);
Index: linux-2.6.24/fs/exec.c
===================================================================
--- linux-2.6.24.orig/fs/exec.c
+++ linux-2.6.24/fs/exec.c
@@ -963,10 +963,13 @@ int flush_old_exec(struct linux_binprm *
 	 */
 	files = current->files;		/* refcounted so safe to hold */
 	retval = unshare_files();
 	if (retval)
 		goto out;
+
+	set_mm_exe_file(bprm->mm, bprm->file);
+
 	/*
 	 * Release all of the old mmap stuff
 	 */
 	retval = exec_mmap(bprm->mm);
 	if (retval)
Index: linux-2.6.24/fs/proc/base.c
===================================================================
--- linux-2.6.24.orig/fs/proc/base.c
+++ linux-2.6.24/fs/proc/base.c
@@ -1145,10 +1145,83 @@ static const struct file_operations proc
 	.release	= single_release,
 };
 
 #endif
 
+/* We added or removed a vma mapping the executable. The vmas are only mapped
+ * during exec and are not mapped with the mmap system call.
+ * Callers must hold the mm's mmap_sem for these */
+void added_exe_file_vma(struct mm_struct *mm)
+{
+	mm->num_exe_file_vmas++;
+}
+
+void removed_exe_file_vma(struct mm_struct *mm)
+{
+	mm->num_exe_file_vmas--;
+	if ((mm->num_exe_file_vmas == 0) && mm->exe_file){
+		fput(mm->exe_file);
+		mm->exe_file = NULL;
+	}
+
+}
+
+void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
+{
+	if (new_exe_file)
+		get_file(new_exe_file);
+	if (mm->exe_file)
+		fput(mm->exe_file);
+	mm->exe_file = new_exe_file;
+	mm->num_exe_file_vmas = 0;
+}
+
+struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	struct file *exe_file;
+
+	/* We need mmap_sem to protect against races with removal of
+	 * VM_EXECUTABLE vmas */
+	down_read(&mm->mmap_sem);
+	exe_file = mm->exe_file;
+	if (exe_file)
+		get_file(exe_file);
+	up_read(&mm->mmap_sem);
+	return exe_file;
+}
+
+void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
+{
+	/* It's safe to write the exe_file pointer without exe_file_lock because
+	 * this is called during fork when the task is not yet in /proc */
+	newmm->exe_file = get_mm_exe_file(oldmm);
+}
+
+static int proc_exe_link(struct inode *inode, struct path *exe_path)
+{
+	struct task_struct *task;
+	struct mm_struct *mm;
+	struct file *exe_file;
+
+	task = get_proc_task(inode);
+	if (!task)
+		return -ENOENT;
+	mm = get_task_mm(task);
+	put_task_struct(task);
+	if (!mm)
+		return -ENOENT;
+	exe_file = get_mm_exe_file(mm);
+	mmput(mm);
+	if (exe_file) {
+		*exe_path = exe_file->f_path;
+		path_get(&exe_file->f_path);
+		fput(exe_file);
+		return 0;
+	} else
+		return -ENOENT;
+}
+
 static void *proc_pid_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode = dentry->d_inode;
 	int error = -EACCES;
 
Index: linux-2.6.24/fs/proc/internal.h
===================================================================
--- linux-2.6.24.orig/fs/proc/internal.h
+++ linux-2.6.24/fs/proc/internal.h
@@ -46,11 +46,10 @@ extern int nommu_vma_show(struct seq_fil
 
 extern int maps_protect;
 
 extern void create_seq_entry(char *name, mode_t mode,
 				const struct file_operations *f);
-extern int proc_exe_link(struct inode *, struct path *);
 extern int proc_tid_stat(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern int proc_tgid_stat(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
Index: linux-2.6.24/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.24.orig/fs/proc/task_mmu.c
+++ linux-2.6.24/fs/proc/task_mmu.c
@@ -73,44 +73,10 @@ int task_statm(struct mm_struct *mm, int
 	*data = mm->total_vm - mm->shared_vm;
 	*resident = *shared + get_mm_counter(mm, anon_rss);
 	return mm->total_vm;
 }
 
-int proc_exe_link(struct inode *inode, struct path *path)
-{
-	struct vm_area_struct * vma;
-	int result = -ENOENT;
-	struct task_struct *task = get_proc_task(inode);
-	struct mm_struct * mm = NULL;
-
-	if (task) {
-		mm = get_task_mm(task);
-		put_task_struct(task);
-	}
-	if (!mm)
-		goto out;
-	down_read(&mm->mmap_sem);
-
-	vma = mm->mmap;
-	while (vma) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
-			break;
-		vma = vma->vm_next;
-	}
-
-	if (vma) {
-		*path = vma->vm_file->f_path;
-		path_get(&vma->vm_file->f_path);
-		result = 0;
-	}
-
-	up_read(&mm->mmap_sem);
-	mmput(mm);
-out:
-	return result;
-}
-
 static void pad_len_spaces(struct seq_file *m, int len)
 {
 	len = 25 + sizeof(void*) * 6 - len;
 	if (len < 1)
 		len = 1;
Index: linux-2.6.24/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.24.orig/fs/proc/task_nommu.c
+++ linux-2.6.24/fs/proc/task_nommu.c
@@ -101,44 +101,10 @@ int task_statm(struct mm_struct *mm, int
 	up_read(&mm->mmap_sem);
 	*resident = size;
 	return size;
 }
 
-int proc_exe_link(struct inode *inode, struct path *path)
-{
-	struct vm_list_struct *vml;
-	struct vm_area_struct *vma;
-	struct task_struct *task = get_proc_task(inode);
-	struct mm_struct *mm = get_task_mm(task);
-	int result = -ENOENT;
-
-	if (!mm)
-		goto out;
-	down_read(&mm->mmap_sem);
-
-	vml = mm->context.vmlist;
-	vma = NULL;
-	while (vml) {
-		if ((vml->vma->vm_flags & VM_EXECUTABLE) && vml->vma->vm_file) {
-			vma = vml->vma;
-			break;
-		}
-		vml = vml->next;
-	}
-
-	if (vma) {
-		*path = vma->vm_file->f_path;
-		path_get(&vma->vm_file->f_path);
-		result = 0;
-	}
-
-	up_read(&mm->mmap_sem);
-	mmput(mm);
-out:
-	return result;
-}
-
 /*
  * display mapping lines for a particular process's /proc/pid/maps
  */
 static int show_map(struct seq_file *m, void *_vml)
 {
Index: linux-2.6.24/include/linux/mm.h
===================================================================
--- linux-2.6.24.orig/include/linux/mm.h
+++ linux-2.6.24/include/linux/mm.h
@@ -1014,10 +1014,23 @@ extern void __vma_link_rb(struct mm_stru
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
+
+#ifdef CONFIG_PROC_FS
+/* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
+extern void added_exe_file_vma(struct mm_struct *mm);
+extern void removed_exe_file_vma(struct mm_struct *mm);
+#else
+static inline void added_exe_file_vma(struct mm_struct *mm)
+{}
+
+static inline void removed_exe_file_vma(struct mm_struct *mm)
+{}
+#endif /* CONFIG_PROC_FS */
+
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
Index: linux-2.6.24/include/linux/mm_types.h
===================================================================
--- linux-2.6.24.orig/include/linux/mm_types.h
+++ linux-2.6.24/include/linux/mm_types.h
@@ -231,8 +231,14 @@ struct mm_struct {
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
+
+#ifdef CONFIG_PROC_FS
+	/* store ref to file /proc/<pid>/exe symlink points to */
+	struct file *exe_file;
+	unsigned long num_exe_file_vmas;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6.24/include/linux/proc_fs.h
===================================================================
--- linux-2.6.24.orig/include/linux/proc_fs.h
+++ linux-2.6.24/include/linux/proc_fs.h
@@ -7,11 +7,10 @@
 #include <linux/magic.h>
 #include <asm/atomic.h>
 
 struct net;
 struct completion;
-
 /*
  * The proc filesystem constants/structures
  */
 
 /*
@@ -207,10 +206,16 @@ extern struct proc_dir_entry *proc_net_f
 	const char *name, mode_t mode, const struct file_operations *fops);
 extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
+/* While the {get|set|dup}_mm_exe_file functions are for mm_structs, they are
+ * only needed to implement /proc/<pid>|self/exe so we define them here. */
+extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern struct file *get_mm_exe_file(struct mm_struct *mm);
+extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
+
 #else
 
 #define proc_root_driver NULL
 #define proc_bus NULL
 
@@ -256,10 +261,23 @@ static inline int pid_ns_prepare_proc(st
 
 static inline void pid_ns_release_proc(struct pid_namespace *ns)
 {
 }
 
+static inline void set_mm_exe_file(struct mm_struct *mm,
+				   struct file *new_exe_file)
+{}
+
+static inline struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	return NULL;
+}
+
+static inline void dup_mm_exe_file(struct mm_struct *oldmm,
+	       			   struct mm_struct *newmm)
+{}
+
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
 static inline void kclist_add(struct kcore_list *new, void *addr, size_t size)
 {
Index: linux-2.6.24/kernel/fork.c
===================================================================
--- linux-2.6.24.orig/kernel/fork.c
+++ linux-2.6.24/kernel/fork.c
@@ -408,10 +408,11 @@ void mmput(struct mm_struct *mm)
 	might_sleep();
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
 		exit_mmap(mm);
+		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
 			spin_lock(&mmlist_lock);
 			list_del(&mm->mmlist);
 			spin_unlock(&mmlist_lock);
 		}
@@ -524,10 +525,11 @@ static struct mm_struct *dup_mm(struct t
 
 	err = dup_mmap(mm, oldmm);
 	if (err)
 		goto free_pt;
 
+	dup_mm_exe_file(oldmm, mm);
 	mm->hiwater_rss = get_mm_rss(mm);
 	mm->hiwater_vm = mm->total_vm;
 
 	return mm;
 
Index: linux-2.6.24/mm/mmap.c
===================================================================
--- linux-2.6.24.orig/mm/mmap.c
+++ linux-2.6.24/mm/mmap.c
@@ -228,12 +228,15 @@ static struct vm_area_struct *remove_vma
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file)
+	if (vma->vm_file) {
 		fput(vma->vm_file);
+		if (vma->vm_flags & VM_EXECUTABLE)
+			removed_exe_file_vma(vma->vm_mm);
+	}
 	mpol_free(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
 }
 
@@ -621,12 +624,15 @@ again:			remove_next = 1 + (end > next->
 		spin_unlock(&anon_vma->lock);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
 	if (remove_next) {
-		if (file)
+		if (file) {
 			fput(file);
+			if (next->vm_flags & VM_EXECUTABLE)
+				removed_exe_file_vma(mm);
+		}
 		mm->map_count--;
 		mpol_free(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -1153,10 +1159,12 @@ munmap_back:
 		vma->vm_file = file;
 		get_file(file);
 		error = file->f_op->mmap(file, vma);
 		if (error)
 			goto unmap_and_free_vma;
+		if (vm_flags & VM_EXECUTABLE)
+			added_exe_file_vma(mm);
 	} else if (vm_flags & VM_SHARED) {
 		error = shmem_zero_setup(vma);
 		if (error)
 			goto free_vma;
 	}
@@ -1190,10 +1198,12 @@ munmap_back:
 	} else {
 		if (file) {
 			if (correct_wcount)
 				atomic_inc(&inode->i_writecount);
 			fput(file);
+			if (vm_flags & VM_EXECUTABLE)
+				removed_exe_file_vma(mm);
 		}
 		mpol_free(vma_policy(vma));
 		kmem_cache_free(vm_area_cachep, vma);
 	}
 out:	
@@ -1818,12 +1828,15 @@ int split_vma(struct mm_struct * mm, str
 		kmem_cache_free(vm_area_cachep, new);
 		return PTR_ERR(pol);
 	}
 	vma_set_policy(new, pol);
 
-	if (new->vm_file)
+	if (new->vm_file) {
 		get_file(new->vm_file);
+		if (vma->vm_flags & VM_EXECUTABLE)
+			added_exe_file_vma(mm);
+	}
 
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
 
 	if (new_below)
@@ -2136,12 +2149,15 @@ struct vm_area_struct *copy_vma(struct v
 			}
 			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
-			if (new_vma->vm_file)
+			if (new_vma->vm_file) {
 				get_file(new_vma->vm_file);
+				if (vma->vm_flags & VM_EXECUTABLE)
+					added_exe_file_vma(mm);
+			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
 		}
 	}
Index: linux-2.6.24/mm/nommu.c
===================================================================
--- linux-2.6.24.orig/mm/nommu.c
+++ linux-2.6.24/mm/nommu.c
@@ -960,12 +960,15 @@ unsigned long do_mmap_pgoff(struct file 
 	if (!vma)
 		goto error_getting_vma;
 
 	INIT_LIST_HEAD(&vma->anon_vma_node);
 	atomic_set(&vma->vm_usage, 1);
-	if (file)
+	if (file) {
 		get_file(file);
+		if (vm_flags & VM_EXECUTABLE)
+			added_exe_file_vma(mm);
+	}
 	vma->vm_file	= file;
 	vma->vm_flags	= vm_flags;
 	vma->vm_start	= addr;
 	vma->vm_end	= addr + len;
 	vma->vm_pgoff	= pgoff;
@@ -1016,12 +1019,15 @@ unsigned long do_mmap_pgoff(struct file 
 
  error:
 	up_write(&nommu_vma_sem);
 	kfree(vml);
 	if (vma) {
-		if (vma->vm_file)
+		if (vma->vm_file) {
 			fput(vma->vm_file);
+			if (vma->vm_flags & VM_EXECUTABLE)
+				removed_exe_file_vma(vma->vm_mm);
+		}
 		kfree(vma);
 	}
 	return ret;
 
  sharing_violation:
@@ -1069,12 +1075,15 @@ static void put_vma(struct vm_area_struc
 			}
 
 			realalloc -= kobjsize(vma);
 			askedalloc -= sizeof(*vma);
 
-			if (vma->vm_file)
+			if (vma->vm_file) {
 				fput(vma->vm_file);
+				if (vma->vm_flags & VM_EXECUTABLE)
+					removed_exe_file_vma(vma->vm_mm);
+			}
 			kfree(vma);
 		}
 
 		up_write(&nommu_vma_sem);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
