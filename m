Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A53026B01F0
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 21:16:18 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o7H1GCIB027901
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 18:16:12 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq5.eem.corp.google.com with ESMTP id o7H1FRj6024107
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 18:16:11 -0700
Received: by pwj8 with SMTP id 8so4312242pwj.25
        for <linux-mm@kvack.org>; Mon, 16 Aug 2010 18:16:11 -0700 (PDT)
Date: Mon, 16 Aug 2010 18:16:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 2/2] oom: kill all threads sharing oom killed task's mm
In-Reply-To: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008161814450.26680@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's necessary to kill all threads that share an oom killed task's mm if
the goal is to lead to future memory freeing.

This patch reintroduces the code removed in 8c5cd6f3 (oom: oom_kill
doesn't kill vfork parent (or child)) since it is obsoleted.

It's now guaranteed that any task passed to oom_kill_task() does not
share an mm with any thread that is unkillable.  Thus, we're safe to
issue a SIGKILL to any thread sharing the same mm.

This is especially necessary to solve an mm->mmap_sem livelock issue
whereas an oom killed thread must acquire the lock in the exit path while
another thread is holding it in the page allocator while trying to
allocate memory itself (and will preempt the oom killer since a task was
already killed).  Since tasks with pending fatal signals are now granted
access to memory reserves, the thread holding the lock may quickly
allocate and release the lock so that the oom killed task may exit.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: kill all threads in other thread groups before killing p to ensure
     it doesn't preemptively exit while still iterating through the
     tasklist and comparing unprotected mm pointers, as suggested by Oleg.

 mm/oom_kill.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -414,17 +414,37 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 #define K(x) ((x) << (PAGE_SHIFT-10))
 static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
+	struct task_struct *q;
+	struct mm_struct *mm;
+
 	p = find_lock_task_mm(p);
 	if (!p) {
 		task_unlock(p);
 		return 1;
 	}
+
+	/* mm cannot be safely dereferenced after task_unlock(p) */
+	mm = p->mm;
+
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(p), p->comm, K(p->mm->total_vm),
 		K(get_mm_counter(p->mm, MM_ANONPAGES)),
 		K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
+	/*
+	 * Kill all processes sharing p->mm in other thread groups, if any.
+	 * They don't get access to memory reserves or a higher scheduler
+	 * priority, though, to avoid depletion of all memory or task
+	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
+	 * task cannot exit because it requires the semaphore and its contended
+	 * by another thread trying to allocate memory itself.  That thread will
+	 * now get access to memory reserves since it has a pending fatal
+	 * signal.
+	 */
+	for_each_process(q)
+		if (q->mm == mm && !same_thread_group(q, p))
+			force_sig(SIGKILL, q);
 
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
