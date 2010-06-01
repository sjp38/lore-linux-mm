Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B25A16B01DB
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:19:08 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o517J62Z026188
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:06 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq2.eem.corp.google.com with ESMTP id o517J3Rd005936
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:04 -0700
Received: by pwj1 with SMTP id 1so455310pwj.41
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:19:03 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:19:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching mm
 prior to exit
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tasks detach its ->mm prior to exiting so it's possible that in progress
oom kills or already exiting tasks may be missed during the oom killer's
tasklist scan.  When an eligible task is found with either TIF_MEMDIE or
PF_EXITING set, the oom killer is supposed to be a no-op to avoid
needlessly killing additional tasks.  This closes the race between a task
detaching its ->mm and being removed from the tasklist.

Out of memory conditions as the result of memory controllers will
automatically filter tasks that have detached their ->mm (since
task_in_mem_cgroup() will return 0).  This is acceptable, however, since
memcg constrained ooms aren't the result of a lack of memory resources but
rather a limit imposed by userspace that requires a task be killed
regardless.

[oleg@redhat.com: fix PF_EXITING check for !p->mm tasks]
Acked-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -317,12 +317,6 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	for_each_process(p) {
 		unsigned int points;
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
-		if (!p->mm)
-			continue;
 		/* skip the init task */
 		if (is_global_init(p))
 			continue;
@@ -355,7 +349,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (p->flags & PF_EXITING) {
+		if (p->flags & PF_EXITING && p->mm) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
@@ -363,6 +357,12 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			*ppoints = 1000;
 		}
 
+		/*
+		 * skip kernel threads and tasks which have already released
+		 * their mm.
+		 */
+		if (!p->mm)
+			continue;
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
