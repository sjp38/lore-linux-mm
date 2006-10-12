From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061012120111.29671.83152.sendpatchset@linux.site>
In-Reply-To: <20061012120102.29671.31163.sendpatchset@linux.site>
References: <20061012120102.29671.31163.sendpatchset@linux.site>
Subject: [patch 1/5] oom: don't kill unkillable children or siblings
Date: Thu, 12 Oct 2006 16:09:43 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Abort the kill if any of our threads have OOM_DISABLE set. Having this test
here also prevents any OOM_DISABLE child of the "selected" process from being
killed.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -312,15 +312,24 @@ static int oom_kill_task(struct task_str
 	if (mm == NULL)
 		return 1;
 
+	/*
+	 * Don't kill the process if any threads are set to OOM_DISABLE
+	 */
+	do_each_thread(g, q) {
+		if (q->mm == mm && p->oomkilladj == OOM_DISABLE)
+			return 1;
+	} while_each_thread(g, q);
+
 	__oom_kill_task(p, message);
+
 	/*
 	 * kill all processes that share the ->mm (i.e. all threads),
 	 * but are in a different thread group
 	 */
-	do_each_thread(g, q)
+	do_each_thread(g, q) {
 		if (q->mm == mm && q->tgid != p->tgid)
 			__oom_kill_task(q, message);
-	while_each_thread(g, q);
+	} while_each_thread(g, q);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
