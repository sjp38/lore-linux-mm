Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id E1F606B009A
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:39:53 -0400 (EDT)
Received: by oier21 with SMTP id r21so11942330oie.1
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 15:39:53 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id t187si3065975oig.134.2015.03.14.15.39.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 15:39:51 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 3/4] prctl: move MMF_EXE_FILE_CHANGED into exe_file struct
Date: Sat, 14 Mar 2015 15:39:25 -0700
Message-Id: <1426372766-3029-4-git-send-email-dave@stgolabs.net>
In-Reply-To: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

Given the introduction of the exe_file structure, this
functionality should be associated with. Because this is
a very specific prctl property, it is easily to do so. As
of now, when the file has already changed, mmap_sem is not
taken at all (however we do need it of course to check the
old mapping, but this is now shared) and we maintain the
test-and-set logic ensuring nothing raced when we were not
holding the exe_file lock.

Now, the downside is that this patch makes MMF_EXE_FILE_CHANGED
functionality general, of course trivially enlarging the mm_struct
to users that don't care about this - which is the most usual case.
But I don't see this of any importance really. Similarly the funcs
that prctl makes use of are also global, in fork.c -- I preferred
leaving things generic for any(?) future user(s), but it could very
well be moved to sys.c.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/mm.h       |  5 +++--
 include/linux/mm_types.h |  1 +
 include/linux/sched.h    |  5 ++---
 kernel/fork.c            | 37 +++++++++++++++++++++++++++---
 kernel/sys.c             | 58 +++++++++++++++++++++++++-----------------------
 5 files changed, 70 insertions(+), 36 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0c0720d..90eae9f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1911,9 +1911,10 @@ extern void mm_drop_all_locks(struct mm_struct *mm);
 
 /* mm->exe_file handling */
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
-extern void set_mm_exe_file_locked(struct mm_struct *mm,
-				   struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
+extern bool test_and_set_mm_exe_file(struct mm_struct *mm,
+				     struct file *new_exe_file);
+extern bool mm_exe_file_changed(struct mm_struct *mm);
 
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1fc994e..2d8b06b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -328,6 +328,7 @@ struct core_state {
 
 struct exe_file {
 	rwlock_t lock;
+	bool changed; /* see prctl_set_mm_exe_file() */
 	struct file *file;
 };
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d77432..0caf62e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -494,10 +494,9 @@ static inline int get_dumpable(struct mm_struct *mm)
 					/* leave room for more dump flags */
 #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
 #define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
-#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
 
-#define MMF_HAS_UPROBES		19	/* has uprobes */
-#define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_HAS_UPROBES		18	/* has uprobes */
+#define MMF_RECALC_UPROBES	19	/* MMF_HAS_UPROBES can be wrong */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/fork.c b/kernel/fork.c
index aa0332b..54b0b91 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -675,18 +675,50 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
-void set_mm_exe_file_locked(struct mm_struct *mm, struct file *new_exe_file)
+/*
+ * exe_file handling is differentiated by the caller's need to
+ * be aware of the file being changed -- which will always require
+ * holding the exe_file lock. As such, the following functions
+ * keep track of this are (currently only used by prctl):
+ *   - test_and_set_mm_exe_file()
+ *   - mm_exe_file_changed()
+ *
+ * The rest of the callers should only stick to:
+ *   - set_mm_exe_file()
+ *   - get_mm_exe_file()
+ */
+bool test_and_set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
+	bool ret = false;
+
+	write_lock(&mm->exe_file.lock);
+	if (mm->exe_file.changed)
+		goto done;
+
 	if (new_exe_file)
 		get_file(new_exe_file);
 	if (mm->exe_file.file)
 		fput(mm->exe_file.file);
 
-	write_lock(&mm->exe_file.lock);
 	mm->exe_file.file = new_exe_file;
+	ret = mm->exe_file.changed = true;
+done:
 	write_unlock(&mm->exe_file.lock);
+	return ret;
 }
 
+bool mm_exe_file_changed(struct mm_struct *mm)
+{
+	bool ret;
+
+	read_lock(&mm->exe_file.lock);
+	ret = mm->exe_file.changed;
+	read_lock(&mm->exe_file.lock);
+
+	return ret;
+}
+
+/* lockless -- see each caller for justification */
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	if (new_exe_file)
@@ -711,7 +743,6 @@ struct file *get_mm_exe_file(struct mm_struct *mm)
 }
 EXPORT_SYMBOL(get_mm_exe_file);
 
-
 static void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
 	/*
diff --git a/kernel/sys.c b/kernel/sys.c
index a4d70f0..a82d0c4 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1649,17 +1649,27 @@ SYSCALL_DEFINE1(umask, int, mask)
 	return mask;
 }
 
-static int __prctl_set_mm_exe_file(struct mm_struct *mm, struct fd exe)
+static int __prctl_set_mm_exe_file(struct mm_struct *mm, struct fd exefd)
 {
-	int err;
 	struct file *exe_file;
 
 	/*
+	 * The symlink can be changed only once, just to disallow arbitrary
+	 * transitions malicious software might bring in. This means one
+	 * could make a snapshot over all processes running and monitor
+	 * /proc/pid/exe changes to notice unusual activity if needed.
+	 */
+	if (mm_exe_file_changed(mm))
+		return -EPERM;
+
+	/*
 	 * Forbid mm->exe_file change if old file still mapped.
 	 */
 	exe_file = get_mm_exe_file(mm);
-	err = -EBUSY;
-	down_write(&mm->mmap_sem);
+	if (!exe_file)
+		goto set_file;
+
+	down_read(&mm->mmap_sem);
 	if (exe_file) {
 		struct vm_area_struct *vma;
 
@@ -1669,44 +1679,36 @@ static int __prctl_set_mm_exe_file(struct mm_struct *mm, struct fd exe)
 			if (path_equal(&vma->vm_file->f_path,
 				       &exe_file->f_path)) {
 				fput(exe_file);
-				goto exit_err;
+				up_read(&mm->mmap_sem);
+				return -EBUSY;
 			}
 		}
 
 		fput(exe_file);
 	}
+	up_read(&mm->mmap_sem);
 
+set_file:
 	/*
-	 * The symlink can be changed only once, just to disallow arbitrary
-	 * transitions malicious software might bring in. This means one
-	 * could make a snapshot over all processes running and monitor
-	 * /proc/pid/exe changes to notice unusual activity if needed.
+	 * Recheck the file state again before setting.
+	 * This grabs a reference to exefd.file.
 	 */
-	err = -EPERM;
-	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
-		goto exit_err;
-
-	up_write(&mm->mmap_sem);
-
-	/* this grabs a reference to exe.file */
-	set_mm_exe_file_locked(mm, exe.file);
-	return 0;
-exit_err:
-	up_write(&mm->mmap_sem);
-	return err;
+	if (test_and_set_mm_exe_file(mm, exefd.file))
+		return 0;
+	return -EPERM;
 }
 
 static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 {
-	struct fd exe;
+	struct fd exefd;
 	struct inode *inode;
 	int err;
 
-	exe = fdget(fd);
-	if (!exe.file)
+	exefd = fdget(fd);
+	if (!exefd.file)
 		return -EBADF;
 
-	inode = file_inode(exe.file);
+	inode = file_inode(exefd.file);
 
 	/*
 	 * Because the original mm->exe_file points to executable file, make
@@ -1715,16 +1717,16 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	 */
 	err = -EACCES;
 	if (!S_ISREG(inode->i_mode)	||
-	    exe.file->f_path.mnt->mnt_flags & MNT_NOEXEC)
+	    exefd.file->f_path.mnt->mnt_flags & MNT_NOEXEC)
 		goto exit;
 
 	err = inode_permission(inode, MAY_EXEC);
 	if (err)
 		goto exit;
 
-	err = __prctl_set_mm_exe_file(mm, exe);
+	err = __prctl_set_mm_exe_file(mm, exefd);
 exit:
-	fdput(exe);
+	fdput(exefd);
 	return err;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
