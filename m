From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210639.30275.10851.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 8/9] oom: kthread infinite loop fix
Date: Fri, 28 Jul 2006 09:21:54 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Skip kernel threads, rather than having them return 0 from badness.
Theoretically, badness might truncate all results to 0, thus a kernel thread
might be picked first, causing an infinite loop.

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -205,6 +205,9 @@ static struct task_struct *select_bad_pr
 		unsigned long points;
 		int releasing;
 
+		/* skip kernel threads */
+		if (!p->mm)
+			continue;
 		/* skip the init task with pid == 1 */
 		if (p->pid == 1)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
