From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210631.30275.91145.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 7/9] oom: swapoff tasks tweak
Date: Fri, 28 Jul 2006 09:21:45 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

PF_SWAPOFF processes currently cause select_bad_process to return straight
away. Instead, give them high priority, so we will kill them first, however
we also first ensure no parallel OOM kills are happening at the same time.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -58,6 +58,12 @@ unsigned long badness(struct task_struct
 	}
 
 	/*
+	 * swapoff can easily use up all memory, so kill those first.
+	 */
+	if (p->flags & PF_SWAPOFF)
+		return ULONG_MAX;
+
+	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
 	points = mm->total_vm;
@@ -228,8 +234,6 @@ static struct task_struct *select_bad_pr
 		}
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
-		if (p->flags & PF_SWAPOFF)
-			return p;
 
 		points = badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
