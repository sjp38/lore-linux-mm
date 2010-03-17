Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACFBA620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:56:01 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o2H8txSs030294
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:59 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe19.cbf.corp.google.com with ESMTP id o2H8tYje004192
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:58 -0700
Received: by pvg12 with SMTP id 12so422612pvg.24
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:58 -0700 (PDT)
Date: Wed, 17 Mar 2010 01:55:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 11/11 -mm v4] oom: avoid race for oom killed tasks detaching
 mm prior to exit
In-Reply-To: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003170154590.31796@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
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
memcg constrained ooms aren't the result of a lack of memory resources
but rather a limit imposed by userspace that requires a task be killed
regardless.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -290,12 +290,6 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
@@ -336,6 +330,12 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
