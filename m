Date: Tue, 15 Apr 2008 10:17:16 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: kernel warning: tried to kill an mm-less task!
Message-ID: <20080415061716.GA89@tv-sign.ru>
References: <4803030D.3070906@cn.fujitsu.com> <48030F69.7040801@linux.vnet.ibm.com> <48031090.5050002@cn.fujitsu.com> <48042539.8050009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48042539.8050009@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

(cc Roland)

On 04/15, Li Zefan wrote:
>
> Li Zefan wrote:
> > Balbir Singh wrote:
> >> Li Zefan wrote:
> >>> When I ran the same test program I described in a previous patch,
> >>> I got the following warning:
> >>>
> >>> WARNING: at mm/oom_kill.c:320 __oom_kill_task+0x6d/0x101()
> >>> Modules linked in: 
> >>>
> 
> I Added 2 printk()s:
> 
>  static void __oom_kill_task(struct task_struct *p, int verbose)
>  {
> +       printk(KERN_WARNING "pid = %d, flags = %x\n", p->pid, p->flags);
> +
>         if (is_global_init(p)) {
>                 WARN_ON(1);
>                 printk(KERN_WARNING "tried to kill init!\n");
> @@ -319,6 +320,7 @@ static void __oom_kill_task(struct task_struct *p, int verbo
> 
>         if (!p->mm) {
>                 WARN_ON(1);
> +               printk(KERN_WARNING "pid = %d, flags = %x\n", p->pid, p->flags);
>                 printk(KERN_WARNING "tried to kill an mm-less task!\n");
>                 return;
>         }
> 
> got this:
> 
> pid = 3817, flags = 400140
> ------------[ cut here ]------------
> WARNING: at mm/oom_kill.c:322 __oom_kill_task+0x74/0xf1()
> ...
> ---[ end trace bb92f2fd8fe6c7c5 ]---
> pid = 3817, flags = 400144
> tried to kill an mm-less task!
> 
> So PF_EXITING may be set during the call of oom_kill_task(), and I notice
> the comment in oom_kill_task():
> 
> 	 * Furthermore, even if mm contains a non-NULL value, p->mm may
> 	 * change to NULL at any time since we do not hold task_lock(p).
> 	 * However, this is of no concern to us.
> 
> Is this warning just harmless so that we can just ignore it ?

Yes sure, tasklist_lock can't prevent the task exiting, it only protects
from release_task(). And task->mm == NULL after do_exit()->exit_mm().
Perhaps we can check "!p->mm && !PF_EXITING".

I don't think we should check PF_BORROWED_MM in __oom_kill_task(), it is
too late.

Perhaps,

	--- fs/aio.c	2008-02-17 23:40:07.000000000 +0300
	+++ fs/aio.c	2008-04-15 09:31:23.841202187 +0400
	@@ -579,6 +579,7 @@ static void use_mm(struct mm_struct *mm)
	 
		task_lock(tsk);
		tsk->flags |= PF_BORROWED_MM;
	+	smp_wmb();
		active_mm = tsk->active_mm;
		atomic_inc(&mm->mm_count);
		tsk->mm = mm;
	@@ -606,13 +607,23 @@ static void unuse_mm(struct mm_struct *m
		struct task_struct *tsk = current;
	 
		task_lock(tsk);
	-	tsk->flags &= ~PF_BORROWED_MM;
		tsk->mm = NULL;
	+	smp_wmb();
	+	tsk->flags &= ~PF_BORROWED_MM;
		/* active_mm is still 'mm' */
		enter_lazy_tlb(mm, tsk);
		task_unlock(tsk);
	 }
	 
	+struct mm_struct *__get_task_mm(struct task_struct *tsk)
	+{
	+	struct mm_struct *mm = tsk->mm;
	+	smp_rmb();
	+	if (tsk->flags & PF_BORROWED_MM)
	+		mm = NULL;
	+	return mm;
	+}
	+
	 /*
	  * Queue up a kiocb to be retried. Assumes that the kiocb
	  * has already been marked as kicked, and places it on

Now oom_kill_task/select_bad_process/etc can use __get_task_mm() to avoid
killing the kernel thread.

Off-topic: why ->oomkilladj is per thread, not per process? All threads share
the same ->mm. Note oom_kill_process(), it shouldn't use do_each_thread(),
it actually needs for_each_process().


Roland, what do you think about the coredump? Looks like we have the ancient
bug, zap_threads() can hit the kernel thread.

How about

	--- fs/exec.c	2008-02-17 23:40:07.000000000 +0300
	+++ fs/exec.c	2008-04-15 10:07:08.998518272 +0400
	@@ -1547,7 +1547,7 @@ static inline int zap_threads(struct tas
			p = g;
			do {
				if (p->mm) {
	-				if (p->mm == mm) {
	+				if (__get_task_mm(p) == mm) {
						/*
						 * p->sighand can't disappear, but
						 * may be changed by de_thread()

?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
