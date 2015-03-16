Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id DAD626B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:13:01 -0400 (EDT)
Received: by lbcgn8 with SMTP id gn8so19494519lbc.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 06:13:01 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id mu1si8115966lbc.3.2015.03.16.06.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 06:13:00 -0700 (PDT)
Subject: [PATCH] mm: rcu-protected get_mm_exe_file()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 16 Mar 2015 16:12:57 +0300
Message-ID: <20150316131257.32340.36600.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>

This patch removes mm->mmap_sem from mm->exe_file read side.
Also it kills dup_mm_exe_file() and moves exe_file duplication into
dup_mmap() where both mmap_sems are locked.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Davidlohr Bueso <dbueso@suse.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/file.c                |    3 +-
 include/linux/fs.h       |    1 +
 include/linux/mm_types.h |    2 +-
 kernel/fork.c            |   56 ++++++++++++++++++++++++++++++----------------
 4 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index ee738ea028fa..93c5f89c248b 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -638,8 +638,7 @@ static struct file *__fget(unsigned int fd, fmode_t mask)
 	file = fcheck_files(files, fd);
 	if (file) {
 		/* File object ref couldn't be taken */
-		if ((file->f_mode & mask) ||
-		    !atomic_long_inc_not_zero(&file->f_count))
+		if ((file->f_mode & mask) || !get_file_rcu(file))
 			file = NULL;
 	}
 	rcu_read_unlock();
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1abc7f2a5730..29bc94cfa273 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -847,6 +847,7 @@ static inline struct file *get_file(struct file *f)
 	atomic_long_inc(&f->f_count);
 	return f;
 }
+#define get_file_rcu(x) atomic_long_inc_not_zero(&(x)->f_count)
 #define fput_atomic(x)	atomic_long_add_unless(&(x)->f_count, -1, 1)
 #define file_count(x)	atomic_long_read(&(x)->f_count)
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 590630eb59ba..8d37e26a1007 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -429,7 +429,7 @@ struct mm_struct {
 #endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
-	struct file *exe_file;
+	struct file __rcu *exe_file;
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 2113001ceb38..a7c596517bd6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -380,6 +380,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
+	/* No ordering required: file already has been exposed. */
+	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
+
 	mm->total_vm = oldmm->total_vm;
 	mm->shared_vm = oldmm->shared_vm;
 	mm->exec_vm = oldmm->exec_vm;
@@ -505,7 +508,13 @@ static inline void mm_free_pgd(struct mm_struct *mm)
 	pgd_free(mm, mm->pgd);
 }
 #else
-#define dup_mmap(mm, oldmm)	(0)
+static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
+{
+	down_write(&oldmm->mmap_sem);
+	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
+	up_write(&oldmm->mmap_sem);
+	return 0;
+}
 #define mm_alloc_pgd(mm)	(0)
 #define mm_free_pgd(mm)
 #endif /* CONFIG_MMU */
@@ -674,36 +683,47 @@ void mmput(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmput);
 
+/**
+ * set_mm_exe_file - change a reference to the mm's executable file
+ *
+ * This changes mm's executale file (shown as symlink /proc/[pid]/exe).
+ *
+ * Main users are mmput(), sys_execve() and sys_prctl(PR_SET_MM_MAP/EXE_FILE).
+ * Callers prevent concurrent invocations: in mmput() nobody alive left,
+ * in execve task is single-threaded, prctl holds mmap_sem exclusively.
+ */
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
+	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
+			!atomic_read(&mm->mm_users) || current->in_execve ||
+			lock_is_held(&mm->mmap_sem));
+
 	if (new_exe_file)
 		get_file(new_exe_file);
-	if (mm->exe_file)
-		fput(mm->exe_file);
-	mm->exe_file = new_exe_file;
+	rcu_assign_pointer(mm->exe_file, new_exe_file);
+	if (old_exe_file)
+		fput(old_exe_file);
 }
 
+/**
+ * get_mm_exe_file - acquire a reference to the mm's executable file
+ *
+ * Returns %NULL if mm has no associated executable file.
+ * User must release file via fput().
+ */
 struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	/* We need mmap_sem to protect against races with removal of exe_file */
-	down_read(&mm->mmap_sem);
-	exe_file = mm->exe_file;
-	if (exe_file)
-		get_file(exe_file);
-	up_read(&mm->mmap_sem);
+	rcu_read_lock();
+	exe_file = rcu_dereference(mm->exe_file);
+	if (exe_file && !get_file_rcu(exe_file))
+		exe_file = NULL;
+	rcu_read_unlock();
 	return exe_file;
 }
 EXPORT_SYMBOL(get_mm_exe_file);
 
-static void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm)
-{
-	/* It's safe to write the exe_file pointer without exe_file_lock because
-	 * this is called during fork when the task is not yet in /proc */
-	newmm->exe_file = get_mm_exe_file(oldmm);
-}
-
 /**
  * get_task_mm - acquire a reference to the task's mm
  *
@@ -865,8 +885,6 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
-	dup_mm_exe_file(oldmm, mm);
-
 	err = dup_mmap(mm, oldmm);
 	if (err)
 		goto free_pt;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
