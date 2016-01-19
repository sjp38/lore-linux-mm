Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 07EB06B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 13:03:22 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so100992748wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:03:21 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g65si34757633wma.77.2016.01.19.10.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 10:03:20 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
Date: Tue, 19 Jan 2016 13:02:39 -0500
Message-Id: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

b764375 ("procfs: mark thread stack correctly in proc/<pid>/maps")
added [stack:TID] annotation to /proc/<pid>/maps. Finding the task of
a stack VMA requires walking the entire thread list, turning this into
quadratic behavior: a thousand threads means a thousand stacks, so the
rendering of /proc/<pid>/maps needs to look at a million threads. The
cost is not in proportion to the usefulness as described in the patch.

Drop the [stack:TID] annotation to make /proc/<pid>/maps (and
/proc/<pid>/numa_maps) usable again for higher thread counts.

The [stack] annotation inside /proc/<pid>/task/<tid>/maps is retained,
as identifying the stack VMA there is an O(1) operation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/filesystems/proc.txt |  9 ++----
 fs/proc/task_mmu.c                 | 66 +++++++++++++-------------------------
 fs/proc/task_nommu.c               | 48 +++++++++++----------------
 include/linux/mm.h                 |  3 +-
 mm/util.c                          | 27 +---------------
 5 files changed, 47 insertions(+), 106 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index e95aa1c..4e95796 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -356,7 +356,7 @@ address           perms offset  dev   inode      pathname
 a7cb1000-a7cb2000 ---p 00000000 00:00 0
 a7cb2000-a7eb2000 rw-p 00000000 00:00 0
 a7eb2000-a7eb3000 ---p 00000000 00:00 0
-a7eb3000-a7ed5000 rw-p 00000000 00:00 0          [stack:1001]
+a7eb3000-a7ed5000 rw-p 00000000 00:00 0
 a7ed5000-a8008000 r-xp 00000000 03:00 4222       /lib/libc.so.6
 a8008000-a800a000 r--p 00133000 03:00 4222       /lib/libc.so.6
 a800a000-a800b000 rw-p 00135000 03:00 4222       /lib/libc.so.6
@@ -388,7 +388,6 @@ is not associated with a file:
 
  [heap]                   = the heap of the program
  [stack]                  = the stack of the main process
- [stack:1001]             = the stack of the thread with tid 1001
  [vdso]                   = the "virtual dynamic shared object",
                             the kernel system call handler
 
@@ -396,10 +395,8 @@ is not associated with a file:
 
 The /proc/PID/task/TID/maps is a view of the virtual memory from the viewpoint
 of the individual tasks of a process. In this file you will see a mapping marked
-as [stack] if that task sees it as a stack. This is a key difference from the
-content of /proc/PID/maps, where you will see all mappings that are being used
-as stack by all of those tasks. Hence, for the example above, the task-level
-map, i.e. /proc/PID/task/TID/maps for thread 1001 will look like this:
+as [stack] if that task sees it as a stack. Hence, for the example above, the
+task-level map, i.e. /proc/PID/task/TID/maps for thread 1001 will look like this:
 
 08048000-08049000 r-xp 00000000 03:00 8312       /opt/test
 08049000-0804a000 rw-p 00001000 03:00 8312       /opt/test
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 65a1b6c..81aa553 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -259,23 +259,29 @@ static int do_maps_open(struct inode *inode, struct file *file,
 				sizeof(struct proc_maps_private));
 }
 
-static pid_t pid_of_stack(struct proc_maps_private *priv,
-				struct vm_area_struct *vma, bool is_pid)
+/*
+ * Indicate if the VMA is a stack for the given task; for
+ * /proc/PID/maps that is the stack of the main task.
+ */
+static int is_stack(struct proc_maps_private *priv,
+		    struct vm_area_struct *vma, int is_pid)
 {
-	struct inode *inode = priv->inode;
-	struct task_struct *task;
-	pid_t ret = 0;
+	int stack = 0;
+
+	if (is_pid) {
+		stack = vma->vm_start <= vma->vm_mm->start_stack &&
+			vma->vm_end >= vma->vm_mm->start_stack;
+	} else {
+		struct inode *inode = priv->inode;
+		struct task_struct *task;
 
-	rcu_read_lock();
-	task = pid_task(proc_pid(inode), PIDTYPE_PID);
-	if (task) {
-		task = task_of_stack(task, vma, is_pid);
+		rcu_read_lock();
+		task = pid_task(proc_pid(inode), PIDTYPE_PID);
 		if (task)
-			ret = task_pid_nr_ns(task, inode->i_sb->s_fs_info);
+			stack = vma_is_stack_for_task(vma, task);
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
-
-	return ret;
+	return stack;
 }
 
 static void
@@ -335,8 +341,6 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 
 	name = arch_vma_name(vma);
 	if (!name) {
-		pid_t tid;
-
 		if (!mm) {
 			name = "[vdso]";
 			goto done;
@@ -348,21 +352,8 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 			goto done;
 		}
 
-		tid = pid_of_stack(priv, vma, is_pid);
-		if (tid != 0) {
-			/*
-			 * Thread stack in /proc/PID/task/TID/maps or
-			 * the main process stack.
-			 */
-			if (!is_pid || (vma->vm_start <= mm->start_stack &&
-			    vma->vm_end >= mm->start_stack)) {
-				name = "[stack]";
-			} else {
-				/* Thread stack in /proc/PID/maps */
-				seq_pad(m, ' ');
-				seq_printf(m, "[stack:%d]", tid);
-			}
-		}
+		if (is_stack(priv, vma, is_pid))
+			name = "[stack]";
 	}
 
 done:
@@ -1613,19 +1604,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 		seq_file_path(m, file, "\n\t= ");
 	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
 		seq_puts(m, " heap");
-	} else {
-		pid_t tid = pid_of_stack(proc_priv, vma, is_pid);
-		if (tid != 0) {
-			/*
-			 * Thread stack in /proc/PID/task/TID/maps or
-			 * the main process stack.
-			 */
-			if (!is_pid || (vma->vm_start <= mm->start_stack &&
-			    vma->vm_end >= mm->start_stack))
-				seq_puts(m, " stack");
-			else
-				seq_printf(m, " stack:%d", tid);
-		}
+	} else if (is_stack(proc_priv, vma, is_pid)) {
+		seq_puts(m, " stack");
 	}
 
 	if (is_vm_hugetlb_page(vma))
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index e0d64c9..60ab72e 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -123,23 +123,25 @@ unsigned long task_statm(struct mm_struct *mm,
 	return size;
 }
 
-static pid_t pid_of_stack(struct proc_maps_private *priv,
-				struct vm_area_struct *vma, bool is_pid)
+static int is_stack(struct proc_maps_private *priv,
+		    struct vm_area_struct *vma, int is_pid)
 {
-	struct inode *inode = priv->inode;
-	struct task_struct *task;
-	pid_t ret = 0;
-
-	rcu_read_lock();
-	task = pid_task(proc_pid(inode), PIDTYPE_PID);
-	if (task) {
-		task = task_of_stack(task, vma, is_pid);
+	int stack = 0;
+
+	if (is_pid) {
+		stack = vma->vm_start <= mm->start_stack &&
+			vma->vm_end >= mm->start_stack;
+	} else {
+		struct inode *inode = priv->inode;
+		struct task_struct *task;
+
+		rcu_read_lock();
+		task = pid_task(proc_pid(inode), PIDTYPE_PID);
 		if (task)
-			ret = task_pid_nr_ns(task, inode->i_sb->s_fs_info);
+			stack = vma_is_stack_for_task(vma, task);
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
-
-	return ret;
+	return stack;
 }
 
 /*
@@ -181,21 +183,9 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 	if (file) {
 		seq_pad(m, ' ');
 		seq_file_path(m, file, "");
-	} else if (mm) {
-		pid_t tid = pid_of_stack(priv, vma, is_pid);
-
-		if (tid != 0) {
-			seq_pad(m, ' ');
-			/*
-			 * Thread stack in /proc/PID/task/TID/maps or
-			 * the main process stack.
-			 */
-			if (!is_pid || (vma->vm_start <= mm->start_stack &&
-			    vma->vm_end >= mm->start_stack))
-				seq_printf(m, "[stack]");
-			else
-				seq_printf(m, "[stack:%d]", tid);
-		}
+	} else if (mm && is_stack(priv, vma, is_pid)) {
+		seq_pad(m, ' ');
+		seq_printf(m, "[stack]");
 	}
 
 	seq_putc(m, '\n');
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7286d5b..0cbed33 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1343,8 +1343,7 @@ static inline int stack_guard_page_end(struct vm_area_struct *vma,
 		!vma_growsup(vma->vm_next, addr);
 }
 
-extern struct task_struct *task_of_stack(struct task_struct *task,
-				struct vm_area_struct *vma, bool in_group);
+int vma_is_stack_for_task(struct vm_area_struct *vma, struct task_struct *t);
 
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
diff --git a/mm/util.c b/mm/util.c
index bafd4c5..4f841e5 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -260,36 +260,11 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /* Check if the vma is being used as a stack by this task */
-static int vm_is_stack_for_task(struct task_struct *t,
-				struct vm_area_struct *vma)
+int vma_is_stack_for_task(struct vm_area_struct *vma, struct task_struct *t)
 {
 	return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
 }
 
-/*
- * Check if the vma is being used as a stack.
- * If is_group is non-zero, check in the entire thread group or else
- * just check in the current task. Returns the task_struct of the task
- * that the vma is stack for. Must be called under rcu_read_lock().
- */
-struct task_struct *task_of_stack(struct task_struct *task,
-				struct vm_area_struct *vma, bool in_group)
-{
-	if (vm_is_stack_for_task(task, vma))
-		return task;
-
-	if (in_group) {
-		struct task_struct *t;
-
-		for_each_thread(task, t) {
-			if (vm_is_stack_for_task(t, vma))
-				return t;
-		}
-	}
-
-	return NULL;
-}
-
 #if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
