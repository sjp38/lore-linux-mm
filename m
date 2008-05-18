Date: Sun, 18 May 2008 21:00:55 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: [RFC,PATCH 3/3] kill PF_BORROWED_MM in favour of PF_KTHREAD
Message-ID: <20080518170055.GA25878@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Jeff Dike <jdike@addtoit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kill PF_BORROWED_MM. Change use_mm/unuse_mm to not play with ->flags, and
do s/PF_BORROWED_MM/PF_KTHREAD/ for a couple of other users.

No functional changes yet. But this allows us to do further fixes.

oom_kill/ptrace/etc often check "p->mm != NULL" to filter out the kthreads,
this is wrong because of use_mm(). The problem with PF_BORROWED_MM is that
we need task_lock() to avoid races. With this patch we can check PF_KTHREAD
directly, or use a simple lockless helper:

	/* The result must not be dereferenced !!! */
	struct mm_struct *__get_task_mm(struct task_struct *tsk)
	{
		if (tsk->flags & PF_KTHREAD)
			return NULL;
		return tsk->mm;
	}

It could be used, for example by zap_threads(). Currently it is buggy, we
can hit a kthread with PF_BORROWED_MM.

Note also that ecard_task(). It runs with ->mm != NULL, but it is the kernel
thread without PF_BORROWED_MM.

Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>

 include/linux/sched.h  |    3 +--
 fs/aio.c               |    2 --
 kernel/fork.c          |    4 ++--
 kernel/power/process.c |    2 +-
 4 files changed, 4 insertions(+), 7 deletions(-)

--- 26-rc2/include/linux/sched.h~3_USE_PF_KTHREAD	2008-05-18 15:44:16.000000000 +0400
+++ 26-rc2/include/linux/sched.h	2008-05-18 19:11:44.000000000 +0400
@@ -1500,7 +1500,7 @@ static inline void put_task_struct(struc
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
 #define PF_SWAPOFF	0x00080000	/* I am in swapoff */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
-#define PF_BORROWED_MM	0x00200000	/* I am a kthread doing use_mm */
+#define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
@@ -1508,7 +1508,6 @@ static inline void put_task_struct(struc
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
-#define PF_KTHREAD	0x80000000	/* I am a kernel thread */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
--- 26-rc2/fs/aio.c~3_USE_PF_KTHREAD	2008-05-18 17:20:42.000000000 +0400
+++ 26-rc2/fs/aio.c	2008-05-18 19:19:07.000000000 +0400
@@ -586,7 +586,6 @@ static void use_mm(struct mm_struct *mm)
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
-	tsk->flags |= PF_BORROWED_MM;
 	active_mm = tsk->active_mm;
 	atomic_inc(&mm->mm_count);
 	tsk->mm = mm;
@@ -610,7 +609,6 @@ static void unuse_mm(struct mm_struct *m
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
-	tsk->flags &= ~PF_BORROWED_MM;
 	tsk->mm = NULL;
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);
--- 26-rc2/kernel/fork.c~3_USE_PF_KTHREAD	2008-05-18 15:44:18.000000000 +0400
+++ 26-rc2/kernel/fork.c	2008-05-18 19:21:02.000000000 +0400
@@ -447,7 +447,7 @@ EXPORT_SYMBOL_GPL(mmput);
 /**
  * get_task_mm - acquire a reference to the task's mm
  *
- * Returns %NULL if the task has no mm.  Checks PF_BORROWED_MM (meaning
+ * Returns %NULL if the task has no mm.  Checks PF_KTHREAD (meaning
  * this kernel workthread has transiently adopted a user mm with use_mm,
  * to do its AIO) is not set and if so returns a reference to it, after
  * bumping up the use count.  User must release the mm via mmput()
@@ -460,7 +460,7 @@ struct mm_struct *get_task_mm(struct tas
 	task_lock(task);
 	mm = task->mm;
 	if (mm) {
-		if (task->flags & PF_BORROWED_MM)
+		if (task->flags & PF_KTHREAD)
 			mm = NULL;
 		else
 			atomic_inc(&mm->mm_users);
--- 26-rc2/kernel/power/process.c~3_USE_PF_KTHREAD	2008-05-18 15:42:44.000000000 +0400
+++ 26-rc2/kernel/power/process.c	2008-05-18 19:22:40.000000000 +0400
@@ -86,7 +86,7 @@ static void fake_signal_wake_up(struct t
 
 static int has_mm(struct task_struct *p)
 {
-	return (p->mm && !(p->flags & PF_BORROWED_MM));
+	return (p->mm && !(p->flags & PF_KTHREAD));
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
