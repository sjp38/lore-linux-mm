Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1746B01EF
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:40 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o31JibZl013602
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:37 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz29.hot.corp.google.com with ESMTP id o31JiRTS018332
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:36 -0700
Received: by pwi7 with SMTP id 7so1307641pwi.21
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:36 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 3/5] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004011243300.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's unnecessary to SIGKILL a task that is already PF_EXITING and can
actually cause a NULL pointer dereference of the sighand if it has
already been detached.  Instead, simply set TIF_MEMDIE so it has access
to memory reserves and can quickly exit as the comment implies.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -462,7 +462,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p);
+		set_tsk_thread_flag(p, TIF_MEMDIE);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
