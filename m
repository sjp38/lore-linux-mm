Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 7BA636B0265
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:44:37 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3510751dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:44:36 -0700 (PDT)
Date: Fri, 22 Jun 2012 14:44:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3.5-rc3] mm, oom: fix potential killing of thread that is
 disabled from oom killing
Message-ID: <alpine.DEB.2.00.1206221443210.23486@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

/proc/sys/vm/oom_kill_allocating_task will immediately kill current when
the oom killer is called to avoid a potentially expensive tasklist scan
for large systems.

Currently, however, it is not checking current's oom_score_adj value
which may be OOM_SCORE_ADJ_MIN, meaning that it has been disabled from
oom killing.

This patch avoids killing current in such a condition and simply falls
back to the tasklist scan since memory still needs to be freed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -720,9 +720,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
 
 	read_lock(&tasklist_lock);
-	if (sysctl_oom_kill_allocating_task &&
+	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
-	    current->mm) {
+	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		oom_kill_process(current, gfp_mask, order, 0, totalpages, NULL,
 				 nodemask,
 				 "Out of memory (oom_kill_allocating_task)");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
