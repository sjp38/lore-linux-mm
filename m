Date: Sun, 18 May 2008 21:00:55 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: [RFC,PATCH 2/3] introduce PF_KTHREAD flag
Message-ID: <20080518170055.GA25875@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Jeff Dike <jdike@addtoit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I am not sure about this patch, PF_KTHREAD is ugly. But hopefully it is less
ugly and nore useful compared to PF_BORROWED_MM (killed by the next patch).

Introduce the new PF_KTHREAD flag to mark the kernel threads. It is set by
INIT_TASK() and copied to the forked childs (we could set it in kthreadd()
along with PF_NOFREEZE instead).

daemonize() was changed as well. In that case testing of PF_KTHREAD is racy,
but daemonize() is hopeless anyway.

This flag is cleared in do_execve(), before search_binary_handler(). Probably
not the best place, we can do this in exec_mmap() or in start_thread(), or
clear it along with PF_FORKNOEXEC. But I think this doesn't matter in practice,
and if do_execve() fails kthread should die soon.

This is the main source of ugliness, there is no exact point when the execing
kthread loses its "I am a kernel thread" status.

Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>

 include/linux/sched.h     |    1 +
 include/linux/init_task.h |    2 +-
 kernel/exit.c             |    2 +-
 fs/exec.c                 |    1 +
 4 files changed, 4 insertions(+), 2 deletions(-)

--- 26-rc2/include/linux/sched.h~2_MAKE_PF_KTHREAD	2008-05-18 15:44:16.000000000 +0400
+++ 26-rc2/include/linux/sched.h	2008-05-18 20:08:13.000000000 +0400
@@ -1508,6 +1508,7 @@ static inline void put_task_struct(struc
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
+#define PF_KTHREAD	0x80000000	/* I am a kernel thread */
 
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
--- 26-rc2/include/linux/init_task.h~2_MAKE_PF_KTHREAD	2008-05-18 15:44:15.000000000 +0400
+++ 26-rc2/include/linux/init_task.h	2008-05-18 20:14:30.000000000 +0400
@@ -143,7 +143,7 @@ extern struct group_info init_groups;
 	.state		= 0,						\
 	.stack		= &init_thread_info,				\
 	.usage		= ATOMIC_INIT(2),				\
-	.flags		= 0,						\
+	.flags		= PF_KTHREAD,					\
 	.lock_depth	= -1,						\
 	.prio		= MAX_PRIO-20,					\
 	.static_prio	= MAX_PRIO-20,					\
--- 26-rc2/kernel/exit.c~2_MAKE_PF_KTHREAD	2008-05-18 15:44:18.000000000 +0400
+++ 26-rc2/kernel/exit.c	2008-05-18 18:11:13.000000000 +0400
@@ -416,7 +416,7 @@ void daemonize(const char *name, ...)
 	 * We don't want to have TIF_FREEZE set if the system-wide hibernation
 	 * or suspend transition begins right now.
 	 */
-	current->flags |= PF_NOFREEZE;
+	current->flags |= (PF_NOFREEZE | PF_KTHREAD);
 
 	if (current->nsproxy != &init_nsproxy) {
 		get_nsproxy(&init_nsproxy);
--- 26-rc2/fs/exec.c~2_MAKE_PF_KTHREAD	2008-05-18 15:44:00.000000000 +0400
+++ 26-rc2/fs/exec.c	2008-05-18 18:36:30.000000000 +0400
@@ -1317,6 +1317,7 @@ int do_execve(char * filename,
 	if (retval < 0)
 		goto out;
 
+	current->flags &= ~PF_KTHREAD;
 	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
 		/* execve success */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
