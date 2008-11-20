Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id mAKM3dvx019066
	for <linux-mm@kvack.org>; Thu, 20 Nov 2008 14:03:40 -0800
Received: from wf-out-1314.google.com (wfd26.prod.google.com [10.142.4.26])
	by spaceape14.eur.corp.google.com with ESMTP id mAKM3bVx003754
	for <linux-mm@kvack.org>; Thu, 20 Nov 2008 14:03:38 -0800
Received: by wf-out-1314.google.com with SMTP id 26so690489wfd.13
        for <linux-mm@kvack.org>; Thu, 20 Nov 2008 14:03:36 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 20 Nov 2008 14:03:36 -0800
Message-ID: <604427e00811201403k26e4bf93tdb2dee9506756a82@mail.gmail.com>
Subject: Make the get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

make get_user_pages interruptible
The initial implementation of checking TIF_MEMDIE covers the cases of OOM
killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
return immediately. This patch includes:

1. add the case that the SIGKILL is sent by user processes. The process can
try to get_user_pages() unlimited memory even if a user process has sent a
SIGKILL to it(maybe a monitor find the process exceed its memory limit and
try to kill it). In the old implementation, the SIGKILL won't be handled
until the get_user_pages() returns.

2. change the return value to be ERESTARTSYS. It makes no sense to return
ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
Considering the general convention for a system call interrupted by a
signal is ERESTARTNOSYS, so the current return value is consistant to that.

Signed-off-by:	Paul Menage <menage@google.com>
		Ying Han <yinghan@google.com>


 include/linux/sched.h         |    1 +
 kernel/signal.c               |    2 +-
 mm/memory.c                   |    9 +-

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b483f39..f2a5cac 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1795,6 +1795,7 @@ extern void flush_signals(struct task_struct *);
 extern void ignore_signals(struct task_struct *);
 extern void flush_signal_handlers(struct task_struct *, int force_default);
 extern int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t
+extern int sigkill_pending(struct task_struct *tsk);

 static inline int dequeue_signal_lock(struct task_struct *tsk, sigset_t *mask
 {
diff --git a/kernel/signal.c b/kernel/signal.c
index 105217d..f3f154e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1497,7 +1497,7 @@ static inline int may_ptrace_stop(void)
  * Return nonzero if there is a SIGKILL that should be waking us up.
  * Called with the siglock held.
  */
-static int sigkill_pending(struct task_struct *tsk)
+int sigkill_pending(struct task_struct *tsk)
 {
 	return	sigismember(&tsk->pending.signal, SIGKILL) ||
 		sigismember(&tsk->signal->shared_pending.signal, SIGKILL);
diff --git a/mm/memory.c b/mm/memory.c
index 164951c..157ea3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1218,12 +1218,11 @@ int __get_user_pages(struct task_struct *tsk, struct m
 			struct page *page;

 			/*
-			 * If tsk is ooming, cut off its access to large memory
-			 * allocations. It has a pending SIGKILL, but it can't
-			 * be processed until returning to user space.
+			 * If we have a pending SIGKILL, don't keep
+			 * allocating memory.
 			 */
-			if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
-				return i ? i : -ENOMEM;
+			if (sigkill_pending(current))
+				return -ERESTARTSYS;

 			if (write)
 				foll_flags |= FOLL_WRITE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
