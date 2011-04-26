Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 422528D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:43:44 -0400 (EDT)
Received: by pvc12 with SMTP id 12so221246pvc.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:43:42 -0700 (PDT)
Date: Tue, 26 Apr 2011 10:54:29 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH] use oom_killer_disabled in all oom pathes
Message-ID: <20110426025429.GA11812@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

oom_killer_disable should be a global switch, also fit for oom paths
other than __alloc_pages_slowpath 

Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 mm/memcontrol.c |    2 +-
 mm/oom_kill.c   |    3 +++

 2 files changed, 4 insertions(+), 1 deletion(-)
--- linux-2.6.orig/mm/memcontrol.c	2011-04-20 15:49:10.336660690 +0800
+++ linux-2.6/mm/memcontrol.c	2011-04-26 10:41:04.746459757 +0800
@@ -1610,7 +1610,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || mem->oom_kill_disable)
+	if (!locked || mem->oom_kill_disable || oom_killer_disabled)
 		need_to_kill = false;
 	if (locked)
 		mem_cgroup_oom_notify(mem);
--- linux-2.6.orig/mm/oom_kill.c	2011-04-20 15:49:10.353327356 +0800
+++ linux-2.6/mm/oom_kill.c	2011-04-26 10:41:04.753126423 +0800
@@ -747,6 +747,9 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	if (oom_killer_disabled)
+		return;
+
 	if (try_set_system_oom()) {
 		out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
