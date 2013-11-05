Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id B65CD6B00A0
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 18:27:29 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ma3so8103204pbc.4
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:27:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.186])
        by mx.google.com with SMTP id ul9si3473320pab.287.2013.11.05.15.27.27
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 15:27:28 -0800 (PST)
Received: by mail-ve0-f202.google.com with SMTP id pa12so398946veb.5
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:27:26 -0800 (PST)
From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH] mm, oom: Fix race when selecting process to kill
Date: Tue,  5 Nov 2013 15:26:27 -0800
Message-Id: <1383693987-14171-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sameer Nanda <snanda@chromium.org>

The selection of the process to be killed happens in two spots -- first
in select_bad_process and then a further refinement by looking for
child processes in oom_kill_process. Since this is a two step process,
it is possible that the process selected by select_bad_process may get a
SIGKILL just before oom_kill_process executes. If this were to happen,
__unhash_process deletes this process from the thread_group list. This
then results in oom_kill_process getting stuck in an infinite loop when
traversing the thread_group list of the selected process.

Fix this race by holding the tasklist_lock across the calls to both
select_bad_process and oom_kill_process.

Change-Id: I8f96b106b3257b5c103d6497bac7f04f4dff4e60
Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 mm/oom_kill.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6738c47..7bd3587 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -436,7 +436,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
-	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -456,7 +455,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			}
 		}
 	} while_each_thread(p, t);
-	read_unlock(&tasklist_lock);
 
 	rcu_read_lock();
 	p = find_lock_task_mm(victim);
@@ -641,6 +639,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
 	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
 
+	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
@@ -663,6 +662,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		killed = 1;
 	}
 out:
+	read_unlock(&tasklist_lock);
 	/*
 	 * Give the killed threads a good chance of exiting before trying to
 	 * allocate memory again.
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
