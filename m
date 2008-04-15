Date: Tue, 15 Apr 2008 14:19:05 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: s/PF_BORROWED_MM/PF_KTHREAD/ (was: kernel warning: tried to kill an mm-less task!)
Message-ID: <20080415101905.GB89@tv-sign.ru>
References: <4803030D.3070906@cn.fujitsu.com> <48030F69.7040801@linux.vnet.ibm.com> <48031090.5050002@cn.fujitsu.com> <48042539.8050009@cn.fujitsu.com> <20080415061716.GA89@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415061716.GA89@tv-sign.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On 04/15, Oleg Nesterov wrote:
>
> 	+struct mm_struct *__get_task_mm(struct task_struct *tsk)
> 	+{
> 	+	struct mm_struct *mm = tsk->mm;
> 	+	smp_rmb();
> 	+	if (tsk->flags & PF_BORROWED_MM)
> 	+		mm = NULL;
> 	+	return mm;
> 	+}

No, this is racy wrt unuse_mm(), we still need task_lock().

Actually, I think PF_BORROWED_MM should die, and PF_I_AM_A_KERNEL_THREAD
is better, see the "patch" below.

First, include/asm-um/mmu_context.h:activate_mm() doesn't look right to me,
use_mm() does switch_mm(), not activate_mm(), so I think we can do

	--- include/asm-um/mmu_context.h	2008-02-17 23:40:08.000000000 +0300
	+++ -	2008-04-15 13:35:34.089295980 +0400
	@@ -29,7 +29,7 @@ static inline void activate_mm(struct mm
		 * host. Since they're very expensive, we want to avoid that as far as
		 * possible.
		 */
	-	if (old != new && (current->flags & PF_BORROWED_MM))
	+	if (old != new)
			__switch_mm(&new->context.id);
	 
		arch_dup_mmap(old, new);

With this + patch below, we can make a simple helper,

	/* The result must not be dereferenced !!! */
	struct mm_struct *__get_task_mm(struct task_struct *tsk)
	{
		if (tsk->flags & PF_KTHREAD)
			return NULL;
		return tsk->mm;
	}

it could ve used by oom_kill/coredump/ptrace_attach instead of "->mm != NULL"
which doesn't really work. Note also that ecard_task() runs with mm != NULL,
but it is the kernel thread without PF_BORROWED_MM.

daemonize() is racy, but it is hopeless anyway.

Oleg.

--- include/linux/sched.h	2008-02-17 23:40:09.000000000 +0300
+++ -	2008-04-15 11:38:46.892847693 +0400
@@ -1458,7 +1458,7 @@ static inline void put_task_struct(struc
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
 #define PF_SWAPOFF	0x00080000	/* I am in swapoff */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
-#define PF_BORROWED_MM	0x00200000	/* I am a kthread doing use_mm */
+#define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
--- kernel/power/process.c	2008-02-17 23:40:09.000000000 +0300
+++ -	2008-04-15 11:41:13.044031366 +0400
@@ -93,7 +93,7 @@ static void send_fake_signal(struct task
 
 static int has_mm(struct task_struct *p)
 {
-	return (p->mm && !(p->flags & PF_BORROWED_MM));
+	return (p->mm && !(p->flags & PF_KTHREAD));
 }
 
 /**
--- fs/aio.c	2008-02-17 23:40:07.000000000 +0300
+++ -	2008-04-15 11:44:11.100698248 +0400
@@ -578,15 +578,10 @@ static void use_mm(struct mm_struct *mm)
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
-	tsk->flags |= PF_BORROWED_MM;
 	active_mm = tsk->active_mm;
 	atomic_inc(&mm->mm_count);
 	tsk->mm = mm;
 	tsk->active_mm = mm;
-	/*
-	 * Note that on UML this *requires* PF_BORROWED_MM to be set, otherwise
-	 * it won't work. Update it accordingly if you change it here
-	 */
 	switch_mm(active_mm, mm, tsk);
 	task_unlock(tsk);
 
@@ -606,7 +601,6 @@ static void unuse_mm(struct mm_struct *m
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
-	tsk->flags &= ~PF_BORROWED_MM;
 	tsk->mm = NULL;
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);
--- kernel/fork.c	2008-02-17 23:40:09.000000000 +0300
+++ -	2008-04-15 11:48:24.539070614 +0400
@@ -424,7 +424,7 @@ EXPORT_SYMBOL_GPL(mmput);
 /**
  * get_task_mm - acquire a reference to the task's mm
  *
- * Returns %NULL if the task has no mm.  Checks PF_BORROWED_MM (meaning
+ * Returns %NULL if the task has no mm.  Checks PF_KTHREAD (meaning
  * this kernel workthread has transiently adopted a user mm with use_mm,
  * to do its AIO) is not set and if so returns a reference to it, after
  * bumping up the use count.  User must release the mm via mmput()
@@ -437,7 +437,7 @@ struct mm_struct *get_task_mm(struct tas
 	task_lock(task);
 	mm = task->mm;
 	if (mm) {
-		if (task->flags & PF_BORROWED_MM)
+		if (task->flags & PF_KTHREAD)
 			mm = NULL;
 		else
 			atomic_inc(&mm->mm_users);
--- kernel/kthread.c	2008-02-17 23:40:09.000000000 +0300
+++ -	2008-04-15 11:51:06.014085477 +0400
@@ -234,7 +234,7 @@ int kthreadd(void *unused)
 	set_user_nice(tsk, KTHREAD_NICE_LEVEL);
 	set_cpus_allowed(tsk, CPU_MASK_ALL);
 
-	current->flags |= PF_NOFREEZE;
+	current->flags |= (PF_NOFREEZE | PF_KTHREAD);
 
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
--- fs/exec.c	2008-02-17 23:40:07.000000000 +0300
+++ -	2008-04-15 12:33:10.854945536 +0400
@@ -1328,6 +1328,7 @@ int do_execve(char * filename,
 		goto out;
 	bprm->argv_len = env_p - bprm->p;
 
+	current->flags &= ~PF_KTHREAD;
 	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
 		/* execve success */
--- kernel/exit.c	2008-02-17 23:40:09.000000000 +0300
+++ -	2008-04-15 13:49:30.916850385 +0400
@@ -382,7 +382,7 @@ void daemonize(const char *name, ...)
 	 * We don't want to have TIF_FREEZE set if the system-wide hibernation
 	 * or suspend transition begins right now.
 	 */
-	current->flags |= PF_NOFREEZE;
+	current->flags |= (PF_NOFREEZE | PF_KTHREAD);
 
 	if (current->nsproxy != &init_nsproxy) {
 		get_nsproxy(&init_nsproxy);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
