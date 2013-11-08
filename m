Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CCD8F6B01A4
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 13:07:22 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fb1so2555267pad.31
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 10:07:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.167])
        by mx.google.com with SMTP id p2si7329287pbe.278.2013.11.08.10.07.20
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 10:07:21 -0800 (PST)
Received: by mail-yh0-f73.google.com with SMTP id z20so187530yhz.0
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 10:07:19 -0800 (PST)
From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH v2] mm, oom: Fix race when selecting process to kill
Date: Fri,  8 Nov 2013 10:07:15 -0800
Message-Id: <1383934035-933-1-git-send-email-snanda@chromium.org>
In-Reply-To: <alpine.DEB.2.02.1311061631280.22318@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311061631280.22318@chino.kir.corp.google.com>
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

Change-Id: I865c64486ccfc0e4818e7045a8fa3353e2fb63f8
Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 mm/oom_kill.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6738c47..af99b1a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -412,13 +412,16 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
+	read_lock(&tasklist_lock);
+
 	/*
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
 
@@ -436,7 +439,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
-	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
