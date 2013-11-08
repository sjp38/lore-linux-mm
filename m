Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 671986B01A8
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 14:50:17 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so2589145pbc.12
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 11:50:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.133])
        by mx.google.com with SMTP id ru9si7606171pbc.108.2013.11.08.11.49.54
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 11:49:56 -0800 (PST)
Received: by mail-ob0-f202.google.com with SMTP id gq1so398305obb.3
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 11:49:53 -0800 (PST)
From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH v3] mm, oom: Fix race when selecting process to kill
Date: Fri,  8 Nov 2013 11:49:33 -0800
Message-Id: <1383940173-16480-1-git-send-email-snanda@chromium.org>
In-Reply-To: <20131108184515.GA11555@redhat.com>
References: <20131108184515.GA11555@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, oleg@redhat.com, dserrg@gmail.com, msb@chromium.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sameer Nanda <snanda@chromium.org>

The selection of the process to be killed happens in two spots:
first in select_bad_process and then a further refinement by
looking for child processes in oom_kill_process. Since this is
a two step process, it is possible that the process selected by
select_bad_process may get a SIGKILL just before oom_kill_process
executes. If this were to happen, __unhash_process deletes this
process from the thread_group list. This results in oom_kill_process
getting stuck in an infinite loop when traversing the thread_group
list of the selected process.

Fix this race by adding a pid_alive check for the selected process
with tasklist_lock held in oom_kill_process.

Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 mm/oom_kill.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6738c47..7b28d9f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -413,12 +413,20 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 					      DEFAULT_RATELIMIT_BURST);
 
 	/*
+	 * while_each_thread is currently not RCU safe. Lets hold the
+	 * tasklist_lock across all invocations of while_each_thread (including
+	 * the one in find_lock_task_mm) in this function.
+	 */
+	read_lock(&tasklist_lock);
+
+	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (p->flags & PF_EXITING) {
+	if (p->flags & PF_EXITING || !pid_alive(p)) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
+		read_unlock(&tasklist_lock);
 		return;
 	}
 
@@ -436,7 +444,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
-	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -456,10 +463,18 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			}
 		}
 	} while_each_thread(p, t);
-	read_unlock(&tasklist_lock);
 
 	rcu_read_lock();
+
 	p = find_lock_task_mm(victim);
+
+	/*
+	 * Since while_each_thread is currently not RCU safe, this unlock of
+	 * tasklist_lock may need to be moved further down if any additional
+	 * while_each_thread loops get added to this function.
+	 */
+	read_unlock(&tasklist_lock);
+
 	if (!p) {
 		rcu_read_unlock();
 		put_task_struct(victim);
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
