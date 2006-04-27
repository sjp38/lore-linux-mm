From: Dave Peterson <dsp@llnl.gov>
Subject: [PATCH 2/2 (repost)] mm: avoid unnecessary looping in out_of_memory()
Date: Thu, 27 Apr 2006 13:08:11 -0700
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604271308.11553.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de, akpm@osdl.org
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
This is a repost of a previous patch.  It applies to kernel
2.6.17-rc3 (after applying patch 1/2).


Index: linux-2.6.17-rc3-oom/mm/oom_kill.c
===================================================================
--- linux-2.6.17-rc3-oom.orig/mm/oom_kill.c	2006-04-27 12:08:36.000000000 -0700
+++ linux-2.6.17-rc3-oom/mm/oom_kill.c	2006-04-27 12:08:36.000000000 -0700
@@ -366,7 +366,6 @@ void out_of_memory(struct zonelist *zone
 		break;
 
 	case CONSTRAINT_NONE:
-retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
@@ -385,9 +384,7 @@ retry:
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
