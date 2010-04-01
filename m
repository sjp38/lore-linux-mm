Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 556E06B01F7
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:51 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o31JieSl016271
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:44:40 +0200
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by hpaq5.eem.corp.google.com with ESMTP id o31JiVDL016661
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:44:39 +0200
Received: by pvb32 with SMTP id 32so586386pvb.16
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:38 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 4/5] oom: cleanup oom_kill_task
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004011243460.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__oom_kill_task() only has a single caller, so merge it into that
function.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -415,17 +415,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
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
@@ -440,7 +429,9 @@ static int oom_kill_task(struct task_struct *p)
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
