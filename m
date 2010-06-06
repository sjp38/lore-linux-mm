Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1C26B01BA
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:30 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o56MYQUB022729
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:26 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz29.hot.corp.google.com with ESMTP id o56MYOAB029229
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:25 -0700
Received: by pxi12 with SMTP id 12so2928371pxi.0
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:24 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's unnecessary to SIGKILL a task that is already PF_EXITING and can
actually cause a NULL pointer dereference of the sighand if it has already
been detached.  Instead, simply set TIF_MEMDIE so it has access to memory
reserves and can quickly exit as the comment implies.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -458,7 +458,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
+		set_tsk_thread_flag(p, TIF_MEMDIE);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
