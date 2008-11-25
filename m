Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id mAPIH1pj028142
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 10:17:02 -0800
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by spaceape23.eur.corp.google.com with ESMTP id mAPIGxwJ028411
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 10:17:00 -0800
Received: by gxk10 with SMTP id 10so181640gxk.10
        for <linux-mm@kvack.org>; Tue, 25 Nov 2008 10:16:59 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 25 Nov 2008 10:16:59 -0800
Message-ID: <604427e00811251016i4703aa0i18ff8797552b1317@mail.gmail.com>
Subject: [PATCH][V5]Make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

Looks good to me (but I'm not the maintainer of this particular piece of
code).

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

i>>?You might want to add an explanation why we check both 'tsk' and
'current' in either in the patch description or as a comment, though. Or
just add a link to the mailing list archives in the description or
something.

> Signed-off-by:        Paul Menage <menage@google.com>
> Singed-off-by:        Ying Han <yinghan@google.com>
 ^^^^^^

I'm sure you have a beautiful singing voice but from legal point of
view, it's probably better to just sign it off. ;-)

thanks . they are fixed in V5.


From: Ying Han <yinghan@google.com>

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
Signed-off-by:	Ying Han <yinghan@google.com>

include/linux/sched.h         |    1 +
kernel/signal.c               |    2 +-
mm/memory.c                   |    9 +-

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b483f39..f9c6a8a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1790,6 +1790,7 @@ extern void sched_dead(struct task_struct *p);
 extern int in_group_p(gid_t);
 extern int in_egroup_p(gid_t);

+extern int sigkill_pending(struct task_struct *tsk);
 extern void proc_caches_init(void);
 extern void flush_signals(struct task_struct *);
 extern void ignore_signals(struct task_struct *);
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
index 164951c..252ad00 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1218,12 +1218,14 @@ int __get_user_pages(struct task_struct *tsk, struct m
 			struct page *page;

 			/*
-			 * If tsk is ooming, cut off its access to large memory
-			 * allocations. It has a pending SIGKILL, but it can't
-			 * be processed until returning to user space.
+			 * If we have a pending SIGKILL, don't keep
+			 * allocating memory. We check both current
+			 * and tsk to cover the cases where current
+			 * is allocating pages on behalf of tsk.
 			 */
-			if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
-				return i ? i : -ENOMEM;
+			if (unlikely(sigkill_pending(current) ||
+					sigkill_pending(tsk)))
+				return i ? i : -ERESTARTSYS;

 			if (write)
 				foll_flags |= FOLL_WRITE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
