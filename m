Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE0F6B01E6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:19:25 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o517JO0f023805
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:24 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz5.hot.corp.google.com with ESMTP id o517JMnq025906
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:23 -0700
Received: by pzk36 with SMTP id 36so1186215pzk.32
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:19:22 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:19:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 18/18] oom: clean up oom_kill_task()
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010017500.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__oom_kill_task() only has a single caller, so merge it into that
function.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -440,17 +440,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_tasks(mem);
 }
 
-/*
- * Give the oom killed task high priority and access to memory reserves so that
- * it may quickly exit and free its memory.
- */
-static void __oom_kill_task(struct task_struct *p)
-{
-	p->rt.time_slice = HZ;
-	set_tsk_thread_flag(p, TIF_MEMDIE);
-	force_sig(SIGKILL, p);
-}
-
 #define K(x) ((x) << (PAGE_SHIFT-10))
 static int oom_kill_task(struct task_struct *p)
 {
@@ -465,7 +454,9 @@ static int oom_kill_task(struct task_struct *p)
 		K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
-	__oom_kill_task(p);
+	p->rt.time_slice = HZ;
+	set_tsk_thread_flag(p, TIF_MEMDIE);
+	force_sig(SIGKILL, p);
 	return 0;
 }
 #undef K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
