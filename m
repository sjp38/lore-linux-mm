Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E33C9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:49:10 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/2] MM: extract exe_file handling from procfs
Date: Tue, 26 Apr 2011 11:48:24 +0200
Message-Id: <1303811305-1191-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alexander Viro <viro@zeniv.linux.org.uk>

Setup and cleanup of mm_struct->exe_file is currently done in
fs/proc/. This was because exe_file was needed only for
/proc/<pid>/exe. Since we will need the exe_file functionality also
for core dumps (so core name can contain full binary path), built this
functionality always into the kernel.

To achieve that move that out of proc FS to the kernel/ where in fact
it should belong. By doing that we can make dup_mm_exe_file static.
Also we can drop linux/proc_fs.h inclusion in fs/exec.c and
kernel/fork.c.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/exec.c                |    1 -
 fs/proc/base.c           |   51 ---------------------------------------------
 include/linux/mm.h       |   10 +-------
 include/linux/mm_types.h |    2 -
 include/linux/proc_fs.h  |   19 ----------------
 kernel/fork.c            |   52 +++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 53 insertions(+), 82 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 451c7e5..5d27d5c 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -42,7 +42,6 @@
 #include <linux/pid_namespace.h>
 #include <linux/module.h>
 #include <linux/namei.h>
-#include <linux/proc_fs.h>
 #include <linux/mount.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 4deef2e..bb308a1 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1576,57 +1576,6 @@ static const struct file_operations proc_pid_set_comm_operations = {
 	.release	= single_release,
 };
 
-/*
- * We added or removed a vma mapping the executable. The vmas are only mapped
- * during exec and are not mapped with the mmap system call.
- * Callers must hold down_write() on the mm's mmap_sem for these
- */
-void added_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas++;
-}
-
-void removed_exe_file_vma(struct mm_struct *mm)
-{
-	mm->num_exe_file_vmas--;
-	if ((mm->num_exe_file_vmas == 0) && mm->exe_file){
-		fput(mm->exe_file);
-		mm->exe_file = NULL;
-	}
-
-}
-
-void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
-{
-	if (new_exe_file)
-		get_file(new_exe_file);
-	if (mm->exe_file)
-		fput(mm->exe_file);
-	mm->exe_file = new_exe_file;
-	mm->num_exe_file_vmas = 0;
-}
-
-struct file *get_mm_exe_file(struct mm_struct *mm)
-{
-	struct file *exe_file;
-
-	/* We need mmap_sem to protect against races with removal of
-	 * VM_EXECUTABLE vmas */
-	down_read(&mm->mmap_sem);
-	exe_file = mm->exe_file;
-	if (exe_file)
-		get_file(exe_file);
-	up_read(&mm->mmap_sem);
-	return exe_file;
-}
-
-void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
-{
-	/* It's safe to write the exe_file pointer without exe_file_lock because
-	 * this is called during fork when the task is not yet in /proc */
-	newmm->exe_file = get_mm_exe_file(oldmm);
-}
-
 static int proc_exe_link(struct inode *inode, struct path *exe_path)
 {
 	struct task_struct *task;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd87a78..f65877d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1414,17 +1414,11 @@ extern void exit_mmap(struct mm_struct *);
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
 
-#ifdef CONFIG_PROC_FS
 /* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
 extern void added_exe_file_vma(struct mm_struct *mm);
 extern void removed_exe_file_vma(struct mm_struct *mm);
-#else
-static inline void added_exe_file_vma(struct mm_struct *mm)
-{}
-
-static inline void removed_exe_file_vma(struct mm_struct *mm)
-{}
-#endif /* CONFIG_PROC_FS */
+extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern struct file *get_mm_exe_file(struct mm_struct *mm);
 
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ca01ab2..fb0f614 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -307,11 +307,9 @@ struct mm_struct {
 	struct task_struct __rcu *owner;
 #endif
 
-#ifdef CONFIG_PROC_FS
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file *exe_file;
 	unsigned long num_exe_file_vmas;
-#endif
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 838c114..2fdbd61 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -173,12 +173,6 @@ extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
-/* While the {get|set|dup}_mm_exe_file functions are for mm_structs, they are
- * only needed to implement /proc/<pid>|self/exe so we define them here. */
-extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
-extern struct file *get_mm_exe_file(struct mm_struct *mm);
-extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
-
 #else
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
@@ -226,19 +220,6 @@ static inline void pid_ns_release_proc(struct pid_namespace *ns)
 {
 }
 
-static inline void set_mm_exe_file(struct mm_struct *mm,
-				   struct file *new_exe_file)
-{}
-
-static inline struct file *get_mm_exe_file(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-static inline void dup_mm_exe_file(struct mm_struct *oldmm,
-	       			   struct mm_struct *newmm)
-{}
-
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
diff --git a/kernel/fork.c b/kernel/fork.c
index cc04197..062cb42 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -59,7 +59,6 @@
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
 #include <linux/tty.h>
-#include <linux/proc_fs.h>
 #include <linux/blkdev.h>
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
@@ -573,6 +572,57 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
+/*
+ * We added or removed a vma mapping the executable. The vmas are only mapped
+ * during exec and are not mapped with the mmap system call.
+ * Callers must hold down_write() on the mm's mmap_sem for these
+ */
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
+static void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
+{
+	/* It's safe to write the exe_file pointer without exe_file_lock because
+	 * this is called during fork when the task is not yet in /proc */
+	newmm->exe_file = get_mm_exe_file(oldmm);
+}
+
 /**
  * get_task_mm - acquire a reference to the task's mm
  *
-- 
1.7.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
