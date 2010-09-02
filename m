Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 41F5C6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:00:58 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o8200uFO007078
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:00:57 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe11.cbf.corp.google.com with ESMTP id o8200t7S023152
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:00:55 -0700
Received: by pwj8 with SMTP id 8so48227pwj.34
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 17:00:55 -0700 (PDT)
Date: Wed, 1 Sep 2010 17:00:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] oom: protect oom_disable_count with task_lock in
 fork
Message-ID: <alpine.DEB.2.00.1009011659020.14215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

task_lock(p) protects p->mm->oom_disable_count such that it accurately 
represents the number of threads attached to that mm that cannot be
killed by the oom killer.  p->signal->oom_score_adj is never changed
without holding the lock.

This was missed in the fork() path, so we take the lock to ensure
checking its oom_score_adj and decrementing oom_disable_count don't race.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/fork.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1304,8 +1304,10 @@ bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
 	if (p->mm) {
+		task_lock(p);
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			atomic_dec(&p->mm->oom_disable_count);
+		task_unlock(p);
 		mmput(p->mm);
 	}
 bad_fork_cleanup_signal:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
