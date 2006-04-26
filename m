From: Dave Peterson <dsp@llnl.gov>
Subject: [PATCH 2/2] mm: avoid unnecessary looping in out_of_memory()
Date: Tue, 25 Apr 2006 17:01:33 -0700
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604251701.33701.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

I see no reason to loop in out_of_memory().  If oom_kill_process()
returns 1, this may be because the task that select_bad_process()
chose is now exiting (and therefore oom_kill_task() found the ->mm
pointer of the chosen task to be NULL).  out_of_memory() may as well
return to its caller, perhaps avoiding the need to shoot a process.
If the memory issues are still not resolved, out_of_memory() will be
called again so there's no reason to loop.

Signed-Off-By: David S. Peterson <dsp@llnl.gov>
---
This patch applies to kernel 2.6.17-rc2-git7 (after applying patch
1/2).

Index: git7-oom/mm/oom_kill.c
===================================================================
--- git7-oom.orig/mm/oom_kill.c	2006-04-25 16:21:48.000000000 -0700
+++ git7-oom/mm/oom_kill.c	2006-04-25 16:21:59.000000000 -0700
@@ -374,7 +374,6 @@ void out_of_memory(struct zonelist *zone
 		break;
 
 	case CONSTRAINT_NONE:
-retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
@@ -393,9 +392,7 @@ retry:
 			panic("Out of memory and no killable processes...\n");
 		}
 
-		if (oom_kill_process(p, points, "Out of memory"))
-			goto retry;
-
+		cancel = oom_kill_process(p, points, "Out of memory");
 		break;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
