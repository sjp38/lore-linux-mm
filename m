Date: Fri, 20 Jun 2003 13:00:30 +0200
From: Dominik Vogt <dominik.vogt@gmx.de>
Subject: VM oops in 2.4.20, attempted patch
Message-ID: <20030620110030.GE18326@gmx.de>
Reply-To: dominik.vogt@gmx.de
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel-owner@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

There is a bug in the 2.4.20 VM that causes a kernel oops.  The
rreason is that sometimes the mm_struct of a task is accessed
while it is currently being deleted.  The function exec_mmap(),
fs/exec.c begins with this code:

  old_mm = current->mm;
  if (old_mm && atomic_read(&old_mm->mm_users) == 1) {
          mm_release();
          exit_mmap(old_mm);
          return 0;
  }

The logic assumes that if mm_users == 1, no other process can
access the tasks mm_struct concurrently.  But that is not true.
There are a number of places that happily use the mm_struct even
while it is being destroyed via the exit_mmap() call in
exec_mmap().  There are definitely oopses caused by the way the
proc fs code accesses the mm_struct.

  Example from proc_pid_read_maps(), fs/proc/array.c:

  task_lock(task);
  mm = task->mm;
  if (mm)
          atomic_inc(&mm->mm_users);
  task_unlock(task);

I am not exactly sure about some other code.  The following code
snippets look suspicious, but I am not deep enough into the VM
code to judge whether they pose a problem or not:

access_process_vm(), kernel/ptrace.c:

  /* Worry about races with exit() */
  task_lock(tsk);
  mm = tsk->mm;
  if (mm)
    atomic_inc(&mm->mm_users);
  task_unlock(tsk);
  /* ... code fiddles with mm */

Calls to access_process_vm() eventually originate from either the
ptrace() system call in some architectures or the proc fs.  I
believe that this code has the potential to make the kernel oops,
but I have no proof.

swap_out(), mm/vmscan.c:

  spin_lock(&mmlist_lock);
  mm = swap_mm;
  while (mm->swap_address == TASK_SIZE || mm == &init_mm)
  {
    mm->swap_address = 0;
    mm = list_entry(mm->mmlist.next, struct mm_struct, mmlist);
    if (mm == swap_mm)
      goto empty;
    swap_mm = mm;
  }
  /* Make sure the mm doesn't disappear when we drop the lock.. */
  atomic_inc(&mm->mm_users);
  spin_unlock(&mmlist_lock);

Since swap_out() can be called by any process, for example via

  ...
  create_buffers()
  free_more_memory()
  try_to_free_pages()
  try_to_free_pages_zone()
  shrink_caches()
  shrink_cache()
  swap_out()

it might occur that mm_struct is swapped out while it is being
destroyed by execve().

There is more suspicious code related to swapping in
try_to_unsuse(), mm/swapfile.c.  Also, mm_users is accessed in an
unsafe fashien in the various architecture dependent smp.c files.
For example smp_flush_tlb_mm(), arch/sparc64/kernel/smp.c:

  if (atomic_read(&mm->mm_users) == 1) {
    /* See smp_flush_tlb_page for info about this. */
    mm->cpu_vm_mask = (1UL << cpu);
    goto local_flush_and_out;
  }
  /* ... */

This is probably safe, but may unnecessarily flush the tlb (or
possibly forget to flush the tlb although it has to?).

----

Basically, I think the problem is that the original VM design did
not take care of concurrent access to the mm_struct of a process.
It seems to assume that all processes accessing the mm_struct are
clones.  If it were like this, mm_users == 1 would mean that only
the current process is using the mm_struct and it can do with it
as it pleases since other processes can not spontaneously start
using the same structure.  Unfortunately this is not true, as
detailed above.  As a consequence the leightweight locking scheme
using the mm_users counter falls apart.

----

As for the severity of the problems we are having:  We have a
cron job that triggers an lsof every minute.  Reading the
/proc/<pid>/maps files of all processes sometimes collides with
another process running once per minute that calls execve().  With
ca. 200 machines we get about 100 oops messages per year cause by
this problem.

----

I have attempted to make a patch that fixes the locking problems
but does not add too much overhead for locking but did not get
very far.  It uses a semaphore to protect read/write access to
mm_users but does not lock the whole mm_struct.  The patch is
attached below for reference.  Do not use it since it deadlocks
the kernel within a couple of seconds.

Bye

Dominik ^_^  ^_^

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmcrash-0.0.4_27_may_2003.patch"

diff -r -u linux-2.4.20.orig/fs/exec.c linux-2.4.20/fs/exec.c
--- linux-2.4.20.orig/fs/exec.c	Fri Nov 29 00:53:15 2002
+++ linux-2.4.20/fs/exec.c	Thu May 22 10:30:56 2003
@@ -413,12 +413,21 @@
 static int exec_mmap(void)
 {
 	struct mm_struct * mm, * old_mm;
+	int cnt;
 
 	old_mm = current->mm;
-	if (old_mm && atomic_read(&old_mm->mm_users) == 1) {
-		mm_release();
-		exit_mmap(old_mm);
-		return 0;
+	if (old_mm) {
+		down_write(&old_mm->mm_users_sem);
+		if ((cnt = atomic_read(&old_mm->mm_users)) == 1) {
+			atomic_dec(&old_mm->mm_users);
+		}
+		up_write(&old_mm->mm_users_sem);
+		if (cnt == 1) {
+			mm_release();
+			exit_mmap(old_mm);
+			atomic_inc(&old_mm->mm_users);
+			return 0;
+		}
 	}
 
 	mm = mm_alloc();
diff -r -u linux-2.4.20.orig/fs/proc/array.c linux-2.4.20/fs/proc/array.c
--- linux-2.4.20.orig/fs/proc/array.c	Sat Aug  3 02:39:45 2002
+++ linux-2.4.20/fs/proc/array.c	Thu May 22 10:53:28 2003
@@ -281,9 +281,7 @@
 	buffer = task_name(task, buffer);
 	buffer = task_state(task, buffer);
 	task_lock(task);
-	mm = task->mm;
-	if(mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (mm) {
 		buffer = task_mem(mm, buffer);
@@ -311,9 +309,7 @@
 	state = *get_task_state(task);
 	vsize = eip = esp = 0;
 	task_lock(task);
-	mm = task->mm;
-	if(mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	if (task->tty) {
 		tty_pgrp = task->tty->pgrp;
 		tty_nr = kdev_t_to_nr(task->tty->device);
@@ -477,9 +473,7 @@
 	int size=0, resident=0, share=0, trs=0, lrs=0, drs=0, dt=0;
 
 	task_lock(task);
-	mm = task->mm;
-	if(mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (mm) {
 		struct vm_area_struct * vma;
@@ -619,9 +613,7 @@
 		goto out_free1;
 
 	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	retval = 0;
 	if (!mm)
diff -r -u linux-2.4.20.orig/fs/proc/base.c linux-2.4.20/fs/proc/base.c
--- linux-2.4.20.orig/fs/proc/base.c	Sat Aug  3 02:39:45 2002
+++ linux-2.4.20/fs/proc/base.c	Thu May 22 10:53:56 2003
@@ -60,9 +60,7 @@
 	struct task_struct *task = inode->u.proc_i.task;
 
 	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (!mm)
 		goto out;
@@ -129,9 +127,7 @@
 	struct mm_struct *mm;
 	int res = 0;
 	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (mm) {
 		int len = mm->env_end - mm->env_start;
@@ -148,9 +144,7 @@
 	struct mm_struct *mm;
 	int res = 0;
 	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (mm) {
 		int len = mm->arg_end - mm->arg_start;
@@ -356,9 +350,7 @@
 		return -ENOMEM;
 
 	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(task);
 	task_unlock(task);
 	if (!mm)
 		return 0;
diff -r -u linux-2.4.20.orig/include/linux/sched.h linux-2.4.20/include/linux/sched.h
--- linux-2.4.20.orig/include/linux/sched.h	Fri Nov 29 00:53:15 2002
+++ linux-2.4.20/include/linux/sched.h	Thu May 22 11:34:34 2003
@@ -213,6 +213,7 @@
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
+	struct rw_semaphore mm_users_sem;	/* protects access to mm_users */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
@@ -244,6 +245,7 @@
 	mm_rb:		RB_ROOT,			\
 	pgd:		swapper_pg_dir, 		\
 	mm_users:	ATOMIC_INIT(2), 		\
+	mm_users_sem:	__RWSEM_INITIALIZER(name.mm_users_sem), \
 	mm_count:	ATOMIC_INIT(1), 		\
 	mmap_sem:	__RWSEM_INITIALIZER(name.mmap_sem), \
 	page_table_lock: SPIN_LOCK_UNLOCKED, 		\
@@ -769,6 +771,9 @@
 		__mmdrop(mm);
 }
 
+/* increases the usage counter of the mm_struct */
+struct mm_struct * mmhold(struct mm_struct *mm);
+struct mm_struct * mmhold_task(struct task_struct *tsk);
 /* mmput gets rid of the mappings and all user-space */
 extern void mmput(struct mm_struct *);
 /* Remove the current tasks stale references to the old mm_struct */
diff -r -u linux-2.4.20.orig/kernel/fork.c linux-2.4.20/kernel/fork.c
--- linux-2.4.20.orig/kernel/fork.c	Fri Nov 29 00:53:15 2002
+++ linux-2.4.20/kernel/fork.c	Mon May 26 17:17:22 2003
@@ -257,6 +257,45 @@
 }
 
 /*
+ * Test whether the mm_users counter of the mm_struct is
+ * positive and increase it by one if it is.  Do not touch
+ * the counter if it is zero or less, i.e. the mm is being
+ * created or destroyed.
+ *
+ * Returns mm if the mm could be held and NULL otherwise.
+ */
+struct mm_struct * mmhold(struct mm_struct *mm)
+{
+	struct mm_struct *ret_mm;
+
+	down_read(&mm->mm_users_sem);
+	if (likely(atomic_read(&mm->mm_users) >= 1)) {
+		atomic_inc(&mm->mm_users);
+		ret_mm = mm;
+	} else {
+		ret_mm = NULL;
+	}
+	up_read(&mm->mm_users_sem);
+
+	return ret_mm;
+}
+
+/*
+ * Calls mmhold with the task's mm.
+ */
+struct mm_struct * mmhold_task(struct task_struct *tsk)
+{
+	struct mm_struct *mm;
+
+	if (tsk->mm != NULL)
+		mm = mmhold(tsk->mm);
+	else
+		mm = NULL;
+
+	return mm;
+}
+
+/*
  * Called when the last reference to the mm
  * is dropped: either by a lazy thread or by
  * mmput. Free the page directory and the mm.
diff -r -u linux-2.4.20.orig/kernel/ptrace.c linux-2.4.20/kernel/ptrace.c
--- linux-2.4.20.orig/kernel/ptrace.c	Sat Aug  3 02:39:46 2002
+++ linux-2.4.20/kernel/ptrace.c	Thu May 22 12:13:24 2003
@@ -135,9 +135,7 @@
 
 	/* Worry about races with exit() */
 	task_lock(tsk);
-	mm = tsk->mm;
-	if (mm)
-		atomic_inc(&mm->mm_users);
+	mm = mmhold_task(tsk);
 	task_unlock(tsk);
 	if (!mm)
 		return 0;

--OXfL5xGRrasGEqWY--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
