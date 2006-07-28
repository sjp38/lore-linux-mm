From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210622.30275.83981.sendpatchset@linux.site>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 6/9] oom: handle oom_disable exiting
Date: Fri, 28 Jul 2006 09:21:37 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Having the oomkilladj == OOM_DISABLE check before the releasing check means
that oomkilladj == OOM_DISABLE tasks exiting will not stop the OOM killer.

Moving the test down will give the desired behaviour. Also: it will allow
them to "OOM-kill" themselves if they are exiting. As per the previous patch,
this is required to prevent OOM killer deadlocks (and they don't actually
get killed, because they're already exiting -- they're simply allowed access
to memory reserves).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/oom_kill.c
===================================================================
--- linux-2.6.orig/mm/oom_kill.c
+++ linux-2.6/mm/oom_kill.c
@@ -202,8 +202,6 @@ static struct task_struct *select_bad_pr
 		/* skip the init task with pid == 1 */
 		if (p->pid == 1)
 			continue;
-		if (p->oomkilladj == OOM_DISABLE)
-			continue;
 
 		/*
 		 * This is in the process of releasing memory so wait for it
@@ -228,6 +226,8 @@ static struct task_struct *select_bad_pr
 			}
 			return ERR_PTR(-1UL);
 		}
+		if (p->oomkilladj == OOM_DISABLE)
+			continue;
 		if (p->flags & PF_SWAPOFF)
 			return p;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
