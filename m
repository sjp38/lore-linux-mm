Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA14fPr2026773
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:25 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA14fO5P104162
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA14fOff010879
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Message-Id: <20071101044124.209949000@us.ibm.com>
References: <20071101033508.720885000@us.ibm.com>
Date: Wed, 31 Oct 2007 20:35:09 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 1/3] [RFC][PATCH] Fix procfs task exe symlinks
Content-Disposition: inline; filename=mm-cache-exe-struct-file
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ftp.linux.org.uk>, Dave Hansen <haveblue@us.ibm.com>
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

I am trying to address the case of running Java installed on an MVFS filesystem.
However the patch solves the problems with the symlink for more than just
MVFS hence I think it's worth posting for comments. Furthermore, if there are
no objections to the direction of the patch I plan on making it acceptable for
eventual inclusion.

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

One question that came up while solving this problem was trying to determine
what /proc/self/exe should point to. The common case is easy enough but does
not seem to unambiguously define /proc/self/exe. When discussing the idea with
Dave Hansen off list we ran through some possible "definitions" such as:

"what's running"
"used to start"
"last exec"

I even went back to earlier versions of the kernel and found an implementation
similar to what an earlier posting of this patch proposed (see Changelog below).
However my search revealed no comments elaborating on why it was changed
so it didn't reveal much useful information.

For now I've chosen "last exec". I'd like to know if this doesn't fit with
what anyone would expect and/or if there's a better definition.

To solve the problem this patch changes the way that the kernel resolves a
task's exe symlink. Instead of walking the VMAs to find the first
executable file-backed VMA we store a reference to the exec'd file in the
mm_struct -- /foo/bar/jvm/bin/java in the example above.

That reference would prevent the filesystem holding the executable file from
being unmounted even if the VMA were unmapped. The first time we
remove a VMA mapping the same file we also drop the reference added by
this patch. This avoids pinning the mounted filesystem in all but the
stacking case. In the case where the open_exec() file and VMA file do not
match (e.g. MVFS) only lazy unmount will work.

The semi-independent reference also allows a future patch to make the symlink
writable which can fix the potential checkpoint/restart case I mentioned
earlier.

A minor added benefit of this approach is we no longer need separate code to
offer this symlink on mmu-less systems.

Dave Hansen suggested droppping the new reference only when the last VMA
of the original mapping is dropped. This requires alot more code but, at least
to me, makes more sense. 

I'm planning on working on Dave's suggestion next. That may require a new type
of VMA flag and a count of the VMAs referring to the file. To maintain them I'll
probably need to increment the count in split_vma() and decrement the count in
vma_merge().

	Alternative ideas on how to fix this would certainly be very nice to
hear since I've not been able to think of anything better and I'm not especially
pleased with this patch.

	This novel will get much shorter if/when this patch gets submitted
for inclusion :).

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ftp.linux.org.uk>
---
Changelog:
	Moved fput() calls out of areas holding task_lock
		(pointed out by Andrew Morton. see:
			http://lkml.org/lkml/2007/7/12/402)
	Moved the exe_file reference to the mm_struct from the task struct
		(suggested by Dave Hansen)
	Avoid pinning most mounted fs by dropping both file refs when the VMA is
		removed (problem pointed out by Al Viro. see:
				http://lkml.org/lkml/2007/7/12/398)

 fs/exec.c               |    2 ++
 fs/proc/base.c          |   25 +++++++++++++++++++++++++
 fs/proc/internal.h      |    1 -
 fs/proc/task_mmu.c      |   34 ----------------------------------
 fs/proc/task_nommu.c    |   34 ----------------------------------
 include/linux/proc_fs.h |   19 +++++++++++++++++++
 include/linux/sched.h   |    3 +++
 kernel/fork.c           |    3 +++
 mm/mmap.c               |   32 ++++++++++++++++++++++++++++++++
 9 files changed, 84 insertions(+), 69 deletions(-)

Index: linux-2.6.23/include/linux/sched.h
===================================================================
--- linux-2.6.23.orig/include/linux/sched.h
+++ linux-2.6.23/include/linux/sched.h
@@ -430,10 +430,13 @@ struct mm_struct {
 	struct completion *core_startup_done, core_done;
 
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+	/* store ref to file /proc/<pid>/exe symlink points to */
+	struct file *exe_file;
 };
 
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
Index: linux-2.6.23/fs/exec.c
===================================================================
--- linux-2.6.23.orig/fs/exec.c
+++ linux-2.6.23/fs/exec.c
@@ -1089,10 +1089,12 @@ int flush_old_exec(struct linux_binprm *
 	current->self_exec_id++;
 			
 	flush_signal_handlers(current, 0);
 	flush_old_files(current->files);
 
+	get_file(bprm->file);
+	set_mm_exe_file(current->mm, bprm->file);
 	return 0;
 
 mmap_failed:
 	reset_files_struct(current, files);
 out:
Index: linux-2.6.23/fs/proc/base.c
===================================================================
--- linux-2.6.23.orig/fs/proc/base.c
+++ linux-2.6.23/fs/proc/base.c
@@ -930,10 +930,35 @@ static const struct file_operations proc
 	.release	= single_release,
 };
 
 #endif
 
+static int proc_exe_link(struct inode *inode, struct dentry **dentry,
+			 struct vfsmount **mnt)
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
+		*mnt = mntget(exe_file->f_path.mnt);
+		*dentry = dget(exe_file->f_path.dentry);
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
 
Index: linux-2.6.23/kernel/fork.c
===================================================================
--- linux-2.6.23.orig/kernel/fork.c
+++ linux-2.6.23/kernel/fork.c
@@ -48,10 +48,11 @@
 #include <linux/freezer.h>
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
 #include <linux/tty.h>
+#include <linux/proc_fs.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -390,10 +391,11 @@ void mmput(struct mm_struct *mm)
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
@@ -506,10 +508,11 @@ static struct mm_struct *dup_mm(struct t
 
 	err = dup_mmap(mm, oldmm);
 	if (err)
 		goto free_pt;
 
+	mm->exe_file = get_mm_exe_file(oldmm);
 	mm->hiwater_rss = get_mm_rss(mm);
 	mm->hiwater_vm = mm->total_vm;
 
 	return mm;
 
Index: linux-2.6.23/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.23.orig/fs/proc/task_mmu.c
+++ linux-2.6.23/fs/proc/task_mmu.c
@@ -70,44 +70,10 @@ int task_statm(struct mm_struct *mm, int
 	*data = mm->total_vm - mm->shared_vm;
 	*resident = *shared + get_mm_counter(mm, anon_rss);
 	return mm->total_vm;
 }
 
-int proc_exe_link(struct inode *inode, struct dentry **dentry, struct vfsmount **mnt)
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
-		*mnt = mntget(vma->vm_file->f_path.mnt);
-		*dentry = dget(vma->vm_file->f_path.dentry);
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
Index: linux-2.6.23/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.23.orig/fs/proc/task_nommu.c
+++ linux-2.6.23/fs/proc/task_nommu.c
@@ -102,44 +102,10 @@ int task_statm(struct mm_struct *mm, int
 	up_read(&mm->mmap_sem);
 	*resident = size;
 	return size;
 }
 
-int proc_exe_link(struct inode *inode, struct dentry **dentry, struct vfsmount **mnt)
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
-		*mnt = mntget(vma->vm_file->f_path.mnt);
-		*dentry = dget(vma->vm_file->f_path.dentry);
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
Index: linux-2.6.23/fs/proc/internal.h
===================================================================
--- linux-2.6.23.orig/fs/proc/internal.h
+++ linux-2.6.23/fs/proc/internal.h
@@ -38,11 +38,10 @@ extern int nommu_vma_show(struct seq_fil
 #endif
 
 extern int maps_protect;
 
 extern void create_seq_entry(char *name, mode_t mode, const struct file_operations *f);
-extern int proc_exe_link(struct inode *, struct dentry **, struct vfsmount **);
 extern int proc_tid_stat(struct task_struct *,  char *);
 extern int proc_tgid_stat(struct task_struct *, char *);
 extern int proc_pid_status(struct task_struct *, char *);
 extern int proc_pid_statm(struct task_struct *, char *);
 
Index: linux-2.6.23/include/linux/proc_fs.h
===================================================================
--- linux-2.6.23.orig/include/linux/proc_fs.h
+++ linux-2.6.23/include/linux/proc_fs.h
@@ -211,10 +211,18 @@ static inline struct proc_dir_entry *pro
 static inline void proc_net_remove(const char *name)
 {
 	remove_proc_entry(name,proc_net);
 }
 
+/* While the foo_mm_exe_file accessor functions are for mm_structs, they are
+ * only needed to implement /proc/<pid>|self/exe so we define them here. */
+
+/* Takes a reference to new_exe_file from caller -- does not get a new
+ * reference; only puts old ones */
+extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern struct file *get_mm_exe_file(struct mm_struct *mm);
+
 #else
 
 #define proc_root_driver NULL
 #define proc_net NULL
 #define proc_bus NULL
@@ -246,10 +254,21 @@ struct tty_driver;
 static inline void proc_tty_register_driver(struct tty_driver *driver) {};
 static inline void proc_tty_unregister_driver(struct tty_driver *driver) {};
 
 extern struct proc_dir_entry proc_root;
 
+/* Takes a reference to new_exe_file from caller -- does not get a new
+ * reference; only puts old ones */
+static inline void set_mm_exe_file(struct mm_struct *mm,
+				   struct file *new_exe_file)
+{}
+
+static inline struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
 static inline void kclist_add(struct kcore_list *new, void *addr, size_t size)
 {
Index: linux-2.6.23/mm/mmap.c
===================================================================
--- linux-2.6.23.orig/mm/mmap.c
+++ linux-2.6.23/mm/mmap.c
@@ -1699,10 +1699,38 @@ find_extend_vma(struct mm_struct * mm, u
 		make_pages_present(addr, start);
 	return vma;
 }
 #endif
 
+#ifdef CONFIG_PROC_FS
+/* Takes a reference to new_exe_file from caller -- does not get a new
+ * reference; only puts old ones */
+void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
+{
+	struct file *old_exe_file;
+
+	down_write(&mm->mmap_sem);
+	old_exe_file = mm->exe_file;
+	mm->exe_file = new_exe_file;
+	up_write(&mm->mmap_sem);
+	if (old_exe_file)
+		fput(old_exe_file);
+}
+
+struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	struct file *exe_file;
+
+	down_read(&mm->mmap_sem);
+	exe_file = mm->exe_file;
+	if (exe_file)
+		get_file(exe_file);
+	up_read(&mm->mmap_sem);
+	return exe_file;
+}
+#endif
+
 /*
  * Ok - we have the memory areas we should free on the vma list,
  * so release them, and do the vma updates.
  *
  * Called with the mm semaphore held.
@@ -1716,10 +1744,14 @@ static void remove_vma_list(struct mm_st
 
 		mm->total_vm -= nrpages;
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
+		if (mm->exe_file && (vma->vm_file == mm->exe_file)) {
+			fput(mm->exe_file);
+			mm->exe_file = NULL;
+		}
 		vma = remove_vma(vma);
 	} while (vma);
 	validate_mm(mm);
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
