Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0NITi3h011064
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 13:29:44 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NITeU0066858
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 11:29:40 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NITdd0017116
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 11:29:39 -0700
Subject: [PATCH] Fix procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Wed, 23 Jan 2008 10:29:37 -0800
Message-Id: <1201112977.5443.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Al Viro <viro@ftp.linux.org.uk>, David Howells <dhowells@redhat.com>, William H Taber <wtaber@us.ibm.com>, William Cesar de Oliveira <owilliam@br.ibm.com>, Richard Kissel <rkissel@us.ibm.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

The kernel implements readlink of /proc/pid/exe by getting the file from the
first executable VMA. Then the path to the file is reconstructed and reported as
the result. While this method is often correct it does not always identify the
correct path.

Some applications may play games with the executable mappings. Al Viro mentioned
an example where the executable region is copied and subsequently unmapped.
In this case the kernel wanders down the VMA list to the next file-backed,
executable VMA -- which is not necessarily the destination of the copy. Worse,
any transformation of the executable could conceivably take place and the
symlink could be deceptive. In this case, since we can't be certain what is
being executed it might be better to simply "delete" the symlink.

Another scenario where the symlink might be broken includes some potential
implementations of checkpoint/restart. If restart is implemented as a loader
application then it will be reported in the symlink instead of the application
being restarted. This would break restarted Java applications for example
(see the java example below).

For executables on the stackable MVFS filesystem the current procfs methods for
implementing a task's exe symlink do not point to the correct file and
applications relying on the symlink fail (see the java example below).

So there are multiple ways in which a task's exe symlink in /proc can break
using the current VMA walk method.

This patch tries to address the case of running Java installed on an MVFS filesystem.
However the patch solves the problems with the symlink for more than just
MVFS.

Java uses the /proc/self/exe symlink to determine JAVAHOME by reading the link
and trimming the path. This breaks under MVFS because MVFS reorganizes
files and directories to enable versioning and stores these on a
filesystem lower in the "stack". This is further complicated by the need for
efficient IO because reads and mapping of the file must access the file
contents from the "lower" filesystem. The symlink points to the mapped/read
file and not the MVFS file. Because MVFS utilizes a different organization of
the files in the lower filesystem the symlink cannot be used to
correctly determine JAVAHOME. This could be a problem for any stacking
filesystem which reorganizes files and directories -- though I don't know of
another besides MVFS.

	Top FS (e.g. MVFS)		Lower FS (e.g. ext3)
	/foo/bar/jvm/bin/java		/qux/baz/java
	/foo/bar/jvm/lib		/bee/buzz

When the executable file is opened MVFS returns its own file struct.
When the MVFS file is subsequently mmap'd or read MVFS transforms the path to
/qux/baz/java, opens, and uses the contents of the lower filesystem's file
to satisfy the read or the mmap.

Since the bytes of the java executable are at /qux/baz/java, /proc/self/exe
points to /qux/baz/java instead of /foo/bar/jvm/bin/java. Hence JAVAHOME
points to the wrong directory and Java subsequently fails to find the files
it needs to run.

To solve the problem this patch changes the way that the kernel resolves a
task's exe symlink. Instead of walking the VMAs to find the first
executable file-backed VMA we store a reference to the exec'd file in the
mm_struct -- /foo/bar/jvm/bin/java in the example above.

That reference would prevent the filesystem holding the executable file from
being unmounted even if the VMA(s) were unmapped. So we track the number of VMAs
that mapped the executable file during exec. Then we drop the new reference on
exit or when the last such VMA is unmapped. This avoids pinning the filesystem.

A minor added benefit of this approach is we no longer need separate code to
offer this symlink on mmu-less systems.

Andrew, please consider this patch for inclusion in -mm.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---

Changelog:
	Added a counter to keep track of the number of "exec" VMAs
	Drop the exe_file reference when the last of the "exec" VMAs goes away
		(Requested by Al Viro)
		The nommu case is untested -- I don't have an mmu-less system
		to test this on.
	#ifdef proc fs portion of mm (requested by Andrew)
	Merged patch series into one patch -- avoids introducing point in series
		where file reference in mm_struct pins mountpoints
	Added MAP_EXECUTABLE to mapping in binfmt_flat -- needed this flag to help
		track exec'd file VMAs.

Changelog during RFC postings:
	Moved fput() calls out of areas holding task_lock
		(pointed out by Andrew Morton. see:
			http://lkml.org/lkml/2007/7/12/402)
	Moved the exe_file reference to the mm_struct from the task struct
		(suggested by Dave Hansen)
	Avoid pinning most mounted fs by dropping both file refs when the VMA is
		removed (problem pointed out by Al Viro. see:
				http://lkml.org/lkml/2007/7/12/398)

Testing:
	2.6.24-rc6-mm1 - compiles, boots, passes simple regression tests on x86,
		x86_64, and ppc64
	2.6.24-rc8-mm1 - compile tested only -- issues with booting test machines
		on unpatched 2.6.24-rc8-mm1 with hotfixes. Will keep trying to get
		these to boot and complete testing.
	nommu-only code paths are untested -- lacking access to nommu system

 fs/binfmt_flat.c          |    3 +
 fs/exec.c                 |    2 +
 fs/proc/base.c            |   77 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/internal.h        |    1 
 fs/proc/task_mmu.c        |   34 --------------------
 fs/proc/task_nommu.c      |   34 --------------------
 include/linux/init_task.h |    8 ++++
 include/linux/mm.h        |   22 +++++++++++++
 include/linux/mm_types.h  |    7 ++++
 include/linux/proc_fs.h   |   14 +++++++-
 kernel/fork.c             |    3 +
 mm/mmap.c                 |   22 ++++++++++---
 mm/nommu.c                |   15 +++++++-
 13 files changed, 164 insertions(+), 78 deletions(-)

Index: linux-2.6.24-rc8-mm1-hf/fs/exec.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/exec.c
+++ linux-2.6.24-rc8-mm1-hf/fs/exec.c
@@ -1022,10 +1022,12 @@ int flush_old_exec(struct linux_binprm *
 	current->self_exec_id++;
 			
 	flush_signal_handlers(current, 0);
 	flush_old_files(current->files);
 
+	get_file(bprm->file);
+	set_mm_exe_file(current->mm, bprm->file);
 	return 0;
 
 mmap_failed:
 	reset_files_struct(current, files);
 out:
Index: linux-2.6.24-rc8-mm1-hf/fs/proc/base.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/proc/base.c
+++ linux-2.6.24-rc8-mm1-hf/fs/proc/base.c
@@ -1084,10 +1084,87 @@ static const struct file_operations proc
 	.release	= single_release,
 };
 
 #endif
 
+/* We added or removed a vma mapping the executable. The vmas are only mapped
+ * during exec and are not mapped with the mmap system call.
+ * Callers must _not_ hold the mm's exe_file_lock for these */
+void added_exe_file_vma(struct mm_struct *mm)
+{
+	spin_lock(&mm->exe_file_lock);
+	mm->num_exe_file_vmas++;
+	spin_unlock(&mm->exe_file_lock);
+}
+
+void removed_exe_file_vma(struct mm_struct *mm)
+{
+	struct file *exe_file = NULL;
+
+	spin_lock(&mm->exe_file_lock);
+	mm->num_exe_file_vmas--;
+	if (mm->num_exe_file_vmas == 0) {
+		exe_file = mm->exe_file;
+		mm->exe_file = NULL;
+	}
+	spin_unlock(&mm->exe_file_lock);
+
+	if (exe_file)
+		fput(exe_file);
+}
+
+/* Takes a reference to new_exe_file from caller -- does not get a new
+ * reference; only puts old ones */
+void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
+{
+	struct file *old_exe_file;
+
+	spin_lock(&mm->exe_file_lock);
+	old_exe_file = mm->exe_file;
+	mm->exe_file = new_exe_file;
+	mm->num_exe_file_vmas = 0;
+	spin_unlock(&mm->exe_file_lock);
+	if (old_exe_file)
+		fput(old_exe_file);
+}
+
+struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	struct file *exe_file;
+
+	spin_lock(&mm->exe_file_lock);
+	exe_file = mm->exe_file;
+	if (exe_file)
+		get_file(exe_file);
+	spin_unlock(&mm->exe_file_lock);
+	return exe_file;
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
 
Index: linux-2.6.24-rc8-mm1-hf/kernel/fork.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/kernel/fork.c
+++ linux-2.6.24-rc8-mm1-hf/kernel/fork.c
@@ -356,10 +356,11 @@ static struct mm_struct * mm_init(struct
 	rwlock_init(&mm->ioctx_list_lock);
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_cgroup(mm, p);
+	init_mm_exe_file(mm);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
 	}
@@ -407,10 +408,11 @@ void mmput(struct mm_struct *mm)
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
@@ -523,10 +525,11 @@ static struct mm_struct *dup_mm(struct t
 
 	err = dup_mmap(mm, oldmm);
 	if (err)
 		goto free_pt;
 
+	mm->exe_file = get_mm_exe_file(oldmm);
 	mm->hiwater_rss = get_mm_rss(mm);
 	mm->hiwater_vm = mm->total_vm;
 
 	return mm;
 
Index: linux-2.6.24-rc8-mm1-hf/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/proc/task_mmu.c
+++ linux-2.6.24-rc8-mm1-hf/fs/proc/task_mmu.c
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
Index: linux-2.6.24-rc8-mm1-hf/include/linux/proc_fs.h
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/include/linux/proc_fs.h
+++ linux-2.6.24-rc8-mm1-hf/include/linux/proc_fs.h
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
@@ -207,10 +206,15 @@ extern struct proc_dir_entry *proc_net_f
 	const char *name, mode_t mode, const struct file_operations *fops);
 extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
+/* While the {get|set}_mm_exe_file functions are for mm_structs, they are
+ * only needed to implement /proc/<pid>|self/exe so we define them here. */
+extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern struct file *get_mm_exe_file(struct mm_struct *mm);
+
 #else
 
 #define proc_root_driver NULL
 #define proc_bus NULL
 
@@ -256,10 +260,18 @@ static inline int pid_ns_prepare_proc(st
 
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
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
 static inline void kclist_add(struct kcore_list *new, void *addr, size_t size)
 {
Index: linux-2.6.24-rc8-mm1-hf/mm/mmap.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/mm/mmap.c
+++ linux-2.6.24-rc8-mm1-hf/mm/mmap.c
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
@@ -1818,12 +1826,15 @@ int split_vma(struct mm_struct * mm, str
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
@@ -2136,12 +2147,15 @@ struct vm_area_struct *copy_vma(struct v
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
Index: linux-2.6.24-rc8-mm1-hf/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/proc/task_nommu.c
+++ linux-2.6.24-rc8-mm1-hf/fs/proc/task_nommu.c
@@ -102,44 +102,10 @@ int task_statm(struct mm_struct *mm, int
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
Index: linux-2.6.24-rc8-mm1-hf/include/linux/mm_types.h
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/include/linux/mm_types.h
+++ linux-2.6.24-rc8-mm1-hf/include/linux/mm_types.h
@@ -231,8 +231,15 @@ struct mm_struct {
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
+
+#ifdef CONFIG_PROC_FS
+	/* store ref to file /proc/<pid>/exe symlink points to */
+	spinlock_t exe_file_lock;
+	struct file *exe_file;
+	unsigned long num_exe_file_vmas;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6.24-rc8-mm1-hf/fs/proc/internal.h
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/proc/internal.h
+++ linux-2.6.24-rc8-mm1-hf/fs/proc/internal.h
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
Index: linux-2.6.24-rc8-mm1-hf/fs/binfmt_flat.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/fs/binfmt_flat.c
+++ linux-2.6.24-rc8-mm1-hf/fs/binfmt_flat.c
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
Index: linux-2.6.24-rc8-mm1-hf/include/linux/init_task.h
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/include/linux/init_task.h
+++ linux-2.6.24-rc8-mm1-hf/include/linux/init_task.h
@@ -44,20 +44,28 @@
 	.ctx_lock	= __SPIN_LOCK_UNLOCKED(name.ctx_lock), \
 	.reqs_active	= 0U,				\
 	.max_reqs	= ~0U,				\
 }
 
+#ifdef CONFIG_PROC_FS
+#define INIT_MM_EXE_FILE(name) \
+	.exe_file_lock	= __SPIN_LOCK_UNLOCKED(name.exe_file_lock),
+#else
+#define INIT_MM_EXE_FILE(name)
+#endif
+
 #define INIT_MM(name) \
 {			 					\
 	.mm_rb		= RB_ROOT,				\
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
 	.mmap_sem	= __RWSEM_INITIALIZER(name.mmap_sem),	\
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
+	INIT_MM_EXE_FILE(name)					\
 }
 
 #define INIT_SIGNALS(sig) {						\
 	.count		= ATOMIC_INIT(1), 				\
 	.wait_chldexit	= __WAIT_QUEUE_HEAD_INITIALIZER(sig.wait_chldexit),\
Index: linux-2.6.24-rc8-mm1-hf/mm/nommu.c
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/mm/nommu.c
+++ linux-2.6.24-rc8-mm1-hf/mm/nommu.c
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
Index: linux-2.6.24-rc8-mm1-hf/include/linux/mm.h
===================================================================
--- linux-2.6.24-rc8-mm1-hf.orig/include/linux/mm.h
+++ linux-2.6.24-rc8-mm1-hf/include/linux/mm.h
@@ -1026,10 +1026,32 @@ extern void __vma_link_rb(struct mm_stru
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
+
+#ifdef CONFIG_PROC_FS
+static inline void init_mm_exe_file(struct mm_struct *mm)
+{
+	/* The exe_file field itself is already correctly set at this point */
+	spin_lock_init(&mm->exe_file_lock);
+}
+
+/* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
+extern void added_exe_file_vma(struct mm_struct *mm);
+extern void removed_exe_file_vma(struct mm_struct *mm);
+#else
+static inline void init_mm_exe_file(struct mm_struct *mm)
+{}
+
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
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
