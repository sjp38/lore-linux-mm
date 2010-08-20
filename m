Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EEFC96B0365
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:52:48 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o7KNqiMM013443
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:52:45 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by kpbe14.cbf.corp.google.com with ESMTP id o7KNqhve006382
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:52:43 -0700
Received: by pzk5 with SMTP id 5so1912799pzk.24
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:52:42 -0700 (PDT)
Date: Fri, 20 Aug 2010 16:52:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/3 v3] oom: kill all threads sharing oom killed task's
 mm
In-Reply-To: <alpine.DEB.2.00.1008201541210.9201@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008201651400.16947@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201541210.9201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, forgot to address KOSAKI-san's request to add a pr_err() when 
sending SIGKILLs to other tasks.  Updated patch here.


oom: kill all threads sharing oom killed task's mm

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

This mainly is for threads that are cloned with CLONE_VM but not
CLONE_THREAD, so they are in a different thread group.  Non-NPTL threads
exist in the wild and this change is necessary to prevent the livelock in
such cases.  We care more about preventing the livelock than incurring
the additional tasklist in the oom killer when a task has been killed.
Systems that are sufficiently large to not want the tasklist scan in the
oom killer in the first place already have the option of enabling
/proc/sys/vm/oom_kill_allocating_task, which was designed specifically
for that purpose.

This code had existed in the oom killer for over eight years dating back
to the 2.4 kernel.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -401,16 +401,38 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 #define K(x) ((x) << (PAGE_SHIFT-10))
 static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
+	struct task_struct *q;
+	struct mm_struct *mm;
+
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 1;
 
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
+		if (q->mm == mm && !same_thread_group(q, p)) {
+			pr_err("Kill process %d (%s) sharing same memory\n",
+				task_pid_nr(q), q->comm);
+			force_sig(SIGKILL, q);
+		}
 
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
