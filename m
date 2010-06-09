Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1794B6B01D0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:22 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o593xJdw016771
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:19 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq14.eem.corp.google.com with ESMTP id o593xH6F031412
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:18 -0700
Received: by pvg2 with SMTP id 2so7992022pvg.2
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:17 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/6] oom: protect dereferencing of task's comm
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082057440.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew notes that dereferencing task->comm is unsafe without holding
task_lock(task).  That's true even when dealing with current, so all
existing dereferences within the oom killer need to ensure they are
holding task_lock() before doing so.

This avoids using get_task_comm() because we'd otherwise need to
allocate a string of TASK_COMM_LEN on the stack (or add synchronization
and use a global string) and we don't want to do that because page
allocations, and thus the oom killer, can happen particularly deep in the
stack.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -387,10 +387,10 @@ static void dump_tasks(const struct mem_cgroup *mem)
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 							struct mem_cgroup *mem)
 {
+	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
 		"oom_adj=%d\n",
 		current->comm, gfp_mask, order, current->signal->oom_adj);
-	task_lock(current);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
@@ -443,8 +443,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return 0;
 	}
 
+	task_lock(p);
 	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
+	task_unlock(p);
 
 	/* Try to sacrifice the worst child first */
 	do_posix_clock_monotonic_gettime(&uptime);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
