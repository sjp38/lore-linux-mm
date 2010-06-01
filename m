Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD376B01E4
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:19:23 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o517JKi2020178
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:20 -0700
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by wpaz17.hot.corp.google.com with ESMTP id o517JIhh032715
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:18 -0700
Received: by pzk13 with SMTP id 13so2537943pzk.13
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:19:18 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:19:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 17/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010017360.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
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
@@ -486,7 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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
