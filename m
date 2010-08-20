Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD1A6004CE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 18:42:03 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o7KMg0WZ025650
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:42:00 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by hpaq12.eem.corp.google.com with ESMTP id o7KMfwRB027654
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:41:58 -0700
Received: by pzk26 with SMTP id 26so1610995pzk.33
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:41:57 -0700 (PDT)
Date: Fri, 20 Aug 2010 15:41:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/3 v3] oom: avoid killing a task if a thread sharing its mm
 cannot be killed
In-Reply-To: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008201541000.9201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The oom killer's goal is to kill a memory-hogging task so that it may
exit, free its memory, and allow the current context to allocate the
memory that triggered it in the first place.  Thus, killing a task is
pointless if other threads sharing its mm cannot be killed because of its
/proc/pid/oom_adj or /proc/pid/oom_score_adj value.

This patch checks whether any other thread sharing p->mm has an
oom_score_adj of OOM_SCORE_ADJ_MIN.  If so, the thread cannot be killed
and oom_badness(p) returns 0, meaning it's unkillable.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -162,10 +162,11 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		return 0;
 
 	/*
-	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
-	 * need to be executed for something that cannot be killed.
+	 * Shortcut check for a thread sharing p->mm that is OOM_SCORE_ADJ_MIN
+	 * so the entire heuristic doesn't need to be executed for something
+	 * that cannot be killed.
 	 */
-	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+	if (atomic_read(&p->mm->oom_disable_count)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -675,7 +676,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
-	    (current->signal->oom_adj != OOM_DISABLE)) {
+	    current->mm && !atomic_read(&current->mm->oom_disable_count)) {
 		/*
 		 * oom_kill_process() needs tasklist_lock held.  If it returns
 		 * non-zero, current could not be killed so we must fallback to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
