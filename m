Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CD8BF60080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:36:49 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7O1akTm004443
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:46 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by hpaq13.eem.corp.google.com with ESMTP id o7O1aiWc027146
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:45 -0700
Received: by pzk26 with SMTP id 26so2410557pzk.5
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:36:44 -0700 (PDT)
Date: Mon, 23 Aug 2010 18:36:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/2] oom: protect task name when killing threads sharing
 memory
In-Reply-To: <alpine.DEB.2.00.1008231829230.6483@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008231830290.6483@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008231829230.6483@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's necessary to prevent dereferences of q->comm for a task q when
q != current because its name may change during prctl() with
PR_SET_NAME.

Unfortunately, we can't use get_task_comm() when killing other threads
sharing the same memory as the oom killed task since it would require a
string to be allocated on the stack which may be very deep, especially
during failed page allocations.

This patch protects the dereference with task_lock() instead.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -429,8 +429,10 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	 */
 	for_each_process(q)
 		if (q->mm == mm && !same_thread_group(q, p)) {
+			task_lock(q);
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(q), q->comm);
+			task_unlock(q);
 			force_sig(SIGKILL, q);
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
